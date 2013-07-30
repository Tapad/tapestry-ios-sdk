//
//  TAURLBuilder.h
//  Tapestry
//
//  Created by Sveinung Kval Bakken on 29.07.13.
//  Copyright (c) 2013 Tapad. All rights reserved.
//

#import <Foundation/Foundation.h>

/** This class simplifies the gradual construction of a URL. */
@interface TAURLBuilder : NSObject

/** The current URL */
@property (nonatomic, strong) NSMutableString* url;

/** Creates and returns a URL builder with the given base URL.

  @param baseURL The base URL
  @return URL Builder
 */
+ (TAURLBuilder*)urlBuilderWithBaseURL:(NSString*)baseURL;

/** Appends a query parameter to the URL with the given name and value.

  The value is URL-encoded.

  @param name The name of the query parameter.
  @param value The value of the query parameter.
 */
- (void)appendParameterNamed:(NSString*)name withValue:(NSString*)value;

@end
