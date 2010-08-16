    //
//  SGMainViewController.m
//  SGLayerUpdater
//
//  Created by Derek Smith on 8/15/10.
//  Copyright 2010 SimpleGeo. All rights reserved.
//

#import "SGMainViewController.h"

@interface SGMainViewController (Private)

- (BOOL) isRequestId:(NSString*)requestIdOne equalTo:(NSString*)requestIdTwo;
- (void) refresh:(id)button;

@end

@implementation SGMainViewController

- (id) initWithLayer:(NSString*)layerName
{
    if(self = [super init]) {        
        createRecordViewController = [[SGCreateRecordViewController alloc] initWithStyle:UITableViewStyleGrouped];
        createRecordNavigationViewController = [[UINavigationController alloc] initWithRootViewController:createRecordViewController];
        locationService = [SGLocationService sharedLocationService];
        [locationService addDelegate:self];
        
        layer = layerName;
        
        sendRequestId = nil;
        deleteRequestId = nil;
        nearbyRequestId = nil;
    }
    
    return self;
}

////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark UIViewController overrides 
//////////////////////////////////////////////////////////////////////////////////////////////// 

- (void) loadView
{
    [super loadView];
    
    self.title = @"SGRecordUpdater";
    
    UIBarButtonItem* sendButton = [[UIBarButtonItem alloc] initWithTitle:@"Send"
                                                                   style:UIBarButtonItemStyleBordered
                                                                  target:self
                                                                  action:@selector(send:)];
    UIBarButtonItem* cancelButton = [[UIBarButtonItem alloc] initWithTitle:@"Cancel"
                                                                     style:UIBarButtonItemStyleBordered
                                                                    target:self
                                                                    action:@selector(cancel:)];
    
    createRecordViewController.navigationItem.rightBarButtonItem = sendButton;
    createRecordViewController.navigationItem.leftBarButtonItem = cancelButton;
    [sendButton release];
    [cancelButton release];
    
    layerMapView = [[SGLayerMapView alloc] initWithFrame:self.view.bounds];
    [layerMapView addLayers:[NSArray arrayWithObject:[[SGLayer alloc] initWithLayerName:layer]]];
    layerMapView.delegate = self;
    layerMapView.showsUserLocation = YES;
    layerMapView.addRetrievedRecordsToLayer = NO;

    // We want to update the map explicitlty
    layerMapView.reloadTimeInterval = -1.0;
    [self.view addSubview:layerMapView];
    
    UIBarButtonItem* addRecordButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                                                                     target:self
                                                                                     action:@selector(addRecord:)];

    refreshButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh
                                                                                  target:self 
                                                                                  action:@selector(refresh:)];
    UIActivityIndicatorView* activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    [activityView startAnimating];
    spinningButton = [[UIBarButtonItem alloc] initWithCustomView:activityView];
    self.navigationItem.rightBarButtonItem = addRecordButton;
    
    [self setToolbarItems:[NSArray arrayWithObject:refreshButton] animated:NO];
    [self.navigationController setToolbarHidden:NO animated:NO];    
    
    [self refresh:refreshButton];
    [refreshButton release];
    [addRecordButton release];    
}

////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark UIButton actions 
//////////////////////////////////////////////////////////////////////////////////////////////// 

- (void) addRecord:(id)button
{
    [self.navigationController presentModalViewController:createRecordNavigationViewController animated:YES];
}

- (void) refresh:(id)button
{
    if(!nearbyRequestId) {
        // Clear the map
        [layerMapView removeAnnotations:[NSArray arrayWithArray:layerMapView.annotations]];
        [layerMapView startRetrieving];
        nearbyRequestId = @"request";
        [self setToolbarItems:[NSArray arrayWithObject:spinningButton] animated:NO];
    }    
}

- (void) cancel:(id)button
{
    [createRecordNavigationViewController dismissModalViewControllerAnimated:YES];
}

- (void) send:(id)button
{
    if(!sendRequestId) {
        SGRecord* newRecord = createRecordViewController.record;
        newRecord.layer = layer;
        sendRequestId = [locationService updateRecordAnnotation:newRecord];
        [self cancel:button];
    }
}

////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark SGLocationService delegate methods 
//////////////////////////////////////////////////////////////////////////////////////////////// 

- (void) locationService:(SGLocationService*)service succeededForResponseId:(NSString*)requestId responseObject:(NSObject*)responseObject
{
    if([self isRequestId:requestId equalTo:deleteRequestId]) {
        deleteRequestId = nil;
    } else if([self isRequestId:requestId equalTo:sendRequestId]) {  
        SGRecord* record = (SGRecord*)[SGGeoJSONEncoder recordForGeoJSONObject:(NSDictionary*)responseObject];
        [layerMapView addAnnotation:record];
        sendRequestId = nil;
    } else {
        [self setToolbarItems:[NSArray arrayWithObject:refreshButton] animated:NO];   
        nearbyRequestId = nil;
    }
}

- (void) locationService:(SGLocationService*)service failedForResponseId:(NSString*)requestId error:(NSError*)error
{
    ;
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
            [layerMapView removeAnnotation:record];            
            deleteRequestId = [locationService deleteRecordAnnotation:record];
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
    [nearbyRequestId release];
    
    [layer release];
    
    [refreshButton release];
    [spinningButton release];
    
    [super dealloc];
}

@end
