//
//  Copyright 2013 Tapad, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@class UIApplication;

@interface TapestryRequestBuilder : NSObject {
    NSString* name;
    NSString* partnerId;
    NSDictionary* dataToSet;
    NSDictionary* dataToAdd;
    NSArray* audiencesToAdd;
    BOOL shouldGetData;
    BOOL shouldGetDevices;
}

@property (nonatomic,copy) NSString* name;
@property (nonatomic,copy) NSString* partnerId;
@property (nonatomic,copy) NSDictionary* dataToSet;
@property (nonatomic,copy) NSDictionary* dataToAdd;
@property (nonatomic,copy) NSArray* audiencesToAdd;
@property (nonatomic) BOOL shouldGetData;
@property (nonatomic) BOOL shouldGetDevices;


- (id)init;

// register an app id with the library, if pre-given to the developer.
// the app id defaults to CFBundleName if not set
+ (void) registerAppWithPartnerId:(NSString*)partnerId;

// registers a user id that will be sent with every subsequent event
// registration of a new user id will override the existing value
+ (void) registerUserId:(NSString*)value;

// returns the user id
+ (NSString*) getUserId;

// removes the registered user id
+ (void) clearUserId;

// Call this method from your application's own method of the same name
// to initialize default settings.
+ (BOOL) applicationDidFinishLaunching:(UIApplication *)application;

// Construct and send request, returns YES if successfully scheduled.
- (BOOL) send;

// Construct and send request, returns YES if successfully scheduled.
// `callback` is invoked when the request returns.
// TODO callback should an NSDictionary corresponding to the response json.
- (BOOL) sendWithCallback:(void (^)(NSDictionary* response))callback;

@end
