//
//  TATapestryRequestTests.m
//  Tapestry
//
//  Created by Sveinung Kval Bakken on 30.07.13.
//  Copyright (c) 2013 Tapad. All rights reserved.
//

#import "TATapestryRequest.h"
#import "TATapestryRequestTests.h"

@interface TATapestryRequestTests ()
@property(nonatomic, strong) TATapestryRequest* request;
@end

@implementation TATapestryRequestTests

- (void)setUp
{
    self.request = [TATapestryRequest request];
}

- (void)testEmpty
{
    STAssertTrue(0 == [[self.request test_parameters] count], @"Expected empty parameters dictionary.");
}

@end
