//
//  TATapestryRequestTests.m
//  Tapestry
//
//  Created by Sveinung Kval Bakken on 30.07.13.
//  Copyright (c) 2013 Tapad. All rights reserved.
//

#import "TATapestryRequest.h"
#import "TATapestryRequestTests.h"

@interface TATapestryRequestTests ()
@property(nonatomic, strong) TATapestryRequest* request;
@end

@implementation TATapestryRequestTests

- (void)setUp
{
    self.request = [TATapestryRequest request];
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

@end
