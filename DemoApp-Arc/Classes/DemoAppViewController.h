//
//  DemoAppViewController.h
//  DemoApp
//
//  Created by Li Qiu on 9/14/11.
//  Copyright 2011 Tapad, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DemoAppViewController : UIViewController

@property (weak, nonatomic) IBOutlet UITextField *addDataKey;
@property (weak, nonatomic) IBOutlet UITextField *addDataValue;
@property (weak, nonatomic) IBOutlet UITextField *setDataKey;
@property (weak, nonatomic) IBOutlet UITextField *setDataValue;
@property (weak, nonatomic) IBOutlet UITextField *audienceInput;

@property (weak, nonatomic) IBOutlet UITextField *userIdInput;
@property (weak, nonatomic) IBOutlet UISwitch *didOpenUdidSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *didMd5RawMacSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *didSha1RawMacSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *didMd5MacSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *didSha1MacSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *didIdfaSwitch;


@property (weak, nonatomic) IBOutlet UISwitch *getDataSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *getDevicesSwitch;

@property (weak, nonatomic) IBOutlet UITextView *apiRequest;
@property (weak, nonatomic) IBOutlet UITextView *apiResponse;

@property (weak, nonatomic) IBOutlet UIButton *sendRequestBtn;

- (IBAction)sendRequest;
- (IBAction)resetForm;
- (IBAction)unregisterUserId;

@end