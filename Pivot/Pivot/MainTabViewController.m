/*********************************************************************
 * 版权所有   magic_Zzz
 *
 * 文件名称： MainTabViewController
 * 内容摘要： // 主切换视图
 * 其它说明： 实现文件
 * 作 成 者： ZGD
 * 完成日期： 2016年03月22日
 * 修改记录1：
 * 修改日期：
 * 修 改 人：
 * 修改内容：
 * 修改记录2：
 **********************************************************************/


#import "MainTabViewController.h"
#import "MainListViewController.h"
#import "UseStoreViewController.h"
#import "BaseNavigationViewController.h"
#import "Common.h"
#import "MessageListViewController.h"
#import "AFNetworking.h"

@interface MainTabViewController ()<TokenDismisDelegate,UITabBarControllerDelegate>
{
    MessageListViewController *msgvc;
}
@end

@implementation MainTabViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    MainListViewController *mlvc = [[MainListViewController alloc]initWithNibName:@"MainListViewController" bundle:nil];
    mlvc.tabBarItem = [[UITabBarItem alloc]initWithTitle:nil image:[UIImage imageNamed:@"tab_btn1"] tag:1];
    UIImage *select = [UIImage imageNamed:@"tab_btn1-sel"];
    
    mlvc.tabBarItem.selectedImage = [select imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    mlvc.delegate = self;
    mlvc.tabBarItem.imageInsets = UIEdgeInsetsMake(6, 0, -6, 0);
    
    
    UseStoreViewController *usvc = [[UseStoreViewController alloc]initWithNibName:@"UseStoreViewController" bundle:nil];
    usvc.tabBarItem = [[UITabBarItem alloc]initWithTitle:nil image:[UIImage imageNamed:@"tab_btn2"] tag:1];
    UIImage *select2 = [UIImage imageNamed:@"tab_btn2-sel"];
    
    usvc.tabBarItem.selectedImage = [select2 imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    usvc.tabBarItem.imageInsets = UIEdgeInsetsMake(6, 0, -6, 0);
    usvc.delegate = self;
    
    msgvc = [[MessageListViewController alloc]initWithNibName:@"MessageListViewController" bundle:nil];
    msgvc.tabBarItem = [[UITabBarItem alloc]initWithTitle:nil image:[UIImage imageNamed:@"tab_btn3"] tag:1];
    UIImage *select3 = [UIImage imageNamed:@"tab_btn3-sel"];
    
    msgvc.tabBarItem.selectedImage = [select3 imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    msgvc.tabBarItem.imageInsets = UIEdgeInsetsMake(6, 0, -6, 0);
    msgvc.delegate = self;
    
    
    BaseNavigationViewController *bnvc1=[[BaseNavigationViewController alloc]initWithRootViewController:mlvc];
    [bnvc1.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]
                                                }];
    bnvc1.navigationBar.translucent = NO;
    bnvc1.title = @"菜单";
    BaseNavigationViewController *bnvc2=[[BaseNavigationViewController alloc]initWithRootViewController:usvc];
    [bnvc2.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]
                                                }];
    bnvc2.navigationBar.translucent = NO;
    bnvc2.title = @"个人收藏";
    
    BaseNavigationViewController *bnvc3=[[BaseNavigationViewController alloc]initWithRootViewController:msgvc];
    [bnvc3.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]
                                                  }];
    bnvc3.navigationBar.translucent = NO;
    bnvc3.title = @"通知消息";
    
    
    
    
    [self setViewControllers:@[bnvc1,bnvc3,bnvc2] animated:true];
    UIImageView *bgimg = [[UIImageView alloc]initWithFrame:self.tabBar.bounds];
    bgimg.image = [UIImage imageNamed:@"tab_bg"];
    [self.tabBar insertSubview:bgimg atIndex:0];
    self.tabBar.opaque = true;
    
    
    
    
}


-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self reloadListOrBadge];
}

- (void)reloadListOrBadge
{
    if (self.selectedIndex != 1) {
        //判断是否有未读
        
        [self getData];
    }else{
        [msgvc beginReloadList];
    }
}

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
        if (arr.count != 0) {
            int countUnread = 0;
            for (int i=0; i<arr.count; i++) {
                NSDictionary *data = [arr objectAtIndex:i];
                NSString *stateStr = [NSString stringWithFormat:@"%@",[data objectForKey:@"state"]];
                if (![Common isBlankString:stateStr]) {
                    if (stateStr.integerValue == 0) {
                        countUnread ++;
                    }
                }
                
            }
            if (countUnread != 0) {
                msgvc.tabBarItem.badgeValue = [NSString stringWithFormat:@"%d",(int)countUnread];
            }else{
                msgvc.tabBarItem.badgeValue = nil;
            }
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
       
    }];
}
-(void)disMisTabView
{
    [self dismissViewControllerAnimated:false completion:^{
        
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController
{

}


@end
