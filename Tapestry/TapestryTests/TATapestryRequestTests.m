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

@property (nonatomic, strong) TATapestryRequest* request;
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

    self.request = [TATapestryRequest request];
}

- (void)tearDown
{
    self.request = nil;

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
    [self.request addData:self.val1 forKey:self.key1];
    [self.request addData:self.val2 forKey:self.key2];
    [self assertMapMatches:@"ta_add_data"];
}

- (void)testRemoveData
{
    [self.request removeData:self.val1 forKey:self.key1];
    [self.request removeData:self.val2 forKey:self.key2];
    [self assertMapMatches:@"ta_remove_data"];
}

- (void)testSetData
{
    [self.request setData:self.val1 forKey:self.key1];
    [self.request setData:self.val2 forKey:self.key2];
    [self assertMapMatches:@"ta_set_data"];
}

- (void)testClearData
{
    [self.request clearData:self.val1, self.val2, nil];
    [self assertArrayMatches:@"ta_clear_data"];
}

- (void)testAddUniqueData
{
    [self.request addUniqueData:self.val1 forKey:self.key1];
    [self.request addUniqueData:self.val2 forKey:self.key2];
    [self assertMapMatches:@"ta_sadd_data"];
}

- (void)testAddAudiences
{
    [self.request addAudiences:self.val1, self.val2, nil];
    [self assertArrayMatches:@"ta_add_audiences"];
}

- (void)testRemoveAudiences
{
    [self.request removeAudiences:self.val1, self.val2, nil];
    [self assertArrayMatches:@"ta_remove_audiences"];
}

- (void)testListDevices;
{
    [self.request listDevices];
    [self assertFlagPresent:@"ta_list_devices"];
}

- (void)testSetDepth
{
    [self.request setDepth:3];
    [self assertKey:@"ta_depth" hasValue:@"3"];
}

- (void)testSetPartnerId
{
    [self.request setPartnerId:@"123"];
    [self assertKey:@"ta_partner_id" hasValue:@"123"];
}

- (void)testAddUserId
{
    [self.request addUserId:@"testUid123@example.com" forSource:@"email"];
    [self assertKey:@"ta_partner_user_id" hasValue:@"email:testUid123%40example.com"];
}

- (void)testSetStrength
{
    [self.request setStrength:2];
    [self assertKey:@"ta_strength" hasValue:@"2"];
}

- (void)testAddTypedId
{
    [self.request addTypedId:self.val1 forSource:self.key1];
    [self.request addTypedId:self.val2 forSource:self.key2];
    [self assertMapMatches:@"ta_typed_did"];
}


- (void)testEmpty
{
    STAssertTrue(0 == [[self.request test_parameters] count], @"Expected empty parameters dictionary.");
    [self assertQuery:@""];
}

- (void)assertQuery:(NSString*)expected
{
    NSString* query = [self.request query];
    STAssertTrue([query isEqualToString:expected], @"Expected query: \n'%@' but got: \n'%@'", expected, query);
}

- (void)assertQueryComponent:(NSString*)expected
{
    NSString* query = [self.request query];
    NSRange match = [query rangeOfString:expected];
    
    STAssertTrue(match.location != NSNotFound, @"Expected \n'%@'to be part of query:\n'%@'", expected, query);
}

- (void)assertStringValue:(NSString*)expected forKey:(NSString*)key
{
    NSString* actual = [[self.request test_parameters] valueForKey:key];
    STAssertTrue([expected isEqualToString:actual], @"Expected '%@', but got '%@' for key %@", expected, actual, key);
}

- (void)testParameterFlag
{
    [self.request listDevices];
    [self assertStringValue:@"" forKey:@"ta_list_devices"];
    [self assertQuery:@"ta_list_devices="];
}

- (void)testParameterWithValue
{
    [self.request setPartnerId:@"abc"];
    [self assertStringValue:@"abc" forKey:@"ta_partner_id"];
    [self assertQuery:@"ta_partner_id=abc"];
}

- (void)testParameterWithNumericValue
{
    [self.request setStrength:5];
    [self assertStringValue:@"5" forKey:@"ta_strength"];
    [self assertQuery:@"ta_strength=5"];
}

- (void)testMultipleParameters
{
    [self.request setStrength:5];
    [self.request setPartnerId:@"abc"];
    [self assertQueryComponent:@"ta_strength=5"];
    [self assertQueryComponent:@"ta_partner_id=abc"];
}

- (void)testExtendedCharsetValue
{
    [self.request setPartnerId:@"?abcÆØÅ"];
    [self assertQuery:@"ta_partner_id=%3Fabc%C3%86%C3%98%C3%85"];
}

- (void)testSimpleMap
{
    [self.request addData:@"value1" forKey:@"key1"];
    [self.request addData:@"value2" forKey:@"key2"];
    [self assertQueryComponent:@"key1:value1"];
    [self assertQueryComponent:@"key2:value2"];
}

- (void)testExtendedMapCharsetValues
{
    [self.request addData:@"?abcÆØÅ" forKey:@"key1"];
    [self.request addData:@"value2" forKey:@"key2"];
    [self assertQueryComponent:@"key1:%3Fabc%C3%86%C3%98%C3%85"];
    [self assertQueryComponent:@"key2:value2"];
}

- (void)testArrayValues
{
    [self.request addAudiences:@"value1", @"value2", @"val,ue3", nil];
    [self assertQueryComponent:@"ta_add_audiences=value1,value2,val%2Cue3"];
}

- (void)testBooleanValueTrue
{
    [self.request setAnalytics:YES];
    [self assertQuery:@"ta_analytics=true"];
}

- (void)testBooleanValueFalse
{
    [self.request setAnalytics:NO];
    [self assertQuery:@"ta_analytics=false"];
}

// Helpers which use this class's various properties (key1, val1, request, etc).
// When these are called, it's assumed that both values have been added (and both keys, if required).
- (void)assertMapMatches:(NSString*)key
{
    NSDictionary *params = [TAURLHelper paramsFromQuery:[self.request query]];
    NSSet *actualAsSet = [self stringToSet:[params objectForKey:key] withSeparator:@","];
    NSSet *expectedAsSet = [self stringToSet:self.mapAsCsv withSeparator:@","];
    STAssertEqualObjects(actualAsSet, expectedAsSet, @"Expected comma-separated list of key-value pairs");
}

- (void)assertArrayMatches:(NSString*)key
{
    NSDictionary *params = [TAURLHelper paramsFromQuery:[self.request query]];
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
    NSDictionary *params = [TAURLHelper paramsFromQuery:[self.request query]];
    NSNumber* flagVal = [NSNumber numberWithBool:YES]; // from TAURLHelper. TODO move this into the interface.
    STAssertEqualObjects([params objectForKey:key], flagVal, @"Expected key to be present");
}

- (void)assertKey:(NSString*)key hasValue:(NSString*)val
{
    NSDictionary *params = [TAURLHelper paramsFromQuery:[self.request query]];
    NSString *actual = [params objectForKey:key];
    STAssertEqualObjects(actual, val, [NSString stringWithFormat:@"Expected key '%@' to equal '%@', got '%@'", key, val, actual]);
}

// END test helpers.

@end
