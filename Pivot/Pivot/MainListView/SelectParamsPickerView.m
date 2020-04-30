/*********************************************************************
 * 版权所有   magic_Zzz
 *
 * 文件名称： SelectParamsPickerView
 * 内容摘要： 参数选择的picker
 * 其它说明： 实现文件
 * 作 成 者： ZGD
 * 完成日期： 2016年03月22日
 * 修改记录1：
 * 修改日期：
 * 修 改 人：
 * 修改内容：
 * 修改记录2：
 **********************************************************************/

#import "SelectParamsPickerView.h"
#import "Common.h"
#import "KLCPopup.h"

@interface SelectParamsPickerView()<UIPickerViewDataSource,UIPickerViewDelegate>
@property (nonatomic, strong) UIPickerView *pickerView;// 选择view
@property (nonatomic, strong) NSMutableArray *dataArray;// 数据
@end
@implementation SelectParamsPickerView
@synthesize pickerView;
@synthesize dataArray;

- (instancetype)initWithData:(NSArray *)arr flag:(BOOL)flag withDelegate:(id)delegate
{
    self = [super initWithFrame:CGRectMake(0, 0, flag ? SCREEN_WIDTH : SCREEN_HEIGHT, 250)];
    if (self) {
        if (arr == nil) {
            dataArray = [NSMutableArray arrayWithObjects:@"2013",@"2013",@"2013",@"2013",@"2013",@"2013",@"2013",@"2013",@"2013",@"2013", nil];
        }else{
            dataArray = [NSMutableArray arrayWithArray:arr];
        }
        self.delegate = delegate;
        UIView  *lineView = [[UIView alloc]initWithFrame:CGRectMake(0 , 0, self.frame.size.width, 1)];
        lineView.backgroundColor = MT_LINE_COLOR;
        UIView  *btnView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.frame.size.width, 40)];
        btnView.backgroundColor = MT_CELL_COLOR;
        
        UIButton *btnSure = [UIButton buttonWithType:UIButtonTypeCustom];
        btnSure.frame = CGRectMake(self.frame.size.width - 60, 0, 50, 40);
        
        [btnSure setTitle:@"确定" forState:UIControlStateNormal];
        [btnSure setTitleColor:[UIColor colorWithRed:69/255.0 green:114/255.0 blue:167/255.0 alpha:1] forState:UIControlStateNormal];
        [btnSure addTarget:self action:@selector(clickDone) forControlEvents:UIControlEventTouchUpInside];
        [btnView addSubview:btnSure];
        
        pickerView = [[UIPickerView alloc]initWithFrame:CGRectZero];
        pickerView.autoresizingMask =UIViewAutoresizingFlexibleHeight ;
        pickerView.showsSelectionIndicator=YES;
        pickerView.dataSource = self;
        pickerView.frame = CGRectMake(0, 40, self.frame.size.width, self.frame.size.height - 40);
        pickerView.delegate = self;
        pickerView.backgroundColor = [UIColor colorWithRed:249/255.0 green:249/255.0 blue:249/255.0 alpha:1];
        [self addSubview:btnView];
        [self addSubview:lineView];
        [self addSubview:pickerView];
        
    }
    return self;
}

- (void)pickerSelectVal:(NSString *)defVal
{

    NSInteger defNum = 0;
    NSString *key = @"text";
    if (self.specFlag) {
        key = @"name";
    }
    if (defVal != nil && ![Common isBlankString:defVal]) {
        for (int i=0; i<dataArray.count; i++) {
            id aDict = dataArray[i];
            if ([aDict isKindOfClass:[NSDictionary class]]) {
                if ([[aDict objectForKey:key] isEqualToString:defVal]) {
                    defNum = i;
                    break;
                }
            }else{
                if ([aDict isEqualToString:defVal]) {
                    defNum = i;
                    break;
                }
            }
        }
    }
    [pickerView selectRow:defNum inComponent:0 animated:NO];

}



- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

// pickerView 每列个数
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    
    return [dataArray count];
}
- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component {
    
    return self.frame.size.width;
}

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component

{
    
    return 25.0;
    
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    
//    NSLog(@"选中了：%@",[dataArray objectAtIndex:row]);
}

-(NSString*) pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    
    id aDict = dataArray[row];
    if ([aDict isKindOfClass:[NSString class]]) {
        return aDict;
    }else{
        if (self.specFlag) {
            return [NSString stringWithFormat:@"%@",[aDict objectForKey:@"name"]];
        }
        return [NSString stringWithFormat:@"%@",[aDict objectForKey:@"text"]];
    }
  
}

-(void)clickDone
{
    if (self.delegate) {
        id data = dataArray[[pickerView selectedRowInComponent:0]];
        if ([data isKindOfClass:[NSDictionary class]]) {
            [self.delegate pickerDidSelectDict:dataArray[[pickerView selectedRowInComponent:0]] withFlag:self.cFlag];
        }
        if ([data isKindOfClass:[NSString class]]) {
            [self.delegate pickerDidSelect:data withFlag:self.cFlag];
        }
        [self dismissPresentingPopup];
    }
  
    
}

//- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row
//          forComponent:(NSInteger)component reusingView:(UIView *)view
//{
//    UILabel *tmpLab = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, self.frame.size.width, 25.0)];
//    tmpLab.font = [UIFont systemFontOfSize:14];
//    tmpLab.textAlignment = NSTextAlignmentCenter;
//    tmpLab.text = [dataArray objectAtIndex:row];
//    
//    return tmpLab;
//}

@end
