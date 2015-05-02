//
//  BLCMediaFullScreenViewController.h
//  Blocstagram
//
//  Created by Casey Ward on 4/12/15.
//  Copyright (c) 2015 Casey Ward. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BLCMedia;

@interface BLCMediaFullScreenViewController : UIViewController


@property (nonatomic, strong) BLCMedia *media;

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIImageView *imageView;

- (instancetype) initWithMedia:(BLCMedia *)media;
- (void) centerScrollView;
- (void) recalculateZoomScale;

@end
