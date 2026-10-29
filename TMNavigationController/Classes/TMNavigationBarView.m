//
//  TMNavigationBarView.m
//  TMNavigationController
//
//  Created by TianMing on 2018/8/27.
//  Copyright © 2018年 TianMing. All rights reserved.
//

#import "TMNavigationBarView.h"
#import "TMMacro.h"

@interface TMNavigationBarView()

- (void)layoutButtonsInContentFrame:(CGRect)frame;
- (CGRect)frame:(CGRect)frame avoidingRegionsOfKind:(UIViewReservedRegionKind *)kind inView:(UIView *)view API_AVAILABLE(ios(27.1));

@end

@implementation TMNavigationBarView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, TM_TopBarHeight)];
    if (self) {
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
        [self configView];
        if (@available(iOS 27.1, *)) {
            __weak typeof(self) weakSelf = self;
            UIHingeInteraction *interaction = [[UIHingeInteraction alloc] initWithUpdateHandler:^(__unused UIHingeInteraction *sender, __unused UIHingeInteractionUpdate *update) {
                [weakSelf setNeedsLayout];
            }];
            [self addInteraction:interaction];
        }
    }
    return self;
}
- (void)configView {
    CAGradientLayer * gradientLayer = [CAGradientLayer layer];
    gradientLayer.startPoint = CGPointMake(0, 0);
    gradientLayer.endPoint = CGPointMake(1, 1);
    gradientLayer.frame = self.frame;
    [self.layer addSublayer:gradientLayer];
    self.gradientLayer = gradientLayer;
    
    _backgroundImageView = [[UIImageView alloc]initWithFrame:self.bounds];
    [self addSubview:_backgroundImageView];
    
    _lineView = [[UIView alloc]initWithFrame:CGRectMake(0,self.bounds.size.height-0.5,self.bounds.size.width,0.5)];
    _lineView.backgroundColor = [[UIColor grayColor] colorWithAlphaComponent:0.2];
    [self addSubview:_lineView];
    
    _titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(90, TM_StatusBarHeight, SCREEN_WIDTH - 90*2, ButtonViewHeight)];
    _titleLabel.text = self.title;
    _titleLabel.textAlignment = NSTextAlignmentCenter;
    _titleLabel.textColor = UIColorFromRGB(0x27313e);
    _titleLabel.font = [UIFont boldSystemFontOfSize:18.5];
    [self addSubview:_titleLabel];
    
    _backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _backButton.adjustsImageWhenHighlighted = NO;
    [_backButton addTarget:self action:@selector(backLastView:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_backButton];
    
    UIImage *backImage = [UIImage imageNamed:@"tm_back"];
    if ([TMNavigationConfig shareInstance].backButtonImage) {
        backImage = [TMNavigationConfig shareInstance].backButtonImage;
    }
    if (kIsRTL) {
        [_backButton setImage:backImage forState:UIControlStateNormal];
        _backButton.transform = CGAffineTransformMakeScale(-1 ,1);
        _backButton.frame = CGRectMake(SCREEN_WIDTH - 55, TM_StatusBarHeight, 55, ButtonViewHeight);
    }else {
        [_backButton setImage:backImage forState:UIControlStateNormal];
        _backButton.frame = CGRectMake(0, TM_StatusBarHeight, 55, ButtonViewHeight);
    }
    
    _leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _leftButton.adjustsImageWhenHighlighted = NO;
    [_leftButton setTitle:@"关闭" forState:UIControlStateNormal];
    _leftButton.titleLabel.font = [UIFont systemFontOfSize:16];
    if (kIsRTL) {
        _leftButton.frame = CGRectMake(50, TM_StatusBarHeight, 50, ButtonViewHeight);
    }else {
        _leftButton.frame = CGRectMake(50, TM_StatusBarHeight, 50, ButtonViewHeight);
    }
    [_leftButton addTarget:self action:@selector(closeAction:) forControlEvents:UIControlEventTouchUpInside];
    [_leftButton setTitleColor:UIColorFromRGB(0x27313e) forState:UIControlStateNormal];
    [_leftButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
    [_leftButton setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
    [self addSubview:_leftButton];
    
    _rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _rightButton.adjustsImageWhenHighlighted = NO;
    [_rightButton setTitle:@"" forState:UIControlStateNormal];
    _rightButton.titleLabel.font = [UIFont systemFontOfSize:16];
    if (kIsRTL) {
        _rightButton.frame = CGRectMake(5, TM_StatusBarHeight, 55, ButtonViewHeight);
    }else {
        _rightButton.frame = CGRectMake(SCREEN_WIDTH-70, TM_StatusBarHeight, 55, ButtonViewHeight);
    }
    [_rightButton addTarget:self action:@selector(rightAction:) forControlEvents:UIControlEventTouchUpInside];
    [_rightButton setTitleColor:UIColorFromRGB(0x27313e) forState:UIControlStateNormal];
    [self addSubview:_rightButton];
    
    _rightFirstButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _rightFirstButton.adjustsImageWhenHighlighted = NO;
    [_rightFirstButton setTitle:@"" forState:UIControlStateNormal];
    _rightFirstButton.titleLabel.font = [UIFont systemFontOfSize:16];
    if (kIsRTL) {
        _rightFirstButton.frame = CGRectMake(70 , TM_StatusBarHeight, 54, ButtonViewHeight);
    }else {
        _rightFirstButton.frame = CGRectMake(SCREEN_WIDTH-70- 44, TM_StatusBarHeight, 54, ButtonViewHeight);
    }
    [_rightFirstButton addTarget:self action:@selector(rightFirstAction:) forControlEvents:UIControlEventTouchUpInside];
    [_rightFirstButton setTitleColor:UIColorFromRGB(0x27313e) forState:UIControlStateNormal];
    [_rightFirstButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentRight];
    [_rightFirstButton setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
    [self addSubview:_rightFirstButton];
}
- (void)didMoveToSuperview
{
    [super didMoveToSuperview];
    [self setNeedsLayout];
}

- (void)safeAreaInsetsDidChange
{
    [super safeAreaInsetsDidChange];
    [self setNeedsLayout];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    UIView *hostView = self.superview;
    // 导航栏尚未挂到页面时，等待实际容器提供尺寸和安全区。
    if (!hostView) return;

    UIEdgeInsets insets = hostView.safeAreaInsets;
    CGFloat width = CGRectGetWidth(hostView.bounds);
    self.frame = CGRectMake(0, 0, width, insets.top + 44.0);
    _backgroundImageView.frame = self.bounds;
    _lineView.frame = CGRectMake(0, CGRectGetHeight(self.bounds) - 0.5, width, 0.5);
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    _gradientLayer.frame = self.bounds;
    [CATransaction commit];

    CGRect frame = CGRectMake(insets.left, insets.top, width - insets.left - insets.right, 44.0);
    if (@available(iOS 27.1, *)) {
        frame = [self frame:frame avoidingRegionsOfKind:UIViewReservedRegionKind.occlusionRegionKind inView:hostView];
    }
    [self layoutButtonsInContentFrame:frame];
}

- (void)layoutButtonsInContentFrame:(CGRect)frame
{
    CGFloat leading = 0;
    CGFloat trailing = CGRectGetWidth(frame);
    for (UIButton *button in [NSArray arrayWithObjects:_backButton, _leftButton, _rightButton, _rightFirstButton, nil]) {
        // 隐藏按钮不占据标题空间；文字按钮使用其实际内容宽度。
        if (button.hidden) continue;
        CGFloat buttonWidth = MAX(44.0, [button sizeThatFits:frame.size].width + 10.0);
        BOOL atLeading = button == _backButton || button == _leftButton;
        CGFloat x = atLeading ? leading : trailing - buttonWidth;
        button.frame = CGRectMake(CGRectGetMinX(frame) + (kIsRTL ? CGRectGetWidth(frame) - x - buttonWidth : x), CGRectGetMinY(frame), buttonWidth, CGRectGetHeight(frame));
        if (atLeading) {
            leading += buttonWidth;
        } else {
            trailing -= buttonWidth;
        }
    }
    CGFloat side = MAX(leading, CGRectGetWidth(frame) - trailing);
    CGRect titleFrame = CGRectMake(CGRectGetMinX(frame) + side, CGRectGetMinY(frame), MAX(0, CGRectGetWidth(frame) - side * 2), CGRectGetHeight(frame));
    if (@available(iOS 27.1, *)) {
        titleFrame = [self frame:titleFrame avoidingRegionsOfKind:UIViewReservedRegionKind.divisionRegionKind inView:self.superview];
    }
    _titleLabel.frame = titleFrame;
}

- (CGRect)frame:(CGRect)frame avoidingRegionsOfKind:(UIViewReservedRegionKind *)kind inView:(UIView *)view
{
    for (UIViewReservedRegion *region in [view reservedRegionsOfKind:kind]) {
        CGRect overlap = CGRectIntersection(frame, region.frame);
        // 区域坐标来自同一个承载页面，仅避让与当前导航内容相交的有效区域。
        if (CGRectIsEmpty(overlap) || CGRectIsNull(overlap)) continue;
        CGFloat leftWidth = CGRectGetMinX(overlap) - CGRectGetMinX(frame);
        CGFloat rightWidth = CGRectGetMaxX(frame) - CGRectGetMaxX(overlap);
        if (leftWidth >= rightWidth) {
            frame.size.width = leftWidth;
        } else {
            frame.origin.x = CGRectGetMaxX(overlap);
            frame.size.width = rightWidth;
        }
    }
    return frame;
}

- (void)backLastView:(UIButton*)button{
    if (self.click) {
        self.click(button);
    }
}
- (void)closeAction:(UIButton*)button{
    if (self.leftClick) {
        self.leftClick(button);
    }
}
- (void)rightAction:(UIButton*)button{
    if (self.rightClick) {
        self.rightClick(button);
    }
}
- (void)rightFirstAction:(UIButton*)button{
    if (self.rightFirstClick) {
        self.rightFirstClick(button);
    }
}
- (void)clickBackButton:(clickBackButton)block{
    self.click = [block copy];
}
- (void)clickLeftButton:(clickBackButton)block{
    self.leftClick = [block copy];
}
- (void)clickRightButton:(clickRightButton)block{
    self.rightClick = [block copy];
}
- (void)clickRightFirstButton:(clickRightFirstButton)block{
    self.rightFirstClick  = [block copy];
}
- (void)setGradientLayer:(CAGradientLayer *)gradientLayer{
    _gradientLayer = gradientLayer;
}
- (void)setTitle:(NSString *)title{
    _title = title;
    if (!title) {
        _titleLabel.text = @"";
        return;
    }
    if ([title isEqualToString:_titleLabel.text]) {
        return;
    }
    _titleLabel.text = title;
}
- (void)setMyBackgroundColor:(UIColor *)myBackgroundColor{
    _myBackgroundColor = myBackgroundColor;
    if (!myBackgroundColor) {
        _backgroundImageView.backgroundColor = [UIColor clearColor];
    }else{
        _backgroundImageView.backgroundColor = myBackgroundColor;
    }
}
- (void)setMyBackgroundImage:(UIImage *)myBackgroundImage{
    _myBackgroundImage = myBackgroundImage;
    if (!myBackgroundImage) {
        _backgroundImageView.backgroundColor = [UIColor clearColor];
    }else{
        _backgroundImageView.image = myBackgroundImage;
    }
}
- (void)setMyTitleColor:(UIColor *)myTitleColor{
    _myTitleColor = myTitleColor;
    if (myTitleColor) {
        _titleLabel.textColor = myTitleColor;
    }
}
- (void)setMyBottomLineColor:(UIColor *)myBottomLineColor{
    _myBottomLineColor = myBottomLineColor;
    if (myBottomLineColor) {
        _lineView.backgroundColor = myBottomLineColor;
    }else{
        _lineView.backgroundColor = [[UIColor grayColor] colorWithAlphaComponent:0.2];
    }
}


@end


