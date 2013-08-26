//
//  TATapestryResponseTests.m
//  Tapestry
//
//  Created by Toby Matejovsky on 8/19/13.
//  Copyright (c) 2013 Tapad. All rights reserved.
//

#import "TATapestryResponseTests.h"

@implementation TATapestryResponseTests

- (void)setUp
{
    [super setUp];
    
    // A generic good response.
    NSString *jsonString = @"{"
    "\"ids\": {"
    "\"idfa\": [\"12345\", \"abc\"]"
    "},"
    "\"data\": {"
    "\"color\": [\"white\"],"
    "\"make\": [\"volvo\", \"lambo\"]"
    "},"
    "\"audiences\": [],"
    "\"platforms\": [\"Computer\"],"
    "\"devices\": [{"
    "\"ids\": {"
    "\"idfa\": [\"12345\"]"
    "},"
    "\"data\": {"
    "\"color\": [\"white\"],"
    "\"make\": [\"volvo\"]"
    "},"
    "\"audiences\": [],"
    "\"platforms\": [\"Computer\"]"
    "},"
    "{"
    "\"ids\": {"
    "\"idfa\": [\"abc\"]"
    "},"
    "\"data\": {"
    "\"make\": [\"lambo\"]"
    "},"
    "\"audiences\": [],"
    "\"platforms\": []"
    "}]"
    "}"
    ;

    NSError *jsonParseError = nil;
    id json = [NSJSONSerialization
               JSONObjectWithData:[jsonString dataUsingEncoding:NSUTF8StringEncoding]
               options:0
               error:&jsonParseError];
    STAssertNil(jsonParseError, @"JSON parsing failed in test setup");
    response = [TATapestryResponse responseWithDictionary:(NSDictionary*)json];
}

- (void)tearDown
{
    response = nil;
    
    [super tearDown];
}


- (void)testGetIds
{
    NSDictionary *expected = [NSDictionary dictionaryWithObjectsAndKeys:[NSArray arrayWithObjects:@"12345", @"abc", nil], @"idfa", nil];
    NSDictionary *actual = [response IDs];
    STAssertEqualObjects(actual, expected, @"IDs dictionary is incorrect.");
}

- (void)testGetData
{
    NSDictionary *expected = [NSDictionary dictionaryWithObjectsAndKeys:[NSArray arrayWithObject:@"white"], @"color", [NSArray arrayWithObjects:@"volvo", @"lambo", nil], @"make",nil];
    NSDictionary *actual = [response data];
    STAssertEqualObjects(actual, expected, @"IDs dictionary is incorrect.");
}

- (void)testGetFirstValueForKey
{
    NSString* expected = @"volvo";
    NSString* actual = [response firstValueForKey:@"make"];
    STAssertEqualObjects(actual, expected, @"Expected %@, got %@", expected, actual);
    STAssertNil([response firstValueForKey:@"non-existent-key"], @"Expected non-existent key to return nil first value");
}

- (void)testGetAudiences
{
    NSArray *expected = [NSArray arrayWithObjects:nil];
    NSArray *actual = [response audiences];
    STAssertEqualObjects(actual, expected, @"Audience list is incorrect.");
}

- (void)testGetPlatforms
{
    NSArray *expected = [NSArray arrayWithObjects:@"Computer", nil];
    NSArray *actual = [response platforms];
    STAssertEqualObjects(actual, expected, @"Platform list is incorrect.");
}

- (void)testGetErrors
{
    NSArray *expected = [NSArray arrayWithObject:@"testing error"];
    response = [TATapestryResponse responseWithDictionary:[NSDictionary dictionaryWithObjectsAndKeys:expected, @"errors", nil]];
    NSArray *actual = [response errors];
    STAssertEqualObjects(actual, expected, @"Error list is incorrect.");
}

- (void)testWasSuccessful
{
    NSArray *expected = [NSArray arrayWithObject:@"testing error"];
    response = [TATapestryResponse responseWithDictionary:[NSDictionary dictionaryWithObjectsAndKeys:expected, @"errors", nil]];
    STAssertFalse([response wasSuccess], @"Response with errors should not be successful");
}

- (void)testGetDevices
{
    NSDictionary *device1 = @{
                              @"ids"  : @{ @"idfa" : @[ @"12345" ] },
                              @"data" : @{
                                      @"color" : @[@"white"],
                                      @"make"  : @[@"volvo"]
                                      },
                              @"audiences" : @[],
                              @"platforms" : @[ @"Computer"]
                              };
    NSDictionary *device2 = @{
                              @"ids"  : @{ @"idfa" : @[ @"abc" ] },
                              @"data" : @{
                                      @"make" : @[@"lambo"]
                                      },
                              @"audiences" : @[],
                              @"platforms" : @[]
                              };
    NSArray *expected = @[device1, device2];
    NSArray *actual = [response devices];
    STAssertEqualObjects(actual, expected, @"Device list is incorrect.");
}

@end
