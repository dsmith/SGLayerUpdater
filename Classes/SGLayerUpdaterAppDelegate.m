//
//  SGLayerUpdaterAppDelegate.m
//  SGLayerUpdater
//
//  Created by Derek Smith on 8/15/10.
//  Copyright SimpleGeo 2010. All rights reserved.
//

#import "SGLayerUpdaterAppDelegate.h"

@implementation SGLayerUpdaterAppDelegate
@synthesize window;

////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Application lifecycle 
//////////////////////////////////////////////////////////////////////////////////////////////// 

- (BOOL) application:(UIApplication*)application didFinishLaunchingWithOptions:(NSDictionary*)launchOptions
{
    [window makeKeyAndVisible];
    
    
	
	return YES;
}

- (void) dealloc
{        
    [window release];
    [super dealloc];
}

@end

