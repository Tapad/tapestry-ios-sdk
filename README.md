Tapestry iOS SDK
================

Project setup:
--------------

1. Drag Tapestry.xcodeproj into your app project
2. Select your target and choose Build Phases
3. 
  1. Add target dependency: Tapestry
  2. Add link binary: libTapestry.a
  3. Add SystemConfiguration.framework
  4. Add AdSupport.framework
4. Under your project or target, add the following build info:
5. 
  1. Add ${BUILD_PRODUCTS_DIR}/include/ (Recursive) to Header Search Path for your app project

  2. Add -ObjC to Other Linker Flags

