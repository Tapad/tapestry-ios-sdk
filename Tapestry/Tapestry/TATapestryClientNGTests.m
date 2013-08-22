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
}

- (void)tearDown
{
    [super tearDown];
}

- (void)testResponse
{
    __block BOOL hasCalledBack = NO;

    TATapestryRequest *request = [TATapestryRequest request];
    [request setPartnerId:@"12345"];
    [[TATapestryClientNG sharedClient] queueRequest:request withResponseBlock:^(TATapestryResponse* response, NSError* error){
        TALog(@"callback: %@", response);
        hasCalledBack = YES;
    }];
    
    NSDate *loopUntil = [NSDate dateWithTimeIntervalSinceNow:10];
    while (hasCalledBack == NO && [loopUntil timeIntervalSinceNow] > 0) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
                                 beforeDate:loopUntil];
    }
    if (!hasCalledBack) { STFail(@"callback timed out!"); }
}

@end
