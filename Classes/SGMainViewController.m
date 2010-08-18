    //
//  SGMainViewController.m
//  SGLayerUpdater
//
//  Copyright (c) 2009-2010, SimpleGeo
//  All rights reserved.
//
//  Redistribution and use in source and binary forms, with or without 
//  modification, are permitted provided that the following conditions are met:
//
//  Redistributions of source code must retain the above copyright notice, 
//  this list of conditions and the following disclaimer. Redistributions 
//  in binary form must reproduce the above copyright notice, this list of
//  conditions and the following disclaimer in the documentation and/or 
//  other materials provided with the distribution.
//  
//  Neither the name of the SimpleGeo nor the names of its contributors may
//  be used to endorse or promote products derived from this software 
//  without specific prior written permission.
//   
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
//  AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE 
//  IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE 
//  ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS 
//  BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR 
//  CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE 
//  GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER 
//  CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
//  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, 
//  EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//
//  Created by Derek Smith.
//

#import "SGMainViewController.h"

@interface SGMainViewController (Private)

- (BOOL) isRequestId:(NSString*)requestIdOne equalTo:(NSString*)requestIdTwo;
- (void) initializeCreateRecordViewController;

@end

@implementation SGMainViewController

- (id) initWithLayer:(NSString*)name
{
    if(self = [super init]) {
        locationService = [SGLocationService sharedLocationService];
        [locationService addDelegate:self];
        
        layerName = [name retain];
        
        sendRequestId = nil;
        deleteRequestId = nil;
    }
    
    return self;
}

- (void) initializeCreateRecordViewController
{
    createRecordViewController = [[SGCreateRecordViewController alloc] initWithStyle:UITableViewStyleGrouped];
    createRecordNavigationViewController = [[UINavigationController alloc] initWithRootViewController:createRecordViewController];

    UIBarButtonItem* sendButton = [[UIBarButtonItem alloc] initWithTitle:@"Send"
                                                                   style:UIBarButtonItemStyleBordered
                                                                  target:self
                                                                  action:@selector(updateRecord:)];
    UIBarButtonItem* cancelButton = [[UIBarButtonItem alloc] initWithTitle:@"Cancel"
                                                                     style:UIBarButtonItemStyleBordered
                                                                    target:self
                                                                    action:@selector(hideCreateRecordViewController:)];
    
    createRecordViewController.navigationItem.rightBarButtonItem = sendButton;
    createRecordViewController.navigationItem.leftBarButtonItem = cancelButton;
    [sendButton release];
    [cancelButton release];    
}

////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark UIViewController overrides 
//////////////////////////////////////////////////////////////////////////////////////////////// 

- (void) loadView
{
    [super loadView];
    
    self.title = @"SGRecordUpdater";
        
    layerMapView = [[SGLayerMapView alloc] initWithFrame:self.view.bounds];
    [layerMapView addLayers:[NSArray arrayWithObject:[[SGLayer alloc] initWithLayerName:layerName]]];

    layerMapView.addRetrievedRecordsToLayer = NO;
    layerMapView.delegate = self;

    [self.view addSubview:layerMapView];
    [layerMapView startRetrieving];
    
    [self initializeCreateRecordViewController];
    UIBarButtonItem* addRecordButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                                                                     target:self
                                                                                     action:@selector(showCreateRecordViewController:)];

    self.navigationItem.rightBarButtonItem = addRecordButton;
    [addRecordButton release];    
}

////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark UIButton actions 
//////////////////////////////////////////////////////////////////////////////////////////////// 

- (void) showCreateRecordViewController:(id)button
{
    [self.navigationController presentModalViewController:createRecordNavigationViewController animated:YES];
}

- (void) hideCreateRecordViewController:(id)button
{
    [createRecordNavigationViewController dismissModalViewControllerAnimated:YES];
}

- (void) updateRecord:(id)button
{
    if(!sendRequestId) {
        SGRecord* newRecord = createRecordViewController.record;
        newRecord.layer = layerName;

        sendRequestId = [locationService updateRecordAnnotation:newRecord];

        [createRecordNavigationViewController dismissModalViewControllerAnimated:YES];
    }
}

////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark SGLocationService delegate methods 
//////////////////////////////////////////////////////////////////////////////////////////////// 

- (void) locationService:(SGLocationService*)service succeededForResponseId:(NSString*)requestId responseObject:(NSObject*)responseObject
{
    if([self isRequestId:requestId equalTo:sendRequestId]) {  
        id<SGRecordAnnotation> recordAnnotation = [SGGeoJSONEncoder recordForGeoJSONObject:(NSDictionary*)responseObject];
        [layerMapView addAnnotation:recordAnnotation];
        sendRequestId = nil;
    } else if([self isRequestId:requestId equalTo:deleteRequestId]) {
        deleteRequestId = nil;
    }
}

- (void) locationService:(SGLocationService*)service failedForResponseId:(NSString*)requestId error:(NSError*)error
{
    if([self isRequestId:requestId equalTo:deleteRequestId] || [self isRequestId:requestId equalTo:sendRequestId]) {
        UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"ERROR!!!"
                                                            message:[error description]
                                                           delegate:self
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
        [alertView show];
        [alertView release];
    }
}

////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark MKMapView delegate methods 
//////////////////////////////////////////////////////////////////////////////////////////////// 

- (MKAnnotationView*) mapView:(MKMapView*)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    MKAnnotationView* annotationView = nil;
    if([annotation isKindOfClass:[SGRecord class]]) {
        MKPinAnnotationView* pinAnnotationView = (MKPinAnnotationView*)[mapView dequeueReusableAnnotationViewWithIdentifier:@"RecordPin"];
        if(!pinAnnotationView) {
            pinAnnotationView = [[[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"RecordPin"] autorelease];
            
            UIButton* deleteButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
            deleteButton.frame = CGRectMake(0.0, 0.0, 50.0, 20.0);
            [deleteButton setTitle:@"Delete" forState:UIControlStateNormal];
            deleteButton.titleLabel.textColor = [UIColor redColor];
            deleteButton.tag = 0;

            UIButton* noteButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
            noteButton.frame = deleteButton.frame;
            [noteButton setTitle:@"Note" forState:UIControlStateNormal];
            noteButton.tag = 1;
            
            pinAnnotationView.leftCalloutAccessoryView = noteButton;
            pinAnnotationView.rightCalloutAccessoryView = deleteButton;
            pinAnnotationView.canShowCallout = YES;
        }
        
        pinAnnotationView.annotation = annotation;
        annotationView = pinAnnotationView;
    }
    
    return annotationView;
}

- (void) mapView:(MKMapView*)mapView annotationView:(MKAnnotationView*)annotationView calloutAccessoryControlTapped:(UIControl*)control
{
    if([annotationView.annotation isKindOfClass:[SGRecord class]]) {
        SGRecord* record = (SGRecord*)annotationView.annotation;
        if(control.tag) {
            UIAlertView* noteAlertView = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"%@'s Note", record.recordId]
                                                                    message:[record.properties objectForKey:@"note"]
                                                                   delegate:self
                                                          cancelButtonTitle:@"Done"
                                                          otherButtonTitles:nil];
            [noteAlertView show];
            [noteAlertView release];
        } else {
            if(!deleteRequestId) {
                [layerMapView removeAnnotation:record];            
                deleteRequestId = [locationService deleteRecordAnnotation:record];
            }
        }
    }
}

////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Utility methods 
//////////////////////////////////////////////////////////////////////////////////////////////// 

- (BOOL) isRequestId:(NSString*)requestIdOne equalTo:(NSString*)requestIdTwo
{
    return requestIdOne && requestIdTwo && [requestIdOne isEqualToString:requestIdTwo];
}

- (void) dealloc
{
    [layerMapView release];
    
    [createRecordViewController release];
    [createRecordNavigationViewController release];
    
    [locationService release];
    
    [deleteRequestId release];
    [sendRequestId release];
    
    [layerName release];
    
    [super dealloc];
}

@end
