//
//  AppDelegate.m
//  Example
//
//  Created by mxl on 2020/5/21.
//  Copyright © 2020 mxl. All rights reserved.
//

#import "AppDelegate.h"
#import "ViewController.h"
#import "XLNavigationBar.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    ViewController *vc = [[ViewController alloc] init];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
    self.window.rootViewController = nav;
    
    //开启 XLNavigationBar
    [XLNavigationBar shareInstance].enabled = YES;
    //全局配置
    [XLNavigationBar shareInstance].xl_navBarTitleColor = [UIColor greenColor];
    [XLNavigationBar shareInstance].xl_navBarButtonColor = [UIColor blueColor];
    [XLNavigationBar shareInstance].xl_navBarBackgroundColor = [UIColor yellowColor];
    
    return YES;
}


@end
