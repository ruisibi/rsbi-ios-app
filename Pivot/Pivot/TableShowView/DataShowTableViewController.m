/*********************************************************************
 * 版权所有   magic_Zzz
 *
 * 文件名称： DataShowTableViewController
 * 内容摘要： 表格展示页面
 * 其它说明： 实现文件
 * 作 成 者： ZGD
 * 完成日期： 2016年03月22日
 * 修改记录1：
 * 修改日期：
 * 修 改 人：
 * 修改内容：
 * 修改记录2：
 **********************************************************************/


#define kCount 20
#define kHeadrHeight 40

#import "DataShowTableViewController.h"
#import "Common.h"
#import "AFNetworking.h"
#import "MJRefresh.h"
#import "RGHudModular.h"
#import "JSONKit.h"
#import "HeadView.h"
#import "TimeView.h"
#import "MyCell.h"
#import "SpecialTableView.h"
#import "KLCPopup.h"
#import "SelectParamsPickerView.h"
#import "PMCalendar.h"

@interface DataShowTableViewController ()<UITableViewDataSource,UITableViewDelegate,MyCellDelegate,TimeViewDelegate,SelectParamsPickerViewDelegate,PMCalendarControllerDelegate>
{
    CGFloat headerHeight;//表头高度
    BOOL    firstLoading;//第一次进入标记
    UILabel *lblValue;// 第一个值
    UILabel *lblValue2;// 第二个值
    int      currentShow;// 当前弹出的框
    NSString *dimType;// 参数类型
    NSString *formatStr;// 日期格式化类型
}
@property (nonatomic,strong) UIView *myHeadView;
@property (nonatomic,strong) UITableView *myTableView;
@property (nonatomic,strong) TimeView *timeView;
@property (nonatomic,strong) NSMutableArray *headerData;// 表头数组
@property (nonatomic,strong) NSMutableArray *dataArray;// 内容数组
@property (nonatomic,strong) NSMutableArray *paramArray;// 参数数组
@property(strong,nonatomic) SpecialTableView *specialTableView;
@property (nonatomic, strong) PMCalendarController *pmCC;
@end

@implementation DataShowTableViewController
@synthesize specialTableView;
@synthesize headerData;
@synthesize dataArray;
@synthesize paramArray;

- (void)viewDidLoad {
    [super viewDidLoad];
    headerHeight = kHeight;
    headerData = [[NSMutableArray alloc]init];
    dataArray = [[NSMutableArray alloc]init];
    paramArray = [[NSMutableArray alloc]init];
    self.view.backgroundColor = [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1];
    currentShow = -1;
    //设置titleview
    [self setUPTitleView];
    // Do any additional setup after loading the view from its nib.
    
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (firstLoading == false) {
        [self getData];
        firstLoading = true;
    }
    
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
    NSDictionary *tmpDict = paramArray.firstObject;
    NSString *name = [tmpDict objectForKey:@"name"];
    NSString *type = [tmpDict objectForKey:@"type"];
    NSLog(@"tmpDict  参数样式%@",tmpDict);
    NSDictionary *dimDict = [tmpDict objectForKey:@"dim"];
    dimType = [dimDict objectForKey:@"type"];
    formatStr = [dimDict objectForKey:@"dateformat"];
    formatStr = [formatStr stringByReplacingOccurrencesOfString:@"mm" withString:@"MM"];
    id vals = [tmpDict objectForKey:@"value"];
    UIView *headerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 60)];
    headerView.backgroundColor = [UIColor colorWithRed:253/255.0 green:253/255.0 blue:253/255.0 alpha:1];
    // 添加标题
    UILabel *pTitle = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 70, 60)];
    pTitle.text = name;
    pTitle.textAlignment = NSTextAlignmentCenter;
    pTitle.font = [UIFont systemFontOfSize:15];
    [headerView addSubview:pTitle];
    
    
    if ([type isEqualToString:@"select"]) {// 如果是下拉框
        if (![dimType isEqualToString:@"day"] && ![dimType isEqualToString:@"month"]) {//类型不为day和month
            lblValue = [[UILabel alloc]initWithFrame:CGRectMake(80, 15, 200, 30)];
            lblValue.tag = 1;
            lblValue.layer.borderColor = MT_LINE_COLOR.CGColor;
            lblValue.layer.borderWidth = 1;
            lblValue.backgroundColor = [UIColor whiteColor];
            lblValue.text =[self getStrByValue:[NSString stringWithFormat:@"%@",vals] arr:[tmpDict objectForKey:@"options"]];
            lblValue.textAlignment = NSTextAlignmentCenter;
            lblValue.font = [UIFont systemFontOfSize:15];
            lblValue.userInteractionEnabled = YES;
            UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(singleTap:)];
            [lblValue addGestureRecognizer:gesture];
            [headerView addSubview:lblValue];
        }else{
            assert(paramArray.count == 2);
            
            // 设置第一个参数
            lblValue = [[UILabel alloc]initWithFrame:CGRectMake(80, 15, 100, 30)];
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
            lblValue2 = [[UILabel alloc]initWithFrame:CGRectMake(200, 15, 100, 30)];
            if (SCREEN_HEIGHT <569) {
                lblValue2.frame = CGRectMake(185, 15, 100, 30);
                
            }
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
    NSLog(@"得到参数:%@",paramArray);
        NSString *minVal = [tmpDict objectForKey:@"value"];
        lblValue = [[UILabel alloc]initWithFrame:CGRectMake(80, 15, 100, 30)];
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
        lblValue2 = [[UILabel alloc]initWithFrame:CGRectMake(200, 15, 100, 30)];
        if (SCREEN_HEIGHT <569) {
            lblValue2.frame = CGRectMake(185, 15, 100, 30);
            
        }
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
    btnSure.frame = CGRectMake(SCREEN_WIDTH - 55 - 12, 15, 55, 30);
    if (SCREEN_HEIGHT <569) {
        btnSure.frame = CGRectMake(SCREEN_WIDTH - 30 - 3, 15, 30, 30);
        btnSure.titleLabel.font = [UIFont systemFontOfSize:14];
    }
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
        int tTag = (int)gesture.view.tag;
        self.pmCC = [[PMCalendarController alloc] init];
        self.pmCC.delegate = self;
        self.pmCC.specFlag = tTag;
        //    pmCC.mondayFirstDayOfWeek = YES;
        self.pmCC.allowsLongPressYearChange = YES;
        self.pmCC.allowsPeriodSelection = NO;
        id sender=lblValue;
        
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
        
        [self.pmCC presentCalendarFromRect:[sender frame]
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
    [self getData];
}

/***********************************************************************
 * 方法名称： setUPTitleView
 * 功能描述： 重置标题栏
 * 输入参数：
 * 输出参数：
 * 返 回 值：
 ***********************************************************************/
- (void)setUPTitleView
{
     
    
    UIView *tView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 200, 49)];
    UILabel *lblTitle = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 200, 25)];
    lblTitle.textAlignment = NSTextAlignmentCenter;
    lblTitle.text = @"数据透视";
    lblTitle.font =[UIFont boldSystemFontOfSize:17];
    lblTitle.textColor = [UIColor whiteColor];
    
    UILabel *lblTitle2 = [[UILabel alloc]initWithFrame:CGRectMake(0, 24,200, 20)];
    lblTitle2.text = @"表格展现";
    lblTitle2.font = [UIFont systemFontOfSize:13];
    lblTitle2.textAlignment = NSTextAlignmentCenter;
    lblTitle2.textColor = [UIColor whiteColor];
    
    CGRect leftViewbounds = self.navigationItem.leftBarButtonItem.customView.bounds;
    
    CGRect rightViewbounds = self.navigationItem.rightBarButtonItem.customView.bounds;
    
    CGRect frame;
    
    CGFloat maxWidth = leftViewbounds.size.width > rightViewbounds.size.width ? leftViewbounds.size.width : rightViewbounds.size.width;
    
    maxWidth += 15;//leftview 左右都有间隙，左边是5像素，右边是8像素，加2个像素的阀值 5 ＋ 8 ＋ 2
    
    frame = lblTitle.frame;
    
    frame.size.width = 200 - maxWidth * 2;
    
    lblTitle.frame = frame;
    
    frame = lblTitle2.frame;
    
    frame.size.width = 200 - maxWidth * 2;
    
    lblTitle2.frame = frame;
    
    frame = tView.frame;
    
    frame.size.width = 200 - maxWidth * 2;
    
    tView.frame = frame;
    
    [tView addSubview:lblTitle];
    [tView addSubview:lblTitle2];
    
    [self.navigationItem setTitleView:tView];
}


/***********************************************************************
 * 方法名称： getData
 * 功能描述： 加载数据
 * 输入参数：
 * 输出参数：
 * 返 回 值：
 ***********************************************************************/
- (void)getData
{
    [[RGHudModular getRGHud] showPopHudWithMessage:@"加载中..." inView:self.view];
    
    AFHTTPRequestOperationManager   *manager    = [AFHTTPRequestOperationManager manager];

    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    
    // 组合table字符串
    NSMutableDictionary *table = [NSMutableDictionary dictionaryWithCapacity:4];
    NSString *kpiId = [self.kpiJson objectForKey:@"col_id"];
    NSString *kpi_name = [self.kpiJson objectForKey:@"text"];
    
    [self.kpiJson setObject:kpiId forKey:@"kpi_id"];
    
    [self.kpiJson setObject:kpi_name forKey:@"kpi_name"];
     
    
    [table setObject:@[self.kpiJson] forKey:@"kpiJson"];
    NSMutableDictionary *tableJson = [NSMutableDictionary dictionaryWithCapacity:2];
    
    // 组合rows字符串
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
        [tableJson setObject:@[self.tableRows] forKey:@"rows"];
    }else{
        [tableJson setObject:@[] forKey:@"rows"];
    }
    
    // 组合cols字符串
    if (self.tableCols != nil) {
        NSString *tname = [self.tableCols objectForKey:@"text"];
        NSString *type = [self.tableCols objectForKey:@"dim_type"];
        NSString *colname = [self.tableCols objectForKey:@"col_name"];

        [self.tableCols setObject:tname forKey:@"name"];
        [self.tableCols setObject:tname forKey:@"dimdesc"];
        [self.tableCols setObject:type forKey:@"type"];
        [self.tableCols setObject:colname forKey:@"colname"];

        [tableJson setObject:@[self.tableCols,@{@"type":@"kpiOther",@"id":@"kpi"}] forKey:@"cols"];
    }else{
        [tableJson setObject:@[@{@"type":@"kpiOther",@"id":@"kpi"}] forKey:@"cols"];
    }
    
    // 组合tableJson字符串
    if ([tableJson allKeys].count != 0) {
        [table setObject:tableJson forKey:@"tableJson"];
    }
    
    // 组合pageInfo字符串
    NSMutableDictionary * pageInfo = [NSMutableDictionary dictionaryWithCapacity:2];
    [pageInfo setObject:table forKey:@"table"];
     if (self.params != nil) {
         NSString *tname = [self.params objectForKey:@"text"];
         NSString *type = [self.params objectForKey:@"dim_type"];
         NSString *colname = [self.params objectForKey:@"col_name"];
         [self.params setObject:tname forKey:@"name"];
         [self.params setObject:type forKey:@"type"];
         [self.params setObject:colname forKey:@"colname"];
        [pageInfo setObject:@[self.params] forKey:@"params"];
    }
    
 
//    NSLog(@"---传入-%@",[pageInfo JSONString]);
    // 组合传入字符串
    NSDictionary     *parameters = @{@"token": [Common shareInstence].token
                                     ,@"pageInfo":[pageInfo JSONString]};
    
    [manager POST:WEB_SERVICE_COMPTABLE([Common GetServiceHost]) parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {

//        NSLog(@"得到的数据：%@",responseObject);
        // 解析数据
        NSDictionary *tDict = responseObject;
        NSArray      *compsArr = [tDict objectForKey:@"comps"];
        NSDictionary *dDict = compsArr.firstObject;
        
        headerData = [dDict objectForKey:@"head"];
        dataArray = [dDict objectForKey:@"data"];
        paramArray = [tDict objectForKey:@"params"];
        
        [[RGHudModular getRGHud] hidePopHudInView:self.view];
        
        if (headerData.count == 1) {
            headerHeight = kHeadrHeight;
//            if (self.myTableView == nil) {
                [self initTableView];
//            }
            
        }else{
            headerHeight = kHeadrHeight * 2;
//            if (self.myTableView == nil) {
                [self initTableView];
//            }
        }
        
 
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        // 判断token是否可用
        NSString *errStr = operation.responseString;
        if (![Common isBlankString:errStr]&& [errStr isEqualToString:@"\r\n{error:'用户未登录。'}"]) {
            [[RGHudModular getRGHud] showAutoHudWithMessageDefault:@"用户登录失效,请重新登录"];
            [Common shareInstence].isLogin = NO;
            [self.navigationController popToRootViewControllerAnimated:false];
            return ;
        }
        [[RGHudModular getRGHud] showAutoHudWithMessageDefault:@"网络错误"];
        [self.navigationController popViewControllerAnimated:true];
    }];
 
}

- (void)initTableView
{
    assert(headerData.count != 0);
    for (UIView *subView in self.view.subviews) {
        [subView removeFromSuperview];
    }
    NSArray *contentArr = headerData.firstObject;
    float marginTop = 0;
    if (paramArray != nil && paramArray.count != 0) {
        marginTop = 60;
        [self setUpParamsView];
    }
    
    UIView *tableViewHeadView=[[UIView alloc]initWithFrame:CGRectMake(0, marginTop, (contentArr.count-1)*kWidth, headerHeight)];
    self.myHeadView=tableViewHeadView;
    NSString *tmpTitle = @"";
    NSArray *arr = headerData.firstObject;
    
    tmpTitle = [arr.firstObject objectForKey:@"name"];
    
    for (int j=0; j<headerData.count; j++) {
        NSArray *arr = [headerData objectAtIndex:j];
        
        
        for(int i=1;i<arr.count;i++){
            NSDictionary *ttDict = [arr objectAtIndex:i];
            HeadView *headView=[[HeadView alloc]initWithFrame:CGRectMake((i-1)*kWidth, j*kHeadrHeight, kWidth, kHeadrHeight)];
            ;
            headView.detail=[ttDict objectForKey:@"name"];
            headView.backgroundColor = [UIColor colorWithRed:239/255.0 green:239/255.0 blue:239/255.0 alpha:1];
            
            [tableViewHeadView addSubview:headView];
            
            
        }
    }
    
    UITableView *tableView=[[UITableView alloc]initWithFrame:CGRectMake(0, 0, self.myHeadView.frame.size.width, SCREEN_HEIGHT - 65 - marginTop) style:UITableViewStylePlain];
    tableView.delegate=self;
    tableView.dataSource=self;
    tableView.bounces=NO;
    tableView.backgroundColor = [UIColor clearColor];
    tableView.separatorStyle=UITableViewCellSeparatorStyleNone;
    self.myTableView=tableView;
    
    UIScrollView *myScrollView=[[UIScrollView alloc]initWithFrame:CGRectMake(kWidth, marginTop, SCREEN_WIDTH-kWidth, SCREEN_HEIGHT -  20)];
    [myScrollView addSubview:tableView];
    myScrollView.backgroundColor = [UIColor clearColor];
    myScrollView.bounces=NO;
    myScrollView.contentSize=CGSizeMake(self.myHeadView.frame.size.width,0);
    [self.view addSubview:myScrollView];
    
    self.timeView =[[TimeView alloc]initWithFrame:CGRectMake(0, headerHeight + marginTop, kWidth, SCREEN_HEIGHT-104) marginTop:0 dataArray:dataArray];
    self.timeView.delegate = self;
    self.timeView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:self.timeView];
    
    HeadView *headView=[[HeadView alloc]initWithFrame:CGRectMake(0, marginTop, kWidth, headerHeight)];
    ;
    headView.detail=tmpTitle;
    headView.backgroundColor = [UIColor colorWithRed:239/255.0 green:239/255.0 blue:239/255.0 alpha:1];
    [self.view  addSubview:headView];
  
    
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return dataArray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier=@"dstcell";
    
    MyCell *cell=[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    NSMutableArray *arrTmp = [NSMutableArray arrayWithArray:[dataArray objectAtIndex:indexPath.row]];
    if(cell==nil){
        
        cell=[[MyCell alloc]initCellWithCount:(int)arrTmp.count-1];
 
        cell.selectionStyle=UITableViewCellSelectionStyleNone;
       
        cell.backgroundColor = [UIColor colorWithRed:249/255.0 green:249/255.0 blue:249/255.0 alpha:1];
    }
    
    [arrTmp removeObjectAtIndex:0];
    [cell setCellArray:arrTmp];
    
    cell.index = (int)indexPath.row;

    return cell;
}
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    
    return self.myHeadView;
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    
    return headerHeight;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return kHeight;
}
-(void)myHeadView:(HeadView *)headView point:(CGPoint)point
{
    CGPoint myPoint= [self.myTableView convertPoint:point fromView:headView];
    
    [self convertRoomFromPoint:myPoint];
}
-(void)convertRoomFromPoint:(CGPoint)ponit
{
 
}

-(void)timeViewDidScroll:(CGPoint)offset
{
    CGPoint tmpOffset = self.myTableView.contentOffset;
    tmpOffset.y = offset.y;
    
    self.myTableView.contentOffset = tmpOffset;
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat offsetY= self.myTableView.contentOffset.y;
    CGPoint timeOffsetY=self.timeView.timeTableView.contentOffset;
    timeOffsetY.y=offsetY;
    self.timeView.timeTableView.contentOffset=timeOffsetY;
    if(offsetY==0){
        self.timeView.timeTableView.contentOffset=CGPointZero;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
