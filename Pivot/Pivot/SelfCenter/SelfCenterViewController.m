/*********************************************************************
 * 版权所有   magic_Zzz
 *
 * 文件名称： SelfCenterViewController
 * 内容摘要： 个人信息
 * 其它说明： 实现文件
 * 作 成 者： ZGD
 * 完成日期： 2016年03月08日
 * 修改记录1：
 * 修改日期：
 * 修 改 人：
 * 修改内容：
 * 修改记录2：
 **********************************************************************/


#import "SelfCenterViewController.h"
#import "Common.h"
#import "UserData.h"
#import "AFNetworking.h"
#import "RGHudModular.h"

@interface SelfCenterViewController ()<UITableViewDataSource,UITableViewDelegate,UIAlertViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *myTableView;
@property (nonatomic,strong) NSArray *nameArray;
@property (nonatomic,strong) NSDictionary *userDict;
@end

@implementation SelfCenterViewController
@synthesize myTableView;
@synthesize nameArray;

- (void)viewDidLoad {
    [super viewDidLoad];
    _userDict = @{};
    nameArray = [[NSArray alloc]initWithObjects:@"登录名",@"用户名",@"所属企业",@"账号状态",@"登录次数",@"上次登录时间",@"账号开通时间",@"账号结束时间", nil];
    self.title = @"个人信息";
    myTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    self.myTableView.scrollEnabled = false;
    [self.myTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"infocell"];
    
    NSMutableDictionary *dict =[NSMutableDictionary dictionaryWithCapacity:1];
    [dict setObject:[UIFont systemFontOfSize:15] forKey:NSFontAttributeName];
    
    
    UIBarButtonItem *leftBtn = [[UIBarButtonItem alloc] initWithTitle:@"注销" style:UIBarButtonItemStylePlain target:self action:@selector(clickSignUp:)];
    
    [leftBtn setTitleTextAttributes:dict forState:UIControlStateNormal];
    self.navigationItem.rightBarButtonItem = leftBtn;
    [self getUserInfo];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)getUserInfo
{
    AFHTTPRequestOperationManager   *manager    = [AFHTTPRequestOperationManager manager];
    
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    
    NSDictionary     *parameters = @{@"token": [Common shareInstence].token
                                     };
    [manager POST:WEB_SERVICE_USERINFO([Common GetServiceHost]) parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        self.userDict = responseObject;
//        NSLog(@"用户信息:%@",responseObject);
        [myTableView reloadData];
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

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        AFHTTPRequestOperationManager   *manager    = [AFHTTPRequestOperationManager manager];
        manager.requestSerializer = [AFJSONRequestSerializer serializer];
        manager.responseSerializer = [AFJSONResponseSerializer serializer];
        
        NSDictionary     *parameters = @{@"userId": [UserData getUserData].userId,@"token": [Common shareInstence].token
                                         };
        
        [manager GET:WEB_SERVICE_LOGOUT([Common GetServiceHost]) parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
            [Common shareInstence].isLogin = NO;
            NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
            [userDefault removeObjectForKey:@"userPass"];
            
            [[UserData getUserData] signOutUser];
            [self.navigationController popToRootViewControllerAnimated:false];
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            
            // 判断token是否可用
            NSString *errStr = operation.responseString;
            if (![Common isBlankString:errStr]&& [errStr isEqualToString:@"\r\n{error:'用户未登录。'}"]) {
                [Common shareInstence].isLogin = NO;
                [[RGHudModular getRGHud] showAutoHudWithMessageDefault:@"用户登录失效,请重新登录"];
                
                [self.navigationController popToRootViewControllerAnimated:false];
                return ;
            }
            [[RGHudModular getRGHud] showAutoHudWithMessageDefault:@"网络错误"];
        }];
    }
}
/***********************************************************************
 * 方法名称： clickSignUp
 * 功能描述： // 点击注销
 * 输入参数：
 * 输出参数：
 * 返 回 值：
 ***********************************************************************/
- (void)clickSignUp:(UIButton *)sender
{
    UIAlertView *alertShow = [[UIAlertView alloc]initWithTitle:@"提示" message:@"是否确认注销用户？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    [alertShow show];
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return nameArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *ID = @"infocell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:ID];
        
    }
    
    for(UIView *subView in cell.contentView.subviews ) {
        [subView removeFromSuperview];
    }
    UILabel *lblTitle = [[UILabel alloc]initWithFrame:CGRectMake(10, 0, 100, 50)];
    lblTitle.text = [nameArray objectAtIndex:indexPath.row];
    lblTitle.font = [UIFont systemFontOfSize:15];
    
    [cell.contentView addSubview:lblTitle];
    UILabel *lblInfo = [[UILabel alloc]initWithFrame:CGRectMake(SCREEN_WIDTH - 200, 0, 190, 50)];
    switch (indexPath.row) {
        case 0:// 登录账号
            lblInfo.text = [Common shareInstence].userAccount;
            break;
        case 1:// 用户名
            lblInfo.text = [self.userDict objectForKey:@"login_name"];
            break;
        case 2:// 所属企业
            lblInfo.text = [self.userDict objectForKey:@"company"];
            break;
        case 3:// 账号状态
            if ([UserData getUserData].state.intValue==1) {
                lblInfo.text = @"有效";
            }else{
                lblInfo.text = @"无效";
            }
            break;
        case 4:// 登录次数
            lblInfo.text = [NSString stringWithFormat:@"%@次",[self.userDict objectForKey:@"log_cnt"]];
            break;
        case 5:// 上次登录时间
        {
            NSDictionary *didi = [self.userDict objectForKey:@"log_date"];
            if (didi != nil) {
                NSString *dateStr = [NSString stringWithFormat:@"%@",[didi objectForKey:@"time"]];
                NSTimeInterval time=[dateStr doubleValue]/1000;//因为时差问题要加8小时 == 28800 sec
                
                NSDate *detaildate=[NSDate dateWithTimeIntervalSince1970:time];
                
//                NSLog(@"date:%@",[detaildate description]);
                
                //实例化一个NSDateFormatter对象
                
                NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                
                //设定时间格式,这里可以设置成自己需要的格式
                
                [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
                
                
                
                NSString *currentDateStr = [dateFormatter stringFromDate: detaildate];
                
              
                
                lblInfo.text = currentDateStr;
            }
            break;
        }
           
        case 6:// 账号开通时间
            lblInfo.text = [UserData getUserData].sdate;
            break;
        case 7:// 账号结束时间
            lblInfo.text = [UserData getUserData].edate;
            break;
            
        default:
            break;
    }
    
    lblInfo.textColor = [UIColor colorWithRed:64/255.0 green:63/255.0 blue:63/255.0 alpha:1];
    lblInfo.textAlignment = NSTextAlignmentRight;
    lblInfo.font = [UIFont systemFontOfSize:15];
    [cell.contentView addSubview:lblInfo];
    UIView *imgLine = [[UIView alloc]init];
    imgLine.frame = CGRectMake(0, 49, SCREEN_WIDTH , 1);
    imgLine.backgroundColor = [UIColor colorWithRed:181/255.0 green:181/255.0 blue:181/255.0 alpha:1.0];
    [cell.contentView addSubview:imgLine];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

 
@end
