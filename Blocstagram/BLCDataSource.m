//
//  BLCDataSource.m
//  Blocstagram
//
//  Created by Casey Ward on 3/15/15.
//  Copyright (c) 2015 Casey Ward. All rights reserved.
//
@import UIKit;
#import "BLCDataSource.h"
#import "BLCUser.h"
#import "BLCMedia.h"
#import "BLCComment.h"
#import "BLCLoginViewController.h"
#import <UICKeyChainStore.h>
#import <AFNetworking/AFNetworking.h>

@interface BLCDataSource ()  {
    NSMutableArray *_mediaItems;
}


@property (nonatomic, strong) NSString *accessToken;

@property (nonatomic, assign) BOOL isRefreshing;
@property (nonatomic, assign) BOOL isLoadingOlderItems;

@property (nonatomic, assign) BOOL thereAreNoMoreOlderMessages;

@property (nonatomic, strong) AFHTTPRequestOperationManager *instagramOperationManager;

@end


@implementation BLCDataSource

NSString *const BLCImageFinishedNotification = @"BLCImageFinishedNotification";

+ (NSString *) instagramClientID {
    return @"9492c761536f4120983efeafaeb707b0";
}

+ (instancetype) sharedInstance {
    static dispatch_once_t once;
    static id sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [[BLCDataSource alloc] init];
    });
    return sharedInstance;
}

//

- (instancetype) init {
    self = [super init];
    
    if (self) {
        
        NSURL *baseURL = [NSURL URLWithString:@"https://api.instagram.com/v1/"];
        self.instagramOperationManager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:baseURL];
        
        AFJSONResponseSerializer *jsonSerializer = [AFJSONResponseSerializer serializer];
        
        AFImageResponseSerializer *imageSerializer = [AFImageResponseSerializer serializer];
        imageSerializer.imageScale = 1.0;
        
        AFCompoundResponseSerializer *serializer = [AFCompoundResponseSerializer compoundSerializerWithResponseSerializers:@[jsonSerializer, imageSerializer]];
        self.instagramOperationManager.responseSerializer = serializer;
        
        self.accessToken = [UICKeyChainStore stringForKey:@"access token"];
        
        if (!self.accessToken) {
        //[self addRandomData];
            [self registerForAccessTokenNotification];
        } else {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                NSString *fullPath = [self pathForFilename:NSStringFromSelector(@selector(mediaItems))];
                NSArray *storedMediaItems = [NSKeyedUnarchiver unarchiveObjectWithFile:fullPath];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (storedMediaItems.count > 0) {
                        NSMutableArray *mutableMediaItems = [storedMediaItems mutableCopy];
                        
                        [self willChangeValueForKey:@"mediaItems"];
                        self.mediaItems = mutableMediaItems;
                        [self didChangeValueForKey:@"mediaItems"];
                    } else {
                        [self populateDataWithParameters:nil completionHandler:nil];
                    }
                });
            });
        }
    }
    
    return self;
}

- (void) registerForAccessTokenNotification {
    [[NSNotificationCenter defaultCenter] addObserverForName:BLCLoginViewControllerDidGetAccessTokenNotification object:nil queue:nil usingBlock:^(NSNotification *note) {
        self.accessToken = note.object;
        
        [UICKeyChainStore setString:self.accessToken forKey:@"access token"];
        // Got a token, populate the initial data
        [self populateDataWithParameters:nil completionHandler:nil];
        
        
    }];
}


- (void)documentInteractionController:(UIDocumentInteractionController *)controller didEndSendingToApplication:(NSString *)application {
    [[NSNotificationCenter defaultCenter] postNotificationName:BLCImageFinishedNotification object:self];
}

 - (void) deleteMediaItem:(BLCMedia *)item {
     NSMutableArray *mutableArrayWithKVO = [self mutableArrayValueForKey:@"mediaItems"];
     [mutableArrayWithKVO removeObject:item];
 }

- (NSString *) pathForFilename:(NSString *) filename {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths firstObject];
    NSString *dataPath = [documentsDirectory stringByAppendingPathComponent:filename];
    
    return dataPath;
}

#pragma mark - Key/Value Observing

- (NSUInteger) countOfMediaItems {
    return self.mediaItems.count;
}

- (id) objectInMediaItemsAtIndex:(NSUInteger)index {
    return [self.mediaItems objectAtIndex:index];
}

- (NSArray *) mediaItemsAtIndexes:(NSIndexSet *)indexes {
    return [self.mediaItems objectsAtIndexes:indexes];
}

- (void) insertObject:(BLCMedia *)object inMediaItemsAtIndex:(NSUInteger)index {
     [_mediaItems insertObject:object atIndex:index];
 }

- (void) removeObjectFromMediaItemsAtIndex:(NSUInteger)index {
    [_mediaItems removeObjectAtIndex:index];
}

- (void) replaceObjectInMediaItemsAtIndex:(NSUInteger)index withObject:(id)object {
    [_mediaItems replaceObjectAtIndex:index withObject:object];
}

#pragma mark - completion handler

 - (void) requestNewItemsWithCompletionHandler:(BLCNewItemCompletionBlock)completionHandler {
     self.thereAreNoMoreOlderMessages = NO;
     if (self.isRefreshing == NO) {
         self.isRefreshing = YES;
         
         
         NSString *minID = [[self.mediaItems firstObject] idNumber];
         
             
         NSDictionary *parameters = minID ? @{@"min_id": minID} : nil;
         
         [self populateDataWithParameters:parameters completionHandler:^(NSError *error) {
             self.isRefreshing = NO;
            
             if (completionHandler) {
                 completionHandler(error);
             }
         }];
       
             
         
         }


}


 - (void) requestOldItemsWithCompletionHandler:(BLCNewItemCompletionBlock)completionHandler {
     if (self.isLoadingOlderItems == NO && self.thereAreNoMoreOlderMessages == NO) {
         self.isLoadingOlderItems = YES;
       
         NSString *maxID = [[self.mediaItems lastObject] idNumber];
         
         NSDictionary *parameters = maxID ? @{@"max_id": maxID} : nil;
         
         [self populateDataWithParameters:parameters completionHandler:^(NSError *error) {
             self.isLoadingOlderItems = NO;
             
             if (completionHandler) {
                 completionHandler(error);
             }
         }];
            
    }
}


- (void) populateDataWithParameters:(NSDictionary *)parameters completionHandler:(BLCNewItemCompletionBlock)completionHandler {
    if (self.accessToken) {
        // only try to get the data if there's an access token
        NSMutableDictionary *mutableParameters = [@{@"access_token": self.accessToken} mutableCopy];
        
        [mutableParameters addEntriesFromDictionary:parameters];
        
        [self.instagramOperationManager GET:@"users/self/feed"
                                 parameters:mutableParameters
                                    success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                        if ([responseObject isKindOfClass:[NSDictionary class]]) {
                                            [self parseDataFromFeedDictionary:responseObject fromRequestWithParameters:parameters];
                                            
                                            if (completionHandler) {
                                                completionHandler(nil);
                                            }
                                        }
                                    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                        if (completionHandler) {
                                            completionHandler(error);
                                        }
                                    }];
  
    }
}

- (void) parseDataFromFeedDictionary:(NSDictionary *)feedDictionary fromRequestWithParameters:(NSDictionary *)parameters {
    NSArray *mediaArray = feedDictionary[@"data"];
    
    NSMutableArray *tmpMediaItems = [NSMutableArray array];
    
    for (NSDictionary *mediaDictionary in mediaArray) {
        BLCMedia *mediaItem = [[BLCMedia alloc] initWithDictionary:mediaDictionary];
        
        if (mediaItem) {
            [tmpMediaItems addObject:mediaItem];
//              [self downloadImageForMediaItem:mediaItem];
            }
        }
    
    NSMutableArray *mutableArrayWithKVO = [self mutableArrayValueForKey:@"mediaItems"];
    
    if (parameters[@"min_id"]) {
        // This was a pull-to-refresh request
        
        NSRange rangeOfIndexes = NSMakeRange(0, tmpMediaItems.count);
        NSIndexSet *indexSetOfNewObjects = [NSIndexSet indexSetWithIndexesInRange:rangeOfIndexes];
        
        [mutableArrayWithKVO insertObjects:tmpMediaItems atIndexes:indexSetOfNewObjects];
        
        } else if (parameters[@"max_id"]) {
        // This was an infinite scroll request
        
            if (tmpMediaItems.count == 0) {
            // disable infinite scroll, since there are no more older messages
                self.thereAreNoMoreOlderMessages = YES;
        }
        
        [mutableArrayWithKVO addObjectsFromArray:tmpMediaItems];
        
    } else {
        [self willChangeValueForKey:@"mediaItems"];
        self.mediaItems = tmpMediaItems;
        [self didChangeValueForKey:@"mediaItems"];
    }
    
    if (tmpMediaItems.count > 0) {
        // Write the changes to disk
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSUInteger numberOfItemsToSave = MIN(self.mediaItems.count, 50);
            NSArray *mediaItemsToSave = [self.mediaItems subarrayWithRange:NSMakeRange(0, numberOfItemsToSave)];
            
            NSString *fullPath = [self pathForFilename:NSStringFromSelector(@selector(mediaItems))];
            NSData *mediaItemData = [NSKeyedArchiver archivedDataWithRootObject:mediaItemsToSave];
            
            NSError *dataError;
            BOOL wroteSuccessfully = [mediaItemData writeToFile:fullPath options:NSDataWritingAtomic | NSDataWritingFileProtectionCompleteUnlessOpen error:&dataError];
            
            if (!wroteSuccessfully) {
                NSLog(@"Couldn't write file: %@", dataError);
            }
        });
        
    }
}

- (void) downloadImageForMediaItem:(BLCMedia *)mediaItem {
    if (mediaItem.mediaURL && !mediaItem.image) {
        
        mediaItem.downloadState = BLCMediaDownloadStateDownloadInProgress;
        
        [self.instagramOperationManager GET:mediaItem.mediaURL.absoluteString
                                 parameters:nil
                                    success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                        if ([responseObject isKindOfClass:[UIImage class]]) {
                                            mediaItem.image = responseObject;
                                            
                                            mediaItem.downloadState = BLCMediaDownloadStateHasImage;
                                            
                                            NSMutableArray *mutableArrayWithKVO = [self mutableArrayValueForKey:@"mediaItems"];
                                            NSUInteger index = [mutableArrayWithKVO indexOfObject:mediaItem];
                                            [mutableArrayWithKVO replaceObjectAtIndex:index withObject:mediaItem];
                                            
                                        } else {
                                            mediaItem.downloadState = BLCMediaDownloadStateNonRecoverableError;
                                            
                                        }
                                    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                        NSLog(@"Error downloading image: %@", error);
                                        
                                        mediaItem.downloadState = BLCMediaDownloadStateNonRecoverableError;
                                        
                                        if ([error.domain isEqualToString:NSURLErrorDomain]) {
                                            // A networking problem
                                            if (error.code == NSURLErrorTimedOut ||
                                                error.code == NSURLErrorCancelled ||
                                                error.code == NSURLErrorCannotConnectToHost ||
                                                error.code == NSURLErrorNetworkConnectionLost ||
                                                error.code == NSURLErrorNotConnectedToInternet ||
                                                error.code == kCFURLErrorInternationalRoamingOff ||
                                                error.code == kCFURLErrorCallIsActive ||
                                                error.code == kCFURLErrorDataNotAllowed ||
                                                error.code == kCFURLErrorRequestBodyStreamExhausted) {
                                                
                                                // It might work if we try again
                                                mediaItem.downloadState = BLCMediaDownloadStateNeedsImage;
                                            }
                                        }
                                        
                                    }];
            }
}

 #pragma mark - Liking Media Items 

- (void) toggleLikeOnMediaItem:(BLCMedia *)mediaItem {
    NSString *urlString = [NSString stringWithFormat:@"media/%@/likes", mediaItem.idNumber];
    NSDictionary *parameters = @{@"access_token": self.accessToken};
    if (mediaItem.likeState == BLCLikeStateNotLiked) {
        mediaItem.likeState = BLCLikeStateLiking;
        [self.instagramOperationManager POST:urlString parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) { mediaItem.likeState = BLCLikeStateLiked;
            
            mediaItem.likeCount++;
            [self reloadMediaItem:mediaItem];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            mediaItem.likeState = BLCLikeStateNotLiked;
            [self reloadMediaItem:mediaItem];
        }];
        
    } else if (mediaItem.likeState == BLCLikeStateLiked) {
        mediaItem.likeState = BLCLikeStateUnliking;
        [self.instagramOperationManager DELETE:urlString parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
            mediaItem.likeState = BLCLikeStateNotLiked;
            
            mediaItem.likeCount--;
            [self reloadMediaItem:mediaItem];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            mediaItem.likeState = BLCLikeStateLiked;
            [self reloadMediaItem:mediaItem];
        }];
    } [self reloadMediaItem:mediaItem];
    
}

- (void) reloadMediaItem:(BLCMedia *)mediaItem {
    NSMutableArray *mutableArrayWithKVO = [self mutableArrayValueForKey:@"mediaItems"];
    NSUInteger index = [mutableArrayWithKVO indexOfObject:mediaItem];
    [mutableArrayWithKVO replaceObjectAtIndex:index withObject:mediaItem];

}

#pragma mark - Comments

- (void) commentOnMediaItem:(BLCMedia *)mediaItem withCommentText:(NSString *)commentText {
    if (!commentText || commentText.length == 0) {
        return;
    }
    
    NSString *urlString = [NSString stringWithFormat:@"media/%@/comments", mediaItem.idNumber];
    NSDictionary *parameters = @{@"access_token": self.accessToken, @"text": commentText};
    
    [self.instagramOperationManager POST:urlString parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        mediaItem.temporaryComment = nil;
        
        NSString *refreshMediaUrlString = [NSString stringWithFormat:@"media/%@", mediaItem.idNumber];
        NSDictionary *parameters = @{@"access_token": self.accessToken};
        [self.instagramOperationManager GET:refreshMediaUrlString parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
            BLCMedia *newMediaItem = [[BLCMedia alloc] initWithDictionary:responseObject];
            NSMutableArray *mutableArrayWithKVO = [self mutableArrayValueForKey:@"mediaItems"];
            NSUInteger index = [mutableArrayWithKVO indexOfObject:mediaItem];
            [mutableArrayWithKVO replaceObjectAtIndex:index withObject:newMediaItem];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            [self reloadMediaItem:mediaItem];
        }];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        NSLog(@"Response: %@", operation.responseString);
        [self reloadMediaItem:mediaItem];
    }];
}

@end
