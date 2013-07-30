//
//  TATapestryRequestTests.m
//  Tapestry
//
//  Created by Toby Matejovsky on 7/30/13.
//  Copyright (c) 2013 Tapad. All rights reserved.
//

#import "TATapestryRequestTests.h"
#import "TAURLHelper.h"

@interface TATapestryRequestTests ()

@property (nonatomic, copy) NSString *key1;
@property (nonatomic, copy) NSString *val1;
@property (nonatomic, copy) NSString *key2;
@property (nonatomic, copy) NSString *val2;
@property (nonatomic, copy) NSString *mapAsEncodedJson;
@property (nonatomic, copy) NSString *mapAsCsv;
@property (nonatomic, copy) NSString *arrayAsEncodedJson;
@property (nonatomic, copy) NSString *arrayAsCsv;

@end


@implementation TATapestryRequestTests

- (void)setUp
{
    [super setUp];

    self.key1 = @"k1";
    self.val1 = @"v1";
    self.key2 = @"k2";
    self.val2 = @"v2";
    self.mapAsEncodedJson = [[NSString stringWithFormat:@"{\"%@\":\"%@\",\"%@\":\"%@\"}", self.key1, self.val1, self.key2, self.val2] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    self.mapAsCsv = [NSString stringWithFormat:@"%@:%@,%@:%@", self.key1, self.val1, self.key2, self.val2];
    self.arrayAsEncodedJson = [[NSString stringWithFormat:@"[\"%@\",\"%@\"]", self.val1, self.val2] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    self.arrayAsCsv = [NSString stringWithFormat:@"%@,%@", self.val1, self.val2];

    request = [TATapestryRequest request];
}

- (void)tearDown
{
    request = nil;

    self.key1 = nil;
    self.val1 = nil;
    self.key2 = nil;
    self.val2 = nil;
    self.mapAsEncodedJson = nil;
    self.mapAsCsv = nil;
    self.arrayAsEncodedJson = nil;
    self.arrayAsCsv = nil;

    [super tearDown];
}

- (void)testAddData
{
    [request addData:self.val1 forKey:self.key1];
    [request addData:self.val2 forKey:self.key2];
    [self assertMapMatches:@"ta_add_data"];
}

- (void)testRemoveData
{
    [request removeData:self.val1 forKey:self.key1];
    [request removeData:self.val1 forKey:self.key1];
    [self assertMapMatches:@"ta_remove_data"];
}

- (void)testSetData
{
    [request setData:self.val1 forKey:self.key1];
    [request setData:self.val2 forKey:self.key2];
    [self assertMapMatches:@"ta_set_data"];
}

- (void)testClearData
{
    [request clearData:self.val1, self.val2, nil];
    [self assertArrayMatches:@"ta_clear_data"];
}

- (void)testAddUniqueData
{
    [request addUniqueData:self.val1 forKey:self.key1];
    [request addUniqueData:self.val2 forKey:self.key2];
    [self assertMapMatches:@"ta_sadd_data"];
}

- (void)testAddAudiences
{
    [request addAudiences:self.val1, self.val2, nil];
    [self assertArrayMatches:@"ta_add_audiences"];
}

- (void)testRemoveAudiences
{
    [request removeAudiences:self.val1, self.val2, nil];
    [self assertArrayMatches:@"ta_remove_audiences"];
}

- (void)testListDevices;
{
    [request listDevices];
    [self assertFlagPresent:@"ta_list_devices"];
}

- (void)testSetDepth
{
    #warning(@"todo");
}

- (void)testSetPartnerId
{
    #warning(@"todo");
}

- (void)testAddUserId
{
    #warning(@"todo");
}

- (void)testSetStrength
{
    #warning(@"todo");
}

- (void)testAddTypedId
{
    #warning(@"todo");
}

// Helpers which use this class's various properties (key1, val1, request, etc).
// When these are called, it's assumed that both values have been added (and both keys, if required).
- (void)assertMapMatches:(NSString*)key
{
    NSDictionary *params = [TAURLHelper paramsFromQuery:[request query]];
    STAssertEqualObjects([params objectForKey:key], self.mapAsCsv, @"Expected comma-separated list of key-value pairs");
//    STAssertEqualObjects([params objectForKey:key], self.mapAsEncodedJson, @"Expected encoded json map");
}

- (void)assertArrayMatches:(NSString*)key
{
    NSDictionary *params = [TAURLHelper paramsFromQuery:[request query]];
    STAssertEqualObjects([params objectForKey:key], self.arrayAsCsv, @"Expected comma-separated list of values");
//    STAssertEqualObjects([params objectForKey:key], self.arrayAsEncodedJson, @"Expected encoded json array");
}

- (void)assertFlagPresent:(NSString*)key
{
    NSDictionary *params = [TAURLHelper paramsFromQuery:[request query]];
    NSNumber* flagVal = [NSNumber numberWithBool:YES]; // from TAURLHelper. TODO move this into the interface.
    STAssertEqualObjects([params objectForKey:key], flagVal, @"Expected key to be present");
}

// END test helpers.

@end
