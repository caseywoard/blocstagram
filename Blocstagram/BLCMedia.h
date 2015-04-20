//
//  BLCMedia.h
//  Blocstagram
//
//  Created by Casey Ward on 3/15/15.
//  Copyright (c) 2015 Casey Ward. All rights reserved.
//

#import <Foundation/Foundation.h>

@import UIKit;

typedef NS_ENUM(NSInteger, BLCMediaDownloadState) {
    BLCMediaDownloadStateNeedsImage             = 0,
    BLCMediaDownloadStateDownloadInProgress     = 1,
    BLCMediaDownloadStateNonRecoverableError    = 2,
    BLCMediaDownloadStateHasImage               = 3
};

@class BLCUser;

@interface BLCMedia : NSObject <NSCoding>

@property (nonatomic, strong) NSString *idNumber;
@property (nonatomic, strong) BLCUser *user;
@property (nonatomic, strong) NSURL *mediaURL;
@property (nonatomic, strong) UIImage *image;
@property (nonatomic, strong) NSString *caption;
@property (nonatomic, strong) NSArray *comments;

@property (nonatomic, assign) BLCMediaDownloadState downloadState;

- (instancetype) initWithDictionary:(NSDictionary *)mediaDictionary;

@end
