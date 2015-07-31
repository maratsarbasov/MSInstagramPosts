//
//  AuthViewController.m
//  Instagram
//
//  Created by MS on 7/28/15.
//  Copyright (c) 2015 Sarbasov inc. All rights reserved.
//


#define CLIENTID @"d50cd4226a534c7abafc49b125838c12"
#define CLIENTSECRET @"d328044390d04d73baadd77f426e972b"
#define REDIRECTURI @"http://google.com"


#import "AuthViewController.h"

@interface AuthViewController () <UIWebViewDelegate>

@property (strong, nonatomic) IBOutlet UIWebView *webView;



@end



@implementation AuthViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIBarButtonItem *flipButton = [[UIBarButtonItem alloc]
                                   initWithTitle:@"Cancel"
                                   style:UIBarButtonItemStylePlain
                                   target:self
                                   action:@selector(cancel)];
    self.navigationItem.leftBarButtonItem = flipButton;
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [self loadURL];
}

- (void)cancel
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)loadURL
{
    NSString *fullURL = [NSString stringWithFormat: @"https://instagram.com/oauth/authorize/?client_id=%@&redirect_uri=%@&response_type=token", CLIENTID, REDIRECTURI];
    
    NSURL *url = [NSURL URLWithString:fullURL];
    NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];
    [self.webView loadRequest:requestObj];
}


- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    //parse accessToken
    NSString *responseString = [[request URL] absoluteString];
    if ([responseString containsString:@"#access_token="]) {
        NSRange range = [responseString rangeOfString:@"#access_token="];
        NSString *accessToken = [responseString substringFromIndex:NSMaxRange(range)];
        NSLog(@"Got access token: %@", accessToken);
        [[NSUserDefaults standardUserDefaults] setObject:accessToken forKey:@"accessToken"];
        
        [self dismissViewControllerAnimated:YES completion:nil];
        return NO;
    }
    
    return YES;
}

@end
