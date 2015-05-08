//
//  ShareUtilities.h
//  Blocstagram
//
//  Created by Casey Ward on 4/13/15.
//  Copyright (c) 2015 Casey Ward. All rights reserved.
//
@import UIKit;
#import <Foundation/Foundation.h>

@class BLCMedia;

@interface ShareUtilities : NSObject

+ (UIActivityViewController *) shareContentsWithText:(BLCMedia *)mediaItem viewController:(UIViewController *)vc;

//+ (void) shareContentsWithText:(BLCMedia *)mediaItem viewController:(UIViewController *)vc;

@end
