//
//  BLCMedia.m
//  Blocstagram
//
//  Created by Casey Ward on 3/15/15.
//  Copyright (c) 2015 Casey Ward. All rights reserved.
//

#import "BLCMedia.h"
#import "BLCUser.h"
#import "BLCComment.h"

@implementation BLCMedia

- (instancetype) initWithDictionary:(NSDictionary *)mediaDictionary {
    self = [super init];
    
    if (self) {
        self.idNumber = mediaDictionary[@"id"];
        self.user = [[BLCUser alloc] initWithDictionary:mediaDictionary[@"user"]];
        NSString *standardResolutionImageURLString = mediaDictionary[@"images"][@"standard_resolution"][@"url"];
        NSURL *standardResolutionImageURL = [NSURL URLWithString:standardResolutionImageURLString];
        
        if (standardResolutionImageURL) {
            self.mediaURL = standardResolutionImageURL;
        }
        
        NSDictionary *captionDictionary = mediaDictionary[@"caption"];
        
        // Caption might be null (if there's no caption)
        if ([captionDictionary isKindOfClass:[NSDictionary class]]) {
            self.caption = captionDictionary[@"text"];
        } else {
            self.caption = @"";
        }
        
        NSMutableArray *commentsArray = [NSMutableArray array];
        
        for (NSDictionary *commentDictionary in mediaDictionary[@"comments"][@"data"]) {
            BLCComment *someComments = [[BLCComment alloc] initWithDictionary:commentDictionary];
            [commentsArray addObject:someComments];
        }
        
        self.comments = commentsArray;
    }
    
    return self;
}

@end
