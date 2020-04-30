/*********************************************************************
 * 版权所有   magic_Zzz
 *
 * 文件名称： MainTabViewController
 * 内容摘要： // 主切换视图
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

@protocol TokenDismisDelegate <NSObject>

-(void)disMisTabView;
@end

@interface MainTabViewController : UITabBarController
- (void)reloadListOrBadge;
@end
