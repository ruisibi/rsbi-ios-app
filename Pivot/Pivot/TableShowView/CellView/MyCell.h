//
//  MyCell.h
//  表格
//
//  Created by zzy on 14-5-6.
//  Copyright (c) 2014年 zzy. All rights reserved.
//
#define kWidthMargin 1
#define kHeightMargin 3
#import <UIKit/UIKit.h>
#import "Common.h"
@class MyCell,HeadView,MeetModel;

@protocol MyCellDelegate <NSObject>

-(void)myHeadView:(HeadView *)headView point:(CGPoint)point;

@end

@interface MyCell : UITableViewCell

- (id)initCellWithCount:(int)count;

- (void)setCellArray:(NSMutableArray *)arr;

-(void)setMsgCellArray:(NSMutableArray *)arr;

@property (nonatomic,strong) NSMutableArray *currentTime;
@property (nonatomic,assign) int index;
@end
