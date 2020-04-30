/*********************************************************************
 * 版权所有   magic_Zzz
 *
 * 文件名称： RGHudModular.h 遮罩弹出工具类
 * 内容摘要： 遮罩弹出工具类
 * 其它说明： 头文件
 * 作 成 者： ZGD
 * 完成日期： 2015年03月04日
 * 修改记录1：
 * 修改日期：
 * 修 改 人：
 * 修改内容：
 * 修改记录2：
 **********************************************************************/

/***************************************************************************   *
 文件引用
 ***************************************************************************/
#import <Foundation/Foundation.h>
#import "MBProgressHUD.h"

/***************************************************************************   *
 类引用
 ***************************************************************************/
/***************************************************************************   *
 宏定义
 ***************************************************************************/
/***************************************************************************   *
 常量
 ***************************************************************************/
/***************************************************************************   *
 类型定义
 ***************************************************************************/

/***************************************************************************   *
 类定义
 ***************************************************************************/
@interface RGHudModular : NSObject

/*****************************************************************************
 * 方法名称: + (RGHudModular *)getRGHud
 * 功能描述: 获取单例对象
 * 输入参数:
 * 输出参数: RGHudModular
 * 返回值:   此单例类
 * 其它说明:
 *****************************************************************************/
+ (RGHudModular *)getRGHud;

/*****************************************************************************
 * 方法名称: - (void)showPopHudWithMessage:(NSString *)message inWindow:(UIView *)containView
 * 功能描述: 弹出带文字的菊花框整体视图
 * 输入参数: message--弹出的文字;
 * 输出参数:
 * 返回值:
 * 其它说明:
 *****************************************************************************/
- (void)showPopHudWithMessage:(NSString *)message inWindow:(UIView *)containView;

/*****************************************************************************
 * 方法名称: - (void)showPopHudWithMessage:(NSString *)message inView:(UIView *)containView
 * 功能描述: 弹出带文字的菊花框
 * 输入参数: message--弹出的文字;containView--父级视图
 * 输出参数:
 * 返回值:
 * 其它说明:
 *****************************************************************************/
- (void)showPopHudWithMessage:(NSString *)message inView:(UIView *)containView;

/*****************************************************************************
 * 方法名称: - (void)hidePopHudInView:(UIView *)containView*)containView
 * 功能描述: 隐藏弹出框
 * 输入参数: containView--父级视图
 * 输出参数:
 * 返回值:
 * 其它说明:
 *****************************************************************************/
- (void)hidePopHudInView:(UIView *)containView;

/*****************************************************************************
 * 方法名称: - (void)hidePopHudInWindow:(UIView *)containView
 * 功能描述: 隐藏弹出框
 * 输入参数: containView--父级视图
 * 输出参数:
 * 返回值:
 * 其它说明:
 *****************************************************************************/
- (void)hidePopHudInWindow:(UIView *)containView;

/*****************************************************************************
 * 方法名称: - (void)showAutoHudWithMessage:(NSString *)message inView:(UIView *)containView
 * 功能描述: 弹出只文字的提示并自动消失
 * 输入参数: message--弹出的文字;containView--父级视图
 * 输出参数:
 * 返回值:
 * 其它说明:
 *****************************************************************************/
- (void)showAutoHudWithMessage:(NSString *)message inView:(UIView *)containView afterTime:(float)afterTime;

/*****************************************************************************
 * 方法名称:- (void)showAutoHudWithMessageDefault:(NSString *)message
 * 功能描述: 弹出只文字的提示并自动消失
 * 输入参数: message--弹出的文字;containView--父级视图
 * 输出参数:
 * 返回值:
 * 其它说明:
 *****************************************************************************/
- (void)showAutoHudWithMessageDefault:(NSString *)message;

/*****************************************************************************
 * 方法名称: - (void)showPophudWithImage:(UIImage *)img showMessage:(NSString *)message backColor:(UIColor *)color inView:(UIView *)containView
 * 功能描述: 弹出图片，文字，背景色自定义
 * 输入参数: img--图片；message--文字(可为空);color--背景色（空的话为默认值;containView--父级视图
 * 输出参数:
 * 返回值:
 * 其它说明:
 *****************************************************************************/
- (void)showPophudWithImage:(UIImage *)img showMessage:(NSString *)message backColor:(UIColor *)color inView:(UIView *)containView;

/*****************************************************************************
 * 方法名称: - (void)showTopHudWithMessage:(NSString *)message inView:(UIView *)containView
 * 功能描述: 在父级View顶部中间弹出一段文字提示并自动消失
 * 输入参数: message--弹出的文字;containView--父级视图
 * 输出参数:
 * 返回值:
 * 其它说明:
 *****************************************************************************/
- (void)showTopHudWithMessage:(NSString *)message inView:(UIView *)containView;

/*****************************************************************************
 * 方法名称: - (void)showBottomHudWithMessage:(NSString *)message inView:(UIView *)containView
 * 功能描述: 在父级View底部中间弹出一段文字提示并自动消失
 * 输入参数: message--弹出的文字;containView--父级视图
 * 输出参数:
 * 返回值:
 * 其它说明:
 *****************************************************************************/
- (void)showBottomHudWithMessage:(NSString *)message inView:(UIView *)containView;
////MBProgressHUDModeDeterminate MBProgressHUDModeDeterminateHorizontalBar MBProgressHUDModeAnnularDeterminate
//- (MBProgressHUD *)showProgressHud:(MBProgressHUDMode)mode withMessage:(NSString *)message inView:(UIView *)containView;
@end
