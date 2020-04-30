//
//  PushFilterViewController.m
//  Pivot
//
//  Created by zzZ on 16/5/17.
//  Copyright © 2016年 bos. All rights reserved.
//

#import "PushFilterViewController.h"
#import "KLCPopup.h"
#import "SelectParamsPickerView.h"
#import "RGHudModular.h"
#import "Common.h"

@interface PushFilterViewController ()<SelectParamsPickerViewDelegate>
{
    __weak IBOutlet UILabel *lblAnd;
    __weak IBOutlet UILabel *lblUnit2;
    UIBarButtonItem *nextBtn;// 下一步按扭
    __weak IBOutlet UILabel *lblUnit1;
}
@property (weak, nonatomic) IBOutlet UILabel *lblLimit;
@property (weak, nonatomic) IBOutlet UILabel *lblTitle;
@property (weak, nonatomic) IBOutlet UITextField *txtVal1;
@property (weak, nonatomic) IBOutlet UITextField *txtVal2;

@end

@implementation PushFilterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"度量筛选条件";
    // Do any additional setup after loading the view from its nib.
    _lblTitle.text = _duliang;
    
    UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(clickChoose:)];
    
    [_lblLimit addGestureRecognizer:gesture];
    _lblLimit.layer.masksToBounds = YES;
    _lblLimit.layer.borderColor = [UIColor lightGrayColor].CGColor;
    _lblLimit.layer.borderWidth = 1;
    _lblLimit.layer.cornerRadius = 4;
    lblUnit1.text = self.cunit;
    lblUnit2.text = self.cunit;
    lblUnit1.adjustsFontSizeToFitWidth = YES;
    lblUnit1.minimumScaleFactor = 9;
    lblUnit2.adjustsFontSizeToFitWidth = YES;
    lblUnit2.minimumScaleFactor = 9;
    _txtVal1.keyboardType = UIKeyboardTypeNumberPad;
    _txtVal2.keyboardType = UIKeyboardTypeNumberPad;
    if (self.defDict != nil) {
        
        _lblLimit.text = [self.defDict objectForKey:@"opt"];
        if ([[self.defDict objectForKey:@"opt"] isEqualToString:@"between"]) {//两个框框
            _txtVal1.hidden = false;
            _txtVal2.hidden = false;
            lblUnit2.hidden = false;
            lblUnit1.hidden = false;
            lblAnd.hidden   = false;
            _txtVal1.text   = [self.defDict objectForKey:@"val1"];
            _txtVal2.text   = [self.defDict objectForKey:@"val2"];
        }else{
            _txtVal1.hidden = false;
            lblUnit2.hidden = YES;
            lblUnit1.hidden = false;
            lblAnd.hidden   = YES;
            _txtVal1.text   = [self.defDict objectForKey:@"val1"];
        }
    }
    // 添加下一步按钮
    UIBarButtonItem *backBtn = self.navigationItem.backBarButtonItem;
    backBtn.tintColor = [UIColor whiteColor];
    [self.navigationItem setBackBarButtonItem:backBtn];
    
    NSMutableDictionary *dict =[NSMutableDictionary dictionaryWithCapacity:1];
    [dict setObject:[UIFont systemFontOfSize:15] forKey:NSFontAttributeName];
    
    
    nextBtn = [[UIBarButtonItem alloc] initWithTitle:@"确定" style:UIBarButtonItemStylePlain target:self action:@selector(clickDone)];
//    nextBtn.enabled = false;
    [nextBtn setTitleTextAttributes:dict forState:UIControlStateNormal];
    self.navigationItem.rightBarButtonItem = nextBtn;
}

-(void)clickChoose:(UITapGestureRecognizer *)gesture
{
    if (gesture.state == UIGestureRecognizerStateEnded) {

        KLCPopupLayout layout = KLCPopupLayoutMake(KLCPopupHorizontalLayoutCenter, KLCPopupVerticalLayoutBottom);
        SelectParamsPickerView *sppv = [[SelectParamsPickerView alloc]initWithData:@[@">",@">=",@"<",@"<=",@"=",@"!=",@"between"] flag:YES withDelegate:self];
        sppv.cFlag = 1;
        sppv.specFlag = YES;
        NSString *tVal = _lblLimit.text;
        if (tVal != nil) {
            [sppv pickerSelectVal:tVal];
        }
        
        KLCPopup *popup = [KLCPopup popupWithContentView:sppv
                                                showType:KLCPopupShowTypeSlideInFromBottom
                                             dismissType:KLCPopupDismissTypeSlideOutToBottom
                                                maskType:KLCPopupMaskTypeDimmed
                                dismissOnBackgroundTouch:YES
                                   dismissOnContentTouch:NO];
        [popup showWithLayout:layout];
        //        NSLog(@"点击了--%d",gesture.view.tag);
    }
}

-(void)reloadViewByFlag:(NSString *)flag
{
    if ([flag isEqualToString:@"between"]) {
        _txtVal1.hidden = false;
        _txtVal2.hidden = false;
        lblUnit2.hidden = false;
        lblUnit1.hidden = false;
        lblAnd.hidden   = false;
    }else{
        lblUnit2.hidden = YES;
        lblUnit1.hidden = false;
        lblAnd.hidden   = YES;
        _txtVal1.hidden = false;
        _txtVal2.hidden = YES;
    }
}

-(void)pickerDidSelect:(NSString *)aStr withFlag:(NSInteger)flag
{
    _lblLimit.text = aStr;
    
    [self reloadViewByFlag:aStr];
//    if (nextBtn.enabled == false) {
//        nextBtn.enabled = true;
//    }
}

-(void)clickDone
{
    if ([_lblLimit.text isEqualToString:@"限制条件"]) {
        [[RGHudModular getRGHud]showAutoHudWithMessageDefault:@"请选择限制条件"];
        return;
    }
    if (![_lblLimit.text isEqualToString:@"between"]) {//单个输入框
        if (_txtVal1.text == nil) {
            [[RGHudModular getRGHud]showAutoHudWithMessageDefault:@"请输入限制值"];
            return;
        }
        self.block(@{@"opt":_lblLimit.text,@"val1":_txtVal1.text});
        
    }else{
        if ([Common isBlankString:_txtVal1.text] || [Common isBlankString:_txtVal2.text]) {
            [[RGHudModular getRGHud]showAutoHudWithMessageDefault:@"请输入限制值"];
            return;
        }
        
        if (_txtVal1.text.intValue > _txtVal2.text.intValue) {
            [[RGHudModular getRGHud]showAutoHudWithMessageDefault:@"请输入正确的区间"];
            return;
        }
        self.block(@{@"opt":_lblLimit.text,@"val1":_txtVal1.text,@"val2":_txtVal2.text});
    }
    [self.navigationController popViewControllerAnimated:YES];
}
- (IBAction)closeKeyBord:(id)sender {
    [[UIApplication sharedApplication].keyWindow endEditing:YES];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
