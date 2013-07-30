//
//  TATapestryClientNG.m
//  Tapestry
//
//  Created by Sveinung Kval Bakken on 30.07.13.
//  Copyright (c) 2013 Tapad. All rights reserved.
//

#import "TATapestryClientNG.h"

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

- (void)queueRequest:(TATapestryRequest*)request
{
    [self queueRequest:request withResponseBlock:nil];
}

- (void)queueRequest:(TATapestryRequest*)request withResponseBlock:(TATapestryResponseHandler)handler
{
    
}

@end
