//
//  HUD.h
//  HUD+
//
//  Created by admin on 2018/10/19.
//  Copyright © 2018 Joslyn. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <MBProgressHUD/MBProgressHUD.h>

/*
 MBProgressHUD 相关属性解释
 
 - 主模式
 hud.mode = MBProgressHUDModeIndeterminate;//菊花，默认值
 hud.mode = MBProgressHUDModeDeterminate;//饼状进度条
 hud.mode = MBProgressHUDModeDeterminateHorizontalBar;//水平进度条
 hud.mode = MBProgressHUDModeAnnularDeterminate;//环形进度条
 hud.mode = MBProgressHUDModeCustomView; //需要设置自定义视图时候设置成这个
 hud.mode = MBProgressHUDModeText; //只显示文本
 
 - 设置背景框颜色和透明度 默认[UIColor colorWithWhite:0.8 alpha:0.6]
 hud.bezelView.color = [UIColor brownColor];
 
 - 设置背景框的圆角值，默认是5
 hud.bezelView.layer.cornerRadius = 20.0;
 
 - 设置提示信息 信息颜色，字体
 hud.label.textColor = [UIColor blueColor];
 hud.label.font = [UIFont systemFontOfSize:13];
 hud.label.text = @"Loading...";
 
 - 设置提示信息详情 详情颜色，字体
 hud.detailsLabel.textColor = [UIColor blueColor];
 hud.detailsLabel.font = [UIFont systemFontOfSize:13];
 hud.detailsLabel.text = @"LoadingLoading...";
 
 - 设置菊花颜色  只能设置菊花的颜色
 [UIActivityIndicatorView appearanceWhenContainedInInstancesOfClasses:
 @[HUD.class]].color = [UIColor blackColor];
 
 - 设置背景模板。backgroundView.alpha辅助减弱/增强毛玻璃效果
 hud.backgroundView.style = MBProgressHUDBackgroundStyleBlur;
 hud.backgroundView.blurEffectStyle = UIBlurEffectStyleDark;
 hud.backgroundView.alpha = 0.65;
 
 - 设置动画的模式
 HUD.mode = MBProgressHUDModeIndeterminate;
 
 - 设置提示框的相对于父视图中心点的偏移，正值 向右下偏移，负值左上
 hud.offset = CGPointMake(50, -180);
 
 - 设置各个元素距离矩形边框的距离。默认20
 hud.margin = 0;
 
 - 背景框(bezelView)的最小尺寸
 hud.minSize = CGSizeMake(50, 50);
 
 - 设置背景框(bezelView)的实际大小
 CGSize size = hud.bezelView.frame.size;
 
 - 是否强制背景框宽高相等
 hud.square = YES;
 
 - 设置显示和隐藏动画类型  有三种动画效果，如下
 hud.animationType = MBProgressHUDAnimationFade; // 默认类型的，透明渐变
 hud.animationType = MBProgressHUDAnimationZoom // 淡入时放大，淡出时收缩
 hud.animationType = MBProgressHUDAnimationZoomOut; // 透明淡入，淡出时收缩
 hud.animationType = MBProgressHUDAnimationZoomIn; // 透明淡入，淡出时放大
 
 - 设置最短显示时间，为了避免显示后立刻被隐藏   默认是0
 hud.minShowTime = 10;
 
 - 这个属性设置了一个宽限期，它是在没有显示HUD窗口前被调用方法可能运行的时间。
 如果被调用方法在宽限期内执行完，则HUD不会被显示。
 这主要是为了避免在执行很短的任务时，去显示一个HUD窗口。
 默认值是0。只有当任务状态是已知时，才支持宽限期。具体我们看实现代码。
 @property (assign) float graceTime;
 
 - 设置隐藏的时候是否从父视图中移除，默认是NO
 hud.removeFromSuperViewOnHide = NO;
 
 - 进度指示器的进度  模式是0，取值从0.0————1.0
 hud.progress = 0.5;
 
 - 隐藏时候的回调 隐藏动画结束之后
 hud.completionBlock = ^(){
 NSLog(@"abnnfsfsf");
 };
 
 - 两种隐藏的方法
 [hud hideAnimated:YES];
 [hud hideAnimated:YES afterDelay:5];
 
 */

typedef NS_ENUM(NSInteger, HudFailedAnimationType){
    HudFailedAnimationTypeNone, // 无外环 + 无动画
    HudFailedAnimationTypeTogether, // 无外环 + 一起出现
    HudFailedAnimationTypeSequence, // 先后依次出现
    // 带外环
    HudFailedAnimationTypeNoneWithLoop, // 带外环 + 无动画
    HudFailedAnimationTypeTogetherWithLoop, // 带外环 + 一起出现
    HudFailedAnimationTypeSequenceWithLoop // 依次先后出现
};

typedef NS_ENUM(NSInteger, HudSuccessAnimationType){
    HudSuccessAnimationTypeNone, // 无外环 + 无动画
    HudSuccessAnimationTypeToRight, // 无外环 + 自左向右动画
    HudSuccessAnimationTypeToRightInside, // 无外环 + 自左向右动画 + 内部
    // 带外环
    HudSuccessAnimationTypeNoneWithLoop, // 带外环 + 无动画
    HudSuccessAnimationTypeToRightWithLoop, // 带外环 + 自左向右动画
    HudSuccessAnimationTypeToRightWithLoopInside, // 带外环 + 自左向右动画 + 内部
    HudSuccessAnimationTypeToOutWithLoop, // 带外环 + 超出外环动画
    HudSuccessAnimationTypeToOutWithLoopInside, // 带外环 + 超出外环动画 + 内部
};

NS_ASSUME_NONNULL_BEGIN
@interface HUD : MBProgressHUD

/**
 HUD隐藏时的默认延时时间。默认为1.5s。
 - 执行结果类HUD适用。如成功、失败、纯文字的hud
 - 执行中类HUD不适用，需要手动关闭。如：菊花、菊花+文本、菊花+上次更新时间、菊花+文本+蒙版、环形加载动画和自定义动画
 */
@property (nonatomic, assign, class) NSTimeInterval afterDelay;

#pragma mark - ********************* 执行结果类HUD *********************

/*
 *  显示成功默认动画
 **/
+ (HUD *)showSuccessInView:(nullable UIView *)view message:(NSString *)message;
- (void)showSuccessMessage:(NSString *)message;

/*
 *  显示失败默认动画
 **/
+ (HUD *)showFailedInView:(nullable UIView *)view message:(NSString *)message;
- (void)showFailedMessage:(NSString *)message;

/*
 *  显示成功动画
 **/
+ (HUD *)showSuccessInView:(nullable UIView *)view
                   message:(NSString *)message
                 animation:(HudSuccessAnimationType)type;

- (void)showSuccessMessage:(NSString *)message
                 animation:(HudSuccessAnimationType)type;

/*
 *  显示失败动画
 **/
+ (HUD *)showFailedInView:(nullable UIView *)view
                  message:(NSString *)message
                animation:(HudFailedAnimationType)type;

- (void)showFailedMessage:(NSString *)message
                animation:(HudFailedAnimationType)type;

/*
 *  文本
 **/
+ (HUD *)showMessageInView:(nullable UIView *)view message:(NSString *)message;
- (void)showMessage:(NSString *)message;

/*
 *  用自定义图片显示结果
 **/
+ (HUD *)showInView:(nullable UIView *)view message:(NSString *)text icon:(NSString *)icon;
- (void)showMessage:(NSString *)text icon:(NSString *)icon;


#pragma mark - ********************* 执行中类HUD 需手动关闭 *********************
/*
 * 菊花
 **/
+ (HUD *)showLoadingInView:(nullable UIView *)view;

/*
 * 菊花 + 文本
 **/
+ (HUD *)showLoadingInView:(nullable UIView *)view message:(NSString *)message;
- (void)showLoadingMessage:(NSString *)message;

/*
 * 菊花 + 上次更新时间
 **/
+ (HUD *)showLoadingUpDateInView:(nullable UIView *)view;
/*
 * 菊花 + 文本 + 蒙版
 **/
+ (HUD *)showBlurInView:(nullable UIView *)view message:(NSString *)message;
- (void)showBlurMessage:(NSString *)message;

/*
 *  显示环形加载动画
 **/
+ (HUD *)showRoundLoadingInView:(nullable UIView *)view message:(NSString *)message;
- (void)showRoundLoadingMessage:(NSString *)message;

/*
 *  显示自定义动画
 *  - duration默认为 imageArr.count/6.0 s，即FPS = 6
 **/
+ (HUD *)showCustomAnimateInView:(nullable UIView *)view
                         message:(NSString *)message
                      imageArray:(NSArray *)imageArr
                        duration:(NSTimeInterval)duration;

- (void)showCustomAnimateMessage:(NSString *)message
                      imageArray:(NSArray *)imageArr
                        duration:(NSTimeInterval)duration;


#pragma mark - ********************* 关闭HUD *********************
/*
 * 消除HUD
 **/
+ (void)hideWithView:(nullable UIView *)view;

@end
NS_ASSUME_NONNULL_END
