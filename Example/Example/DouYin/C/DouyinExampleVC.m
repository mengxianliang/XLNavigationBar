//
//  DouyinExampleVC.m
//  Example
//
//  Created by MengXianLiang on 2020/5/22.
//  Copyright © 2020 mxl. All rights reserved.
//

#import "DouyinExampleVC.h"
#import "DouyinHeader.h"
#import "XLNavigationBar.h"

@interface DouyinExampleVC ()<UITableViewDataSource,UITableViewDelegate>

@property (nonatomic, strong) UITableView *tableView;

@end

@implementation DouyinExampleVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initUI];
}

- (void)initUI {
    self.view.backgroundColor = [UIColor colorWithRed:23/255.0f green:23/255.0f blue:34/255.0f alpha:1];
    self.title = @"DouYin";
    [self initTableViewAndHeader];
    [self configNavigationBar];
}

- (void)initTableViewAndHeader {
    
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    if (@available(iOS 11.0, *)) {
        self.tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.view addSubview:_tableView];
    
    DouyinHeader *header = [[DouyinHeader alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.width*0.75)];
    self.tableView.xl_zoomHeader = header;
}

- (void)configNavigationBar {
    self.xl_navBarBackgroundColor = [UIColor colorWithRed:23/255.0f green:23/255.0f blue:34/255.0f alpha:1];
    self.xl_navBarBackgroundAlpha = 0;
    self.xl_navBarTitleColor = [UIColor clearColor];
    self.xl_navBarButtonColor = [UIColor whiteColor];
    self.xl_statusBarStyle = UIStatusBarStyleLightContent;
}

#pragma mark -
#pragma mark TableViewDelegate&DataSource
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    //count some value
    CGFloat contentOffsetY = scrollView.contentOffset.y;
    CGFloat headerHeight = self.tableView.xl_zoomHeader.bounds.size.height;
    CGFloat distance = headerHeight - self.xl_navBarHeight;
    CGFloat targetY = distance - headerHeight;
    CGFloat alpha = (1 - (targetY - contentOffsetY)/distance);
    
    //update colors
    if (contentOffsetY <= targetY) {
        self.xl_navBarTitleColor = [UIColor clearColor];
    }else {
        self.xl_navBarTitleColor = [UIColor whiteColor];
    }
    
    //update background alpha
    self.xl_navBarBackgroundAlpha = alpha;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 30;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString* cellIdentifier = @"cell";
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        cell.backgroundColor = [UIColor clearColor];
        cell.textLabel.textColor = [UIColor colorWithRed:138/255.0f green:139/255.0f blue:145/255.0f alpha:1];;
    }
    cell.textLabel.text = @"Pull me baby !!!";
    return cell;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
