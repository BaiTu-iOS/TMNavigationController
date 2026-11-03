//
//  TMNavigationButton.h
//  Created by xuedanwu on 2026/11/02.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/// 原业务按钮及其系统栏展示；仅供组件内部使用。
@interface TMNavigationButton : UIButton

/// 控件状态变化后通知所属导航栏更新系统 items。
@property(nonatomic, copy, nullable) void (^tm_stateChanged)(void);

/// 仅屏蔽原按钮的显示和交互，不修改业务属性。
@property(nonatomic) BOOL tm_systemPresentationActive;

/// 自定义导航栏的透明度，合并到系统展示。
@property(nonatomic) CGFloat tm_containerAlpha;

/// 系统栏展示对象，首次使用时创建。
@property(nonatomic, readonly) UIBarButtonItem *tm_systemItem;

/// 已创建的系统 item；普通模式不会因查询而创建。
@property(nonatomic, readonly, nullable) UIBarButtonItem *tm_existingSystemItem;

/// 更新按钮状态、文字样式及可访问性信息。
- (void)tm_synchronizeSystemItem;

@end

NS_ASSUME_NONNULL_END
