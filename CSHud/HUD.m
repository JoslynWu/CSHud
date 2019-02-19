//
//  hud.m
//  HUD+
//
//  Created by Joslyn on 2018/10/19.
//  Copyright © 2018 Joslyn. All rights reserved.
//
// https://github.com/JoslynWu/CSHud.git
//

#import "HUD.h"

static NSString * const HUD_LAST_UPDATE_TIME_KEY = @"HUD_LAST_UPDATE_TIME_KEY";
static const CGFloat HUD_STROKE_WIDTH = 2.5;
static NSTimeInterval HUD_DEFAULT_AFTER_DELAY = 1.5;

NS_ASSUME_NONNULL_BEGIN
@implementation HUD

+ (NSTimeInterval)afterDelay {
    return HUD_DEFAULT_AFTER_DELAY;
}

+ (void)setAfterDelay:(NSTimeInterval)afterDelay {
    HUD_DEFAULT_AFTER_DELAY = afterDelay;
}

+ (void)textAppearanceWithHud:(HUD *)hud {
    hud.label.font = [UIFont systemFontOfSize:14];
    hud.detailsLabel.font = [UIFont systemFontOfSize:12];
}

/** 创建一个基础的HUD **/
+ (HUD *)createHud:(nullable UIView *)view {
    if (view == nil){
        view = [UIApplication sharedApplication].keyWindow;;
    }
    HUD *hud = [[HUD alloc] initWithView:view];
    [self textAppearanceWithHud:hud];
    [view addSubview:hud];
    hud.animationType = MBProgressHUDAnimationZoom;
    hud.removeFromSuperViewOnHide = YES;
    [hud showAnimated:YES];
    return hud;
}

+ (HUD *)showInView:(nullable UIView *)view message:(NSString *)message icon:(NSString *)icon; {
    HUD *hud = [self createHud:view];
    [hud showMessage:message icon:icon];
    return hud;
}

- (void)showMessage:(NSString *)message icon:(NSString *)icon {
    if (icon.length > 0) {
        self.square = YES;
    }
    self.label.text = message;
    self.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:icon]];
    self.mode = MBProgressHUDModeCustomView;
    [self hideAnimated:YES afterDelay:self.class.afterDelay];
}

#pragma mark - ********************* 执行结果类HUD *********************
/*
 *  文本
 **/
+ (HUD *)showMessageInView:(nullable UIView *)view message:(NSString *)message{
    HUD *hud = [self createHud:view];
    [hud showMessage:message];
    return hud;
}

- (void)showMessage:(NSString *)message{
    self.mode = MBProgressHUDModeText;
    self.label.text = message;
    [self hideAnimated:YES afterDelay:self.class.afterDelay];
}

/*
 *  显示成功(图片)
 *  - 读取名为“hud_success”的图片
 **/
+ (HUD *)showSuccessIconInView:(nullable UIView *)view message:(NSString *)message{
    return [self showInView:view message:message icon:@"hud_success"];
}

/*
 *  显示失败(图片)
 *  - 读取名为“hud_failed”的图片
 **/
+ (HUD *)showFailedIconInView:(nullable UIView  *)view message:(NSString *)message{
    return [self showInView:view message:message icon:@"hud_failed"];
}

/*
 *  显示成功默认动画
 **/
+ (HUD *)showSuccessInView:(nullable UIView *)view message:(NSString *)message{
    return [self showSuccessInView:view message:message animation:HudSuccessAnimationTypeToRightInside];
}
- (void)showSuccessMessage:(NSString *)message{
    [self showSuccessMessage:message animation:HudSuccessAnimationTypeToRightInside];
}

/*
 *  显示失败默认动画
 **/
+ (HUD *)showFailedInView:(nullable UIView *)view message:(NSString *)message {
    return [self showFailedInView:view message:message animation:HudFailedAnimationTypeSequence];
}
- (void)showFailedMessage:(NSString *)message {
    [self showFailedMessage:message animation:HudFailedAnimationTypeSequence];
}

/*
 *  显示成功动画
 **/
+ (HUD *)showSuccessInView:(nullable UIView *)view
                   message:(NSString *)message
                 animation:(HudSuccessAnimationType)type {
    HUD *hud = [self createHud:view];
    [hud showAnimated:YES];
    [hud showSuccessMessage:message animation:type];
    return hud;
}

- (void)showSuccessMessage:(NSString *)message
                 animation:(HudSuccessAnimationType)type {
    
    self.label.text = message;
    self.square = YES;
    self.mode = MBProgressHUDModeCustomView;
    
    UIImageView *iconImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 55, 55)];
    CAShapeLayer *layer = [CAShapeLayer layer];
    layer.fillColor = [UIColor clearColor].CGColor;
    layer.strokeColor = self.label.textColor.CGColor;
    layer.frame = iconImageView.bounds;
    [iconImageView.layer addSublayer:layer];
    
    [iconImageView.heightAnchor constraintEqualToConstant:55].active = YES;
    [iconImageView.widthAnchor constraintEqualToConstant:55].active = YES;
    self.customView = iconImageView;
    [self hideAnimated:YES afterDelay:self.class.afterDelay];
    
    // 绘制外部透明的圆形
    CAShapeLayer *alphaLineLayer = [CAShapeLayer layer];
    alphaLineLayer.strokeColor = [[UIColor colorWithCGColor:layer.strokeColor] colorWithAlphaComponent:0.1].CGColor;
    alphaLineLayer.lineWidth = HUD_STROKE_WIDTH;
    alphaLineLayer.fillColor = [UIColor clearColor].CGColor;
    
    // 设置当前图层的绘制属性
    layer.fillColor = [UIColor clearColor].CGColor;
    layer.lineCap = kCALineCapRound;
    // layer.lineJoin = kCALineJoinRound;
    layer.lineWidth = HUD_STROKE_WIDTH;
    
    CGSize size = layer.frame.size;
    CGPoint point_last = CGPointMake(size.width * 0.75, size.width * 0.35);
    CGPoint point_mid = CGPointMake(size.width * 0.42, size.width * 0.68);
    CGFloat startAngle = 67 * M_PI / 180;
    CGFloat endAngle = -158 * M_PI / 180;
    CGFloat strokeEnd_duration = 0.5;
    CGFloat strokeStart_duration = 0.4;
    CGFloat strokeStart_delay = 0.2;
    CGFloat fromValue = 0;
    CGFloat endValue = 0.76;
    CGFloat radius = size.width / 2 - HUD_STROKE_WIDTH;
    BOOL needAnimation = true;
    switch (type) {
        case HudSuccessAnimationTypeNone:
            needAnimation = false;
            break;
            
        case HudSuccessAnimationTypeToRight:
            break;
            
        case HudSuccessAnimationTypeToRightInside:
            startAngle = endAngle;
            endValue = 0.3;
            fromValue = endValue - 0.15;
            strokeEnd_duration *= 0.5;
            strokeStart_duration *= 0.5;
            strokeStart_delay *= 0.5;
            break;
            
        case HudSuccessAnimationTypeNoneWithLoop:
            [layer addSublayer: alphaLineLayer];
            needAnimation = false;
            break;
            
        case HudSuccessAnimationTypeToRightWithLoop:
            [layer addSublayer: alphaLineLayer];
            break;
            
        case HudSuccessAnimationTypeToRightWithLoopInside:
            [layer addSublayer: alphaLineLayer];
            startAngle = endAngle;
            endValue = 0.3;
            fromValue = endValue - 0.15;
            strokeEnd_duration *= 0.5;
            strokeStart_duration *= 0.5;
            strokeStart_delay *= 0.5;
            break;
            
        case HudSuccessAnimationTypeToOutWithLoop:
            [layer addSublayer: alphaLineLayer];
            radius *= 0.8;
            endValue = 0.63;
            point_mid = CGPointMake(size.width * 0.46, size.width * 0.68);
            point_last = CGPointMake(size.width * 0.95, size.width * 0.15);
            break;
            
        case HudSuccessAnimationTypeToOutWithLoopInside:
            [layer addSublayer: alphaLineLayer];
            startAngle = endAngle;
            radius *= 0.75;
            endValue = 0.2;
            fromValue = endValue - 0.15;
            strokeEnd_duration *= 0.5;
            strokeStart_duration *= 0.5;
            strokeStart_delay *= 0.5;
            point_mid = CGPointMake(size.width * 0.46, size.width * 0.68);
            point_last = CGPointMake(size.width * 0.95, size.width * 0.15);
            break;
    }
    
    UIBezierPath *circlePath = [UIBezierPath bezierPath];
    [circlePath addArcWithCenter:CGPointMake(layer.frame.size.width / 2, layer.frame.size.height / 2) radius:radius startAngle:0 endAngle:2 * M_PI clockwise:NO];
    alphaLineLayer.path = circlePath.CGPath;
    
    // 半圆+动画的绘制路径初始化
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path addArcWithCenter: CGPointMake(layer.frame.size.width / 2, layer.frame.size.height / 2) radius:radius startAngle:startAngle endAngle:endAngle clockwise: NO];
    [path addLineToPoint:point_mid];
    [path addLineToPoint:point_last];
    layer.path = path.CGPath;
    
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath: @"strokeEnd"];
    animation.duration = strokeEnd_duration;
    animation.fromValue = @(fromValue);
    animation.toValue = @(1);
    
    layer.strokeStart = endValue; // 设置最终效果，防止动画结束之后效果改变
    layer.strokeEnd = 1.0;
    
    if (!needAnimation) {
        return;
    }
    
    // 创建路径顺序从结尾开始消失的动画
    CAMediaTimingFunction *timing = [[CAMediaTimingFunction alloc] initWithControlPoints:0.3 :0.6 :0.8 :1.1];
    CABasicAnimation *strokeStartAnimation = [CABasicAnimation animationWithKeyPath: @"strokeStart"];
    strokeStartAnimation.duration = strokeStart_duration;
    strokeStartAnimation.beginTime = CACurrentMediaTime() + strokeStart_delay;// 延迟执行动画
    strokeStartAnimation.fromValue = @(fromValue);
    strokeStartAnimation.toValue = @(endValue);
    strokeStartAnimation.timingFunction = timing;
    
    [layer addAnimation: animation forKey: @"strokeEnd"];
    [layer addAnimation: strokeStartAnimation forKey: @"strokeStart"];
}

/*
 *  显示失败动画
 **/
+ (HUD *)showFailedInView:(nullable UIView *)view
                  message:(NSString  *)message
                animation:(HudFailedAnimationType)type{
    HUD *hud = [self createHud:view];
    [hud showFailedMessage:message animation:type];
    return hud;
}

/*
 *  显示失败动画
 **/
- (void)showFailedMessage:(NSString *)message
                animation:(HudFailedAnimationType)type{
    self.mode = MBProgressHUDModeCustomView;
    self.label.text = message;
    self.square = YES;
    CAShapeLayer *layer = [CAShapeLayer layer];
    UIImageView *iconImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 55, 55)];
    layer.fillColor = [UIColor clearColor].CGColor;
    layer.strokeColor = self.label.textColor.CGColor;
    layer.frame = iconImageView.bounds;
    [iconImageView.layer addSublayer: layer];
    [iconImageView.heightAnchor constraintEqualToConstant:55].active = YES;
    [iconImageView.widthAnchor constraintEqualToConstant:55].active = YES;
    self.customView = iconImageView;
    [self hideAnimated:YES afterDelay:self.class.afterDelay];
    
    // 绘制外部透明的圆形
    UIBezierPath *circlePath = [UIBezierPath bezierPath];
    [circlePath addArcWithCenter: CGPointMake(layer.frame.size.width / 2, layer.frame.size.height / 2) radius:layer.frame.size.width / 2 - HUD_STROKE_WIDTH startAngle:0 endAngle: 2 * M_PI clockwise: NO];
    CAShapeLayer *alphaLineLayer = [CAShapeLayer layer];
    alphaLineLayer.path = circlePath.CGPath;
    alphaLineLayer.strokeColor = [[UIColor colorWithCGColor: layer.strokeColor] colorWithAlphaComponent: 0.1].CGColor;
    alphaLineLayer.lineWidth = HUD_STROKE_WIDTH;
    alphaLineLayer.fillColor = [UIColor clearColor].CGColor;
    
    // 左边叉线
    CAShapeLayer *leftLayer = [CAShapeLayer layer];
    leftLayer.frame = layer.bounds;
    leftLayer.fillColor = [UIColor clearColor].CGColor;
    leftLayer.lineCap = kCALineCapRound;
    leftLayer.lineWidth = HUD_STROKE_WIDTH;
    leftLayer.strokeColor = layer.strokeColor;
    
    // 右边叉线
    CAShapeLayer *rightLayer = [CAShapeLayer layer];
    rightLayer.frame = layer.bounds;
    rightLayer.fillColor = [UIColor clearColor].CGColor;
    rightLayer.lineCap = kCALineCapRound;
    rightLayer.lineWidth = HUD_STROKE_WIDTH;
    rightLayer.strokeColor = layer.strokeColor;
    
    CGSize size = layer.frame.size;
    CGFloat startAngle_left = 90 * M_PI / 180;;
    CGFloat endAngle_left = -47 * M_PI / 180;
    CGPoint endPoint_left = CGPointMake(size.width * 0.35, size.width * 0.65);
    CGFloat startAngle_right = 90 * M_PI / 180;
    CGFloat endAngle_right = -137 * M_PI / 180;
    CGPoint endPoint_right = CGPointMake(size.width * 0.65, size.width * 0.65);
    CGFloat stopValue = 0.825;
    CGFloat strokeEnd_duration = 0.5;
    CGFloat strokeStart_duration = 0.4;
    CGFloat strokeStart_delay = 0.2;
    BOOL needAnimation = true;
    switch (type) {
        case HudFailedAnimationTypeNone:
            needAnimation = false;
            break;
            
        case HudFailedAnimationTypeTogether:
            break;
            
        case HudFailedAnimationTypeSequence:
            leftLayer.hidden = true;
            startAngle_left = endAngle_left;
            startAngle_right = endAngle_right;
            strokeEnd_duration *= 0.5;
            strokeStart_duration *= 0.5;
            strokeStart_delay *= 0.5;
            stopValue = 0.36;
            break;
            
        case HudFailedAnimationTypeNoneWithLoop:
            needAnimation = false;
            [layer addSublayer: alphaLineLayer];
            break;
            
        case HudFailedAnimationTypeTogetherWithLoop:
            [layer addSublayer: alphaLineLayer];
            break;
            
        case HudFailedAnimationTypeSequenceWithLoop:
            [layer addSublayer: alphaLineLayer];
            leftLayer.hidden = true;
            startAngle_left = endAngle_left;
            startAngle_right = endAngle_right;
            strokeEnd_duration *= 0.5;
            strokeStart_duration *= 0.5;
            strokeStart_delay *= 0.5;
            stopValue = 0.36;
            break;
    }
    
    UIBezierPath *leftPath = [UIBezierPath bezierPath];
    [leftPath addArcWithCenter: CGPointMake(layer.frame.size.width / 2, layer.frame.size.height / 2) radius:layer.frame.size.width / 2 - HUD_STROKE_WIDTH  startAngle:startAngle_left endAngle:endAngle_left clockwise: YES];
    [leftPath addLineToPoint:endPoint_left];
    leftLayer.path = leftPath.CGPath;
    [layer addSublayer: leftLayer];
    
    UIBezierPath *rightPath = [UIBezierPath bezierPath];
    [rightPath addArcWithCenter: CGPointMake(layer.frame.size.width / 2, layer.frame.size.height / 2) radius:layer.frame.size.width / 2 - HUD_STROKE_WIDTH startAngle:startAngle_right endAngle:endAngle_right clockwise: NO];
    [rightPath addLineToPoint: endPoint_right];
    rightLayer.path = rightPath.CGPath;
    [layer addSublayer: rightLayer];
    
    // 锁定最终动画
    leftLayer.strokeStart = stopValue;
    leftLayer.strokeEnd = 1.0;
    rightLayer.strokeStart = stopValue;
    rightLayer.strokeEnd = 1.0;
    
    if (!needAnimation) {
        return;
    }
    
    CAMediaTimingFunction *timing = [[CAMediaTimingFunction alloc] initWithControlPoints:0.3 :0.6 :0.8 :1.1];
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath: @"strokeEnd"];
    animation.duration = strokeEnd_duration;// 动画使用时间
    animation.fromValue = [NSNumber numberWithInt: 0.0];// 从头
    animation.toValue = [NSNumber numberWithInt: 1.0];// 画到尾
    
    // 创建路径顺序从结尾开始消失的动画
    CABasicAnimation *strokeStartAnimation = [CABasicAnimation animationWithKeyPath: @"strokeStart"];
    strokeStartAnimation.duration = strokeStart_duration;
    strokeStartAnimation.beginTime = CACurrentMediaTime() + strokeStart_delay;// 延迟执行动画
    strokeStartAnimation.fromValue = [NSNumber numberWithFloat: 0.0];// 从开始消失
    strokeStartAnimation.toValue = [NSNumber numberWithFloat: stopValue];// 这个数没有啥技巧，一点点调试看效果，希望看此代码的人不要被这个数值怎么来的困惑
    strokeStartAnimation.timingFunction = timing;
    
    [rightLayer addAnimation: animation forKey: @"strokeEnd"];
    [rightLayer addAnimation: strokeStartAnimation forKey: @"strokeStart"];
    CGFloat time_after = strokeStart_duration + strokeStart_delay;
    if (!leftLayer.hidden) { // 非依次出现
        time_after = 0;
    }
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(time_after * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        leftLayer.hidden = false;
        [leftLayer addAnimation: animation forKey: @"strokeEnd"];
        [leftLayer addAnimation: strokeStartAnimation forKey: @"strokeStart"];
    });
}

#pragma mark - ********************* 执行中类HUD 需手动关闭 *********************
/*
 * 菊花
 **/
+ (HUD *)showLoadingInView:(nullable UIView *)view{
    HUD *hud = [self createHud:view];
    [hud showLoading];
    return hud;
}

- (void)showLoading {
    self.mode = MBProgressHUDModeIndeterminate;
}

/*
 * 菊花 + 文本
 **/
+ (HUD *)showLoadingInView:(nullable UIView *)view message:(NSString *)message{
    HUD *hud = [self createHud:view];
    [hud showLoadingMessage:message];
    return hud;
}

- (void)showLoadingMessage:(NSString *)message {
    self.mode = MBProgressHUDModeIndeterminate;
    self.label.text = message;
}

/*
 * 转圈 + 上次更新时间
 **/
+ (HUD *)showLoadingUpDateInView:(nullable UIView  *)view{
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString* dateString = [dateFormatter stringFromDate:[NSDate date]];
    HUD *hud = [self createHud:view];
    hud.label.text = @"上次更新:";
    if ([[NSUserDefaults  standardUserDefaults] valueForKey:HUD_LAST_UPDATE_TIME_KEY]) {
        hud.detailsLabel.text = [[NSUserDefaults  standardUserDefaults] valueForKey:HUD_LAST_UPDATE_TIME_KEY];
        [[NSUserDefaults  standardUserDefaults] setValue:dateString forKey:HUD_LAST_UPDATE_TIME_KEY];
    } else{
        hud.detailsLabel.text = dateString;
        [[NSUserDefaults  standardUserDefaults] setValue:dateString forKey:HUD_LAST_UPDATE_TIME_KEY];
    }
    
    return hud;
}

/*
 * 转圈 + 文本 + 蒙版
 **/
+ (HUD *)showBlurInView:(nullable UIView *)view message:(NSString *)message{
    HUD *hud = [self createHud:view];
    [hud showBlurMessage:message];
    return hud;
}

- (void)showBlurMessage:(NSString *)message {
    self.label.text = message;
    self.backgroundView.style = MBProgressHUDBackgroundStyleBlur;
}

/*
 *  显示环形动画
 **/

+ (HUD *)showRoundLoadingInView:(nullable UIView *)view message:(NSString *)message{
    HUD *hud = [self createHud:view];
    [hud showRoundLoadingMessage:message];
    return hud;
}

- (void)showRoundLoadingMessage:(NSString *)message {
    CGFloat l = 55;
    self.mode = MBProgressHUDModeCustomView;
    self.label.text = message;
    self.square = YES;
    CAShapeLayer *layer = [CAShapeLayer layer];
    UIImageView *iconImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, l, l)];
    layer.fillColor = [UIColor clearColor].CGColor;
    layer.strokeColor = self.label.textColor.CGColor;
    layer.frame = iconImageView.bounds;
    [iconImageView.layer addSublayer: layer];
    [iconImageView.heightAnchor constraintEqualToConstant:l].active = YES;
    [iconImageView.widthAnchor constraintEqualToConstant:l].active = YES;
    self.customView = iconImageView;
    
    // 绘制外部透明的圆形
    UIBezierPath *circlePath = [UIBezierPath bezierPath];
    [circlePath addArcWithCenter: CGPointMake(layer.frame.size.width / 2, layer.frame.size.height / 2) radius:layer.frame.size.width / 2 - HUD_STROKE_WIDTH startAngle:  0 * M_PI/180 endAngle: 360 * M_PI/180 clockwise: NO];
    // 创建外部透明圆形的图层
    CAShapeLayer *alphaLineLayer = [CAShapeLayer layer];
    alphaLineLayer.path = circlePath.CGPath;
    alphaLineLayer.strokeColor = [[UIColor colorWithCGColor: layer.strokeColor] colorWithAlphaComponent: 0.1].CGColor;
    alphaLineLayer.lineWidth = HUD_STROKE_WIDTH;
    alphaLineLayer.fillColor = [UIColor clearColor].CGColor;
    [layer addSublayer: alphaLineLayer];
    
    CAShapeLayer *drawLayer = [CAShapeLayer layer];
    UIBezierPath *progressPath = [UIBezierPath bezierPath];
    [progressPath addArcWithCenter: CGPointMake(layer.frame.size.width / 2, layer.frame.size.height / 2) radius:layer.frame.size.width / 2 - HUD_STROKE_WIDTH startAngle: 0 * M_PI / 180 endAngle: 360 * M_PI / 180 clockwise: YES];
    
    drawLayer.lineWidth = HUD_STROKE_WIDTH;
    drawLayer.fillColor = [UIColor clearColor].CGColor;
    drawLayer.path = progressPath.CGPath;
    drawLayer.frame = drawLayer.bounds;
    drawLayer.strokeColor = layer.strokeColor;
    [layer addSublayer: drawLayer];
    
    CAMediaTimingFunction *progressRotateTimingFunction = [CAMediaTimingFunction functionWithControlPoints:0.25 :0.80 :0.75 :1.00];
    
    // 开始划线的动画
    CABasicAnimation *progressLongAnimation = [CABasicAnimation animationWithKeyPath: @"strokeEnd"];
    progressLongAnimation.fromValue = [NSNumber numberWithFloat: 0.0];
    progressLongAnimation.toValue = [NSNumber numberWithFloat: 1.0];
    progressLongAnimation.duration = 1.5;
    progressLongAnimation.timingFunction = progressRotateTimingFunction;
    progressLongAnimation.repeatCount = INT_MAX;
    // 线条逐渐变短收缩的动画
    CABasicAnimation *progressLongEndAnimation = [CABasicAnimation animationWithKeyPath: @"strokeStart"];
    progressLongEndAnimation.fromValue = [NSNumber numberWithFloat: 0.0];
    progressLongEndAnimation.toValue = [NSNumber numberWithFloat: 1.0];
    progressLongEndAnimation.duration = 1.5;
    CAMediaTimingFunction *strokeStartTimingFunction = [[CAMediaTimingFunction alloc] initWithControlPoints: 0.65 : 0.0 :1.0 : 1.0];
    progressLongEndAnimation.timingFunction = strokeStartTimingFunction;
    progressLongEndAnimation.repeatCount = INT_MAX;
    // 线条不断旋转的动画
    CABasicAnimation *progressRotateAnimation = [CABasicAnimation animationWithKeyPath: @"transform.rotation.z"];
    progressRotateAnimation.fromValue = [NSNumber numberWithFloat: 0.0];
    progressRotateAnimation.toValue = [NSNumber numberWithFloat: M_PI / 180 * 360];
    progressRotateAnimation.repeatCount = INT_MAX;
    progressRotateAnimation.duration = 4;
    
    [drawLayer addAnimation:progressLongAnimation forKey: @"strokeEnd"];
    [layer addAnimation:progressRotateAnimation forKey: @"transfrom.rotation.z"];
    [drawLayer addAnimation: progressLongEndAnimation forKey: @"strokeStart"];
}
/*
 *  显示自定义动画
 **/
+ (HUD *)showCustomAnimateInView:(nullable UIView *)view
                         message:(NSString *)message
                      imageArray:(NSArray *)imageArr
                        duration:(NSTimeInterval)duration{
    HUD *hud = [self createHud:view];
    [hud showCustomAnimateMessage:message imageArray:imageArr duration:duration];
    return hud;
}
- (void)showCustomAnimateMessage:(NSString *)message
                      imageArray:(NSArray *)imageArr
                        duration:(NSTimeInterval)duration {
    self.mode = MBProgressHUDModeCustomView;
    self.label.text = message;
    self.square = YES;
    UIImage *image = [UIImage imageNamed:[NSString stringWithFormat:@"%@", imageArr[0]]];
    UIImageView *animateGifView = [[UIImageView alloc] initWithImage:image];
    
    NSMutableArray *gifArray = [NSMutableArray array];
    for (int i = 0; i < imageArr.count; i ++) {
        NSString *imageName = imageArr[i];
        UIImage *image = [UIImage imageNamed:[NSString stringWithFormat:@"%@",imageName]];
        if (nil == image) {
            NSLog(@"[CSHud]图片不存在: %@", imageName);
            continue;
        } else {
            [gifArray addObject:image];
        }
    }
    if (isnan(duration) || duration <= 0.0001) {
        duration = imageArr.count / 6.0;
    }
    [animateGifView setAnimationImages:gifArray];
    [animateGifView setAnimationDuration:duration];
    [animateGifView setAnimationRepeatCount:0];
    [animateGifView startAnimating];
    
    self.customView = animateGifView;
}


#pragma mark - ********************* 关闭HUD *********************
/*
 * 消除HUD
 **/
+ (void)hideWithView:(nullable UIView *)view{
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    if (view == nil) {
        view = window;
    }
    [HUD hideHUDForView:view animated:YES];
}

@end
NS_ASSUME_NONNULL_END
