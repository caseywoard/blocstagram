//
//  BLCImageLibraryViewController.h
//  Blocstagram
//
//  Created by Casey Ward on 4/30/15.
//  Copyright (c) 2015 Casey Ward. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BLCImageLibraryViewController;

@protocol BLCImageLibraryViewControllerDelegate <NSObject>

- (void) imageLibraryViewController:(BLCImageLibraryViewController *)imageLibraryViewController didCompleteWithImage:(UIImage *)image;


@end




@interface BLCImageLibraryViewController : UICollectionViewController

@property (nonatomic, weak) NSObject <BLCImageLibraryViewControllerDelegate> *delegate;

@end