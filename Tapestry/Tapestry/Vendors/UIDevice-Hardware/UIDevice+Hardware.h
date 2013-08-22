/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 5.0 Edition
 BSD License, Use at your own risk
 
 Slimmed by TapAd
 */

#import <UIKit/UIKit.h>

@interface UIDevice (TA_Hardware)
- (NSString *) ta_platform;
- (NSString *) ta_hwmodel;

- (NSUInteger) ta_cpuFrequency;
- (NSUInteger) ta_busFrequency;
- (NSUInteger) ta_totalMemory;
- (NSUInteger) ta_userMemory;

- (NSNumber *) ta_totalDiskSpace;
- (NSNumber *) ta_freeDiskSpace;

- (NSString *) ta_macaddress;
- (BOOL) ta_macaddressTo:(unsigned char*)charbuf;
@end