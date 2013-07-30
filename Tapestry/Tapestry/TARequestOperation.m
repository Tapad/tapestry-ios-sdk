//
//  TARequestOperation.m
//  Tapestry
//
//  Created by Sveinung Kval Bakken on 30.07.13.
//  Copyright (c) 2013 Tapad. All rights reserved.
//

#import "TARequestOperation.h"

@interface TARequestOperation ()
@property(nonatomic, retain)    TATapestryRequest* request;
@property(nonatomic, copy)      TATapestryResponseHandler handler;
@end

@implementation TARequestOperation

+ (TARequestOperation*)operationWithRequest:(TATapestryRequest *)request andHandler:(TATapestryResponseHandler)handler
{
    TARequestOperation* operation = [[TARequestOperation alloc] init];
    operation.request = request;
    operation.handler = handler;
    return operation;
}

- (void)main
{
    sleep(3);
    NSLog(@"Doing heavy work...");
#warning Needs to implement the actual HTTP operation.
    
    TATapestryResponse* response = nil;
    
    if (self.handler) {
        self.handler(response);
    }
}

@end
