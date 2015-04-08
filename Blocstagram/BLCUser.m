//
//  BLCUser.m
//  Blocstagram
//
//  Created by Casey Ward on 3/15/15.
//  Copyright (c) 2015 Casey Ward. All rights reserved.
//

#import "BLCUser.h"

@implementation BLCUser

- (instancetype) initWithDictionary:(NSDictionary *)userDictionary {
     
     self = [super init];
     
     if (self) {
         self.idNumber = userDictionary[@"id"];
         self.userName = userDictionary[@"username"];
         self.fullName = userDictionary[@"full_name"];
         NSString *profileURLString = userDictionary[@"profile_picture"];
         NSURL *profileURL = [NSURL URLWithString:profileURLString];
         
         if (profileURL) {
             self.profilePictureURL = profileURL;
         }
     }
     return self;
 }

@end
