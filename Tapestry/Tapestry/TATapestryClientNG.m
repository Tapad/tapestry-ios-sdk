//
//  TATapestryClientNG.m
//  Tapestry
//
//  Created by Sveinung Kval Bakken on 30.07.13.
//  Copyright (c) 2013 Tapad. All rights reserved.
//

#import <SystemConfiguration/SystemConfiguration.h>
#import "TARequestOperation.h"
#import "TATapadIdentifiers.h"
#import "UIDevice+Hardware.h"
#import "TATapestryClientNG.h"
#import "TAMacros.h"

static NSString* const kTATapestryClientBaseURL = @"http://tapestry.tapad.com/tapestry/1";
static NSString* const kTATapestryConnectivityTestHostname = @"google.com";

@interface TATapestryClientNG ()
@property(nonatomic, copy) NSString* partnerId;
@property(nonatomic, copy) NSString* baseURL;
@property(nonatomic, strong) NSOperationQueue* requestQueue;
@property(nonatomic, strong) NSMutableDictionary* requestTiming;
@property(nonatomic, assign) SCNetworkReachabilityRef reachabilityRef;
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
        [self startMonitoringNetworkConnectivity];
    }
    return self;
}

- (void)dealloc
{
    [self stopMonitoringNetworkConnectivity];
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
    // Include all enabled typed device ids.
    NSDictionary* typedIds = [TATapadIdentifiers typedDeviceIDs];
    for (id key in typedIds) {
        [request addTypedId:[typedIds objectForKey:key] forSource:key];
    }

    // If there's a handler, then we want data back.
    if (handler != nil) {
        [request getData];
    }

    // Set the platform parameter, because we don't control the user agent header.
    [request setPlatform:[[UIDevice currentDevice] ta_platform]];
    
    TALog(@"TATapestryClientNG queueRequest %@", request);
    
    // Record when this request was first sent.
    NSDate *start = [self startTimeForRequest:request];

    TATapestryResponseHandler innerHandler = ^(TATapestryResponse* response, NSError *error, NSTimeInterval interval){
        TALog(@"Inner handler: response received for request:\n%@\nresponse:\n%@\nerror:\n%@\nintervalSinceQueued:%f", request, response, error, interval);
        
        if (error != nil && [NSURLErrorDomain isEqualToString:error.domain]) {
            // Network error!
            // 1. Pause the queue. No request will succeed unless we have a network connection.
            [self.requestQueue setSuspended:YES];
            // 2. Put this failed operation back on the queue so it can try again when the network is back.
            [self queueRequest:request withResponseBlock:handler];
            // 3. Wait for the network to come back before continuing. Handled by network connectivity monitoring.
        }
        
        else if (handler != nil)
        {
            // Call response handler
            handler(response, error, interval);
        }
    };
    
    TARequestOperation* operation = [TARequestOperation operationWithRequest:request andBaseUrl:self.baseURL andHandler:innerHandler andStartTime:start];
    [self.requestQueue addOperation:operation];
}

- (NSDate*) startTimeForRequest:(TATapestryRequest*)request
{
    @synchronized(self)
    {
        id start = [self.requestTiming objectForKey:[request requestID]];
        if (start == nil) {
            start = [NSDate date];
            [self.requestTiming setValue:start forKey:[request requestID]];
        }
        return start;
    }
}

- (void) clearStartTimeForRequest:(TATapestryRequest*)request
{
    @synchronized(self)
    {
        [self.requestTiming removeObjectForKey:[request requestID]];
    }
}

#pragma mark - Network connectivity

- (void)startMonitoringNetworkConnectivity
{
    self.reachabilityRef = SCNetworkReachabilityCreateWithName(NULL, [kTATapestryConnectivityTestHostname UTF8String]);
    
    SCNetworkReachabilityContext context = {0, (__bridge void *)(self), NULL, NULL, NULL};
    
    if (SCNetworkReachabilitySetCallback(self.reachabilityRef, TANetworkConnectionCallBack, &context))
    {
        if (SCNetworkReachabilityScheduleWithRunLoop(self.reachabilityRef, CFRunLoopGetCurrent(), kCFRunLoopDefaultMode))
        {
            // add logging
            TALog(@"Scheduled network monitor");
        }
    }
}

static void (TANetworkConnectionCallBack)(SCNetworkReachabilityRef target, SCNetworkReachabilityFlags flags, void* info)
{
    BOOL reachable = TANetworkIsReachableForFlag(flags);
    
    TALog(@"Connection state changed: 0x%02x, reachable: %@", (unsigned int) flags, reachable ? @"YES" : @"NO");
    
    [[TATapestryClientNG sharedClient].requestQueue setSuspended:!reachable];
}

static BOOL (TANetworkIsReachableForFlag)(SCNetworkReachabilityFlags flags)
{
    if ((flags & kSCNetworkReachabilityFlagsReachable) == 0)
    {
        // The target host is not reachable.
        return NO;
    }
    
    BOOL returnValue = NO;
    
    if ((flags & kSCNetworkReachabilityFlagsConnectionRequired) == 0)
    {
        /*
         If the target host is reachable and no connection is required then we'll assume (for now) that you're on Wi-Fi...
         */
        returnValue = YES;
    }
    
    if ((((flags & kSCNetworkReachabilityFlagsConnectionOnDemand ) != 0) ||
         (flags & kSCNetworkReachabilityFlagsConnectionOnTraffic) != 0))
    {
        /*
         ... and the connection is on-demand (or on-traffic) if the calling application is using the CFSocketStream or higher APIs...
         */
        
        if ((flags & kSCNetworkReachabilityFlagsInterventionRequired) == 0)
        {
            /*
             ... and no [user] intervention is needed...
             */
            returnValue = YES;
        }
    }
    
    if ((flags & kSCNetworkReachabilityFlagsIsWWAN) == kSCNetworkReachabilityFlagsIsWWAN)
    {
        /*
         ... but WWAN connections are OK if the calling application is using the CFNetwork APIs.
         */
        returnValue = YES;
    }
    
    return returnValue;
}
             

- (void)stopMonitoringNetworkConnectivity
{
    SCNetworkReachabilityUnscheduleFromRunLoop(self.reachabilityRef, CFRunLoopGetCurrent(), kCFRunLoopDefaultMode);
    CFRelease(self.reachabilityRef);
    self.reachabilityRef = NULL;
}

@end
