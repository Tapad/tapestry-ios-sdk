//
//  TATapestryClientNG.m
//  Tapestry
//
//  Created by Sveinung Kval Bakken on 30.07.13.
//  Copyright (c) 2013 Tapad. All rights reserved.
//

#import "TARequestOperation.h"
#import "TATapestryClientNG.h"
#import "TAMacros.h"

static NSString* const kTATapestryClientBaseURL = @"http://tapestry.tapad.com/tapestry/1";

@interface TATapestryClientNG ()
@property(nonatomic, copy) NSString* partnerId;
@property(nonatomic, copy) NSString* baseURL;
@property(nonatomic, strong) NSOperationQueue* requestQueue;
@end

@implementation TATapestryClientNG

+ (TATapestryClientNG *)sharedClient
{
    static dispatch_once_t singleton_guard;
    static TATapestryClientNG* sharedClient;
    dispatch_once(&singleton_guard, ^{
        sharedClient = [[self alloc] init];
    });
    return sharedClient;
}

- (id)init
{
    self = [super init];
    if (self != nil)
    {
        self.baseURL = kTATapestryClientBaseURL;
        self.requestQueue = [[NSOperationQueue alloc] init];
        [self.requestQueue setMaxConcurrentOperationCount:2];
    }
    return self;
}

- (void)setPartnerId:(NSString *)partnerId
{
    _partnerId = partnerId;
}

- (void)setBaseURL:(NSString *)baseURL
{
    _baseURL = baseURL;
}

- (void)setDefaultBaseURL
{
    _baseURL = kTATapestryClientBaseURL;
}

- (void)queueRequest:(TATapestryRequest*)request
{
    [self queueRequest:request withResponseBlock:nil];
}

- (void)queueRequest:(TATapestryRequest*)request withResponseBlock:(TATapestryResponseHandler)handler
{
    // TODO add typed device ids
    // TODO add ta_get if there is a handler
    
//    [params addObject:[NSString stringWithFormat:@"%@=%@", ktypedUid, [TATapadIdentifiers deviceIDs] ]];
//    [params addObject:[NSString stringWithFormat:@"%@=%@", kplatform, [[UIDevice currentDevice] ta_platform] ]];
    
    TALog(@"TATapestryClientNG queueRequest %@", request);
    
    TATapestryResponseHandler innerHandler = ^(TATapestryResponse* response, NSError *error){
        TALog(@"Inner handler: response received for request:\n%@\nresponse:\n%@\nerror:\n%@", request, response, error);
        
        if (error != nil && [NSURLErrorDomain isEqualToString:error.domain]) {
            // TODO Network error. Pause and retry using a time-since-first-failure backoff strategy.
            if (handler != nil)
            {
                // Call response handler
                handler(response, error);
            }
        }
        
        else if (handler != nil)
        {
            // Call response handler
            handler(response, error);
        }
    };
    
    TARequestOperation* operation = [TARequestOperation operationWithRequest:request andBaseUrl:self.baseURL andHandler:innerHandler];
    [self.requestQueue addOperation:operation];
}

@end
