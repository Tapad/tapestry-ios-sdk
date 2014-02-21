//
//  AppDelegate.m
//  CuteAnimals
//
//  Copyright 2012 Google, Inc. All rights reserved.
//

#import "AppDelegate.h"
#import "NavController.h"
#import "RootViewController.h"
#import "Tapestry/TATapestryClient.h"
#import "Tapestry/TATapadIdentifiers.h"
#import "GAIDictionaryBuilder.h"
#import "GAIFields.h"
#import <libkern/OSAtomic.h>

/******* Set your tracking ID here *******/
static NSString *const kTrackingId = @"YOUR TRACKING ID HERE";
static NSString *const kAllowTracking = @"allowTracking";

@interface AppDelegate ()

- (NSDictionary *)loadImages;

@end

// Keep track of whether the user is in a new session
static int64_t lastAnalyticsPush = 0;

@implementation AppDelegate
- (void)applicationDidBecomeActive:(UIApplication *)application {
  [GAI sharedInstance].optOut =
      ![[NSUserDefaults standardUserDefaults] boolForKey:kAllowTracking];
}
- (BOOL)application:(UIApplication *)application
    didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  self.images = [self loadImages];
  NSDictionary *appDefaults = @{kAllowTracking: @(YES)};
  [[NSUserDefaults standardUserDefaults] registerDefaults:appDefaults];
  // User must be able to opt out of tracking
  [GAI sharedInstance].optOut =
      ![[NSUserDefaults standardUserDefaults] boolForKey:kAllowTracking];
  // Initialize Google Analytics with a 120-second dispatch interval. There is a
  // tradeoff between battery usage and timely dispatch.
  [GAI sharedInstance].dispatchInterval = 120;
  [GAI sharedInstance].trackUncaughtExceptions = YES;
  self.tracker = [[GAI sharedInstance] trackerWithName:@"CuteAnimals"
                                            trackingId:kTrackingId];
  
  // Enable IDFV
  [TATapadIdentifiers setIdentifierEnabledIdentifierForVendor:YES];
  // Asynchronously fetch and send Tapestry's cross-platform web analytics to google anlytics.
  [self sendCrossPlatformWebAnalytics];

  self.window =
      [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
  // Override point for customization after application launch.
  self.viewController =
      [[RootViewController alloc] initWithNibName:@"RootViewController"
                                            bundle:nil];

  self.navController =
      [[NavController alloc] initWithRootViewController:self.viewController];
  self.navController.delegate = self.navController;

  self.window.rootViewController = self.navController;
  [self.window makeKeyAndVisible];

  return YES;
}

- (void)sendCrossPlatformWebAnalytics {
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
            
            // Visited Platforms
            [self.tracker send:[[[GAIDictionaryBuilder createAppView] set:[[analytics objectForKey:@"vp"] description]
                                                                   forKey:[GAIFields customDimensionForIndex:1]] build]];
            
            // Platforms Associated
            [self.tracker send:[[[GAIDictionaryBuilder createAppView] set:[[analytics objectForKey:@"pa"] description]
                                                                   forKey:[GAIFields customDimensionForIndex:2]] build]];
            
            // Platform Types
            [self.tracker send:[[[GAIDictionaryBuilder createAppView] set:[[analytics objectForKey:@"pt"] description]
                                                                   forKey:[GAIFields customDimensionForIndex:3]] build]];
            
            // First Visited Platform
            [self.tracker send:[[[GAIDictionaryBuilder createAppView] set:[[analytics objectForKey:@"fvp"] description]
                                                                   forKey:[GAIFields customDimensionForIndex:4]] build]];
            
            // Most Often Visited Platform
            [self.tracker send:[[[GAIDictionaryBuilder createAppView] set:[[analytics objectForKey:@"movp"] description]
                                                                   forKey:[GAIFields customDimensionForIndex:5]] build]];
            
            [self.tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"tapestry"
                                                                       action:@"iOS"
                                                                        label:@""
                                                                        value:nil] build]];
            
        } else if (error) {
            NSLog(@"Call failed with error: %@", [error localizedDescription]);
        } else {
            NSLog(@"Call failed with service failures: \n%@", [response errors]);
        }
    };
    [[TATapestryClient sharedClient] queueRequest:request withResponseBlock:handler];
}

- (NSDictionary *)loadImages {
  NSArray *contents = [[NSBundle mainBundle] pathsForResourcesOfType:@"jpg"
                                                         inDirectory:nil];
  if (!contents) {
    NSLog(@"Failed to load directory contents");
    return nil;
  }
  NSMutableDictionary *images = [NSMutableDictionary dictionary];
  for (NSString *file in contents) {
    NSArray *components = [[file lastPathComponent]
                           componentsSeparatedByString:@"-"];
    if (components.count == 0) {
      NSLog(@"Filename doesn't contain dash: %@", file);
      continue;
    }
    UIImage *image = [UIImage imageWithContentsOfFile:file];
    if (!image) {
      NSLog(@"Failed to load file: %@", file);
      continue;
    }
    NSString *prefix = components[0];
    NSMutableArray *categoryImages = images[prefix];
    if (!categoryImages) {
      categoryImages = [NSMutableArray array];
      images[prefix] = categoryImages;
    }
    [categoryImages addObject:image];
  }
  for (NSString *cat in [images allKeys]) {
    NSArray *array = images[cat];
    NSLog(@"Category %@: %u image(s).", cat, array.count);
  }
  return images;
}

@end
