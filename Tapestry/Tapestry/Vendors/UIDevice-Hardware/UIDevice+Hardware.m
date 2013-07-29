/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 5.0 Edition
 BSD License, Use at your own risk
 */

// Thanks to Emanuele Vulcano, Kevin Ballard/Eridius, Ryandjohnson, Matt Brown, etc.

#include <sys/socket.h> // Per msqr
#include <sys/sysctl.h>
#include <net/if.h>
#include <net/if_dl.h>

#import "UIDevice+Hardware.h"

@implementation UIDevice (TA_Hardware)
/*
 Platforms
 
 iFPGA ->        ??

 iPhone1,1 ->    iPhone 1G, M68
 iPhone1,2 ->    iPhone 3G, N82
 iPhone2,1 ->    iPhone 3GS, N88
 iPhone3,1 ->    iPhone 4/AT&T, N89
 iPhone3,2 ->    iPhone 4/Other Carrier?, ??
 iPhone3,3 ->    iPhone 4/Verizon, TBD
 iPhone4,1 ->    (iPhone 5/AT&T), TBD
 iPhone4,2 ->    (iPhone 5/Verizon), TBD

 iPod1,1   ->    iPod touch 1G, N45
 iPod2,1   ->    iPod touch 2G, N72
 iPod2,2   ->    Unknown, ??
 iPod3,1   ->    iPod touch 3G, N18
 iPod4,1   ->    iPod touch 4G, N80
 
 // Thanks NSForge
 iPad1,1   ->    iPad 1G, WiFi and 3G, K48
 iPad2,1   ->    iPad 2G, WiFi, K93
 iPad2,2   ->    iPad 2G, GSM 3G, K94
 iPad2,3   ->    iPad 2G, CDMA 3G, K95
 iPad3,1   ->    (iPad 3G, GSM)
 iPad3,2   ->    (iPad 3G, CDMA)

 AppleTV2,1 ->   AppleTV 2, K66

 i386, x86_64 -> iPhone Simulator
*/


#pragma mark sysctlbyname utils
- (NSString *) ta_getSysInfoByName:(char *)typeSpecifier
{
    size_t size;
    sysctlbyname(typeSpecifier, NULL, &size, NULL, 0);
    
    char *answer = malloc(size);
    sysctlbyname(typeSpecifier, answer, &size, NULL, 0);
    
    NSString *results = [NSString stringWithCString:answer encoding: NSUTF8StringEncoding];

    free(answer);
    return results;
}

- (NSString *) ta_platform
{
    return [self ta_getSysInfoByName:"hw.machine"];
}


// Thanks, Tom Harrington (Atomicbird)
- (NSString *) ta_hwmodel
{
    return [self ta_getSysInfoByName:"hw.model"];
}

#pragma mark sysctl utils
- (NSUInteger) ta_getSysInfo: (uint) typeSpecifier
{
    size_t size = sizeof(int);
    int results;
    int mib[2] = {CTL_HW, typeSpecifier};
    sysctl(mib, 2, &results, &size, NULL, 0);
    return (NSUInteger) results;
}

- (NSUInteger) ta_cpuFrequency
{
    return [self ta_getSysInfo:HW_CPU_FREQ];
}

- (NSUInteger) ta_busFrequency
{
    return [self ta_getSysInfo:HW_BUS_FREQ];
}

- (NSUInteger) ta_totalMemory
{
    return [self ta_getSysInfo:HW_PHYSMEM];
}

- (NSUInteger) ta_userMemory
{
    return [self ta_getSysInfo:HW_USERMEM];
}

- (NSUInteger) ta_maxSocketBufferSize
{
    return [self ta_getSysInfo:KIPC_MAXSOCKBUF];
}

#pragma mark file system -- Thanks Joachim Bean!
- (NSNumber *) ta_totalDiskSpace
{
    NSDictionary *fattributes = [[NSFileManager defaultManager] attributesOfFileSystemForPath:NSHomeDirectory() error:nil];
    return [fattributes objectForKey:NSFileSystemSize];
}

- (NSNumber *) ta_freeDiskSpace
{
    NSDictionary *fattributes = [[NSFileManager defaultManager] attributesOfFileSystemForPath:NSHomeDirectory() error:nil];
    return [fattributes objectForKey:NSFileSystemFreeSize];
}

#pragma mark platform type and name utils
- (NSUInteger) ta_platformType
{
    NSString *platform = [self ta_platform];

    // The ever mysterious iFPGA
    if ([platform isEqualToString:@"iFPGA"])        return TAUIDeviceIFPGA;

    // iPhone
    if ([platform isEqualToString:@"iPhone1,1"])    return TAUIDevice1GiPhone;
    if ([platform isEqualToString:@"iPhone1,2"])    return TAUIDevice3GiPhone;
    if ([platform hasPrefix:@"iPhone2"])            return TAUIDevice3GSiPhone;
    if ([platform hasPrefix:@"iPhone3"])            return TAUIDevice4iPhone;
    if ([platform hasPrefix:@"iPhone4"])            return TAUIDevice5iPhone;
    
    // iPod
    if ([platform hasPrefix:@"iPod1"])              return TAUIDevice1GiPod;
    if ([platform hasPrefix:@"iPod2"])              return TAUIDevice2GiPod;
    if ([platform hasPrefix:@"iPod3"])              return TAUIDevice3GiPod;
    if ([platform hasPrefix:@"iPod4"])              return TAUIDevice4GiPod;

    // iPad
    if ([platform hasPrefix:@"iPad1"])              return TAUIDevice1GiPad;
    if ([platform hasPrefix:@"iPad2"])              return TAUIDevice2GiPad;
    if ([platform hasPrefix:@"iPad3"])              return TAUIDevice3GiPad;
    
    // Apple TV
    if ([platform hasPrefix:@"AppleTV2"])           return TAUIDeviceAppleTV2;

    if ([platform hasPrefix:@"iPhone"])             return TAUIDeviceUnknowniPhone;
    if ([platform hasPrefix:@"iPod"])               return TAUIDeviceUnknowniPod;
    if ([platform hasPrefix:@"iPad"])               return TAUIDeviceUnknowniPad;
    
     // Simulator thanks Jordan Breeding
    if ([platform hasSuffix:@"86"] || [platform isEqual:@"x86_64"])
    {
        BOOL smallerScreen = [[UIScreen mainScreen] bounds].size.width < 768;
        return smallerScreen ? TAUIDeviceiPhoneSimulatoriPhone : TAUIDeviceiPhoneSimulatoriPad;
    }

    return TAUIDeviceUnknown;
}

- (NSString *) ta_platformString
{
    switch ([self ta_platformType])
    {
        case TAUIDevice1GiPhone: return TA_IPHONE_1G_NAMESTRING;
        case TAUIDevice3GiPhone: return TA_IPHONE_3G_NAMESTRING;
        case TAUIDevice3GSiPhone: return TA_IPHONE_3GS_NAMESTRING;
        case TAUIDevice4iPhone: return TA_IPHONE_4_NAMESTRING;
        case TAUIDevice5iPhone: return TA_IPHONE_5_NAMESTRING;
        case TAUIDeviceUnknowniPhone: return TA_IPHONE_UNKNOWN_NAMESTRING;
        
        case TAUIDevice1GiPod: return TA_IPOD_1G_NAMESTRING;
        case TAUIDevice2GiPod: return TA_IPOD_2G_NAMESTRING;
        case TAUIDevice3GiPod: return TA_IPOD_3G_NAMESTRING;
        case TAUIDevice4GiPod: return TA_IPOD_4G_NAMESTRING;
        case TAUIDeviceUnknowniPod: return TA_IPOD_UNKNOWN_NAMESTRING;
            
        case TAUIDevice1GiPad : return TA_IPAD_1G_NAMESTRING;
        case TAUIDevice2GiPad : return TA_IPAD_2G_NAMESTRING;
        case TAUIDevice3GiPad : return TA_IPAD_3G_NAMESTRING;
        case TAUIDeviceUnknowniPad : return TA_IPAD_UNKNOWN_NAMESTRING;
            
        case TAUIDeviceAppleTV2 : return TA_APPLETV_2G_NAMESTRING;
        case TAUIDeviceUnknownAppleTV: return TA_APPLETV_UNKNOWN_NAMESTRING;
            
        case TAUIDeviceiPhoneSimulator: return TA_IPHONE_SIMULATOR_NAMESTRING;
        case TAUIDeviceiPhoneSimulatoriPhone: return TA_IPHONE_SIMULATOR_IPHONE_NAMESTRING;
        case TAUIDeviceiPhoneSimulatoriPad: return TA_IPHONE_SIMULATOR_IPAD_NAMESTRING;
            
        case TAUIDeviceIFPGA: return TA_IFPGA_NAMESTRING;
            
        default: return TA_IOS_FAMILY_UNKNOWN_DEVICE;
    }
}

#pragma mark MAC addy
// Return the local MAC addy
// Courtesy of FreeBSD hackers email list
// Accidentally munged during previous update. Fixed thanks to mlamb.
- (NSString *) ta_macaddress
{
    int                 mib[6];
    size_t              len;
    char                *buf;
    unsigned char       *ptr;
    struct if_msghdr    *ifm;
    struct sockaddr_dl  *sdl;
    
    mib[0] = CTL_NET;
    mib[1] = AF_ROUTE;
    mib[2] = 0;
    mib[3] = AF_LINK;
    mib[4] = NET_RT_IFLIST;
    
    if ((mib[5] = if_nametoindex("en0")) == 0) {
        printf("Error: if_nametoindex error\n");
        return NULL;
    }
    
    if (sysctl(mib, 6, NULL, &len, NULL, 0) < 0) {
        printf("Error: sysctl, take 1\n");
        return NULL;
    }
    
    if ((buf = malloc(len)) == NULL) {
        printf("Could not allocate memory. error!\n");
        return NULL;
    }
    
    if (sysctl(mib, 6, buf, &len, NULL, 0) < 0) {
        printf("Error: sysctl, take 2");
        return NULL;
    }
    
    ifm = (struct if_msghdr *)buf;
    sdl = (struct sockaddr_dl *)(ifm + 1);
    ptr = (unsigned char *)LLADDR(sdl);
    NSString *outstring = [NSString stringWithFormat:@"%02X:%02X:%02X:%02X:%02X:%02X", 
                           *ptr, *(ptr+1), *(ptr+2), *(ptr+3), *(ptr+4), *(ptr+5)];
    // NSString *outstring = [NSString stringWithFormat:@"%02X%02X%02X%02X%02X%02X", 
    //                       *ptr, *(ptr+1), *(ptr+2), *(ptr+3), *(ptr+4), *(ptr+5)];
    free(buf);

    return outstring;
}

// duplicate of macaddress logic above except
// returning the 6 bytes without printing it out into a human readable form
- (BOOL) ta_macaddressTo:(unsigned char*)charbuf
{
    int                 mib[6];
    size_t              len;
    char                *buf;
    struct if_msghdr    *ifm;
    struct sockaddr_dl  *sdl;
    BOOL                successful = YES;
    
    mib[0] = CTL_NET;
    mib[1] = AF_ROUTE;
    mib[2] = 0;
    mib[3] = AF_LINK;
    mib[4] = NET_RT_IFLIST;
    
    if ((mib[5] = if_nametoindex("en0")) == 0) {
        printf("Error: if_nametoindex error\n");
        successful = NO;
    }
    
    if (successful) {
        if (sysctl(mib, 6, NULL, &len, NULL, 0) < 0) {
            printf("Error: sysctl, take 1\n");
            successful = NO;
        }
    }
    
    if (successful) {
        if ((buf = malloc(len)) == NULL) {
            printf("Could not allocate memory. error!\n");
            successful = NO;
        }
    }
    
    if (successful) {
        if (sysctl(mib, 6, buf, &len, NULL, 0) < 0) {
            printf("Error: sysctl, take 2");
            free(buf);
            successful = NO;
        }
    }
    
    if (successful) {
        ifm = (struct if_msghdr *)buf;
        sdl = (struct sockaddr_dl *)(ifm + 1);
        memcpy(charbuf, (unsigned char*)LLADDR(sdl), 6);
        free(buf);
    }
    
    return successful;
}

@end