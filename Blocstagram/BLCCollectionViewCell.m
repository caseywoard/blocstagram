//
//  BLCCollectionViewCell.m
//  Blocstagram
//
//  Created by Casey Ward on 5/4/15.
//  Copyright (c) 2015 Casey Ward. All rights reserved.
//

#import "BLCCollectionViewCell.h"



@implementation BLCCollectionViewCell

-(id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    
    CGFloat thumbnailEdgeSize = 44;
    
    self.thumbnail = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, thumbnailEdgeSize, thumbnailEdgeSize)];
    self.thumbnail.contentMode = UIViewContentModeScaleAspectFill;
    self.thumbnail.clipsToBounds = YES;
    
    [self.contentView addSubview:self.thumbnail];
    
    
    
    self.nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, thumbnailEdgeSize, thumbnailEdgeSize, 20)];
    self.nameLabel.textAlignment = NSTextAlignmentCenter;
    self.nameLabel.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:10];
    [self.contentView addSubview:self.nameLabel];
    
    return self;
}




@end
