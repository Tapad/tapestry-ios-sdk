//
//  TAURLHelper.h
//  Tapestry
//
//  Created by Toby Matejovsky on 7/29/13.
//  Copyright (c) 2013 Tapad. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 * Helper to parse an NSDictionary of parameters out of a URI/queryString.
 */
@interface TAURLHelper : NSObject

/** Return dictionary of parameters from the full uri.

    [TAURLHelper paramsFromQuery:@"http://example.com?key=val&foo=bar"]

  @param uri The full URI to parse
 */
+ (NSDictionary*)paramsFromUri:(NSString*)uri;

/** Return dictionary of parameters from the querystring directly.

     [TAURLHelper paramsFromQuery:@"key=val&foo=bar"]
  
  @param queryString The query string to parse
 */
+ (NSDictionary*)paramsFromQuery:(NSString*)queryString;

@end
