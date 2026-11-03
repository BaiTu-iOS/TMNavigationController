//
//  TMSystemLayoutNavigationController.h
//  Created by xuedanwu on 2026/11/02.
//

#import <TMNavigationController/TMNavigationController.h>

/// 单元测试只替换布局输入，按钮映射和 UIKit 显隐仍运行真实实现。
@interface TMSystemLayoutNavigationController : TMNavigationController

/// 测试当前处于系统竖栏布局。
@property(nonatomic) BOOL systemLayout;

@end
