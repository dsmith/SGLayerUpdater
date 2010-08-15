//
//  SGLayerUpdaterAppDelegate.m
//  SGLayerUpdater
//
//  Created by Derek Smith on 8/15/10.
//  Copyright SimpleGeo 2010. All rights reserved.
//

#import "SGLayerUpdaterAppDelegate.h"

#import "SGClient.h"

@implementation SGLayerUpdaterAppDelegate
@synthesize window;

////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Application lifecycle 
//////////////////////////////////////////////////////////////////////////////////////////////// 

- (BOOL) application:(UIApplication*)application didFinishLaunchingWithOptions:(NSDictionary*)launchOptions
{   
    NSString* path = [mainBundle pathForResource:@"Token" ofType:@"plist"];
    NSDictionary* token = [NSDictionary dictionaryWithContentsOfFile:path];
    
    NSString* key = [token objectForKey:@"key"];
    NSString* secret = [token objectForKey:@"secret"];
    
    if([key isEqualToString:@"my-secret"] || [secret isEqualToString:@"my-secret"]) {
        NSLog(@"ERROR!!! - Please change the credentials in Resources/Token.plist");
        exit(1);
    }   
    
    SGOAuth* token = [[[SGOAuth alloc] initWithKey:key secret:secret] autorelease];
    SGLocationService* locationService = [SGLocationService sharedLocationService];
    locationService.HTTPAuthorizer = token;

    // We want to make sure that we are adding the proper credentials to the
    // location service before we make the window visible. We might end up using
    // the location service in some of the UIVIew initialization code.
    [window makeKeyAndVisible];

	return YES;
}

- (void) dealloc
{        
    [window release];
    [super dealloc];
}

@end

