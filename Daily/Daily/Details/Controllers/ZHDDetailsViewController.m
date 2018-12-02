//
//  ZHDDetailsViewController.m
//  Daily
//
//  Created by 小哲的DELL on 2018/11/18.
//  Copyright © 2018年 小哲的DELL. All rights reserved.
//
#define WIDTH self.view.frame.size.width
#define HEIGHT self.view.frame.size.height
#import "ZHDDetailsViewController.h"
#import <WebKit/WebKit.h>
#import "ZHDCommentsViewController.h"
#import "ZHDCommentsManager.h"

@interface ZHDDetailsViewController () <WKUIDelegate>

@end

@implementation ZHDDetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self postData];
    [self createChildView];
}

- (void)createChildView{
    self.detailsView = [[ZHDDetailsView alloc] initWithFrame:self.view.frame];
    
    WKWebView *webView = [[WKWebView alloc] initWithFrame:CGRectMake(0, 0, WIDTH, HEIGHT*0.94)];
    webView.UIDelegate = self;
    NSString *str = [NSString stringWithFormat:@"https://daily.zhihu.com/story/%@", self.ID];
    NSURL *url = [NSURL URLWithString:str];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [webView loadRequest:request];
    [self.detailsView addSubview:webView];
    
    [self.view addSubview:self.detailsView];
    
    //为bottomView的button添加点击事件
    [self.detailsView.bottomView.backButton addTarget:self action:@selector(backClick) forControlEvents:UIControlEventTouchUpInside];
    [self.detailsView.bottomView.commentButton addTarget:self action:@selector(commentsClilk) forControlEvents:UIControlEventTouchUpInside];
    
}

- (void)postData{
    [[ZHDCommentsManager sharedManager] requestCommentsWithID:self.ID Success:^(ZHDCommentsModel *commentsModel) {
        self.commentsModel = commentsModel;
    }];
}

- (void)backClick{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)commentsClilk{
    ZHDCommentsViewController *commentsController = [[ZHDCommentsViewController alloc] init];
    commentsController.ID = self.ID;
    commentsController.title = [NSString stringWithFormat:@"%@条点评", self.commentsModel.comments];
    commentsController.commentsModel = self.commentsModel;
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:commentsController];
    [self presentViewController:navigationController animated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
