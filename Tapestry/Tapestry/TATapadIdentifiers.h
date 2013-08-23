//
//  TapadIdentifiers.h
//
//  Created by Li Qiu on 6/20/2012.
//  Copyright 2012 Tapad, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <ADSupport/ASIdentifierManager.h>
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)

/** Interface to retreive device IDs and to configure device ID preferences. */
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
