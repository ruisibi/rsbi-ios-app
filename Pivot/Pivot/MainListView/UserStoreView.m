/*********************************************************************
 * 版权所有   magic_Zzz
 *
 * 文件名称： UserStoreView
 * 内容摘要： 用户收藏列表
 * 其它说明： 实现文件
 * 作 成 者： ZGD
 * 完成日期： 2016年03月22日
 * 修改记录1：
 * 修改日期：
 * 修 改 人：
 * 修改内容：
 * 修改记录2：
 **********************************************************************/

#import "UserStoreView.h"
#import "Common.h"
#import "AFNetworking.h"
#import "MJRefresh.h"
#import "RGHudModular.h"
#import "RxWebViewController.h"

@interface UserStoreView()<UITableViewDataSource,UITableViewDelegate,UIAlertViewDelegate>
@property (strong, nonatomic)  UITableView *myTableView;
@property (nonatomic,strong) NSMutableArray *dataArray;// array
@end
@implementation UserStoreView
@synthesize dataArray;
@synthesize myTableView;


-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
         dataArray    = [[NSMutableArray alloc]init];
        myTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
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
        
        [self addSubview:self.myTableView];
    }
    
    
    return self;
}

/***********************************************************************
 * 方法名称：- (void)beginRefreshTable
 * 功能描述： 刷新数据
 * 输入参数：
 * 输出参数：
 * 返 回 值：
 ***********************************************************************/
-(void)beginRefreshTable
{

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
                                     };
    NSString *urlString = WEB_SERVICE_COLLECTLIST([Common GetServiceHost]);
    
    [manager GET:urlString parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
//        NSLog(@"收藏：%@",responseObject);
        
        NSArray *arr = responseObject;
        
        dataArray = [[NSMutableArray alloc]initWithArray:arr];
        
        [self.myTableView.header endRefreshing];
        [self.myTableView reloadData];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        // 判断token是否可用
        NSString *errStr = operation.responseString;
        if (![Common isBlankString:errStr]&& [errStr isEqualToString:@"\r\n{error:'用户未登录。'}"]) {
            [[RGHudModular getRGHud] showAutoHudWithMessageDefault:@"用户登录失效,请重新登录"];
            [Common shareInstence].isLogin = NO;
            [self.parent.navigationController popToRootViewControllerAnimated:false];
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
    
    //    UIButton *btnDel = [UIButton buttonWithType:UIButtonTypeCustom];
    //    btnDel.frame = CGRectMake(SCREEN_WIDTH - 18 - 40, 0, 40, 40);
    //    [btnDel setImage:[UIImage imageNamed:@"btn_storeDel"] forState:UIControlStateNormal];
    //    btnDel.tag = indexPath.row;
    //    [btnDel addTarget:self action:@selector(clickShowAlet:) forControlEvents:UIControlEventTouchUpInside];
    //
    //    [cell.contentView addSubview:btnDel];
    
    return cell;
    
}

-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete;
}

/*改变删除按钮的title*/
-(NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return @"删除";
}

/*删除用到的函数*/
-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        /*此处处理自己的代码，如删除数据*/
        UIAlertView *alertShow = [[UIAlertView alloc]initWithTitle:@"提示" message:@"是否确认删除操作？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        alertShow.tag = indexPath.row;
        [alertShow show];
        /*删除tableView中的一行*/
        //        [tableView deleteRowsAtIndexPaths:[NSMutableArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {//确定删除配置
        AFHTTPRequestOperationManager   *manager    = [AFHTTPRequestOperationManager manager];
        //        manager.requestSerializer = [AFJSONRequestSerializer serializer];
        //        manager.responseSerializer = [AFJSONResponseSerializer serializer];
        
        NSDictionary *aDict = [dataArray objectAtIndex:alertView.tag];
        NSNumber *idStr = [aDict objectForKey:@"rid"];
        assert(idStr != nil);
        NSDictionary     *parameters = @{@"token": [Common shareInstence].token
                                         ,@"rid":idStr};
        NSString *urlString = WEB_SERVICE_COLLECTDEL([Common GetServiceHost]);
        
        [manager POST:urlString parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            [self.myTableView.header beginRefreshing];
//            NSLog(@"删除返回 ----- %@",responseObject);
//            [[RGHudModular getRGHud] showAutoHudWithMessageDefault:@"删除成功"];
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            
            // 判断token是否可用
            NSString *errStr = operation.responseString;
            if (![Common isBlankString:errStr]&& [errStr isEqualToString:@"\r\n{error:'用户未登录。'}"]) {
                [[RGHudModular getRGHud] showAutoHudWithMessageDefault:@"用户登录失效,请重新登录"];
                [Common shareInstence].isLogin = NO;
                [self.parent.navigationController popToRootViewControllerAnimated:false];
                return ;
            }
            [self.myTableView.header beginRefreshing];
            //            [[RGHudModular getRGHud] showAutoHudWithMessageDefault:@"网络错误"];
        }];
    }
    
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
    webViewController.iscollect =@"1";
    webViewController.rid = [NSString stringWithFormat:@"%@",[data objectForKey:@"rid"]];
    [self.parent.navigationController pushViewController:webViewController animated:YES];

}



@end
