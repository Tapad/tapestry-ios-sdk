//
//  TAURLBuilder.h
//  Tapestry
//
//  Created by Sveinung Kval Bakken on 29.07.13.
//  Copyright (c) 2013 Tapad. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TAURLBuilder : NSObject
@property (nonatomic, strong) NSMutableString* url;

+ (TAURLBuilder*)urlBuilderWithBaseURL:(NSString*)baseURL;
- (void)appendParameterNamed:(NSString*)name withValue:(NSString*)value;

@end
