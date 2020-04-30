/*********************************************************************
 * 版权所有   magic_Zzz
 *
 * 文件名称： ParameterListViewController
 * 内容摘要： // 维度或者度量选择
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



typedef enum {
    ParameterTypeWeiDu1 = 0,  // 维度1
    ParameterTypeWeiDu2 ,  // 维度2
    ParameterTypeWeiDu3 ,  // 维度3
    ParameterTypeDuliang, // 度量
    ParameterTypeWeiDuPush //推送特殊
} ParameterType;

@protocol ParameterSelectDelegate <NSObject>

@optional
- (void)didSelectDict:(NSDictionary *)tDict pType:(ParameterType)pType;

@end

@interface ParameterListViewController : UIViewController

@property (nonatomic, assign) id<ParameterSelectDelegate> delegate;
@property (nonatomic) ParameterType     currentType;// 当前选择参数
@property (nonatomic, strong) NSDictionary  *tmpDict;// 不能用的id 不能用的类型
@property (nonatomic, strong) NSString  *selectTid;// 表id
@property (nonatomic, strong) NSDictionary *defDict;// 默认选中
@end
