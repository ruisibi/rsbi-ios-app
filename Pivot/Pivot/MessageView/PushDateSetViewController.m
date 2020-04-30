//
//  PushDateSetViewController.m
//  Pivot
//
//  Created by djh on 16/5/18.
//  Copyright © 2016年 bos. All rights reserved.
//

#import "PushDateSetViewController.h"
#import "KLCPopup.h"
#import "SelectParamsPickerView.h"

@interface PushDateSetViewController ()<SelectParamsPickerViewDelegate>
{
    NSMutableArray *monthArr;
    NSMutableArray *hourArr;
    NSMutableArray *minArr;
    UIBarButtonItem *nextBtn;// 下一步按扭
}

@property (weak, nonatomic) IBOutlet UIView *monthView;
@property (weak, nonatomic) IBOutlet UILabel *monthVal;
@property (weak, nonatomic) IBOutlet UILabel *hourVal;
@property (weak, nonatomic) IBOutlet UILabel *minVal;

@end

@implementation PushDateSetViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _monthVal.layer.masksToBounds = YES;
    _monthVal.layer.borderColor = [UIColor lightGrayColor].CGColor;
    _monthVal.layer.borderWidth = 1;
    _monthVal.layer.cornerRadius = 4;
    
    _hourVal.layer.masksToBounds = YES;
    _hourVal.layer.borderColor = [UIColor lightGrayColor].CGColor;
    _hourVal.layer.borderWidth = 1;
    _hourVal.layer.cornerRadius = 4;
    
    _minVal.layer.masksToBounds = YES;
    _minVal.layer.borderColor = [UIColor lightGrayColor].CGColor;
    _minVal.layer.borderWidth = 1;
    _minVal.layer.cornerRadius = 4;
    //初始化数组
    monthArr = [[NSMutableArray alloc]init];
    hourArr  = [[NSMutableArray alloc]init];
    minArr   = [[NSMutableArray alloc]init];
    for (int i=0; i<=59; i++) {
        if (i !=0 && i<=31) {
            [monthArr addObject:[NSString stringWithFormat:@"%d",i]];
        }
        if (i <= 23) {
            [hourArr addObject:[NSString stringWithFormat:@"%d",i]];
        }
        [minArr addObject:[NSString stringWithFormat:@"%d",i]];
    }
    // Do any additional setup after loading the view from its nib.
    self.navigationItem.title = @"推送时间设置";
    // 添加下一步按钮
    UIBarButtonItem *backBtn = self.navigationItem.backBarButtonItem;
    backBtn.tintColor = [UIColor whiteColor];
    [self.navigationItem setBackBarButtonItem:backBtn];
    
    NSMutableDictionary *dict =[NSMutableDictionary dictionaryWithCapacity:1];
    [dict setObject:[UIFont systemFontOfSize:15] forKey:NSFontAttributeName];
    
    
    nextBtn = [[UIBarButtonItem alloc] initWithTitle:@"确定" style:UIBarButtonItemStylePlain target:self action:@selector(clickDone)];
    
    [nextBtn setTitleTextAttributes:dict forState:UIControlStateNormal];
    self.navigationItem.rightBarButtonItem = nextBtn;
    if (self.pushType == 1) {
        _monthView.hidden = false;
    }else{
        _monthView.hidden = YES;
    }
    
    if (self.defDict != nil) {
        
        if (self.pushType == 1) {
            _monthView.hidden = false;
            _monthVal.text = [self.defDict objectForKey:@"day"];
            _hourVal.text  = [self.defDict objectForKey:@"hour"];
            _minVal.text   = [self.defDict objectForKey:@"minute"];
        }else{
            _monthView.hidden = YES;
            _hourVal.text  = [self.defDict objectForKey:@"hour"];
            _minVal.text   = [self.defDict objectForKey:@"minute"];
        }
    }
    
    UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(clickChoose:)];
    
    [_monthVal addGestureRecognizer:gesture];
    
    UITapGestureRecognizer *gesture2 = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(clickChoose:)];
    
    [_hourVal addGestureRecognizer:gesture2];
    
    UITapGestureRecognizer *gesture3 = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(clickChoose:)];
    
    [_minVal addGestureRecognizer:gesture3];
    
}

-(void)clickChoose:(UITapGestureRecognizer *)gesture
{
    if (gesture.state == UIGestureRecognizerStateEnded) {
        
        KLCPopupLayout layout = KLCPopupLayoutMake(KLCPopupHorizontalLayoutCenter, KLCPopupVerticalLayoutBottom);
        NSArray *datArr = [NSArray array];
        NSString *tVal = @"";
        switch (gesture.view.tag) {
            case 1:
                datArr = [NSArray arrayWithArray:monthArr];
                tVal = _monthVal.text;
                break;
            case 2:
                datArr = [NSArray arrayWithArray:hourArr];
                tVal = _hourVal.text;
                break;
            case 3:
                datArr = [NSArray arrayWithArray:minArr];
                tVal = _minVal.text;
                break;
            default:
                break;
        }
        
        SelectParamsPickerView *sppv = [[SelectParamsPickerView alloc]initWithData:datArr flag:YES withDelegate:self];
        sppv.cFlag = gesture.view.tag;
        sppv.specFlag = YES;
        
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

-(void)pickerDidSelect:(NSString *)aStr withFlag:(NSInteger)flag
{
    switch (flag) {
        case 1:
            
            _monthVal.text = aStr;
            break;
        case 2:
            _hourVal.text = aStr;
            
            break;
        case 3:
            _minVal.text = aStr;
            
            break;
        default:
            break;
    }
}

-(void)clickDone
{
    if (_hourVal.text != nil && _minVal.text != nil) {
        if (self.pushType == 1) {//每月
            self.block(@{@"day":_monthVal.text,@"hour":_hourVal.text,@"minute":_minVal.text});
        }else{//每日
            self.block(@{@"hour":_hourVal.text,@"minute":_minVal.text});
        }
        [self.navigationController popViewControllerAnimated:YES];
    }
    
    
    
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
