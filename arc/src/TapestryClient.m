//
//  Copyright 2013 Tapad, Inc. All rights reserved.
//

#import "TapestryRequestBuilder.h"
#import "TapadPreferences.h"
#import "TapadIdentifiers.h"
#import "TapestryClient.h"
#import "UIDevice-Hardware.h"

#pragma mark private protocol for internal stuff

@interface TapestryClient ()

    @property (nonatomic,copy) NSString* protocol;
    @property (nonatomic,copy) NSString* dns;
    @property (nonatomic,copy) NSString* port;
    @property (nonatomic,copy) NSString* apiVersion;

- (NSString*) stringWithDeviceParams;
- (id) initWithTapestryRequest:(TapestryRequestBuilder *)req;


// both of these assume the properties have been set during request processing
- (BOOL) checkIfResponseSuccessful;
- (BOOL) checkForError;

+ (NSString*) visibleResponseStatusCode:(NSURLResponse *)response;


@end


@implementation TapestryClient

@synthesize protocol;
@synthesize dns;
@synthesize port;
@synthesize apiVersion;


@synthesize request;
@synthesize lastError;
@synthesize lastResponse;
@synthesize hasError;
@synthesize responseSuccess;


// params understood by tapad
static NSString*const ktypedUid      =@"ta_typed_did";
static NSString*const kplatform      =@"ta_platform";

+ (TapestryClient *) initializeForRequest:(TapestryRequestBuilder *)req {
    TapestryClient *client = [[TapestryClient alloc] initWithTapestryRequest:req];
    return client;
}

// Must always override super's designated initializer.
- (id) init {
    if ((self = [super init])) {
        protocol=@"http";
        dns=@"tapestry.tapad.com";
        port=@":80";
        apiVersion=@"1";
        hasError=NO;
        responseSuccess=NO;
    }
    return self;
}

- (id) initWithTapestryRequest:(TapestryRequestBuilder *)req {
    if (self = [self init]) { // note: not super init!
        
        NSString *urlString = [[NSString stringWithFormat:@"%@://%@%@/tapestry/%@?ta_partner_id=%@&%@",
                                                 protocol, dns, port, apiVersion,
                                                 req.partnerId,
                                                 [self stringWithDeviceParams]]
                               stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding ];
        
        NSString* userId = [TapestryRequestBuilder getUserId];
        if (userId != nil) {
            urlString = [NSString stringWithFormat:@"%@%@%@:%@", urlString, @"&ta_partner_user_id=", req.partnerId,
                         [userId stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        }

        if (req.analytics) {
            urlString = [NSString stringWithFormat:@"%@%@%@", urlString, @"&ta_analytics=", [TapadPreferences dictionaryAsEncodedCsvString:req.analytics]];
        }
        if (req.shouldGetData) {
            urlString = [NSString stringWithFormat:@"%@%@", urlString, @"&ta_get"];
        }
        if (req.shouldGetDevices) {
            urlString = [NSString stringWithFormat:@"%@%@", urlString, @"&ta_list_devices"];
        }
        if ([req.dataToSet count] > 0) {
            urlString = [NSString stringWithFormat:@"%@%@%@", urlString, @"&ta_set_data=", [TapadPreferences dictionaryAsEncodedCsvString:req.dataToSet]];
        }
        if ([req.dataToAdd count] > 0) {
            urlString = [NSString stringWithFormat:@"%@%@%@", urlString, @"&ta_add_data=", [TapadPreferences dictionaryAsEncodedCsvString:req.dataToAdd]];
        }
        if ([req.audiencesToAdd count] > 0) {
            urlString = [NSString stringWithFormat:@"%@%@%@", urlString, @"&ta_add_audiences=", [TapadPreferences arrayAsEncodedCsvString:req.audiencesToAdd]];
        }

        NSLog(@"raw request=[%@]",urlString);
        
        NSURL* url =  [[NSURL alloc] initWithString:urlString];
        
        self.request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:kTimeout]; // autoreleased=>retained
    }
    return self;  
}

static const float kTimeout = 2.5;

- (void) dealloc {
    // will release as necessary
    self.protocol=nil;
    self.dns=nil;
    self.port=nil;
    self.lastError=nil;
    self.lastResponse=nil;
    self.request=nil;
    self.apiVersion=nil;
}

// using the current request params, make a blocking call to the tapad server,
// and turn the raw data into a string (we expect it to be a chunk of html)
// the returned string will be marked for autorelease
- (NSString*) getSynchronous {
            
    NSError* synchronousError=nil;
    NSHTTPURLResponse* synchronousResponse=nil;
    
    NSData* madData = [NSURLConnection sendSynchronousRequest:self.request 
                                            returningResponse:&synchronousResponse 
                                                        error:&synchronousError];
    
    self.lastResponse=synchronousResponse;
    self.lastError=synchronousError;
    
    NSString *tapadResponseString = @"";

    if ([self checkForError]) {
        tapadResponseString = [self.lastError localizedDescription];
    } else if ([self checkIfResponseSuccessful]) {
        
        tapadResponseString = [[NSString alloc] initWithBytes:[madData bytes]
                                                       length:[madData length] 
                                                     encoding:NSUTF8StringEncoding];
        
    }  // else there was an error! no response string!
    
        
    return tapadResponseString;
}



+ (NSString*) visibleResponseStatusCode:(NSURLResponse *)response {
    int statusCode = [(NSHTTPURLResponse*) response statusCode];
    return  [NSString stringWithFormat:@"Server response code=[code:%d \"%@\"]",statusCode, [NSHTTPURLResponse localizedStringForStatusCode:statusCode] ];
}

- (NSString*) responseStatusCodeDescription {
    return [TapestryClient visibleResponseStatusCode:self.lastResponse];
}

- (BOOL) checkIfResponseSuccessful {
    if (self.lastResponse==nil) {
        NSLog(@"[WARNING] response was nil!");
        self.responseSuccess=NO;
    } else if ([self.lastResponse isKindOfClass: [NSHTTPURLResponse class]]) {
        
        int statusCode = [self.lastResponse statusCode];
        NSLog(@"%@:status code=%d",[self class],statusCode); 
 
        switch (statusCode) {
            case 200:
                self.responseSuccess=YES;
                break;
               
            default:
                NSLog(@"%@",[self responseStatusCodeDescription]);
                self.responseSuccess=NO;
                break;
        }
    }
    
    return self.responseSuccess;
}

- (BOOL) checkForError {
    if (self.lastError) {
        NSLog(@"[ERROR] %@",[self.lastError localizedDescription]);
        self.hasError=YES;
    } else {
        self.hasError=NO;
    }
    return self.hasError;
}



#pragma mark param utilities

-(NSString*) stringWithDeviceParams { // autoreleased 

    NSMutableArray* params = [NSMutableArray arrayWithCapacity:5]; // autoreleased

    [params addObject:[NSString stringWithFormat:@"%@=%@", ktypedUid, [TapadIdentifiers deviceID] ]];
    [params addObject:[NSString stringWithFormat:@"%@=%@", kplatform, [[UIDevice currentDevice] platformString] ]];

    /* Add as needed
    NSBundle *bundle = [NSBundle mainBundle];
    NSDictionary *info = [bundle infoDictionary];

    [params addObject:[NSString stringWithFormat:@"bundleID=%@"             ,[info objectForKey:@"CFBundleIdentifier"] ]];
    [params addObject:[NSString stringWithFormat:@"bundleName=%@"           ,[info objectForKey:@"CFBundleName"] ]];
    [params addObject:[NSString stringWithFormat:@"bundleDisplayName=%@"    ,[info objectForKey:@"CFBundleDisplayName"] ]];
    [params addObject:[NSString stringWithFormat:@"bundleExec=%@"           ,[info objectForKey:@"CFBundleExecutable"] ]];
    [params addObject:[NSString stringWithFormat:@"bundleSignature=%@"      ,[info objectForKey:@"CFBundleSignature"] ]];
    [params addObject:[NSString stringWithFormat:@"bundleVersion=%@"        ,[info objectForKey:@"CFBundleVersion"] ]];
    [params addObject:[NSString stringWithFormat:@"bundlePackage=%@"        ,[info objectForKey:@"CFBundlePackageType"] ]];
     */

    return [params componentsJoinedByString:@"&"];
}

@end
