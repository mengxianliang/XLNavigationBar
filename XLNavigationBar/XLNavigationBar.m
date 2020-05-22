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

@implementation XLNavigationBar

+ (instancetype)shareInstance {
    static XLNavigationBar *bar = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        bar = [[XLNavigationBar alloc] init];
    });
    return bar;
}

@end

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
    if (![XLNavigationBar shareInstance].enabled) {
        return [self xl_preferredStatusBarStyle];
    }
    return self.topViewController.preferredStatusBarStyle;
}

- (BOOL)xl_prefersStatusBarHidden {
    if (![XLNavigationBar shareInstance].enabled) {
        return [self xl_prefersStatusBarHidden];
    }
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

- (void)setXl_navBarBackgroundColor:(UIColor *)xl_navBarBackgroundColor {
    objc_setAssociatedObject(self, &XLBarBackgroundColorKey,
    xl_navBarBackgroundColor, OBJC_ASSOCIATION_COPY);
    [self updateNavigationBarAppearance];
}

- (UIColor *)xl_navBarBackgroundColor {
    return objc_getAssociatedObject(self, &XLBarBackgroundColorKey);;
}

- (void)setXl_navBarTitleColor:(UIColor *)xl_navBarTitleColor {
    objc_setAssociatedObject(self, &XLBarTitleColorKey,
    xl_navBarTitleColor, OBJC_ASSOCIATION_COPY);
    [self updateNavigationBarAppearance];
}

- (UIColor *)xl_navBarTitleColor {
    return objc_getAssociatedObject(self, &XLBarTitleColorKey);
}

- (void)setXl_navBarButtonColor:(UIColor *)xl_navBarButtonColor {
    objc_setAssociatedObject(self, &XLBarButtonColorKey,
    xl_navBarButtonColor, OBJC_ASSOCIATION_COPY);
    [self updateNavigationBarAppearance];
}

- (UIColor *)xl_navBarButtonColor {
    return objc_getAssociatedObject(self, &XLBarButtonColorKey);
}

- (void)setXl_statusBarStyle:(UIStatusBarStyle)xl_statusBarStyle {
    objc_setAssociatedObject(self, &XLStatusBarStyleKey,
    @(xl_statusBarStyle), OBJC_ASSOCIATION_COPY);
    //updateStatusBarAppearance
    [self.navigationController setNeedsStatusBarAppearanceUpdate];
}

- (UIStatusBarStyle)xl_statusBarStyle {
    return (UIStatusBarStyle)[objc_getAssociatedObject(self, &XLStatusBarStyleKey) integerValue];
}

- (void)setXl_statusBarHidden:(BOOL)xl_statusBarHidden {
    objc_setAssociatedObject(self, &XLStatusBarHiddenKey,
    @(xl_statusBarHidden), OBJC_ASSOCIATION_COPY);
    //updateStatusBarAppearance
    [self.navigationController setNeedsStatusBarAppearanceUpdate];
}

- (BOOL)xl_statusBarHidden {
    return [objc_getAssociatedObject(self, &XLStatusBarHiddenKey) boolValue];
}

- (void)setXl_navBarShadowImageHidden:(BOOL)xl_navBarShadowImageHidden {
    objc_setAssociatedObject(self, &XLBarShadowImageHiddenKey,
    @(xl_navBarShadowImageHidden), OBJC_ASSOCIATION_COPY);
    [self updateNavigationBarAppearance];
}

- (BOOL)xl_navBarShadowImageHidden {
    return [objc_getAssociatedObject(self, &XLBarShadowImageHiddenKey) boolValue];
}

- (void)setXl_navBarBackgroundAlpha:(float)xl_navBarBackgroundAlpha {
    objc_setAssociatedObject(self, &XLBarBackgroundAlphaKey,
    @(xl_navBarBackgroundAlpha), OBJC_ASSOCIATION_COPY);
    [self updateNavigationBarAppearance];
}

- (float)xl_navBarBackgroundAlpha {
    id obj = objc_getAssociatedObject(self, &XLBarBackgroundAlphaKey);
    if (!obj) {return 1;}
    return [obj floatValue];
}

- (CGFloat)xl_navBarHeight {
    return self.navigationController.navigationBar.xl_backgroundView.bounds.size.height;
}

- (UIStatusBarStyle)xl_preferredStatusBarStyle {
    if (![XLNavigationBar shareInstance].enabled) {
        return [self xl_preferredStatusBarStyle];
    }
    return self.xl_statusBarStyle;
}

- (BOOL)xl_prefersStatusBarHidden {
    if (![XLNavigationBar shareInstance].enabled) {
        return [self xl_prefersStatusBarHidden];
    }
    return self.xl_statusBarHidden;
}

- (void)xl_viewDidLoad {
    
    //judge enabled
    if (![XLNavigationBar shareInstance].enabled) {
        [self xl_viewDidLoad];
    }
    
    //add color view
    if (!self.navigationController.navigationBar.xl_colorView) {
        self.navigationController.navigationBar.xl_colorView = [[UIView alloc] initWithFrame:CGRectZero];
    }
    
    //run system viewDidLoad method
    [self xl_viewDidLoad];
}

- (void)xl_viewWillAppear:(BOOL)animated {
    
    //only run at topVC
    if (![self isEqual:self.navigationController.topViewController]) {
        [self xl_viewWillAppear:animated];
        return;
    }
    
    //update navigation bar appearance
    [self updateNavigationBarAppearance];
    
    //update status bar appearance
    [self.navigationController setNeedsStatusBarAppearanceUpdate];
    
    //run system viewWillAppear method
    [self xl_viewWillAppear:animated];
}

///updateNavigationBar apperance. rule: set global appearance first, set current appearance next
- (void)updateNavigationBarAppearance {
    
    // global appearance
    XLNavigationBar *xlNavigationBar = [XLNavigationBar shareInstance];
    
    //judge enabled
     if (!xlNavigationBar.enabled) {return;}
    
    //set title color
    NSDictionary *currentAttributes = self.navigationController.navigationBar.titleTextAttributes;
    if (!currentAttributes) {
        currentAttributes = [[NSDictionary alloc] init];
    }
    UIColor *titleColor = [currentAttributes objectForKey:NSForegroundColorAttributeName];
    if (xlNavigationBar.xl_navBarTitleColor) {
        titleColor = xlNavigationBar.xl_navBarTitleColor;
    }
    if (self.xl_navBarTitleColor) {
        titleColor = self.xl_navBarTitleColor;
    }
    NSMutableDictionary *newAttributes = [NSMutableDictionary dictionaryWithDictionary:currentAttributes];
    if (titleColor) {
        [newAttributes setObject:titleColor forKey:NSForegroundColorAttributeName];
    }
    self.navigationController.navigationBar.titleTextAttributes = newAttributes;
    
    //set button color
    UIColor *barButtonColor = xlNavigationBar.xl_navBarButtonColor;
    if (self.xl_navBarButtonColor) {
        barButtonColor = self.xl_navBarButtonColor;
    }
    self.navigationController.navigationBar.tintColor = barButtonColor;
    
    //set background color
    UIColor *barBackgroundColor = xlNavigationBar.xl_navBarBackgroundColor;
    if (self.xl_navBarBackgroundColor) {
        barBackgroundColor = self.xl_navBarBackgroundColor;
    }
    self.navigationController.navigationBar.xl_colorView.backgroundColor = barBackgroundColor ? barBackgroundColor : [UIColor whiteColor];
    
    //set background alpha
    float barBackgroundAlpha = xlNavigationBar.xl_navBarBackgroundAlpha;
    if (self.xl_navBarBackgroundAlpha != 1) {
        barBackgroundAlpha = self.xl_navBarBackgroundAlpha;
    }
    self.navigationController.navigationBar.xl_backgroundView.alpha = barBackgroundAlpha;
    
    //set shadow image hidden
    bool barShadowImageHidden = xlNavigationBar.xl_navBarShadowImageHidden;
    if (self.xl_navBarShadowImageHidden) {
        barShadowImageHidden = self.xl_navBarShadowImageHidden;
    }
    UIImage *shadowImage = barShadowImageHidden ? [[UIImage alloc] init] : nil;
    self.navigationController.navigationBar.shadowImage = shadowImage;
    
}

@end

