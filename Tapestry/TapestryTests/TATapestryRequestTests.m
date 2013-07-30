//
//  TATapestryRequestTests.m
//  Tapestry
//
//  Created by Toby Matejovsky on 7/30/13.
//  Copyright (c) 2013 Tapad. All rights reserved.
//

#import "TATapestryRequestTests.h"
#import "TAURLHelper.h"

@implementation TATapestryRequestTests

- (void)setUp
{
    [super setUp];

    request = [TATapestryRequest request];
}

- (void)tearDown
{
    request = nil;

    [super tearDown];
}

- (void)testAddData
{
    id key = @"k";
    id val = @"v";
    
    // Backend support encoded json map or a comma-separated list of key-value pairs.
    id encodedJson = [[NSString stringWithFormat:@"{\"%@\":\"%@\"}", key, val] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    id csv = @"k=v";
    
    [request addData:val forKey:key];
    
    NSDictionary *params = [TAURLHelper paramsFromQuery:[request query]];
    
    // TODO use the one which is correct based on the TATapestryRequest implementation.
    STAssertEqualObjects([params objectForKey:@"ta_add_data"], csv, @"Expected comma-separated list of key-value pairs");
    STAssertEqualObjects([params objectForKey:@"ta_add_data"], encodedJson, @"Expected encoded json map");
}

//- (void)addData:(NSString*)data forKey:(NSString*)key;
//- (void)removeData:(NSString*)data forKey:(NSString*)key;
//- (void)setData:(NSString*)data forKey:(NSString *)key;
//- (void)clearData:(NSString *)dataKeys, ...;
//- (void)addUniqueData:(NSString*)data forKey:(NSString*)key;
//- (void)addAudiences:(NSString *)audiences, ...;
//- (void)removeAudiences:(NSString *)audiences, ...;
//- (void)listDevices;
//- (void)setDepth:(NSInteger)depth;
//- (void)setPartnerId:(NSString*)partnedId;
//- (void)addUserId:(NSString*)userId forSource:(NSString*)source;
//- (void)setStrength:(NSInteger)strength;
//- (void)addTypedId:(NSString*)typedId forSource:(NSString*)source;

@end
