//
//  TapadPreferences.m
//
//  Created by gmack on 7/7/11.
//  Copyright 2011 Tapad, Inc. All rights reserved.
//

#import "TATapadPreferences.h"


@implementation TATapadPreferences

static NSString* kTAPAD_OPT_OUT = @"Tapad Opt-out";
static NSString* kTAPAD_GEO_OPT_IN = @"Tapad Geo Opt-in";
static NSString* kTAPESTRY_PARTNER_ID = @"Tapestry Partner Id";
static NSString* kTAPAD_IDENTIFIER_PREFIX = @"Tapad Identifier";
static NSString* kTAPAD_CUSTOM_DATA = @"Tapad Custom Data";

+ (BOOL) registerDefaults {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *appDefaults = [NSDictionary
                                 dictionaryWithObjectsAndKeys:
                                 [NSNumber numberWithBool:NO], kTAPAD_OPT_OUT,
                                 [NSNumber numberWithBool:NO], kTAPAD_GEO_OPT_IN,
                                 [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleName"], kTAPESTRY_PARTNER_ID,
                                 [NSDictionary dictionary], kTAPAD_CUSTOM_DATA,
                                 nil
                                 ];
    
    [defaults registerDefaults:appDefaults];
    BOOL syncOK = [defaults synchronize];
    return syncOK;
}

+ (void) setTapadOptOutUserDefault {
    [[NSUserDefaults standardUserDefaults] setObject:@"YES" forKey:kTAPAD_OPT_OUT];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (NSString*) getTapadOptOutUserDefault {
    NSString* defaultValue = [[NSUserDefaults standardUserDefaults] stringForKey:kTAPAD_OPT_OUT];
    return defaultValue;
}

+ (void) setTapadPartnerId:(NSString*)partnerId {
    [[NSUserDefaults standardUserDefaults] setObject:partnerId forKey:kTAPESTRY_PARTNER_ID];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (NSString*) getTapadPartnerId {
    NSString* defaultValue = [[NSUserDefaults standardUserDefaults] stringForKey:kTAPESTRY_PARTNER_ID];
    return defaultValue;
}

+ (BOOL) willSendIdFor:(NSString*)method {
    BOOL defaultValue = [[NSUserDefaults standardUserDefaults] boolForKey:[NSString stringWithFormat:@"%@ %@", kTAPAD_IDENTIFIER_PREFIX, method]];
    return defaultValue;
}

+ (void) setSendIdFor:(NSString *)method to:(BOOL)state {
    [[NSUserDefaults standardUserDefaults] setBool:state forKey:[NSString stringWithFormat:@"%@ %@", kTAPAD_IDENTIFIER_PREFIX, method]];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (void) setCustomDataForKey:(NSString*)key value:(id)value {
    NSDictionary* existingCustomData = [[NSUserDefaults standardUserDefaults] objectForKey:kTAPAD_CUSTOM_DATA];
    NSMutableDictionary* newCustomData = [NSMutableDictionary dictionaryWithDictionary:existingCustomData];
    [newCustomData setObject:value forKey: key];
    [[NSUserDefaults standardUserDefaults] setObject:newCustomData forKey:kTAPAD_CUSTOM_DATA];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (id) getCustomDataForKey:(NSString*)key {
    NSDictionary* existingCustomData = [[NSUserDefaults standardUserDefaults] objectForKey:kTAPAD_CUSTOM_DATA];
    return [existingCustomData objectForKey:key];
}

+ (void) removeCustomDataForKey:(NSString*)key {
    NSDictionary* existingCustomData = [[NSUserDefaults standardUserDefaults] objectForKey:kTAPAD_CUSTOM_DATA];
    NSMutableDictionary* newCustomData = [NSMutableDictionary dictionaryWithDictionary:existingCustomData];
    [newCustomData removeObjectForKey:key];
    [[NSUserDefaults standardUserDefaults] setObject:newCustomData forKey:kTAPAD_CUSTOM_DATA];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (void) clearAllCustomData {
    [[NSUserDefaults standardUserDefaults] setObject:[NSDictionary dictionary] forKey:kTAPAD_CUSTOM_DATA];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (NSString*) dictionaryAsEncodedCsvString:(NSDictionary*)data {
    NSMutableArray* params = [NSMutableArray arrayWithCapacity:[data count]]; // autoreleased
    for (id key in data) {
        id value = [data objectForKey:key];
        [params addObject:[NSString stringWithFormat:@"%@:%@", [TATapadPreferences encodeString:key], [TATapadPreferences encodeString:value] ]];
    }
    if ([params count] == 0) {
        return NULL;
    }
    else {
        return [params componentsJoinedByString:@","];
    }
}

+ (NSString*) arrayAsEncodedCsvString:(NSArray*)data {
    NSMutableArray* params = [NSMutableArray arrayWithCapacity:[data count]]; // autoreleased
    for (id x in data) {
        [params addObject:[TATapadPreferences encodeString:x]];
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
