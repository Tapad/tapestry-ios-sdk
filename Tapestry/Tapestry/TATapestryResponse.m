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

- (NSDictionary*)getIds
{
    return [self.response objectForKey:@"ids"];
}

- (NSDictionary*)getData
{
    return [self.response objectForKey:@"data"];
}

- (NSArray*)getAudiences
{
    return [self.response objectForKey:@"audiences"];
}

- (NSArray*)getPlatforms
{
    return [self.response objectForKey:@"platforms"];
}

- (NSArray*)getErrors
{
    return [self.response objectForKey:@"errors"];
}

- (NSArray*)getDevices
{
    return [self.response objectForKey:@"devices"];
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"%@ with data: \n%@", NSStringFromClass(self.class), [self.response description]];
}

@end
