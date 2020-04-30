/*********************************************************************
 * 版权所有   magic_Zzz
 *
 * 文件名称： FilterWedoViewController
 * 内容摘要： // 筛选维度
 * 其它说明： 实现文件
 * 作 成 者： ZGD
 * 完成日期： 2016年03月22日
 * 修改记录1：
 * 修改日期：
 * 修 改 人：
 * 修改内容：
 * 修改记录2：
 **********************************************************************/

#import "FilterWedoViewController.h"
#import "ParameterListViewController.h"
#import "MJRefresh.h"
#import "Common.h"
#import "AFNetworking.h"
#import "RGHudModular.h"
#import "KLCPopup.h"
#import "SelectParamsPickerView.h"
#import "PMCalendar.h"

@interface FilterWedoViewController ()<UITableViewDataSource,UITableViewDelegate,PMCalendarControllerDelegate>
{
    NSInteger currentIndex;// 当前选中path
    UIBarButtonItem *nextBtn; // 完成按钮
    NSMutableDictionary *curDict;//当前选中的字典
    UILabel *lblValue;// 第一个值
    UILabel *lblValue2;// 第二个值
    int      currentShow;// 当前弹出的框
    NSString *dimType;// 参数类型
    NSArray  *beginArray;//开始时间
    NSArray  *endArray;// 结束时间

}

@property (nonatomic, strong) PMCalendarController *pmCC;
@property (weak, nonatomic) IBOutlet UITableView *myTableView;
@property (nonatomic,strong) NSMutableArray *dataArray;// 维度array

@end

@implementation FilterWedoViewController
@synthesize dataArray;
@synthesize myTableView;
@synthesize wedoType;
@synthesize selectArray;


- (void)viewDidLoad {
    [super viewDidLoad];
    
    currentIndex = -1;
    dataArray    = [[NSMutableArray alloc]init];
//    selectArray  = [[NSMutableArray alloc]init];
    
    self.myTableView.showsVerticalScrollIndicator = FALSE;
    self.myTableView.dataSource         = self;
    self.myTableView.delegate           = self;
    self.myTableView.backgroundColor    = [UIColor whiteColor];
    self.myTableView.separatorStyle     = UITableViewCellSeparatorStyleNone;
    self.navigationItem.title = @"维度筛选";
    
    // 添加下拉加载页面
    __weak typeof(self) weakSelf        = self;
    
    self.myTableView.header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [weakSelf getData];
    }];
    
    
    [self.myTableView.header beginRefreshing];
    
    // 添加确定按钮
    NSMutableDictionary *dict =[NSMutableDictionary dictionaryWithCapacity:1];
    [dict setObject:[UIFont systemFontOfSize:15] forKey:NSFontAttributeName];
  
    
    nextBtn = [[UIBarButtonItem alloc] initWithTitle:@"确定" style:UIBarButtonItemStylePlain target:self action:@selector(clickDone)];
//    nextBtn.enabled = false;
    [nextBtn setTitleTextAttributes:dict forState:UIControlStateNormal];
    self.navigationItem.rightBarButtonItem = nextBtn;
    
}

/***********************************************************************
 * 方法名称： setUpParamsView
 * 功能描述： 设置查询条件视图(H60)
 * 输入参数：
 * 输出参数：
 * 返 回 值：
 ***********************************************************************/
-(void)setUpParamsView:(NSString *)title1 name:(NSString *)title2
{
    
    UIView *headerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 120)];
    headerView.backgroundColor = [UIColor colorWithRed:253/255.0 green:253/255.0 blue:253/255.0 alpha:1];
    // 添加标题
    UILabel *pTitle = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 70, 60)];
    pTitle.text = title1;
    pTitle.textAlignment = NSTextAlignmentCenter;
    pTitle.font = [UIFont systemFontOfSize:15];
    
    [headerView addSubview:pTitle];
    UILabel *pTitle2 = [[UILabel alloc]initWithFrame:CGRectMake(0, 60, 70, 60)];
    pTitle2.text = title2;
    pTitle2.textAlignment = NSTextAlignmentCenter;
    pTitle2.font = [UIFont systemFontOfSize:15];
    
    [headerView addSubview:pTitle2];
    
    lblValue = [[UILabel alloc]initWithFrame:CGRectMake(80, 15, 200, 30)];
    lblValue.tag = 1;
    lblValue.layer.borderColor = MT_LINE_COLOR.CGColor;
    lblValue.layer.borderWidth = 1;
    lblValue.backgroundColor = [UIColor whiteColor];
    lblValue.font = [UIFont systemFontOfSize:15];
    if (curDict != nil) {
        NSDictionary *startMt = [curDict objectForKey:@"val1"];
        if (startMt != nil) {
            lblValue.text = [startMt objectForKey:@"name"];
        }
        
    }
 
    lblValue.textAlignment = NSTextAlignmentCenter;
    lblValue.userInteractionEnabled = YES;
    UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(singleTap:)];
    [lblValue addGestureRecognizer:gesture];
    [headerView addSubview:lblValue];
    
    lblValue2 = [[UILabel alloc]initWithFrame:CGRectMake(80, 15 + 60 , 200, 30)];
    lblValue2.tag = 2;
    lblValue2.font = [UIFont systemFontOfSize:15];
    lblValue2.textAlignment = NSTextAlignmentCenter;
    lblValue2.layer.borderColor = MT_LINE_COLOR.CGColor;
    lblValue2.layer.borderWidth = 1;
    lblValue2.backgroundColor = [UIColor whiteColor];

    if (curDict != nil) {
        NSDictionary *endmt = [curDict objectForKey:@"val2"];
        if (endmt != nil) {
            lblValue2.text = [endmt objectForKey:@"name"];
        }
        
    }
//            lblValue2.text = [NSString stringWithFormat:@"%@",val2];
    lblValue2.userInteractionEnabled = YES;
    UITapGestureRecognizer *gesture2 = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(singleTap:)];
    [lblValue2 addGestureRecognizer:gesture2];
    [headerView addSubview:lblValue2];
    
    
    
    
    [self.view addSubview:headerView];
}

/***********************************************************************
 * 方法名称： setUpParamsView
 * 功能描述： 设置查询条件视图(H60)
 * 输入参数：
 * 输出参数：
 * 返 回 值：
 ***********************************************************************/
-(void)setUpDateView:(NSDictionary *)title1 name:(NSDictionary *)title2
{
    
    UIView *headerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 120)];
    headerView.backgroundColor = [UIColor colorWithRed:253/255.0 green:253/255.0 blue:253/255.0 alpha:1];
    // 添加标题
    UILabel *pTitle = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 70, 60)];
    pTitle.text = [title1 objectForKey:@"name"];
    pTitle.textAlignment = NSTextAlignmentCenter;
    pTitle.font = [UIFont systemFontOfSize:15];
    
    [headerView addSubview:pTitle];
    UILabel *pTitle2 = [[UILabel alloc]initWithFrame:CGRectMake(0, 60, 70, 60)];
    pTitle2.text = [title2 objectForKey:@"name"];
    pTitle2.textAlignment = NSTextAlignmentCenter;
    pTitle2.font = [UIFont systemFontOfSize:15];
    
    [headerView addSubview:pTitle2];
    
    lblValue = [[UILabel alloc]initWithFrame:CGRectMake(80, 15, 200, 30)];
    lblValue.tag = 1;
    lblValue.layer.borderColor = MT_LINE_COLOR.CGColor;
    lblValue.layer.borderWidth = 1;
    lblValue.backgroundColor = [UIColor whiteColor];
    lblValue.font = [UIFont systemFontOfSize:15];
    lblValue.text = [title1 objectForKey:@"min"];
    if (self.defDict != nil) {
//        NSLog(@"def ---%@",self.defDict);
        NSString *endmt = [self.defDict objectForKey:@"startdt"];
        if (endmt != nil) {
            lblValue.text = endmt;
        }
        
    }
    
    lblValue.textAlignment = NSTextAlignmentCenter;
    lblValue.userInteractionEnabled = YES;
    UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(singleDateTap:)];
    [lblValue addGestureRecognizer:gesture];
    [headerView addSubview:lblValue];
    
    lblValue2 = [[UILabel alloc]initWithFrame:CGRectMake(80, 15 + 60 , 200, 30)];
    lblValue2.tag = 2;
    lblValue2.font = [UIFont systemFontOfSize:15];
    lblValue2.textAlignment = NSTextAlignmentCenter;
    lblValue2.layer.borderColor = MT_LINE_COLOR.CGColor;
    lblValue2.layer.borderWidth = 1;
    lblValue2.backgroundColor = [UIColor whiteColor];
    lblValue2.text = [title2 objectForKey:@"max"];
    if (self.defDict != nil) {
        NSString *endmt = [self.defDict objectForKey:@"enddt"];
        if (endmt != nil) {
            lblValue2.text = endmt;
        }
        
    }
    lblValue2.userInteractionEnabled = YES;
    UITapGestureRecognizer *gesture2 = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(singleDateTap:)];
    [lblValue2 addGestureRecognizer:gesture2];
    [headerView addSubview:lblValue2];

    
    
    
    [self.view addSubview:headerView];
}


- (void)calendarController:(PMCalendarController *)calendarController didChangePeriod:(PMPeriod *)newPeriod
{
    if (self.pmCC.specFlag == 1) {
        lblValue.text = [newPeriod.startDate dateStringWithFormat:@"yyyy-MM-dd"];
    }else{
        lblValue2.text = [newPeriod.startDate dateStringWithFormat:@"yyyy-MM-dd"];
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
        id sender=lblValue;
        
        if (tTag == 1) {
            
            if (![Common isBlankString:lblValue.text]) {
                self.pmCC.period = [PMPeriod oneDayPeriodWithDate:[Common convertDateFromString:lblValue.text withFormat:@"yyyy-MM-dd"]];
                self.pmCC.showCurrent = YES;
            }
            
            
        }else{
            if (![Common isBlankString:lblValue2.text]) {
                self.pmCC.period = [PMPeriod oneDayPeriodWithDate:[Common convertDateFromString:lblValue2.text withFormat:@"yyyy-MM-dd"]];
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
 * 功能描述： 点击事件
 * 输入参数：
 * 输出参数：
 * 返 回 值：
 ***********************************************************************/
- (void)singleTap:(UITapGestureRecognizer *)gesture
{
    if (gesture.state == UIGestureRecognizerStateEnded) {
        int tTag = gesture.view.tag;
        
        
        KLCPopupLayout layout = KLCPopupLayoutMake(KLCPopupHorizontalLayoutCenter, KLCPopupVerticalLayoutBottom);
        SelectParamsPickerView *sppv = [[SelectParamsPickerView alloc]initWithData:tTag==1 ? beginArray:endArray flag:YES withDelegate:self];
        sppv.cFlag = tTag;
        sppv.specFlag = YES;
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
 * 方法名称：- (void)getData
 * 功能描述： 加载数据
 * 输入参数：
 * 输出参数：
 * 返 回 值：
 ***********************************************************************/
- (void)getData
{
    AFHTTPRequestOperationManager   *manager    = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    
    NSDictionary     *parameters = @{@"token": [Common shareInstence].token
                                     ,@"tid":_selectTid,@"dimId":_dimId};
    NSString *urlString = WEB_SERVICE_DIMFILTER([Common GetServiceHost]);
    
    
    [manager GET:urlString parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        [self.myTableView.header endRefreshing];
        NSLog(@"得到的数据是：%@",responseObject);
        NSDictionary *rDict = responseObject;
        wedoType = [rDict objectForKey:@"type"];
        currentIndex = -1;
        
        if ([wedoType isEqualToString:@"other"]) {
            dataArray = [[NSMutableArray alloc]initWithArray:[rDict objectForKey:@"options"]];
            [myTableView reloadData];
            myTableView.hidden = false;
        }else if ([wedoType isEqualToString:@"month"]) {
            myTableView.hidden = true;
            NSDictionary *startMonth = [rDict objectForKey:@"startMonth"];
            NSDictionary *endMonth = [rDict objectForKey:@"endMonth"];
            beginArray = [startMonth objectForKey:@"options"];
            endArray   = [endMonth objectForKey:@"options"];
            curDict = [NSMutableDictionary dictionaryWithCapacity:2];
            if (self.defDict != nil) {
                NSString *startMt = [self.defDict objectForKey:@"startmt"];
                NSString *endmt = [self.defDict objectForKey:@"endmt"];
                if (startMt != nil) {
                    for (NSDictionary *ttDict in beginArray) {
                        NSNumber *idVal = ttDict[@"id"];
                        if (idVal.integerValue == startMt.integerValue) {
                            [curDict setObject:ttDict forKey:@"val1"];
                            break;
                        }
                    }
                    
                }
                if (endmt != nil) {
                    for (NSDictionary *ttDict in endArray) {
                        NSNumber *idVal = ttDict[@"id"];
                        if (idVal.integerValue == idVal.integerValue) {
                            [curDict setObject:ttDict forKey:@"val2"];
                            break;
                        }
                    }
                    
                }
            }
            [self setUpParamsView:[startMonth objectForKey:@"name"] name:[endMonth objectForKey:@"name"]];
            
        }else if ([wedoType isEqualToString:@"day"]){
            myTableView.hidden = true;
            NSDictionary *startMonth = [rDict objectForKey:@"startDay"];
            NSDictionary *endMonth = [rDict objectForKey:@"endDay"];
            [self setUpDateView:startMonth name:endMonth];
        }
        
//        NSLog(@"筛选arr：%@",responseObject);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        // 判断token是否可用
        NSString *errStr = operation.responseString;
        if (![Common isBlankString:errStr]&& [errStr isEqualToString:@"\r\n{error:'用户未登录。'}"]) {
            [[RGHudModular getRGHud] showAutoHudWithMessageDefault:@"用户登录失效,请重新登录"];
            [Common shareInstence].isLogin = NO;
            [self.navigationController popToRootViewControllerAnimated:false];
            return ;
        }
        [self.myTableView.header endRefreshing];
        [[RGHudModular getRGHud] showAutoHudWithMessageDefault:@"网络错误"];
    }];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return dataArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 40;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString         *CellIdentifier = @"plCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone; //选中cell时无色
     
        cell.contentView.backgroundColor = MT_CELL_COLOR;
    }
    
    for (UIView *subView in cell.contentView.subviews) {
        [subView removeFromSuperview];
    }
    
    NSDictionary *data = [dataArray objectAtIndex:indexPath.row];
 
    
    UILabel *lblName = [[UILabel alloc]initWithFrame:CGRectMake(40, 0, SCREEN_WIDTH - 40, 40)];
    lblName.text = [data objectForKey:@"name"];
    lblName.font = [UIFont systemFontOfSize:13];
    UIView  *lineView = [[UIView alloc]initWithFrame:CGRectMake(0, 39, SCREEN_WIDTH, 1)];
    lineView.backgroundColor = MT_LINE_COLOR;
    [cell.contentView addSubview:lblName];
    [cell.contentView addSubview:lineView];
    UIImageView *selectImg = [[UIImageView alloc]initWithFrame:CGRectMake(10, 7.5, 25, 25)];
    [cell.contentView addSubview:selectImg];
    
    id mmm = [data objectForKey:@"id"];
    BOOL flag = false;
    for (int i=0;i<selectArray.count;i++) {
        NSDictionary *tmp = selectArray[i];
        id nnn = [tmp objectForKey:@"id"];
        if ([mmm isKindOfClass:[NSNumber class]]) {
            if ([mmm intValue] == [nnn intValue]) {
                flag = YES;
                break;
            }
        }else{
            if ([mmm isEqualToString:nnn]) {
                flag = YES;
                break;
            }
        }
    }
    
    if (flag)
    {
       selectImg.image = [UIImage imageNamed:@"cellSelect-1"];
    }
    else
    {
        selectImg.image = [UIImage imageNamed:@"cellnormal-1"];
    }
    
    return cell;
    
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    currentIndex = indexPath.row;
    NSDictionary *dict = [dataArray objectAtIndex:indexPath.row];
    id mmm = [dict objectForKey:@"id"];
    NSInteger flag = -1;
    for (int i=0;i<selectArray.count;i++) {
        NSDictionary *tmp = selectArray[i];
        id nnn = [tmp objectForKey:@"id"];
        if ([mmm isKindOfClass:[NSNumber class]]) {
            if ([mmm intValue] == [nnn intValue]) {
                flag = i;
                break;
            }
        }else{
            if ([mmm isEqualToString:nnn]) {
                flag = i;
                break;
            }
        }
        
    }
    
    if (flag != -1) {
        [selectArray removeObjectAtIndex:flag];
    }else{
        [selectArray addObject:[dataArray objectAtIndex:indexPath.row]];
    }
    
//    NSLog(@"%@",[dataArray objectAtIndex:currentIndex]);
//    if (selectArray.count != 0) {
//        nextBtn.enabled = true;
//    }else{
//        nextBtn.enabled = false;
//    }
    [tableView reloadData];
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
 
    switch (flag) {
        case 1://第一个参数值
            [curDict setObject:aDict forKey:@"val1"];
            lblValue.text = [NSString stringWithFormat:@"%@",[aDict objectForKey:@"name"]];
            break;
        case 2://第2个参数值
            if ([wedoType isEqualToString:@"month"]) {// 参数为month时
                
              
            }
            [curDict setObject:aDict forKey:@"val2"];
            lblValue2.text = [NSString stringWithFormat:@"%@",[aDict objectForKey:@"name"]];
            break;
        default:
            break;
    }
    
}

/***********************************************************************
 * 方法名称：- (void)clickDone
 * 功能描述： 确定选中
 * 输入参数：
 * 输出参数：
 * 返 回 值：
 ***********************************************************************/
- (void)clickDone
{
    
    if (self.delegate) {
        if ([wedoType isEqualToString:@"day"]) {
            NSString *txt1 = [lblValue.text stringByReplacingOccurrencesOfString:@"-" withString:@""];
            NSString *txt2 = [lblValue2.text stringByReplacingOccurrencesOfString:@"-" withString:@""];
            if (txt1.integerValue > txt2.integerValue) {
                [[RGHudModular getRGHud]showAutoHudWithMessageDefault:@"结束日期不能小于起始时间"];
                return;
            }
            
            selectArray = [NSMutableArray arrayWithObjects:lblValue.text,lblValue2.text, nil];
           
        }else if([wedoType isEqualToString:@"month"]){
            NSDictionary *val1=[curDict objectForKey:@"val1"];
            NSDictionary *val2=[curDict objectForKey:@"val2"];
            if (val1 == nil || val2 == nil) {
                [[RGHudModular getRGHud]showAutoHudWithMessageDefault:@"日期不能为空"];
                return;
            }
            NSNumber *idVal1 = [val1 objectForKey:@"id"];
            NSNumber *idVal2 = [val2 objectForKey:@"id"];
            
            if (idVal1.integerValue > idVal2.integerValue) {
                [[RGHudModular getRGHud]showAutoHudWithMessageDefault:@"结束日期不能小于起始时间"];
                return;
            }
            selectArray = [NSMutableArray arrayWithObjects:[NSString stringWithFormat:@"%@",idVal1],[NSString stringWithFormat:@"%@",idVal2], nil];
        }
        
        [self.delegate didFilterSelected:selectArray withType:self.currentType wedo:wedoType];
        [self.navigationController popViewControllerAnimated:YES];
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
