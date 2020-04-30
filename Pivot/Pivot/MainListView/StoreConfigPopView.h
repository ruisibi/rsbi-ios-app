/*********************************************************************
 * 版权所有   magic_Zzz
 *
 * 文件名称： StoreConfigPopView
 * 内容摘要： 存储配置弹出视图
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

@protocol StoreConfigPopViewDelegate <NSObject>

@optional
-(void)clickDoneWithName:(NSString *)name;

@end
@interface StoreConfigPopView : UIView
- (instancetype)initWithDelegate:(id)delegate;
@property (nonatomic, strong) UITextField *txtName;
@property (nonatomic, assign) id<StoreConfigPopViewDelegate> delegate;
@end
