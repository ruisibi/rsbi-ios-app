/*********************************************************************
 * 版权所有   magic_Zzz
 *
 * 文件名称： SignUpViewController
 * 内容摘要： //     登录页面
 * 其它说明： 实现文件
 * 作 成 者： ZGD
 * 完成日期： 2016年03月22日
 * 修改记录1：
 * 修改日期：
 * 修 改 人：
 * 修改内容：
 * 修改记录2：
 **********************************************************************/

#import "SignUpViewController.h"
#import "Common.h"
#import "AFNetworking.h"
#import "UserData.h"
#import "MainListViewController.h"
#import "RGHudModular.h"
#import "AddressListView.h"
#import "BPush.h"

@interface SignUpViewController ()<AddressListViewDelegate>
@property (weak, nonatomic) IBOutlet UITextField *txtUserName;// 用户名
@property (weak, nonatomic) IBOutlet UITextField *txtPass;// 用户密码
@property (weak, nonatomic) IBOutlet UIButton *btnLogin;// 登录按钮
@property (weak, nonatomic) IBOutlet UITextField *txtIpAddress;// 服务器地址
@property (nonatomic, strong) AddressListView *listView;
@end

@implementation SignUpViewController
@synthesize btnLogin;
@synthesize txtPass;
@synthesize txtUserName;
@synthesize txtIpAddress;
@synthesize listView;

- (void)viewDidLoad {
    [super viewDidLoad];
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    NSString *ipAddress = [userDefault stringForKey:@"ipAddress0"];
 
    if (ipAddress == nil) {
        ipAddress = @"http://bi.rosetech.cn";
        [userDefault setObject:@"http://bi.rosetech.cn" forKey:@"ipAddress0"];
    } 
    self.title = @"系统登录";
    txtIpAddress.text = ipAddress;
//    txtUserName.text = @"dyc";
//    txtPass.text = @"123456";
    
    // 设置视图
    [self.navigationController.navigationBar setBarTintColor:[UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1.0]];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    txtPass.secureTextEntry = YES;
  
    btnLogin.layer.masksToBounds = YES;
    btnLogin.layer.cornerRadius = 6;
    
    
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    NSString *userAccount = [userDefault stringForKey:@"userAccount"];
    NSString *userPass = [userDefault stringForKey:@"userPass"];
    
    if (![Common isBlankString:userAccount]) {// 账号不为空
        txtUserName.text = userAccount;
    }
    
    if (![Common isBlankString:userPass]) {// 用户密码
        txtPass.text = userPass;
        [self clickLogin:nil];
        
    }else{
        txtPass.text = @"";
    }
}
/***********************************************************************
 * 方法名称： clickLogin
 * 功能描述： 登录点击事件
 * 输入参数：
 * 输出参数：
 * 返 回 值：
 ***********************************************************************/
- (IBAction)clickLogin:(id)sender {
    [[RGHudModular getRGHud] showPopHudWithMessage:@"登录中..." inWindow:self.view];
    
    if ([Common isBlankString:txtPass.text]) {
        [[RGHudModular getRGHud]showAutoHudWithMessageDefault:@"服务器地址不能为空"];
        return;
    }
    if ([Common isBlankString:txtUserName.text]) {
        
        [[RGHudModular getRGHud]showAutoHudWithMessageDefault:@"账号不能为空"];
        return;
    }
    if ([Common isBlankString:txtPass.text]) {
        [[RGHudModular getRGHud]showAutoHudWithMessageDefault:@"密码不能为空"];
        return;
    }
    
    AFHTTPRequestOperationManager   *manager    = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    // 设置超时时间
    [manager.requestSerializer willChangeValueForKey:@"timeoutInterval"];
    manager.requestSerializer.timeoutInterval = 20.f;
    [manager.requestSerializer didChangeValueForKey:@"timeoutInterval"];
    
    NSMutableDictionary     *parameters =[NSMutableDictionary dictionaryWithCapacity:2];
    [parameters setObject:txtUserName.text forKey:@"userName"];
    [parameters setObject:txtPass.text forKey:@"password"];
    if ([BPush getChannelId] != nil) {
        [parameters setObject:[BPush getChannelId] forKey:@"channel_id"];
    }
    
    NSLog(@"登录参数:%@",parameters);
    
    [manager GET:WEB_SERVICE_LOGIN(txtIpAddress.text) parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSString *result =[responseObject objectForKey:@"result"];
        
        if (result.intValue == 0) {//登录失败
            [[RGHudModular getRGHud] hidePopHudInWindow:self.view];
            [Common shareInstence].isLogin     = NO;
            NSString *msg =[responseObject objectForKey:@"msg"];
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"提示" message:msg delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [alert show];
            
        }else{// 登录成功
           
            [Common saveHost:txtIpAddress.text];
            
            [[RGHudModular getRGHud] hidePopHudInWindow:self.view];
            NSDictionary *userDict = [responseObject objectForKey:@"user"];
            [[UserData getUserData] initUserData:userDict];
            [Common shareInstence].token = [responseObject objectForKey:@"token"];
            [Common shareInstence].userAccount = txtUserName.text;
            [Common shareInstence].isLogin     = YES;
            NSLog(@"登录的用户名:%@",userDict);
            self.mainTabView = [[MainTabViewController alloc]initWithNibName:@"MainTabViewController" bundle:nil];
            //保存自动登录
            NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
            
            [userDefault setObject:txtUserName.text forKey:@"userAccount"];
            [userDefault setObject:txtPass.text forKey:@"userPass"];
            
            [self presentViewController:self.mainTabView animated:true completion:nil];
        }
        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
       [[RGHudModular getRGHud] showAutoHudWithMessageDefault:@"网络错误"];
    }];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/***********************************************************************
 * 方法名称： closeKeyboard
 * 功能描述： 关闭键盘
 * 输入参数：
 * 输出参数：
 * 返 回 值：
 ***********************************************************************/
- (IBAction)closeKeyboard:(id)sender {
    listView.hidden = true;
    [txtPass resignFirstResponder];
    [txtUserName resignFirstResponder];
    [txtIpAddress resignFirstResponder];
}

/***********************************************************************
 * 方法名称： - (void)didSelectAddress:(NSString *)iphost
 * 功能描述： 选中下拉列表
 * 输入参数：
 * 输出参数：
 * 返 回 值：
 ***********************************************************************/
- (void)didSelectAddress:(NSString *)iphost
{
    txtIpAddress.text = iphost;
}

/***********************************************************************
 * 方法名称： clickOpenList
 * 功能描述： 打开下拉列表
 * 输入参数：
 * 输出参数：
 * 返 回 值：
 ***********************************************************************/
- (IBAction)clickOpenList:(id)sender {
    if (listView == nil) {
        listView = [[AddressListView alloc]initWithFrame:CGRectMake(txtIpAddress.frame.origin.x, txtIpAddress.frame.origin.y + 28, txtIpAddress.frame.size.width, 120)];
        listView.hidden = true;
        listView.delegate = self;
        [self.view addSubview:listView];
    }
    if (listView.hidden) {
        
        listView.hidden = false;
        [listView reloadData];
    }else{
        listView.hidden = true;
    }
    
}

- (IBAction)clikcOpenUrl:(id)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.ruisitech.com/appsy.html"]];
}

@end
