/*********************************************************************
 * 版权所有   magic_Zzz
 *
 * 文件名称： UserStoreView
 * 内容摘要： 用户收藏列表
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
#import "MainListViewController.h"

@interface UserStoreView : UIView
@property (nonatomic,strong) MainListViewController *parent;

-(void)beginRefreshTable;
@end
