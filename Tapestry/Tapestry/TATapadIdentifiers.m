//
//  TapadIdentifiers.m
//
//  Created by Li Qiu on 6/20/2012.
//  Copyright 2012 Tapad, Inc. All rights reserved.
//

#import <CommonCrypto/CommonDigest.h>

#import "TAOpenUDID.h"
#import "TATapadIdentifiers.h"
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

static NSDictionary* deviceIDs = nil;

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

/** Clear the static representation of enabled ids. */
+ (void)invalidateIDs
{
    deviceIDs = nil;
}

+ (NSString*) typedDeviceIDsAsCommaSeparatedString
{
    return [self dictionaryAsEncodedCsvString:[self typedDeviceIDs]];
}

+ (NSDictionary*) typedDeviceIDs
{
    @synchronized(self)
    {
        if (deviceIDs == nil) {
            deviceIDs = [self buildDeviceIDs];
        }
    }
    return deviceIDs;
}

/** @return dictionary of enabled id types -> id values. */
+ (NSDictionary*) buildDeviceIDs
{
    NSMutableDictionary *dids = [NSMutableDictionary dictionary];
    
    NSArray *ids = @[
      [self fetchAdvertisingIdentifier],
      [self fetchOpenUDID],
      [self fetchMD5HashedMAC],
      [self fetchMD5HashedRawMAC],
      [self fetchSHA1HashedMAC],
      [self fetchSHA1HashedRawMAC]
    ];
    
    for (NSArray* did in ids) {
        if (did != nil) {
            [dids setValue:[did objectAtIndex:1] forKey:[did objectAtIndex:0]];
        }
    }

    return [NSDictionary dictionaryWithDictionary:dids];
}

/** @return tuple of @[ open udid type, open udid value ], or nil if disabled. openudid value is a string of 0s if the user is opted out. */
+ (NSArray*) fetchOpenUDID {
    if ([self isIdentifierEnabled:kIdentifierOpenUDID]) {
        return @[kTypeOpenUDID, [TAOpenUDID value]];
    } else {
        return nil;
    }
}

/** @return tuple of @[ md5 hashed raw mac type, md5 hashed raw mac value ], or nil if disabled. */
+ (NSArray*) fetchMD5HashedRawMAC {
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
        return @[kTypeMacRawMd5, output];
    }
    else {
        return nil;
    }
}

/** @return tuple of @[ sha1 hashed raw mac type, sha1 hashed raw mac value ], or nil if disabled */
+ (NSArray*) fetchSHA1HashedRawMAC {
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
        return @[kTypeMacRawSha1, output];
    }
    else {
        return nil;
    }
}

/** @return tuple of @[ md5 hashed mac type, md5 hashed mac value ], or nil if disabled */
+ (NSArray*) fetchMD5HashedMAC {
    if ([self isIdentifierEnabled:kIdentifierMAC] && [[UIDevice currentDevice] ta_macaddress] != nil) {
        return @[kTypeMacMd5, [[[UIDevice currentDevice] ta_macaddress] ta_MD5]];
    } else {
        return nil;
    }
}

/** @return tuple of @[ sha1 hashed mac type, sha1 hashed mac value ], or nil if disabled */
+ (NSArray*) fetchSHA1HashedMAC {
    if ([self isIdentifierEnabled:kIdentifierMAC] && [[UIDevice currentDevice] ta_macaddress] != nil) {
        return @[kTypeMacSha1, [[[UIDevice currentDevice] ta_macaddress] ta_SHA1]];
    } else {
        return nil;
    }
}

/** @return tuple of @[ idfa type, idfa value ], or nil if unavailable. idfa value is "0" if user is opted out. */
+ (NSArray*) fetchAdvertisingIdentifier {
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"6.0")) {
        if ([[ASIdentifierManager sharedManager] isAdvertisingTrackingEnabled]) {
            return @[kTypeAdvertisingIdentifier, [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString]];
        }
        else {
            return @[kTypeAdvertisingIdentifier, @"0"];
        }
    }
    else {
        return nil;
    }
}

+ (NSString*) dictionaryAsEncodedCsvString:(NSDictionary*)data {
    NSMutableArray* params = [NSMutableArray arrayWithCapacity:[data count]];
    for (id key in data) {
        id value = [data objectForKey:key];
        [params addObject:[NSString stringWithFormat:@"%@:%@", [self encodeString:key], [self encodeString:value] ]];
    }
    if ([params count] == 0) {
        return NULL;
    }
    else {
        return [params componentsJoinedByString:@","];
    }
}

+ (NSString*) arrayAsEncodedCsvString:(NSArray*)data {
    NSMutableArray* params = [NSMutableArray arrayWithCapacity:[data count]];
    for (id x in data) {
        [params addObject:[self encodeString:x]];
    }
    if ([params count] == 0) {
        return NULL;
    }
    else {
        return [params componentsJoinedByString:@","];
    }
}

+ (NSString*) encodeString: (id) unencodedString {
    return (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(NULL,
                                                                                 (CFStringRef)unencodedString,
                                                                                 NULL,
                                                                                 (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                                                                 kCFStringEncodingUTF8));
}

@end
