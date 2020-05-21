//
//  ExampleVC.m
//  Example
//
//  Created by mxl on 2020/5/21.
//  Copyright © 2020 mxl. All rights reserved.
//

#import "ExampleVC.h"
#import "ExampleVC2.h"
#import "XLNavigationBar.h"

@interface ExampleVC ()<UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate>

@property (nonatomic, strong) UITableView *tableView;

@end

@implementation ExampleVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.xl_barBackgroundColor = [UIColor redColor];
    self.xl_barTitleColor = [UIColor whiteColor];
    self.xl_barButtonColor = [UIColor whiteColor];
    self.xl_statusBarStyle = UIStatusBarStyleLightContent;
//    self.xl_barBackgroundAlpha = 0;
//    self.xl_statusBarHidden = YES;
    
    [self buildTable];
}

- (void)buildTable {
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    if (@available(iOS 11.0, *)) {
        self.tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    [self.view addSubview:self.tableView];
    
    UIView *header = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 300)];
    header.backgroundColor = [UIColor purpleColor];
    self.tableView.tableHeaderView = header;
    
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    self.tableView.frame = self.view.bounds;
}

#pragma mark -
#pragma mark TableViewDelegate&DataSource

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat y = scrollView.contentOffset.y;
    CGFloat alpha = y/(self.tableView.tableHeaderView.bounds.size.height - self.xl_barHeight);
    if (alpha < 0) {
        alpha = 0;
    }
    NSLog(@"y = %f, alpha = %f", y, alpha);
    self.xl_barBackgroundAlpha = alpha;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 20;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString* cellIdentifier = @"cell";
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    cell.textLabel.text = @"表格";
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    ExampleVC2 *vc = [[ExampleVC2 alloc] init];
    [self.navigationController pushViewController:vc animated:true];
}

@end
