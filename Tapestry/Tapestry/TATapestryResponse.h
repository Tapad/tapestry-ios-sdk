//
//  TATapestryResponse.h
//  Tapestry
//
//  Created by Sveinung Kval Bakken on 30.07.13.
//  Copyright (c) 2013 Tapad. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 The response type which is passed into a Tapestry request's callback.

 It contains data returned by the API for the requesting device and its associated devices (as determined by the request).
 */
@interface TATapestryResponse : NSObject

/**
 Create and return a TATapestryResponse from the given dictionary.
 @param dictionary Dictionary which contains the data from an API request
 @return Tapestry response
 */
+ (TATapestryResponse*) responseWithDictionary:(NSDictionary*)dictionary;

/**
 @return Whether or not the request has any API-level errors, such as permission violations.
 */
- (BOOL)wasSuccess;

/**
 @return Dictionary of typed IDs. Key is the ID type and the object is a list of ID values.
 */
- (NSDictionary*)IDs;

/**
 @return Dictionary of data. Objects are a list of values for the given key in chronological order.
 */
- (NSDictionary*)data;

/**
 @return Array of audience tags.
 */
- (NSArray*)audiences;

/**
 @return Array of human-readable platforms, such as iPhone, Computer, AndroidTablet.
 */
- (NSArray*)platforms;

/**
 @return Array of API errors, such as permission violations.
 */
- (NSArray*)errors;

/**
  Get the devices which were the source for the data in this class.
  Each device is an NSDictionary which can be fed back into the constructor to access the data more easily.

  @return Array of individual devices from the originating request.
 */
- (NSArray*)devices;

@end
