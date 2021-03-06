//
//  WeiBoHeader.m
//  Example
//
//  Created by MengXianLiang on 2020/5/22.
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
    
    self.backgroundImage = [UIImage imageNamed:@"weiboHeader"];
    
   
    UIImageView *icon = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 90, 90)];
    icon.image = [UIImage imageNamed:@"Icon"];
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
