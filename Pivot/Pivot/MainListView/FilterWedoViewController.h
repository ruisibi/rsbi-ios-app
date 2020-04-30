/*********************************************************************
 * 版权所有   magic_Zzz
 *
 * 文件名称： FilterWedoViewController
 * 内容摘要： // 筛选维度
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
#import "ParameterListViewController.h"
@protocol FilterWedoViewControllerDelegate <NSObject>

@optional
-(void)didFilterSelected:(NSArray *)arr withType:(ParameterType)pType wedo:(NSString *)type;

@end
@interface FilterWedoViewController : UIViewController

@property (nonatomic, assign) id<FilterWedoViewControllerDelegate> delegate;

@property (nonatomic) ParameterType     currentType;// 当前选择参数
@property (nonatomic, strong) NSString  *selectTid;// 表id
@property (nonatomic, strong) NSString  *dimId;// 维度ID 对应 col_id 字段
@property (nonatomic, strong) NSDictionary *defDict;// 默认选中
@property (nonatomic, strong) NSString *wedoType;//当前的type可以是day,month和other,注意如果是day,month类型，包括开始和结束两个字段。
@property (nonatomic, strong) NSMutableArray *selectArray;// 选择的参数
@end
