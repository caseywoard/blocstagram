//
//  BLCMediaFullScreenAnimator.h
//  Blocstagram
//
//  Created by Casey Ward on 4/12/15.
//  Copyright (c) 2015 Casey Ward. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BLCMediaFullScreenViewController.h"

@interface BLCMediaFullScreenAnimator : NSObject <UIViewControllerAnimatedTransitioning>

@property (nonatomic, assign) BOOL presenting;
@property (nonatomic, weak) UIImageView *cellImageView;

@end
