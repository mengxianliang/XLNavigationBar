//
//  WeiBoExampleVC.m
//  Example
//
//  Created by mxl on 2020/5/22.
//  Copyright © 2020 mxl. All rights reserved.
//

#import "WeiBoExampleVC.h"
#import "WeiBoHeader.h"
#import "XLNavigationBar.h"

@interface WeiBoExampleVC ()<UITableViewDataSource,UITableViewDelegate>

@property (nonatomic, strong) UITableView *tableView;

@end

@implementation WeiBoExampleVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initUI];
}

- (void)initUI {
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"WeiBo";
    [self initTableViewAndHeader];
    [self configNavigationBarDefault];
}

- (void)initTableViewAndHeader {
    
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    if (@available(iOS 11.0, *)) {
        self.tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.view addSubview:_tableView];
    
    WeiBoHeader *header = [[WeiBoHeader alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.width*0.55)];
    self.tableView.xl_zoomHeader = header;
}

- (void)configNavigationBarDefault {
    self.xl_navBarBackgroundColor = [UIColor colorWithRed:250/255.0f green:250/255.0f blue:250/255.0f alpha:1];
    self.xl_navBarBackgroundAlpha = 0;
    self.xl_navBarTitleColor = [UIColor clearColor];
    self.xl_navBarButtonColor = [UIColor whiteColor];
    self.xl_statusBarStyle = UIStatusBarStyleLightContent;
}

- (void)configNavigationBarNew {
    self.xl_navBarButtonColor = [UIColor colorWithRed:96/255.0f green:96/255.0f blue:96/255.0f alpha:1];
    self.xl_navBarTitleColor = [UIColor colorWithRed:50/255.0f green:50/255.0f blue:50/255.0f alpha:1];
    self.xl_statusBarStyle = UIStatusBarStyleDefault;
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
    
    //update background alpha
    self.xl_navBarBackgroundAlpha = alpha;
    
    //update colors
    if (contentOffsetY <= targetY) {
        [self configNavigationBarDefault];
    }else {
        [self configNavigationBarNew];
    }
    
//    NSLog(@"y = %f,headerHeight = %f,distance = %f,targetY = %f,alpha = %f",contentOffsetY, self.tableView.xl_zoomHeader.bounds.size.height, distance,targetY,alpha);
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
    }
    cell.textLabel.text = @"Pull me baby !!!";
    return cell;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
