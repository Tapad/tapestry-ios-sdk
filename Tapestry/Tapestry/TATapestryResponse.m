//
//  TATapestryResponse.m
//  Tapestry
//
//  Created by Sveinung Kval Bakken on 30.07.13.
//  Copyright (c) 2013 Tapad. All rights reserved.
//

#import "TATapestryResponse.h"

@interface TATapestryResponse ()
@property(nonatomic, strong) NSDictionary* response;
@end

@implementation TATapestryResponse

+ (TATapestryResponse*) responseWithDictionary:(NSDictionary*)dictionary
{
    return [[TATapestryResponse alloc] initWithDictionary:dictionary];
}

- (id)initWithDictionary:(NSDictionary*)dictionary
{
    self = [super init];
    if (self != nil)
    {
        self.response = dictionary;
    }
    return self;
}

- (BOOL)wasSuccess
{
    return [self.response objectForKey:@"errors"] == nil;
}

- (NSDictionary*)IDs
{
    return [self.response objectForKey:@"ids"];
}

- (NSDictionary*)data
{
    return [self.response objectForKey:@"data"];
}

- (NSString*)firstValueForKey:(NSString*)key
{
    id data = [self data];
    NSString* firstValue = nil;
    if (data) {
        id valuesForKey = [data valueForKey:key];
        if (valuesForKey != nil && [valuesForKey isKindOfClass:[NSArray class]] && [valuesForKey count] > 0) {
            firstValue = [valuesForKey firstObject];
        }
    }
    return firstValue;
}

- (NSArray*)analytics
{
    return [self.response objectForKey:@"analytics"];
}

- (NSArray*)audiences
{
    return [self.response objectForKey:@"audiences"];
}

- (NSArray*)platforms
{
    return [self.response objectForKey:@"platforms"];
}

- (NSArray*)errors
{
    return [self.response objectForKey:@"errors"];
}

- (NSArray*)devices
{
    return [self.response objectForKey:@"devices"];
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"%@ with data: \n%@", NSStringFromClass(self.class), [self.response description]];
}

@end
