//
//  TATapestryRequest.m
//  Tapestry
//
//  Created by Sveinung Kval Bakken on 30.07.13.
//  Copyright (c) 2013 Tapad. All rights reserved.
//

#import "TATapestryRequest.h"
#import "NSString+Tapad.h"

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
    NSMutableDictionary* map = [self.parameters objectForKey:key];
    if (map == nil)
    {
        map = [NSMutableDictionary dictionary];
        [self.parameters setValue:map forKey:key];
    }
   // [map setValue:value forKey:key];
}

- (void)addArray:(NSArray*)array forParameter:(NSString*)parameter
{
    
}

- (void)addValue:(NSString*)value forParameter:(NSString*)parameter
{
    [self.parameters setValue:value forKey:parameter];
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
    [self addValue:@"" forParameter:@"ta_list_devices"];
}

- (void)setDepth:(NSInteger)depth
{
    [self addValue:[NSString stringWithFormat:@"%d", depth] forParameter:@"ta_depth"];
}

- (void)setPartnerId:(NSString*)partnedId
{
    [self addValue:partnedId forParameter:@"ta_partner_id"];
}

- (void)addUserId:(NSString*)userId forSource:(NSString*)source
{
    
}

- (void)setStrength:(NSInteger)strength
{
    [self addValue:[NSString stringWithFormat:@"%d", strength] forParameter:@"ta_strength"];
}

- (void)addTypedId:(NSString*)typedId forSource:(NSString*)source
{
    
}

- (NSString *)query
{
    NSMutableArray* components = [NSMutableArray array];
    NSDictionary* parameters = self.parameters;
    
    for (NSString* key in [parameters keyEnumerator])
    {
        NSObject* value = [parameters valueForKey:key];
        if ([value isKindOfClass:[NSString class]])
            [components addObject:[self encodeStringValue:(NSString*)value forParameter:key]];
    }
    
    return [components componentsJoinedByString:@"&"];
}

- (NSString*)encodeStringValue:(NSString*)value forParameter:(NSString*)parameter
{
    return [NSString stringWithFormat:@"%@=%@", [parameter ta_URLEncodedString], [value ta_URLEncodedString]];
}

@end

@implementation TATapestryRequest (Testing)

- (NSDictionary *)test_parameters
{
    return self.parameters;
}

@end