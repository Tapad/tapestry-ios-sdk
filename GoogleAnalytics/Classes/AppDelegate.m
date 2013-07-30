//
// Use this AppDelegate.m to send analytics with Tapestry
//
#import "AppDelegate.h"
#import "GANTracker.h"
#import "TATapestryRequestBuilder.h"

@implementation AppDelegate

static NSDate *lastAnalyticsSend;

@synthesize window = window_;

- (void)sendAnalytics {
    if (lastAnalyticsSend == nil) {
        // initialize
        [TATapestryRequestBuilder registerAppWithPartnerId:@"12345"];
        [[GANTracker sharedTracker] startTrackerWithAccountID:@"UA-41283710-1"
                                               dispatchPeriod:10
                                                     delegate:nil];
        lastAnalyticsSend = [NSDate date];
    }

    NSString* isNewSession = [lastAnalyticsSend timeIntervalSinceNow] < (-30 * 60) ? @"true" : @"false";
    TATapestryRequestBuilder* req = [[TATapestryRequestBuilder alloc] init];
    [req setAnalytics:[NSDictionary dictionaryWithObjectsAndKeys:isNewSession, @"isNewSession", nil]];
    [req sendWithCallback:^(NSDictionary *response) {
        NSDictionary* analytics = [[NSDictionary alloc] initWithDictionary:[response objectForKey:@"analytics"]];
        if ([analytics count] != 0) {
            // You can modify the custom variables and scope here (2 = session-level scope)
            [[GANTracker sharedTracker] setCustomVariableAtIndex:1
                                                            name:@"Visited_Platforms"
                                                           value:[[analytics objectForKey:@"vp"] description]
                                                           scope:kGANSessionScope
                                                       withError:NULL];
            [[GANTracker sharedTracker] setCustomVariableAtIndex:2
                                                            name:@"Platforms_Associated"
                                                           value:[[analytics objectForKey:@"pa"] description]
                                                           scope:kGANSessionScope
                                                       withError:NULL];
            [[GANTracker sharedTracker] setCustomVariableAtIndex:3
                                                            name:@"Platform_Types"
                                                           value:[[analytics objectForKey:@"pt"] description]
                                                           scope:kGANSessionScope
                                                       withError:NULL];
            [[GANTracker sharedTracker] setCustomVariableAtIndex:4
                                                            name:@"First_Visited_Platform"
                                                           value:[[analytics objectForKey:@"fvp"] description]
                                                           scope:kGANSessionScope
                                                       withError:NULL];
            if ([analytics objectForKey:@"movp"] != nil)
                [[GANTracker sharedTracker] setCustomVariableAtIndex:5
                                                                name:@"Most_Often_Visited_Platform"
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
}

- (void)applicationDidFinishLaunching:(UIApplication *)application {
    [[GANTracker sharedTracker] setDebug:true];
    [self sendAnalytics];
    [window_ makeKeyAndVisible];
}

- (void)dealloc {
    [[GANTracker sharedTracker] stopTracker];
    [super dealloc];
}
@end