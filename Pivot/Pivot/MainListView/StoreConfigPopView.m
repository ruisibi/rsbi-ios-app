/*********************************************************************
 * 版权所有   magic_Zzz
 *
 * 文件名称： StoreConfigPopView
 * 内容摘要： 存储配置弹出视图
 * 其它说明： 实现文件
 * 作 成 者： ZGD
 * 完成日期： 2016年03月08日
 * 修改记录1：
 * 修改日期：
 * 修 改 人：
 * 修改内容：
 * 修改记录2：
 **********************************************************************/

#import "StoreConfigPopView.h"
#import "Common.h"
#import "RGHudModular.h"
#import "KLCPopup.h"

@interface StoreConfigPopView ()

@end
@implementation StoreConfigPopView
@synthesize txtName;
//320 180
- (instancetype)initWithDelegate:(id)delegate
{
    self = [super initWithFrame:CGRectMake(0, 0, 320, 180)];
    
    if (self) {
        self.layer.masksToBounds = YES;
        self.layer.cornerRadius  = 6;
        self.delegate = delegate;
        
        UILabel *lblTitle = [[UILabel alloc]initWithFrame:CGRectMake(20, 0, 60, 49)];
        lblTitle.text = @"保存";
        UIView  *lineView = [[UIView alloc]initWithFrame:CGRectMake(20, 49, 280, 1)];
        lineView.backgroundColor = MT_LINE_COLOR;
        
        txtName = [[UITextField alloc]initWithFrame:CGRectMake(20, 60, 280, 30)];
        txtName.placeholder = @"请输入名称";
        txtName.backgroundColor = [UIColor whiteColor];
        
        UIButton *btnCancel = [[UIButton alloc]initWithFrame:CGRectMake(20, 120, 137, 40)];
        [btnCancel setBackgroundImage:[UIImage imageNamed:@"navBg"] forState:UIControlStateNormal];
        [btnCancel setTitle:@"取消" forState:UIControlStateNormal];
        [btnCancel setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [btnCancel addTarget:self action:@selector(clickCancel) forControlEvents:UIControlEventTouchUpInside];
        btnCancel.layer.masksToBounds = YES;
        btnCancel.layer.cornerRadius  = 4;
        
        UIButton *btnSure = [[UIButton alloc]initWithFrame:CGRectMake(20 + 135 +10, 120, 135, 40)];
//        [btnSure setImage:[UIImage imageNamed:@"navBg"] forState:UIControlStateNormal];
        [btnSure setTitle:@"确定" forState:UIControlStateNormal];
        [btnSure setBackgroundImage:[UIImage imageNamed:@"navBg"] forState:UIControlStateNormal];
        [btnSure setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        btnSure.layer.masksToBounds = YES;
        btnSure.layer.cornerRadius  = 4;
        [btnSure addTarget:self action:@selector(clickSure) forControlEvents:UIControlEventTouchUpInside];
        
        [self addSubview:lblTitle];
        [self addSubview:lineView];
        [self addSubview:txtName];
        [self addSubview:btnCancel];
        [self addSubview:btnSure];
        
        self.backgroundColor = [UIColor colorWithRed:252/255.0 green:252/255.0 blue:252/255.0 alpha:1];
        
        UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(closeKeyBord)];
        [self addGestureRecognizer:gesture];
    }
    
    return self;
}

-(void)closeKeyBord
{
    [txtName resignFirstResponder];
}
/***********************************************************************
 * 方法名称： clickCancel
 * 功能描述： 取消
 * 输入参数：
 * 输出参数：
 * 返 回 值：
 ***********************************************************************/
- (void)clickCancel
{
    [self dismissPresentingPopup];
}

/***********************************************************************
 * 方法名称：clickSure
 * 功能描述： 确定
 * 输入参数：
 * 输出参数：
 * 返 回 值：
 ***********************************************************************/
- (void)clickSure
{
    if ([Common isBlankString:txtName.text]) {
        [[RGHudModular getRGHud]showAutoHudWithMessageDefault:@"名称不能为空"];
        return;
    }
    if (self.delegate) {
        [self.delegate clickDoneWithName:txtName.text];
        [self dismissPresentingPopup];
    }
}
@end
