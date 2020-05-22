//
//  XLnavigationBar.h
//  Example
//
//  Created by mxl on 2020/5/21.
//  Copyright © 2020 mxl. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface XLNavigationBar : UIViewController

+ (instancetype)shareInstance;

///enabled default NO
@property (nonatomic, assign) BOOL enabled;

@end


@interface UIViewController (XLBarExtension)

///statusBar style default UIStatusBarStyleDefault
@property (nonatomic, assign) UIStatusBarStyle xl_statusBarStyle;

///statusBar hidden default NO
@property (nonatomic, assign) BOOL xl_statusBarHidden;

///background color  default white
@property (nonatomic, strong) UIColor *xl_navBarBackgroundColor;

///background alpha default 1
@property (nonatomic, assign) float xl_navBarBackgroundAlpha;

///title color default sytem
@property (nonatomic, strong) UIColor *xl_navBarTitleColor;

///bar button color default sytem
@property (nonatomic, strong) UIColor *xl_navBarButtonColor;

///shadow image hidden default NO
@property (nonatomic, assign) BOOL xl_navBarShadowImageHidden;

///navigation bar hieght
@property (nonatomic, assign, readonly) CGFloat xl_navBarHeight;

@end

NS_ASSUME_NONNULL_END
