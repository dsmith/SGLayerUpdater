//
//  SGLayerUpdaterAppDelegate.m
//  SGLayerUpdater
//
//  Created by Derek Smith on 8/15/10.
//  Copyright SimpleGeo 2010. All rights reserved.
//

#import "SGLayerUpdaterAppDelegate.h"
#import "SGMainViewController.h"

#import "SGClient.h"

@implementation SGLayerUpdaterAppDelegate
@synthesize window;

////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Application lifecycle 
//////////////////////////////////////////////////////////////////////////////////////////////// 

- (BOOL) application:(UIApplication*)application didFinishLaunchingWithOptions:(NSDictionary*)launchOptions
{   
    NSString* path = [[NSBundle mainBundle] pathForResource:@"Token" ofType:@"plist"];
    NSDictionary* token = [NSDictionary dictionaryWithContentsOfFile:path];
    
    NSString* key = [token objectForKey:@"key"];
    NSString* secret = [token objectForKey:@"secret"];
    NSString* layer = [token objectForKey:@"layer"];
    
    if([key isEqualToString:@"my-secret"] || [secret isEqualToString:@"my-secret"] || [layer isEqualToString:@"my-layer"]) {
        NSLog(@"ERROR!!! - Please change the credentials in Resources/Token.plist");
        exit(1);
    }   
    
    SGOAuth* oauthToken = [[SGOAuth alloc] initWithKey:key secret:secret];
    SGLocationService* locationService = [SGLocationService sharedLocationService];
    locationService.HTTPAuthorizer = oauthToken;

    // We want to make sure that we are adding the proper credentials to the
    // location service before we make the window visible. We might end up using
    // the location service in some of the UIVIew initialization code.
    SGMainViewController* mainViewController = [[SGMainViewController alloc] initWithLayer:layer];
    UINavigationController* navigationController = [[UINavigationController alloc] initWithRootViewController:mainViewController];
    [window addSubview:navigationController.view];
    [window makeKeyAndVisible];

	return YES;
}

- (void) dealloc
{        
    [window release];
    [super dealloc];
}

@end

