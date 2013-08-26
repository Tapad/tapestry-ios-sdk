//
//  TARequestOperation.m
//  Tapestry
//
//  Created by Sveinung Kval Bakken on 30.07.13.
//  Copyright (c) 2013 Tapad. All rights reserved.
//

#import "TAMacros.h"
#import "TARequestOperation.h"

@interface TARequestOperation ()
@property(nonatomic, retain)    TATapestryRequest* request;
@property(nonatomic, copy)      NSString* baseUrl;
@property(nonatomic, copy)      TATapestryResponseHandler handler;
@property(nonatomic, copy)      NSDate* startTime;
@end

@implementation TARequestOperation

+ (TARequestOperation*)operationWithRequest:(TATapestryRequest *)request andBaseUrl:(NSString*)baseUrl andHandler:(TATapestryResponseHandler)handler andStartTime:(NSDate*)startTime
{
    TARequestOperation* operation = [[TARequestOperation alloc] init];
    operation.request = request;
    operation.baseUrl = baseUrl;
    operation.handler = handler;
    operation.startTime = startTime;
    return operation;
}

- (void)main
{
    // Full URL of request.
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@?%@", self.baseUrl, self.request.query]];
    
    // Non-caching request with 10s timeout.
    NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:url
                            cachePolicy:NSURLRequestReloadIgnoringCacheData
                        timeoutInterval:10.0];
    [req setValue:[self.request getPartnerId] forHTTPHeaderField:@"X-Tapestry-Id"];
    
    TALog(@"Going to request %@", req);
    
    // Synchronous request.
    NSError* networkError=nil;
    NSHTTPURLResponse* networkResponse=nil;
    NSData *data = [NSURLConnection sendSynchronousRequest:req
                                         returningResponse:&networkResponse
                                                     error:&networkError];
    
    // Interval between now and when the request was first queued.
    NSTimeInterval interval = [[NSDate date] timeIntervalSinceDate:self.startTime];
    
    NSError* finalError = nil;
    TATapestryResponse* response = nil; 
    
    if (networkError) {
       TALog(@"There was an error when retrieving %@ (%@)", url, [networkError domain]);
        finalError = networkError;
    } else {
        // If there's no error, extract the response string.
        NSString *responseString = [[NSString alloc] initWithBytes:[data bytes]
                                                       length:[data length]
                                                     encoding:NSUTF8StringEncoding];
        TALog(@"Response from Tapestry: %@", responseString);
        
        if (self.handler != nil) {
            // If we have a handler, then parse the JSON response. It should look something like this:
            /*
             {
                "ids": {
                    "idfa": ["xyz"]
                },
                "data": {
                    "event": ["checkout", "add to cart", "install"]
                },
                "audiences": ["1234"],
                "platforms": ["iPhone", "Computer"]
             }
             */
            NSError* jsonError=nil;
            id json = [NSJSONSerialization
                       JSONObjectWithData:[responseString dataUsingEncoding:NSUTF8StringEncoding]
                       options:0
                       error:&jsonError];
            
            if (jsonError) {
                // JSON was malformed.
                TALog(@"Unable to parse Tapestry response as JSON: %@", responseString);
                finalError = jsonError;
            } else if([json isKindOfClass:[NSDictionary class]]) {
                // JSON response is all good
                response = [TATapestryResponse responseWithDictionary:(NSDictionary*)json];
            } else {
                TALog(@"Received unexpected JSON response: %@", responseString);
                finalError = [NSError errorWithDomain:@"com.tapad" code:1
                                             userInfo:@{NSLocalizedDescriptionKey: @"Unexpected JSON response"}];
            }
            
            dispatch_async(dispatch_get_main_queue(), ^(){
                self.handler(response, finalError, interval);
            });
        }
    }
}

@end
