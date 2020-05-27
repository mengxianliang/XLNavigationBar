//
//  XLNavigationBar.m
//  Example
//
//  Created by MengXianLiang on 2020/5/21.
//  Copyright © 2020 mxl. All rights reserved.
//

#import "XLNavigationBar.h"
#import <objc/runtime.h>

//------------------------------------------------------------------------------------------

@interface UIColor (Transform)

- (UIColor *)transformTo:(UIColor *)toColor progress:(CGFloat)progress;

@end

@implementation UIColor (Transform)

- (UIColor *)transformTo:(UIColor *)toColor progress:(CGFloat)progress {
    UIColor *fromColor = [UIColor colorWithCGColor:self.CGColor];
    if (!fromColor || !toColor) {
        NSLog(@"Warning !!! color is nil");
        return [UIColor blackColor];
    }
    progress = progress >= 1 ? 1 : progress;
    progress = progress <= 0 ? 0 : progress;
    const CGFloat * fromeComponents = CGColorGetComponents(fromColor.CGColor);
    const CGFloat * toComponents = CGColorGetComponents(toColor.CGColor);
    size_t  fromColorNumber = CGColorGetNumberOfComponents(fromColor.CGColor);
    size_t  toColorNumber = CGColorGetNumberOfComponents(toColor.CGColor);
    if (fromColorNumber == 2) {
        CGFloat white = fromeComponents[0];
        fromColor = [UIColor colorWithRed:white green:white blue:white alpha:1];
        fromeComponents = CGColorGetComponents(fromColor.CGColor);
    }
    if (toColorNumber == 2) {
        CGFloat white = toComponents[0];
        toColor = [UIColor colorWithRed:white green:white blue:white alpha:1];
        toComponents = CGColorGetComponents(toColor.CGColor);
    }
    CGFloat red = fromeComponents[0]*(1 - progress) + toComponents[0]*progress;
    CGFloat green = fromeComponents[1]*(1 - progress) + toComponents[1]*progress;
    CGFloat blue = fromeComponents[2]*(1 - progress) + toComponents[2]*progress;
    return [UIColor colorWithRed:red green:green blue:blue alpha:1];
}

@end

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

static NSString *XLBarRightColorViewKey = @"XLBarRightColorViewKey";
static NSInteger XLBarRightColorViewTag = 7777777;

@interface UINavigationBar (XLExtension)

@property (nonatomic, strong) UIView *xl_colorView;

@property (nonatomic, strong) UIView *xl_rightColorView;

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
//    [self.xl_backgroundView insertSubview:xl_colorView atIndex:0];
    [self.xl_backgroundView addSubview:xl_colorView];
    [self setNeedsDisplay];
}

- (UIView *)xl_colorView {
    return objc_getAssociatedObject(self, &XLBarColorViewKey);
}

- (void)setXl_rightColorView:(UIView *)xl_rightColorView {
    objc_setAssociatedObject(self, &XLBarRightColorViewKey,
    xl_rightColorView, OBJC_ASSOCIATION_RETAIN);
    xl_rightColorView.tag = XLBarRightColorViewTag;
    for (UIView *subview in self.xl_backgroundView.subviews) {
        if (subview.tag == XLBarRightColorViewTag) {
            [subview removeFromSuperview];
        }
    }
    [self.xl_backgroundView insertSubview:xl_rightColorView belowSubview:self.xl_colorView];
    [self setNeedsDisplay];
}

- (UIView *)xl_rightColorView {
    return objc_getAssociatedObject(self, &XLBarRightColorViewKey);
}

- (void)xl_layoutSubviews {
    self.xl_colorView.frame = self.xl_backgroundView.bounds;
    self.xl_rightColorView.frame = self.xl_backgroundView.bounds;
    [self xl_layoutSubviews];
}

- (UIView *)xl_backgroundView {
    return self.subviews.firstObject;
}

@end

//------------------------------------------------------------------------------------------

@interface UINavigationController (XLExtension)<UINavigationControllerDelegate>

@property (nonatomic, strong, readonly) UIViewController *xl_fromeVC;

@property (nonatomic, strong, readonly) UIViewController *xl_toVC;

@end

@implementation UINavigationController (XLExtension)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self swizzleSelector:@selector(preferredStatusBarStyle) withSelector:@selector(xl_preferredStatusBarStyle)];
        [self swizzleSelector:@selector(prefersStatusBarHidden) withSelector:@selector(xl_prefersStatusBarHidden)];
        [self swizzleSelector:NSSelectorFromString(@"_updateInteractiveTransition:") withSelector:@selector(xl_updateInteractiveTransition:)];
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

- (void)viewDidLoad {
    self.delegate = self;
}

- (void)xl_updateInteractiveTransition:(CGFloat)percentComplete {
    self.navigationBar.xl_backgroundView.alpha = 0;
    self.navigationBar.tintColor = [self.xl_fromeVC.xl_navBarButtonColor transformTo:self.xl_toVC.xl_navBarButtonColor progress:percentComplete];
    [self xl_updateInteractiveTransition:percentComplete];
}

#pragma mark-
#pragma NavigationDelegate
- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    NSLog(@"导航显示新的视图开始");
    [self updateNavigationBarBackgroundColor];
    
    id <UIViewControllerTransitionCoordinator>tc = navigationController.topViewController.transitionCoordinator;
    [tc notifyWhenInteractionChangesUsingBlock:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
        NSLog(@"手动拖拽返回终端");
        CGFloat duration = tc.cancelled ? tc.transitionDuration*tc.percentComplete : tc.transitionDuration*(1-tc.percentComplete);
        [UIView animateWithDuration:duration animations:^{
            self.navigationBar.tintColor = tc.cancelled ? self.xl_fromeVC.xl_navBarButtonColor : self.xl_toVC.xl_navBarButtonColor;
        }];
        
    }];
    [tc animateAlongsideTransition:nil completion:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
        if (tc.cancelled) {
            NSLog(@"动画结束被取消");
            [self resetNavigationBarBackgroundColor];
        }
    }];
}

- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    NSLog(@"导航显示新的视图结束");
    [self resetNavigationBarBackgroundColor];
}


//开始显示时 更新导航栏背景色
- (void)updateNavigationBarBackgroundColor {
    
    NSLog(@"更新导航栏");
    
    self.navigationBar.xl_backgroundView.alpha = 0;

    [self.navigationBar.xl_colorView removeFromSuperview];
    self.navigationBar.xl_colorView.backgroundColor = self.xl_toVC.xl_navBarBackgroundColor;
    self.navigationBar.xl_colorView.alpha = self.xl_toVC.xl_navBarBackgroundAlpha;
    [self.xl_toVC.view addSubview:self.navigationBar.xl_colorView];

    [self.navigationBar.xl_rightColorView removeFromSuperview];
    self.navigationBar.xl_rightColorView.backgroundColor = self.xl_fromeVC.xl_navBarBackgroundColor;
    self.navigationBar.xl_rightColorView.alpha = self.xl_fromeVC.xl_navBarBackgroundAlpha;
    [self.xl_fromeVC.view addSubview:self.navigationBar.xl_rightColorView];
}

//结束时 恢复背景色
- (void)resetNavigationBarBackgroundColor {
    
    NSLog(@"重置导航栏");
    
    self.navigationBar.xl_backgroundView.alpha = self.topViewController.xl_navBarBackgroundAlpha;

    [self.navigationBar.xl_colorView removeFromSuperview];
    self.navigationBar.xl_colorView = self.navigationBar.xl_colorView;
    self.navigationBar.xl_colorView.alpha = 1;
    self.navigationBar.xl_colorView.backgroundColor = self.topViewController.xl_navBarBackgroundColor;

    [self.navigationBar.xl_rightColorView removeFromSuperview];
    self.navigationBar.xl_rightColorView = self.navigationBar.xl_rightColorView;
    self.navigationBar.xl_rightColorView.alpha = 1;
    self.navigationBar.xl_rightColorView.backgroundColor = nil;
}

- (UIViewController *)xl_fromeVC {
    return [self.topViewController.transitionCoordinator viewControllerForKey:UITransitionContextFromViewControllerKey];
}

- (UIViewController *)xl_toVC {
    return [self.topViewController.transitionCoordinator viewControllerForKey:UITransitionContextToViewControllerKey];
}

@end

//------------------------------------------------------------------------------------------

static NSString *XLBarBackgroundColorKey = @"XLBarBackgroundColorKey";
static NSString *XLBarTitleColorKey = @"XLBarTitleColorKey";
static NSString *XLBarTitleFontKey = @"XLBarTitleFontKey";
static NSString *XLBarButtonColorKey = @"XLBarButtonColorKey";
static NSString *XLStatusBarStyleKey = @"XLStatusBarStyleKey";
static NSString *XLStatusBarHiddenKey = @"XLStatusBarHiddenKey";
static NSString *XLBarShadowImageHiddenKey = @"XLBarShadowImageHiddenKey";
static NSString *XLBarBackgroundAlphaKey = @"XLBarBackgroundAlphaKey";

@interface XLBarExtension

@property (nonatomic, strong) NSString *shit;

@end

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
    [self updateNavigationBarTitleTextAttributes];
}

- (UIColor *)xl_navBarTitleColor {
    return objc_getAssociatedObject(self, &XLBarTitleColorKey);
}

- (void)setXl_navBarTitleFont:(UIFont *)xl_navBarTitleFont {
    objc_setAssociatedObject(self, &XLBarTitleFontKey,
    xl_navBarTitleFont, OBJC_ASSOCIATION_COPY);
    [self updateNavigationBarTitleTextAttributes];
}

- (UIFont *)xl_navBarTitleFont {
    return objc_getAssociatedObject(self, &XLBarTitleFontKey);
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
    //update status bar appearance
    [self.navigationController setNeedsStatusBarAppearanceUpdate];
}

- (UIStatusBarStyle)xl_statusBarStyle {
    return (UIStatusBarStyle)[objc_getAssociatedObject(self, &XLStatusBarStyleKey) integerValue];
}

- (void)setXl_statusBarHidden:(BOOL)xl_statusBarHidden {
    objc_setAssociatedObject(self, &XLStatusBarHiddenKey,
    @(xl_statusBarHidden), OBJC_ASSOCIATION_COPY);
    //update status bar appearance
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
    [self updateNavigationBarBackgroundAlpha];
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
    
    if (!self.navigationController.navigationBar.xl_rightColorView) {
        self.navigationController.navigationBar.xl_rightColorView = [[UIView alloc] initWithFrame:CGRectZero];
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
    
    //update title attributes
    [self updateNavigationBarTitleTextAttributes];

    //update navigation bar appearance,if is draging don't update
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(CGFLOAT_MIN * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        id <UIViewControllerTransitionCoordinator>tc = self.navigationController.topViewController.transitionCoordinator;
        if (!tc.interactive) {
            [self updateNavigationBarAppearance];
        }
    });

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
        
    //set shadow image hidden
    bool barShadowImageHidden = xlNavigationBar.xl_navBarShadowImageHidden;
    if (self.xl_navBarShadowImageHidden) {
        barShadowImageHidden = self.xl_navBarShadowImageHidden;
    }
    UIImage *shadowImage = barShadowImageHidden ? [[UIImage alloc] init] : nil;
    self.navigationController.navigationBar.shadowImage = shadowImage;
}

- (void)updateNavigationBarBackgroundAlpha {
    
    // global appearance
    XLNavigationBar *xlNavigationBar = [XLNavigationBar shareInstance];
    
    //judge enabled
     if (!xlNavigationBar.enabled) {return;}
    
    //set background alpha
    float barBackgroundAlpha = xlNavigationBar.xl_navBarBackgroundAlpha;
    if (self.xl_navBarBackgroundAlpha != 1) {
        barBackgroundAlpha = self.xl_navBarBackgroundAlpha;
    }
    self.navigationController.navigationBar.xl_backgroundView.alpha = barBackgroundAlpha;
}

//update title attributes
- (void)updateNavigationBarTitleTextAttributes {
    // global appearance
    XLNavigationBar *xlNavigationBar = [XLNavigationBar shareInstance];
    
    //judge enabled
     if (!xlNavigationBar.enabled) {return;}
    
    //set title color&font
    NSDictionary *currentAttributes = self.navigationController.navigationBar.titleTextAttributes;
    if (!currentAttributes) {
        currentAttributes = [[NSDictionary alloc] init];
    }
    NSMutableDictionary *newAttributes = [NSMutableDictionary dictionaryWithDictionary:currentAttributes];
    //color
    UIColor *titleColor = xlNavigationBar.xl_navBarTitleColor;
    if (self.xl_navBarTitleColor) {
        titleColor = self.xl_navBarTitleColor;
    }
    if (titleColor) {
        [newAttributes setObject:titleColor forKey:NSForegroundColorAttributeName];
    }
    //font
    UIFont *font = xlNavigationBar.xl_navBarTitleFont;
    if (self.xl_navBarTitleFont) {
        font = self.xl_navBarTitleFont;
    }
    if (font) {
        [newAttributes setObject:font forKey:NSFontAttributeName];
    }
    self.navigationController.navigationBar.titleTextAttributes = newAttributes;
}

@end

