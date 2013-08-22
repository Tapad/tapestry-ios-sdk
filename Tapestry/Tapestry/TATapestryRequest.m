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
    NSMutableDictionary* map = [self.parameters objectForKey:parameter];
    if (map == nil)
    {
        map = [NSMutableDictionary dictionary];
        [self.parameters setValue:map forKey:parameter];
    }
    [map setValue:value forKey:key];
}

- (void)addArray:(NSArray*)array forParameter:(NSString*)parameter
{
    [self.parameters setValue:array forKey:parameter];
}

- (void)addValue:(NSString*)value forParameter:(NSString*)parameter
{
    [self.parameters setValue:value forKey:parameter];
}

- (void)addData:(NSString*)data forKey:(NSString*)key
{
    [self addMapParameter:@"ta_add_data" forKey:key andValue:data];
}

- (void)removeData:(NSString*)data forKey:(NSString*)key
{
    [self addMapParameter:@"ta_remove_data" forKey:key andValue:data];
}

- (void)setData:(NSString*)data forKey:(NSString *)key
{
    [self addMapParameter:@"ta_set_data" forKey:key andValue:data];
}

- (void)clearData:(NSString *)firstDataKey, ...
{
    NSMutableArray* array = [NSMutableArray array];
    va_list args;
    va_start(args, firstDataKey);
    for (NSString *dataKey = firstDataKey; dataKey != nil; dataKey = va_arg(args, NSString*))
    {
        [array addObject:dataKey];
    }
    va_end(args);
    [self addArray:array forParameter:@"ta_clear_data"];
}

- (void)addUniqueData:(NSString*)data forKey:(NSString*)key
{
    [self addMapParameter:@"ta_sadd_data" forKey:key andValue:data];
}

- (void)addAudiences:(NSString *)audiences, ...
{
    NSMutableArray* array = [NSMutableArray array];
    va_list args;
    va_start(args, audiences);
    for (NSString *audience = audiences; audience != nil; audience = va_arg(args, NSString*))
    {
        [array addObject:audience];
    }
    va_end(args);
    [self addArray:array forParameter:@"ta_add_audiences"];
}

- (void)removeAudiences:(NSString *)audiences, ...
{
    NSMutableArray* array = [NSMutableArray array];
    va_list args;
    va_start(args, audiences);
    for (NSString *audience = audiences; audience != nil; audience = va_arg(args, NSString*))
    {
        [array addObject:audience];
    }
    va_end(args);
    [self addArray:array forParameter:@"ta_remove_audiences"];
}

- (void)getDevices
{
    [self addValue:@"" forParameter:@"ta_get_devices"];
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
    [self addMapParameter:@"ta_partner_user_id" forKey:source andValue:userId];
}

- (void)setStrength:(NSInteger)strength
{
    [self addValue:[NSString stringWithFormat:@"%d", strength] forParameter:@"ta_strength"];
}

- (void)addTypedId:(NSString*)typedId forSource:(NSString*)source
{
    [self addMapParameter:@"ta_typed_did" forKey:source andValue:typedId];
}

- (void)setAnalytics:(BOOL)isNewSession
{
    [self addValue:isNewSession ? @"true" : @"false" forParameter:@"ta_analytics"];
}

#pragma mark - Build query

- (NSString *)query
{
    NSMutableArray* components = [NSMutableArray array];
    NSDictionary* parameters = self.parameters;
    
    for (NSString* key in [parameters keyEnumerator])
    {
        NSObject* value = [parameters valueForKey:key];
        if ([value isKindOfClass:[NSString class]])
            [components addObject:[self encodeStringValue:(NSString*)value forParameter:key]];
        else if ([value isKindOfClass:[NSDictionary class]])
            [components addObject:[self encodeDictionaryValue:(NSDictionary*)value forParameter:key]];
        else if ([value isKindOfClass:[NSArray class]])
            [components addObject:[self encodeArrayValue:(NSArray*)value forParameter:key]];
    }
    
    return [components componentsJoinedByString:@"&"];
}

- (NSString*)encodeStringValue:(NSString*)value forParameter:(NSString*)parameter
{
    return [NSString stringWithFormat:@"%@=%@", [parameter ta_URLEncodedString], [value ta_URLEncodedString]];
}

- (NSString*)encodeDictionaryValue:(NSDictionary*)values forParameter:(NSString*)parameter
{
    NSMutableArray* components = [NSMutableArray array];
    
    for (NSString* key in values)
    {
        NSString* value = [values valueForKey:key];
        [components addObject:[NSString stringWithFormat:@"%@:%@",
                                [key ta_URLEncodedString],
                                [value ta_URLEncodedString]]];
    }
    NSString* encodedValues = [components componentsJoinedByString:@","];
    return [NSString stringWithFormat:@"%@=%@", [parameter ta_URLEncodedString], encodedValues];
}

- (NSString*)encodeArrayValue:(NSArray*)values forParameter:(NSString*)parameter
{
    NSMutableString* buffer = [NSMutableString stringWithFormat:@"%@=", [parameter ta_URLEncodedString]];
    for (NSInteger index=0; index<[values count]; index++)
    {
        [buffer appendString:[[values objectAtIndex:index] ta_URLEncodedString]];
        if (index + 1 < [values count])
            [buffer appendString:@","];
    }
    return buffer;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"%@ with query: \n%@", NSStringFromClass(self.class), [self.query description]];
}

@end

@implementation TATapestryRequest (Testing)

- (NSDictionary *)test_parameters
{
    return self.parameters;
}

@end