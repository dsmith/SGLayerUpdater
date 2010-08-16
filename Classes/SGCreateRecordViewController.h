//
//  SGCreateRecordViewController.h
//  SGLayerUpdater
//
//  Created by Derek Smith on 8/15/10.
//  Copyright 2010 SimpleGeo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SGCreateRecordViewController : UITableViewController {

    SGRecord* record;
    
    @private
    UITextField* recordIdTextField;
    UITextField* latitudeTextField;
    UITextField* longitudeTextField;
    UITextField* noteTextField;
}

@property (nonatomic, readonly) SGRecord* record;

@end
