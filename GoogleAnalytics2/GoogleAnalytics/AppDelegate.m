//
//  AppDelegate.m
//  GoogleAnalytics
//
//  Created by Garrett Hall on 6/13/13.
//  Copyright (c) 2013 Tapad. All rights reserved.
//

#import "AppDelegate.h"
#import "GANTracker.h"
#import "TapestryRequestBuilder.h"

@implementation AppDelegate

// Dispatch period in seconds
static const NSInteger kGANDispatchPeriodSec = 10;

@synthesize window = window_;

- (void)applicationDidFinishLaunching:(UIApplication *)application {
    [[GANTracker sharedTracker] startTrackerWithAccountID:@"UA-41283710-1"
                                           dispatchPeriod:kGANDispatchPeriodSec
                                                 delegate:nil];
    
    TapestryRequestBuilder* req = [[TapestryRequestBuilder alloc] init];
    [req sendWithCallback:^(NSDictionary *response) {
        NSError *error = nil;
        NSDictionary* results = [[NSDictionary alloc] initWithDictionary:[response objectForKey:@"results"]];
       NSLog(@"%@", results);
    }];
    
//    if (![[GANTracker sharedTracker] setCustomVariableAtIndex:1
//                                                         name:@"iPhone1"
//                                                        value:@"iv1"
//                                                    withError:&error]) {
//        // Handle error here
//    }
    
    [window_ makeKeyAndVisible];
}

- (void)dealloc {
    [[GANTracker sharedTracker] stopTracker];
    [window_ release];
    [super dealloc];
}

@end