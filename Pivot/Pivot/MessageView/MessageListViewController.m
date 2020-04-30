//
//  MessageListViewController.m
//  Pivot
//
//  Created by djh on 16/5/24.
//  Copyright © 2016年 bos. All rights reserved.
//

#import "MessageListViewController.h"
#import "Common.h"
#import "AFNetworking.h"
#import "MJRefresh.h"
#import "RGHudModular.h"
#import "MessageDetailViewController.h"
#import "UITableViewRowAction+JZExtension.h"

@interface MessageListViewController ()<UITableViewDataSource,UITableViewDelegate>
{
    NSInteger countUnread;
    UIView *noStoreView;// 暂无收藏提示
}
@property (weak, nonatomic) IBOutlet UITableView *myTableView;
@property (nonatomic,strong) NSMutableArray *dataArray;// array

@end

@implementation MessageListViewController
@synthesize dataArray;
@synthesize myTableView;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.navigationItem.title = @"消息列表";
    self.myTableView.showsVerticalScrollIndicator = FALSE;
    self.myTableView.dataSource         = self;
    self.myTableView.delegate           = self;
    self.myTableView.backgroundColor    = [UIColor whiteColor];
    self.myTableView.separatorStyle     = UITableViewCellSeparatorStyleNone;
    countUnread = 0;
    // 添加下拉加载页面
    __weak typeof(self) weakSelf        = self;
    
    self.myTableView.header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [weakSelf getData];
    }];
    
    noStoreView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 124, 112)];
    UIImageView *noStoreImg = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 124, 82)];
    noStoreImg.image = [UIImage imageNamed:@"noStore"];
    [noStoreView addSubview:noStoreImg];
    UILabel *lblTip = [[UILabel alloc]initWithFrame:CGRectMake(0, 82, 124, 30)];
    lblTip.text = @"暂无消息";
    lblTip.textAlignment = NSTextAlignmentCenter;
    lblTip.font = [UIFont systemFontOfSize:14];
    lblTip.textColor = [UIColor colorWithRed:79/255.0 green:79/255.0 blue:79/255.0 alpha:1];
    
    [noStoreView addSubview:lblTip];
    
    noStoreView.hidden = YES;
    noStoreView.center = CGPointMake(SCREEN_WIDTH/2, SCREEN_HEIGHT/2 -100);
    [self.view insertSubview:noStoreView belowSubview:myTableView];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.myTableView.header beginRefreshing];
   
}

-(void)beginReloadList
{
    [self.myTableView.header beginRefreshing];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    //判断是否开启通知
    if (![self pushNotificationsEnabled]) {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"提示" message:@"你现在无法收到新消息通知。请到系统“设置”-“通知”-“睿思云”中开启" delegate:self cancelButtonTitle:@"现在设置" otherButtonTitles:@"取消",nil];
        alert.tag = -1;
        [alert show];
    }
}
- (BOOL)pushNotificationsEnabled {
    if ([[UIApplication sharedApplication] respondsToSelector:@selector(currentUserNotificationSettings)]) {
        UIUserNotificationType types = [[[UIApplication sharedApplication] currentUserNotificationSettings] types];
        return (types & UIUserNotificationTypeAlert);
    }
    else {
        UIRemoteNotificationType types = [[UIApplication sharedApplication] enabledRemoteNotificationTypes];
        return (types & UIRemoteNotificationTypeAlert);
    }
}

-(void)updateBgNum
{
    countUnread = 0;
    for (int i=0; i<dataArray.count; i++) {
        NSDictionary *data = [dataArray objectAtIndex:i];
        NSString *stateStr = [NSString stringWithFormat:@"%@",[data objectForKey:@"state"]];
        if (![Common isBlankString:stateStr]) {
            if (stateStr.integerValue == 0) {
                countUnread ++;
            }
        }
        
    }
    if (countUnread != 0) {
        self.tabBarItem.badgeValue = [NSString stringWithFormat:@"%d",(int)countUnread];
    }else{
        self.tabBarItem.badgeValue = nil;
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
                                     };
    NSString *urlString = WEB_SERVICE_LISTMSG([Common GetServiceHost]);
    
    
    [manager GET:urlString parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSArray *arr = responseObject;
        
        dataArray = [[NSMutableArray alloc]initWithArray:arr];
       
        if (dataArray.count == 0) {
            noStoreView.hidden = NO;
        }else{
            noStoreView.hidden = YES;
        }
        
        [self.myTableView.header endRefreshing];
        [self.myTableView reloadData];
        [self updateBgNum];
        
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
        if (dataArray.count == 0) {
            noStoreView.hidden = NO;
        }else{
            noStoreView.hidden = YES;
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
    return 66;
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
    
    UIImageView *imgView = [[UIImageView alloc]initWithFrame:CGRectMake(10, 9, 50, 50)];
    
    imgView.layer.masksToBounds = YES;
    imgView.layer.cornerRadius  = 4;
    NSString *pushType = [data objectForKey:@"pushType"];
    if ([pushType isEqualToString:@"day"]) {
        imgView.image = [UIImage imageNamed:@"appri"];
    }else{
        imgView.image = [UIImage imageNamed:@"appyue"];
    }
    //标题
    UILabel *lblName = [[UILabel alloc]initWithFrame:CGRectMake(70, 0, SCREEN_WIDTH - 70 - 72, 65)];
    lblName.text = [data objectForKey:@"title"];
    lblName.font = [UIFont systemFontOfSize:15];
    
    //时间
    UILabel *lblTime = [[UILabel alloc]initWithFrame:CGRectMake(SCREEN_WIDTH - 70, 0, 60, 65)];
    lblTime.textColor = [UIColor lightGrayColor];
    lblTime.font = [UIFont systemFontOfSize:14];
    NSDictionary *timeDict = [data objectForKey:@"crtdate"];
    if (timeDict != nil) {
        lblTime.text = [Common formatTimeWithStr:[timeDict objectForKey:@"time"]];
    }
    
    lblTime.textAlignment = NSTextAlignmentRight;
    
    //是否阅读标记
    UIView *flagView = [[UIView alloc]initWithFrame:CGRectMake(53, 6, 10, 10)];
    flagView.backgroundColor = [UIColor redColor];
    flagView.layer.masksToBounds = YES;
    flagView.layer.cornerRadius  = 5;
    flagView.hidden = YES;
    
    UIView  *lineView = [[UIView alloc]initWithFrame:CGRectMake(10, 65, SCREEN_WIDTH - 10, 1)];
    lineView.backgroundColor = MT_LINE_COLOR;
    
    NSString *stateStr = [NSString stringWithFormat:@"%@",[data objectForKey:@"state"]];
    if (![Common isBlankString:stateStr]) {
        if (stateStr.integerValue == 0) {
            flagView.hidden = false;
            
        }else{
            flagView.hidden = YES;
        }
    }
    [cell.contentView addSubview:lblName];
    [cell.contentView addSubview:lineView];
    [cell.contentView addSubview:imgView];
    [cell.contentView addSubview:lblTime];
    [cell.contentView addSubview:flagView];
    //    UIButton *btnDel = [UIButton buttonWithType:UIButtonTypeCustom];
    //    btnDel.frame = CGRectMake(SCREEN_WIDTH - 18 - 40, 0, 40, 40);
    //    [btnDel setImage:[UIImage imageNamed:@"btn_storeDel"] forState:UIControlStateNormal];
    //    btnDel.tag = indexPath.row;
    //    [btnDel addTarget:self action:@selector(clickShowAlet:) forControlEvents:UIControlEventTouchUpInside];
    //
    //    [cell.contentView addSubview:btnDel];
    
    return cell;
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSMutableDictionary *tDict = [NSMutableDictionary dictionaryWithDictionary:[dataArray objectAtIndex:indexPath.row]];
    NSString *stateStr = [NSString stringWithFormat:@"%@",[tDict objectForKey:@"state"]];
    if (![Common isBlankString:stateStr]) {
        if (stateStr.integerValue == 0) {
            [tDict setObject:@"1" forKey:@"state"];
            [dataArray replaceObjectAtIndex:indexPath.row withObject:tDict];
            
            [tableView reloadData];
            [self updateFlagAtIndex:indexPath.row];
            
        }
    }
    [self updateBgNum];
    
    [[RGHudModular getRGHud] showPopHudWithMessage:@"加载中..." inView:self.view];
    
    AFHTTPRequestOperationManager   *manager    = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    NSDictionary *aDict = [dataArray objectAtIndex:indexPath.row];
    NSNumber *idStr = [aDict objectForKey:@"id"];
    NSDictionary     *parameters = @{@"token": [Common shareInstence].token,
                                     @"id":idStr};
    NSString *urlString = WEB_SERVICE_MSGDETAIL([Common GetServiceHost]);
    NSString *title2 = [aDict objectForKey:@"title"];
    NSDictionary *timeDict = [aDict objectForKey:@"crtdate"];
    
    [manager GET:urlString parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        [[RGHudModular getRGHud]hidePopHudInView:self.view];
        NSLog(@"推送消息详情%@",responseObject);
        MessageDetailViewController *mdvc = [[MessageDetailViewController alloc]initWithNibName:@"MessageDetailViewController" bundle:nil];
        mdvc.dataArray = [NSMutableArray arrayWithArray:responseObject];
        mdvc.hidesBottomBarWhenPushed = YES;
        mdvc.titleStr = title2;
        if (timeDict != nil) {
            mdvc.pushTime = [Common formatDetailTimeWithStr:[timeDict objectForKey:@"time"]];
        }
        [self.navigationController pushViewController:mdvc animated:YES];
        
        
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
        
        [[RGHudModular getRGHud] showAutoHudWithMessageDefault:@"网络错误"];
    }];
    
}

- (void)updateFlagAtIndex:(NSInteger)index
{
    AFHTTPRequestOperationManager   *manager    = [AFHTTPRequestOperationManager manager];
    //        manager.requestSerializer = [AFJSONRequestSerializer serializer];
    //        manager.responseSerializer = [AFJSONResponseSerializer serializer];
    NSString *url = WEB_SERVICE_MSG2READ([Common GetServiceHost]);
    
   
    NSDictionary *aDict = [dataArray objectAtIndex:index];
    NSNumber *idStr = [aDict objectForKey:@"id"];
    assert(idStr != nil);
    NSDictionary     *parameters = @{@"token": [Common shareInstence].token
                                     ,@"id":idStr};
    
    
    [manager POST:url parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        
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
        
        
    }];
}

- (nullable NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    void(^rowActionHandler)(UITableViewRowAction *, NSIndexPath *) = ^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        NSLog(@"%@", action.title);
        if ([action.title isEqualToString:@"删除"]) {
            UIAlertView *alertShow = [[UIAlertView alloc]initWithTitle:@"提示" message:@"是否确认删除操作？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
            alertShow.tag = indexPath.row;
            [alertShow show];
        }
        
    };
    
    //    UIButton *buttonForImage = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
    //    UITableViewRowAction *action1 = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault image:[buttonForImage imageForState:UIControlStateNormal] handler:rowActionHandler];
    //
    
    UITableViewRowAction *action3 = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:@"删除" handler:rowActionHandler];
    
    return @[action3];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == -1) {
        
        if (buttonIndex == 0) {
            NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
            if([[UIApplication sharedApplication] canOpenURL:url]) {
                [[UIApplication sharedApplication]openURL:url];
            }
            
        }
        return;
    }
    if (buttonIndex == 1) {//确定删除配置
        AFHTTPRequestOperationManager   *manager    = [AFHTTPRequestOperationManager manager];
        //        manager.requestSerializer = [AFJSONRequestSerializer serializer];
        //        manager.responseSerializer = [AFJSONResponseSerializer serializer];
        
        NSDictionary *aDict = [dataArray objectAtIndex:alertView.tag];
        NSNumber *idStr = [aDict objectForKey:@"id"];
        assert(idStr != nil);
        NSDictionary     *parameters = @{@"token": [Common shareInstence].token
                                         ,@"id":idStr};
        NSString *urlString = WEB_SERVICE_DELMSG([Common GetServiceHost]);
        
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
