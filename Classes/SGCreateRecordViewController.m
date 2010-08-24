//
//  SGCreateRecordViewController.m
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

#import "SGCreateRecordViewController.h"

enum SGCreateRecordViewControllerSection {
    kSGCreateRecordViewControllerSection_Name = 0,
    kSGCreateRecordViewControllerSection_Location,
    kSGCreateRecordViewControllerSection_Note,

    kSGCreateRecordViewControllerSection_Amount
};

typedef NSInteger SGCreateRecordViewControllerSection;

@interface SGCreateRecordViewController (Private) <UITextFieldDelegate>

- (UITextField*) createTextField;
- (UITextField*) textFieldForIndexPath:(NSIndexPath*)indexPath;

@end

@implementation SGCreateRecordViewController
@dynamic record;

- (id) initWithStyle:(UITableViewStyle)style
{
    if(self = [super initWithStyle:style]) {
        self.title = @"Create Record";
        locationManager = [[CLLocationManager alloc] init];
        [locationManager startUpdatingLocation];
    }
    
    return self;
}

- (void) loadView
{
    [super loadView];
    
    recordIdTextField = [self createTextField];
    latitudeTextField = [self createTextField];
    longitudeTextField = [self createTextField];
    noteTextField = [self createTextField];
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    latitudeTextField.text = [NSString stringWithFormat:@"%f", locationManager.location.coordinate.latitude];
    longitudeTextField.text = [NSString stringWithFormat:@"%f", locationManager.location.coordinate.longitude];
    recordIdTextField.text = @"default";
    noteTextField.text = @"";
    
    [self.tableView reloadData];
}

////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Accessor methods 
//////////////////////////////////////////////////////////////////////////////////////////////// 

- (SGRecord*) record
{
    SGRecord* newRecord = [[SGRecord alloc] init];
    newRecord.latitude = [latitudeTextField.text doubleValue];
    newRecord.longitude = [longitudeTextField.text doubleValue];
    newRecord.recordId = recordIdTextField.text;
    [newRecord.properties setObject:noteTextField.text forKey:@"note"];
    return newRecord;
}

////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark UITableView delegate methods 
////////////////////////////////////////////////////////////////////////////////////////////////

- (void) tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath
{
    [[self textFieldForIndexPath:indexPath] becomeFirstResponder];
}

////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark UITableView delegate methods 
////////////////////////////////////////////////////////////////////////////////////////////////

- (UITableViewCell*) tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath
{
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"TextFieldCell"];
    if(!cell)
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"TextFieldCell"] autorelease];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    switch (indexPath.section) {
        case kSGCreateRecordViewControllerSection_Name:
        {
            cell.textLabel.text = @"ID";
        }
            break;
        case kSGCreateRecordViewControllerSection_Location:
        {
            if(indexPath.row)
                cell.textLabel.text = @"Latitude";
            else
                cell.textLabel.text = @"Longitude";
        }
            break;
        case kSGCreateRecordViewControllerSection_Note:
        {
            cell.textLabel.text = @"Note";
        }
            break;
        default:
            break;
    }
    
    [cell.contentView addSubview:[self textFieldForIndexPath:indexPath]];
    return cell;
}

- (NSInteger) numberOfSectionsInTableView:(UITableView*)tableView
{
    return kSGCreateRecordViewControllerSection_Amount;
}

- (NSInteger) tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger rows = 0;
    switch (section) {
        case kSGCreateRecordViewControllerSection_Name:
            rows = 1;
            break;
        case kSGCreateRecordViewControllerSection_Location:
            rows = 2;
            break;
        case kSGCreateRecordViewControllerSection_Note:
            rows = 1;
            break;
        default:
            break;
    }
    
    return rows;
}

- (NSString*) tableView:(UITableView*)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString* title = nil;
    switch (section) {
        case kSGCreateRecordViewControllerSection_Name:
            title = @"Record ID";
            break;
        case kSGCreateRecordViewControllerSection_Location:
            title = @"Location";
            break;
        case kSGCreateRecordViewControllerSection_Note:
            title = @"Properties (optional)";
            break;
        default:
            break;
    }
    
    return title;
}

- (BOOL) tableView:(UITableView*)tableView canEditRowAtIndexPath:(NSIndexPath*)indexPath
{
    return NO;
}

- (BOOL) textFieldShouldReturn:(UITextField*)textField
{
    [textField resignFirstResponder];
    return YES;
}

////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Utility methods 
//////////////////////////////////////////////////////////////////////////////////////////////// 

- (UITextField*) createTextField
{
    UITextField* textField = [[UITextField alloc] initWithFrame:CGRectMake(120.0, 10.0, 174.0, 38.0)];
    textField.delegate = self;
    textField.adjustsFontSizeToFitWidth = YES;
    textField.autocorrectionType = UITextAutocorrectionTypeNo;
    textField.returnKeyType = UIReturnKeyDone;
    return textField;
}

- (UITextField*) textFieldForIndexPath:(NSIndexPath*)indexPath
{
    UITextField* textField = nil;
    switch (indexPath.section) {
        case kSGCreateRecordViewControllerSection_Name:
        {
            textField = recordIdTextField;
        }
            break;
        case kSGCreateRecordViewControllerSection_Location:
        {
            if(indexPath.row)
                textField = latitudeTextField;
            else 
                textField = longitudeTextField;
        }
            break;
        case kSGCreateRecordViewControllerSection_Note:
        {
            textField = noteTextField;
        }
            break;
        default:
            break;
    }

    return textField;
}

- (void) dealloc
{
    [recordIdTextField release];
    [latitudeTextField release];
    [longitudeTextField release];
    [noteTextField release];

    [locationManager release];
    [super dealloc];
}

@end
