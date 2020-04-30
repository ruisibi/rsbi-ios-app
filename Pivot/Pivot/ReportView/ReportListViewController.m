/*********************************************************************
 * 版权所有   magic_Zzz
 *
 * 文件名称： ReportListViewController
 * 内容摘要： // 报表目录列表
 * 其它说明： 实现文件
 * 作 成 者： ZGD
 * 完成日期： 2016年03月22日
 * 修改记录1：
 * 修改日期：
 * 修 改 人：
 * 修改内容：
 * 修改记录2：
 **********************************************************************/

#import "ReportListViewController.h"
#import "Common.h"
#import "AFNetworking.h"
#import "MJRefresh.h"
#import "RGHudModular.h"
#import "RxWebViewController.h"

@interface ReportListViewController ()<UITableViewDataSource,UITableViewDelegate,UIAlertViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *myTableView;
@property (nonatomic,strong) NSMutableArray *dataArray;// array
@end

@implementation ReportListViewController
@synthesize dataArray;
@synthesize myTableView;


- (void)viewDidLoad {
    [super viewDidLoad];

    dataArray    = [[NSMutableArray alloc]init];
    
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
    
    
    
    
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.myTableView.header beginRefreshing];
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
                                     ,@"cataId":self.cataId};
    NSString *urlString = WEB_SERVICE_REPORTLIST([Common GetServiceHost]);
    
    [manager GET:urlString parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSArray *arr = responseObject;
//        NSLog(@"得到的数据：%@",arr);
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
    return 50;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString         *CellIdentifier = @"plCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone; //选中cell时无色
        cell.accessoryType  = UITableViewCellAccessoryDisclosureIndicator;
        cell.contentView.backgroundColor = MT_CELL_COLOR;
    }
    
    for (UIView *subView in cell.contentView.subviews) {
        [subView removeFromSuperview];
    }
    
    NSDictionary *data = [dataArray objectAtIndex:indexPath.row];
    
    
    UILabel *lblName = [[UILabel alloc]initWithFrame:CGRectMake(20, 0, SCREEN_WIDTH - 20, 50)];
    lblName.text = [data objectForKey:@"title"];
    lblName.font = [UIFont systemFontOfSize:15];
    UIView  *lineView = [[UIView alloc]initWithFrame:CGRectMake(0, 49, SCREEN_WIDTH, 1)];
    lineView.backgroundColor = MT_LINE_COLOR;
    [cell.contentView addSubview:lblName];
    [cell.contentView addSubview:lineView];
    
    
    return cell;
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *data = [dataArray objectAtIndex:indexPath.row];
    NSString *urlStr = [data objectForKey:@"url"];
//    NSLog(@"url %@",urlStr);
   
    if ([Common isBlankString:urlStr]) {
        [[RGHudModular getRGHud] showAutoHudWithMessageDefault:@"数据错误"];
        return ;
    }
   

    RxWebViewController* webViewController = [[RxWebViewController alloc] initWithUrl:[NSURL URLWithString:urlStr]];
    webViewController.title = [data objectForKey:@"title"];
    webViewController.rid = [NSString stringWithFormat:@"%@",[data objectForKey:@"rid"]];
    webViewController.iscollect =[NSString stringWithFormat:@"%@",[data objectForKey:@"iscollect"]];
    [self.navigationController pushViewController:webViewController animated:YES];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
