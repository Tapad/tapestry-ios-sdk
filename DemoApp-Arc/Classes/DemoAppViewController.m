//
//  DemoAppViewController.m
//  DemoApp
//
//  Created by Li Qiu on 9/14/11.
//  Copyright 2011 Tapad, Inc. All rights reserved.
//

#import "DemoAppViewController.h"
#import "Tapestry/TATapestry.h"
#import <QuartzCore/QuartzCore.h>

@implementation DemoAppViewController

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
	// Do any additional setup after loading the view, typically from a nib.
    
    [[[self apiRequest] layer] setBorderWidth:1.0f];
    [[[self apiRequest] layer] setBorderColor:[[UIColor grayColor] CGColor]];
    [[self apiRequest] setEditable:NO];
    
    [[[self apiResponse] layer] setBorderWidth:1.0f];
    [[[self apiResponse] layer] setBorderColor:[[UIColor grayColor] CGColor]];
    [[self apiResponse] setEditable:NO];
    
    [self.sendRequestBtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    
    [self resetForm];
}

- (void)hideKeyboard {
    NSArray *inputs = [NSArray arrayWithObjects:self.addDataKey, self.addDataValue,
                       self.setDataKey, self.setDataValue, self.audienceInput, self.userIdInput, nil];
    for (id input in inputs) {
        if ([input isFirstResponder]) {
            [input resignFirstResponder];
        }
    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *) event
{
    [self hideKeyboard];
}

- (void)viewDidUnload
{
    [self setAddDataKey:nil];
    [self setAddDataValue:nil];
    [self setGetDataSwitch:nil];
    [self setGetDevicesSwitch:nil];
    [self setApiRequest:nil];
    [self setApiResponse:nil];
    [self setSetDataKey:nil];
    [self setSetDataValue:nil];
    [self setAudienceInput:nil];
    [self setUserIdInput:nil];
    [self setDidOpenUdidSwitch:nil];
    [self setDidMd5RawMacSwitch:nil];
    [self setDidSha1RawMacSwitch:nil];
    [self setDidMd5MacSwitch:nil];
    [self setDidSha1MacSwitch:nil];
    [self setDidIdfaSwitch:nil];
    [self setSendRequestBtn:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }
}

- (IBAction)sendRequest {
    [self hideKeyboard];
    
    
}

- (IBAction)resetForm {
    [self hideKeyboard];
    [self.addDataKey setText:@""];
    [self.addDataValue setText:@""];
    [self.setDataKey setText:@""];
    [self.audienceInput setText:@""];
    [self.setDataValue setText:@""];
    [self.getDataSwitch setOn:YES];
    [self.getDevicesSwitch setOn:NO];
    [self.apiRequest setText:@""];
    [self.apiResponse setText:@""];
    
    [self.didOpenUdidSwitch setOn:YES];
    [self.didMd5RawMacSwitch setOn:YES];
    [self.didSha1RawMacSwitch setOn:YES];
    [self.didMd5MacSwitch setOn:YES];
    [self.didSha1MacSwitch setOn:YES];
    [self.didIdfaSwitch setOn:YES];
}

- (IBAction)unregisterUserId {
    [self.userIdInput setText:@""];
}

- (void)threadsafeUpdateApiResponseView:(NSString*)jsonString {
    [self performSelectorOnMainThread:@selector(updateApiResponseView:) withObject:jsonString waitUntilDone:NO];
}

- (void)updateApiResponseView:(id)jsonString {
    self.apiResponse.text = jsonString;
    [self.apiResponse sizeToFit];
}

@end
