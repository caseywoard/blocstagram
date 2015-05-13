//
//  BLCMediaTableViewCellTests.m
//  Blocstagram
//
//  Created by Casey Ward on 5/9/15.
//  Copyright (c) 2015 Casey Ward. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "BLCMediaTableViewCell.h"

@interface BLCMediaTableViewCellTests : XCTestCase

@end

@implementation BLCMediaTableViewCellTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testThatheightForMediaItemsReturnsAccurateDimensions:(BLCMedia *)mediaItem width:(CGFloat)width {
}
  /*
    
    BLCMediaTableViewCell *testLayoutCell = [[BLCMediaTableViewCell alloc] init];
     testLayoutCell.mediaItem = mediaItem;
    [testLayoutCell.imageView setUIImageView:@"1.jpg" ];
    
    
    [BLCMediaTableViewCell heightForMediaItem:item width:CGRectGetWidth(self.view.frame)]
    
     XCTAssertEqualObjects(testComment.idNumber, sourceDictionary[@"id"], @"The ID number should be equal")
     XCTAssertEqualObjects(testComment.text, sourceDictionary[@"text"], @"The text should be equal");
 }

(CGFloat) heightForMediaItem:(BLCMedia *)mediaItem width:(CGFloat)width {
    // Make a cell
    BLCMediaTableViewCell *layoutCell = [[BLCMediaTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"layoutCell"];
    layoutCell.mediaItem = mediaItem;
    layoutCell.frame = CGRectMake(0, 0, width, CGRectGetHeight(layoutCell.frame));
    
    [layoutCell setNeedsLayout];
    [layoutCell layoutIfNeeded];
    
    // Get the actual height required for the cell
    return CGRectGetMaxY(layoutCell.commentView.frame);
}
   

*/
- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}
   


@end
