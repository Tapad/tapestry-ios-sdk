//
//  TAURLHelperTests.m
//  Tapestry
//
//  Created by Toby Matejovsky on 7/29/13.
//  Copyright (c) 2013 Tapad. All rights reserved.
//

#import "TAURLHelperTests.h"
#import "TAURLHelper.h"

@implementation TAURLHelperTests

- (void)setUp
{
    [super setUp];
    uri = @"http://example.com?foo=bar&baz=buz&multi2[]=one&multi2[]=two&multi3[]=a&multi3[]=b&multi3[]=c&flag&unset=";
}

- (void)testBasicParams
{
    NSDictionary *params = [TAURLHelper paramsFromUri:uri];
    [self basicParamsMatch:params];
}

- (void)testMultiParams
{
    NSDictionary *params = [TAURLHelper paramsFromUri:uri];
    [self multiParamsMatch:params];
}

- (void)testUndefinedParams
{
    NSDictionary *params = [TAURLHelper paramsFromUri:uri];
    [self undefinedParamsMatch:params];
}

- (void)testQueryStringOnlyParsing
{
    id queryString = [[uri componentsSeparatedByString:@"?"] objectAtIndex:1];
    NSDictionary *params = [TAURLHelper paramsFromQuery:queryString];
    [self basicParamsMatch:params];
    [self multiParamsMatch:params];
    [self undefinedParamsMatch:params];
}

// Helpers that match parsed params from the uri defined in setUp:

- (void)basicParamsMatch:(NSDictionary *)params
{
    STAssertEqualObjects([params valueForKey:@"foo"], @"bar", @"'foo' key should have value 'bar'");
    STAssertEqualObjects([params valueForKey:@"baz"], @"buz", @"'baz' key should have value 'buz'");
}

- (void)multiParamsMatch:(NSDictionary *) params
{
    NSString *multi2Key = @"multi2[]";
    NSArray *multi2Value = [NSArray arrayWithObjects:@"one", @"two", nil];
    STAssertEqualObjects([params valueForKey:multi2Key], multi2Value, [NSString stringWithFormat:@"'%@' key should have value '%@'", multi2Key, multi2Value]);
    NSString *multi3Key = @"multi3[]";
    NSArray *multi3Value = [NSArray arrayWithObjects:@"a", @"b", @"c", nil];
    STAssertEqualObjects([params valueForKey:multi3Key], multi3Value, [NSString stringWithFormat:@"'%@' key should have value '%@'", multi3Key, multi3Value]);
}

- (void)undefinedParamsMatch:(NSDictionary *) params
{
    NSNumber* flagVal = [NSNumber numberWithBool:YES];
    STAssertEqualObjects([params valueForKey:@"flag"], flagVal, [NSString stringWithFormat:@"'flag' key with unset value in query param should have value in dictionary '%@'", flagVal]);
    STAssertEqualObjects([params valueForKey:@"unset"], flagVal, [NSString stringWithFormat:@"'unset' key with unset value in query param should have value in dictionary '%@'", flagVal]);
}


@end
