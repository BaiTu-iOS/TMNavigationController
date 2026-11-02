//
//  UIViewController+TMNavigationBarView.m
//  TMNavigationController
//
//  Created by TianMing on 2019/2/22.
//  Copyright © 2019 TianMing. All rights reserved.
//

#import "UIViewController+TMNavigationBarView.h"
#import "TMNavigationController.h"
#import "TMNavigationConfig.h"

@implementation UIViewController (TMNavigationBarView)

@dynamic navigationCanDragBack;
@dynamic navigationCanSideslipBack;
@dynamic navigationRightBarImage;
@dynamic navigationBar;
@dynamic navigationBarHidden;
@dynamic navigationLeftBarHidden;
@dynamic navigationRightBarHidden;
@dynamic navigationRightBarTitleColor;
@dynamic navigationRightBarTitle;
@dynamic title;
@dynamic navigationBackButtonImage;
@dynamic navigationBarBackgroundColor;
@dynamic navigationBarBottomLineBackgroundColor;
@dynamic navigationBarTitleColor;
@dynamic navigationRightFirstBarImage;
@dynamic navigationRightFirstBarHidden;
@dynamic navigationRightFirstBarTitle;
@dynamic navigationRightFirstBarTitleColor;
@dynamic navigationBarBackgroundImage;
@dynamic navigationLeftBarTitleColor;

- (BOOL)navigationCanDragBack {
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}
- (void)setNavigationCanDragBack:(BOOL)navigationCanDragBack {
    if ([self.navigationController isKindOfClass:[TMNavigationController class]]) {
        TMNavigationController * nav = (TMNavigationController*)self.navigationController;
        if (nav && [nav isKindOfClass:TMNavigationController.class]) {
            if (nav.panGesture) {
                if (!navigationCanDragBack ) {
                    // 禁用返回手势
                    nav.panGesture.enabled = NO;
                }else{
                    nav.panGesture.enabled = YES;
                }
            }
        }
    }
    objc_setAssociatedObject(self, @selector(navigationCanDragBack), @(navigationCanDragBack), OBJC_ASSOCIATION_ASSIGN);
}
- (BOOL)navigationCanSideslipBack {
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}
- (void)setNavigationCanSideslipBack:(BOOL)navigationCanSideslipBack {
    if ([self.navigationController isKindOfClass:[TMNavigationController class]]) {
        TMNavigationController * nav = (TMNavigationController*)self.navigationController;
        if (nav && [nav isKindOfClass:TMNavigationController.class]) {
            if (nav.panGesture) {
                // 如果打开全局的侧滑返回
                if ([TMNavigationConfig shareInstance].forceSideslipGesture) {
                    nav.navigationCanSideslipBack = YES;
                }else {
                    nav.navigationCanSideslipBack = navigationCanSideslipBack;
                }
            }
        }
    }
    objc_setAssociatedObject(self, @selector(navigationCanSideslipBack), @(navigationCanSideslipBack), OBJC_ASSOCIATION_ASSIGN);
}
- (TMNavigationBarView *)navigationBar{
    return objc_getAssociatedObject(self, _cmd);
}
- (void)setNavigationBar:(TMNavigationBarView *)navigationBar{
    objc_setAssociatedObject(self, @selector(navigationBar), navigationBar, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (BOOL)isNavigationBar{
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}
- (void)setNavigationBarHidden:(BOOL)navigationBarHidden{
    if (navigationBarHidden) {
        self.navigationBar.hidden = YES;
    }else{
        self.navigationBar.hidden = NO;
    }
    objc_setAssociatedObject(self, @selector(isNavigationBar), @(navigationBarHidden), OBJC_ASSOCIATION_ASSIGN);
}
- (void)setNavigationBackBarHidden:(BOOL)navigationBackBarHidden
{
    self.navigationBar.backButton.hidden = navigationBackBarHidden;
    [self.navigationBar setNeedsLayout];
    objc_setAssociatedObject(self, @selector(navigationBackBarHidden), @(navigationBackBarHidden), OBJC_ASSOCIATION_ASSIGN);
}
- (BOOL)navigationBackBarHidden{
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}
- (void)setNavigationLeftBarHidden:(BOOL)navigationLeftBarHidden
{
    self.navigationBar.leftButton.hidden = navigationLeftBarHidden;
    [self.navigationBar setNeedsLayout];
    objc_setAssociatedObject(self, @selector(navigationLeftBarHidden), @(navigationLeftBarHidden), OBJC_ASSOCIATION_ASSIGN);
}
- (BOOL)navigationLeftBarHidden{
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}
- (NSString*)navigationLeftBarTitle{
    return objc_getAssociatedObject(self, _cmd);
}
- (void)setNavigationLeftBarTitle:(NSString *)navigationLeftBarTitle {
    if (navigationLeftBarTitle) {
        [self.navigationBar.leftButton setTitle:navigationLeftBarTitle forState:UIControlStateNormal];
    }
    [self.navigationBar setNeedsLayout];
    objc_setAssociatedObject(self, @selector(navigationLeftBarTitle), navigationLeftBarTitle, OBJC_ASSOCIATION_RETAIN);
}
- (UIColor*)navigationLeftBarTitleColor{
    return objc_getAssociatedObject(self, _cmd);
}
- (void)setNavigationLeftBarTitleColor:(UIColor *)navigationLeftBarTitleColor{
    if (navigationLeftBarTitleColor) {
        [self.navigationBar.leftButton setTitleColor:navigationLeftBarTitleColor forState:UIControlStateNormal];
    }
    objc_setAssociatedObject(self, @selector(navigationLeftBarTitleColor), navigationLeftBarTitleColor, OBJC_ASSOCIATION_RETAIN);
}
- (void)setNavigationRightBarHidden:(BOOL)navigationRightBarHidden
{
    self.navigationBar.rightButton.hidden = navigationRightBarHidden;
    [self.navigationBar setNeedsLayout];
    objc_setAssociatedObject(self, @selector(navigationRightBarHidden), @(navigationRightBarHidden), OBJC_ASSOCIATION_ASSIGN);
}
- (BOOL)navigationRightBarHidden{
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}
- (NSString*)navigationRightBarTitle{
    return objc_getAssociatedObject(self, _cmd);
}
- (void)setNavigationRightBarTitle:(NSString *)navigationRightBarTitle
{
    if (navigationRightBarTitle) {
        [self.navigationBar.rightButton setTitle:navigationRightBarTitle forState:UIControlStateNormal];
    }
    [self.navigationBar setNeedsLayout];
    objc_setAssociatedObject(self, @selector(navigationRightBarTitle), navigationRightBarTitle, OBJC_ASSOCIATION_RETAIN);
}

- (BOOL)navigationRightFirstBarHidden{
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}
- (void)setNavigationRightFirstBarHidden:(BOOL)navigationRightFirstBarHidden
{
    self.navigationBar.rightFirstButton.hidden = navigationRightFirstBarHidden;
    [self.navigationBar setNeedsLayout];
    objc_setAssociatedObject(self, @selector(navigationRightFirstBarHidden), @(navigationRightFirstBarHidden), OBJC_ASSOCIATION_ASSIGN);
}
- (NSString*)navigationRightFirstBarTitle{
    return objc_getAssociatedObject(self, _cmd);
}
- (void)setNavigationRightFirstBarTitle:(NSString *)navigationRightFirstBarTitle
{
    if (navigationRightFirstBarTitle) {
        [self.navigationBar.rightFirstButton setTitle:navigationRightFirstBarTitle forState:UIControlStateNormal];
    }
    [self.navigationBar setNeedsLayout];
    objc_setAssociatedObject(self, @selector(navigationRightFirstBarTitle), navigationRightFirstBarTitle, OBJC_ASSOCIATION_RETAIN);
}
- (UIColor*)navigationRightFirstBarTitleColor{
    return objc_getAssociatedObject(self, _cmd);
}
- (void)setNavigationRightFirstBarTitleColor:(UIColor *)navigationRightFirstBarTitleColor{
    if (navigationRightFirstBarTitleColor) {
        [self.navigationBar.rightFirstButton setTitleColor:navigationRightFirstBarTitleColor forState:UIControlStateNormal];
    }
    objc_setAssociatedObject(self, @selector(navigationRightFirstBarTitleColor), navigationRightFirstBarTitleColor, OBJC_ASSOCIATION_RETAIN);
}
- (UIColor*)navigationRightBarTitleColor{
    return objc_getAssociatedObject(self, _cmd);
}
- (void)setNavigationRightBarTitleColor:(UIColor *)navigationRightBarTitleColor{
    if (navigationRightBarTitleColor) {
        [self.navigationBar.rightButton setTitleColor:navigationRightBarTitleColor forState:UIControlStateNormal];
    }
    objc_setAssociatedObject(self, @selector(navigationRightBarTitleColor), navigationRightBarTitleColor, OBJC_ASSOCIATION_RETAIN);
}
- (UIImage*)navigationRightFirstBarImage{
    return objc_getAssociatedObject(self, _cmd);
}
- (void)setNavigationRightFirstBarImage:(UIImage *)navigationRightFirstBarImage{
    if (navigationRightFirstBarImage) {
        self.navigationBar.rightFirstButton.titleLabel.text = @"";
        [self.navigationBar.rightFirstButton setImage:navigationRightFirstBarImage forState:UIControlStateNormal];
    }
    [self.navigationBar setNeedsLayout];
    objc_setAssociatedObject(self, @selector(navigationRightFirstBarImage), navigationRightFirstBarImage, OBJC_ASSOCIATION_RETAIN);
}
- (UIImage*)navigationRightBarImage{
    return objc_getAssociatedObject(self, _cmd);
}
- (void)setNavigationRightBarImage:(UIImage *)navigationRightBarImage{
    if (navigationRightBarImage) {
        self.navigationBar.rightButton.titleLabel.text = @"";
        [self.navigationBar.rightButton setImage:navigationRightBarImage forState:UIControlStateNormal];
    }
    [self.navigationBar setNeedsLayout];
    objc_setAssociatedObject(self, @selector(navigationRightBarImage), navigationRightBarImage, OBJC_ASSOCIATION_RETAIN);
}
- (NSString *)title{
    return objc_getAssociatedObject(self, _cmd);
}
- (void)setTitle:(NSString *)title{
    if (title && self.navigationBar ) {
        if ([self.navigationBar isKindOfClass:[TMNavigationBarView class]]) {
            self.navigationBar.title = title;
        }
    }
    objc_setAssociatedObject(self, @selector(title), title, OBJC_ASSOCIATION_COPY);
}
- (void)setNavigationBarTitleColor:(UIColor *)navigationBarTitleColor{
    if (navigationBarTitleColor) {
        self.navigationBar.myTitleColor = navigationBarTitleColor;
    }
    objc_setAssociatedObject(self, @selector(navigationBarTitleColor), navigationBarTitleColor, OBJC_ASSOCIATION_COPY);
    
}
- (UIColor*)navigationBarTitleColor{
    return objc_getAssociatedObject(self, _cmd);
}
- (void)setNavigationBarBackgroundColor:(UIColor *)navigationBarBackgroundColor{
    if (navigationBarBackgroundColor) {
        self.navigationBar.myBackgroundColor = navigationBarBackgroundColor;
    }
    objc_setAssociatedObject(self, @selector(navigationBarBackgroundColor), navigationBarBackgroundColor, OBJC_ASSOCIATION_RETAIN);
}
- (UIColor*)navigationBarBackgroundColor{
    return objc_getAssociatedObject(self, _cmd);
}
- (void)setNavigationBarBackgroundImage:(UIImage *)navigationBarBackgroundImage{
    if (navigationBarBackgroundImage) {
        self.navigationBar.myBackgroundImage = navigationBarBackgroundImage;
    }
    objc_setAssociatedObject(self, @selector(navigationBarBackgroundImage), navigationBarBackgroundImage, OBJC_ASSOCIATION_RETAIN);
}
- (UIImage*)navigationBarBackgroundImage{
    return objc_getAssociatedObject(self, _cmd);
}
- (void)setNavigationBarBottomLineBackgroundColor:(UIColor *)navigationBarBottomLineBackgroundColor{
    if (navigationBarBottomLineBackgroundColor) {
        self.navigationBar.myBottomLineColor = navigationBarBottomLineBackgroundColor;
    }
    objc_setAssociatedObject(self, @selector(navigationBarBottomLineBackgroundColor), navigationBarBottomLineBackgroundColor, OBJC_ASSOCIATION_RETAIN);
}
- (UIColor*)navigationBarBottomLineBackgroundColor{
    return objc_getAssociatedObject(self, _cmd);
}
- (void)setNavigationBackButtonImage:(UIImage *)navigationBackButtonImage{
    if (navigationBackButtonImage) {
        [self.navigationBar.backButton setImage:navigationBackButtonImage forState:UIControlStateNormal];
    }
    [self.navigationBar setNeedsLayout];
    objc_setAssociatedObject(self, @selector(navigationBackButtonImage), navigationBackButtonImage, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (UIImage*)navigationBackButtonImage{
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setNavigationGradientBackgroundFromColor:(UIColor*)fromColor toColor:(UIColor*)toColor{
    self.navigationBar.gradientLayer.colors = @[(__bridge id)fromColor.CGColor,(__bridge id)toColor.CGColor];
}
- (void)setNavigationBarAlpha:(CGFloat)alpha{
    for (UIView * view in self.navigationBar.subviews) {
        view.alpha = alpha;
    }
}

- (void)navigationBackButtonClickBlock:(void (^)(UIButton* button))block{
    if (self.navigationBar) {
        self.navigationBar.click = [block copy];
    }
}
- (void)navigationLeftButtonClickBlock:(void (^)(UIButton* button))block{
    if (self.navigationBar) {
        self.navigationBar.leftClick = [block copy];
    }
}
- (void)navigationRightButtonClickBlock:(void (^)(UIButton* button))block{
    if (self.navigationBar) {
        self.navigationBar.rightClick = [block copy];
    }
}
- (void)navigationRightFirstButtonClickBlock:(void (^)(UIButton* button))block{
    if (self.navigationBar) {
        self.navigationBar.rightFirstClick = [block copy];
    }
}

@end
