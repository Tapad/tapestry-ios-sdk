//
//  TAURLBuilderTests.m
//  Tapestry
//
//  Created by Toby Matejovsky on 7/29/13.
//  Copyright (c) 2013 Tapad. All rights reserved.
//

#import "TAURLBuilderTests.h"

@implementation TAURLBuilderTests

- (void)setUp
{
    [super setUp];
    
    // Set-up code here.
}

- (void)tearDown
{
    // Tear-down code
    
    [super tearDown];
}

- (void)testInitializing
{
    NSString *base = @"http://example.com";
    TAURLBuilder *builder = [TAURLBuilder urlBuilderWithBaseURL:base];
    NSString *actual = [NSString stringWithString:[builder url]];
    STAssertTrue([actual isEqualToString:base], [NSString stringWithFormat:@"Expected url '%@'; got '%@'", base, actual]);
}

- (void)testAddingParameters
{
    NSString *base = @"http://example.com";
    TAURLBuilder *builder = [TAURLBuilder urlBuilderWithBaseURL:base];
    [builder appendParameterNamed:@"foo" withValue:@"bar1"];
    [builder appendParameterNamed:@"foo" withValue:@"bar2"];
    [builder appendParameterNamed:@"test" withValue:@"[1,2]"];
    NSString *expected = @"http://example.com?foo=bar1&foo=bar2&test=%5B1%2C2%5D";
    NSString *actual = [NSString stringWithString:[builder url]];
    STAssertTrue([actual isEqualToString:expected], [NSString stringWithFormat:@"Expected url '%@'; got '%@'", expected, actual]);
}

@end