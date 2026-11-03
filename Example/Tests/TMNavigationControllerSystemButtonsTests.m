//
//  TMNavigationControllerSystemButtonsTests.m
//  Created by xuedanwu on 2026/11/02.
//

@import XCTest;
#import "TMSystemLayoutNavigationController.h"

/// 验证业务原调用在两个展示模式下的契约。
@interface TMNavigationControllerSystemButtonsTests : XCTestCase

/// 每个测试持有自己的页面和导航栈。
@property(nonatomic, strong) UIViewController *page;
@property(nonatomic, strong) TMSystemLayoutNavigationController *navigation;

/// Scene 窗口使真实 UIKit 栏位与约束参与布局。
@property(nonatomic, strong) UIWindow *window;

- (void)applySystemLayout:(BOOL)system;
- (UIButton *)displayButton;
- (NSUInteger)visiblePixelsInButton:(UIButton *)button;

@end

@implementation TMNavigationControllerSystemButtonsTests

- (void)setUp
{
    [super setUp];
    UIWindowScene *scene;
    for (UIScene *candidate in UIApplication.sharedApplication.connectedScenes) {
        if ([candidate isKindOfClass:UIWindowScene.class]) {
            scene = (UIWindowScene *)candidate;
            break;
        }
    }
    XCTAssertNotNil(scene);
    _page = [[UIViewController alloc] init];
    _navigation = [[TMSystemLayoutNavigationController alloc] initWithRootViewController:_page];
    _window = [[UIWindow alloc] initWithWindowScene:scene];
    _window.rootViewController = _navigation;
    [_window makeKeyAndVisible];
    [_window layoutIfNeeded];
    _page.navigationRightBarHidden = NO;
    _page.navigationRightBarTitle = @"保存";
}

- (void)tearDown
{
    _window.hidden = YES;
    _window.rootViewController = nil;
    _window = nil;
    _page = nil;
    _navigation = nil;
    [super tearDown];
}

- (void)applySystemLayout:(BOOL)system
{
    _navigation.systemLayout = system;
    [_navigation.view setNeedsLayout];
    [_navigation.view layoutIfNeeded];
    [_page.navigationBar setNeedsLayout];
    [_page.navigationBar layoutIfNeeded];
}

- (UIButton *)displayButton
{
    return (UIButton *)_page.navigationItem.rightBarButtonItems.firstObject.customView;
}

- (void)testLegacySystemBarHideAndWholeBarVisibility
{
    [_navigation setNavigationBarHidden:YES animated:NO];
    [self applySystemLayout:YES];
    XCTAssertFalse(_navigation.isNavigationBarHidden);
    [_navigation setNavigationBarHidden:YES animated:NO];
    XCTAssertFalse(_navigation.isNavigationBarHidden);
    XCTAssertEqual(_page.navigationItem.rightBarButtonItems.count, 1);
    _page.navigationBarHidden = YES;
    [_navigation.view layoutIfNeeded];
    XCTAssertTrue(_navigation.isNavigationBarHidden);
    XCTAssertEqual(_page.navigationItem.rightBarButtonItems.count, 0);
    _page.navigationBarHidden = NO;
    [_navigation.view layoutIfNeeded];
    XCTAssertFalse(_navigation.isNavigationBarHidden);
    [self applySystemLayout:NO];
    XCTAssertTrue(_navigation.isNavigationBarHidden);
    XCTAssertEqual(_page.navigationItem.rightBarButtonItems.count, 0);
}

- (void)testOriginalButtonKeepsStateConstraintsAndRendering
{
    UIButton *source = _page.navigationBar.rightButton;
    source.backgroundColor = UIColor.redColor;
    source.alpha = 0.6;
    source.translatesAutoresizingMaskIntoConstraints = NO;
    [NSLayoutConstraint activateConstraints:@[
        [source.leadingAnchor constraintEqualToAnchor:_page.navigationBar.leadingAnchor constant:24],
        [source.topAnchor constraintEqualToAnchor:_page.navigationBar.topAnchor constant:12],
        [source.widthAnchor constraintEqualToConstant:72],
        [source.heightAnchor constraintEqualToConstant:44],
    ]];
    UILabel *peer = [[UILabel alloc] init];
    peer.translatesAutoresizingMaskIntoConstraints = NO;
    [_page.navigationBar addSubview:peer];
    [NSLayoutConstraint activateConstraints:@[
        [peer.leadingAnchor constraintEqualToAnchor:source.trailingAnchor constant:8],
        [peer.topAnchor constraintEqualToAnchor:source.topAnchor],
        [peer.widthAnchor constraintEqualToConstant:20],
        [peer.heightAnchor constraintEqualToConstant:20],
    ]];
    [self applySystemLayout:NO];
    CGRect originalFrame = source.frame;
    NSUInteger pixels = [self visiblePixelsInButton:source];
    XCTAssertGreaterThan(pixels, 0);
    [self applySystemLayout:YES];
    XCTAssertEqual(source, _page.navigationBar.rightButton);
    XCTAssertEqual(source.superview, _page.navigationBar);
    XCTAssertTrue(CGRectEqualToRect(source.frame, originalFrame));
    XCTAssertEqualWithAccuracy(CGRectGetMinX(peer.frame), CGRectGetMaxX(source.frame) + 8, 0.01);
    XCTAssertFalse(source.hidden);
    XCTAssertEqualWithAccuracy(source.alpha, 0.6, 0.001);
    XCTAssertEqual([self visiblePixelsInButton:source], 0);
    XCTAssertNil([source hitTest:CGPointMake(20, 20) withEvent:nil]);
    XCTAssertFalse(source.isAccessibilityElement);
    [self applySystemLayout:NO];
    XCTAssertNil(source.layer.mask);
    XCTAssertEqual([self visiblePixelsInButton:source], pixels);
    XCTAssertNotNil([source hitTest:CGPointMake(20, 20) withEvent:nil]);
}

- (NSUInteger)visiblePixelsInButton:(UIButton *)button
{
    size_t width = (size_t)CGRectGetWidth(button.bounds);
    size_t height = (size_t)CGRectGetHeight(button.bounds);
    unsigned char *pixels = calloc(width * height, 4);
    CGColorSpaceRef colors = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(pixels, width, height, 8, width * 4, colors, (CGBitmapInfo)kCGImageAlphaPremultipliedLast);
    [button.layer renderInContext:context];
    NSUInteger visible = 0;
    for (size_t index = 0; index < width * height; index++) {
        if (pixels[index * 4 + 3]) visible++;
    }
    CGContextRelease(context);
    CGColorSpaceRelease(colors);
    free(pixels);
    return visible;
}

- (void)testDirectButtonChangesAndLatestHiddenStateSurviveSwitching
{
    UIButton *source = _page.navigationBar.rightButton;
    [self applySystemLayout:YES];
    source.enabled = NO;
    XCTAssertFalse(self.displayButton.enabled);
    source.enabled = YES;
    source.userInteractionEnabled = NO;
    XCTAssertFalse(self.displayButton.enabled);
    source.userInteractionEnabled = YES;
    XCTAssertTrue(self.displayButton.enabled);
    source.hidden = YES;
    XCTAssertEqual(_page.navigationItem.rightBarButtonItems.count, 0);
    [self applySystemLayout:NO];
    XCTAssertTrue(source.hidden);
    source.hidden = NO;
    [self applySystemLayout:YES];
    XCTAssertEqual(_page.navigationItem.rightBarButtonItems.count, 1);
    _page.navigationBar.alpha = 0.5;
    XCTAssertEqualWithAccuracy(self.displayButton.alpha, 0.5, 0.001);
}

- (void)testMultilineFontAndSelectedDisabledContent
{
    UIButton *source = _page.navigationBar.rightButton;
    [source setTitle:@"保存\n资料" forState:UIControlStateNormal];
    [source setTitle:@"已选择" forState:UIControlStateSelected];
    [source setTitleColor:UIColor.redColor forState:UIControlStateDisabled];
    source.titleLabel.font = [UIFont boldSystemFontOfSize:14];
    source.titleLabel.numberOfLines = 2;
    [self applySystemLayout:YES];
    XCTAssertEqualObjects(self.displayButton.currentTitle, source.currentTitle);
    XCTAssertEqualObjects(self.displayButton.titleLabel.font, source.titleLabel.font);
    XCTAssertEqual(self.displayButton.titleLabel.numberOfLines, 2);
    source.selected = YES;
    XCTAssertEqualObjects(self.displayButton.currentTitle, @"已选择");
    source.enabled = NO;
    XCTAssertEqualObjects(self.displayButton.currentTitleColor, source.currentTitleColor);
    XCTAssertFalse(self.displayButton.enabled);
}

- (void)testClickUsesOriginalSenderOnceAndUpdatesSelection
{
    UIButton *source = _page.navigationBar.rightButton;
    __block NSUInteger calls = 0;
    __block UIButton *received;
    [_page navigationRightButtonClickBlock:^(UIButton *button) {
        calls++;
        received = button;
        button.selected = !button.selected;
        [button setTitle:@"完成" forState:UIControlStateNormal];
    }];
    [self applySystemLayout:YES];
    [self.displayButton sendActionsForControlEvents:UIControlEventTouchUpInside];
    XCTAssertEqual(calls, 1);
    XCTAssertEqual(received, source);
    XCTAssertTrue(source.selected);
    XCTAssertEqualObjects(self.displayButton.currentTitle, @"完成");
}

- (void)testImageReplacementDoesNotRestoreOldTitle
{
    [self applySystemLayout:YES];
    UIImage *image = [UIImage systemImageNamed:@"square.and.arrow.up"];
    _page.navigationRightBarImage = image;
    XCTAssertNil(_page.navigationBar.rightButton.currentTitle);
    XCTAssertNil(self.displayButton.currentTitle);
    XCTAssertEqualObjects(self.displayButton.currentImage, image);
}

- (void)testSystemItemClickUsesOriginalSenderOnce
{
    UIButton *source = _page.navigationBar.rightButton;
    __block NSUInteger calls = 0;
    __block UIButton *received;
    [_page navigationRightButtonClickBlock:^(UIButton *button) {
        calls++;
        received = button;
        button.selected = YES;
    }];
    [self applySystemLayout:YES];
    UIBarButtonItem *item = _page.navigationItem.rightBarButtonItems.firstObject;
    BOOL delivered = item.action && [UIApplication.sharedApplication sendAction:item.action to:item.target from:item forEvent:nil];
    XCTAssertTrue(delivered);
    XCTAssertEqual(calls, 1);
    XCTAssertEqual(received, source);
    XCTAssertTrue(source.selected);
}

- (void)testSystemBackItemPopsCurrentPage
{
    [self applySystemLayout:YES];
    UIViewController *next = [[UIViewController alloc] init];
    [_navigation pushViewController:next animated:NO];
    [_navigation.view layoutIfNeeded];
    UIBarButtonItem *item = next.navigationItem.leftBarButtonItems.firstObject;
    XCTAssertNotNil(item);
    BOOL delivered = item.action && [UIApplication.sharedApplication sendAction:item.action to:item.target from:item forEvent:nil];
    XCTAssertTrue(delivered);
    XCTAssertEqual(_navigation.topViewController, _page);
    XCTAssertEqual(_navigation.viewControllers.count, 1);
}

- (void)testRepeatedSwitchKeepsForeignItemsAndOriginalBusinessHidden
{
    UIBarButtonItem *foreign = [[UIBarButtonItem alloc] initWithTitle:@"其他" style:UIBarButtonItemStylePlain target:nil action:nil];
    _page.navigationItem.rightBarButtonItem = foreign;
    for (NSUInteger index = 0; index < 4; index++) {
        [self applySystemLayout:YES];
        XCTAssertEqual(_page.navigationItem.rightBarButtonItems.count, 2);
        [self applySystemLayout:NO];
        XCTAssertEqualObjects(_page.navigationItem.rightBarButtonItems, @[foreign]);
    }
    XCTAssertFalse(_page.navigationBar.rightButton.hidden);
}

- (void)testPushThenReplaceStackDoesNotLeaveOldButtonSuppressed
{
    [self applySystemLayout:YES];
    UIViewController *next = [[UIViewController alloc] init];
    [_navigation pushViewController:next animated:NO];
    next.navigationRightBarHidden = NO;
    next.navigationRightBarTitle = @"下一页";
    [_navigation.view layoutIfNeeded];
    XCTAssertEqual(next.navigationItem.leftBarButtonItems.count, 1);
    [_navigation setViewControllers:@[_page] animated:NO];
    [_navigation.view layoutIfNeeded];
    XCTAssertNil(next.navigationBar.rightButton.layer.mask);
    XCTAssertEqual(next.navigationItem.rightBarButtonItems.count, 0);
    XCTAssertEqual(_page.navigationItem.rightBarButtonItems.count, 1);
}

- (void)testReplacingStackLoadsOnlyTopAndAttachesItsNavigationBar
{
    for (NSNumber *system in @[@NO, @YES]) {
        [self applySystemLayout:system.boolValue];
        UIViewController *history = [[UIViewController alloc] init];
        UIViewController *top = [[UIViewController alloc] init];
        XCTAssertFalse(history.isViewLoaded);
        XCTAssertFalse(top.isViewLoaded);
        [_navigation setViewControllers:@[history, top] animated:NO];
        XCTAssertEqual(_navigation.topViewController, top);
        XCTAssertTrue(top.isViewLoaded);
        XCTAssertNotNil(top.navigationBar);
        XCTAssertEqual(top.navigationBar.superview, top.viewIfLoaded);
        XCTAssertFalse(history.isViewLoaded);
        _page = top;
    }
}

- (void)testPoppedPageReleasesItsSystemButtonAndItem
{
    [self applySystemLayout:YES];
    __weak UIViewController *releasedPage;
    __weak TMNavigationBarView *releasedBar;
    __weak UIButton *releasedButton;
    __weak UIBarButtonItem *releasedItem;
    @autoreleasepool {
        UIViewController *next = [[UIViewController alloc] init];
        [_navigation pushViewController:next animated:NO];
        [_navigation.view layoutIfNeeded];
        releasedPage = next;
        releasedBar = next.navigationBar;
        releasedButton = next.navigationBar.backButton;
        releasedItem = next.navigationItem.leftBarButtonItem;
        XCTAssertTrue(releasedItem != nil);
        [_navigation popViewControllerAnimated:NO];
        [_navigation.view layoutIfNeeded];
    }
    NSPredicate *released = [NSPredicate predicateWithBlock:^BOOL(id object, NSDictionary *bindings) {
        @autoreleasepool {
            return !releasedPage && !releasedBar && !releasedButton;
        }
    }];
    [self expectationForPredicate:released evaluatedWithObject:NSNull.null handler:nil];
    [self waitForExpectationsWithTimeout:3 handler:nil];
    XCTAssertNil(releasedPage);
    XCTAssertNil(releasedBar);
    XCTAssertNil(releasedButton);
    @autoreleasepool {
        _window.rootViewController = nil;
        _navigation = nil;
        _page = nil;
    }
    NSPredicate *itemReleased = [NSPredicate predicateWithBlock:^BOOL(id object, NSDictionary *bindings) {
        @autoreleasepool {
            return !releasedItem;
        }
    }];
    [self expectationForPredicate:itemReleased evaluatedWithObject:NSNull.null handler:nil];
    [self waitForExpectationsWithTimeout:3 handler:nil];
    XCTAssertNil(releasedItem);
}

- (void)testSystemItemClickDoesNotKeepPoppedButtonAlive
{
    [self applySystemLayout:YES];
    __weak UIViewController *releasedPage;
    __weak UIButton *releasedButton;
    @autoreleasepool {
        UIViewController *next = [[UIViewController alloc] init];
        [_navigation pushViewController:next animated:NO];
        [_navigation.view layoutIfNeeded];
        releasedPage = next;
        releasedButton = next.navigationBar.backButton;
        UIBarButtonItem *item = next.navigationItem.leftBarButtonItem;
        XCTAssertNotNil(item);
        XCTAssertTrue([UIApplication.sharedApplication sendAction:item.action to:item.target from:item forEvent:nil]);
    }
    NSPredicate *released = [NSPredicate predicateWithBlock:^BOOL(id object, NSDictionary *bindings) {
        @autoreleasepool {
            return !releasedPage && !releasedButton;
        }
    }];
    [self expectationForPredicate:released evaluatedWithObject:NSNull.null handler:nil];
    [self waitForExpectationsWithTimeout:3 handler:nil];
    XCTAssertNil(releasedPage);
    XCTAssertNil(releasedButton);
}

- (void)testExplicitAccessibilityLabelUpdatesSystemButton
{
    UIButton *source = _page.navigationBar.rightButton;
    source.accessibilityLabel = @"保存资料";
    [self applySystemLayout:YES];
    XCTAssertEqualObjects(self.displayButton.accessibilityLabel, @"保存资料");
    source.accessibilityLabel = @"确认保存";
    XCTAssertEqualObjects(self.displayButton.accessibilityLabel, @"确认保存");
    XCTAssertEqualObjects(_page.navigationItem.rightBarButtonItem.accessibilityLabel, @"确认保存");
    [self applySystemLayout:NO];
    XCTAssertEqualObjects(source.accessibilityLabel, @"确认保存");
}

@end
