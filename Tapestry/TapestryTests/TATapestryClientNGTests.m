//
//  TATapestryClientNGTests.m
//  Tapestry
//
//  Created by Toby Matejovsky on 8/21/13.
//  Copyright (c) 2013 Tapad. All rights reserved.
//


#import "TATapestryClientNGTests.h"
#import "TATapestryClientNG.h"
#import "TAMacros.h"

@implementation TATapestryClientNGTests

- (void)setUp
{
    [super setUp];
    [[TATapestryClientNG sharedClient] setBaseURL:@"http://localhost:4567/tapestry/1"];
}

- (void)testBasicResponseCallback
{
    __block BOOL hasCalledBack = NO;

    TATapestryRequest *request = [TATapestryRequest request];
    [request setPartnerId:@"12345"];
    [[TATapestryClientNG sharedClient] queueRequest:request withResponseBlock:^(TATapestryResponse* response, NSError* error, NSTimeInterval sinceQueued){
        TALog(@"callback: %@", response);
        STAssertNotNil(response, @"Expected valid response.");
        STAssertNil(error, @"Did not expect an error in this callback.");
        hasCalledBack = YES;
    }];
    
    NSDate *loopUntil = [NSDate dateWithTimeIntervalSinceNow:5];
    while (hasCalledBack == NO && [loopUntil timeIntervalSinceNow] > 0) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
                                 beforeDate:loopUntil];
    }
    if (!hasCalledBack) { STFail(@"callback timed out!"); }
}

- (void)testTimeoutResponseCallback
{
    [[[TATapestryClientNG sharedClient] test_requestQueue] setSuspended:YES];
    __block BOOL hasCalledBack = NO;
    
    TATapestryRequest *request = [TATapestryRequest request];
    [request setPartnerId:@"12345"];
    // Setting an integrer as the data for key "sleep" will cause the test server to sleep for that many seconds before returning.

    [[TATapestryClientNG sharedClient] queueRequest:request withResponseBlock:^(TATapestryResponse* response, NSError* error, NSTimeInterval sinceQueued){
        TALog(@"callback: %@", response);
        STAssertNotNil(response, @"Did not expected valid response.");
        STAssertNil(error, @"Expected to receive a network failure error in this callback (because of request timeout).");
        hasCalledBack = YES;
        
        STAssertTrue(sinceQueued >= 5.0, @"Expected this request to take more than or 5s");
    }];
    
    sleep(5);
    [[[TATapestryClientNG sharedClient] test_requestQueue] setSuspended:NO];
    
    double delayInSeconds = 2.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        if (!hasCalledBack) {
            STFail(@"callback timed out after the expected 5s network timeout limit!");
        }
    });
}

- (void)testAutoIncludingTaGetParamIfHandlerProvided
{
    __block BOOL hasCalledBack = NO;
    
    TATapestryRequest *request = [TATapestryRequest request];
    [request setPartnerId:@"12345"];
    [[TATapestryClientNG sharedClient] queueRequest:request withResponseBlock:^(TATapestryResponse* response, NSError* error, NSTimeInterval sinceQueued){
        TALog(@"callback: %@", response);
        STAssertNotNil(response, @"Expected valid response.");
        STAssertNil(error, @"Did not expect an error in this callback.");
        NSDictionary *data = [response data];
        NSString *echoedQueryString = [[data objectForKey:@"query"] objectAtIndex:0];
        
        NSRange match = [echoedQueryString rangeOfString:@"ta_get"];
        STAssertTrue(match.location != NSNotFound, @"Expected \n'%@' to be part of query:\n'%@'", @"ta_get", echoedQueryString);
        
        hasCalledBack = YES;
    }];
    
    NSDate *loopUntil = [NSDate dateWithTimeIntervalSinceNow:5];
    while (hasCalledBack == NO && [loopUntil timeIntervalSinceNow] > 0) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
                                 beforeDate:loopUntil];
    }
    if (!hasCalledBack) { STFail(@"callback timed out!"); }
}

- (void)testAutoIncludingTypedDids
{
    __block BOOL hasCalledBack = NO;
    
    TATapestryRequest *request = [TATapestryRequest request];
    [request setPartnerId:@"12345"];
    [[TATapestryClientNG sharedClient] queueRequest:request withResponseBlock:^(TATapestryResponse* response, NSError* error, NSTimeInterval sinceQueued){
        TALog(@"callback: %@", response);
        STAssertNotNil(response, @"Expected valid response.");
        STAssertNil(error, @"Did not expect an error in this callback.");
        NSDictionary *data = [response data];
        NSString *echoedQueryString = [[data objectForKey:@"query"] objectAtIndex:0];
        NSString *expected = @"ta_typed_did";
        NSRange match = [echoedQueryString rangeOfString:expected];
        STAssertTrue(match.location != NSNotFound, @"Expected \n'%@' to be part of query:\n'%@'", expected, echoedQueryString);
        
        hasCalledBack = YES;
    }];
    
    NSDate *loopUntil = [NSDate dateWithTimeIntervalSinceNow:5];
    while (hasCalledBack == NO && [loopUntil timeIntervalSinceNow] > 0) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
                                 beforeDate:loopUntil];
    }
    if (!hasCalledBack) { STFail(@"callback timed out!"); }
}

- (void)testAutoIncludingPlatforms
{
    __block BOOL hasCalledBack = NO;
    
    TATapestryRequest *request = [TATapestryRequest request];
    [request setPartnerId:@"12345"];
    [[TATapestryClientNG sharedClient] queueRequest:request withResponseBlock:^(TATapestryResponse* response, NSError* error, NSTimeInterval sinceQueued){
        TALog(@"callback: %@", response);
        STAssertNotNil(response, @"Expected valid response.");
        STAssertNil(error, @"Did not expect an error in this callback.");
        NSDictionary *data = [response data];
        NSString *echoedQueryString = [[data objectForKey:@"query"] objectAtIndex:0];
        NSString *expected = @"ta_platform";
        NSRange match = [echoedQueryString rangeOfString:expected];
        STAssertTrue(match.location != NSNotFound, @"Expected \n'%@' to be part of query:\n'%@'", expected, echoedQueryString);
        
        hasCalledBack = YES;
    }];
    
    NSDate *loopUntil = [NSDate dateWithTimeIntervalSinceNow:5];
    while (hasCalledBack == NO && [loopUntil timeIntervalSinceNow] > 0) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
                                 beforeDate:loopUntil];
    }
    if (!hasCalledBack) { STFail(@"callback timed out!"); }
}

- (void)testDefaultPartnerId
{
    __block BOOL hasCalledBack = NO;
    
    TATapestryRequest *request = [TATapestryRequest request];
    [[TATapestryClientNG sharedClient] setPartnerId:@"xxx"];

    [[TATapestryClientNG sharedClient] queueRequest:request withResponseBlock:^(TATapestryResponse* response, NSError* error, NSTimeInterval sinceQueued){
        TALog(@"callback: %@", response);
        STAssertNotNil(response, @"Expected valid response.");
        STAssertNil(error, @"Did not expect an error in this callback.");
        NSDictionary *data = [response data];
        NSString *echoedQueryString = [[data objectForKey:@"query"] objectAtIndex:0];
        NSString *expected = @"ta_partner_id=xxx";
        NSRange match = [echoedQueryString rangeOfString:expected];
        STAssertTrue(match.location != NSNotFound, @"Expected \n'%@' to be part of query:\n'%@'", expected, echoedQueryString);
        
        hasCalledBack = YES;
    }];
    
    NSDate *loopUntil = [NSDate dateWithTimeIntervalSinceNow:5];
    while (hasCalledBack == NO && [loopUntil timeIntervalSinceNow] > 0) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
                                 beforeDate:loopUntil];
    }
    if (!hasCalledBack) { STFail(@"callback timed out!"); }
}

@end
