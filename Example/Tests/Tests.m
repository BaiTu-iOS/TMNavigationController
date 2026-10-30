//
//  TMNavigationControllerTests.m
//  TMNavigationControllerTests
//
//  Created by youingge on 04/20/2023.
//  Copyright (c) 2023 youingge. All rights reserved.
//

@import XCTest;
#import <TMNavigationController/TMNavigationBarView.h>
#import <TMNavigationController/TMNavigationConfig.h>
#import <TMNavigationController/UIViewController+TMNavigationBarView.h>

@interface Tests : XCTestCase

@end

@implementation Tests

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testButtonsAndBackgroundFollowSuperviewWidth
{
    UIView *host = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 375, 750)];
    TMNavigationBarView *bar = [[TMNavigationBarView alloc] initWithFrame:CGRectZero];
    bar.leftButton.hidden = YES;
    bar.rightFirstButton.hidden = YES;
    [bar.rightButton setTitle:@"编辑" forState:UIControlStateNormal];
    [host addSubview:bar];
    for (NSNumber *width in @[@375, @951, @375]) {
        host.frame = CGRectMake(0, 0, width.doubleValue, 750);
        [bar setNeedsLayout];
        [bar layoutIfNeeded];
        XCTAssertEqualWithAccuracy(CGRectGetWidth(bar.frame), width.doubleValue, 0.01);
        XCTAssertEqualWithAccuracy(CGRectGetWidth(bar.backgroundImageView.frame), width.doubleValue, 0.01);
        XCTAssertEqualWithAccuracy(CGRectGetWidth(bar.gradientLayer.frame), width.doubleValue, 0.01);
        XCTAssertLessThanOrEqual(CGRectGetMaxX(bar.rightButton.frame), width.doubleValue);
        XCTAssertGreaterThanOrEqual(CGRectGetMinX(bar.rightButton.frame), width.doubleValue - 100);
    }
}

- (void)testVisibilitySettersReflowTitleWithoutOverlappingTextButtons
{
    UIViewController *host = [[UIViewController alloc] init];
    host.view.frame = CGRectMake(0, 0, 375, 750);
    TMNavigationBarView *bar = [[TMNavigationBarView alloc] initWithFrame:CGRectZero];
    host.navigationBar = bar;
    [host.view addSubview:bar];
    host.navigationLeftBarHidden = YES;
    host.navigationRightBarHidden = NO;
    host.navigationRightBarTitle = @"编辑资料";
    host.navigationRightFirstBarHidden = NO;
    host.navigationRightFirstBarTitle = @"分享";
    [bar layoutIfNeeded];
    CGFloat titleWidth = CGRectGetWidth(bar.titleLabel.frame);
    XCTAssertFalse(CGRectIntersectsRect(bar.rightButton.frame, bar.rightFirstButton.frame));
    XCTAssertGreaterThanOrEqual(CGRectGetWidth(bar.rightButton.frame), 44.0);
    host.navigationRightFirstBarHidden = YES;
    [bar layoutIfNeeded];
    XCTAssertGreaterThan(CGRectGetWidth(bar.titleLabel.frame), titleWidth);
}

- (void)testRTLButtonsRemainInsideCurrentViewport
{
    TMInterfaceLayoutDirection original = [TMNavigationConfig shareInstance].layoutDirection;
    [TMNavigationConfig shareInstance].layoutDirection = TMInterfaceLayoutDirectionRightToLeft;
    UIView *host = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 375, 750)];
    TMNavigationBarView *bar = [[TMNavigationBarView alloc] initWithFrame:CGRectZero];
    [host addSubview:bar];
    [bar layoutIfNeeded];
    XCTAssertEqualWithAccuracy(CGRectGetMinX(bar.rightButton.frame), 0, 0.01);
    XCTAssertEqualWithAccuracy(CGRectGetMaxX(bar.backButton.frame), 375, 0.01);
    XCTAssertFalse(CGRectIntersectsRect(bar.rightButton.frame, bar.rightFirstButton.frame));
    [TMNavigationConfig shareInstance].layoutDirection = original;
}

- (void)testHostedNavigationAvoidsCurrentSafeAreaAndReservedCameraRegion
{
    UIWindowScene *scene;
    for (UIScene *candidate in UIApplication.sharedApplication.connectedScenes) {
        if ([candidate isKindOfClass:UIWindowScene.class]) {
            scene = (UIWindowScene *)candidate;
            break;
        }
    }
    XCTAssertNotNil(scene);
    UIWindow *window = [[UIWindow alloc] initWithWindowScene:scene];
    UIViewController *host = [[UIViewController alloc] init];
    window.rootViewController = host;
    [window makeKeyAndVisible];
    host.additionalSafeAreaInsets = UIEdgeInsetsMake(20, 12, 0, 46);
    TMNavigationBarView *bar = [[TMNavigationBarView alloc] initWithFrame:CGRectZero];
    bar.leftButton.hidden = YES;
    [host.view addSubview:bar];
    [window layoutIfNeeded];
    [host.view layoutIfNeeded];
    [bar layoutIfNeeded];
    UIEdgeInsets insets = host.view.safeAreaInsets;
    XCTAssertGreaterThanOrEqual(insets.left, 12);
    XCTAssertGreaterThanOrEqual(insets.right, 46);
    XCTAssertEqualWithAccuracy(CGRectGetHeight(bar.frame), insets.top + 44, 0.01);
    XCTAssertGreaterThanOrEqual(CGRectGetMinX(bar.backButton.frame), insets.left);
    XCTAssertLessThanOrEqual(CGRectGetMaxX(bar.rightButton.frame), CGRectGetWidth(host.view.bounds) - insets.right);
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 270100
    if (@available(iOS 27.1, *)) {
        for (UIViewReservedRegion *region in [host.view reservedRegionsOfKind:UIViewReservedRegionKind.occlusionRegionKind]) {
            XCTAssertFalse(CGRectIntersectsRect(bar.rightButton.frame, region.frame));
            XCTAssertFalse(CGRectIntersectsRect(bar.backButton.frame, region.frame));
        }
    }
#endif
    window.hidden = YES;
}

- (void)testCustomTitleConstraintsFollowSharedTitleFrame
{
    UIView *host = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 375, 750)];
    TMNavigationBarView *bar = [[TMNavigationBarView alloc] initWithFrame:CGRectZero];
    [host addSubview:bar];
    UIView *background = [[UIView alloc] initWithFrame:bar.bounds];
    background.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [bar insertSubview:background atIndex:0];
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectZero];
    title.translatesAutoresizingMaskIntoConstraints = NO;
    [background addSubview:title];
    [NSLayoutConstraint activateConstraints:@[
        [title.leadingAnchor constraintEqualToAnchor:bar.titleLabel.leadingAnchor],
        [title.trailingAnchor constraintEqualToAnchor:bar.titleLabel.trailingAnchor],
        [title.topAnchor constraintEqualToAnchor:bar.titleLabel.topAnchor],
        [title.bottomAnchor constraintEqualToAnchor:bar.titleLabel.bottomAnchor],
    ]];
    for (NSNumber *width in @[@375, @951, @375]) {
        host.frame = CGRectMake(0, 0, width.doubleValue, 750);
        [bar setNeedsLayout];
        [bar layoutIfNeeded];
        XCTAssertTrue(CGRectEqualToRect([title convertRect:title.bounds toView:bar], bar.titleLabel.frame));
    }
}

@end

