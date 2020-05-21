//
//  ViewController.m
//  Example
//
//  Created by mxl on 2020/5/21.
//  Copyright © 2020 mxl. All rights reserved.
//

#import "ViewController.h"
#import "ExampleVC.h"


@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    ExampleVC *vc = [[ExampleVC alloc] init];
    vc.title = @"测试";
    [self.navigationController pushViewController:vc animated:YES];
}

@end
