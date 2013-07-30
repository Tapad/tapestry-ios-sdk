//
//  TAURLHelper.m
//  Tapestry
//
//  Created by Toby Matejovsky on 7/29/13.
//  Copyright (c) 2013 Tapad. All rights reserved.
//

#import "TAURLHelper.h"

@implementation TAURLHelper
+ (NSDictionary*)paramsFromUri:(NSString*)uri
{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    
    NSArray *parts = [uri componentsSeparatedByString:@"?"];
    NSArray *queryParts = [parts subarrayWithRange:NSMakeRange(1, [parts count] - 1)];
    NSString *queryString = [queryParts componentsJoinedByString:@"?"]; // queryParts should be length 1, but we can code defensively.
    NSArray *kvPairs = [queryString componentsSeparatedByString:@"&"];
    for (int i = 0; i < [kvPairs count]; i++) {
        // Split on "=" to get key-value pair.
        NSArray *kv = [[kvPairs objectAtIndex:i] componentsSeparatedByString:@"="];
        
        // Extract the key. It's always here.
        id key = [kv objectAtIndex:0];
        
        // Extract the value, directly if it's present; otherwise assume it is a boolean flag and set the value to YES.
        id val = ([kv count] == 2) ? (NSString *)[kv objectAtIndex:1] : [NSNumber numberWithBool:YES];
        
        // Now update the params dictionary.
        // TODO change value to NSArray if a value already exists.
        [params setValue:val forKey:key];
    }

    
    // Return immutable copy
    return [NSDictionary dictionaryWithDictionary:params];
}
@end
