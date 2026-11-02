//
//  TMNavigationConfig.m
//  TMNavigationController
//
//  Created by TianMing on 2022/11/29.
//  Copyright © 2022 TianMing. All rights reserved.
//

#import "TMNavigationConfig.h"

@implementation TMNavigationConfig

+ (UIEdgeInsets)tm_safeAreaInsets
{
    // 开合及场景尺寸变化后必须重新读取，不能缓存首次窗口的安全区。
    return [self tm_getKeyWindow].safeAreaInsets;
}

+ (UIWindow *)tm_getKeyWindow {
    UIWindow *keyWindow;
    if ([[UIApplication sharedApplication].delegate respondsToSelector:@selector(window)]) {
        keyWindow = [[UIApplication sharedApplication].delegate performSelector:@selector(window)];
    }
    if (keyWindow) return keyWindow;

    if (@available(iOS 13.0, *)) {

        for (UIWindow * window in UIApplication.sharedApplication.windows) {
            if ([window isKindOfClass:UIWindow.class]) {
                if (window.isKeyWindow == YES) {
                    keyWindow = window;
                    break;
                }
            }
        }

        if (keyWindow) {
            // 非UIScene模式
            return keyWindow;
        } else {
            // 遍历所有已连接的 scene
            keyWindow = [TMNavigationConfig tm_sceneKeyWindow];
            if (keyWindow) {
                return keyWindow;
            }
        }
        return UIApplication.sharedApplication.windows.firstObject;
    } else {
        return UIApplication.sharedApplication.keyWindow;
    }
}

+ (nullable UIWindow *)tm_sceneKeyWindow {
    UIWindow *keyWindow = nil;
    if (@available(iOS 13.0, *)) {
        // 遍历所有已连接的 scene
        for (UIWindowScene *scene in UIApplication.sharedApplication.connectedScenes) {
            if (scene.activationState == UISceneActivationStateForegroundActive) {
                for (UIWindow *window in scene.windows) {
                    if (window.isKeyWindow) {
                        keyWindow = window;
                        break;
                    }
                }
            }
            if (keyWindow) break;
        }
    }
    return keyWindow;
}

static TMNavigationConfig *_service = nil;

+ (instancetype)shareInstance {
    static dispatch_once_t once_token;
    dispatch_once(&once_token, ^{
        if (_service == nil) {
            _service = [[super allocWithZone:NULL] init];
        }
    });
    return _service;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    return [TMNavigationConfig shareInstance];
}

- (id)init {
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (BOOL)getIsRTL {
    TMInterfaceLayoutDirection hasRTL = [TMNavigationConfig shareInstance].layoutDirection;
    if (hasRTL) {
        if (hasRTL == TMInterfaceLayoutDirectionRightToLeft) {
            return YES;
        }
        return NO;
    }
    return [UIApplication sharedApplication].userInterfaceLayoutDirection;
}


@end
