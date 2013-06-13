//
//  Copyright 2013 Tapad, Inc. All rights reserved.
//

#import "TapestryRequestBuilder.h"
#import "TapadPreferences.h"
#import "TapestryClient.h"

@implementation TapestryRequestBuilder

@synthesize name;
@synthesize partnerId;
@synthesize dataToSet;
@synthesize dataToAdd;
@synthesize audiencesToAdd;
@synthesize analytics;
@synthesize shouldGetData;
@synthesize shouldGetDevices;

static NSString* kPARTNER_USER_ID = @"Tapestry Partner User ID";

- (id) init {
    self = [super init];
    self.partnerId = [TapadPreferences getTapadPartnerId];
    return self;
}

+ (void) registerAppWithPartnerId:(NSString *)partnerId {
    [TapadPreferences setTapadPartnerId:partnerId];
}

+ (void) registerUserId:(NSString*)uid {
    [TapadPreferences setCustomDataForKey:kPARTNER_USER_ID value:uid];
}

+ (NSString*) getUserId {
    id value = [TapadPreferences getCustomDataForKey:kPARTNER_USER_ID];
    if ([value isKindOfClass:[NSString class]]) {
        return (NSString*) value;
    } else {
        return nil;
    }
}

+ (void) clearUserId {
    [TapadPreferences removeCustomDataForKey:kPARTNER_USER_ID];
}

- (BOOL) send {
    return [self sendWithCallback:nil];
}

- (BOOL) sendWithCallback:(void (^)(NSDictionary* response))callback {
    // Not much of a reason to have a callback if we don't retrieve data to pass into it.
    if (callback != nil) [self setShouldGetData:YES];

    // todo: should we hold on to this object?
    dispatch_queue_t tapadq = dispatch_queue_create("Tapad Events Queue", NULL);
    
    dispatch_block_t block = ^{
        // note: since we are referencing the req object instance within this
        // block, it will be retained by the block until freed
        TapestryClient* client = [TapestryClient initializeForRequest:self];
        NSString* response = [client getSynchronous]; // autoreleased string
        NSLog(@"Response from Tapestry: %@", response);
        if (callback != nil) {
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
                         JSONObjectWithData:[response dataUsingEncoding:NSUTF8StringEncoding]
                         options:0
                         error:&error];
            if (error) {
                /* JSON was malformed. Probably should invoke the callback with an NSError. */
                NSLog(@"Unable to parse Tapestry response as JSON: %@", response);
            } else if([json isKindOfClass:[NSDictionary class]]) {
                callback((NSDictionary*)json);
            } else {
                NSLog(@"Received JSON response not wrapped in a top-level object: %@", response);
            }
        }
    };

    dispatch_async(tapadq, block);
    dispatch_release(tapadq);
    return YES;
}

// the basic hook for global initializations
// note that the method signature matches the one expected of app developers
+ (BOOL) applicationDidFinishLaunching:(UIApplication *)application {
    [TapadPreferences registerDefaults];
    return YES;
}

@end
