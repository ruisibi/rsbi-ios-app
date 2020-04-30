//
//  AddressListView.h
/*********************************************************************
 * 版权所有   magic_Zzz
 *
 * 文件名称： AddressListView
 * 内容摘要： 下拉列表
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
@protocol AddressListViewDelegate <NSObject>
@optional
- (void)didSelectAddress:(NSString *)iphost;
@end
@interface AddressListView : UIView
@property (nonatomic, assign) id<AddressListViewDelegate> delegate;

/***********************************************************************
 * 方法名称： reloadData
 * 功能描述： 刷新数据
 * 输入参数：
 * 输出参数：
 * 返 回 值：
 ***********************************************************************/
- (void)reloadData;
@end
