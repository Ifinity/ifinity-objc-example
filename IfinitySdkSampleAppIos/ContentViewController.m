//
//  ContentViewController.m
//  IfinitySdkSampleAppIos
//
//  Created by Ifinity on 24.11.2015.
//  Copyright © 2015 getifinity.com. All rights reserved.
//

#import "ContentViewController.h"
#import "SVProgressHUD.h"

@interface ContentViewController () <UIWebViewDelegate>

@property (weak, nonatomic) IBOutlet UIWebView *webView;

@end

@implementation ContentViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated
{
    if(self.url){
        [self loadUrl:self.url];
    }else if(self.content){
        [self loadHTMLString:self.content];
    }
    
    [super viewWillAppear:animated];
}

- (void)loadUrl:(NSURL *)url
{
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeBlack];

    NSLog(@"load url: %@", [url absoluteString]);
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [self.webView loadRequest:request];
}

- (void)loadHTMLString:(NSString *)content
{
    NSLog(@"load content: YES");
    [self.webView loadHTMLString:content baseURL:nil];
}

#pragma mark - UIWebViewDelegate

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [SVProgressHUD dismiss];
}

#pragma mark - Handler

- (IBAction)backToHome:(id)sender
{
    [SVProgressHUD dismiss];
    
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
