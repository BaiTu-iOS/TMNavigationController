//
//  TMNavigationControllerTitlePresentationTests.m
//  Created by xuedanwu on 2026/11/04.
//

@import XCTest;
#import "TMSystemLayoutNavigationController.h"

@interface TMNavigationControllerTitlePresentationTests : XCTestCase

@property(nonatomic, strong) UIViewController *page;
@property(nonatomic, strong) TMSystemLayoutNavigationController *navigation;
@property(nonatomic, strong) UIWindow *window;

- (void)applySystemLayout:(BOOL)system;
- (NSUInteger)visibleCustomTitlePixels;

@end

@implementation TMNavigationControllerTitlePresentationTests

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
    _page.title = @"新关注者";
    _navigation = [[TMSystemLayoutNavigationController alloc] initWithRootViewController:_page];
    _window = [[UIWindow alloc] initWithWindowScene:scene];
    _window.rootViewController = _navigation;
    [_window makeKeyAndVisible];
    [_window layoutIfNeeded];
    [self applySystemLayout:NO];
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

- (NSUInteger)visibleCustomTitlePixels
{
    UILabel *label = _page.navigationBar.titleLabel;
    size_t width = (size_t)CGRectGetWidth(label.bounds);
    size_t height = (size_t)CGRectGetHeight(label.bounds);
    unsigned char *pixels = calloc(width * height, 4);
    CGColorSpaceRef colors = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(pixels, width, height, 8, width * 4, colors, (CGBitmapInfo)kCGImageAlphaPremultipliedLast);
    [label.layer renderInContext:context];
    NSUInteger visible = 0;
    for (size_t index = 0; index < width * height; index++) {
        if (pixels[index * 4 + 3]) visible++;
    }
    CGContextRelease(context);
    CGColorSpaceRelease(colors);
    free(pixels);
    return visible;
}

- (void)testSystemModeShowsOnlyNativeTitleAndRestoresCustomTitle
{
    UILabel *title = _page.navigationBar.titleLabel;
    XCTAssertGreaterThan([self visibleCustomTitlePixels], 0);
    XCTAssertTrue(_navigation.isNavigationBarHidden);
    for (NSUInteger index = 0; index < 3; index++) {
        [self applySystemLayout:YES];
        XCTAssertFalse(_navigation.isNavigationBarHidden);
        XCTAssertNotNil(_navigation.navigationBar.window);
        XCTAssertEqualObjects(_navigation.navigationBar.topItem.title, @"新关注者");
        XCTAssertEqual([self visibleCustomTitlePixels], 0);
        XCTAssertTrue(title.accessibilityElementsHidden);
        [self applySystemLayout:NO];
        XCTAssertTrue(_navigation.isNavigationBarHidden);
        XCTAssertGreaterThan([self visibleCustomTitlePixels], 0);
        XCTAssertFalse(title.accessibilityElementsHidden);
    }
    XCTAssertEqual(title, _page.navigationBar.titleLabel);
    XCTAssertEqualObjects(title.text, @"新关注者");
}

- (void)testDirectTitleChangesStayVisibleInSystemModeAndRestoreLatestText
{
    _page.navigationBar.title = @"创建好友群";
    [self applySystemLayout:YES];
    XCTAssertEqualObjects(_navigation.navigationBar.topItem.title, @"创建好友群");
    _page.navigationBar.title = @"已选择";
    XCTAssertEqualObjects(_navigation.navigationBar.topItem.title, @"已选择");
    XCTAssertEqual([self visibleCustomTitlePixels], 0);
    _page.navigationBar.title = nil;
    XCTAssertNil(_navigation.navigationBar.topItem.title);
    XCTAssertEqualObjects(_page.navigationBar.titleLabel.text, @"");
    _page.navigationBar.title = @"更新标题";
    XCTAssertEqualObjects(_navigation.navigationBar.topItem.title, @"更新标题");
    [self applySystemLayout:NO];
    XCTAssertEqualObjects(_page.navigationBar.titleLabel.text, @"更新标题");
    XCTAssertGreaterThan([self visibleCustomTitlePixels], 0);
}

- (void)testBusinessTitleVisibilitySurvivesSystemModeChanges
{
    UILabel *title = _page.navigationBar.titleLabel;
    title.hidden = YES;
    title.alpha = 0.6;
    [self applySystemLayout:YES];
    XCTAssertTrue(title.hidden);
    [self applySystemLayout:NO];
    XCTAssertTrue(title.hidden);
    [self applySystemLayout:YES];
    // 模拟视频详情在系统模式内滚动，业务继续更新标题显隐。
    title.hidden = NO;
    title.alpha = 0.4;
    XCTAssertEqual([self visibleCustomTitlePixels], 0);
    [self applySystemLayout:NO];
    XCTAssertFalse(title.hidden);
    XCTAssertEqualWithAccuracy(title.alpha, 0.4, 0.001);
    XCTAssertGreaterThan([self visibleCustomTitlePixels], 0);
}

- (void)testWholeBarVisibilityAndStackRemovalKeepTitlePresentationConsistent
{
    [self applySystemLayout:YES];
    _page.navigationBarHidden = YES;
    [_navigation.view layoutIfNeeded];
    XCTAssertTrue(_navigation.isNavigationBarHidden);
    XCTAssertTrue(_page.navigationBar.hidden);
    _page.navigationBarHidden = NO;
    [_navigation.view layoutIfNeeded];
    XCTAssertFalse(_navigation.isNavigationBarHidden);
    XCTAssertEqual([self visibleCustomTitlePixels], 0);
    UIViewController *next = [[UIViewController alloc] init];
    next.title = @"下一页";
    [_navigation pushViewController:next animated:NO];
    [_navigation.view layoutIfNeeded];
    XCTAssertTrue(next.navigationBar.titleLabel.accessibilityElementsHidden);
    [_navigation popViewControllerAnimated:NO];
    [_navigation.view layoutIfNeeded];
    XCTAssertNil(next.navigationBar.titleLabel.layer.mask);
    XCTAssertFalse(next.navigationBar.titleLabel.accessibilityElementsHidden);
    XCTAssertEqualObjects(next.navigationBar.titleLabel.text, @"下一页");
    XCTAssertEqualObjects(_navigation.navigationBar.topItem.title, @"新关注者");
    XCTAssertEqual([self visibleCustomTitlePixels], 0);
}

@end
