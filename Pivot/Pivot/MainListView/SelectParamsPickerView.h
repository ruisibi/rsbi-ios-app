/*********************************************************************
 * 版权所有   magic_Zzz
 *
 * 文件名称： SelectParamsPickerView
 * 内容摘要： 参数选择的picker
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

@protocol SelectParamsPickerViewDelegate <NSObject>

@optional
-(void)pickerDidSelectDict:(NSDictionary *)aDict withFlag:(NSInteger)flag ;
-(void)pickerDidSelect:(NSString *)aStr withFlag:(NSInteger)flag ;

@end
@interface SelectParamsPickerView : UIView

- (instancetype)initWithData:(NSArray *)arr flag:(BOOL)flag withDelegate:(id)delegate;

@property (nonatomic) BOOL    specFlag;
@property (nonatomic, assign) id<SelectParamsPickerViewDelegate> delegate;
@property (nonatomic) NSInteger cFlag;//当前的flag


- (void)pickerSelectVal:(NSString *)defVal;



@end
