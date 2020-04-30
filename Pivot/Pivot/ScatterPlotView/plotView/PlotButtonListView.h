/*********************************************************************
 * 版权所有   magic_Zzz
 *
 * 文件名称： PlotButtonListView
 * 内容摘要： 按扭列表view
 * 其它说明： 头文件
 * 作 成 者： ZGD
 * 完成日期： 2016年03月22日
 * 修改记录1：
 * 修改日期：
 * 修 改 人：
 * 修改内容：
 * 修改记录2：
 **********************************************************************/

#import <UIKit/UIKit.h>
#import "Common.h"

@protocol PlotButtonListViewDelegate <NSObject>

@optional
- (void)didChangeSelected:(NSDictionary *)dict;

@end

@interface PlotButtonListView : UIView

@property (nonatomic, assign) id<PlotButtonListViewDelegate> delegate;
@property (nonatomic) ZZZPLOTSTYLE  curStyle;

/***********************************************************************
 * 方法名称： - (instancetype)initWithFrame:(CGRect)frame withData:(NSArray *)arr
 * 功能描述： 初始化按扭列表
 * 输入参数：
 * 输出参数：
 * 返 回 值：
 ***********************************************************************/
- (instancetype)initWithFrame:(CGRect)frame;

/***********************************************************************
 * 方法名称： - (void)reloadSelectedCell:(NSDictionary *)sDict total:(NSArray *)arr
 * 功能描述： 重载选中按扭
 * 输入参数：
 * 输出参数：
 * 返 回 值：
 ***********************************************************************/
- (void)reloadSelectedCell:(NSDictionary *)sDict total:(NSArray *)arr;
@end
