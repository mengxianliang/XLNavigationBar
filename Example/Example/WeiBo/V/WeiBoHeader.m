//
//  WeiBoHeader.m
//  Example
//
//  Created by mxl on 2020/5/22.
//  Copyright © 2020 mxl. All rights reserved.
//

#import "WeiBoHeader.h"

@implementation WeiBoHeader

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self buildUI];
    }
    return self;
}

- (void)buildUI {
    //设置背景图
    self.image = [UIImage imageNamed:@"weiboHeader"];
    
    //自定义内容
    UIImageView *icon = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 80, 80)];
    icon.image = [UIImage imageNamed:@"test_icon"];
    icon.center = CGPointMake(self.bounds.size.width/2.0f, self.bounds.size.height/2.0f);
    icon.layer.cornerRadius = icon.bounds.size.height/2.0f;
    icon.clipsToBounds = true;
    icon.layer.borderWidth = 2;
    icon.layer.borderColor = [UIColor colorWithWhite:1 alpha:0.5].CGColor;
    [self addSubview:icon];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(icon.frame) + 20, 120, 30)];
    label.center = CGPointMake(icon.center.x, label.center.y);
    label.text = @"WeiBo";
    label.textColor = [UIColor whiteColor];
    label.font = [UIFont boldSystemFontOfSize:17];
    label.textAlignment = NSTextAlignmentCenter;
    [self addSubview:label];
}

@end
