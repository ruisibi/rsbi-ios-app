/*********************************************************************
 * 版权所有   magic_Zzz
 *
 * 文件名称： BaseNavigationViewController 基础navigation
 * 内容摘要： 基础抽屉
 * 其它说明： 实现文件
 * 作 成 者： ZGD
 * 完成日期： 2016年03月08日
 * 修改记录1：
 * 修改日期：
 * 修 改 人：
 * 修改内容：
 * 修改记录2：
 **********************************************************************/
#import "BaseNavigationViewController.h"


@interface BaseNavigationViewController ()<UINavigationControllerDelegate>

@end

@implementation BaseNavigationViewController

- (id)initWithRootViewController:(UIViewController *)rootViewController
{
    self = [super initWithRootViewController:rootViewController];
    
    [self.navigationBar setBackgroundImage:[UIImage imageNamed:@"navBg"] forBarMetrics:UIBarMetricsDefault];
    [self.navigationBar setBarTintColor:[UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1.0]];
    [[UIBarButtonItem appearance] setBackButtonTitlePositionAdjustment:UIOffsetMake(NSIntegerMin, NSIntegerMin) forBarMetrics:UIBarMetricsDefault];
    
    self.navigationBar.tintColor = [UIColor whiteColor];
    return self;
}

//-(BOOL)shouldAutorotate
//{
//    
//    return NO;
//}
//
//
//-(NSUInteger)supportedInterfaceOrientations
//{
//    return [self.topViewController supportedInterfaceOrientations];
//}
//
//
//- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
//{
//    return [self.topViewController preferredInterfaceOrientationForPresentation];
//}

- (void)viewDidLoad {
    [super viewDidLoad];
//    self.delegate = self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}




@end
