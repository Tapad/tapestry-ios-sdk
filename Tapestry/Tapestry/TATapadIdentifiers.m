//
//  TapadIdentifiers.m
//
//  Created by Li Qiu on 6/20/2012.
//  Copyright 2012 Tapad, Inc. All rights reserved.
//

#import <CommonCrypto/CommonDigest.h>

#import "OpenUDID.h"
#import "TATapadIdentifiers.h"
#import "TATapadPreferences.h"
#import "UIDevice-Hardware.h"
#import "NSString+MD5.h"

@implementation TATapadIdentifiers

static NSString* kMETHOD_OPENUDID = @"OpenUDID";
static NSString* kTYPE_OPENUDID = @"oudid"; // @"0";

+ (BOOL) willSendOpenUDID {
    return [TATapadPreferences willSendIdFor:kMETHOD_OPENUDID];
}

+ (void) sendOpenUDID:(BOOL)state {
    [TATapadPreferences setSendIdFor:kMETHOD_OPENUDID to:state];
}

+ (NSString*) fetchOpenUDID {
    return [NSString stringWithFormat:@"%@:%@", kTYPE_OPENUDID, [OpenUDID value]];
}

static NSString* kMETHOD_MD5_HASHED_RAW_MAC = @"MD5 Hashed Raw MAC";
static NSString* kTYPE_MD5_HASHED_RAW_MAC = @"md5rmac"; // @"1";

+ (BOOL) willSendMD5HashedRawMAC {
    return [TATapadPreferences willSendIdFor:kMETHOD_MD5_HASHED_RAW_MAC];
}

+ (void) sendMD5HashedRawMAC:(BOOL)state {
    [TATapadPreferences setSendIdFor:kMETHOD_MD5_HASHED_RAW_MAC to:state];
}

+ (NSString*) fetchMD5HashedRawMAC {
    // storage of mac addy bytes
    unsigned char macBuffer[6];
    // storage of md5 output bytes
    unsigned char md5Buffer[CC_MD5_DIGEST_LENGTH];
    
    if ([[UIDevice currentDevice] macaddressTo:macBuffer]) {
        // Create 16 byte MD5 hash value, store in buffer
        CC_MD5(macBuffer, 6, md5Buffer);
        
        // Convert MD5 value in the buffer to NSString of hex values
        NSMutableString* output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
        for (int i = 0; i < CC_MD5_DIGEST_LENGTH; i++) {
            [output appendFormat:@"%02x",md5Buffer[i]];
        }
        return [NSString stringWithFormat:@"%@:%@", kTYPE_MD5_HASHED_RAW_MAC, output];
    }
    else {
        return [NSString stringWithFormat:@"%@:%@", kTYPE_MD5_HASHED_RAW_MAC, @"0"];
    }
}


static NSString* kMETHOD_SHA1_HASHED_RAW_MAC = @"SHA1 Hashed Raw MAC";
static NSString* kTYPE_SHA1_HASHED_RAW_MAC = @"sha1rmac"; // @"2";

+ (BOOL) willSendSHA1HashedRawMAC {
    return [TATapadPreferences willSendIdFor:kMETHOD_SHA1_HASHED_RAW_MAC];
}

+ (void) sendSHA1HashedRawMAC:(BOOL)state {
    [TATapadPreferences setSendIdFor:kMETHOD_SHA1_HASHED_RAW_MAC to:state];
}

+ (NSString*) fetchSHA1HashedRawMAC {
    // storage of mac addy bytes
    unsigned char macBuffer[6];
    // storage of sha1 output bytes
    unsigned char sha1Buffer[CC_SHA1_DIGEST_LENGTH];
    
    if ([[UIDevice currentDevice] macaddressTo:macBuffer]) {
        // Create 20 byte SHA1 hash value, store in buffer
        CC_SHA1(macBuffer, 6, sha1Buffer);
        
        // Convert SHA1 value in the buffer to NSString of hex values
        NSMutableString* output = [NSMutableString stringWithCapacity:CC_SHA1_DIGEST_LENGTH * 2];
        for (int i = 0; i < CC_SHA1_DIGEST_LENGTH; i++) {
            [output appendFormat:@"%02x",sha1Buffer[i]];
        }
        return [NSString stringWithFormat:@"%@:%@", kTYPE_SHA1_HASHED_RAW_MAC, output];
    }
    else {
        return [NSString stringWithFormat:@"%@:%@", kTYPE_SHA1_HASHED_RAW_MAC, @"0"];
    }
}

static NSString* kMETHOD_MD5_HASHED_MAC = @"MD5 Hashed MAC";
static NSString* kTYPE_MD5_HASHED_MAC = @"md5mac"; // @"5";

+ (BOOL) willSendMD5HashedMAC {
    return [TATapadPreferences willSendIdFor:kMETHOD_MD5_HASHED_MAC];
}

+ (void) sendMD5HashedMAC:(BOOL)state {
    [TATapadPreferences setSendIdFor:kMETHOD_MD5_HASHED_MAC to:state];
}

+ (NSString*) fetchMD5HashedMAC {
    if ([[UIDevice currentDevice] macaddress] == NULL) {
        return [NSString stringWithFormat:@"%@:%@", kTYPE_MD5_HASHED_MAC, @"0"];
    }
    else {
        return [NSString stringWithFormat:@"%@:%@", kTYPE_MD5_HASHED_MAC, [[[UIDevice currentDevice] macaddress] ta_MD5]];
    }
}

static NSString* kMETHOD_SHA1_HASHED_MAC = @"SHA1 Hashed MAC";
static NSString* kTYPE_SHA1_HASHED_MAC = @"sha1mac"; // @"6";

+ (BOOL) willSendSHA1HashedMAC {
    return [TATapadPreferences willSendIdFor:kMETHOD_SHA1_HASHED_MAC];
}

+ (void) sendSHA1HashedMAC:(BOOL)state {
    [TATapadPreferences setSendIdFor:kMETHOD_SHA1_HASHED_MAC to:state];
}

+ (NSString*) fetchSHA1HashedMAC {
    if ([[UIDevice currentDevice] macaddress] == NULL) {
        return [NSString stringWithFormat:@"%@:%@", kTYPE_SHA1_HASHED_MAC, @"0"];
    }
    else {
        return [NSString stringWithFormat:@"%@:%@", kTYPE_SHA1_HASHED_MAC, [[[UIDevice currentDevice] macaddress] ta_SHA1]];
    }
}


static NSString* kMETHOD_ADVERTISING_IDENTIFIER = @"Advertising Identifier";
static NSString* kTYPE_ADVERTISING_IDENTIFIER = @"idfa"; // @"7";

+ (BOOL) willSendAdvertisingIdentifier {
    return [TATapadPreferences willSendIdFor:kMETHOD_ADVERTISING_IDENTIFIER];
}

+ (void) sendAdvertisingIdentifier:(BOOL)state {
    [TATapadPreferences setSendIdFor:kMETHOD_ADVERTISING_IDENTIFIER to:state];
}

+ (NSString*) fetchAdvertisingIdentifier {
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"6.0")) {
        if ([[ASIdentifierManager sharedManager] isAdvertisingTrackingEnabled]) {
            return [NSString stringWithFormat:@"%@:%@", kTYPE_ADVERTISING_IDENTIFIER, [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString]];
        }
        else {
            return [NSString stringWithFormat:@"%@:%@", kTYPE_ADVERTISING_IDENTIFIER, @"0"];
        }
    }
    else {
        return [NSString stringWithFormat:@"%@:%@", kTYPE_ADVERTISING_IDENTIFIER, @"0"];
    }
}

+ (NSString*) deviceID {
    NSMutableArray* ids = [NSMutableArray arrayWithCapacity:7]; // autoreleased

    if ([TATapadIdentifiers willSendOpenUDID]) {
      [ids addObject:[TATapadIdentifiers fetchOpenUDID]];
    }

    if ([TATapadIdentifiers willSendMD5HashedRawMAC]) {
        [ids addObject:[TATapadIdentifiers fetchMD5HashedRawMAC]];
    }

    if ([TATapadIdentifiers willSendSHA1HashedRawMAC]) {
        [ids addObject:[TATapadIdentifiers fetchSHA1HashedRawMAC]];
    }

    if ([TATapadIdentifiers willSendMD5HashedMAC]) {
        [ids addObject:[TATapadIdentifiers fetchMD5HashedMAC]];
    }

    if ([TATapadIdentifiers willSendSHA1HashedMAC]) {
        [ids addObject:[TATapadIdentifiers fetchSHA1HashedMAC]];
    }

    if ([TATapadIdentifiers willSendAdvertisingIdentifier]) {
        [ids addObject:[TATapadIdentifiers fetchAdvertisingIdentifier]];
    }

    if ([ids count] == 0) {
        return [TATapadIdentifiers defaultDeviceID];
    }
    else {
        return [ids componentsJoinedByString:@","];
    }
}

+ (NSString*) defaultDeviceID {
    // by default, if nothing is explicitly enabled, we will send OpenUDID
    return [TATapadIdentifiers fetchOpenUDID];
}

@end
