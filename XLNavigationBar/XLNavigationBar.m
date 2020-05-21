//
//  XLNavigationBar.m
//  Example
//
//  Created by mxl on 2020/5/21.
//  Copyright © 2020 mxl. All rights reserved.
//

#import "XLNavigationBar.h"
#import <objc/runtime.h>

//------------------------------------------------------------------------------------------

@interface NSObject (Swizzle)

- (void)swizzleSelector:(SEL)originalSelector withSelector:(SEL)swizzledSelector;

@end

@implementation NSObject (Swizzle)

- (void)swizzleSelector:(SEL)originalSelector withSelector:(SEL)swizzledSelector {
    Class class = [self class];
    Method originalMethod = class_getInstanceMethod(class, originalSelector);
    Method swizzledMethod = class_getInstanceMethod(class, swizzledSelector);
    BOOL didAddMethod = class_addMethod(class,
                                        originalSelector,
                                        method_getImplementation(swizzledMethod),
                                        method_getTypeEncoding(swizzledMethod));
    if (didAddMethod) {
        class_replaceMethod(class,
                            swizzledSelector,
                            method_getImplementation(originalMethod),
                            method_getTypeEncoding(originalMethod));
    } else {
        method_exchangeImplementations(originalMethod, swizzledMethod);
    }
}

@end

//------------------------------------------------------------------------------------------

static NSString *XLBarColorViewKey = @"XLBarColorViewKey";
static NSInteger XLBarColorViewTag = 666666;

@interface UINavigationBar (XLExtension)

@property (nonatomic, strong) UIView *xl_colorView;

@property (nonatomic, strong, readonly) UIView *xl_backgroundView;

@end

@implementation UINavigationBar (XLExtension)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self swizzleSelector:@selector(layoutSubviews) withSelector:@selector(xl_layoutSubviews)];
    });
}

- (void)setXl_colorView:(UIView *)xl_colorView {
    objc_setAssociatedObject(self, &XLBarColorViewKey,
    xl_colorView, OBJC_ASSOCIATION_RETAIN);
    xl_colorView.tag = XLBarColorViewTag;
    for (UIView *subview in self.xl_backgroundView.subviews) {
        if (subview.tag == XLBarColorViewTag) {
            [subview removeFromSuperview];
        }
    }
    [self.xl_backgroundView insertSubview:xl_colorView atIndex:0];
    [self setNeedsDisplay];
}

- (UIView *)xl_colorView {
    return objc_getAssociatedObject(self, &XLBarColorViewKey);
}

- (void)xl_layoutSubviews {
    self.xl_colorView.frame = self.xl_backgroundView.bounds;
    [self xl_layoutSubviews];
}

- (UIView *)xl_backgroundView {
    return self.subviews.firstObject;
}

@end

//------------------------------------------------------------------------------------------

@implementation UINavigationController (StatusBarStyle)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self swizzleSelector:@selector(preferredStatusBarStyle) withSelector:@selector(xl_preferredStatusBarStyle)];
        [self swizzleSelector:@selector(prefersStatusBarHidden) withSelector:@selector(xl_prefersStatusBarHidden)];
    });
}

- (UIStatusBarStyle)xl_preferredStatusBarStyle {
    return self.topViewController.preferredStatusBarStyle;
}

- (BOOL)xl_prefersStatusBarHidden {
    return self.topViewController.prefersStatusBarHidden;
}

@end

//------------------------------------------------------------------------------------------

static NSString *XLBarBackgroundColorKey = @"XLBarBackgroundColorKey";
static NSString *XLBarTitleColorKey = @"XLBarTitleColorKey";
static NSString *XLBarButtonColorKey = @"XLBarButtonColorKey";
static NSString *XLStatusBarStyleKey = @"XLStatusBarStyleKey";
static NSString *XLStatusBarHiddenKey = @"XLStatusBarHiddenKey";
static NSString *XLBarShadowImageHiddenKey = @"XLBarShadowImageHiddenKey";
static NSString *XLBarBackgroundAlphaKey = @"XLBarBackgroundAlphaKey";

@implementation UIViewController (XLBarExtension)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self swizzleSelector:@selector(viewWillAppear:) withSelector:@selector(xl_viewWillAppear:)];
        [self swizzleSelector:@selector(viewDidLoad) withSelector:@selector(xl_viewDidLoad)];
        [self swizzleSelector:@selector(preferredStatusBarStyle) withSelector:@selector(xl_preferredStatusBarStyle)];
        [self swizzleSelector:@selector(prefersStatusBarHidden) withSelector:@selector(xl_prefersStatusBarHidden)];
    });
}

- (void)setXl_barBackgroundColor:(UIColor *)xl_barBackgroundColor {
    objc_setAssociatedObject(self, &XLBarBackgroundColorKey,
    xl_barBackgroundColor, OBJC_ASSOCIATION_COPY);
}

- (UIColor *)xl_barBackgroundColor {
    UIColor *color = objc_getAssociatedObject(self, &XLBarBackgroundColorKey);
    if (!color) { return [UIColor whiteColor];}
    return color;
}

- (void)setXl_barTitleColor:(UIColor *)xl_barTitleColor {
    objc_setAssociatedObject(self, &XLBarTitleColorKey,
    xl_barTitleColor, OBJC_ASSOCIATION_COPY);
}

- (UIColor *)xl_barTitleColor {
    return objc_getAssociatedObject(self, &XLBarTitleColorKey);
}

- (void)setXl_barButtonColor:(UIColor *)xl_barButtonColor {
    objc_setAssociatedObject(self, &XLBarButtonColorKey,
    xl_barButtonColor, OBJC_ASSOCIATION_COPY);
}

- (UIColor *)xl_barButtonColor {
    return objc_getAssociatedObject(self, &XLBarButtonColorKey);
}

- (void)setXl_statusBarStyle:(UIStatusBarStyle)xl_statusBarStyle {
    objc_setAssociatedObject(self, &XLStatusBarStyleKey,
    @(xl_statusBarStyle), OBJC_ASSOCIATION_COPY);
}

- (UIStatusBarStyle)xl_statusBarStyle {
    return (UIStatusBarStyle)[objc_getAssociatedObject(self, &XLStatusBarStyleKey) integerValue];
}

- (void)setXl_statusBarHidden:(BOOL)xl_statusBarHidden {
    objc_setAssociatedObject(self, &XLStatusBarHiddenKey,
    @(xl_statusBarHidden), OBJC_ASSOCIATION_COPY);
}

- (BOOL)xl_statusBarHidden {
    return [objc_getAssociatedObject(self, &XLStatusBarHiddenKey) boolValue];
}

- (void)setXl_barShadowImageHidden:(BOOL)xl_barShadowImageHidden {
    objc_setAssociatedObject(self, &XLBarShadowImageHiddenKey,
    @(xl_barShadowImageHidden), OBJC_ASSOCIATION_COPY);
}

- (BOOL)xl_barShadowImageHidden {
    return [objc_getAssociatedObject(self, &XLBarShadowImageHiddenKey) boolValue];
}

- (void)setXl_barBackgroundAlpha:(float)xl_barBackgroundAlpha {
    objc_setAssociatedObject(self, &XLBarBackgroundAlphaKey,
    @(xl_barBackgroundAlpha), OBJC_ASSOCIATION_COPY);
    self.navigationController.navigationBar.xl_backgroundView.alpha = self.xl_barBackgroundAlpha;
}

- (float)xl_barBackgroundAlpha {
    id obj = objc_getAssociatedObject(self, &XLBarBackgroundAlphaKey);
    if (!obj) {return 1;}
    return [obj floatValue];
}

- (CGFloat)xl_barHeight {
    return self.navigationController.navigationBar.xl_backgroundView.bounds.size.height;
}

- (UIStatusBarStyle)xl_preferredStatusBarStyle {
    return self.xl_statusBarStyle;
}

- (BOOL)xl_prefersStatusBarHidden {
    return self.xl_statusBarHidden;
}

- (void)xl_viewDidLoad {
    self.navigationController.navigationBar.xl_colorView = [[UIView alloc] init];
    [self xl_viewDidLoad];
}

- (void)xl_viewWillAppear:(BOOL)animated {
    
    if (![self isEqual:self.navigationController.topViewController]) {
        [self xl_viewWillAppear:animated];
        return;
    }
    
    //设置标题颜色
    NSDictionary *attributes = self.xl_barTitleColor ? @{NSForegroundColorAttributeName:self.xl_barTitleColor} : nil;
    self.navigationController.navigationBar.titleTextAttributes = attributes;
    
    //设置按钮颜色
    self.navigationController.navigationBar.tintColor = self.xl_barButtonColor;
    
    //设置背景颜色
    self.navigationController.navigationBar.xl_colorView.backgroundColor = self.xl_barBackgroundColor;
    
    //设置透明度
    self.navigationController.navigationBar.xl_backgroundView.alpha = self.xl_barBackgroundAlpha;
    
    //底部阴影隐藏
    UIImage *shadowImage = self.xl_barShadowImageHidden ? [[UIImage alloc] init] : nil;
    self.navigationController.navigationBar.shadowImage = shadowImage;
    
    //更新StatusBar外观
    [self.navigationController setNeedsStatusBarAppearanceUpdate];
    
    //执行系统viewWillAppear方法
    [self xl_viewWillAppear:animated];
}

@end

