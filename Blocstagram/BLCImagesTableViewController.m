//
//  BLCImagesTableViewController.m
//  Blocstagram
//
//  Created by Casey Ward on 3/14/15.
//  Copyright (c) 2015 Casey Ward. All rights reserved.
//

#import "BLCImagesTableViewController.h"

#import "BLCComment.h" //?
#import "BLCMediaTableViewCell.h" //?
#import "BLCMediaFullScreenViewController.h"
#import "BLCMediaFullScreenAnimator.h"
#import "ShareUtilities.h"
#import "BLCCameraViewController.h"
#import "BLCImageLibraryViewController.h"
#import "BLCPostToInstagramViewController.h"
#import "ShareUtilities.h"

@interface BLCImagesTableViewController () <BLCMediaTableViewCellDelegate, UIViewControllerTransitioningDelegate, UIScrollViewDelegate, BLCCameraViewControllerDelegate, BLCImageLibraryViewControllerDelegate>

@property (nonatomic, weak) UIImageView *lastTappedImageView;
@property (nonatomic, weak) UIView *lastSelectedCommentView;
@property (nonatomic, assign) CGFloat lastKeyboardAdjustment;
@property (nonatomic, strong) UIPopoverController *cameraPopover;


@property(nonatomic, readonly, getter=isDecelerating) BOOL decelerating; //for assignment

@end

@implementation BLCImagesTableViewController

//added method
-(id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        //Custom initialization
       
    }
    return self;
}

- (void) dealloc {
    [[BLCDataSource sharedInstance] removeObserver:self forKeyPath:@"mediaItems"];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[BLCDataSource sharedInstance] addObserver:self forKeyPath:@"mediaItems" options:0 context:nil];
    
    //refresh gesture
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(refreshControlDidFire:) forControlEvents:UIControlEventValueChanged];
    
    [self.tableView registerClass:[BLCMediaTableViewCell class] forCellReuseIdentifier:@"mediaCell"];
    
    self.tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeInteractive;
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera] ||
        [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeSavedPhotosAlbum]) {
        UIBarButtonItem *cameraButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCamera target:self action:@selector(cameraPressed:)];
        self.navigationItem.rightBarButtonItem = cameraButton;
    }
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(imageDidFinish:)
                                                 name:BLCImageFinishedNotification
                                               object:nil];
}


- (void)viewWillAppear:(BOOL)animated {

    NSIndexPath *indexPath = self.tableView.indexPathForSelectedRow;
    if (indexPath) {
        [self.tableView deselectRowAtIndexPath:indexPath animated:animated];
    }
}

- (void) viewWillDisappear:(BOOL)animated {
    
}



- (void) refreshControlDidFire:(UIRefreshControl *) sender {
    [[BLCDataSource sharedInstance] requestNewItemsWithCompletionHandler:^(NSError *error) {
        [sender endRefreshing];
    }];
}

- (void) infiniteScrollIfNecessary {
     NSIndexPath *bottomIndexPath = [[self.tableView indexPathsForVisibleRows] lastObject];
     if (bottomIndexPath && bottomIndexPath.row == [BLCDataSource sharedInstance].mediaItems.count - 1) {// The very last cell is on screen
         [[BLCDataSource sharedInstance] requestOldItemsWithCompletionHandler:nil];
     }
}

#pragma mark - UIScrollViewDelegate 



-(void) scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
        [self infiniteScrollIfNecessary];
        NSLog(@"infiniteScrollNecessary was called");
    
}



-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    for (NSIndexPath* indexPath in [self.tableView indexPathsForVisibleRows]) {
        BLCMedia *mediaItem = [BLCDataSource sharedInstance].mediaItems[indexPath.row];
        if (mediaItem.downloadState == BLCMediaDownloadStateNeedsImage) {
            [[BLCDataSource sharedInstance] downloadImageForMediaItem:mediaItem];
        }
    }
    
}

/*
- (void) tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    BLCMedia *mediaItem = [BLCDataSource sharedInstance].mediaItems[indexPath.row];
    if (mediaItem.downloadState == BLCMediaDownloadStateNeedsImage) {
        [[BLCDataSource sharedInstance] downloadImageForMediaItem:mediaItem];
    }
}

*/

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return [self items].count;
}

- (void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (object == [BLCDataSource sharedInstance] && [keyPath isEqualToString:@"mediaItems"]) {
        // We know mediaItems changed.  Let's see what kind of change it is.
        int kindOfChange = [change[NSKeyValueChangeKindKey] intValue];
        
        if (kindOfChange == NSKeyValueChangeSetting) {
            // Someone set a brand new images array
            [self.tableView reloadData];
        } else if (kindOfChange == NSKeyValueChangeInsertion ||
                   kindOfChange == NSKeyValueChangeRemoval ||
                   kindOfChange == NSKeyValueChangeReplacement) {
            // We have an incremental change: inserted, deleted, or replaced images
            
            // Get a list of the index (or indices) that changed
            NSIndexSet *indexSetOfChanges = change[NSKeyValueChangeIndexesKey];
            
            // Convert this NSIndexSet to an NSArray of NSIndexPaths (which is what the table view animation methods require)
            NSMutableArray *indexPathsThatChanged = [NSMutableArray array];
            [indexSetOfChanges enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
                NSIndexPath *newIndexPath = [NSIndexPath indexPathForRow:idx inSection:0];
                [indexPathsThatChanged addObject:newIndexPath];
            }];
            
            // Call `beginUpdates` to tell the table view we're about to make changes
            [self.tableView beginUpdates];
            
            // Tell the table view what the changes are
            if (kindOfChange == NSKeyValueChangeInsertion) {
                [self.tableView insertRowsAtIndexPaths:indexPathsThatChanged withRowAnimation:UITableViewRowAnimationAutomatic];
            } else if (kindOfChange == NSKeyValueChangeRemoval) {
                [self.tableView deleteRowsAtIndexPaths:indexPathsThatChanged withRowAnimation:UITableViewRowAnimationAutomatic];
            } else if (kindOfChange == NSKeyValueChangeReplacement) {
                [self.tableView reloadRowsAtIndexPaths:indexPathsThatChanged withRowAnimation:UITableViewRowAnimationAutomatic];
            }
            
            // Tell the table view that we're done telling it about changes, and to complete the animation
            [self.tableView endUpdates];
        }
    }
}

- (void) cellDidPressLikeButton:(BLCMediaTableViewCell *)cell {
    [[BLCDataSource sharedInstance] toggleLikeOnMediaItem:cell.mediaItem];
    
}

- (void) cellWillStartComposingComment:(BLCMediaTableViewCell *)cell {
    self.lastSelectedCommentView = (UIView *)cell.commentView;
}

- (void) cell:(BLCMediaTableViewCell *)cell didComposeComment:(NSString *)comment {
    [[BLCDataSource sharedInstance] commentOnMediaItem:cell.mediaItem withCommentText:comment];
}

#pragma mark - UIViewControllerTransitioningDelegate

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented
                                                                  presentingController:(UIViewController *)presenting
                                                                      sourceController:(UIViewController *)source {
    BLCMediaFullScreenAnimator *animator = [BLCMediaFullScreenAnimator new];
    animator.presenting = YES;
    animator.cellImageView = self.lastTappedImageView;
    return animator;
}

#pragma mark - Keyboard Handling

- (void)keyboardWillShow:(NSNotification *)notification
{
    // Get the frame of the keyboard within self.view's coordinate system
    NSValue *frameValue = notification.userInfo[UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardFrameInScreenCoordinates = frameValue.CGRectValue;
    CGRect keyboardFrameInViewCoordinates = [self.navigationController.view convertRect:keyboardFrameInScreenCoordinates fromView:nil];
    
    // Get the frame of the comment view in the same coordinate system
    CGRect commentViewFrameInViewCoordinates = [self.navigationController.view convertRect:self.lastSelectedCommentView.bounds fromView:self.lastSelectedCommentView];
    
    CGPoint contentOffset = self.tableView.contentOffset;
    UIEdgeInsets contentInsets = self.tableView.contentInset;
    UIEdgeInsets scrollIndicatorInsets = self.tableView.scrollIndicatorInsets;
    CGFloat heightToScroll = 0;
    
    CGFloat keyboardY = CGRectGetMinY(keyboardFrameInViewCoordinates);
    CGFloat commentViewY = CGRectGetMinY(commentViewFrameInViewCoordinates);
    CGFloat difference = commentViewY - keyboardY;
    
    if (difference > 0) {
        heightToScroll += difference;
    }
    
    if (CGRectIntersectsRect(keyboardFrameInViewCoordinates, commentViewFrameInViewCoordinates)) {
        // The two frames intersect (the keyboard would block the view)
        CGRect intersectionRect = CGRectIntersection(keyboardFrameInViewCoordinates, commentViewFrameInViewCoordinates);
        heightToScroll += CGRectGetHeight(intersectionRect);
    }
    
    if (heightToScroll > 0) {
        contentInsets.bottom += heightToScroll;
        scrollIndicatorInsets.bottom += heightToScroll;
        contentOffset.y += heightToScroll;
        
        NSNumber *durationNumber = notification.userInfo[UIKeyboardAnimationDurationUserInfoKey];
        NSNumber *curveNumber = notification.userInfo[UIKeyboardAnimationCurveUserInfoKey];
        
        NSTimeInterval duration = durationNumber.doubleValue;
        UIViewAnimationCurve curve = curveNumber.unsignedIntegerValue;
        UIViewAnimationOptions options = curve << 16;
        
        [UIView animateWithDuration:duration delay:0 options:options animations:^{
            self.tableView.contentInset = contentInsets;
            self.tableView.scrollIndicatorInsets = scrollIndicatorInsets;
            self.tableView.contentOffset = contentOffset;
        } completion:nil];
    }
    
    self.lastKeyboardAdjustment = heightToScroll;
}

 - (void)keyboardWillHide:(NSNotification *)notification {
     UIEdgeInsets contentInsets = self.tableView.contentInset;
     contentInsets.bottom -= self.lastKeyboardAdjustment;
     
     UIEdgeInsets scrollIndicatorInsets = self.tableView.scrollIndicatorInsets;
     scrollIndicatorInsets.bottom -= self.lastKeyboardAdjustment;
     
     NSNumber *durationNumber = notification.userInfo[UIKeyboardAnimationDurationUserInfoKey];
     NSNumber *curveNumber = notification.userInfo[UIKeyboardAnimationCurveUserInfoKey];
     
     NSTimeInterval duration = durationNumber.doubleValue;
     UIViewAnimationCurve curve = curveNumber.unsignedIntegerValue;
     
     UIViewAnimationOptions options = curve << 16;
     [UIView animateWithDuration:duration delay:0 options:options animations:^{
         self.tableView.contentInset = contentInsets;
         self.tableView.scrollIndicatorInsets = scrollIndicatorInsets;
     } completion:nil];
 }


- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
    BLCMediaFullScreenAnimator *animator = [BLCMediaFullScreenAnimator new];
    animator.cellImageView = self.lastTappedImageView;
    return animator;
}

#pragma mark - BLCMediaTableViewCellDelegate 

- (void) cell:(BLCMediaTableViewCell *)cell didTapImageView:(UIImageView *)imageView {
    self.lastTappedImageView = imageView;
    BLCMediaFullScreenViewController *fullScreenVC = [[BLCMediaFullScreenViewController alloc] initWithMedia:cell.mediaItem];
    
    if (isPhone) {
        fullScreenVC.transitioningDelegate = self;
        fullScreenVC.modalPresentationStyle = UIModalPresentationCustom;
    } else {
        fullScreenVC.modalPresentationStyle = UIModalPresentationFormSheet;
    }
    
    [self presentViewController:fullScreenVC animated:YES completion:nil];
}

- (void) cell:(BLCMediaTableViewCell *)cell didLongPressImageView:(UIImageView *)imageView {
    
    UIActivityViewController *activityVC = [ShareUtilities shareContentsWithText:cell.mediaItem viewController:self];
    
    if (isPhone) {
         [self presentViewController:activityVC animated:YES completion:nil];
        
    } else {
        //if ipad
            
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:activityVC];
        self.cameraPopover = [[UIPopoverController alloc] initWithContentViewController:nav];
        self.cameraPopover.popoverContentSize = CGSizeMake(768, 568);
        [self.cameraPopover presentPopoverFromRect:cell.bounds inView:imageView permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
        }


}


- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
                                         duration:(NSTimeInterval)duration {
    
}

#pragma mark - Camera and BLCCameraViewControllerDelegate

- (void) cameraPressed:(UIBarButtonItem *) sender {
    
    UIViewController *imageVC;
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        
        BLCCameraViewController *cameraVC = [[BLCCameraViewController alloc] init];
        cameraVC.delegate = self;
        imageVC = cameraVC;
        
        } else if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeSavedPhotosAlbum]) {
            
            BLCImageLibraryViewController *imageLibraryVC = [[BLCImageLibraryViewController alloc] init];
            imageLibraryVC.delegate = self;
            imageVC = imageLibraryVC;
        }
    
    if (imageVC) {
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:imageVC];
        if (isPhone) {
            [self presentViewController:nav animated:YES completion:nil];
        } else {
            self.cameraPopover = [[UIPopoverController alloc] initWithContentViewController:nav];
            self.cameraPopover.popoverContentSize = CGSizeMake(320, 568);
            [self.cameraPopover presentPopoverFromBarButtonItem:sender permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
        }
    }
    return;
}



- (void) handleImage:(UIImage *)image withNavigationController:(UINavigationController *)nav {
    if (image) {
        BLCPostToInstagramViewController *postVC = [[BLCPostToInstagramViewController alloc] initWithImage:image];
        
        [nav pushViewController:postVC animated:YES];
    } else {
        if (isPhone) {
            [nav dismissViewControllerAnimated:YES completion:nil];
        } else {
            [self.cameraPopover dismissPopoverAnimated:YES];
            self.cameraPopover = nil;
        }
    }
}

- (void) cameraViewController:(BLCCameraViewController *)cameraViewController didCompleteWithImage:(UIImage *)image {
    [self handleImage:image withNavigationController:cameraViewController.navigationController];
}

- (void) imageLibraryViewController:(BLCImageLibraryViewController *)imageLibraryViewController didCompleteWithImage:(UIImage *)image {
    [self handleImage:image withNavigationController:imageLibraryViewController.navigationController];
}


#pragma mark - Table view data source


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    // Configure the cell...
    BLCMediaTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"mediaCell" forIndexPath:indexPath];
    
    
    cell.delegate = self;
    cell.mediaItem = [BLCDataSource sharedInstance].mediaItems[indexPath.row];
    
    return cell;
}

//work here for assignment

/*
- (void) tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    BLCMedia *mediaItem = [BLCDataSource sharedInstance].mediaItems[indexPath.row];
    if (mediaItem.downloadState == BLCMediaDownloadStateNeedsImage) {
        [[BLCDataSource sharedInstance] downloadImageForMediaItem:mediaItem];
    }
}

*/


// this method expands teh tableviewcells to the correct ratio in order to fit the fixed width of the device
- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    BLCMedia *item = [self items][indexPath.row];
    return [BLCMediaTableViewCell heightForMediaItem:item width:CGRectGetWidth(self.view.frame)];
}

-(NSMutableArray *) items {
    
    return [BLCDataSource sharedInstance].mediaItems;
    
}



 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
 // Return NO if you do not want the specified item to be editable.
 
     return YES;
 }

- (CGFloat) tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    BLCMedia *item = [BLCDataSource sharedInstance].mediaItems[indexPath.row];
    if (item.image) {
        return 450;
    } else {
        return 250;
    }
}


 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
     if (editingStyle == UITableViewCellEditingStyleDelete) { // Delete the row from the data source
         BLCMedia *item = [BLCDataSource sharedInstance].mediaItems[indexPath.row];
         [[BLCDataSource sharedInstance] deleteMediaItem:item];
     }
 }

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    BLCMediaTableViewCell *cell = (BLCMediaTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
    [cell stopComposingComment];
}

 #pragma mark - Popover Handling 
- (void) imageDidFinish:(NSNotification *)notification {
    if (isPhone) {
        [self dismissViewControllerAnimated:YES completion:nil];
    } else {
        [self.cameraPopover dismissPopoverAnimated:YES];
        self.cameraPopover = nil;
    }
}

@end
