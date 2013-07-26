//
//  Copyright 2013 Tapad, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

// TATapestryClient handles the transport of a TATapestryRequest from the app to the API endpoint.

@class TATapestryRequestBuilder;

@interface TATapestryClient : NSObject {}

// using its initialized state, makes a blocking GET request to the 
// server, and formats the resulting raw data into an UTF8 encoded string
// the returned string will be autoreleased
- (NSString*) getSynchronous; 

// returns autoreleased request object for event tracking such as install tracking
+ (TATapestryClient *)initializeForRequest:(TATapestryRequestBuilder *)req;

// in some cases you may want direct access to the request 
@property (nonatomic,retain) NSURLRequest* request;
@property (nonatomic,retain) NSError* lastError;
@property (nonatomic,retain) NSHTTPURLResponse* lastResponse;
@property (nonatomic) BOOL hasError;
@property (nonatomic) BOOL responseSuccess;  // YES only if status code is 200. if there were no serious error, we could still get 404's and what not.

// returns an autoreleased string with description of last status code
- (NSString*) responseStatusCodeDescription;


@end
