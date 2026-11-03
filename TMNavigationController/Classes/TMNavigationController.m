//
//  TMNavigationController.m
//  Demo
//
//  Created by TianMing on 16/3/10.
//  Copyright © 2016年 TianMing. All rights reserved.
//

#import "TMNavigationController.h"
#import "TMNavigationConfig.h"
#import "TMNavigationBarView+SystemButtons.h"
#import <objc/runtime.h>

@interface TMNavigationController () <UIGestureRecognizerDelegate,UINavigationControllerDelegate>
// 忽略
@property (nonatomic, assign) BOOL shouldIgnorePushingViewControllers;

/// 业务原有系统栏显隐请求，退出竖栏后继续沿用。
@property(nonatomic) BOOL tm_requestedNavigationBarHidden;

/// 曾由本导航栈管理的页面；移出栈时解除其系统展示。
@property(nonatomic, strong) NSHashTable<UIViewController *> *tm_managedControllers;

- (void)tm_prepareNavigationBarForController:(UIViewController *)controller root:(BOOL)root;
- (BOOL)tm_prefersSystemButtons;
- (void)tm_updateSystemPresentation;


@end

@implementation TMNavigationController

- (instancetype)initWithRootViewController:(UIViewController *)rootViewController{
    if (self = [super initWithRootViewController:rootViewController]) {
//        NSLog(@"%@",rootViewController.childViewControllers);
    }
    return self;
}
- (void)loadView{
    [super loadView];
    [self createBarView];
    self.navigationCanDragBack = YES;
    self.delegate = self;
    [self addPopGesture];
}
- (void)viewDidLoad {
    [super viewDidLoad];
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 270100
    if (@available(iOS 27.1, *)) {
        [self registerForTraitChanges:UITraitCollection.systemTraitsAffectingVerticalBarEdge
                         withHandler:^(__kindof TMNavigationController *controller, UITraitCollection *previous) {
            [controller.view setNeedsLayout];
        }];
    }
#endif
    if ([TMNavigationConfig shareInstance].forceSideslipGesture) {
        self.navigationCanSideslipBack = YES;
    }
}

- (void)createBarView
{
    self.tm_requestedNavigationBarHidden = YES;
    [super setNavigationBarHidden:YES animated:NO];
    [self tm_prepareNavigationBarForController:self.topViewController root:self.viewControllers.count == 1];
    if (self.topViewController) {
        [self.topViewController.view addSubview:self.topViewController.navigationBar];
    }
}

- (void)tm_prepareNavigationBarForController:(UIViewController *)controller root:(BOOL)root
{
    // 初始化空导航栈时没有页面；已绑定的页面保留业务状态与原按钮。
    if (!controller) return;
    if (!self.tm_managedControllers) self.tm_managedControllers = [NSHashTable weakObjectsHashTable];
    [self.tm_managedControllers addObject:controller];
    if (!controller.navigationBar) {
        TMNavigationBarView *bar = [[TMNavigationBarView alloc] initWithFrame:CGRectZero];
        controller.navigationBar = bar;
        bar.backButton.hidden = root;
        [self setPropertyWithViewController:controller barView:bar];
    }
    [controller.navigationBar tm_bindToViewController:controller];
    __weak typeof(self) weakSelf = self;
    controller.navigationBar.tm_presentationChanged = ^{
        [weakSelf.view setNeedsLayout];
    };
}

- (BOOL)tm_prefersSystemButtons
{
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 270100
    if (@available(iOS 27.1, *)) {
        if (self.traitCollection.verticalBarEdge == UIVerticalBarEdgeUnspecified) return NO;
        for (UIViewController *controller = self.topViewController; controller; controller = controller.parentViewController) {
            if (controller.preferredVerticalBarBehavior == UIVerticalBarBehaviorDisabled) return NO;
        }
        return YES;
    }
#endif
    return NO;
}

- (void)tm_updateSystemPresentation
{
    if (!self.isViewLoaded) return;
    BOOL system = [self tm_prefersSystemButtons];
    for (UIViewController *controller in self.tm_managedControllers.allObjects) {
        BOOL inStack = [self.viewControllers containsObject:controller];
        [controller.navigationBar tm_applySystemButtons:system && inStack];
        if (!inStack) [self.tm_managedControllers removeObject:controller];
    }
    TMNavigationBarView *bar = self.topViewController.navigationBar;
    BOOL hidden = system && bar ? bar.hidden : self.tm_requestedNavigationBarHidden;
    // 旧业务的“隐藏横向系统栏”在竖栏模式下由自定义栏的业务显隐决定。
    if (self.isNavigationBarHidden != hidden) [super setNavigationBarHidden:hidden animated:NO];
}

- (void)setNavigationBarHidden:(BOOL)hidden
{
    [self setNavigationBarHidden:hidden animated:NO];
}

- (void)setNavigationBarHidden:(BOOL)hidden animated:(BOOL)animated
{
    self.tm_requestedNavigationBarHidden = hidden;
    TMNavigationBarView *bar = self.topViewController.navigationBar;
    BOOL actual = self.isViewLoaded && [self tm_prefersSystemButtons] && bar ? bar.hidden : hidden;
    [super setNavigationBarHidden:actual animated:animated];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    [self tm_updateSystemPresentation];
}

- (void)setViewControllers:(NSArray<UIViewController *> *)controllers animated:(BOOL)animated
{
    for (UIViewController *controller in controllers) {
        [self tm_prepareNavigationBarForController:controller root:controller == controllers.firstObject];
    }
    [super setViewControllers:controllers animated:animated];
    for (UIViewController *controller in controllers) {
        if (controller.isViewLoaded) [controller.view addSubview:controller.navigationBar];
    }
    [self tm_updateSystemPresentation];
}

- (void)addPopGesture {
    self.interactivePopGestureRecognizer.enabled = NO;
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc]init];
    pan.delegate = self;
    pan.maximumNumberOfTouches = 1;
    [self.view addGestureRecognizer:pan];
    NSMutableArray * _targets = [self.interactivePopGestureRecognizer valueForKey:@"_targets"];
    id _UINavigationInteractiveTransition = [[_targets firstObject] valueForKey:@"_target"];
    NSString * pop = @"handleNavigationTransition:";
    SEL popAction = NSSelectorFromString(pop);
    [pan addTarget:_UINavigationInteractiveTransition action:popAction];
    self.panGesture = pan;
}
- (BOOL)gestureRecognizerShouldBegin:(UIPanGestureRecognizer *)gestureRecognizer {
    CGPoint translation = [gestureRecognizer translationInView:gestureRecognizer.view];
    if (kIsRTL) { // 适配阿拉伯
        if (translation.x >= 0  || self.childViewControllers.count==1 || [[self valueForKey:@"_isTransitioning"] boolValue]) {
            return NO;
        }
    }else {
        if (translation.x <= 0  || self.childViewControllers.count==1 || [[self valueForKey:@"_isTransitioning"] boolValue]) {
            return NO;
        }
    }
    // 如果开启了侧滑 50 以内
    CGPoint touchPoint = [gestureRecognizer locationInView:self.view];
    if (self.navigationCanSideslipBack) {
        CGFloat locationX = kIsRTL ? SCREEN_WIDTH - touchPoint.x : touchPoint.x;
        if (locationX > 50) {
            return NO;
        }
    }
    return YES;
}
- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    if (self.viewControllers.count > 0) viewController.hidesBottomBarWhenPushed = YES;
    if (@available(iOS 26.0, *)) {
        [self tm_prepareNavigationBarForController:viewController root:self.viewControllers.count == 0];
        [super pushViewController:viewController animated:animated];
    } else {
        if (self.shouldIgnorePushingViewControllers) return;
        [self tm_prepareNavigationBarForController:viewController root:self.viewControllers.count == 0];
        [super pushViewController:viewController animated:animated];
        self.shouldIgnorePushingViewControllers = YES;
    }
    [viewController.view addSubview:viewController.navigationBar];
    [self tm_updateSystemPresentation];
}
- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    self.shouldIgnorePushingViewControllers = NO;
    [self tm_updateSystemPresentation];
}
- (void)setPropertyWithViewController:(UIViewController*)viewController barView:(TMNavigationBarView *)barView {
    barView.title = viewController.title;
    barView.hidden = viewController.navigationBarHidden;
    barView.myBackgroundImage = viewController.navigationBarBackgroundImage;
    barView.myBackgroundColor = viewController.navigationBarBackgroundColor;
    barView.myTitleColor = viewController.navigationBarTitleColor;
    barView.myBottomLineColor = viewController.navigationBarBottomLineBackgroundColor;
    // 默认点击返回方法
    __weak typeof(self) weakSelf = self;
    [barView clickBackButton:^(UIButton *button) {
        [weakSelf popViewControllerAnimated:YES];
    }];
    // 默认 左边第二个按钮隐藏、右边按钮隐藏
    for (NSString *key in @[@"navigationLeftBarHidden", @"navigationRightBarHidden", @"navigationRightFirstBarHidden"]) {
        NSNumber *configured = objc_getAssociatedObject(viewController, NSSelectorFromString(key));
        [viewController setValue:configured ?: @YES forKey:key];
    }
    
}
- (UIViewController*)popViewControllerAnimated:(BOOL)animated {
    return [super popViewControllerAnimated:animated];
}
// 支持子控制器旋转方向
- (BOOL)shouldAutorotate {
    return self.topViewController.shouldAutorotate;
}
- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return self.topViewController.supportedInterfaceOrientations;
}
- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return self.topViewController.preferredInterfaceOrientationForPresentation;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


@end





