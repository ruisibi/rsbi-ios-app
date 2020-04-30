/*********************************************************************
 * 版权所有   magic_Zzz
 *
 * 文件名称： ParameterListViewController
 * 内容摘要： // 维度或者度量选择
 * 其它说明： 实现文件
 * 作 成 者： ZGD
 * 完成日期： 2016年03月22日
 * 修改记录1：
 * 修改日期：
 * 修 改 人：
 * 修改内容：
 * 修改记录2：
 **********************************************************************/

#import "ParameterListViewController.h"
#import "Common.h"
#import "AFNetworking.h"
#import "MJRefresh.h"
#import "RGHudModular.h"

@interface ParameterListViewController ()<UITableViewDataSource,UITableViewDelegate>
{
    NSInteger currentIndex;// 当前选中path
    UIBarButtonItem *nextBtn; // 完成按钮
    NSMutableDictionary *curDict;//当前选中的字典
}
@property (weak, nonatomic) IBOutlet UITableView *myTableView;
@property (nonatomic,strong) NSMutableArray *dataArray;// 度量array
@end

@implementation ParameterListViewController
@synthesize dataArray;

- (void)viewDidLoad {
    [super viewDidLoad];
    currentIndex = -1;
    dataArray    = [[NSMutableArray alloc]init];
 
    self.myTableView.showsVerticalScrollIndicator = FALSE;
    self.myTableView.dataSource         = self;
    self.myTableView.delegate           = self;
    self.myTableView.backgroundColor    = [UIColor whiteColor];
    self.myTableView.separatorStyle     = UITableViewCellSeparatorStyleNone;
    self.navigationItem.title = @"维度选择";
    if (self.currentType == ParameterTypeDuliang) {
        self.navigationItem.title = @"度量选择";
    }
    
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
    nextBtn.enabled = false;
    [nextBtn setTitleTextAttributes:dict forState:UIControlStateNormal];
    self.navigationItem.rightBarButtonItem = nextBtn;
    curDict = [NSMutableDictionary dictionaryWithCapacity:1];
    if (self.defDict != nil) {
        nextBtn.enabled = true;
        curDict = [NSMutableDictionary dictionaryWithDictionary:self.defDict];
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
    
    NSMutableDictionary     *parameters = [NSMutableDictionary dictionaryWithCapacity:2];
    [parameters setObject:[Common shareInstence].token forKey:@"token"];
    [parameters setObject:_selectTid forKey:@"tableid"];
    if (self.currentType == ParameterTypeWeiDuPush) {
        [parameters setObject:@"y" forKey:@"filterDateDim"];
    }
    
    NSString *urlString = WEB_SERVICE_CUBEDIM([Common GetServiceHost]);
    
    if (self.currentType == ParameterTypeDuliang) {
        urlString = WEB_SERVICE_CUBEKPI([Common GetServiceHost]);
    }
    
    [manager GET:urlString parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        
        NSArray *arr = responseObject;
     
        currentIndex = -1;
 
        dataArray = [[NSMutableArray alloc]initWithArray:arr];
        [self.myTableView.header endRefreshing];
        [self.myTableView reloadData];
        
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
    lblName.text = [data objectForKey:@"text"];
    lblName.font = [UIFont systemFontOfSize:13];
    UIView  *lineView = [[UIView alloc]initWithFrame:CGRectMake(0, 39, SCREEN_WIDTH, 1)];
    lineView.backgroundColor = MT_LINE_COLOR;
    [cell.contentView addSubview:lblName];
    [cell.contentView addSubview:lineView];
    UIImageView *selectImg = [[UIImageView alloc]initWithFrame:CGRectMake(10, 7.5, 25, 25)];
    [cell.contentView addSubview:selectImg];

    
    NSNumber *tId = [data objectForKey:@"col_id"];
    NSNumber *tId2 = [curDict objectForKey:@"col_id"];
    if (tId2 != nil && tId.intValue == tId2.intValue)
    {
        selectImg.image = [UIImage imageNamed:@"cellSelect"];
    }
    else
    {
        selectImg.image = [UIImage imageNamed:@"cellnormal"];
    }
    
    if (self.tmpDict != nil) {
        NSNumber *tmpId = [self.tmpDict objectForKey:@"col_id"];
        NSString *groupType = [self.tmpDict objectForKey:@"grouptype"];
        NSString *groupType2 = [data objectForKey:@"grouptype"];
        BOOL ttttFlag = YES;
        if (tmpId != nil && tmpId.intValue == tId.intValue) {
            ttttFlag = false;
        }
        
        if (groupType != nil && ![Common isBlankString:groupType] && groupType2 != nil && ![Common isBlankString:groupType2]) {
            NSString *ttgroup = [NSString stringWithFormat:@"%@",groupType];
            NSString *ttgroup2 = [NSString stringWithFormat:@"%@",groupType2];
            if ([ttgroup isEqualToString:ttgroup2]) {
                ttttFlag = false;
            }
        }
        
        cell.userInteractionEnabled = ttttFlag;
        if (!ttttFlag) {
            lblName.textColor = [UIColor lightGrayColor];
        }else{
            lblName.textColor = [UIColor blackColor];
        }
    }
    
    return cell;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    currentIndex = indexPath.row;
    curDict = [dataArray objectAtIndex:currentIndex];
    if (nextBtn.enabled == false) {
        nextBtn.enabled = true;
    }
//    NSLog(@"%@",[dataArray objectAtIndex:currentIndex]);
    [tableView reloadData];
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

    if (self.delegate != nil && curDict != nil) {
        [self.delegate didSelectDict:curDict pType:self.currentType];
        [self.navigationController popViewControllerAnimated:true];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

 
@end
