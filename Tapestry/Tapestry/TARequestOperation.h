//
//  TARequestOperation.h
//  Tapestry
//
//  Created by Sveinung Kval Bakken on 30.07.13.
//  Copyright (c) 2013 Tapad. All rights reserved.
//

#import "TATapestryRequest.h"
#import "TATapestryClientNG.h"
#import <Foundation/Foundation.h>

@interface TARequestOperation : NSOperation

+ (TARequestOperation*)operationWithRequest:(TATapestryRequest*)request andHandler:(TATapestryResponseHandler)handler;

@end
