//
//  DemoAppAppDelegate.m
//  DemoApp
//
//  Created by Li Qiu on 9/14/11.
//  Copyright 2011 Tapad, Inc. All rights reserved.
//

#import "DemoAppAppDelegate.h"
#import "Tapestry/TATapestry.h"

@implementation DemoAppAppDelegate

@synthesize window = _window;

- (void)applicationDidFinishLaunching:(UIApplication *)application
{
    /*
     Add launch tracking logic here.
     */

    NSLog(@"App Started");

    NSString* deviceIDs = [TATapadIdentifiers deviceIDs];
    NSArray* ids = [deviceIDs componentsSeparatedByString:@","];
    NSLog(@"Device IDs: %@\n\n", deviceIDs);
    for (NSString* id in ids) {
        NSLog(@" - '%@'", id);
    }
}

+ (BOOL) send:(NSString *)eventName {
    return NO;
}
@end
