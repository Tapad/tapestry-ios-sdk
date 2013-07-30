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
    TATapestryClient* client = [[TATapestryClient alloc] init];
    NSString *requestUrl = [client buildRequestUrl:req];
    NSString *expectedBase = @"http://tapestry.tapad.com:80/tapestry/1";
    STAssertTrue([requestUrl hasPrefix:expectedBase], [NSString stringWithFormat:@"Request URL should default to %@", expectedBase]);
}

- (void)actualString:(NSString*)actual matchesPattern:(NSString*)pattern
{
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern options:0 error:NULL];
    NSUInteger matches = [regex numberOfMatchesInString:actual options:0 range:NSMakeRange(0, [actual length])];
    STAssertEquals(1, matches, [NSString stringWithFormat:@"Expected exactly one match of '%@' in '%@'", pattern, actual]);
}

@end
