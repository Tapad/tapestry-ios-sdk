//
//  NSString+Tapad.m
//  Tapestry
//
//  Created by Sveinung Kval Bakken on 29.07.13.
//  Copyright (c) 2013 Tapad. All rights reserved.
//

#import "NSString+Tapad.h"

@implementation NSString (Tapad)

- (NSString*) ta_URLEncodedString
{
    return (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(NULL,
                                                                                 (CFStringRef)self,
                                                                                 NULL,
                                                                                 (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                                                                 kCFStringEncodingUTF8));
}

@end
