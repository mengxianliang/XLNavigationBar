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
    
    //enable XLNavigationBar
    [XLNavigationBar shareInstance].enabled = YES;
    //global config
    //title color
    [XLNavigationBar shareInstance].xl_navBarTitleColor = [UIColor blackColor];
    //title font
    [XLNavigationBar shareInstance].xl_navBarTitleFont = [UIFont systemFontOfSize:20];
    //background color
    [XLNavigationBar shareInstance].xl_navBarBackgroundColor = [UIColor whiteColor];
    return YES;
}


@end
