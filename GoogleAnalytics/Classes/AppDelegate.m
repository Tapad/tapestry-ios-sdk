//
//  AppDelegate.m
//

#import "AppDelegate.h"
#import "GANTracker.h"
#import "TapestryRequestBuilder.h"

@implementation AppDelegate

static NSDate *lastAnalyticsSend;

@synthesize window = window_;

- (void)applicationDidFinishLaunching:(UIApplication *)application {
    [[GANTracker sharedTracker] setDebug:true];
    
    [[GANTracker sharedTracker] startTrackerWithAccountID:@"UA-41283710-1"
                                           dispatchPeriod:10
                                                 delegate:nil];
    if (lastAnalyticsSend == nil)
        lastAnalyticsSend = [NSDate date];
    
    NSString* isNewSession = [lastAnalyticsSend timeIntervalSinceNow] < (-30 * 60) ? @"true" : @"false";
    TapestryRequestBuilder* req = [[TapestryRequestBuilder alloc] init];
    [req setAnalytics:[NSDictionary dictionaryWithObjectsAndKeys:isNewSession, @"isNewSession", nil]];
    [req sendWithCallback:^(NSDictionary *response) {
        NSDictionary* analytics = [[NSDictionary alloc] initWithDictionary:[response objectForKey:@"analytics"]];
        if ([analytics count] != 0) {
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
        }
    }];
    
    [window_ makeKeyAndVisible];
}

- (void)dealloc {
    [[GANTracker sharedTracker] stopTracker];
    [window_ release];
    [super dealloc];
}

@end