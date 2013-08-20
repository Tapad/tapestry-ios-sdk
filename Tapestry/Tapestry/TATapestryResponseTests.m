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
    "\"platforms\": [\"Computer\"]"
    "}";

    NSError *jsonParseError;
    id json = [NSJSONSerialization
               JSONObjectWithData:[jsonString dataUsingEncoding:NSUTF8StringEncoding]
               options:0
               error:&jsonParseError];
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
    NSDictionary *actual = [response getIds];
    STAssertEqualObjects(actual, expected, @"IDs dictionary is incorrect.");
}

- (void)testGetData
{
    NSDictionary *expected = [NSDictionary dictionaryWithObjectsAndKeys:[NSArray arrayWithObject:@"white"], @"color", [NSArray arrayWithObjects:@"volvo", @"lambo", nil], @"make",nil];
    NSDictionary *actual = [response getData];
    STAssertEqualObjects(actual, expected, @"IDs dictionary is incorrect.");
}

- (void)testGetAudiences
{
    NSArray *expected = [NSArray arrayWithObjects:nil];
    NSArray *actual = [response getAudiences];
    STAssertEqualObjects(actual, expected, @"Audience list is incorrect.");
}

- (void)testGetPlatforms
{
    NSArray *expected = [NSArray arrayWithObjects:@"Computer", nil];
    NSArray *actual = [response getPlatforms];
    STAssertEqualObjects(actual, expected, @"Platform list is incorrect.");
}

- (void)testGetErrors
{
    NSArray *expected = [NSArray arrayWithObject:@"testing error"];
    response = [TATapestryResponse responseWithDictionary:[NSDictionary dictionaryWithObjectsAndKeys:expected, @"errors", nil]];
    NSArray *actual = [response getErrors];
    STAssertEqualObjects(actual, expected, @"Error list is incorrect.");
}

- (void)testWasSuccessful
{
    NSArray *expected = [NSArray arrayWithObject:@"testing error"];
    response = [TATapestryResponse responseWithDictionary:[NSDictionary dictionaryWithObjectsAndKeys:expected, @"errors", nil]];
    STAssertFalse([response wasSuccess], @"Response with errors should not be successful");
}

//- (void)testGetDevices // TODO
//{
//    NSArray *actual = [response getDevices];
//    STAssertEqualObjects(expected, actual, @"Device list is incorrect.");
//}

@end
