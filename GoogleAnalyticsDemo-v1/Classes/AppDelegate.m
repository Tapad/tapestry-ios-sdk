//
//  AppDelegate.m
//

#import "AppDelegate.h"
#import "GANTracker.h"
#import "Tapestry/TATapestryClient.h"
#import <libkern/OSAtomic.h>

@implementation AppDelegate

// Keep track of whether the user is in a new session
static int64_t lastAnalyticsPush = 0;

@synthesize window = window_;

- (void)applicationDidFinishLaunching:(UIApplication *)application {
    [[GANTracker sharedTracker] setDebug:true];
    [[GANTracker sharedTracker] startTrackerWithAccountID:@"UA-41283710-1"
                                           dispatchPeriod:10
                                                 delegate:nil];
    [self sendAnalytics];
}

- (void)sendAnalytics {
    // has 30 minutes elapsed since last analytics push?
    NSTimeInterval currentTime = [[NSDate date] timeIntervalSince1970];
    BOOL isNewSession = lastAnalyticsPush < currentTime - 30 * 60 * 1000;
    // update timestamp in a thread-safe manner
    OSAtomicCompareAndSwap64(lastAnalyticsPush, currentTime, &lastAnalyticsPush);

    TATapestryRequest* request = [TATapestryRequest request];
    [request setAnalytics:isNewSession];

    TATapestryResponseHandler handler = ^(TATapestryResponse* response, NSError* error,
                                          NSTimeInterval intervalSinceRequestFirstInvoked){
        if (response && [response analytics] && [[response analytics] count] > 0) {
            NSDictionary* analytics = [response analytics];
            [[GANTracker sharedTracker] setCustomVariableAtIndex:1
                                                            name:@"Visited Platforms"
                                                           value:[[analytics objectForKey:@"vp"] description]
                                                           scope:kGANSessionScope
                                                       withError:NULL];
            [[GANTracker sharedTracker] setCustomVariableAtIndex:2
                                                            name:@"Platforms Associated"
                                                           value:[[analytics objectForKey:@"pa"] description]
                                                           scope:kGANSessionScope
                                                       withError:NULL];
            [[GANTracker sharedTracker] setCustomVariableAtIndex:3
                                                            name:@"Platform Types"
                                                           value:[[analytics objectForKey:@"pt"] description]
                                                           scope:kGANSessionScope
                                                       withError:NULL];
            [[GANTracker sharedTracker] setCustomVariableAtIndex:4
                                                            name:@"First Visited Platform"
                                                           value:[[analytics objectForKey:@"fvp"] description]
                                                           scope:kGANSessionScope
                                                       withError:NULL];
            if ([analytics objectForKey:@"movp"] != nil)
                [[GANTracker sharedTracker] setCustomVariableAtIndex:5
                                                                name:@"Most Often Visited Platform"
                                                               value:[[analytics objectForKey:@"movp"] description]
                                                               scope:kGANSessionScope
                                                           withError:NULL];
            
            [[GANTracker sharedTracker] trackEvent:@"tapestry"
                                            action:@"iOS"
                                             label:@""
                                             value:0
                                         withError:NULL];
            [[GANTracker sharedTracker] dispatch];
        } else if (error) {
            NSLog(@"Call failed with error: %@", [error localizedDescription]);
        } else {
            NSLog(@"Call failed with service failures: \n%@", [response errors]);
        }
    };
    [[TATapestryClient sharedClient] queueRequest:request withResponseBlock:handler];
}

- (void)dealloc {
    [[GANTracker sharedTracker] stopTracker];
    [window_ release];
    [super dealloc];
}

@end