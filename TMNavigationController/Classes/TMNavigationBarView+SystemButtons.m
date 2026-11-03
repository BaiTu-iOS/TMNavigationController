//
//  TMNavigationBarView+SystemButtons.m
//  Created by xuedanwu on 2026/11/02.
//

#import "TMNavigationBarView+SystemButtons.h"
#import "TMNavigationButton.h"

@interface TMNavigationBarView (SystemButtonsPrivate)

- (NSArray<TMNavigationButton *> *)tm_buttons;

@end

@implementation TMNavigationBarView (SystemButtons)

@dynamic tm_owner, tm_systemButtonsActive, tm_originalHidesBackButton, tm_presentationChanged;

- (void)tm_bindToViewController:(UIViewController *)controller
{
    self.tm_owner = controller;
    __weak typeof(self) weakSelf = self;
    for (TMNavigationButton *button in [self tm_buttons]) {
        button.tm_stateChanged = ^{
            [weakSelf setNeedsLayout];
            [weakSelf tm_refreshSystemButtons];
        };
    }
}

- (NSArray<TMNavigationButton *> *)tm_buttons
{
    return [NSArray arrayWithObjects:self.backButton, self.leftButton, self.rightButton, self.rightFirstButton, nil];
}

- (void)tm_applySystemButtons:(BOOL)active
{
    if (active != self.tm_systemButtonsActive) {
        if (active) self.tm_originalHidesBackButton = self.tm_owner.navigationItem.hidesBackButton;
        self.tm_systemButtonsActive = active;
        for (TMNavigationButton *button in [self tm_buttons]) button.tm_systemPresentationActive = active;
        [self.tm_owner.navigationItem setHidesBackButton:active ? YES : self.tm_originalHidesBackButton animated:NO];
    }
    [self tm_refreshSystemButtons];
}

- (void)tm_refreshSystemButtons
{
    if (!self.tm_owner) return;
    NSArray<TMNavigationButton *> *buttons = [self tm_buttons];
    NSMutableArray<UIBarButtonItem *> *leading = [NSMutableArray array];
    NSMutableArray<UIBarButtonItem *> *trailing = [NSMutableArray array];
    NSMutableArray<UIBarButtonItem *> *owned = [NSMutableArray array];
    for (TMNavigationButton *button in buttons) {
        UIBarButtonItem *item = self.tm_systemButtonsActive ? button.tm_systemItem : button.tm_existingSystemItem;
        // 未创建过映射的普通按钮没有需要清理的系统 item。
        if (!item) continue;
        [owned addObject:item];
        button.tm_containerAlpha = self.alpha;
        [button tm_synchronizeSystemItem];
        if (!self.tm_systemButtonsActive || self.hidden || button.hidden || button.alpha <= 0.01 || self.alpha <= 0.01) continue;
        [(button == self.backButton || button == self.leftButton) ? leading : trailing addObject:item];
    }
    UINavigationItem *navigationItem = self.tm_owner.navigationItem;
    for (UIBarButtonItem *item in navigationItem.leftBarButtonItems) {
        if (![owned containsObject:item]) [leading addObject:item];
    }
    for (UIBarButtonItem *item in navigationItem.rightBarButtonItems) {
        if (![owned containsObject:item]) [trailing addObject:item];
    }
    if (![navigationItem.leftBarButtonItems isEqualToArray:leading] && (leading.count || navigationItem.leftBarButtonItems.count)) {
        navigationItem.leftBarButtonItems = leading;
    }
    if (![navigationItem.rightBarButtonItems isEqualToArray:trailing] && (trailing.count || navigationItem.rightBarButtonItems.count)) {
        navigationItem.rightBarButtonItems = trailing;
    }
}

@end
