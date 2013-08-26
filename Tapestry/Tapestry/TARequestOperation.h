//
//  TARequestOperation.h
//  Tapestry
//
//  Created by Sveinung Kval Bakken on 30.07.13.
//  Copyright (c) 2013 Tapad. All rights reserved.
//

#import "TATapestryRequest.h"
#import "TATapestryClient.h"
#import <Foundation/Foundation.h>

/**
 An operation which actually makes the HTTP request. It's run asyncronously in a queue which is coordinated by TATapestryClient. It should not be used directly.
 */
@interface TARequestOperation : NSOperation

/**
 Create and return a TARequestOperation.
 
 @param request Tapestry request object
 @param baseUrl Base url to which tapestry request params are appended
 @param handler Callback which is invoked upon request completion
 @param startTime The time when this request was originally queued
 */
+ (TARequestOperation*)operationWithRequest:(TATapestryRequest*)request andBaseUrl:(NSString*)baseUrl andHandler:(TATapestryResponseHandler)handler andStartTime:(NSDate*)startTime;

@end
