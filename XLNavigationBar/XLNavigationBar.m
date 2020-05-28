//
//  XLNavigationBar.m
//  Example
//
//  Created by MengXianLiang on 2020/5/21.
//  Copyright © 2020 mxl. All rights reserved.
//

#import "XLNavigationBar.h"
#import <objc/runtime.h>

#pragma mark -------------------------------------------------------------------------------------------------------------------------
#pragma mark XLNavigationBar

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

#pragma mark -------------------------------------------------------------------------------------------------------------------------
#pragma mark UIColor + Transform

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

#pragma mark -------------------------------------------------------------------------------------------------------------------------
#pragma mark NSObject + swizzle

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

#pragma mark -------------------------------------------------------------------------------------------------------------------------
#pragma mark UINavigationBar + extension

static NSString *XLBarColorViewKey = @"XLBarColorViewKey";
static NSInteger XLBarColorViewTag = 666666;

static NSString *XLBarTempColorViewKey = @"XLBarTempColorViewKey";
static NSInteger XLBarTempColorViewTag = 7777777;

@interface UINavigationBar (XLExtension)

@property (nonatomic, strong) UIView *xl_colorView;

@property (nonatomic, strong) UIView *xl_tempColorView;

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
    [self.xl_backgroundView addSubview:xl_colorView];
    [self setNeedsDisplay];
}

- (UIView *)xl_colorView {
    return objc_getAssociatedObject(self, &XLBarColorViewKey);
}

- (void)setXl_tempColorView:(UIView *)xl_tempColorView {
    objc_setAssociatedObject(self, &XLBarTempColorViewKey,
    xl_tempColorView, OBJC_ASSOCIATION_RETAIN);
    xl_tempColorView.tag = XLBarTempColorViewTag;
    for (UIView *subview in self.xl_backgroundView.subviews) {
        if (subview.tag == XLBarTempColorViewTag) {
            [subview removeFromSuperview];
        }
    }
    [self.xl_backgroundView insertSubview:xl_tempColorView belowSubview:self.xl_colorView];
    [self setNeedsDisplay];
}

- (UIView *)xl_tempColorView {
    return objc_getAssociatedObject(self, &XLBarTempColorViewKey);
}

- (void)xl_layoutSubviews {
    self.xl_colorView.frame = self.xl_backgroundView.bounds;
    self.xl_tempColorView.frame = self.xl_backgroundView.bounds;
    [self xl_layoutSubviews];
}

- (UIView *)xl_backgroundView {
    return self.subviews.firstObject;
}

@end

#pragma mark -------------------------------------------------------------------------------------------------------------------------
#pragma mark UINavigationController + extension

@interface UINavigationController (XLExtension)

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

- (void)xl_updateInteractiveTransition:(CGFloat)percentComplete {
    [self xl_updateInteractiveTransition:percentComplete];
    if (![XLNavigationBar shareInstance].enabled) {return;}
    self.navigationBar.tintColor = [self.xl_fromeVC.xl_navBarButtonColor transformTo:self.xl_toVC.xl_navBarButtonColor progress:percentComplete];
    
}

- (UIViewController *)xl_fromeVC {
    return [self.topViewController.transitionCoordinator viewControllerForKey:UITransitionContextFromViewControllerKey];
}

- (UIViewController *)xl_toVC {
    return [self.topViewController.transitionCoordinator viewControllerForKey:UITransitionContextToViewControllerKey];
}

@end

#pragma mark -------------------------------------------------------------------------------------------------------------------------
#pragma mark UIViewController + transition


@interface UIViewController (XLBarTransition)<UINavigationControllerDelegate>

@end

@implementation UIViewController (XLBarTransition)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self swizzleSelector:@selector(viewWillAppear:) withSelector:@selector(xl_transition_viewWillAppear:)];
        [self swizzleSelector:@selector(viewWillDisappear:) withSelector:@selector(xl_transition_viewWillDisappear:)];
    });
}

- (void)xl_transition_viewWillAppear:(BOOL)animated {
    [self xl_transition_viewWillAppear:animated];
    if ([XLNavigationBar shareInstance].enabled) {
        self.navigationController.delegate = self;
    }
}

- (void)xl_transition_viewWillDisappear:(BOOL)animated {
    [self xl_transition_viewWillDisappear:animated];
    if ([XLNavigationBar shareInstance].enabled) {
        self.navigationController.delegate = nil;
    }
}

#pragma mark -
#pragma mark navigation controller delegate
- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    
    //updante background color when show new vc
    [self updateNavigationBarBackgroundColor];
    
    //drag back end
    id <UIViewControllerTransitionCoordinator>tc = navigationController.topViewController.transitionCoordinator;
    [tc notifyWhenInteractionChangesUsingBlock:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
        CGFloat duration = tc.cancelled ? tc.transitionDuration*tc.percentComplete : tc.transitionDuration*(1-tc.percentComplete);
        [UIView animateWithDuration:duration animations:^{
            self.navigationController.navigationBar.tintColor = tc.cancelled ? self.navigationController.xl_fromeVC.xl_navBarButtonColor : self.navigationController.xl_toVC.xl_navBarButtonColor;
        }];
    }];
    
    // animation end by canclled
    [tc animateAlongsideTransition:nil completion:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
        if (tc.cancelled) {
            [self resetNavigationBarBackgroundColor];
        }
    }];
}

// did show new viewController
- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    [self resetNavigationBarBackgroundColor];
}


//update navbar background color
- (void)updateNavigationBarBackgroundColor {
    
    self.navigationController.navigationBar.xl_backgroundView.alpha = 0;

    [self.navigationController.navigationBar.xl_colorView removeFromSuperview];
    self.navigationController.navigationBar.xl_colorView.backgroundColor = self.navigationController.xl_toVC.xl_navBarBackgroundColor;
    self.navigationController.navigationBar.xl_colorView.alpha = self.navigationController.xl_toVC.xl_navBarBackgroundAlpha;
    [self.navigationController.xl_toVC.view addSubview:self.navigationController.navigationBar.xl_colorView];

    [self.navigationController.navigationBar.xl_tempColorView removeFromSuperview];
    self.navigationController.navigationBar.xl_tempColorView.backgroundColor = self.navigationController.xl_fromeVC.xl_navBarBackgroundColor;
    self.navigationController.navigationBar.xl_tempColorView.alpha = self.navigationController.xl_fromeVC.xl_navBarBackgroundAlpha;
    [self.navigationController.xl_fromeVC.view addSubview:self.navigationController.navigationBar.xl_tempColorView];
}

//reset navbar background color
- (void)resetNavigationBarBackgroundColor {
    
    self.navigationController.navigationBar.xl_backgroundView.alpha = self.navigationController.topViewController.xl_navBarBackgroundAlpha;

    [self.navigationController.navigationBar.xl_colorView removeFromSuperview];
    self.navigationController.navigationBar.xl_colorView = self.navigationController.navigationBar.xl_colorView;
    self.navigationController.navigationBar.xl_colorView.alpha = 1;
    self.navigationController.navigationBar.xl_colorView.backgroundColor = self.navigationController.topViewController.xl_navBarBackgroundColor;

    [self.navigationController.navigationBar.xl_tempColorView removeFromSuperview];
    self.navigationController.navigationBar.xl_tempColorView = self.navigationController.navigationBar.xl_tempColorView;
    self.navigationController.navigationBar.xl_tempColorView.alpha = 1;
    self.navigationController.navigationBar.xl_tempColorView.backgroundColor = nil;
}


@end

#pragma mark -------------------------------------------------------------------------------------------------------------------------
#pragma mark UIViewController + extension

static NSString *XLBarBackgroundColorKey = @"XLBarBackgroundColorKey";
static NSString *XLBarTitleColorKey = @"XLBarTitleColorKey";
static NSString *XLBarTitleFontKey = @"XLBarTitleFontKey";
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
    
    //run system viewDidLoad method
    [self xl_viewDidLoad];
    
    //judge enabled
    if (![XLNavigationBar shareInstance].enabled) {return;}
    
    //add color view
    if (!self.navigationController.navigationBar.xl_colorView) {
        self.navigationController.navigationBar.xl_colorView = [[UIView alloc] initWithFrame:CGRectZero];
    }
    
    //add temp color view
    if (!self.navigationController.navigationBar.xl_tempColorView) {
        self.navigationController.navigationBar.xl_tempColorView = [[UIView alloc] initWithFrame:CGRectZero];
    }
}

- (void)xl_viewWillAppear:(BOOL)animated {
    //run system viewWillAppear method
    [self xl_viewWillAppear:animated];
    
    //only run at topVC
    if (![self isEqual:self.navigationController.topViewController]) {return;}
    
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

