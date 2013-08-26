//
//  ViewController.m
//  TapestryDemo
//
//  Created by Toby Matejovsky & Sveinung Kval Bakken on 8/22/13.
//  Copyright (c) 2013 TapAd. All rights reserved.
//

#import <MessageUI/MessageUI.h>
#import "TATapestryClient.h"
#import "TATapadIdentifiers.h"
#import "NSString+Tapad.h"
#import "ViewController.h"

@interface ViewController () <MFMailComposeViewControllerDelegate>
@property(nonatomic, weak) IBOutlet UIImageView*        carImage;
@property(nonatomic, strong) NSArray*                   carColors;
@property(nonatomic, copy) NSString*                    currentColor;
@property(nonatomic, strong) UITapGestureRecognizer*    tapRecognizer;
@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onImageTapped:)];
    [self.carImage addGestureRecognizer:self.tapRecognizer];
    [self.carImage setUserInteractionEnabled:YES];
    self.carColors = @[@"black", @"blue", @"gray", @"red", @"white"];
    [self setCarImageToColor:[self nextColor]];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self onRefresh:nil];
}

- (void)setCarImageToColor:(NSString*)color
{
    self.currentColor = color;
    NSString* imageName = [NSString stringWithFormat:@"%@_car.jpg", color];
    [self.carImage setImage:[UIImage imageNamed:imageName]];
    NSLog(@"Changed car image to: %@", imageName);
}

- (NSString*)nextColor
{
    for (NSInteger index = 0; index<[self.carColors count]; index++) {
        if ([self.currentColor isEqualToString:[self.carColors objectAtIndex:index]]) {
            NSInteger nextColorIndex = (index + 1) % [self.carColors count];
            return [self.carColors objectAtIndex:nextColorIndex];
        }
    }
    return [self.carColors objectAtIndex:0];
}

- (void)onImageTapped:(id)sender
{
    [self setCarImageToColor:[self nextColor]];
    TATapestryRequest* request = [TATapestryRequest request];
    [request setData:self.currentColor forKey:@"color"];
    [[TATapestryClient sharedClient] queueRequest:request];
}

- (void)onRefresh:(id)sender
{
    TATapestryRequest* request = [TATapestryRequest request];
    TATapestryResponseHandler handler = ^(TATapestryResponse* response, NSError* error,
                                          NSTimeInterval intervalSinceRequestFirstInvoked){
        if (error) {
            NSLog(@"Call failed with error: %@", [error localizedDescription]);
        } else {
            if ([response wasSuccess]) {
                [self setColor:response];
            } else {
                NSLog(@"Call failed with service failures: \n%@", [response errors]);
            }
        }
    };
    [[TATapestryClient sharedClient] queueRequest:request withResponseBlock:handler];
}

- (void)setColor:(TATapestryResponse*)response
{
    NSString* color = [response firstValueForKey:@"color"];
    if (color != nil) {
        [self setCarImageToColor:color];
    }
}

- (void)onBridge:(id)sender
{
    NSDictionary* typedIds = [TATapadIdentifiers typedDeviceIDs];
    NSError* error = nil;
    NSData* typedIDsData = [NSJSONSerialization dataWithJSONObject:typedIds options:0 error:&error];
    NSString* typedIDsString = [[NSString alloc] initWithData:typedIDsData encoding:NSUTF8StringEncoding];
    
    
    TATapestryClient* client = [TATapestryClient sharedClient];
    NSMutableString* url = [NSMutableString stringWithString:client.baseURL];
    [url appendFormat:@"?ta_partner_id=%@", client.partnerId];
    [url appendFormat:@"&ta_bridge=%@", [typedIDsString ta_URLEncodedString]];
    [url appendFormat:@"&ta_redirect=%@", [@"http://tapestry-demo-test.dev.tapad.com/content_optimization" ta_URLEncodedString]];

    MFMailComposeViewController* mailComposer = [[MFMailComposeViewController alloc] init];

    [mailComposer setSubject:[NSString stringWithFormat:@"TapAd Bridge: %@", [[UIDevice currentDevice] name]]];
    NSString* body = [NSString stringWithFormat:@"Please open this URL in your desktop's browser to bridge %@:\n\n%@", [[UIDevice currentDevice] name], url];
    [mailComposer setMailComposeDelegate:self];
    [mailComposer setMessageBody:body isHTML:NO];
    
    [self presentViewController:mailComposer animated:YES completion:nil];
    
    NSLog(@"URL: %@", url);
}

#pragma mark MFMailComposeViewDelegate

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
