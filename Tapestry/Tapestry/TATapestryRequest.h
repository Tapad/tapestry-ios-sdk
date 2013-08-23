//
//  TATapestryRequest.h
//  Tapestry
//
//  Created by Sveinung Kval Bakken on 30.07.13.
//  Copyright (c) 2013 Tapad. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 A mutable class for building requests that are sent with @see TATapestryClient.  Building a request adds parameters to the HTTP query string that will be sent to Tapestry Web API.
 
 An example of building a request:
 
 	TATapestryRequest* request = [TATapestryRequest request];
    [request addAudiences:@"aud1", @"aud2", @"aud3", nil];
    [request addData:@"blue" forKey:@"color"];
    [request addData:@"ford" forKey:@"make"];
    [request listDevices];
    [request depth:2];
 */

@interface TATapestryRequest : NSObject

/**---------------------------------------------------------------------------------------
 * @name Creating a request
 *  ---------------------------------------------------------------------------------------
 */

/**
 Create and return a TATapestryRequest instance
 */
+ (TATapestryRequest*) request;


/**---------------------------------------------------------------------------------------
 * @name Working with data
 *  ---------------------------------------------------------------------------------------
 */


/**
 Sets the value for a data key. This will overwrite any existing data for this key.
 
 @param key   The data key
 @param data  The value to set the key to
 */
- (void)setData:(NSString*)data forKey:(NSString *)key;

/**
 Adds a value to a data key.  Only one value can be added per request, so calling this method with the same key
 more than once will simply replace any existing values with the most recent.
 
 @param key   The data key
 @param data  The value to add to the key
 */
- (void)addData:(NSString*)data forKey:(NSString*)key;

/**
 This method will add or set a unique value (set-add) for this key. No duplicates.
 
 @param key   The data key
 @param data  The value to set-add to the key
 */
- (void)addUniqueData:(NSString*)data forKey:(NSString*)key;

/**
 Removes the value for a data key.
 
 @param key     The data key
 @param data    The value to remove from the key
 */
- (void)removeData:(NSString*)data forKey:(NSString*)key;

/**
 Clear data removes all data from one or more keys.
 
 @param firstDataKey Nil terminated list of keys to remove.
 */
- (void)clearData:(NSString *)firstDataKey, ... NS_REQUIRES_NIL_TERMINATION;

/**
 Tells Tapestry to return data (for use in a callback). This is automatically set by the client when a handler is present.
 */
- (void)getData;

/**
 Tells Tapestry to return all the devices listed out as well as combined.
 The list of devices can be accessed in the response.
 */
- (void)getDevices;


/**---------------------------------------------------------------------------------------
 * @name Tuning the query
 *  ---------------------------------------------------------------------------------------
 */

/**
 Tells Tapestry to consider devices this many steps away from the source device.
 
 @param depth The depth value between 0-2 inclusive.  Default is 1
 */
- (void)setDepth:(NSInteger)depth;

/**
 @param strength The strength value between 1-5 inclusive. Default is 2
 */
- (void)setStrength:(NSInteger)strength;


/**---------------------------------------------------------------------------------------
 * @name Working with audiences
 *  ---------------------------------------------------------------------------------------
 */

/**
 Adds this device to one or more audiences.
 
 @param audiences A nil terminated list of audiences
 */
- (void)addAudiences:(NSString *)audiences, ... NS_REQUIRES_NIL_TERMINATION;

/**
 Removes this device to one or more audiences.
 
 @param audiences A nil terminated list of audiences
 */
- (void)removeAudiences:(NSString *)audiences, ... NS_REQUIRES_NIL_TERMINATION;


/**---------------------------------------------------------------------------------------
 * @name Working with IDs
 *  ---------------------------------------------------------------------------------------
 */

/**
 Sets the partner ID for this request, will be set by the Tapestry SDK automatically.
 @param partnerId The partner id
 */
- (void)setPartnerId:(NSString*)partnerId;

/**
 Adds a cross-device user id
 
 @param source The source of this user id, e.g. "google email address"
 @param userId The id itself, e.g. "user@gmail.com"
 */
- (void)addUserId:(NSString*)userId forSource:(NSString*)source;

/**
 Add a typed device id, e.g. OpenUDID or IDFA. The client sets these automatically; under normal circumstances it is not necessary to set your own.
 
 @param typedId The typed id, e.g. ABCDEF-GHJID-FDSFASD
 @param source The source for this ID, e.g. OpenUDID
 */
- (void)addTypedId:(NSString*)typedId forSource:(NSString*)source;


/**---------------------------------------------------------------------------------------
 * @name Other methods
 *  ---------------------------------------------------------------------------------------
 */

/**
 Sets the analytics parameter for tracking in analytics platforms
 
 @param isNewSession Has enough time elapsed to be considered a new tracking session
 */
- (void)setAnalytics:(BOOL)isNewSession;


/** Converts the request into a URL-encoded query string.
 
 @return query string.
 */
- (NSString*)query;

/**
 Sets the platform query parameter to better identify the device type. This is set automatically by the client.
 
 @param platform The platform string, like a user agent
 */
- (void)setPlatform:(NSString*)platform;

/**
 Returns the uuid for this request
 
 @return uuid for this request
 */
- (NSString*)requestID;

@end

@interface TATapestryRequest (Testing)
// Exposing the parameters dictionary for testing purpose.
- (NSDictionary*)test_parameters;
@end
