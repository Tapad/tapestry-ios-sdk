//
//  TATapestryResponse.h
//  Tapestry
//
//  Created by Sveinung Kval Bakken on 30.07.13.
//  Copyright (c) 2013 Tapad. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TATapestryResponse : NSObject

+ (TATapestryResponse*) responseWithDictionary:(NSDictionary*)dictionary;
- (BOOL)wasSuccess;
- (NSDictionary*)IDs;
- (NSDictionary*)data;
- (NSArray*)audiences;
- (NSArray*)platforms;
- (NSArray*)errors;
- (NSArray*)devices;

@end
