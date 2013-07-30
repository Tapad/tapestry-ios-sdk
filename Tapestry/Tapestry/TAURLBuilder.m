//
//  TAURLBuilder.m
//  Tapestry
//
//  Created by Sveinung Kval Bakken on 29.07.13.
//  Copyright (c) 2013 Tapad. All rights reserved.
//

#import "TAURLBuilder.h"
#import "NSString+Tapad.h"

@interface TAURLBuilder ()
@property (nonatomic, assign) BOOL gotParameters;
@end

@implementation TAURLBuilder

+ (TAURLBuilder *)urlBuilderWithBaseURL:(NSString *)baseURL
{
    return [[TAURLBuilder alloc] initWithBaseURL:baseURL];
}

- (id)initWithBaseURL:(NSString*)baseURL
{
    self = [super init];
    if (self != nil)
    {
        self.url = [baseURL mutableCopy];
        self.gotParameters = NO;
    }
    return self;
}

- (void)appendParameterNamed:(NSString *)name withValue:(NSString *)value
{
    NSString* format = self.gotParameters ? @"&%@=%@" : @"?%@=%@";
    self.gotParameters = YES;
    
    [self.url appendFormat:format, name, [value ta_URLEncodedString]];
}

@end
