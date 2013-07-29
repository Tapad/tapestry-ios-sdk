//
//  TATapestryTests.m
//  TATapestryTests
//
//  Created by Sveinung Kval Bakken on 7/25/13.
//  Copyright (c) 2013 Tapad. All rights reserved.
//

#import "TATapestryRequestBuilder.h"
#import "TATapestryClient.h"
#import "TATapestryTests.h"

@implementation TATapestryTests

- (void)setUp
{
    [super setUp];
    
    // Set-up code here.
    req = [[TATapestryRequestBuilder alloc] init];
    STAssertNotNil(req, @"Tapestry request should be initialized");
}

- (void)tearDown
{
    // Tear-down code here.
    req = Nil;
    
    [super tearDown];
}

- (void)testClientShouldHaveTheApiBaseUrlPreconfigured
{
    TATapestryClient* client = [TATapestryClient alloc];
    NSString *requestUrl = [client buildRequestUrl:req];
    STFail(@"Not implemented yet");
}

@end
