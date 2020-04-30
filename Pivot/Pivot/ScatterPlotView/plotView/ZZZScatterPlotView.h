/*********************************************************************
 * 版权所有   magic_Zzz
 *
 * 文件名称： ZZZScatterPlotView 图形容器
 * 内容摘要： 图形视图
 * 其它说明： 头文件
 * 作 成 者： ZGD
 * 完成日期： 2016年03月08日
 * 修改记录1：
 * 修改日期：
 * 修 改 人：
 * 修改内容：
 * 修改记录2：
 **********************************************************************/

#import <UIKit/UIKit.h>
#import "Common.h"

#define MAX_XAXES 100
#define MAX_YAXES 0.0004
#define MAX_YAXES_INT 0.0001
#define MAX_BAR_WIDTH 10

#define ZZZBARPLOT1      @"barplot0"  // 曲线1
#define ZZZBARPLOT2      @"barplot1" // 曲线2
#define ZZZBARPLOT3      @"barplot2" // 曲线3
#define ZZZBARPLOT4      @"barplot3" // 曲线4
#define ZZZBARPLOT5      @"barplot4" // 曲线5
#define ZZZBARPLOT6      @"barplot5" // 曲线6

@interface ZZZScatterPlotView : UIView

@property (nonatomic) ZZZPLOTSTYLE     plotStyle;// 图形样式
@property (nonatomic, strong) NSString *yTitle;// y轴名称
@property (nonatomic, strong) NSString *yUnit;//y轴单位
 

/***********************************************************************
 * 方法名称： - (void)initPlotWithDict:(NSDictionary *)dict
 * 功能描述： 初始化数据
 * 输入参数：
 * 输出参数：
 * 返 回 值：
 ***********************************************************************/
- (void)initPlotWithDict:(NSDictionary *)dict;


/***********************************************************************
 * 方法名称： - (void)reloadPlotWithStyle:(ZZZPLOTSTYLE)style withData:(NSDictionary *)dict
 * 功能描述： 选择样式刷新视图
 * 输入参数：
 * 输出参数：
 * 返 回 值：
 ***********************************************************************/
- (void)reloadPlotWithStyle:(ZZZPLOTSTYLE)style withData:(NSDictionary *)dict;

@end
