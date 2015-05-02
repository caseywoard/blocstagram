//
//  BLCLoginViewController.m
//  Blocstagram
//
//  Created by Casey Ward on 4/5/15.
//  Copyright (c) 2015 Casey Ward. All rights reserved.
//

#import "BLCLoginViewController.h"
#import "BLCDataSource.h"


@interface BLCLoginViewController () <UIAlertViewDelegate>

@property (nonatomic, weak) UIWebView *webView;



@end

@implementation BLCLoginViewController

NSString *const BLCLoginViewControllerDidGetAccessTokenNotification = @"BLCLoginViewControllerDidGetAccessTokenNotification";

- (void)viewDidLoad {
    [super viewDidLoad];
  
    // Do any additional setup after loading the view.
    
    //NSString *urlString = [NSString stringWithFormat:@"https://instagram.com/oauth/authorize/?client_id=%@&redirect_uri=%@&response_type=token", [BLCDataSource instagramClientID], [self redirectURI]];
    NSString *urlString = [NSString stringWithFormat:@"https://instagram.com/oauth/authorize/?client_id=%@&scope=likes+comments+relationships&redirect_uri=%@&response_type=token", [BLCDataSource instagramClientID], [self redirectURI]];
    
    NSURL *url = [NSURL URLWithString:urlString];
    
    if (url) {
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
        [self.webView loadRequest:request];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

 - (void)loadView {
     UIWebView *webView = [[UIWebView alloc] init];
     webView.delegate = self;
     self.webView = webView;
     self.view = webView;
     
     //assignment
     self.title = NSLocalizedString(@"Login", @"login");

    
 }


- (NSString *)redirectURI {
    return @"http://bloc.io";
}

 - (void) dealloc {
     // Removing this line causes a weird flickering effect when you relaunch the app after logging in, as the web view is briefly displayed, automatically authenticates with cookies, returns the access token, and dismisses the login view, sometimes in less than a second.
     [self clearInstagramCookies];
     // see https://developer.apple.com/library/ios/documentation/uikit/reference/UIWebViewDelegate_Protocol/Reference/Reference.html#//apple_ref/doc/uid/TP40006951-CH3-DontLinkElementID_1
     self.webView.delegate = nil;
 
 } /** Clears Instagram cookies. This prevents caching the credentials in the cookie jar. */

- (void) clearInstagramCookies {
    for(NSHTTPCookie *cookie in [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies]) {
        NSRange domainRange = [cookie.domain rangeOfString:@"instagram.com"];
        
        if(domainRange.location != NSNotFound) {
            [[NSHTTPCookieStorage sharedHTTPCookieStorage] deleteCookie:cookie];
        }
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (BOOL) webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    NSString *urlString = request.URL.absoluteString;
    if ([urlString hasPrefix:[self redirectURI]]) {
        // This contains our auth token
        NSRange rangeOfAccessTokenParameter = [urlString rangeOfString:@"access_token="];
        NSUInteger indexOfTokenStarting = rangeOfAccessTokenParameter.location + rangeOfAccessTokenParameter.length;
        NSString *accessToken = [urlString substringFromIndex:indexOfTokenStarting];
        [[NSNotificationCenter defaultCenter] postNotificationName:BLCLoginViewControllerDidGetAccessTokenNotification object:accessToken];
        return NO;
    }
    
    if (webView.canGoBack) {
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Home" style:UIBarButtonItemStyleDone target:self action:@selector(homeTapped:)];
    } else {
        self.navigationItem.leftBarButtonItem = nil;
    }
    
    return YES;
}

-(void) homeTapped: (id) sender {
    [self.webView goBack];
}
@end
