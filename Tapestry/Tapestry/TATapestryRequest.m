//
//  TATapestryRequest.m
//  Tapestry
//
//  Created by Sveinung Kval Bakken on 30.07.13.
//  Copyright (c) 2013 Tapad. All rights reserved.
//

#import "TATapestryRequest.h"

@interface TATapestryRequest ()
@property(nonatomic, strong) NSMutableDictionary* parameters;
@end

@implementation TATapestryRequest

+ (TATapestryRequest*) request
{
    return [[TATapestryRequest alloc] init];
}

- (id)init
{
    self = [super init];
    if (self != nil)
    {
        self.parameters = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)addMapParameter:(NSString*)parameter forKey:(NSString*)key andValue:(NSString*)value
{
    
}

- (void)addArray:(NSArray*)array forParameter:(NSString*)parameter
{
    
}

- (void)addValue:(NSString*)value forParameter:(NSString*)parameter
{
    
}

- (void)addData:(NSString*)data forKey:(NSString*)key
{
    
}

- (void)removeData:(NSString*)data forKey:(NSString*)key
{
    
}

- (void)setData:(NSString*)data forKey:(NSString *)key
{
    
}

- (void)clearData:(NSString *)dataKeys, ...
{
    
}

- (void)addUniqueData:(NSString*)data forKey:(NSString*)key
{
    
}

- (void)addAudiences:(NSString *)audiences, ...
{
    
}

- (void)removeAudiences:(NSString *)audiences, ...
{
    
}

- (void)listDevices
{
    
}

- (void)setDepth:(NSInteger)depth
{
    
}

- (void)setPartnerId:(NSString*)partnedId
{
    
}

- (void)addUserId:(NSString*)userId forSource:(NSString*)source
{
    
}

- (void)setStrength:(NSInteger)strength
{
    
}

- (void)addTypedId:(NSString*)typedId forSource:(NSString*)source
{
    
}

- (NSString *)query
{
    return nil;
}

@end

@implementation TATapestryRequest (Testing)

- (NSDictionary *)test_parameters
{
    return self.parameters;
}

@end