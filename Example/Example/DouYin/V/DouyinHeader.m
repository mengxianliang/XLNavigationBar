//
//  DouYinHeader.m
//  Example
//
//  Created by MengXianLiang on 2020/5/22.
//  Copyright © 2020 mxl. All rights reserved.
//

#import "DouyinHeader.h"

@implementation DouyinHeader

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self buildUI];
    }
    return self;
}

- (void)buildUI {
    
    self.backgroundColor = [UIColor colorWithRed:23/255.0f green:23/255.0f blue:34/255.0f alpha:1];
    
    CGFloat iconH = 90;
    
    CGFloat labelHeight = 30.0f;
    
    //设置背景图
    self.backgroundImage = [UIImage imageNamed:@"douyinHeader"];
    //设置背景图缩进
    self.backgroundImageInsets = UIEdgeInsetsMake(0, 0, labelHeight + labelHeight + iconH - 15, 0);
    
    //自定义内容
    UILabel *numberLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, self.bounds.size.height - labelHeight - 5, 200, labelHeight)];
    numberLabel.text = @"Number:12345678";
    numberLabel.textColor = [UIColor whiteColor];
    numberLabel.font = [UIFont boldSystemFontOfSize:15];
    [self addSubview:numberLabel];
    
    UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, CGRectGetMinY(numberLabel.frame) - labelHeight, 200, labelHeight)];
    nameLabel.text = @"Douyin";
    nameLabel.textColor = [UIColor whiteColor];
    nameLabel.font = [UIFont boldSystemFontOfSize:20];
    [self addSubview:nameLabel];
    
    UIImageView *icon = [[UIImageView alloc] initWithFrame:CGRectMake(15, CGRectGetMinY(nameLabel.frame) - iconH, iconH, iconH)];
    icon.image = [UIImage imageNamed:@"Icon"];
    icon.layer.cornerRadius = iconH/2.0f;
    icon.clipsToBounds = true;
    icon.layer.borderWidth = 2;
    icon.layer.borderColor = [UIColor colorWithRed:23/255.0f green:23/255.0f blue:34/255.0f alpha:1].CGColor;
    [self addSubview:icon];
    
    
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, self.bounds.size.height, self.bounds.size.width, 1)];
    line.backgroundColor = [UIColor colorWithRed:50/255.0f green:50/255.0f blue:50/255.0f alpha:1];
    [self addSubview:line];
}

@end
