//
//  ZZZBarPlotView.h
//  Pivot
//
//  Created by djh on 16/3/14.
//  Copyright © 2016年 bos. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CorePlot-CocoaTouch.h"
#import "ZZZScatterPlotView.h"
#import "Common.h"

@protocol ZZZBarPlotViewDelegate <NSObject>

@optional
- (void)didSelectBar:(NSUInteger)idx identi:(NSString *)identi withX:(CGFloat)xVal withY:(CGFloat)yVal;
- (void)didSelectPie:(NSUInteger)idx identi:(NSString *)identi withX:(CGFloat)xVal withY:(CGFloat)yVal withRate:(NSString *)rate;
@end

@interface ZZZBarPlotView : CPTGraphHostingView
@property (nonatomic, assign) id<ZZZBarPlotViewDelegate> delegate;
@property (nonatomic) ZZZPLOTSTYLE     plotStyle;// 图形样式
@property (nonatomic, strong) NSString *yTitle;// y轴名称
@property (nonatomic, strong) NSString *yUnit;//y轴单位

/***********************************************************************
 * 方法名称： - (void)reloadByDidSelect:(NSDictionary *)dict
 * 功能描述： 选择列表按钮刷新
 * 输入参数：
 * 输出参数：
 * 返 回 值：
 ***********************************************************************/
- (void)reloadByDidSelect:(NSDictionary *)dict;


/***********************************************************************
 * 方法名称： - (void)reloadPlotWithStyle:(ZZZPLOTSTYLE)style withData:(NSDictionary *)dict
 * 功能描述： 选择样式刷新视图
 * 输入参数：
 * 输出参数：
 * 返 回 值：
 ***********************************************************************/
- (void)reloadPlotWithStyle:(ZZZPLOTSTYLE)style withData:(NSDictionary *)dict;

@end
