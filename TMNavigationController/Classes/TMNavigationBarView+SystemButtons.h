//
//  TMNavigationBarView+SystemButtons.h
//  Created by xuedanwu on 2026/11/02.
//

#import "TMNavigationBarView.h"

NS_ASSUME_NONNULL_BEGIN

/// 系统栏映射的组件内部入口，不属于业务 API。
@interface TMNavigationBarView (SystemButtons)

/// 原导航栏所属页面；弱引用避免页面与按钮映射互相持有。
@property(nonatomic, weak, nullable) UIViewController *tm_owner;

/// 当前是否由系统栏展示标准按钮。
@property(nonatomic) BOOL tm_systemButtonsActive;

/// 接管前的系统默认返回按钮策略。
@property(nonatomic) BOOL tm_originalHidesBackButton;

/// 整栏显隐变化后通知导航控制器重新布局。
@property(nonatomic, copy, nullable) void (^tm_presentationChanged)(void);

/// 绑定现有页面，不替换业务按钮。
- (void)tm_bindToViewController:(UIViewController *)controller;

/// 进入或退出系统按钮展示。
- (void)tm_applySystemButtons:(BOOL)active;

/// 同步当前页面的标准按钮，保留非组件 items。
- (void)tm_refreshSystemButtons;

@end

NS_ASSUME_NONNULL_END
