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
@property (nonatomic, copy) NSString *mapAsCsv;
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
    self.mapAsCsv = [NSString stringWithFormat:@"%@:%@,%@:%@", self.key1, self.val1, self.key2, self.val2];
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
    self.mapAsCsv = nil;
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
    [request removeData:self.val2 forKey:self.key2];
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
    [request setDepth:3];
    [self assertKey:@"ta_depth" hasValue:@"3"];
}

- (void)testSetPartnerId
{
    [request setPartnerId:@"123"];
    [self assertKey:@"ta_partner_id" hasValue:@"123"];
}

- (void)testAddUserId
{
    [request addUserId:@"testUid123@example.com" forSource:@"email"];
    [self assertKey:@"ta_partner_user_id" hasValue:@"email:testUid123%40example.com"];
}

- (void)testSetStrength
{
    [request setStrength:2];
    [self assertKey:@"ta_strength" hasValue:@"2"];
}

- (void)testAddTypedId
{
    [request addTypedId:self.val1 forSource:self.key1];
    [request addTypedId:self.val2 forSource:self.key2];
    [self assertMapMatches:@"ta_typed_did"];
}

// Helpers which use this class's various properties (key1, val1, request, etc).
// When these are called, it's assumed that both values have been added (and both keys, if required).
- (void)assertMapMatches:(NSString*)key
{
    NSDictionary *params = [TAURLHelper paramsFromQuery:[request query]];
    NSSet *actualAsSet = [self stringToSet:[params objectForKey:key] withSeparator:@","];
    NSSet *expectedAsSet = [self stringToSet:self.mapAsCsv withSeparator:@","];
    STAssertEqualObjects(actualAsSet, expectedAsSet, @"Expected comma-separated list of key-value pairs");
}

- (void)assertArrayMatches:(NSString*)key
{
    NSDictionary *params = [TAURLHelper paramsFromQuery:[request query]];
    NSSet *actualAsSet = [self stringToSet:[params objectForKey:key] withSeparator:@","];
    NSSet *expectedAsSet = [self stringToSet:self.arrayAsCsv withSeparator:@","];
    STAssertEqualObjects(actualAsSet, expectedAsSet, @"Expected comma-separated list of values");
}

- (NSSet*)stringToSet:(NSString*)string withSeparator:(NSString*)separator
{
    NSArray *array = [string componentsSeparatedByString:separator];
    return [NSSet setWithArray:array];
}

- (void)assertFlagPresent:(NSString*)key
{
    NSDictionary *params = [TAURLHelper paramsFromQuery:[request query]];
    NSNumber* flagVal = [NSNumber numberWithBool:YES]; // from TAURLHelper. TODO move this into the interface.
    STAssertEqualObjects([params objectForKey:key], flagVal, @"Expected key to be present");
}

- (void)assertKey:(NSString*)key hasValue:(NSString*)val
{
    NSDictionary *params = [TAURLHelper paramsFromQuery:[request query]];
    NSString *actual = [params objectForKey:key];
    STAssertEqualObjects(actual, val, [NSString stringWithFormat:@"Expected key '%@' to equal '%@', got '%@'", key, val, actual]);
}

// END test helpers.

@end
