//
//  BLCMediaTests.m
//  Blocstagram
//
//  Created by Casey Ward on 5/10/15.
//  Copyright (c) 2015 Casey Ward. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "BLCMedia.h"
#import "BLCUser.h"

@interface BLCMediaTests : XCTestCase

@end

@implementation BLCMediaTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testThatBCMEdiaInitializationWorks
{
    NSDictionary *sourceDictionary = @{@"id": @"8675309",
                                       @"user_has_liked" : @"0",
                                       //@"link" : @"http://www.instagram.com/p/example",
                                       //@"attribution" : @"0x1234cc8",
                                       //@"tags" : @"0 objects",
                                       //@"type" : @"image",
                                       //@"location" : @"0x14266c8",
                                       @"caption" : @{@"text": @"sample" },
                                       @"images" : @{@"standard_resolution":@{@"url":@"http://www.example.com/example.jpg"}} ,
                                       //@"filter" : @"Normal",
                                       //@"comments" : @"image",
                                       @"user" : @{@"id": @"8675309",
                                                   @"username" : @"d'oh",
                                                   @"full_name" : @"Homer Simpson",
                                                   @"profile_picture" : @"http://www.example.com/example.jpg"},
                                       
                                       //@"likes" : @"0",
                                      
                                       };


    
    BLCMedia *testMedia = [[BLCMedia alloc] initWithDictionary:sourceDictionary];
    
    XCTAssertEqualObjects(testMedia.idNumber, sourceDictionary[@"id"], @"The ID number should be equal");
    XCTAssertEqualObjects(testMedia.user.idNumber, sourceDictionary[@"user"][@"id"], @"The username should be equal");
    XCTAssertEqualObjects(testMedia.mediaURL,[NSURL URLWithString: sourceDictionary[@"images"][@"standard_resolution"][@"url"]], @"The full name should be equal");
    XCTAssertEqualObjects(testMedia.caption,sourceDictionary[@"caption"][@"text"], @"The profile picture should be equal");
}


- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
