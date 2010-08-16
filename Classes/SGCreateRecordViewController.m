    //
//  SGCreateRecordViewController.m
//  SGLayerUpdater
//
//  Created by Derek Smith on 8/15/10.
//  Copyright 2010 SimpleGeo. All rights reserved.
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

    CLLocation* currentLocation = [SGLocationService sharedLocationService].locationManager.location;
    latitudeTextField.text = [NSString stringWithFormat:@"%f", currentLocation.coordinate.latitude];
    longitudeTextField.text = [NSString stringWithFormat:@"%f", currentLocation.coordinate.longitude];
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
    
    [super dealloc];
}

@end
