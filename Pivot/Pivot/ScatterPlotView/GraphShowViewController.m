/*********************************************************************
 * 版权所有   magic_Zzz
 *
 * 文件名称： GraphShowViewController 图形容器
 * 内容摘要： 图形容器
 * 其它说明： 实现文件
 * 作 成 者： ZGD
 * 完成日期： 2016年03月08日
 * 修改记录1：
 * 修改日期：
 * 修 改 人：
 * 修改内容：
 * 修改记录2：
 **********************************************************************/

#import "GraphShowViewController.h"
#import "Common.h"
#import "ZZZScatterPlotView.h"
#import "Common.h"
#import "AFNetworking.h"
#import "MJRefresh.h"
#import "RGHudModular.h"
#import "JSONKit.h"
#import "KxMenu.h"
#import "KLCPopup.h"
#import "SelectParamsPickerView.h"
#import "PMCalendar.h"

//column 柱状图

@interface GraphShowViewController ()<PMCalendarControllerDelegate>
{
    ZZZScatterPlotView *zspView;// 折线视图
    NSString  *yName;// y轴名称
    BOOL      firstFlag;// 第一次启动
    ZZZPLOTSTYLE currentStyle;// 当前的样式
    NSString  *curType;// 当前图形
    
    UILabel *lblValue;// 第一个值
    UILabel *lblValue2;// 第二个值
    NSString *dimType;// 参数类型
    NSString *formatStr;// 日期格式化类型
    UIView *headerView;
}
@property (nonatomic,strong) NSMutableArray *paramArray;// 参数数组
@property (nonatomic, strong) PMCalendarController *pmCC;
@end

@implementation GraphShowViewController
@synthesize paramArray;

/***********************************************************************
 * 方法名称： shouldAutorotate
 * 功能描述： 禁止旋转
 * 输入参数：
 * 输出参数：
 * 返 回 值：
 ***********************************************************************/
- (BOOL)shouldAutorotate
{
    return NO;
}

/***********************************************************************
 * 方法名称： preferredInterfaceOrientationForPresentation
 * 功能描述： 保持横屏
 * 输入参数：
 * 输出参数：
 * 返 回 值：
 ***********************************************************************/
- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationLandscapeRight;
}
 

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationLandscapeRight animated:false];
    
    
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (!firstFlag) {
        // 加载数据
        [self loadDataArray];
        firstFlag = YES;
    }
}

/***********************************************************************
 * 方法名称： prefersStatusBarHidden
 * 功能描述： 显示状态栏
 * 输入参数：
 * 输出参数：
 * 返 回 值：
 ***********************************************************************/
//- (BOOL)prefersStatusBarHidden
//{
//    return NO; // 返回NO表示要显示，返回YES将hiden
//}


- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
 
    [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationPortrait animated:false];
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
}

- (void)viewDidLoad {
    [super viewDidLoad];
 
    //初始化当前视图
    currentStyle = ZZZPLOTSTYLE_Scatter;
    yName = @"";
    curType      = @"line";
    paramArray = [[NSMutableArray alloc]init];
   
 
    
}



/***********************************************************************
 * 方法名称： setUpParamsView
 * 功能描述： 设置查询条件视图(H60)
 * 输入参数：
 * 输出参数：
 * 返 回 值：
 ***********************************************************************/
-(void)setUpParamsView
{
    [headerView removeFromSuperview];
    
    NSDictionary *tmpDict = paramArray.firstObject;
    NSString *name = [tmpDict objectForKey:@"name"];
    NSString *type = [tmpDict objectForKey:@"type"];
    NSDictionary *dimDict = [tmpDict objectForKey:@"dim"];
    dimType = [dimDict objectForKey:@"type"];
    formatStr = [dimDict objectForKey:@"dateformat"];
    formatStr = [formatStr stringByReplacingOccurrencesOfString:@"mm" withString:@"MM"];
    id vals = [tmpDict objectForKey:@"value"];
    headerView = [[UIView alloc]initWithFrame:CGRectMake(0, 45, SCREEN_WIDTH, 50)];
    headerView.backgroundColor = [UIColor colorWithRed:253/255.0 green:253/255.0 blue:253/255.0 alpha:1];
    // 添加标题
    UILabel *pTitle = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 70, 50)];
    pTitle.text = name;
    pTitle.textAlignment = NSTextAlignmentCenter;
    pTitle.font = [UIFont systemFontOfSize:15];
    [headerView addSubview:pTitle];
    
    
    if ([type isEqualToString:@"select"]) {// 如果是下拉框
        if (![dimType isEqualToString:@"day"] && ![dimType isEqualToString:@"month"]) {//类型不为day和month
            lblValue = [[UILabel alloc]initWithFrame:CGRectMake(80, 10, 200, 30)];
            lblValue.tag = 1;
            lblValue.layer.borderColor = MT_LINE_COLOR.CGColor;
            lblValue.layer.borderWidth = 1;
            lblValue.backgroundColor = [UIColor whiteColor];
            lblValue.text = [self getStrByValue:[NSString stringWithFormat:@"%@",vals] arr:[tmpDict objectForKey:@"options"]];
            lblValue.textAlignment = NSTextAlignmentCenter;
            lblValue.font = [UIFont systemFontOfSize:15];
            lblValue.userInteractionEnabled = YES;
            UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(singleTap:)];
            [lblValue addGestureRecognizer:gesture];
            [headerView addSubview:lblValue];
        }else{
            assert(paramArray.count == 2);
            // 设置第一个参数
            lblValue = [[UILabel alloc]initWithFrame:CGRectMake(80, 10, 100, 30)];
            lblValue.tag = 1;
            lblValue.textAlignment = NSTextAlignmentCenter;
            lblValue.layer.borderColor = MT_LINE_COLOR.CGColor;
            lblValue.layer.borderWidth = 1;
            lblValue.backgroundColor = [UIColor whiteColor];
            lblValue.text = [self getStrByValue:[NSString stringWithFormat:@"%@",vals] arr:[tmpDict objectForKey:@"options"]];
            lblValue.font = [UIFont systemFontOfSize:15];
            lblValue.userInteractionEnabled = YES;
            UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(singleTap:)];
            [lblValue addGestureRecognizer:gesture];
            [headerView addSubview:lblValue];
            // 设置第二个参数
            NSDictionary *ttDict = [paramArray objectAtIndex:1];
            id val2 = [ttDict objectForKey:@"value"];
            lblValue2 = [[UILabel alloc]initWithFrame:CGRectMake(200, 10, 100, 30)];
            lblValue2.tag = 2;
            lblValue2.font = [UIFont systemFontOfSize:15];
            lblValue2.textAlignment = NSTextAlignmentCenter;
            lblValue2.layer.borderColor = MT_LINE_COLOR.CGColor;
            lblValue2.layer.borderWidth = 1;
            lblValue2.backgroundColor = [UIColor whiteColor];
            lblValue2.text = [self getStrByValue:[NSString stringWithFormat:@"%@",val2] arr:[ttDict objectForKey:@"options"]];
            lblValue2.userInteractionEnabled = YES;
            UITapGestureRecognizer *gesture2 = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(singleTap:)];
            [lblValue2 addGestureRecognizer:gesture2];
            [headerView addSubview:lblValue2];
        }
        
    }else{
        assert(paramArray.count == 2);
        
        NSString *minVal = [tmpDict objectForKey:@"value"];
        lblValue = [[UILabel alloc]initWithFrame:CGRectMake(80, 10, 100, 30)];
        lblValue.tag = 1;
        lblValue.textAlignment = NSTextAlignmentCenter;
        lblValue.layer.borderColor = MT_LINE_COLOR.CGColor;
        lblValue.layer.borderWidth = 1;
        lblValue.backgroundColor = [UIColor whiteColor];
        lblValue.text = [NSString stringWithFormat:@"%@",minVal];
        lblValue.font = [UIFont systemFontOfSize:15];
        lblValue.userInteractionEnabled = YES;
        UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(singleDateTap:)];
        [lblValue addGestureRecognizer:gesture];
        [headerView addSubview:lblValue];
        // 设置第二个参数
        NSDictionary *lastDict = paramArray.lastObject;
        NSString *maxVal = [lastDict objectForKey:@"value"];
        lblValue2 = [[UILabel alloc]initWithFrame:CGRectMake(200, 10, 100, 30)];
        lblValue2.tag = 2;
        lblValue2.font = [UIFont systemFontOfSize:15];
        lblValue2.textAlignment = NSTextAlignmentCenter;
        lblValue2.layer.borderColor = MT_LINE_COLOR.CGColor;
        lblValue2.layer.borderWidth = 1;
        lblValue2.backgroundColor = [UIColor whiteColor];
        lblValue2.text = [NSString stringWithFormat:@"%@",maxVal];
        lblValue2.userInteractionEnabled = YES;
        UITapGestureRecognizer *gesture2 = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(singleDateTap:)];
        [lblValue2 addGestureRecognizer:gesture2];
        [headerView addSubview:lblValue2];
        [self.params setObject:[NSString stringWithFormat:@"%@",lblValue.text] forKey:@"st"];
        [self.params setObject:[NSString stringWithFormat:@"%@",lblValue2.text] forKey:@"end"];
    }
    //![type isEqualToString:@"day"] && ![type isEqualToString:@"month"]
    // 添加按钮
    UIButton *btnSure = [UIButton buttonWithType:UIButtonTypeCustom];
    btnSure.frame = CGRectMake(SCREEN_WIDTH - 55 - 12, 10, 55, 30);
    [btnSure setTitle:@"查询" forState:UIControlStateNormal];
    [btnSure setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btnSure setBackgroundColor:[UIColor colorWithRed:255/255.0 green:157/255.0 blue:46/255.0 alpha:1]];
    btnSure.layer.masksToBounds = YES;
    [btnSure addTarget:self action:@selector(clickquery) forControlEvents:UIControlEventTouchUpInside];
    btnSure.layer.cornerRadius  = 4;
    
    [headerView addSubview:btnSure];
    [self.view addSubview:headerView];
}

-(NSString *)getStrByValue:(NSString *)str arr:(NSArray *)optionsArr
{
    NSString *tmpStr = str;
    for (NSDictionary *aDict in optionsArr) {
        NSString *tmpVal = [NSString stringWithFormat:@"%@",[aDict objectForKey:@"value"]];
        if ([tmpVal isEqualToString:str]) {
            tmpStr = [NSString stringWithFormat:@"%@",[aDict objectForKey:@"text"]];
            break;
        }
    }
    return tmpStr;
}

- (void)calendarController:(PMCalendarController *)calendarController didChangePeriod:(PMPeriod *)newPeriod
{
    if (self.pmCC.specFlag == 1) {
        lblValue.text = [newPeriod.startDate dateStringWithFormat:formatStr];
        [self.params setObject:[NSString stringWithFormat:@"%@",lblValue.text] forKey:@"st"];
    }else{
        lblValue2.text = [newPeriod.startDate dateStringWithFormat:formatStr];
        [self.params setObject:[NSString stringWithFormat:@"%@",lblValue2.text] forKey:@"end"];
    }
}

/***********************************************************************
 * 方法名称： singleDateTap
 * 功能描述： 日期参数设置
 * 输入参数：
 * 输出参数：
 * 返 回 值：
 ***********************************************************************/
- (void)singleDateTap:(UITapGestureRecognizer *)gesture
{
    if (gesture.state == UIGestureRecognizerStateEnded) {
        int tTag = gesture.view.tag;
        self.pmCC = [[PMCalendarController alloc] init];
        self.pmCC.delegate = self;
        self.pmCC.specFlag = tTag;
        //    pmCC.mondayFirstDayOfWeek = YES;
        self.pmCC.allowsLongPressYearChange = YES;
        self.pmCC.allowsPeriodSelection = NO;
        UILabel* sender=lblValue;
        
        if (tTag == 1) {
            
            if (![Common isBlankString:lblValue.text]) {
                self.pmCC.period = [PMPeriod oneDayPeriodWithDate:[Common convertDateFromString:lblValue.text withFormat:formatStr]];
                self.pmCC.showCurrent = YES;
            }
            
            
        }else{
            if (![Common isBlankString:lblValue2.text]) {
                self.pmCC.period = [PMPeriod oneDayPeriodWithDate:[Common convertDateFromString:lblValue2.text withFormat:formatStr]];
                self.pmCC.showCurrent = YES;
            }
            sender = lblValue2;
        }
        
        [self.pmCC presentCalendarFromRect:CGRectMake(sender.frame.origin.x, sender.frame.origin.y +45, sender.frame.size.width, sender.frame.size.height)
                                    inView:self.view
                  permittedArrowDirections:PMCalendarArrowDirectionAny
                                  animated:YES];
    }
    
}

/***********************************************************************
 * 方法名称： singleTap
 * 功能描述： 参数设置
 * 输入参数：
 * 输出参数：
 * 返 回 值：
 ***********************************************************************/
- (void)singleTap:(UITapGestureRecognizer *)gesture
{
    if (gesture.state == UIGestureRecognizerStateEnded) {
        int tTag = gesture.view.tag;
        NSDictionary *aDict = paramArray[tTag-1];
        
        KLCPopupLayout layout = KLCPopupLayoutMake(KLCPopupHorizontalLayoutCenter, KLCPopupVerticalLayoutBottom);
        SelectParamsPickerView *sppv = [[SelectParamsPickerView alloc]initWithData:[aDict objectForKey:@"options"] flag:YES withDelegate:self];
        sppv.cFlag = tTag;
        NSString *tVal = tTag == 1 ? lblValue.text : lblValue2.text;
        [sppv pickerSelectVal:tVal];

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

/***********************************************************************
 * 方法名称： picker返回代理
 * 功能描述： 重置标题栏
 * 输入参数：
 * 输出参数：
 * 返 回 值：
 ***********************************************************************/
-(void)pickerDidSelectDict:(NSDictionary *)aDict withFlag:(NSInteger)flag
{
    NSString *tmpKey1 = @"vals";
    NSString *tmpKey2 = @"valStrs";
    //        day区间参数 startdt/enddt
    //        month 区间参数 startmt/endmt
    switch (flag) {
        case 1://第一个参数值
            if ([dimType isEqualToString:@"day"] || [dimType isEqualToString:@"month"]) {// 参数为day时
                
                [self.params setObject:[NSString stringWithFormat:@"%@",[aDict objectForKey:@"value"]] forKey:@"st"];
                
            }else{
                [self.params setObject:[NSString stringWithFormat:@"%@",[aDict objectForKey:@"value"]] forKey:tmpKey1];
                [self.params setObject:[NSString stringWithFormat:@"%@",[aDict objectForKey:@"text"]] forKey:tmpKey2];
            }
            lblValue.text = [NSString stringWithFormat:@"%@",[aDict objectForKey:@"text"]];
            break;
        case 2://第2个参数值
            if ([dimType isEqualToString:@"day"] || [dimType isEqualToString:@"month"]) {// 参数为day时
                
                [self.params setObject:[NSString stringWithFormat:@"%@",[aDict objectForKey:@"value"]] forKey:@"end"];
                
            }
            lblValue2.text = [NSString stringWithFormat:@"%@",[aDict objectForKey:@"text"]];
            break;
        default:
            break;
    }
    
}

/***********************************************************************
 * 方法名称： clickquery
 * 功能描述： 查询事件
 * 输入参数：
 * 输出参数：
 * 返 回 值：
 ***********************************************************************/
- (void)clickquery
{
    if ([dimType isEqualToString:@"day"] || [dimType isEqualToString:@"month"]) {// 参数为day时
        NSString *txt1 = [lblValue.text stringByReplacingOccurrencesOfString:@"-" withString:@""];
        NSString *txt2 = [lblValue2.text stringByReplacingOccurrencesOfString:@"-" withString:@""];
        if (txt1.integerValue > txt2.integerValue) {
            [[RGHudModular getRGHud]showAutoHudWithMessageDefault:@"结束日期不能小于起始时间"];
            return;
        }
    }
    [self loadDataArray];
}


- (void)setUpGraphView
{
    float marginTop = 0;
    if (paramArray != nil && paramArray.count != 0) {
        marginTop = 50;
        [self setUpParamsView];
    }
    // 实例化折线视图
    if (zspView == nil) {
        zspView= [[ZZZScatterPlotView alloc]initWithFrame:CGRectMake(0, 45 + marginTop, SCREEN_WIDTH , SCREEN_HEIGHT - 45 - marginTop)];
        
        [self.view  addSubview:zspView];
    }
    
}
/***********************************************************************
 * 方法名称： loadDataArray
 * 功能描述： // 加载数据
 * 输入参数：
 * 输出参数：
 * 返 回 值：
 ***********************************************************************/
- (void)loadDataArray
{
    [[RGHudModular getRGHud] showPopHudWithMessage:@"加载中..." inWindow:self.view];
    AFHTTPRequestOperationManager   *manager    = [AFHTTPRequestOperationManager manager];

    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    
    // 组合chartJson字符串
    NSMutableDictionary *chartJson = [NSMutableDictionary dictionaryWithCapacity:4];
    
    NSString *kpiId = [self.kpiJson objectForKey:@"col_id"];
    NSString *kpi_name = [self.kpiJson objectForKey:@"text"];
    NSString *unit = [self.kpiJson objectForKey:@"unit"];
    [self.kpiJson setObject:kpiId forKey:@"kpi_id"];
    [self.kpiJson setObject:kpi_name forKey:@"kpi_name"];

   
    
    // 设置图形样式
    [chartJson setObject:curType forKey:@"type"];
    
    
    // 组合xcol字符串
    if (self.tableRows != nil) {
        NSString *tname = [self.tableRows objectForKey:@"text"];
        NSString *type = [self.tableRows objectForKey:@"dim_type"];
        NSString *colname = [self.tableRows objectForKey:@"col_name"];
        NSString *dim_name = [self.tableRows objectForKey:@"groupname"];
        [self.tableRows setObject:tname forKey:@"name"];
        [self.tableRows setObject:tname forKey:@"dimdesc"];
        [self.tableRows setObject:type forKey:@"type"];
        [self.tableRows setObject:colname forKey:@"colname"];
        [self.tableRows setObject:dim_name forKey:@"dim_name"];
        [chartJson setObject:self.tableRows forKey:@"xcol"];
    }
    
    // 组合scol字符串
    if (self.tableCols != nil) {
        NSString *tname = [self.tableCols objectForKey:@"text"];
        NSString *type = [self.tableCols objectForKey:@"dim_type"];
        NSString *colname = [self.tableCols objectForKey:@"col_name"];
        
        [self.tableCols setObject:tname forKey:@"name"];
        [self.tableCols setObject:tname forKey:@"dimdesc"];
        [self.tableCols setObject:type forKey:@"type"];
        [self.tableCols setObject:colname forKey:@"colname"];
        
        [chartJson setObject:self.tableCols forKey:@"scol"];
    }
    
    // 组合pageInfo字符串
    NSMutableDictionary * pageInfo = [NSMutableDictionary dictionaryWithCapacity:2];
    [pageInfo setObject:chartJson forKey:@"chartJson"];
    [pageInfo setObject:@[self.kpiJson] forKey:@"kpiJson"];
    
    // 组合params字符串
    if (self.params != nil) {
        NSString *tname = [self.params objectForKey:@"text"];
        NSString *type = [self.params objectForKey:@"dim_type"];
        NSString *colname = [self.params objectForKey:@"col_name"];
        [self.params setObject:tname forKey:@"name"];
        [self.params setObject:type forKey:@"type"];
        [self.params setObject:colname forKey:@"colname"];
        [pageInfo setObject:@[self.params] forKey:@"params"];
    }else{
        [pageInfo setObject:@[] forKey:@"params"];
    }
    
    // 组合输入参数
    NSDictionary     *parameters = @{@"token": [Common shareInstence].token
                                     ,@"pageInfo":[pageInfo JSONString]};

    [manager POST:WEB_SERVICE_COMPVIEW([Common GetServiceHost]) parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {

        [[RGHudModular getRGHud] hidePopHudInView:self.view];
        // 接卸输出参数
        NSDictionary *tDict = responseObject;
        NSArray      *compsArr = [tDict objectForKey:@"comps"];
        NSDictionary *dDict = compsArr.firstObject;
//
        paramArray = [tDict objectForKey:@"params"];
        
        [self setUpGraphView];
        zspView.yTitle = kpi_name;
        zspView.yUnit  = unit;
       
        [zspView reloadPlotWithStyle:currentStyle withData:dDict];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSString *errStr = operation.responseString;
        
        // 判断token是否可用
        if (![Common isBlankString:errStr] && [errStr isEqualToString:@"\r\n{error:'用户未登录。'}"]) {
            [[RGHudModular getRGHud] showAutoHudWithMessageDefault:@"用户登录失效,请重新登录"];
            [Common shareInstence].isLogin = NO;
            [self dismissViewControllerAnimated:YES completion:^{
                [self.navigationController popToRootViewControllerAnimated:false];
            }];
            return ;
        }
        [[RGHudModular getRGHud] showAutoHudWithMessageDefault:@"网络错误"];
        
    }];
}

/***********************************************************************
 * 方法名称： clickChange
 * 功能描述： 切换试图
 * 输入参数：
 * 输出参数：
 * 返 回 值：
 ***********************************************************************/
- (void)clickChange
{

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/***********************************************************************
 * 方法名称： backClick
 * 功能描述： 返回
 * 输入参数：
 * 输出参数：
 * 返 回 值：
 ***********************************************************************/
- (IBAction)backClick:(id)sender {
    [self dismissViewControllerAnimated:true completion:nil];

}

/***********************************************************************
 * 方法名称： changePlot:(id)sender
 * 功能描述： 切换视图
 * 输入参数：
 * 输出参数：
 * 返 回 值：
 ***********************************************************************/
- (IBAction)changePlot:(id)sender {
    UIButton *btn = sender;
    NSArray *itemsArray = @[
                            [KxMenuItem menuItem:@"曲线图" image:nil target:self action:@selector(pushMenuItem:)],
                            [KxMenuItem menuItem:@"柱状图" image:nil target:self action:@selector(pushMenuItem:)],
                            [KxMenuItem menuItem:@"饼状图" image:nil target:self action:@selector(pushMenuItem:)],
                            [KxMenuItem menuItem:@"条形图" image:nil target:self action:@selector(pushMenuItem:)],
                            [KxMenuItem menuItem:@"面积图" image:nil target:self action:@selector(pushMenuItem:)],
                            [KxMenuItem menuItem:@"雷达图" image:nil target:self action:@selector(pushMenuItem:)]
                            
                            ];
    if (self.tableCols != nil) {
        itemsArray = @[
                       [KxMenuItem menuItem:@"曲线图" image:nil target:self action:@selector(pushMenuItem:)],
                       [KxMenuItem menuItem:@"柱状图" image:nil target:self action:@selector(pushMenuItem:)],
                       [KxMenuItem menuItem:@"条形图" image:nil target:self action:@selector(pushMenuItem:)],
                       [KxMenuItem menuItem:@"面积图" image:nil target:self action:@selector(pushMenuItem:)],
                       [KxMenuItem menuItem:@"雷达图" image:nil target:self action:@selector(pushMenuItem:)]
                       
                       ];
    }
    [KxMenu showMenuInView:self.view fromRect:btn.frame menuItems:itemsArray
     
               contentView:nil];
}

/***********************************************************************
 * 方法名称： clickChange
 * 功能描述： 切换试图
 * 输入参数：
 * 输出参数：
 * 返 回 值：
 ***********************************************************************/
- (void) pushMenuItem:(KxMenuItem *)sender
{
//    NSLog(@"%@", sender);
    ZZZPLOTSTYLE selectStyle;
    if ([sender.title isEqualToString:@"曲线图"]) {
        selectStyle = ZZZPLOTSTYLE_Scatter;
        
        curType     = @"line";
    }else if ([sender.title isEqualToString:@"柱状图"]){
        selectStyle = ZZZPLOTSTYLE_HBar;
        curType     = @"column";
    }else if ([sender.title isEqualToString:@"饼状图"]){
        selectStyle = ZZZPLOTSTYLE_Pie;
        curType     = @"pie";
    }else if ([sender.title isEqualToString:@"条形图"]){
        selectStyle = ZZZPLOTSTYLE_VBar;
        curType     = @"bar";
    }else if ([sender.title isEqualToString:@"面积图"]){
        selectStyle = ZZZPLOTSTYLE_Area;
        curType     = @"area";
    }else if ([sender.title isEqualToString:@"雷达图"]){
        selectStyle = ZZZPLOTSTYLE_Radar;
        curType     = @"radar";
    }
    currentStyle = selectStyle;
    [self loadDataArray];
}
@end


