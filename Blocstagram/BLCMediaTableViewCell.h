//
//  BLCMediaTableViewCell.h
//  Blocstagram
//
//  Created by Casey Ward on 3/17/15.
//  Copyright (c) 2015 Casey Ward. All rights reserved.
//

#import <UIKit/UIKit.h>



@class BLCMedia, BLCMediaTableViewCell;

@protocol BLCMediaTableViewCellDelegate <NSObject>

- (void) cell:(BLCMediaTableViewCell *)cell didTapImageView:(UIImageView *)imageView;
- (void) cell:(BLCMediaTableViewCell *)cell didLongPressImageView:(UIImageView *)imageView;

@end

@interface BLCMediaTableViewCell : UITableViewCell

@property (nonatomic, strong) BLCMedia *mediaItem;
@property (nonatomic, weak) id <BLCMediaTableViewCellDelegate> delegate;

@property (nonatomic, strong) UILongPressGestureRecognizer *longPressGestureRecognizer;


+ (CGFloat) heightForMediaItem:(BLCMedia *)mediaItem width:(CGFloat)width;


@end
