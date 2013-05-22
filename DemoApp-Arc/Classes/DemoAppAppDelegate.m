//
//  DemoAppAppDelegate.m
//  DemoApp
//
//  Created by Li Qiu on 9/14/11.
//  Copyright 2011 Tapad, Inc. All rights reserved.
//

#import "DemoAppAppDelegate.h"
#import "TapestryRequestBuilder.h"
#import "TapadIdentifiers.h"

@implementation DemoAppAppDelegate

@synthesize window = _window;

- (void)applicationDidFinishLaunching:(UIApplication *)application
{
    /*
     Add launch tracking logic here.
     */

    NSLog(@"App Started");

    // Uncomment and provide partner id from Tapad.  If unspecified, the partner id is set to the CFBundleName.
    [TapestryRequestBuilder registerAppWithPartnerId:@"1"];

    // reset all Identifier config
    [self resetIdentifierConfig];
    
    // Prepare and send the launch tracking event.
    [TapestryRequestBuilder applicationDidFinishLaunching:application];

    // tests (scheduled because the event sending is asynchronous but the config setting is synchronous
    
    /*
    [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(testEventWithNoIdentifier) userInfo:nil repeats:NO];
    [NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(testEventWithUserId) userInfo:nil repeats:NO];
    [NSTimer scheduledTimerWithTimeInterval:4 target:self selector:@selector(testEventWithOpenUDID) userInfo:nil repeats:NO];
    [NSTimer scheduledTimerWithTimeInterval:6 target:self selector:@selector(testEventWithMD5HashedRawMAC) userInfo:nil repeats:NO];
    [NSTimer scheduledTimerWithTimeInterval:8 target:self selector:@selector(testEventWithSHA1HashedRawMAC) userInfo:nil repeats:NO];
    [NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(testEventWithMD5HashedMAC) userInfo:nil repeats:NO];
    [NSTimer scheduledTimerWithTimeInterval:11 target:self selector:@selector(testEventWithoutUserId) userInfo:nil repeats:NO];
    [NSTimer scheduledTimerWithTimeInterval:12 target:self selector:@selector(testEventWithSHA1HashedMAC) userInfo:nil repeats:NO];
    [NSTimer scheduledTimerWithTimeInterval:14 target:self selector:@selector(testEventWithAdvertisingIdentifier) userInfo:nil repeats:NO];
    [NSTimer scheduledTimerWithTimeInterval:16 target:self selector:@selector(testEventWithAllIdentifiers) userInfo:nil repeats:NO];
     */
}

- (void) resetIdentifierConfig {
    // reset all Identifier config
    [TapadIdentifiers sendOpenUDID:NO];
    [TapadIdentifiers sendMD5HashedRawMAC:NO];
    [TapadIdentifiers sendSHA1HashedRawMAC:NO];
    [TapadIdentifiers sendMD5HashedMAC:NO];
    [TapadIdentifiers sendSHA1HashedMAC:NO];
    [TapadIdentifiers sendAdvertisingIdentifier:NO];
}

- (void) testEventWithNoIdentifier {
    [self resetIdentifierConfig];
    
    // send test event with no identifiers specified
    [DemoAppAppDelegate send:@"no identifiers enabled event"];
}

- (void) testEventWithUserId {
    [self resetIdentifierConfig];
    [TapestryRequestBuilder registerUserId:@"demo_user_id"];
    // send test event with no identifiers specified other than the demo user id.
    [DemoAppAppDelegate send:@"only user id is set"];
}

- (void) testEventWithoutUserId {
    [self resetIdentifierConfig];
    [TapestryRequestBuilder clearUserId];
    // send test event with no identifiers specified and no user id.
    [DemoAppAppDelegate send:@"no identifiers are enabled, user id is cleared"];
}

- (void) testEventWithOpenUDID {
    [self resetIdentifierConfig];
    
    // enable OpenUDID
    [TapadIdentifiers sendOpenUDID:YES];

    // send test event with OpenUDID enabled
    [DemoAppAppDelegate send:@"OpenUDID specified"];
}

- (void) testEventWithMD5HashedRawMAC {
    [self resetIdentifierConfig];
    
    // enable MD5 Hashed Raw MAC
    [TapadIdentifiers sendMD5HashedRawMAC:YES];

    // send test event with MD5 Hashed Raw MAC enabled
    [DemoAppAppDelegate send:@"MD5HashedRawMAC specified"];
}

- (void) testEventWithSHA1HashedRawMAC {
    [self resetIdentifierConfig];
    
    // enable SHA1 Hashed Raw MAC
    [TapadIdentifiers sendSHA1HashedRawMAC:YES];

    // send test event with SHA1 Hashed Raw MAC enabled
    [DemoAppAppDelegate send:@"SHA1HashedRawMAC specified"];
}

- (void) testEventWithMD5HashedMAC {
    [self resetIdentifierConfig];
    
    // enable MD5 Hashed MAC
    [TapadIdentifiers sendMD5HashedMAC:YES];
    
    // send test event with MD5 Hashed MAC enabled
    [DemoAppAppDelegate send:@"MD5HashedMAC specified"];
}

- (void) testEventWithSHA1HashedMAC {
    [self resetIdentifierConfig];
    
    // enable SHA1 Hashed MAC
    [TapadIdentifiers sendSHA1HashedMAC:YES];
    
    // send test event with SHA1 Hashed MAC enabled
    [DemoAppAppDelegate send:@"SHA1HashedMAC specified"];
}

- (void) testEventWithAdvertisingIdentifier {
    [self resetIdentifierConfig];
    
    // enable iOS 6 Advertising Identifier
    [TapadIdentifiers sendAdvertisingIdentifier:YES];
    
    // send test event with iOS 6 Advertising Identifier enabled
    [DemoAppAppDelegate send:@"Advertising Identifier specified"];
}

- (void) testEventWithAllIdentifiers {
    [self resetIdentifierConfig];

    // enable all identifiers
    [TapadIdentifiers sendOpenUDID:YES];
    [TapadIdentifiers sendMD5HashedRawMAC:YES];
    [TapadIdentifiers sendSHA1HashedRawMAC:YES];
    [TapadIdentifiers sendMD5HashedMAC:YES];
    [TapadIdentifiers sendSHA1HashedMAC:YES];
    [TapadIdentifiers sendAdvertisingIdentifier:YES];
    
    // send test event with all identifiers enabled
    [DemoAppAppDelegate send:@"all identifiers enabled"];
}

+ (BOOL) send:(NSString *)eventName {
    TapestryRequestBuilder *req = [[TapestryRequestBuilder alloc] init];
    [req setDataToAdd:[NSDictionary dictionaryWithObjectsAndKeys:eventName, @"event", @"sports", @"category", nil]];
    [req setDataToSet:[NSDictionary dictionaryWithObjectsAndKeys:@"my_value_ONE_which_is_set", @"my_key_ONE_to_set", @"val2", @"key2", nil]];
    [req setAudiencesToAdd:[NSArray arrayWithObjects:@"aud1", @"aud2", nil]];
    [req setShouldGetData:YES];
    [req setShouldGetDevices:YES];
    return [req sendWithCallback:^(NSDictionary *response) {
        NSDictionary* data = [response objectForKey:@"data"];
        NSArray* events = [data objectForKey:@"event"];
        NSLog(@"Callback firing...data for the 'events' key is %@", [events componentsJoinedByString:@", "]);
    }];
}
@end
