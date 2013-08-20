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
    NSError* synchronousError=nil;
    NSHTTPURLResponse* synchronousResponse=nil;
    
    // Full URL of request.
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@?%@", self.baseUrl, self.request.query]];
    
    // Non-caching request with 2-second timeout.
    NSURLRequest *req = [NSURLRequest requestWithURL:url
                                         cachePolicy:NSURLRequestReloadIgnoringCacheData
                                     timeoutInterval:2 /* seconds */];
    NSLog(@"Going to request %@", req);
    
    // Synchronous request.
    NSData *data = [NSURLConnection sendSynchronousRequest:req
                                         returningResponse:&synchronousResponse
                                                     error:&synchronousError];
    
    if (synchronousError) {
       NSLog(@"There was an error when retrieving %@ (%@)", url, synchronousError);
    } else {
        // If there's no error, extract the response string.
        NSString *responseString = [[NSString alloc] initWithBytes:[data bytes]
                                                       length:[data length]
                                                     encoding:NSUTF8StringEncoding];
        NSLog(@"Response from Tapestry: %@", responseString);
        
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
            NSError* error = nil;
            id json = [NSJSONSerialization
                       JSONObjectWithData:[responseString dataUsingEncoding:NSUTF8StringEncoding]
                       options:0
                       error:&error];
            if (error) {
                // JSON was malformed.
                NSLog(@"Unable to parse Tapestry response as JSON: %@", responseString);
            } else if([json isKindOfClass:[NSDictionary class]]) {
                // Good response. Invoke the callback!
                TATapestryResponse* response = [TATapestryResponse responseWithDictionary:(NSDictionary*)json];
                self.handler(response);
            } else {
                NSLog(@"Received unexpected JSON response: %@", responseString);
            }
        }
    }

}

@end
