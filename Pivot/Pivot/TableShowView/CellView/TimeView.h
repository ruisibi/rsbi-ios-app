//
//  TimeView.h
//  表格
//
//  Created by zzy on 14-5-6.
//  Copyright (c) 2014年 zzy. All rights reserved.
//
#define kHeightMargin 3
#import <UIKit/UIKit.h>
#import "Common.h"

@protocol TimeViewDelegate <NSObject>

@optional
-(void)timeViewDidScroll:(CGPoint)offset;

@end
@interface TimeView : UIView
- (id)initWithFrame:(CGRect)frame marginTop:(CGFloat)marginTop dataArray:(NSMutableArray *)arr;
@property (nonatomic,strong) UITableView *timeTableView;
@property (nonatomic,assign) id<TimeViewDelegate> delegate;
@end
