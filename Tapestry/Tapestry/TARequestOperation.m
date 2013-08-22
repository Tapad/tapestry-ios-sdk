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
@end

@implementation TARequestOperation

+ (TARequestOperation*)operationWithRequest:(TATapestryRequest *)request andBaseUrl:(NSString*)baseUrl andHandler:(TATapestryResponseHandler)handler
{
    TARequestOperation* operation = [[TARequestOperation alloc] init];
    operation.request = request;
    operation.baseUrl = baseUrl;
    operation.handler = handler;
    return operation;
}

- (void)main
{
    // Full URL of request.
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@?%@", self.baseUrl, self.request.query]];
    
    // Non-caching request with 10s timeout.
    NSURLRequest *req = [NSURLRequest requestWithURL:url
                                         cachePolicy:NSURLRequestReloadIgnoringCacheData
                                     timeoutInterval:10.0];
    TALog(@"Going to request %@", req);
    
    // Synchronous request.
    NSError* networkError=nil;
    NSHTTPURLResponse* networkResponse=nil;
    NSData *data = [NSURLConnection sendSynchronousRequest:req
                                         returningResponse:&networkResponse
                                                     error:&networkError];
    
    if (networkError) {
       TALog(@"There was an error when retrieving %@ (%@)", url, [networkError domain]);
        self.handler(nil, networkError, 0 /* FIXME */);
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
                self.handler(nil, jsonError, 0 /* FIXME */);
            } else if([json isKindOfClass:[NSDictionary class]]) {
                // Good response. Invoke the callback!
                TATapestryResponse* response = [TATapestryResponse responseWithDictionary:(NSDictionary*)json];
                self.handler(response, nil, 0 /* FIXME */);
            } else {
                TALog(@"Received unexpected JSON response: %@", responseString);
                self.handler(nil, [NSError errorWithDomain:@"com.tapad" code:1 userInfo:@{NSLocalizedDescriptionKey: @"Unexpected JSON response"}], 0 /* FIXME */);
            }
        }
    }
}

@end
