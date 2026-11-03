//
//  TMSceneDelegate.h
//  Created by xuedanwu on 2026/11/02.
//

#import <UIKit/UIKit.h>

/// Example 的 Scene 窗口由 storyboard 创建，用于验证系统竖栏。
@interface TMSceneDelegate : UIResponder <UIWindowSceneDelegate>

/// 持有当前 Scene 的测试窗口。
@property(nonatomic, strong) UIWindow *window;

@end
