//
//  OpenUDID.m
//  openudid
//
//  initiated by Yann Lechelle (cofounder @Appsfire) on 8/28/11.
//  Copyright 2011, 2012 OpenUDID.org
//
//  Initiators/root branches
//      iOS code: https://github.com/ylechelle/OpenUDID
//      Android code: https://github.com/vieux/OpenUDID
//
//  Contributors:
//      https://github.com/ylechelle/OpenUDID/contributors
//

/*
 http://en.wikipedia.org/wiki/Zlib_License
 
 This software is provided 'as-is', without any express or implied
 warranty. In no event will the authors be held liable for any damages
 arising from the use of this software.
 
 Permission is granted to anyone to use this software for any purpose,
 including commercial applications, and to alter it and redistribute it
 freely, subject to the following restrictions:
 
 1. The origin of this software must not be misrepresented; you must not
 claim that you wrote the original software. If you use this software
 in a product, an acknowledgment in the product documentation would be
 appreciated but is not required.
 
 2. Altered source versions must be plainly marked as such, and must not be
 misrepresented as being the original software.
 
 3. This notice may not be removed or altered from any source
 distribution.
 */

#if __has_feature(objc_arc)
#error This file uses the classic non-ARC retain/release model; hints below...
// to selectively compile this file as non-ARC, do as follows:
// https://img.skitch.com/20120717-g3ag5h9a6ehkgpmpjiuen3qpwp.png
#endif

#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)

#import "TAOpenUDID.h"
#import <CommonCrypto/CommonDigest.h> // Need to import for CC_MD5 access
#if TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR
#import <UIKit/UIPasteboard.h>
#import <UIKit/UIKit.h>
#import <AdSupport/AdSupport.h>
#else
#import <AppKit/NSPasteboard.h>
#endif

#define TAOpenUDIDLog(fmt, ...)
//#define TAOpenUDIDLog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);
//#define TAOpenUDIDLog(fmt, ...) NSLog((@"[Line %d] " fmt), __LINE__, ##__VA_ARGS__);

static NSString * kTAOpenUDIDSessionCache = nil;
static NSString * const kTAOpenUDIDKey = @"OpenUDID";
static NSString * const kTAOpenUDIDSlotKey = @"OpenUDID_slot";
static NSString * const kTAOpenUDIDAppUIDKey = @"OpenUDID_appUID";
static NSString * const kTAOpenUDIDTSKey = @"OpenUDID_createdTS";
static NSString * const kTAOpenUDIDOOTSKey = @"OpenUDID_optOutTS";
static NSString * const kTAOpenUDIDDomain = @"org.OpenUDID";
static NSString * const kTAOpenUDIDSlotPBPrefix = @"org.OpenUDID.slot.";
static int const kTAOpenUDIDRedundancySlots = 100;

@interface TAOpenUDID (Private)
+ (void) _setDict:(id)dict forPasteboard:(id)pboard;
+ (NSMutableDictionary*) _getDictFromPasteboard:(id)pboard;
+ (NSString*) _generateFreshOpenUDID;
@end

@implementation TAOpenUDID

// Archive a NSDictionary inside a pasteboard of a given type
// Convenience method to support iOS & Mac OS X
//
+ (void) _setDict:(id)dict forPasteboard:(id)pboard {
#if TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR
    [pboard setData:[NSKeyedArchiver archivedDataWithRootObject:dict] forPasteboardType:kTAOpenUDIDDomain];
#else
    [pboard setData:[NSKeyedArchiver archivedDataWithRootObject:dict] forType:kTAOpenUDIDDomain];
#endif
}

// Retrieve an NSDictionary from a pasteboard of a given type
// Convenience method to support iOS & Mac OS X
//
+ (NSMutableDictionary*) _getDictFromPasteboard:(id)pboard {
#if TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR
    id item = [pboard dataForPasteboardType:kTAOpenUDIDDomain];
#else
	id item = [pboard dataForType:kTAOpenUDIDDomain];
#endif
    if (item) {
        @try{
            item = [NSKeyedUnarchiver unarchiveObjectWithData:item];
        } @catch(NSException* e) {
            TAOpenUDIDLog(@"Unable to unarchive item %@ on pasteboard!", [pboard name]);
            item = nil;
        }
    }
    
    // return an instance of a MutableDictionary
    return [NSMutableDictionary dictionaryWithDictionary:(item == nil || [item isKindOfClass:[NSDictionary class]]) ? item : nil];
}

// Private method to create and return a new OpenUDID
// Theoretically, this function is called once ever per application when calling [OpenUDID value] for the first time.
// After that, the caching/pasteboard/redundancy mechanism inside [OpenUDID value] returns a persistent and cross application OpenUDID
//
+ (NSString*) _generateFreshOpenUDID {
    
    NSString* _openUDID = nil;
      
    //
    // !!!!! IMPORTANT README !!!!!
    //
    // August 2012: iOS 6 introduces new APIs that help us deal with the now deprecated [UIDevice uniqueIdentifier]
    // Since iOS 6 is still pre-release and under NDA, the following piece of code is meant to produce an error at
    // compile time. Accredited developers integrating OpenUDID are expected to review the iOS 6 release notes and
    // documentation, and replace the underscore ______ in the last part of the selector below with the right
    // selector syntax as described here (make sure to use the right one! last word starts with the letter "A"):
    // https://developer.apple.com/library/prerelease/ios/#documentation/UIKit/Reference/UIDevice_Class/Reference/UIDevice.html
    //
    // The semantic compiler warnings are still normal if you are compiling for iOS 5 only since Xcode will not
    // know about the two instance methods used on that line; the code running on iOS will work well at run-time.
    // Either way, it's time that you junped on the iOS 6 bandwagon and start testing your code on iOS 6 ;-)
    //
    // WHAT IS THE SIGNIFICANCE OF THIS CHANGE?
    //
    // Essentially, this means that OpenUDID will keep on behaving the same way as before for existing users or
    // new users in iOS 5 and before. For new users on iOS 6 and after, the new official public APIs will take over.
    // OpenUDID will therefore be obsoleted when iOS reaches significant adoption, anticipated around mid-2013.
    
    /*
     
     September 14; ok, new development. The alleged API has moved!
     This part of the code will therefore be updated when iOS 6 is actually released.
     Nevertheless, if you want to go ahead, the code should be pretty easy to
     guess... it involves including a .h file from a nine-letter framework that ends
     with the word "Support", and then assigning _openUDID with the only identifier method called on the sharedManager of that new class... don't forget to add
     the framework to your project!
     
      */
     
     #if TARGET_OS_IPHONE
     if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"6.0") && [[ASIdentifierManager sharedManager] isAdvertisingTrackingEnabled]) {
         _openUDID = [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString];
     }
     #endif
     
    
    
    // Next we generate a UUID.
    // UUIDs (Universally Unique Identifiers), also known as GUIDs (Globally Unique Identifiers) or IIDs
    // (Interface Identifiers), are 128-bit values guaranteed to be unique. A UUID is made unique over
    // both space and time by combining a value unique to the computer on which it was generated—usually the
    // Ethernet hardware address—and a value representing the number of 100-nanosecond intervals since
    // October 15, 1582 at 00:00:00.
    // We then hash this UUID with md5 to get 32 bytes, and then add 4 extra random bytes
    // Collision is possible of course, but unlikely and suitable for most industry needs (e.g. aggregate tracking)
    //
    if (_openUDID==nil) {
        CFUUIDRef uuid = CFUUIDCreate(kCFAllocatorDefault);
        CFStringRef cfstring = CFUUIDCreateString(kCFAllocatorDefault, uuid);
        const char *cStr = CFStringGetCStringPtr(cfstring,CFStringGetFastestEncoding(cfstring));
        unsigned char result[16];
        CC_MD5( cStr, (CC_LONG)strlen(cStr), result );
        CFRelease(uuid);
        CFRelease(cfstring);
        
        _openUDID = [NSString stringWithFormat:
                     @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%08lx",
                     result[0], result[1], result[2], result[3],
                     result[4], result[5], result[6], result[7],
                     result[8], result[9], result[10], result[11],
                     result[12], result[13], result[14], result[15],
                     (unsigned long)(arc4random() % NSUIntegerMax)];
    }
    
    // Call to other developers in the Open Source community:
    //
    // feel free to suggest better or alternative "UDID" generation code above.
    // NOTE that the goal is NOT to find a better hash method, but rather, find a decentralized (i.e. not web-based)
    // 160 bits / 20 bytes random string generator with the fewest possible collisions.
    //
    
    return _openUDID;
}


// Main public method that returns the OpenUDID
// This method will generate and store the OpenUDID if it doesn't exist, typically the first time it is called
// It will return the null udid (forty zeros) if the user has somehow opted this app out (this is subject to 3rd party implementation)
// Otherwise, it will register the current app and return the OpenUDID
//
+ (NSString*) value {
    return [TAOpenUDID valueWithError:nil];
}

+ (NSString*) valueWithError:(NSError **)error {
    
    if (kTAOpenUDIDSessionCache!=nil) {
        if (error!=nil)
            *error = [NSError errorWithDomain:kTAOpenUDIDDomain
                                         code:kTAOpenUDIDErrorNone
                                     userInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"OpenUDID in cache from first call",@"description", nil]];
        return kTAOpenUDIDSessionCache;
    }
    
  	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    // The AppUID will uniquely identify this app within the pastebins
    //
    NSString * appUID = [defaults objectForKey:kTAOpenUDIDAppUIDKey];
    if(appUID == nil)
    {
        // generate a new uuid and store it in user defaults
        CFUUIDRef uuid = CFUUIDCreate(NULL);
        appUID = (NSString *) CFUUIDCreateString(NULL, uuid);
        CFRelease(uuid);
        [appUID autorelease];
    }
    
    NSString* openUDID = nil;
    NSString* myRedundancySlotPBid = nil;
    NSDate* optedOutDate = nil;
    BOOL optedOut = NO;
    BOOL saveLocalDictToDefaults = NO;
    BOOL isCompromised = NO;
    
    // Do we have a local copy of the OpenUDID dictionary?
    // This local copy contains a copy of the openUDID, myRedundancySlotPBid (and unused in this block, the local bundleid, and the timestamp)
    //
    id localDict = [defaults objectForKey:kTAOpenUDIDKey];
    if ([localDict isKindOfClass:[NSDictionary class]]) {
        localDict = [NSMutableDictionary dictionaryWithDictionary:localDict]; // we might need to set/overwrite the redundancy slot
        openUDID = [localDict objectForKey:kTAOpenUDIDKey];
        myRedundancySlotPBid = [localDict objectForKey:kTAOpenUDIDSlotKey];
        optedOutDate = [localDict objectForKey:kTAOpenUDIDOOTSKey];
        optedOut = optedOutDate!=nil;
        TAOpenUDIDLog(@"localDict = %@",localDict);
    }
    
    // Here we go through a sequence of slots, each of which being a UIPasteboard created by each participating app
    // The idea behind this is to both multiple and redundant representations of OpenUDIDs, as well as serve as placeholder for potential opt-out
    //
    NSString* availableSlotPBid = nil;
    NSMutableDictionary* frequencyDict = [NSMutableDictionary dictionaryWithCapacity:kTAOpenUDIDRedundancySlots];
    for (int n=0; n<kTAOpenUDIDRedundancySlots; n++) {
        NSString* slotPBid = [NSString stringWithFormat:@"%@%d",kTAOpenUDIDSlotPBPrefix,n];
#if TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR
        UIPasteboard* slotPB = [UIPasteboard pasteboardWithName:slotPBid create:NO];
#else
        NSPasteboard* slotPB = [NSPasteboard pasteboardWithName:slotPBid];
#endif
        TAOpenUDIDLog(@"SlotPB name = %@",slotPBid);
        if (slotPB==nil) {
            // assign availableSlotPBid to be the first one available
            if (availableSlotPBid==nil) availableSlotPBid = slotPBid;
        } else {
            NSDictionary* dict = [TAOpenUDID _getDictFromPasteboard:slotPB];
            NSString* oudid = [dict objectForKey:kTAOpenUDIDKey];
            TAOpenUDIDLog(@"SlotPB dict = %@",dict);
            if (oudid==nil) {
                // availableSlotPBid could inside a non null slot where no oudid can be found
                if (availableSlotPBid==nil) availableSlotPBid = slotPBid;
            } else {
                // increment the frequency of this oudid key
                int count = [[frequencyDict valueForKey:oudid] intValue];
                [frequencyDict setObject:[NSNumber numberWithInt:++count] forKey:oudid];
            }
            // if we have a match with the app unique id,
            // then let's look if the external UIPasteboard representation marks this app as OptedOut
            NSString* gid = [dict objectForKey:kTAOpenUDIDAppUIDKey];
            if (gid!=nil && [gid isEqualToString:appUID]) {
                myRedundancySlotPBid = slotPBid;
                // the local dictionary is prime on the opt-out subject, so ignore if already opted-out locally
                if (optedOut) {
                    optedOutDate = [dict objectForKey:kTAOpenUDIDOOTSKey];
                    optedOut = optedOutDate!=nil;
                }
            }
        }
    }
    
    // sort the Frequency dict with highest occurence count of the same OpenUDID (redundancy, failsafe)
    // highest is last in the list
    //
    NSArray* arrayOfUDIDs = [frequencyDict keysSortedByValueUsingSelector:@selector(compare:)];
    NSString* mostReliableOpenUDID = (arrayOfUDIDs!=nil && [arrayOfUDIDs count]>0)? [arrayOfUDIDs lastObject] : nil;
    TAOpenUDIDLog(@"Freq Dict = %@\nMost reliable %@",frequencyDict,mostReliableOpenUDID);
    
    // if openUDID was not retrieved from the local preferences, then let's try to get it from the frequency dictionary above
    //
    if (openUDID==nil) {
        if (mostReliableOpenUDID==nil) {
            // this is the case where this app instance is likely to be the first one to use OpenUDID on this device
            // we create the OpenUDID, legacy or semi-random (i.e. most certainly unique)
            //
            openUDID = [TAOpenUDID _generateFreshOpenUDID];
        } else {
            // or we leverage the OpenUDID shared by other apps that have already gone through the process
            //
            openUDID = mostReliableOpenUDID;
        }
        // then we create a local representation
        //
        if (localDict==nil) {
            localDict = [NSMutableDictionary dictionaryWithCapacity:4];
            [localDict setObject:openUDID forKey:kTAOpenUDIDKey];
            [localDict setObject:appUID forKey:kTAOpenUDIDAppUIDKey];
            [localDict setObject:[NSDate date] forKey:kTAOpenUDIDTSKey];
            if (optedOut) [localDict setObject:optedOutDate forKey:kTAOpenUDIDTSKey];
            saveLocalDictToDefaults = YES;
        }
    }
    else {
        // Sanity/tampering check
        //
        if (mostReliableOpenUDID!=nil && ![mostReliableOpenUDID isEqualToString:openUDID])
            isCompromised = YES;
    }
    
    // Here we store in the available PB slot, if applicable
    //
    TAOpenUDIDLog(@"Available Slot %@ Existing Slot %@",availableSlotPBid,myRedundancySlotPBid);
    if (availableSlotPBid!=nil && (myRedundancySlotPBid==nil || [availableSlotPBid isEqualToString:myRedundancySlotPBid])) {
#if TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR
        UIPasteboard* slotPB = [UIPasteboard pasteboardWithName:availableSlotPBid create:YES];
        [slotPB setPersistent:YES];
#else
        NSPasteboard* slotPB = [NSPasteboard pasteboardWithName:availableSlotPBid];
#endif
        
        // save slotPBid to the defaults, and remember to save later
        //
        if (localDict) {
            [localDict setObject:availableSlotPBid forKey:kTAOpenUDIDSlotKey];
            saveLocalDictToDefaults = YES;
        }
        
        // Save the local dictionary to the corresponding UIPasteboard slot
        //
        if (openUDID && localDict)
            [TAOpenUDID _setDict:localDict forPasteboard:slotPB];
    }
    
    // Save the dictionary locally if applicable
    //
    if (localDict && saveLocalDictToDefaults)
        [defaults setObject:localDict forKey:kTAOpenUDIDKey];
    
    // If the UIPasteboard external representation marks this app as opted-out, then to respect privacy, we return the ZERO OpenUDID, a sequence of 40 zeros...
    // This is a *new* case that developers have to deal with. Unlikely, statistically low, but still.
    // To circumvent this and maintain good tracking (conversion ratios, etc.), developers are invited to calculate how many of their users have opted-out from the full set of users.
    // This ratio will let them extrapolate convertion ratios more accurately.
    //
    if (optedOut) {
        if (error!=nil) *error = [NSError errorWithDomain:kTAOpenUDIDDomain
                                                     code:kTAOpenUDIDErrorOptedOut
                                                 userInfo:[NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"Application with unique id %@ is opted-out from OpenUDID as of %@",appUID,optedOutDate],@"description", nil]];
        
        kTAOpenUDIDSessionCache = [[NSString stringWithFormat:@"%040x",0] retain];
        return kTAOpenUDIDSessionCache;
    }
    
    // return the well earned openUDID!
    //
    if (error!=nil) {
        if (isCompromised)
            *error = [NSError errorWithDomain:kTAOpenUDIDDomain
                                         code:kTAOpenUDIDErrorCompromised
                                     userInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"Found a discrepancy between stored OpenUDID (reliable) and redundant copies; one of the apps on the device is most likely corrupting the OpenUDID protocol",@"description", nil]];
        else
            *error = [NSError errorWithDomain:kTAOpenUDIDDomain
                                         code:kTAOpenUDIDErrorNone
                                     userInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"OpenUDID succesfully retrieved",@"description", nil]];
    }
    kTAOpenUDIDSessionCache = [openUDID retain];
    return kTAOpenUDIDSessionCache;
}

+ (void) setOptOut:(BOOL)optOutValue {
    
    // init call
    [TAOpenUDID value];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    // load the dictionary from local cache or create one
    id dict = [defaults objectForKey:kTAOpenUDIDKey];
    if ([dict isKindOfClass:[NSDictionary class]]) {
        dict = [NSMutableDictionary dictionaryWithDictionary:dict];
    } else {
        dict = [NSMutableDictionary dictionaryWithCapacity:2];
    }
    
    // set the opt-out date or remove key, according to parameter
    if (optOutValue)
        [dict setObject:[NSDate date] forKey:kTAOpenUDIDOOTSKey];
    else
        [dict removeObjectForKey:kTAOpenUDIDOOTSKey];
    
  	// store the dictionary locally
    [defaults setObject:dict forKey:kTAOpenUDIDKey];
    
    TAOpenUDIDLog(@"Local dict after opt-out = %@",dict);
    
    // reset memory cache 
    kTAOpenUDIDSessionCache = nil;
    
}

@end