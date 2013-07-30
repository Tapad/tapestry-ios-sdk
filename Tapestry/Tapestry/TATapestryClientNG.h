//
//  TATapestryClientNG.h
//  Tapestry
//
//  Created by Sveinung Kval Bakken on 30.07.13.
//  Copyright (c) 2013 Tapad. All rights reserved.
//

#import "TATapestryRequest.h"
#import <Foundation/Foundation.h>

@class TATapestryResponse;

typedef void(^TATapestryResponseHandler)(TATapestryResponse* response);

@interface TATapestryClientNG : NSObject

+ (TATapestryClientNG*)sharedClient;
- (void)setPartnerId:(NSString*)partnerId;
- (void)setBaseURL:(NSString*)baseURL;
- (void)queueRequest:(TATapestryRequest*)request;
- (void)queueRequest:(TATapestryRequest*)request withResponseBlock:(TATapestryResponseHandler)handler;

@end
