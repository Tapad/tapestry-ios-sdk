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
    
    // This is used as the value for when a query parameter is present but has no value.
    id valForFlagKey = [NSNumber numberWithBool:YES];
    
    NSArray *parts = [uri componentsSeparatedByString:@"?"];
    NSArray *queryParts = [parts subarrayWithRange:NSMakeRange(1, [parts count] - 1)];
    NSString *queryString = [queryParts componentsJoinedByString:@"?"]; // queryParts should be length 1, but we can code defensively.
    NSArray *kvPairs = [queryString componentsSeparatedByString:@"&"];
    for (int i = 0; i < [kvPairs count]; i++) {
        // Split on "=" to get key-value pair.
        NSArray *kv = [[kvPairs objectAtIndex:i] componentsSeparatedByString:@"="];
        
        // Extract the key. It's always here.
        id key = [kv objectAtIndex:0];
        
        // Extract the value, directly if it's present; otherw  ise assume it is a boolean flag and set the value to YES.
        // In the querystring "foo&bar=", both "foo" and "bar" are considered flag-type parameters.
        id val = ([kv count] == 2) ? (NSString *)[kv objectAtIndex:1] : valForFlagKey;
        if ([@"" isEqual: val]) val = valForFlagKey;
        
        // Now update the params dictionary.
        id existingVal = [params objectForKey:key];
        if (nil == existingVal) {
            // Add data for new key.
            [params setValue:val forKey:key];
        } else {
            // The key already exists.
            if ([existingVal isKindOfClass:[NSArray class]]) {
                // If the value is an array, it's already a duplicate and we just append.
                [params setValue:[existingVal arrayByAddingObject:val] forKey:key];
            } else {
                // Otherwise we need to make this value into an array and then append.
                [params setValue:[NSArray arrayWithObjects:existingVal, val, nil] forKey:key];
            }
        }
    }

    
    // Return immutable copy
    return [NSDictionary dictionaryWithDictionary:params];
}
@end
