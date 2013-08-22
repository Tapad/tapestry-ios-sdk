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
    [[TATapestryClientNG sharedClient] setBaseURL:@"http://localhost:3000/tapestry/1"];
}

- (void)tearDown
{
    [[TATapestryClientNG sharedClient] setDefaultBaseURL];
    [super tearDown];
}

- (void)testBasicResponseCallback
{
    __block BOOL hasCalledBack = NO;

    TATapestryRequest *request = [TATapestryRequest request];
    [request setPartnerId:@"12345"];
    [[TATapestryClientNG sharedClient] queueRequest:request withResponseBlock:^(TATapestryResponse* response, NSError* error){
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
    __block BOOL hasCalledBack = NO;
    
    TATapestryRequest *request = [TATapestryRequest request];
    [request setPartnerId:@"12345"];
    // Setting an integrer as the data for key "sleep" will cause the test server to sleep for that many seconds before returning.
    [request setData:@"11" forKey:@"sleep"];
    [[TATapestryClientNG sharedClient] queueRequest:request withResponseBlock:^(TATapestryResponse* response, NSError* error){
        TALog(@"callback: %@", response);
        STAssertNil(response, @"Did not expected valid response.");
        STAssertNotNil(error, @"Expected to receive a network failure error in this callback (because of request timeout).");
        hasCalledBack = YES;
    }];
    
    NSDate *loopUntil = [NSDate dateWithTimeIntervalSinceNow:15];
    while (hasCalledBack == NO && [loopUntil timeIntervalSinceNow] > 0) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
                                 beforeDate:loopUntil];
    }
    if (!hasCalledBack) { STFail(@"callback timed out after the expected 10s network timeout limit!"); }
}

- (void)testAutoIncluding
{
    __block BOOL hasCalledBack = NO;
    
    TATapestryRequest *request = [TATapestryRequest request];
    [request setPartnerId:@"12345"];
    [[TATapestryClientNG sharedClient] queueRequest:request withResponseBlock:^(TATapestryResponse* response, NSError* error){
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

@end
