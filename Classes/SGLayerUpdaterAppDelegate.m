//
//  SGLayerUpdaterAppDelegate.m
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

