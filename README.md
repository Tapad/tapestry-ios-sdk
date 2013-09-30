Quick Setup
--------------
Download the [Tapestry iOS SDK](https://github.com/Tapad/tapestry-ios-sdk/releases) (tapestry-ios-X-X-X.zip) from the releases page ([appledocs here](https://tapad.github.com/tapestry-ios-sdk)).

1. Extract the zip and drag Tapestry.xcodeproj into your app project
2. Select your target and choose the **Build Phases** tab, adding the following:
    * Target dependency: `Tapestry`
    * Link binary: `libTapestry.a`
    * Link binary: `SystemConfiguration.framework`
    * Link binary: `AdSupport.framework`
3. Under your target's **Build Settings** tab, add the following:
    * Header Search Paths: `${BUILD_PRODUCTS_DIR}/include/` (select recursive when adding)
    * Other Linker Flags: `-ObjC`
4. Under your target's **Info** tab, add:
    * Custom iOS Target Properies: `TapestryPartnerID` as the key.  The value should be your partner id.

Using Tapestry
-------------
Include the Tapestry header file:

```objc
    #import "TATapestryClient.h"
```

Construct a request, add some audiences and data, and send the request:

```objc
    TATapestryRequest* request = [TATapestryRequest request];
    [request addAudiences:@"aud1", @"aud2", @"aud3", nil];
    [request addData:@"blue" forKey:@"color"];
    [request addData:@"ford" forKey:@"make"];
    [[TATapestryClient sharedClient] queueRequest:request];
```

Make a request for data, and do something with it in a callback:

```objc
    TATapestryRequest* request = [TATapestryRequest request];
    TATapestryResponseHandler handler = ^(TATapestryResponse* response, NSError* error,
                                          NSTimeInterval intervalSinceRequestFirstInvoked){
        if (error) {
            NSLog(@"Call failed with error: %@", [error localizedDescription]);
        } else {
            if ([response wasSuccess]) {
                NSString* color = [response firstValueForKey:@"color"];
                NSArray* allColors = [[response data] valueForKey:@"color"];
                NSLog(@"This user likes the color %@", color");
            } else {
                NSLog(@"Call failed with service failures: \n%@", [response errors]);
            }
        }
    };
    [[TATapestryClient sharedClient] queueRequest:request withResponseBlock:handler];
```


Documentation
--------------
See the docs folder for documentation. They are also available online [here](http://engineering.tapad.com/tapestry-ios-sdk/doc/index.html).


Testing
--------
To run the client unit tests, you will need to run the provided mock server:

    ruby scripts/test_server.rb -p 4567


Privacy
--------
The SDK uses IDFA, OpenUDID, and hashed MAC addresses for device identification. If any identifier is found to be opted-out, Tapad considers the entire device opted-out. OpenUDID and MAC address can be disabled with a configuration setting. To remove any trace of code which accesses the MAC address, you can simply delete a few lines of code in TATapadIdentifiers.m. See the documentation for TATapadIdentifiers for more details.


License
--------
This software is released under the MIT license. See the LICENSE file for details.