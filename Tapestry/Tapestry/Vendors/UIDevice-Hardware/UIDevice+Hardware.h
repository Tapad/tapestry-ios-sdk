/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 5.0 Edition
 BSD License, Use at your own risk
 */

#import <UIKit/UIKit.h>

#define TA_IFPGA_NAMESTRING                @"iFPGA"

#define TA_IPHONE_1G_NAMESTRING            @"iPhone 1G"
#define TA_IPHONE_3G_NAMESTRING            @"iPhone 3G"
#define TA_IPHONE_3GS_NAMESTRING           @"iPhone 3GS" 
#define TA_IPHONE_4_NAMESTRING             @"iPhone 4" 
#define TA_IPHONE_5_NAMESTRING             @"iPhone 5"
#define TA_IPHONE_UNKNOWN_NAMESTRING       @"Unknown iPhone"

#define TA_IPOD_1G_NAMESTRING              @"iPod touch 1G"
#define TA_IPOD_2G_NAMESTRING              @"iPod touch 2G"
#define TA_IPOD_3G_NAMESTRING              @"iPod touch 3G"
#define TA_IPOD_4G_NAMESTRING              @"iPod touch 4G"
#define TA_IPOD_UNKNOWN_NAMESTRING         @"Unknown iPod"

#define TA_IPAD_1G_NAMESTRING              @"iPad 1G"
#define TA_IPAD_2G_NAMESTRING              @"iPad 2G"
#define TA_IPAD_3G_NAMESTRING              @"iPad 3G"
#define TA_IPAD_UNKNOWN_NAMESTRING         @"Unknown iPad"

#define TA_APPLETV_2G_NAMESTRING           @"Apple TV 2G"
#define TA_APPLETV_UNKNOWN_NAMESTRING      @"Unknown Apple TV"

#define TA_IOS_FAMILY_UNKNOWN_DEVICE       @"Unknown iOS device"

#define TA_IPHONE_SIMULATOR_NAMESTRING         @"iPhone Simulator"
#define TA_IPHONE_SIMULATOR_IPHONE_NAMESTRING  @"iPhone Simulator"
#define TA_IPHONE_SIMULATOR_IPAD_NAMESTRING    @"iPad Simulator"

typedef enum {
    TAUIDeviceUnknown,
    
    TAUIDeviceiPhoneSimulator,
    TAUIDeviceiPhoneSimulatoriPhone, // both regular and iPhone 4 devices
    TAUIDeviceiPhoneSimulatoriPad,
    
    TAUIDevice1GiPhone,
    TAUIDevice3GiPhone,
    TAUIDevice3GSiPhone,
    TAUIDevice4iPhone,
    TAUIDevice5iPhone,
    
    TAUIDevice1GiPod,
    TAUIDevice2GiPod,
    TAUIDevice3GiPod,
    TAUIDevice4GiPod,
    
    TAUIDevice1GiPad,
    TAUIDevice2GiPad,
    TAUIDevice3GiPad,
    
    TAUIDeviceAppleTV2,
    TAUIDeviceUnknownAppleTV,
    
    TAUIDeviceUnknowniPhone,
    TAUIDeviceUnknowniPod,
    TAUIDeviceUnknowniPad,
    TAUIDeviceIFPGA,

} TAUIDevicePlatform;

@interface UIDevice (TA_Hardware)
- (NSString *) ta_platform;
- (NSString *) ta_hwmodel;
- (NSUInteger) ta_platformType;
- (NSString *) ta_platformString;

- (NSUInteger) ta_cpuFrequency;
- (NSUInteger) ta_busFrequency;
- (NSUInteger) ta_totalMemory;
- (NSUInteger) ta_userMemory;

- (NSNumber *) ta_totalDiskSpace;
- (NSNumber *) ta_freeDiskSpace;

- (NSString *) ta_macaddress;
- (BOOL) ta_macaddressTo:(unsigned char*)charbuf;
@end