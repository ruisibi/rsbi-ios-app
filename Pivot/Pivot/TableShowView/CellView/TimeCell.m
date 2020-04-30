//
//  TimeCell.m
//  表格
//
//  Created by zzy on 14-5-7.
//  Copyright (c) 2014年 zzy. All rights reserved.
//

#import "TimeCell.h"
#import "MyLabel.h"
#import "Common.h"

@implementation TimeCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.timeLabel=[[HeadView alloc]initWithFrame:CGRectMake(0, 0,kWidth, kHeight)];
//        [self.timeLabel setVerticalAlignment:VerticalAlignmentMiddle];

        [self.contentView addSubview:self.timeLabel];
    }
    return self;
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
