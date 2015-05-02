//
//  BLCMediaFullScreenViewController.m
//  Blocstagram
//
//  Created by Casey Ward on 4/12/15.
//  Copyright (c) 2015 Casey Ward. All rights reserved.
//

#import "BLCMediaFullScreenViewController.h"
#import "BLCMedia.h"
#import "BLCMediaTableViewCell.h"
#import "ShareUtilities.h"

@interface BLCMediaFullScreenViewController () <UIScrollViewDelegate>



@property (nonatomic, strong) UITapGestureRecognizer *tap;
@property (nonatomic, strong) UITapGestureRecognizer *doubleTap;


@property (nonatomic, strong) UIButton *shareButton;

@end

@implementation BLCMediaFullScreenViewController

- (instancetype) initWithMedia:(BLCMedia *)media {
    self = [super init];
    
    if (self) {
        self.media = media;
    }
    
    return self;
}




- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.scrollView = [UIScrollView new];
    self.scrollView.delegate = self;
    self.scrollView.backgroundColor = [UIColor whiteColor];
    
    [self.view addSubview:self.scrollView];
    
    self.imageView = [UIImageView new];
    self.imageView.image = self.media.image;
    
    [self.scrollView addSubview:self.imageView];
    self.scrollView.contentSize = self.media.image.size;
    
    //about the double tap
    self.tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapFired:)];
    //self.tap.numberOfTouchesRequired = 1;//needed?
    
    self.doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTapFired:)];
    self.doubleTap.numberOfTapsRequired = 2;
    
    [self.tap requireGestureRecognizerToFail:self.doubleTap];
    
    [self.scrollView addGestureRecognizer:self.tap];
    [self.scrollView addGestureRecognizer:self.doubleTap];
    
    //checkpoint assignment
    
    UIButton *shareButton = [[UIButton alloc] init];
    
    [shareButton setTitle:@"Share" forState:UIControlStateNormal];
    //[shareButton sizeToFit];
    CGFloat shareButtonHeight = 20;
    CGFloat shareButtonWidth = 100;
    CGFloat shareButtonX = CGRectGetWidth(self.view.frame) - 100;
    CGFloat shareButtonY = 20;
    
    shareButton.frame = CGRectMake(shareButtonX, shareButtonY, shareButtonWidth, shareButtonHeight);
    
    [self.view addSubview:shareButton];
    
    [shareButton addTarget:self action:@selector(shareTapped:) forControlEvents:UIControlEventTouchUpInside];
    
   
    
}


-(void) shareTapped: (id) sender {
    [ShareUtilities shareContentsWithText:self.media viewController:self];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    self.scrollView.frame = self.view.bounds;
    
    [self recalculateZoomScale];
}

- (void) recalculateZoomScale {
    CGSize scrollViewFrameSize = self.scrollView.frame.size;
    CGSize scrollViewContentSize = self.scrollView.contentSize;
    
    scrollViewContentSize.height /= self.scrollView.zoomScale;
    scrollViewContentSize.width /= self.scrollView.zoomScale;
    
    CGFloat scaleWidth = scrollViewFrameSize.width / scrollViewContentSize.width;
    CGFloat scaleHeight = scrollViewFrameSize.height / scrollViewContentSize.height;
    CGFloat minScale = MIN(scaleWidth, scaleHeight);
    
    self.scrollView.minimumZoomScale = minScale;
    self.scrollView.maximumZoomScale = 1;
}

- (void)centerScrollView {
     [self.imageView sizeToFit];
     CGSize boundsSize = self.scrollView.bounds.size;
     CGRect contentsFrame = self.imageView.frame;
     if (contentsFrame.size.width < boundsSize.width) {
         contentsFrame.origin.x = (boundsSize.width - CGRectGetWidth(contentsFrame)) / 2; }
     else {
         contentsFrame.origin.x = 0;
     }
     
     if (contentsFrame.size.height < boundsSize.height) {
         contentsFrame.origin.y = (boundsSize.height - CGRectGetHeight(contentsFrame)) / 2;
     } else {
         contentsFrame.origin.y = 0;
     }
     self.imageView.frame = contentsFrame;
}

#pragma mark - Gesture Recognizers 

- (void) tapFired:(UITapGestureRecognizer *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void) doubleTapFired:(UITapGestureRecognizer *)sender {
    if (self.scrollView.zoomScale == self.scrollView.minimumZoomScale) {
        CGPoint locationPoint = [sender locationInView:self.imageView];
        
        CGSize scrollViewSize = self.scrollView.bounds.size;
        
        CGFloat width = scrollViewSize.width / self.scrollView.maximumZoomScale;
        CGFloat height = scrollViewSize.height / self.scrollView.maximumZoomScale;
        CGFloat x = locationPoint.x - (width / 2);
        CGFloat y = locationPoint.y - (height / 2);
        
        [self.scrollView zoomToRect:CGRectMake(x, y, width, height) animated:YES];
    } else {
        [self.scrollView setZoomScale:self.scrollView.minimumZoomScale animated:YES];
    }
}



#pragma mark - UIScrollViewDelegate

- (UIView*)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.imageView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    [self centerScrollView];
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self centerScrollView];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
