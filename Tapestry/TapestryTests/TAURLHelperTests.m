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
    STAssertEqualObjects([params valueForKey:@"foo"], @"bar", @"'foo' key should have value 'bar'");
    STAssertEqualObjects([params valueForKey:@"baz"], @"buz", @"'baz' key should have value 'buz'");
}

- (void)testMultiParams
{
//    NSDictionary *params = [TAURLHelper paramsFromUri:uri];
    STFail(@"testMultiParams is not implemented yet");
}

- (void)testUndefinedParams
{
//    NSDictionary *params = [TAURLHelper paramsFromUri:uri];
    STFail(@"testUndefinedParams is not implemented yet");
}

@end
