/*********************************************************************
 * 版权所有   magic_Zzz
 *
 * 文件名称： PivotDataSetViewController
 * 内容摘要： 数据透视 --- 数据配置
 * 其它说明： 实现文件
 * 作 成 者： ZGD
 * 完成日期： 2016年03月22日
 * 修改记录1：
 * 修改日期：
 * 修 改 人：
 * 修改内容：
 * 修改记录2：
 **********************************************************************/


#import "PivotDataSetViewController.h"
#import "Common.h"
#import "AFNetworking.h"
#import "MJRefresh.h"
#import "RGHudModular.h"
#import "ParameterListViewController.h"
#import "DataShowTableViewController.h"
#import "GraphShowViewController.h"
#import "StoreConfigPopView.h"
#import "KLCPopup.h"
#import "SelectParamsPickerView.h"
#import "FilterWedoViewController.h"
#import "JSONKit.h"

@interface PivotDataSetViewController ()<UITableViewDataSource,UITableViewDelegate,ParameterSelectDelegate,StoreConfigPopViewDelegate,FilterWedoViewControllerDelegate>
{
    NSArray *nameArray;// 名字数组
    NSMutableDictionary *selectDict;// 选择好的度量
    NSString *filterWedo1;// 维度类型
    NSString *filterWedo2;// 维度类型
    NSString *saveID;//保存的id
    NSString *saveName;//保存的名字
}
@property (weak, nonatomic) IBOutlet UIButton *btnTable;// 表格按扭
@property (weak, nonatomic) IBOutlet UIButton *btnPlot;// 图形按扭
@property (weak, nonatomic) IBOutlet UITableView *myTableView;// 列表
@property (nonatomic,strong) NSMutableArray *dataArray;// 度量array
@property (nonatomic,strong) NSMutableArray *filterWedoArray1;
@property (nonatomic,strong) NSMutableArray *filterWedoArray2;
@end

@implementation PivotDataSetViewController
@synthesize dataArray;
@synthesize myTableView;
@synthesize btnPlot;
@synthesize btnTable;
@synthesize filterWedoArray1;
@synthesize filterWedoArray2;

- (void)viewDidLoad {
    [super viewDidLoad];
   
    saveID = @"";
    saveName = @"";
    // 调整按扭样式
    
    btnTable.layer.masksToBounds = YES;
    btnTable.layer.cornerRadius = 6;
  
    filterWedoArray1 = [[NSMutableArray alloc]init];
    filterWedoArray2 = [[NSMutableArray alloc]init];
    btnPlot.layer.masksToBounds = YES;
    btnPlot.layer.cornerRadius = 6;
    
    
    nameArray = [[NSArray alloc]initWithObjects:@"查询条件",@"行标签（横轴）",@"列标签（图例）",@"度   量（纵轴）", nil];
    dataArray = [[NSMutableArray alloc]init];
    
    selectDict = [NSMutableDictionary dictionaryWithCapacity:4];//dict0,dict1,dict2,dict3
    
    //设置titleview
    [self setUPTitleView];
    
   
    // 右上角按钮
    UIImage *imgRight = [UIImage imageNamed:@"btn_save"];
    UIButton *rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    rightBtn.frame = CGRectMake(0, 0, imgRight.size.width, imgRight.size.height);
    [rightBtn setBackgroundImage:imgRight forState:UIControlStateNormal];
    [rightBtn addTarget:self action:@selector(clickSave) forControlEvents:UIControlEventTouchUpInside];
    
    [self.navigationItem setRightBarButtonItem:[[UIBarButtonItem alloc]initWithCustomView:rightBtn]];
    
    // 初始化列表
    self.myTableView.showsVerticalScrollIndicator = FALSE;
    self.myTableView.dataSource         = self;
    self.myTableView.delegate           = self;
    self.myTableView.backgroundColor    = [UIColor whiteColor];
    self.myTableView.separatorStyle     = UITableViewCellSeparatorStyleNone;
    
 
    [myTableView reloadData];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        //刷新完成
        if ([self hasHistory]) {// 有历史数据就还原配置
            assert([self.historyDict objectForKey:@"id"] != nil);
            saveID = [NSString stringWithFormat:@"%@",[self.historyDict objectForKey:@"id"]];
            saveName = [self.historyDict objectForKey:@"subjectname"];
            NSDictionary *table = [self.historyDict objectForKey:@"table"];//表格
            
            NSArray *kpiJsonArr = [table objectForKey:@"kpiJson"];// 度量
            if (kpiJsonArr.count == 0) {
                return ;
            }
            // 转化kpiJson 度量
            NSDictionary *kpiJson = [Common converKpiJson:kpiJsonArr.firstObject];
            [selectDict setObject:kpiJson forKey:@"dict3"];
            
            NSDictionary *tableJson = [table objectForKey:@"tableJson"];// 表格数据
            // 转化rows字符串
            NSArray *rowsArr = [tableJson objectForKey:@"rows"];
            
            if (rowsArr.count != 0) {
                NSDictionary *rows = [Common converRowsJson:rowsArr.firstObject];
                [selectDict setObject:rows forKey:@"dict1"];
                //vals valStrs endmt enddt startdt startmt
                NSString *vals = [rows objectForKey:@"vals"];
                NSString *startdt = [rows objectForKey:@"startdt"];
                NSString *enddt = [rows objectForKey:@"enddt"];
                NSString *startmt = [rows objectForKey:@"startmt"];
                NSString *endmt = [rows objectForKey:@"endmt"];
                filterWedoArray1 = [[NSMutableArray alloc]init];
                if (vals != nil) {// 普通类型
                    filterWedo1 = @"other";
                    NSArray *list=[vals componentsSeparatedByString:@","];
                    
                    for (NSString *subStr in list) {
                        
                        [filterWedoArray1 addObject:@{@"id":subStr,@"name":subStr}];
                    }
                    
                }else if (enddt != nil || startdt != nil){//day
                    filterWedo1 = @"day";
                    [filterWedoArray1 addObject:startdt];
                    [filterWedoArray1 addObject:enddt];
                }else if(endmt != nil || startmt != nil){//month
                    filterWedo1 = @"month";
                    [filterWedoArray1 addObject:startmt];
                    [filterWedoArray1 addObject:endmt];
                }
                
            }
            // 转化cols字符串
            NSArray *colsArr = [tableJson objectForKey:@"cols"];
            
            if (colsArr.count != 0) {
                NSDictionary *tmpCols = colsArr.firstObject;
                if (tmpCols.count != 2) {
                    NSDictionary *cols = [Common converColsJson:tmpCols];
                    [selectDict setObject:cols forKey:@"dict2"];
                    //vals valStrs endmt enddt startdt startmt
                    NSString *vals = [cols objectForKey:@"vals"];
                    NSString *enddt = [cols objectForKey:@"enddt"];
                    NSString *endmt = [cols objectForKey:@"endmt"];
                    filterWedoArray2 = [[NSMutableArray alloc]init];
                    if (vals != nil) {// 普通类型
                        filterWedo2 = @"other";
                        NSArray *list=[vals componentsSeparatedByString:@","];
                        
                        for (NSString *subStr in list) {
                            
                            [filterWedoArray2 addObject:@{@"id":subStr,@"name":subStr}];
                        }
                        
                    }else if (enddt != nil){//day
                        filterWedo2 = @"day";
                        [filterWedoArray2 addObject:[cols objectForKey:@"startdt"]];
                        [filterWedoArray2 addObject:[cols objectForKey:@"enddt"]];
                    }else if (endmt != nil){//month
                        filterWedo2 = @"month";
                        [filterWedoArray2 addObject:[cols objectForKey:@"startmt"]];
                        [filterWedoArray2 addObject:[cols objectForKey:@"endmt"]];
                    }
                }
            }
            
            // 转化查询条件
            NSArray *params = [self.historyDict objectForKey:@"params"];//查询条件
            if (params.count != 0) {
                NSDictionary *paramdict = [Common converParamsJson:params.firstObject];
                [selectDict setObject:paramdict forKey:@"dict0"];
            }
            
            [myTableView reloadData];
//            NSLog(@"还原配置%@",self.historyDict);
            
        }
        
    });
    
}


-(UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return 0;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationPortrait animated:false];
}
/***********************************************************************
 * 方法名称： hasHistory
 * 功能描述： 是否有历史数据就还原配置
 * 输入参数：
 * 输出参数：
 * 返 回 值：
 ***********************************************************************/
-(BOOL)hasHistory
{
    BOOL flag = NO;
    if (self.historyDict != nil) {// 有历史数据就还原配置
        NSString *cTid = [NSString stringWithFormat:@"%@",[self.historyDict objectForKey:@"tid"]];
        if ([cTid isEqualToString:self.selectTid]) {
            flag = YES;
        }
    }
    return flag;
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
    lblTitle2.text = @"数据配置";
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    tableView.sectionIndexBackgroundColor = [UIColor whiteColor];
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, myTableView.frame.size.width, 20)];
    view.backgroundColor = [UIColor  clearColor];
    
    return view;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return nameArray.count;
}


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 20;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 70;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString         *CellIdentifier = @"psCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone; //选中cell时无色
        cell.accessoryType  = UITableViewCellAccessoryDisclosureIndicator;
        cell.contentView.backgroundColor = MT_CELL_COLOR;
    }
    for(UIView *subView in cell.contentView.subviews ) {
        [subView removeFromSuperview];
    }
    
    UILabel *lblTitle = [[UILabel alloc]initWithFrame:CGRectMake(10, 0, 64, 70)];
    lblTitle.text = [nameArray objectAtIndex:indexPath.section];
    lblTitle.font = [UIFont systemFontOfSize:14];
    lblTitle.textAlignment = NSTextAlignmentCenter;
    lblTitle.numberOfLines = 2;
    [cell.contentView addSubview:lblTitle];
    
    UILabel *lblInfo = [[UILabel alloc]initWithFrame:CGRectMake(SCREEN_WIDTH - 200, 0, 170, 70)];
    lblInfo.textColor = [UIColor colorWithRed:64/255.0 green:63/255.0 blue:63/255.0 alpha:1];
    lblInfo.textAlignment = NSTextAlignmentRight;

    lblInfo.font = [UIFont systemFontOfSize:14];
    lblInfo.adjustsFontSizeToFitWidth = true;
    NSDictionary *tmpStr = [selectDict objectForKey:[NSString stringWithFormat:@"dict%d",(int)indexPath.section]];
    if (tmpStr != nil) {
        if ([tmpStr objectForKey:@"text"] == nil) {
            lblInfo.text = @"空";
        }else{
            
            CGSize labelsize = [self sizeWithString:[tmpStr objectForKey:@"text"] font:[UIFont systemFontOfSize:14]];
            lblInfo.frame = CGRectMake(SCREEN_WIDTH - 30 - labelsize.width, 0.0, labelsize.width, 70 );
        
            lblInfo.text = [tmpStr objectForKey:@"text"];
            
            UIButton *btnDel = [[UIButton alloc]initWithFrame:CGRectMake(SCREEN_WIDTH - 30 - labelsize.width - 35, 20, 30, 30)];
            [btnDel setImage:[UIImage imageNamed:@"btn_del"] forState:UIControlStateNormal];
            [btnDel addTarget:self action:@selector(delSelected:) forControlEvents:UIControlEventTouchUpInside];
            btnDel.tag = indexPath.section;
            [cell.contentView addSubview:btnDel];
            
            if (indexPath.section !=0 && indexPath.section != 3) {
                UIButton *btnFileter = [[UIButton alloc]initWithFrame:CGRectMake(SCREEN_WIDTH - 30 - labelsize.width - 30 - 45, 20, 30, 30)];
                [btnFileter setImage:[UIImage imageNamed:@"btn_filter"] forState:UIControlStateNormal];
                [btnFileter addTarget:self action:@selector(fileterSelected:) forControlEvents:UIControlEventTouchUpInside];
                btnFileter.tag = indexPath.section;
                [cell.contentView addSubview:btnFileter];
            }
        }
    }else{
        lblInfo.text = @"空";
    }
    
    
    [cell.contentView addSubview:lblInfo];
    
    UIView  *lineView = [[UIView alloc]initWithFrame:CGRectMake(0, 69, SCREEN_WIDTH, 1)];
    lineView.backgroundColor = MT_LINE_COLOR;
    UIView  *lineView1 = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 1)];
    lineView1.backgroundColor = MT_LINE_COLOR;
    [cell.contentView addSubview:lineView];
    [cell.contentView addSubview:lineView1];
    return cell;
}

/***********************************************************************
 * 方法名称： - (CGSize)sizeWithString:(NSString *)string font:(UIFont *)font
 * 功能描述： 定义成方法方便多个label调用 增加代码的复用性
 * 输入参数：
 * 输出参数：
 * 返 回 值：
 ***********************************************************************/
- (CGSize)sizeWithString:(NSString *)string font:(UIFont *)font
{
    CGRect rect = [string boundingRectWithSize:CGSizeMake(170, 40)//限制最大的宽度和高度
                                       options:NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesFontLeading  |NSStringDrawingUsesLineFragmentOrigin//采用换行模式
                                    attributes:@{NSFontAttributeName: font}//传人的字体字典
                                       context:nil];
    
    return rect.size;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    ParameterListViewController *plvc = [[ParameterListViewController alloc] initWithNibName:@"ParameterListViewController" bundle:nil];
    plvc.selectTid = self.selectTid;
    plvc.delegate = self;
    switch (indexPath.section) {
        case 0:
            plvc.currentType = ParameterTypeWeiDu1;// 查询条件
            plvc.defDict     = [selectDict objectForKey:@"dict0"];
            break;
        case 1:
            plvc.currentType = ParameterTypeWeiDu2;// 行标签
            plvc.defDict     = [selectDict objectForKey:@"dict1"];
            plvc.tmpDict     = [selectDict objectForKey:@"dict2"];
            break;
        case 2:
            plvc.currentType = ParameterTypeWeiDu3;// 列标签
            plvc.defDict     = [selectDict objectForKey:@"dict2"];
            plvc.tmpDict     = [selectDict objectForKey:@"dict1"];
            break;
        case 3:
            plvc.currentType = ParameterTypeDuliang;// 度量
            plvc.defDict     = [selectDict objectForKey:@"dict3"];
            break;
        default:
            break;
    }
   
    [self.navigationController pushViewController:plvc animated:true];
    
}


/***********************************************************************
 * 方法名称：- (void)delSelected:(UIButton *)sender
 * 功能描述： // 删除已选的参数
 * 输入参数：
 * 输出参数：
 * 返 回 值：
 ***********************************************************************/
- (void)delSelected:(UIButton *)sender
{
    [selectDict removeObjectForKey:[NSString stringWithFormat:@"dict%d",(int)sender.tag]];
    if (sender.tag == 1) {
        filterWedoArray1 = [[NSMutableArray alloc]init];
    }else if (sender.tag == 2){
        filterWedoArray2 = [[NSMutableArray alloc]init];
    }
    [myTableView reloadData];
}

/***********************************************************************
 * 方法名称：- (void)fileterSelected:(UIButton *)sender
 * 功能描述： // 筛选已选的参数
 * 输入参数：
 * 输出参数：
 * 返 回 值：
 ***********************************************************************/
- (void)fileterSelected:(UIButton *)sender
{
    FilterWedoViewController *fwvc = [[FilterWedoViewController alloc]initWithNibName:@"FilterWedoViewController" bundle:nil];
    fwvc.selectTid = self.selectTid;
    fwvc.delegate  = self;
    switch (sender.tag) {
        case 1:
            fwvc.currentType = ParameterTypeWeiDu2;// 行标签
            fwvc.defDict = [selectDict objectForKey:@"dict1"];
            fwvc.selectArray = [[NSMutableArray alloc]initWithArray:filterWedoArray1];
            break;
        case 2:
            fwvc.currentType = ParameterTypeWeiDu3;// 列标签
            fwvc.defDict = [selectDict objectForKey:@"dict2"];
            fwvc.selectArray = [[NSMutableArray alloc]initWithArray:filterWedoArray2];
            break;
        default:
            break;
    }
    fwvc.dimId   = [fwvc.defDict objectForKey:@"col_id"];
    
//    NSLog(@"fwvc.defDict ---- %@",fwvc.defDict);
    if (fwvc.dimId == nil) {
        return;
    }
    [self.navigationController pushViewController:fwvc animated:YES];
}

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
 * 方法名称：- (void)didFilterSelected:(NSArray *)arr withType:(ParameterType)pType
 * 功能描述： // 筛选代理方法
 * 输入参数：
 * 输出参数：
 * 返 回 值：
 ***********************************************************************/
- (void)didFilterSelected:(NSArray *)arr withType:(ParameterType)pType wedo:(NSString *)type
{
    if (pType == ParameterTypeWeiDu2) {
        filterWedoArray1 = [[NSMutableArray alloc]initWithArray:arr];
        filterWedo1 = type;
         
        [self configWithFilter:filterWedoArray1 withKey:@"dict1"];
    }else if (pType == ParameterTypeWeiDu3){
        filterWedoArray2 = [[NSMutableArray alloc]initWithArray:arr];
        filterWedo2 = type;
       
        [self configWithFilter:filterWedoArray2 withKey:@"dict2"];
    }
}

/***********************************************************************
 * 方法名称：- (void)didSelectDict:(NSDictionary *)tDict pType:(ParameterType)pType
 * 功能描述： 代理方法选择了某个参数
 * 输入参数：
 * 输出参数：
 * 返 回 值：
 ***********************************************************************/
- (void)didSelectDict:(NSDictionary *)tDict pType:(ParameterType)pType
{
    switch (pType) {
        case ParameterTypeWeiDu1:
            [selectDict setObject:tDict forKey:@"dict0"];// 查询条件
            break;
        case ParameterTypeWeiDu2:
            [selectDict setObject:tDict forKey:@"dict1"];// 行标签
            filterWedoArray1 = [[NSMutableArray alloc]init];
            [self configWithFilter:filterWedoArray1 withKey:@"dict1"];
            break;
        case ParameterTypeWeiDu3:
            [selectDict setObject:tDict forKey:@"dict2"];// 列标签
            filterWedoArray2 = [[NSMutableArray alloc]init];
            [self configWithFilter:filterWedoArray2 withKey:@"dict2"];
            break;
        case ParameterTypeDuliang:
            [selectDict setObject:tDict forKey:@"dict3"];// 度量
            break;
        default:
            break;
    }
   
    [myTableView reloadData];
}




/***********************************************************************
 * 方法名称：clickSave
 * 功能描述： // 保存选择项
 * 输入参数：
 * 输出参数：
 * 返 回 值：
 ***********************************************************************/
- (void)clickSave
{
    if (![Common isBlankString:saveID]) {
    
        [self clickDoneWithName:saveName];
        
        return;
    }
    KLCPopupLayout layout = KLCPopupLayoutMake(KLCPopupHorizontalLayoutCenter, KLCPopupVerticalLayoutCenter);
    StoreConfigPopView *scpv = [[StoreConfigPopView alloc]initWithDelegate:self];
    KLCPopup *popup = [KLCPopup popupWithContentView:scpv
                                  showType:KLCPopupShowTypeSlideInFromTop
                               dismissType:KLCPopupDismissTypeSlideOutToBottom
                                  maskType:KLCPopupMaskTypeDimmed
                  dismissOnBackgroundTouch:YES
                     dismissOnContentTouch:NO];
    [popup showWithLayout:layout];
 
    
}

/***********************************************************************
 * 方法名称：- (void)clickDoneWithName:(NSString *)name
 * 功能描述： 确定代理事件
 * 输入参数：
 * 输出参数：
 * 返 回 值：
 ***********************************************************************/
- (void)clickDoneWithName:(NSString *)name
{
    NSDictionary *kpiDict = [selectDict objectForKey:@"dict3"];
    if (kpiDict == nil) {
        [[RGHudModular getRGHud]showAutoHudWithMessageDefault:@"您至少需要配置一个度量"];
        [self.view dismissPresentingPopup];
        return;
    }
    saveName = name;
    AFHTTPRequestOperationManager   *manager    = [AFHTTPRequestOperationManager manager];
//    manager.requestSerializer  = [AFJSONRequestSerializer serializer];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    
    //配置信息
    // 组合table字符串
    NSMutableDictionary *table = [NSMutableDictionary dictionaryWithCapacity:4];
    NSDictionary *kpiJson = [Common converKpiJson:kpiDict];
    [table setObject:@[kpiJson] forKey:@"kpiJson"];
    
    NSMutableDictionary *tableJson = [NSMutableDictionary dictionaryWithCapacity:2];
    
    // 组合横轴
    NSDictionary *rowsDict = [selectDict objectForKey:@"dict1"];
    if (rowsDict !=nil && rowsDict.count != 0) {
        NSDictionary *rowsJson = [Common converRowsJson:rowsDict];
        [tableJson setObject:@[rowsJson] forKey:@"rows"];
    }else{
        [tableJson setObject:@[] forKey:@"rows"];
    }
    
    // 组合纵轴
    NSDictionary *colsDict = [selectDict objectForKey:@"dict2"];
    if (colsDict !=nil && colsDict.count != 0) {
        NSDictionary *colsJson = [Common converColsJson:colsDict];
        [tableJson setObject:@[colsJson,@{@"type":@"kpiOther",@"id":@"kpi"}] forKey:@"cols"];
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
    NSDictionary *paramDict = [selectDict objectForKey:@"dict0"];
    if (paramDict !=nil && paramDict.count != 0) {
        NSDictionary *params = [Common converParamsJson:paramDict];
        [pageInfo setObject:@[params] forKey:@"params"];
    }else{
        [pageInfo setObject:@[] forKey:@"params"];
    }
    [pageInfo setObject:name forKey:@"subjectname"];
    [pageInfo setObject:self.selectTid forKey:@"tid"];
    [pageInfo setObject:self.selectTid forKey:@"subjectid"];
    
    NSMutableDictionary     *parameters =[NSMutableDictionary dictionaryWithCapacity:2];
    NSString *urlString = WEB_SERVICE_SAVEINFO([Common GetServiceHost]);
    if (![Common isBlankString:saveID]) {
        urlString = WEB_SERVICE_SAVEUPDATE([Common GetServiceHost]);
        [parameters setObject:saveID forKey:@"id"];
        [pageInfo setObject:saveID forKey:@"id"];
    }
    
    
    [parameters setObject:[Common shareInstence].token forKey:@"token"];
    [parameters setObject:name forKey:@"pageName"];
    [parameters setObject:[pageInfo JSONString] forKey:@"pageInfo"];
    
    
//    NSLog(@"---传入-%@",[pageInfo JSONString]);
    
    [manager POST:urlString parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        [[RGHudModular getRGHud] showAutoHudWithMessageDefault:@"保存成功"];
//        NSLog(@"保存返回值----- %@",responseObject);
        [self.view dismissPresentingPopup];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        // 判断token是否可用
        NSString *errStr = operation.responseString;

//        NSLog(@"----得到的errstr%@",errStr);
        if (![Common isBlankString:errStr]&& [errStr isEqualToString:@"\r\n{error:'用户未登录。'}"]) {
            [[RGHudModular getRGHud] showAutoHudWithMessageDefault:@"用户登录失效,请重新登录"];
            [Common shareInstence].isLogin = NO;
            [self.navigationController popToRootViewControllerAnimated:false];
            return ;
        }
        [self.myTableView.header endRefreshing];
        if (errStr.integerValue != 0) {
            saveID = [NSString stringWithFormat:@"%@",errStr];
            [[RGHudModular getRGHud] showAutoHudWithMessageDefault:@"保存成功"];

        }else{
            [[RGHudModular getRGHud] showAutoHudWithMessageDefault:@"网络错误"];
        }
        
    }];

}


/***********************************************************************
 * 方法名称：turnToTable
 * 功能描述： // 点击表格
 * 输入参数：
 * 输出参数：
 * 返 回 值：
 ***********************************************************************/
- (IBAction)turnToTable:(id)sender {
    NSDictionary *kpiDict = [selectDict objectForKey:@"dict3"];
    if (kpiDict == nil) {
        [[RGHudModular getRGHud] showAutoHudWithMessageDefault:@"您至少需要配置一个度量"];
        return;
    }
    DataShowTableViewController  *dstvc = [[DataShowTableViewController alloc]initWithNibName:@"DataShowTableViewController" bundle:nil];
    dstvc.kpiJson = [NSMutableDictionary dictionaryWithDictionary:[selectDict objectForKey:@"dict3"]];
 
    if ([selectDict objectForKey:@"dict0"] != nil) {
        dstvc.params  = [NSMutableDictionary dictionaryWithDictionary:[selectDict objectForKey:@"dict0"]];
    }
    if ([selectDict objectForKey:@"dict1"] != nil) {
        
        dstvc.tableRows  = [NSMutableDictionary dictionaryWithDictionary:[selectDict objectForKey:@"dict1"]];
      
    }
    if ([selectDict objectForKey:@"dict2"] != nil) {
        
        
        dstvc.tableCols  = [NSMutableDictionary dictionaryWithDictionary:[selectDict objectForKey:@"dict2"]];
        
    }

    
    [self.navigationController pushViewController:dstvc animated:true];
}

/***********************************************************************
 * 方法名称：configWithFilter
 * 功能描述： 配置多维筛选参数
 * 输入参数：
 * 输出参数：
 * 返 回 值：
 ***********************************************************************/
- (void)configWithFilter:(NSArray *)filterArr withKey:(NSString *)mkey
{
    NSMutableDictionary *dict1 = [NSMutableDictionary dictionaryWithDictionary:[selectDict objectForKey:mkey]];
    if (dict1 != nil) {
        [dict1 removeObjectForKey:@"endmt"];
        [dict1 removeObjectForKey:@"enddt"];
        [dict1 removeObjectForKey:@"startdt"];
        [dict1 removeObjectForKey:@"startmt"];
        [dict1 removeObjectForKey:@"vals"];
        [dict1 removeObjectForKey:@"valStrs"];
        [selectDict setObject:dict1 forKey:mkey];
    }
    
    if (filterArr.count != 0) {
        NSString *tmpKey1 = @"vals";
        NSString *tmpKey2 = @"valStrs";
        NSString *val1 = @"";
        NSString *val2 = @"";
//        day区间参数 startdt/enddt
//        month 区间参数 startmt/endmt
        for (int i=0;i<filterArr.count;i++) {
            id send = filterArr[i];
            
            if ([send isKindOfClass:[NSDictionary class]]) {
                if (i == 0) {
                    val1 = [NSString stringWithFormat:@"%@",[send objectForKey:@"id"]];
                    val2 = [NSString stringWithFormat:@"%@",[send objectForKey:@"name"]];
                }else{
                    val1 = [NSString stringWithFormat:@"%@,%@",val1,[send objectForKey:@"id"]];
                    val2 = [NSString stringWithFormat:@"%@,%@",val2,[send objectForKey:@"name"]];
                }
            }else{
                
                
                if (i == 0) {
                    if ([mkey isEqualToString:@"dict1"]) {
                        if ([filterWedo1 isEqualToString:@"day"]) {
                            tmpKey1 = @"startdt";
                        }else{
                            tmpKey1 = @"startmt";
                        }
                        
                    }else{
                        if ([filterWedo2 isEqualToString:@"day"]) {
                            tmpKey1 = @"startdt";
                        }else{
                            tmpKey1 = @"startmt";
                        }
                    }
                    val1 = [NSString stringWithFormat:@"%@",send];
                    
                }else{
                    if ([mkey isEqualToString:@"dict1"]) {
                        if ([filterWedo1 isEqualToString:@"day"]) {
                            tmpKey2 = @"enddt";
                        }else{
                            tmpKey2 = @"endmt";
                        }
                        
                    }else{
                        if ([filterWedo2 isEqualToString:@"day"]) {
                            tmpKey2 = @"enddt";
                        }else{
                            tmpKey2 = @"endmt";
                        }
                    }
                    val2 = [NSString stringWithFormat:@"%@",send];
                }
            }
        }
        
        
        [dict1 setObject:val1 forKey:tmpKey1];
        [dict1 setObject:val2 forKey:tmpKey2];
        [selectDict setObject:dict1 forKey:mkey];
    }

}

/***********************************************************************
 * 方法名称：clickShowGraph
 * 功能描述： // 点击图形
 * 输入参数：
 * 输出参数：
 * 返 回 值：
 ***********************************************************************/
- (IBAction)clickShowGraph:(id)sender {
    NSDictionary *kpiDict = [selectDict objectForKey:@"dict3"];
    if (kpiDict == nil) {
        [[RGHudModular getRGHud]showAutoHudWithMessageDefault:@"您至少需要配置一个度量"];
        return;
    }
    
    GraphShowViewController *gsvc = [[GraphShowViewController alloc]initWithNibName:@"GraphShowViewController" bundle:nil];
    gsvc.kpiJson = [NSMutableDictionary dictionaryWithDictionary:[selectDict objectForKey:@"dict3"]];
  
    if ([selectDict objectForKey:@"dict0"] != nil) {
        gsvc.params  = [NSMutableDictionary dictionaryWithDictionary:[selectDict objectForKey:@"dict0"]];
    }
    if ([selectDict objectForKey:@"dict1"] != nil) {
        
        gsvc.tableRows  = [NSMutableDictionary dictionaryWithDictionary:[selectDict objectForKey:@"dict1"]];
      
    }
    if ([selectDict objectForKey:@"dict2"] != nil) {
      
        gsvc.tableCols  = [NSMutableDictionary dictionaryWithDictionary:[selectDict objectForKey:@"dict2"]];
       
    }
    
    
    [self presentViewController:gsvc animated:true completion:nil];
 
}
 

@end
