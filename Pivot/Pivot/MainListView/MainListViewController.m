/*********************************************************************
 * 版权所有   magic_Zzz
 *
 * 文件名称： MainListViewController
 * 内容摘要： 主列表页面
 * 其它说明： 实现文件
 * 作 成 者： ZGD
 * 完成日期： 2016年03月22日
 * 修改记录1：
 * 修改日期：
 * 修 改 人：
 * 修改内容：
 * 修改记录2：
 **********************************************************************/


#import "MainListViewController.h"
#import "MainListTableViewCell.h"
#import "Common.h"
#import "AFNetworking.h"
#import "MJRefresh.h"
#import "RGHudModular.h"
#import "SelfCenterViewController.h"
#import "PivotSelectViewController.h"
#import "HistoryStoreViewController.h"
#import "ReportCataViewController.h"
#import "UserStoreView.h"
#import "UserData.h"
#import "DataPushViewController.h"

@interface MainListViewController ()<UITableViewDataSource,UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *myTableView;
@property (nonatomic,strong) UserStoreView  *usView;//用户收藏view
@property (nonatomic,strong) NSMutableArray *dataArray;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentBtn;
@property (nonatomic,strong) UIButton       *btnConnect;// 重新连接按钮
@end

@implementation MainListViewController
@synthesize myTableView;
@synthesize dataArray;
@synthesize btnConnect;
@synthesize usView;

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"菜单";
    dataArray = [[NSMutableArray alloc]init];
    self.navigationController.navigationBarHidden = false;
     [self.navigationItem setHidesBackButton:YES];
    self.myTableView.showsVerticalScrollIndicator = FALSE;
    self.myTableView.dataSource         = self;
    self.myTableView.delegate           = self;
    self.myTableView.backgroundColor    = [UIColor whiteColor];
    self.myTableView.separatorStyle     = UITableViewCellSeparatorStyleNone;
    
    btnConnect = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 43)];
    [btnConnect setTitle:@"网络错误，点击重新加载" forState:UIControlStateNormal];
    [btnConnect setTitleColor:[UIColor colorWithRed:79/255.0 green:79/255.0 blue:79/255.0 alpha:1] forState:UIControlStateNormal];
    [btnConnect setBackgroundColor:[UIColor colorWithRed:253/255.0 green:236/255.0 blue:170/255.0 alpha:1]];
    [btnConnect addTarget:self action:@selector(clickToHome) forControlEvents:UIControlEventTouchUpInside];
    btnConnect.hidden = YES;
    btnConnect.titleLabel.font = [UIFont systemFontOfSize:15];
    [self.view addSubview:btnConnect];
    
    
    usView = [[UserStoreView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    usView.hidden = YES;
    usView.parent = self;
    [self.view insertSubview:usView belowSubview:self.segmentBtn];
    // 添加下拉加载页面
    __weak typeof(self) weakSelf        = self;
    
    self.myTableView.header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [weakSelf getData];
    }];
    
    
    [self.myTableView.header beginRefreshing];
    
    
    // 右上角按钮
    UIImage *imgRight = [UIImage imageNamed:@"btn_user"];
    UIButton *rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    rightBtn.frame = CGRectMake(0, 0, imgRight.size.width, imgRight.size.height);
    [rightBtn setBackgroundImage:imgRight forState:UIControlStateNormal];
    [rightBtn addTarget:self action:@selector(clickInfo) forControlEvents:UIControlEventTouchUpInside];

    [self.navigationItem setRightBarButtonItem:[[UIBarButtonItem alloc]initWithCustomView:rightBtn]];
    
    [NSThread detachNewThreadSelector:@selector(beginCheck) toTarget:self withObject:nil];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if ([Common shareInstence].isLogin == NO) {
        if (self.delegate) {
            [self.delegate disMisTabView];
        }
    }else{
        [usView beginRefreshTable];
    }
   
}
- (void)beginCheck
{
    while (true) {
        [NSThread sleepForTimeInterval:5];
        
        if (![self checkNet] ) {
            if (btnConnect.hidden == YES) {
                [self showConnectView:YES];
            }
        }
        
        if ([UserData getUserData].userId == nil || [[UserData getUserData].userId isEqualToString:@""]) {
            break;
        }
    }
    
}


-(BOOL)checkNet
{
    
    NSString *theHost=[NSString stringWithFormat:@"%@",[Common GetServiceHost]];
    
    NSURL *url1 = [NSURL URLWithString:theHost];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:url1 cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:5.0];
    NSHTTPURLResponse *response;
    [NSURLConnection sendSynchronousRequest:request returningResponse: &response error: nil];
    if (response == nil) {
        
        return NO;
    }
    else{
        
        return YES;
    }
}

/***********************************************************************
 * 方法名称： loadDataArray
 * 功能描述： // 加载数据
 * 输入参数：
 * 输出参数：
 * 返 回 值：
 ***********************************************************************/
-(void)showConnectView:(BOOL)flag
{
    btnConnect.hidden = !flag;
    if (flag) {
        self.myTableView.frame = CGRectMake(0, 43, SCREEN_WIDTH, SCREEN_HEIGHT - 43);
        usView.frame = CGRectMake(0, 43, SCREEN_WIDTH, SCREEN_HEIGHT - 43);
    }else{
        self.myTableView.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
        usView.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
    }
}

-(void)clickToHome
{
    if (self.delegate) {
        NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
        [userDefault removeObjectForKey:@"userPass"];
        [[UserData getUserData] signOutUser];
        [self.delegate disMisTabView];
    }
}

/***********************************************************************
 * 方法名称： loadDataArray
 * 功能描述： // 加载数据
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
    
    [manager GET:WEB_SERVICE_MAINLIST([Common GetServiceHost]) parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [self showConnectView:NO];
        [myTableView.header endRefreshing];
        if ([responseObject isKindOfClass:[NSArray class]]) {
            NSArray *arr = responseObject;
            dataArray = [[NSMutableArray alloc]initWithArray:arr];
            [myTableView reloadData];
        }
  
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        // 判断token是否可用
        NSString *errStr = operation.responseString;
        if (![Common isBlankString:errStr]&& [errStr isEqualToString:@"\r\n{error:'用户未登录。'}"]) {
            [[RGHudModular getRGHud] showAutoHudWithMessageDefault:@"用户登录失效,请重新登录"];
            [Common shareInstence].isLogin = NO;
            if (self.delegate) {
                [self.delegate disMisTabView];
            }
            return ;
        }
        [self showConnectView:YES];
        [myTableView.header endRefreshing];
        [[RGHudModular getRGHud] showAutoHudWithMessageDefault:@"网络错误"];
    }];
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
    return dataArray.count;
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
    return 80;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString         *CellIdentifier = @"MainListTableViewCell";
    MainListTableViewCell  *cell            = (MainListTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil)
    {
        cell = [[MainListTableViewCell alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 80)];
    }
    [cell setCellDict:[dataArray objectAtIndex:indexPath.section]];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) { // 数据透视
        PivotSelectViewController *psvc =[[PivotSelectViewController alloc]initWithNibName:@"PivotSelectViewController" bundle:nil];
        psvc.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:psvc animated:true];
    }else if (indexPath.section == 1){// 已保存的配置
        HistoryStoreViewController *hsvc = [[HistoryStoreViewController alloc]initWithNibName:@"HistoryStoreViewController" bundle:nil];
        hsvc.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:hsvc animated:true];
    }else if (indexPath.section == 2){// 手机报表
        ReportCataViewController *rcvc = [[ReportCataViewController alloc]initWithNibName:@"ReportCataViewController" bundle:nil];
        rcvc.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:rcvc animated:YES];
    }else if (indexPath.section == 3){// 信息推送
        DataPushViewController *rcvc = [[DataPushViewController alloc]initWithNibName:@"DataPushViewController" bundle:nil];
        rcvc.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:rcvc animated:YES];
    }
}

/***********************************************************************
 * 方法名称： clickInfo
 * 功能描述： 跳转个人信息
 * 输入参数：
 * 输出参数：
 * 返 回 值：
 ***********************************************************************/
- (void)clickInfo
{
    SelfCenterViewController *scvc = [[SelfCenterViewController alloc]initWithNibName:@"SelfCenterViewController" bundle:nil];
    scvc.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:scvc animated:true];
    
}
- (IBAction)clickChangeView:(id)sender {
    UISegmentedControl *seg = sender;
    if (seg.selectedSegmentIndex == 0) {
        self.myTableView.hidden = NO;
        usView.hidden = YES;
    }else{
        self.myTableView.hidden = YES;
        usView.hidden = NO;
        [usView beginRefreshTable];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
