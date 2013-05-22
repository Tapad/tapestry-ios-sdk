//
//  TapadPreferences.h
//  AdWhirlSDK2_Sample
//
//  Created by gmack on 7/7/11.
//  Copyright 2011 Tapad, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface TapadPreferences : NSObject {}

+ (BOOL) registerDefaults;

+ (void) setTapadOptOutUserDefault;
+ (NSString*) getTapadOptOutUserDefault;
+ (void) setTapadPartnerId:(NSString*)appId;
+ (NSString*) getTapadPartnerId;
+ (BOOL) willSendIdFor:(NSString*)method;
+ (void) setSendIdFor:(NSString*)method to:(BOOL)state;
+ (void) setCustomDataForKey:(NSString*)key value:(id)value;
+ (id) getCustomDataForKey:(NSString*)key;
+ (void) removeCustomDataForKey:(NSString*)key;
+ (void) clearAllCustomData;
+ (NSString*) dictionaryAsEncodedCsvString:(NSDictionary*)data;
+ (NSString*) arrayAsEncodedCsvString:(NSArray*)data;

@end