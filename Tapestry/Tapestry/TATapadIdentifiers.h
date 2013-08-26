//
//  TapadIdentifiers.h
//
//  Created by Li Qiu on 6/20/2012.
//  Copyright 2012 Tapad, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <ADSupport/ASIdentifierManager.h>
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)

/**
 TATapadIdentifiers is an interface to retrieve device IDs and to configure device ID preferences.
 
 There are three classes of identifiers: IDFA, OpenUDID, and hashed MAC address.
 
 __IDFA__ is managed by iOS; users can opt out via general preferences. As of summer 2013, 94% of iOS devices support IDFA (iOS 6+).
 
 __OpenUDID__ can be disabled by setting `setIdentifierEnabledOpenUDID` to `NO`. If this method is enabled but the user has opted out, the value is the generic OpenUDID opt-out value.
 
 __Hashed MAC addresses__ can be disabled by setting `setIdentifierEnabledMAC` to `NO`. If this method is enabled, the MAC address is hashed to protect privacy. If a user is opted out, the hashed MAC address is still sent because the opt-out status is stored on Tapad's servers, and it must be sent in order to properly look up the opt-out status and prevent tracking.
 
 If you wish to avoid having any code which even accesses the device's MAC address, simply remove the following methods and their usages in `TATapadIdentifiers.m`:
    fetchMD5HashedMAC
    fetchMD5HashedRawMAC
    fetchSHA1HashedMAC
    fetchSHA1HashedRawMAC
 
 If any of the identifiers turns out to be opted out, Tapad considers the entire device opted out. More privacy information is available here: http://www.tapad.com/consumer-privacy/
 */
@interface TATapadIdentifiers : NSObject

/** @name Configuring IDs */

/** Set usage of hashed MAC address as an identifier.
  @param enabled YES to enable MAC identifiers, NO to disable
 */
+ (void)setIdentifierEnabledMAC:(BOOL)enabled;

/** Set usage of OpenUDID as an identifier.
  @param enabled YES to enable OpenUDID, NO to disable
 */
+ (void)setIdentifierEnabledOpenUDID:(BOOL)enabled;


/** @name Retrieving IDs */

/** Get device IDs as string
  @return comma-separated list of enabled_id_type:id_value.
  */
+ (NSString*) typedDeviceIDsAsCommaSeparatedString;

/** Get device IDs as dictionary
   @return dictionary of enabled id types -> id values.
  */
+ (NSDictionary*) typedDeviceIDs;

@end
