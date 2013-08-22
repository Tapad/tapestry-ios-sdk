//
//  TAMacros.h
//  Tapestry
//
//  Created by Toby Matejovsky on 8/21/13.
//  Copyright (c) 2013 Tapad. All rights reserved.
//

#define TA_DEBUG

#ifdef __OBJC__

#ifdef TA_DEBUG
    #define TALog(fmt, ...) NSLog((@"TA_DEBUG: %s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);
#else
    #define TALog(fmt, ...)
#endif

#endif