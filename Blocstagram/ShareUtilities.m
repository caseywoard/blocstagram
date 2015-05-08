//
//  ShareUtilities.m
//  Blocstagram
//
//  Created by Casey Ward on 4/13/15.
//  Copyright (c) 2015 Casey Ward. All rights reserved.
//

#import "ShareUtilities.h"
#import "BLCMedia.h"

@implementation ShareUtilities

+ (UIActivityViewController *) shareContentsWithText:(BLCMedia *)mediaItem viewController:(UIViewController *)vc {
    NSMutableArray *itemsToShare = [NSMutableArray array];
    UIActivityViewController *aVC = [[UIActivityViewController alloc] init];
    
    if (mediaItem.caption.length > 0) {
        [itemsToShare addObject:mediaItem.caption];
    }
    
    if (mediaItem.image) {
        [itemsToShare addObject:mediaItem.image];
    }
    
    if (itemsToShare.count > 0) {
        
        UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:itemsToShare applicationActivities:nil];
       
        
        aVC = activityVC;
        
    }
    return aVC;
}

/*
+ (void) shareContentsWithText:(BLCMedia *)mediaItem viewController:(UIViewController *)vc {
    NSMutableArray *itemsToShare = [NSMutableArray array];
    
    if (mediaItem.caption.length > 0) {
        [itemsToShare addObject:mediaItem.caption];
    }
    
    if (mediaItem.image) {
        [itemsToShare addObject:mediaItem.image];
    }
    
    if (itemsToShare.count > 0) {
     
        UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:itemsToShare applicationActivities:nil];
        [vc presentViewController:activityVC animated:YES completion:nil];
      
        }
}

*/

@end
