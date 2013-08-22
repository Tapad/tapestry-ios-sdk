//
//  TapadIdentifiers.m
//
//  Created by Li Qiu on 6/20/2012.
//  Copyright 2012 Tapad, Inc. All rights reserved.
//

#import <CommonCrypto/CommonDigest.h>

#import "TAOpenUDID.h"
#import "TATapadIdentifiers.h"
#import "TATapadPreferences.h"
#import "UIDevice+Hardware.h"
#import "NSString+MD5.h"

@implementation TATapadIdentifiers

static NSString* const kTypeAdvertisingIdentifier       = @"idfa";
static NSString* const kTypeOpenUDID                    = @"oudid";
static NSString* const kTypeMacMd5                      = @"md5mac";
static NSString* const kTypeMacRawMd5                   = @"md5rmac";
static NSString* const kTypeMacSha1                     = @"sha1mac";
static NSString* const kTypeMacRawSha1                  = @"sha1rmac";

static NSString* const kIdentifierOpenUDID              = @"tapestry.identifier.openudid.disabled";
static NSString* const kIdentifierMAC                   = @"tapestry.identifier.mac.disabled";

static NSString* kDeviceIDs = nil;

+ (void)setIdentifierEnabledMAC:(BOOL)enabled
{
    [self setIdentifier:kIdentifierMAC enabled:enabled];
}

+ (void)setIdentifierEnabledOpenUDID:(BOOL)enabled
{
    [self setIdentifier:kIdentifierOpenUDID enabled:enabled];
}

+ (void)setIdentifier:(NSString*)identifier enabled:(BOOL)enabled
{

    [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithBool:enabled] forKey:identifier];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [self invalidateIDs];
}

+ (BOOL)isIdentifierEnabled:(NSString*)identifier
{
    NSNumber* value = [[NSUserDefaults standardUserDefaults] valueForKey:identifier];
    if (value) {
        return [value boolValue];
    }
    else {
        return YES;
    }
}

+ (void)invalidateIDs
{
    kDeviceIDs = nil;
}

+ (NSString*) deviceIDs
{
    if (kDeviceIDs == nil) {
        kDeviceIDs = [self buildDeviceIDs];
    }
    return kDeviceIDs;
}

+ (NSString*)buildDeviceIDs
{
    NSMutableArray* ids = [NSMutableArray array];
    
    [ids addObject:[self fetchAdvertisingIdentifier]];
    [ids addObject:[self fetchOpenUDID]];
    [ids addObject:[self fetchMD5HashedMAC]];
    [ids addObject:[self fetchMD5HashedRawMAC]];
    [ids addObject:[self fetchSHA1HashedMAC]];
    [ids addObject:[self fetchSHA1HashedRawMAC]];
    
    return [ids componentsJoinedByString:@","];
}

+ (NSString*) fetchOpenUDID {
    NSString* value = @"0";
    if ([self isIdentifierEnabled:kIdentifierOpenUDID]) {
        value = [TAOpenUDID value];
    }
    return [NSString stringWithFormat:@"%@:%@", kTypeOpenUDID, value];
}

+ (NSString*) fetchMD5HashedRawMAC {
    // storage of mac addy bytes
    unsigned char macBuffer[6];
    // storage of md5 output bytes
    unsigned char md5Buffer[CC_MD5_DIGEST_LENGTH];
    
    if ([self isIdentifierEnabled:kIdentifierMAC] && [[UIDevice currentDevice] ta_macaddressTo:macBuffer]) {
        // Create 16 byte MD5 hash value, store in buffer
        CC_MD5(macBuffer, 6, md5Buffer);
        
        // Convert MD5 value in the buffer to NSString of hex values
        NSMutableString* output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
        for (int i = 0; i < CC_MD5_DIGEST_LENGTH; i++) {
            [output appendFormat:@"%02x",md5Buffer[i]];
        }
        return [NSString stringWithFormat:@"%@:%@", kTypeMacRawMd5, output];
    }
    else {
        return [NSString stringWithFormat:@"%@:%@", kTypeMacRawMd5, @"0"];
    }
}

+ (NSString*) fetchSHA1HashedRawMAC {
    // storage of mac addy bytes
    unsigned char macBuffer[6];
    // storage of sha1 output bytes
    unsigned char sha1Buffer[CC_SHA1_DIGEST_LENGTH];
    
    if ([self isIdentifierEnabled:kIdentifierMAC] && [[UIDevice currentDevice] ta_macaddressTo:macBuffer]) {
        // Create 20 byte SHA1 hash value, store in buffer
        CC_SHA1(macBuffer, 6, sha1Buffer);
        
        // Convert SHA1 value in the buffer to NSString of hex values
        NSMutableString* output = [NSMutableString stringWithCapacity:CC_SHA1_DIGEST_LENGTH * 2];
        for (int i = 0; i < CC_SHA1_DIGEST_LENGTH; i++) {
            [output appendFormat:@"%02x",sha1Buffer[i]];
        }
        return [NSString stringWithFormat:@"%@:%@", kTypeMacRawSha1, output];
    }
    else {
        return [NSString stringWithFormat:@"%@:%@", kTypeMacRawSha1, @"0"];
    }
}

+ (NSString*) fetchMD5HashedMAC {
    NSString* value = @"0";
    if ([self isIdentifierEnabled:kIdentifierMAC] && [[UIDevice currentDevice] ta_macaddress] != nil) {
        value = [[[UIDevice currentDevice] ta_macaddress] ta_MD5];
    }
    return [NSString stringWithFormat:@"%@:%@", kTypeMacMd5, value];
}

+ (NSString*) fetchSHA1HashedMAC {
    NSString* value = @"0";
    if ([self isIdentifierEnabled:kIdentifierMAC] && [[UIDevice currentDevice] ta_macaddress] != nil) {
        value = [[[UIDevice currentDevice] ta_macaddress] ta_SHA1];
    }
    return [NSString stringWithFormat:@"%@:%@", kTypeMacSha1, value];
}

+ (NSString*) fetchAdvertisingIdentifier {
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"6.0")) {
        if ([[ASIdentifierManager sharedManager] isAdvertisingTrackingEnabled]) {
            return [NSString stringWithFormat:@"%@:%@", kTypeAdvertisingIdentifier, [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString]];
        }
        else {
            return [NSString stringWithFormat:@"%@:%@", kTypeAdvertisingIdentifier, @"0"];
        }
    }
    else {
        return [NSString stringWithFormat:@"%@:%@", kTypeAdvertisingIdentifier, @"0"];
    }
}

@end
