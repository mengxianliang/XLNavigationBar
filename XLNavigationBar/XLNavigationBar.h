//
//  XLnavigationBar.h
//  Example
//
//  Created by mxl on 2020/5/21.
//  Copyright © 2020 mxl. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIViewController (XLBarExtension)

///状态栏样式 default UIStatusBarStyleDefault
@property (nonatomic, assign) UIStatusBarStyle xl_statusBarStyle;

///状态栏隐藏 default NO
@property (nonatomic, assign) BOOL xl_statusBarHidden;

///navigationBar 背景颜色 default [UIColor whiteColor]
@property (nonatomic, strong) UIColor *xl_navBarBackgroundColor;

///navigationBar 背景透明度 default 1
@property (nonatomic, assign) float xl_navBarBackgroundAlpha;

///navigationBar 标题颜色 default 系统颜色
@property (nonatomic, strong) UIColor *xl_navBarTitleColor;

///navigationBar 按钮颜色 default 系统颜色
@property (nonatomic, strong) UIColor *xl_navBarButtonColor;

///navigationBar 分割线隐藏 default NO
@property (nonatomic, assign) BOOL xl_navBarShadowImageHidden;

///navigationBar 高度
@property (nonatomic, assign, readonly) CGFloat xl_navBarHeight;

@end

NS_ASSUME_NONNULL_END
