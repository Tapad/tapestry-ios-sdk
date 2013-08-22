//
//  TapadIdentifiers.h
//
//  Created by Li Qiu on 6/20/2012.
//  Copyright 2012 Tapad, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <ADSupport/ASIdentifierManager.h>
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)

@interface TATapadIdentifiers : NSObject

+ (void)setIdentifierEnabledMAC:(BOOL)enabled;
+ (void)setIdentifierEnabledOpenUDID:(BOOL)enabled;

+ (NSString*) typedDeviceIDsAsCommaSeparatedString;
+ (NSDictionary*) typedDeviceIDs;

@end