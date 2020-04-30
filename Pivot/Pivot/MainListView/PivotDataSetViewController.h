/*********************************************************************
 * 版权所有   magic_Zzz
 *
 * 文件名称： PivotDataSetViewController
 * 内容摘要： 数据透视 --- 数据配置
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

//数据透视 --- 数据配置
@interface PivotDataSetViewController : UIViewController

@property (nonatomic, strong) NSString  *selectTid;//  当前的tid
@property (nonatomic, strong) NSDictionary *historyDict;// 历史数据

@end
