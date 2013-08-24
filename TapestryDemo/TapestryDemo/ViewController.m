//
//  ViewController.m
//  TapestryDemo
//
//  Created by Toby Matejovsky on 8/22/13.
//  Copyright (c) 2013 TapAd. All rights reserved.
//

#import "TATapestryClientNG.h"
#import "ViewController.h"

@interface ViewController ()
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
    [[TATapestryClientNG sharedClient] queueRequest:request];
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
                [self handleData:[response getData]];
            } else {
                NSLog(@"Call failed with service failures: \n%@", [response getErrors]);
            }
        }
    };
    [[TATapestryClientNG sharedClient] queueRequest:request withResponseBlock:handler];
}

- (void)handleData:(NSDictionary*)data
{
    NSArray* colorValues = [data valueForKey:@"color"];
    if (colorValues != nil && [colorValues isKindOfClass:[NSArray class]] && [colorValues count] > 0) {
        [self setCarImageToColor:[colorValues objectAtIndex:0]];
    }
}

- (void)onBridge:(id)sender
{
//    NSDictionary* typedIds = [TATapadIdentifiers typedDeviceIDs];
//    for (id key in typedIds) {
//        [request addTypedId:[typedIds objectForKey:key] forSource:key];
//    }
}

@end
