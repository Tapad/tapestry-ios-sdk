//
//  TAURLHelper.h
//  Tapestry
//
//  Created by Toby Matejovsky on 7/29/13.
//  Copyright (c) 2013 Tapad. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TAURLHelper : NSObject
+ (NSDictionary*)paramsFromUri:(NSString*)uri;
@end
