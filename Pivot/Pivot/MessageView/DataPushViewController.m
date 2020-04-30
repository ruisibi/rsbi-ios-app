//
//  DataPushViewController.m
//  Pivot
//
//  Created by djh on 16/5/12.
//  Copyright © 2016年 bos. All rights reserved.
//

#import "DataPushViewController.h"
#import "Common.h"
#import "AFNetworking.h"
#import "MJRefresh.h"
#import "RGHudModular.h"
#import "AddDataPushViewController.h"
#import "UITableViewRowAction+JZExtension.h"

@interface DataPushViewController ()<UITableViewDataSource,UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *myTableView;
@property (nonatomic,strong) NSMutableArray *dataArray;// array
@end

@implementation DataPushViewController
@synthesize dataArray;
@synthesize myTableView;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 右上角按钮
    UIImage *imgRight = [UIImage imageNamed:@"pl_add"];
    UIButton *rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    rightBtn.frame = CGRectMake(0, 0, imgRight.size.width, imgRight.size.height);
    [rightBtn setBackgroundImage:imgRight forState:UIControlStateNormal];
    [rightBtn addTarget:self action:@selector(clickAdd) forControlEvents:UIControlEventTouchUpInside];
    
    [self.navigationItem setRightBarButtonItem:[[UIBarButtonItem alloc]initWithCustomView:rightBtn]];
    
    // Do any additional setup after loading the view from its nib.
    dataArray    = [[NSMutableArray alloc]init];
   
    self.myTableView.showsVerticalScrollIndicator = FALSE;
    self.myTableView.dataSource         = self;
    self.myTableView.delegate           = self;
    self.myTableView.backgroundColor    = [UIColor whiteColor];
    self.myTableView.separatorStyle     = UITableViewCellSeparatorStyleNone;
    
    self.navigationItem.title = @"推送配置信息";
    
    // 添加下拉加载页面
    __weak typeof(self) weakSelf        = self;
    
    self.myTableView.header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [weakSelf getData];
    }];
    
    
    [self.myTableView.header beginRefreshing];
    
}

-(void)reloadMyTable
{
    [self.myTableView.header beginRefreshing];
}

/***********************************************************************
 * 方法名称：- (void)clickAdd
 * 功能描述： 添加数据
 * 输入参数：
 * 输出参数：
 * 返 回 值：
 ***********************************************************************/
-(void)clickAdd
{
    AddDataPushViewController *addView = [[AddDataPushViewController alloc]initWithNibName:@"AddDataPushViewController" bundle:nil];
    [self.navigationController pushViewController:addView animated:YES];
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
    NSString *urlString = WEB_SERVICE_PUSHLIST([Common GetServiceHost]);
    
    [manager GET:urlString parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSArray *arr = responseObject;
        NSLog(@"推送列表%@",arr);
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
        
        cell.contentView.backgroundColor = MT_CELL_COLOR;
    }
    
    for (UIView *subView in cell.contentView.subviews) {
        [subView removeFromSuperview];
    }
    
    NSDictionary *data = [dataArray objectAtIndex:indexPath.row];
    
    
    UILabel *lblName = [[UILabel alloc]initWithFrame:CGRectMake(20, 0, SCREEN_WIDTH - 20, 50)];
    lblName.text = [data objectForKey:@"title"];
    lblName.font = [UIFont systemFontOfSize:15];
    NSString *state = [NSString stringWithFormat:@"%@",[data objectForKey:@"state"]];
    if (state.intValue == 1) {//禁用用
        lblName.textColor = [UIColor blackColor];
    }else{//启用
        lblName.textColor = [UIColor colorWithRed:150/255.0 green:150/255.0 blue:150/255.0 alpha:1];
        
    }
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


/*改变删除按钮的title*/

- (nullable NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    void(^rowActionHandler)(UITableViewRowAction *, NSIndexPath *) = ^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        NSLog(@"%@", action.title);
        if ([action.title isEqualToString:@"删除"]) {
            UIAlertView *alertShow = [[UIAlertView alloc]initWithTitle:@"提示" message:@"是否确认删除操作？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
            alertShow.tag = indexPath.row;
            [alertShow show];
        }else{
            
            [self startOrStopPushAtIndex:indexPath.row];
//            [tableView setEditing:false animated:true];
        }
        
    };
    
//    UIButton *buttonForImage = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
//    UITableViewRowAction *action1 = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault image:[buttonForImage imageForState:UIControlStateNormal] handler:rowActionHandler];
//    
    UITableViewRowAction *action2 = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:@"启用" handler:rowActionHandler];
    
    NSDictionary *data = [dataArray objectAtIndex:indexPath.row];
    if ([data objectForKey:@"state"] != nil) {
        NSString *state = [NSString stringWithFormat:@"%@",[data objectForKey:@"state"]];
        if (state.intValue == 1) {//启用
            action2.backgroundColor = [UIColor lightGrayColor];
            action2.title = @"禁用";
        }else{//禁用
            action2.backgroundColor = [UIColor greenColor];
            action2.title = @"启用";
        }
    }else{
        action2.enabled = YES;
    }
    UITableViewRowAction *action3 = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:@"删除" handler:rowActionHandler];
    
    return @[action3,action2];
}
 
- (void)startOrStopPushAtIndex:(NSInteger)index
{
    AFHTTPRequestOperationManager   *manager    = [AFHTTPRequestOperationManager manager];
    //        manager.requestSerializer = [AFJSONRequestSerializer serializer];
    //        manager.responseSerializer = [AFJSONResponseSerializer serializer];
    NSString *url = WEB_SERVICE_STOPPUSH([Common GetServiceHost]);
    NSDictionary *data = [dataArray objectAtIndex:index];
    NSString *state = [NSString stringWithFormat:@"%@",[data objectForKey:@"state"]];
    if ([state isEqualToString:@"0"]) {
        url = WEB_SERVICE_STARTPUSH([Common GetServiceHost]);
    }
    NSDictionary *aDict = [dataArray objectAtIndex:index];
    NSNumber *idStr = [aDict objectForKey:@"push_id"];
    assert(idStr != nil);
    NSDictionary     *parameters = @{@"token": [Common shareInstence].token
                                     ,@"id":idStr};
    
    
    [manager POST:url parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        [self.myTableView.header beginRefreshing];
        NSLog(@"修改返回 ----- %@",responseObject);
//        [[RGHudModular getRGHud] showAutoHudWithMessageDefault:@"修改成功"];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        // 判断token是否可用
        NSString *errStr = operation.responseString;
        if (![Common isBlankString:errStr]&& [errStr isEqualToString:@"\r\n{error:'用户未登录。'}"]) {
            [[RGHudModular getRGHud] showAutoHudWithMessageDefault:@"用户登录失效,请重新登录"];
            [Common shareInstence].isLogin = NO;
            [self.navigationController popToRootViewControllerAnimated:false];
            return ;
        }
        [self.myTableView.header beginRefreshing];
        
    }];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {//确定删除配置
        AFHTTPRequestOperationManager   *manager    = [AFHTTPRequestOperationManager manager];
        //        manager.requestSerializer = [AFJSONRequestSerializer serializer];
        //        manager.responseSerializer = [AFJSONResponseSerializer serializer];
        
        NSDictionary *aDict = [dataArray objectAtIndex:alertView.tag];
        NSNumber *idStr = [aDict objectForKey:@"push_id"];
        assert(idStr != nil);
        NSDictionary     *parameters = @{@"token": [Common shareInstence].token
                                         ,@"id":idStr};
        NSString *urlString = WEB_SERVICE_PUSHDEL([Common GetServiceHost]);
        
        [manager POST:urlString parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            [self.myTableView.header beginRefreshing];
            //            NSLog(@"删除返回 ----- %@",responseObject);
            [[RGHudModular getRGHud] showAutoHudWithMessageDefault:@"删除成功"];
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            
            // 判断token是否可用
            NSString *errStr = operation.responseString;
            if (![Common isBlankString:errStr]&& [errStr isEqualToString:@"\r\n{error:'用户未登录。'}"]) {
                [[RGHudModular getRGHud] showAutoHudWithMessageDefault:@"用户登录失效,请重新登录"];
                [Common shareInstence].isLogin = NO;
                [self.navigationController popToRootViewControllerAnimated:false];
                return ;
            }
            [self.myTableView.header beginRefreshing];
            
        }];
    }
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    [[RGHudModular getRGHud] showPopHudWithMessage:@"加载中..." inWindow:self.view];
    
    NSDictionary *aDict = [dataArray objectAtIndex:indexPath.row];
    
    AFHTTPRequestOperationManager   *manager    = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    
    NSNumber *idStr = [aDict objectForKey:@"push_id"];
    assert(idStr != nil);
    NSDictionary     *parameters = @{@"token": [Common shareInstence].token
                                     ,@"id":idStr};
    
    NSString *urlString = WEB_SERVICE_PUSHGET([Common GetServiceHost]);
    
    [manager GET:urlString parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *tDict = responseObject;
//        NSLog(@"详情返回 ----- %@",responseObject);
        [[RGHudModular getRGHud]hidePopHudInView:self.view];
        if (tDict != nil) {
            AddDataPushViewController *addView = [[AddDataPushViewController alloc]initWithNibName:@"AddDataPushViewController" bundle:nil];
            NSMutableDictionary *ttDict = [NSMutableDictionary dictionaryWithDictionary:tDict];
            [ttDict setObject:idStr forKey:@"id"];
            [ttDict setObject:[aDict objectForKey:@"title"] forKey:@"title"];
            [addView reloadViewByStore:ttDict];
            [self.navigationController pushViewController:addView animated:YES];
        }else{
            [[RGHudModular getRGHud] showAutoHudWithMessageDefault:@"配置错误"];
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
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
