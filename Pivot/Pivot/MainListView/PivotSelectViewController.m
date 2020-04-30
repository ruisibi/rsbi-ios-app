/*********************************************************************
 * 版权所有   magic_Zzz
 *
 * 文件名称： PivotSelectViewController
 * 内容摘要： 数据透视 --- 数据选择
 * 其它说明： 实现文件
 * 作 成 者： ZGD
 * 完成日期： 2016年03月08日
 * 修改记录1：
 * 修改日期：
 * 修 改 人：
 * 修改内容：
 * 修改记录2：
 **********************************************************************/


#import "PivotSelectViewController.h"
#import "Common.h"
#import "AFNetworking.h"
#import "MJRefresh.h"
#import "RGHudModular.h"
#import "PivotFirstData.h"
#import "PivotDataSetViewController.h"
#import "JSONKit.h"

@interface PivotSelectViewController ()<UITableViewDataSource,UITableViewDelegate>
{
    UIBarButtonItem *nextBtn;// 下一步按扭
    NSString *selectTid;// 当前选中的表id
    NSInteger ccIndex;//特殊index
}
@property (weak, nonatomic) IBOutlet UITableView *myTableView;
@property (nonatomic,strong) NSMutableArray *dataArray;
@property (nonatomic)  BOOL isHistory;// 是否历史进入
@property (nonatomic,strong) NSDictionary *historyDict;//历史数据
@end

@implementation PivotSelectViewController
@synthesize dataArray;
@synthesize myTableView;
@synthesize isHistory;
@synthesize historyDict;


- (void)viewDidLoad {
    [super viewDidLoad];
    ccIndex = -1;
    dataArray = [[NSMutableArray alloc]init];
    
    // 添加下一步按钮
    UIBarButtonItem *backBtn = self.navigationItem.backBarButtonItem;
    backBtn.tintColor = [UIColor whiteColor];
    [self.navigationItem setBackBarButtonItem:backBtn];
    
    NSMutableDictionary *dict =[NSMutableDictionary dictionaryWithCapacity:1];
    [dict setObject:[UIFont systemFontOfSize:15] forKey:NSFontAttributeName];
    
    
    nextBtn = [[UIBarButtonItem alloc] initWithTitle:@"下一步" style:UIBarButtonItemStylePlain target:self action:@selector(clickNext)];
    nextBtn.enabled = false;
    [nextBtn setTitleTextAttributes:dict forState:UIControlStateNormal];
    self.navigationItem.rightBarButtonItem = nextBtn;
   
    
    //设置titleview
    [self setUPTitleView];
    
//    UIImage *backButtonImage = [UIImage imageNamed:@"btn_Back"] ;
//    [[UIBarButtonItem appearance] setBackButtonBackgroundImage:backButtonImage  forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    
  
    
    self.myTableView.showsVerticalScrollIndicator = FALSE;
    self.myTableView.dataSource         = self;
    self.myTableView.delegate           = self;
    self.myTableView.backgroundColor    = [UIColor whiteColor];
    self.myTableView.separatorStyle     = UITableViewCellSeparatorStyleNone;
    
    // 添加下拉加载页面
    __weak typeof(self) weakSelf        = self;
    
    self.myTableView.header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [weakSelf getData];
    }];
    
    
    [self.myTableView.header beginRefreshing];
    
    
   
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
    UIView *tView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 260, 49)];
    UILabel *lblTitle = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 260, 25)];
    lblTitle.textAlignment = NSTextAlignmentCenter;
    lblTitle.text = @"数据透视";
    lblTitle.font =[UIFont boldSystemFontOfSize:17];
    lblTitle.textColor = [UIColor whiteColor];
    
    UILabel *lblTitle2 = [[UILabel alloc]initWithFrame:CGRectMake(0, 24,260, 20)];
    lblTitle2.text = @"数据选择";
    lblTitle2.font = [UIFont systemFontOfSize:13];
    lblTitle2.textAlignment = NSTextAlignmentCenter;
    lblTitle2.textColor = [UIColor whiteColor];
    
  
    
    
    CGRect leftViewbounds = self.navigationItem.leftBarButtonItem.customView.bounds;
    
    CGRect rightViewbounds = self.navigationItem.rightBarButtonItem.customView.bounds;
    rightViewbounds.size.width = 80;
    
    CGRect frame;
    
    CGFloat maxWidth = leftViewbounds.size.width > rightViewbounds.size.width ? leftViewbounds.size.width : rightViewbounds.size.width;
    
    maxWidth += 15;//leftview 左右都有间隙，左边是5像素，右边是8像素，加2个像素的阀值 5 ＋ 8 ＋ 2
    
    frame = lblTitle.frame;
    
    frame.size.width = 260 - maxWidth * 2;
    
    lblTitle.frame = frame;
    
    frame = lblTitle2.frame;
    
    frame.size.width = 260 - maxWidth * 2;
    
    lblTitle2.frame = frame;
    
    frame = tView.frame;
    
    frame.size.width = 260 - maxWidth * 2;
    
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
    AFHTTPRequestOperationManager   *manager    = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    
    NSDictionary     *parameters = @{@"token": [Common shareInstence].token};
    
    [manager GET:WEB_SERVICE_SUBLIST([Common GetServiceHost]) parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSArray *arr = responseObject;
//        NSLog(@"返回参数：%@",arr);
        dataArray = [[NSMutableArray alloc]initWithArray:arr];
        
        selectTid    = @"";
        if (isHistory && historyDict != nil) {
            [[RGHudModular getRGHud] showPopHudWithMessage:@"加载中..." inWindow:self.view];
            selectTid = [NSString stringWithFormat:@"%@",[historyDict objectForKey:@"tid"]];
        }
        
        [myTableView.header endRefreshing];
        [myTableView reloadData];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            //刷新完成
            if (isHistory) {
                [self clickNext];
            }
            
        });
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        // 判断token是否可用
        NSString *errStr = operation.responseString;
        if (![Common isBlankString:errStr]&& [errStr isEqualToString:@"\r\n{error:'用户未登录。'}"]) {
            [[RGHudModular getRGHud] showAutoHudWithMessageDefault:@"用户登录失效,请重新登录"];
            [Common shareInstence].isLogin = NO;
            [self.navigationController popToRootViewControllerAnimated:false];
            return ;
        }
//        NSLog(@"error - %@----%@",error,operation.responseString);
        [myTableView.header endRefreshing];
        [[RGHudModular getRGHud] showAutoHudWithMessageDefault:@"网络错误"];
    }];
}

/***********************************************************************
 * 方法名称： reloadViewByStore:(NSDictionary *)aDict
 * 功能描述： 从保存的配置进入
 * 输入参数：
 * 输出参数：
 * 返 回 值：
 ***********************************************************************/
-(void)reloadViewByStore:(NSDictionary *)aDict
{
    isHistory = YES;// 历史进入
    assert(aDict != nil);
    historyDict = [NSDictionary dictionaryWithDictionary:aDict];
    
}


- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
   
    UILabel *lblTitle = [[UILabel alloc]initWithFrame:CGRectMake(15, 0, SCREEN_WIDTH - 30, 30)];
    lblTitle.font = [UIFont systemFontOfSize:16];
    NSDictionary *data = [dataArray objectAtIndex:section];
    lblTitle.text = [data objectForKey:@"text"];
    lblTitle.textColor = [UIColor colorWithRed:43/255.0 green:169/255.0 blue:243/255.0 alpha:1];
//    lblTitle.backgroundColor = [UIColor colorWithRed:249/255.0 green:249/255.0 blue:249/255.0 alpha:1];
    UIView *tmpView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 30)];
    tmpView.backgroundColor = [UIColor colorWithRed:249/255.0 green:249/255.0 blue:249/255.0 alpha:1];
    [tmpView addSubview:lblTitle];
//    UIView  *lineView = [[UIView alloc]initWithFrame:CGRectMake(0, 19, SCREEN_WIDTH, 1)];
//    lineView.backgroundColor = MT_LINE_COLOR;
//    [tmpView addSubview:lineView];
    if (section == 0) {
        UIView  *lineView2 = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 1)];
        lineView2.backgroundColor = MT_LINE_COLOR;
        [tmpView addSubview:lineView2];
    }
    return tmpView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 30;
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return dataArray.count;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSDictionary *data = [dataArray objectAtIndex:section];
    NSArray *tmpArr = [data objectForKey:@"children"];
    return tmpArr.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 40;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString         *CellIdentifier = @"psCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone; //选中cell时无色
        
        cell.contentView.backgroundColor = MT_CELL_COLOR;
    }
    NSDictionary *data = [dataArray objectAtIndex:indexPath.section];
    NSArray *tmpArr = [data objectForKey:@"children"];
    if (tmpArr.count == 0) {
        return cell;
    }
    for (UIView *subView in cell.contentView.subviews) {
        [subView removeFromSuperview];
    }
    NSDictionary *dataDict = tmpArr[indexPath.row];
    
    UILabel *lblName = [[UILabel alloc]initWithFrame:CGRectMake(40, 0, SCREEN_WIDTH - 40, 40)];
    lblName.text = [dataDict objectForKey:@"text"];
    lblName.font = [UIFont systemFontOfSize:15];
    UIView  *lineView = [[UIView alloc]initWithFrame:CGRectMake(0, 39, SCREEN_WIDTH, 1)];
    lineView.backgroundColor = MT_LINE_COLOR;
    [cell.contentView addSubview:lblName];
    [cell.contentView addSubview:lineView];
    UIImageView *selectImg = [[UIImageView alloc]initWithFrame:CGRectMake(10, 7.5, 25, 25)];
    [cell.contentView addSubview:selectImg];
    NSString *ttid = [NSString stringWithFormat:@"%@",[dataDict objectForKey:@"tid"]];
    if (selectTid != nil && [selectTid isEqualToString:ttid])
    {
        ccIndex = indexPath.row;
        selectImg.image = [UIImage imageNamed:@"cellSelect"];
        if (nextBtn.enabled == false) {
            nextBtn.enabled = true;
        }
    }
    else
    {
        selectImg.image = [UIImage imageNamed:@"cellnormal"];
    }
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *data = [dataArray objectAtIndex:indexPath.section];
    NSArray *tmpArr = [data objectForKey:@"children"];
    
    if (tmpArr.count == 0) {
        return;
    }
    
    
    NSDictionary *dataDict = tmpArr[indexPath.row];
    selectTid = [NSString stringWithFormat:@"%@",[dataDict objectForKey:@"tid"]];
    
    [myTableView reloadData];
}

/***********************************************************************
 * 方法名称： clickNext
 * 功能描述： 下一步按扭事件
 * 输入参数：
 * 输出参数：
 * 返 回 值：
 ***********************************************************************/
- (void)clickNext
{
    if (selectTid != nil  && ccIndex != -1) {
        if (isHistory) {// 是否历史判断
            [[RGHudModular getRGHud]hidePopHudInView:self.view];
            isHistory = false;
        }
        PivotDataSetViewController *pdsvc = [[PivotDataSetViewController alloc]initWithNibName:@"PivotDataSetViewController" bundle:nil];
        pdsvc.selectTid = selectTid;
        if (historyDict != nil) {
            pdsvc.historyDict = [NSDictionary dictionaryWithDictionary:historyDict];
        }
        [self.navigationController pushViewController:pdsvc animated:true];
        
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

 

@end
