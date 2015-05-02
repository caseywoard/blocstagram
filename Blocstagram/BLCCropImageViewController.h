//
//  BLCCropImageViewController.h
//  Blocstagram
//
//  Created by Casey Ward on 4/29/15.
//  Copyright (c) 2015 Casey Ward. All rights reserved.
//

#import "BLCMediaFullScreenViewController.h"

@class BLCCropImageViewController;

@protocol BLCCropImageViewControllerDelegate <NSObject>

- (void) cropControllerFinishedWithImage:(UIImage *)croppedImage;

@end

@interface BLCCropImageViewController : BLCMediaFullScreenViewController

- (instancetype) initWithImage:(UIImage *)sourceImage;

@property (nonatomic, weak) NSObject <BLCCropImageViewControllerDelegate> *delegate;


@end
