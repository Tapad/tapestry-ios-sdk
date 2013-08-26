Tapestry iOS SDK
================

Project setup:
--------------

1. Drag Tapestry.xcodeproj into your app project
2. Select your target and choose Build Phases
3. Configure dependecies:
    1. Add target dependency: Tapestry
    2. Add link binary: libTapestry.a
    3. Add SystemConfiguration.framework
    4. Add AdSupport.framework
4. Under your project or target, add the following build info:
    1. Add ${BUILD_PRODUCTS_DIR}/include/ (Recursive) to Header Search Path for your app project
    2. Add -ObjC to Other Linker Flags


Documentation:
--------------
See the docs folder for documentation. They are also available online [here](http://engineering.tapad.com/tapestry-ios-sdk/doc/index.html).


Testing:
--------
To run the client unit tests, you will need to run the provided mock server:

    ruby scripts/test_server.rb -p 4567


License:
--------
This software is released under the MIT license. See the LICENSE file for details.

