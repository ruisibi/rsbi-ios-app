/*********************************************************************
 * 版权所有   magic_Zzz
 *
 * 文件名称： GraphShowViewController 图形容器
 * 内容摘要： 图形容器
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



@interface GraphShowViewController : UIViewController
@property (nonatomic ,strong) NSMutableDictionary *kpiJson;//表格指标
@property (nonatomic ,strong) NSMutableDictionary *tableRows;//表格行标签
@property (nonatomic ,strong) NSMutableDictionary *tableCols;//表格列标签
@property (nonatomic ,strong) NSMutableDictionary *params;//表格参数
@end
