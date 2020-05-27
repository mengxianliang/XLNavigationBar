//
//  ViewController2.m
//  Example
//
//  Created by mxl on 2020/5/25.
//  Copyright © 2020 mxl. All rights reserved.
//

#import "ViewController2.h"
#import "XLNavigationBar.h"
#import "ViewController.h"

@interface ViewController2 ()

@end

@implementation ViewController2

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"TestVC2";
    self.xl_navBarBackgroundColor = [UIColor purpleColor];
    self.xl_navBarTitleColor = [UIColor whiteColor];
    self.xl_navBarButtonColor = [UIColor whiteColor];
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    ViewController *vc = [[ViewController alloc] init];
    [self.navigationController pushViewController:vc animated:NO];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
