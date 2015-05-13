//
//  BLCComposeCommentViewTest.m
//  Blocstagram
//
//  Created by Casey Ward on 5/11/15.
//  Copyright (c) 2015 Casey Ward. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "BLCComposeCommentView.h"

@interface BLCComposeCommentViewTest : XCTestCase

@end

@implementation BLCComposeCommentViewTest

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testSetTextIsWritingComment {
    // This is an example of a functional test case.
    
    BLCComposeCommentView *testCommentViewOne = [[BLCComposeCommentView alloc] init];
    [testCommentViewOne setText:@"test text"];
    
    BLCComposeCommentView *testCommentViewTwo = [[BLCComposeCommentView alloc] init];
    [testCommentViewTwo setText:@""];
    
    XCTAssertTrue(testCommentViewOne, @"this is true. Pass.");
    //XCTAssertFalse(testCommentViewTwo, @"this is false. Pass.");
    
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
