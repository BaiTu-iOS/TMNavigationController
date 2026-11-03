//
//  TMViewController.m
//  TMNavigationController
//
//  Created by youingge on 04/20/2023.
//  Copyright (c) 2023 youingge. All rights reserved.
//

#import "TMViewController.h"
#import "TMNavigationController.h"
#import "FirstViewController.h"
#import "TMAppDelegate.h"

@interface TMViewController ()

@property (strong , nonatomic) UITabBarController * tabbar;

@end

@implementation TMViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initTabbar];

    
}

- (void)initTabbar {
    
    //    [TMNavigationConfig shareInstance].forceSideslipGesture = YES;
    [TMNavigationConfig shareInstance].backButtonImage = [UIImage imageNamed:@"left"];
    
    _tabbar = [[UITabBarController alloc]init];
    TMNavigationController * nav1 = [[TMNavigationController alloc]initWithRootViewController:[FirstViewController new]];
    TMNavigationController * nav2 = [[TMNavigationController alloc]initWithRootViewController:[FirstViewController new]];
    TMNavigationController * nav3 = [[TMNavigationController alloc]initWithRootViewController:[FirstViewController new]];
    _tabbar.viewControllers = @[nav1,nav2,nav3];
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    // Example 使用当前 Scene 的窗口，供系统竖栏与宿主布局测试使用。
    self.view.window.rootViewController = _tabbar;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
