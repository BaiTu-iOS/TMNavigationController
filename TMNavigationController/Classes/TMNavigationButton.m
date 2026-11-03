//
//  TMNavigationButton.m
//  Created by xuedanwu on 2026/11/02.
//

#import "TMNavigationButton.h"

@interface TMNavigationButton ()

/// 系统栏使用独立视图，原按钮始终保留在业务约束中。
@property(nonatomic, strong) UIButton *tm_displayButton;

/// 当前按钮拥有的唯一系统 item。
@property(nonatomic, strong) UIBarButtonItem *tm_cachedItem;

/// 系统模式期间暂存原图层遮罩。
@property(nonatomic, strong) CALayer *tm_originalMask;

/// 透明遮罩只抑制绘制，不影响 UIView 的 hidden/alpha 和 Auto Layout。
@property(nonatomic, strong) CALayer *tm_suppressionMask;

/// 只同步业务显式设置的文案；默认文案由显示按钮按其标题和图片生成。
@property(nonatomic, copy) NSString *tm_explicitAccessibilityLabel;

- (void)tm_stateDidChange;
- (void)tm_activateOriginalButton;

@end

@implementation TMNavigationButton

- (UIBarButtonItem *)tm_systemItem
{
    if (!_tm_cachedItem) {
        _tm_containerAlpha = 1;
        _tm_displayButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_tm_displayButton addTarget:self action:@selector(tm_activateOriginalButton) forControlEvents:UIControlEventTouchUpInside];
        _tm_cachedItem = [[UIBarButtonItem alloc] initWithCustomView:_tm_displayButton];
        // 竖栏使用系统按钮展示时由 item 分发事件，继续转发给原业务按钮。
        _tm_cachedItem.target = self;
        _tm_cachedItem.action = @selector(tm_activateOriginalButton);
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 270100
        if (@available(iOS 27.1, *)) {
            _tm_cachedItem.axisBehavior = UIBarButtonItemAxisBehaviorVerticalPreferred;
        }
#endif
        [self tm_synchronizeSystemItem];
    }
    return _tm_cachedItem;
}

- (UIBarButtonItem *)tm_existingSystemItem
{
    return _tm_cachedItem;
}

- (void)setTm_systemPresentationActive:(BOOL)active
{
    if (_tm_systemPresentationActive == active) return;
    _tm_systemPresentationActive = active;
    if (active) {
        _tm_originalMask = self.layer.mask;
        _tm_suppressionMask = [CALayer layer];
        self.layer.mask = _tm_suppressionMask;
    } else {
        self.layer.mask = _tm_originalMask;
        _tm_originalMask = nil;
        _tm_suppressionMask = nil;
    }
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    if (_tm_systemPresentationActive) return nil;
    return [super hitTest:point withEvent:event];
}

- (BOOL)isAccessibilityElement
{
    return !_tm_systemPresentationActive && [super isAccessibilityElement];
}

- (BOOL)accessibilityElementsHidden
{
    return _tm_systemPresentationActive || [super accessibilityElementsHidden];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    // titleLabel.font 等嵌套属性在原按钮正常布局后同步；遮罩不停止布局。
    [self tm_synchronizeSystemItem];
}

- (void)tm_activateOriginalButton
{
    // 系统点击仍从原 UIControl 发出，保留业务 target/action、sender 和节流。
    if (!self.enabled || !self.userInteractionEnabled || self.hidden || self.alpha <= 0.01) return;
    [self sendActionsForControlEvents:UIControlEventTouchUpInside];
    [self tm_stateDidChange];
}

- (void)tm_stateDidChange
{
    [self setNeedsLayout];
    [self tm_synchronizeSystemItem];
    if (_tm_stateChanged) _tm_stateChanged();
}

- (void)tm_synchronizeSystemItem
{
    // 普通设备未创建系统 item，不产生展示同步开销。
    if (!_tm_cachedItem) return;
    UIButton *display = _tm_displayButton;
    NSString *title = self.currentTitle;
    UIImage *image = self.currentImage;
    NSAttributedString *attributedTitle = self.currentAttributedTitle;
    if (display.currentTitle != title && ![display.currentTitle isEqual:title]) {
        [display setTitle:title forState:UIControlStateNormal];
    }
    if (display.currentImage != image) [display setImage:image forState:UIControlStateNormal];
    if (display.currentAttributedTitle != attributedTitle && ![display.currentAttributedTitle isEqual:attributedTitle]) {
        [display setAttributedTitle:attributedTitle forState:UIControlStateNormal];
    }
    if (![display.currentTitleColor isEqual:self.currentTitleColor]) {
        [display setTitleColor:self.currentTitleColor forState:UIControlStateNormal];
    }
    if (display.currentBackgroundImage != self.currentBackgroundImage) {
        [display setBackgroundImage:self.currentBackgroundImage forState:UIControlStateNormal];
    }
    if (![display.titleLabel.font isEqual:self.titleLabel.font]) display.titleLabel.font = self.titleLabel.font;
    display.titleLabel.numberOfLines = self.titleLabel.numberOfLines;
    display.titleLabel.adjustsFontSizeToFitWidth = self.titleLabel.adjustsFontSizeToFitWidth;
    display.titleLabel.minimumScaleFactor = self.titleLabel.minimumScaleFactor;
    display.titleLabel.textAlignment = self.titleLabel.textAlignment;
    display.titleLabel.lineBreakMode = self.titleLabel.lineBreakMode;
    display.enabled = self.enabled && self.userInteractionEnabled;
    display.alpha = self.alpha * _tm_containerAlpha;
    display.tintColor = self.tintColor;
    display.backgroundColor = self.backgroundColor;
    display.transform = self.transform;
    display.accessibilityHint = self.accessibilityHint;
    display.accessibilityValue = self.accessibilityValue;
    display.accessibilityIdentifier = self.accessibilityIdentifier;
    display.accessibilityTraits = self.accessibilityTraits;
    display.isAccessibilityElement = [super isAccessibilityElement];
    _tm_cachedItem.enabled = display.enabled;
    if (_tm_cachedItem.title != title && ![_tm_cachedItem.title isEqual:title]) _tm_cachedItem.title = title;
    if (_tm_cachedItem.image != image) _tm_cachedItem.image = image;
    // 不读取原控件自动生成的 AX 标签，避免系统关联对象反向持有原控件。
    _tm_cachedItem.accessibilityLabel = _tm_explicitAccessibilityLabel;
    display.accessibilityLabel = _tm_explicitAccessibilityLabel;
    CGSize size = CGSizeMake(MAX(44, CGRectGetWidth(self.bounds)), MAX(44, CGRectGetHeight(self.bounds)));
    if (!CGSizeEqualToSize(display.bounds.size, size)) display.bounds = (CGRect){CGPointZero, size};
}

- (void)setEnabled:(BOOL)enabled
{
    [super setEnabled:enabled];
    [self tm_stateDidChange];
}

- (void)setSelected:(BOOL)selected
{
    [super setSelected:selected];
    [self tm_stateDidChange];
}

- (void)setHidden:(BOOL)hidden
{
    [super setHidden:hidden];
    [self tm_stateDidChange];
}

- (void)setAlpha:(CGFloat)alpha
{
    [super setAlpha:alpha];
    [self tm_stateDidChange];
}

- (void)setUserInteractionEnabled:(BOOL)enabled
{
    [super setUserInteractionEnabled:enabled];
    [self tm_stateDidChange];
}

- (void)setTitle:(NSString *)title forState:(UIControlState)state
{
    [super setTitle:title forState:state];
    [self tm_stateDidChange];
}

- (void)setImage:(UIImage *)image forState:(UIControlState)state
{
    [super setImage:image forState:state];
    [self tm_stateDidChange];
}

- (void)setTitleColor:(UIColor *)color forState:(UIControlState)state
{
    [super setTitleColor:color forState:state];
    [self tm_stateDidChange];
}

- (void)setAttributedTitle:(NSAttributedString *)title forState:(UIControlState)state
{
    [super setAttributedTitle:title forState:state];
    [self tm_stateDidChange];
}

- (void)setAccessibilityLabel:(NSString *)accessibilityLabel
{
    [super setAccessibilityLabel:accessibilityLabel];
    self.tm_explicitAccessibilityLabel = accessibilityLabel;
    [self tm_stateDidChange];
}

@end
