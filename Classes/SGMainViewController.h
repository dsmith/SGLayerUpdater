//
//  SGMainViewController.h
//  SGLayerUpdater
//
//  Created by Derek Smith on 8/15/10.
//  Copyright 2010 SimpleGeo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

#import "SGCreateRecordViewController.h"


@interface SGMainViewController : UIViewController <SGLocationServiceDelegate, MKMapViewDelegate> {

    @private
    SGLayerMapView* layerMapView;

    SGCreateRecordViewController* createRecordViewController;
    UINavigationController* createRecordNavigationViewController;

    SGLocationService* locationService;
    
    NSString* deleteRequestId;
    NSString* sendRequestId;
    NSString* nearbyRequestId;
    
    NSString* layer;
    
    UIBarButtonItem* refreshButton;
    UIBarButtonItem* spinningButton;
}

@end
