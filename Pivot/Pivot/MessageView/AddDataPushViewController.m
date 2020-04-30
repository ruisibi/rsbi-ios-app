//
//  AddDataPushViewController.m
//  Pivot
//
//  Created by djh on 16/5/12.
//  Copyright © 2016年 bos. All rights reserved.
//

#import "AddDataPushViewController.h"
#import "Common.h"
#import "AFNetworking.h"
#import "MJRefresh.h"
#import "RGHudModular.h"
#import "PushSettingViewController.h"

@interface AddDataPushViewController ()<UITableViewDataSource,UITableViewDelegate>
{
    UIBarButtonItem *nextBtn;// 下一步按扭
    BOOL     isHistory;
    NSString *selectTid;
}
@property (weak, nonatomic) IBOutlet UITableView *myTableView;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentMode;//选择的模式
@property (nonatomic,strong) NSMutableArray *dayArray;// array
@property (nonatomic,strong) NSMutableArray *monthArray;// array

@property (nonatomic,strong) NSDictionary   *selectDict;


@end

@implementation AddDataPushViewController
@synthesize dayArray;
@synthesize monthArray;
@synthesize segmentMode;
@synthesize myTableView;
@synthesize selectDict;


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    segmentMode.selectedSegmentIndex = 0;
    self.navigationItem.title = @"新增推送信息";
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
    
    
    
    
    dayArray      = [[NSMutableArray alloc]init];
    monthArray    = [[NSMutableArray alloc]init];
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
 * 方法名称：- (void)clickNext
 * 功能描述： 下一步配置
 * 输入参数：
 * 输出参数：
 * 返 回 值：
 ***********************************************************************/
-(void)clickNext
{
    PushSettingViewController *psvc = [[PushSettingViewController alloc]initWithNibName:@"PushSettingViewController" bundle:nil];
    if (isHistory) {// 是否历史判断
        [[RGHudModular getRGHud]hidePopHudInView:self.view];
        isHistory = false;
    }
    if (![Common isBlankString:selectTid]) {
        psvc.tid = [NSString stringWithFormat:@"%@",selectTid];
        psvc.pushType = segmentMode.selectedSegmentIndex;
        if (_historyDict != nil) {
            psvc.historyDict = [NSDictionary dictionaryWithDictionary:_historyDict];
        }
        [self.navigationController pushViewController:psvc animated:YES];
    }else{
        [[RGHudModular getRGHud]showAutoHudWithMessageDefault:@"配置信息异常"];
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
    
    
    NSString *subType = @"day";
    if (segmentMode.selectedSegmentIndex == 1) {
        subType = @"month";
    }
    
    if (isHistory && _historyDict != nil) {
        [[RGHudModular getRGHud] showPopHudWithMessage:@"加载中..." inWindow:self.view];
        selectTid = [NSString stringWithFormat:@"%@",[_historyDict objectForKey:@"tid"]];
        
        if ([_historyDict objectForKey:@"pushType"] != nil) {
            subType   = [_historyDict objectForKey:@"pushType"];
            if ([subType isEqualToString:@"day"]) {
                segmentMode.selectedSegmentIndex = 0;
            }else{
                segmentMode.selectedSegmentIndex = 1;
            }
        }
    }
    
    NSDictionary     *parameters = @{@"token": [Common shareInstence].token
                                     ,@"subjectType":subType};
    NSString *urlString = WEB_SERVICE_PUSHSUBJECT([Common GetServiceHost]);
    
    [manager GET:urlString parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSArray *arr = responseObject;
        
        if (segmentMode.selectedSegmentIndex == 0) {
            dayArray = [NSMutableArray arrayWithArray:arr];
        }else{
            monthArray = [NSMutableArray arrayWithArray:arr];
        }
        
        [self.myTableView.header endRefreshing];
        [self.myTableView reloadData];
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
        [self.myTableView.header endRefreshing];
        [[RGHudModular getRGHud] showAutoHudWithMessageDefault:@"网络错误"];
    }];
}

- (IBAction)changeMode:(id)sender {
    selectDict = nil;
    selectTid  = nil;
    nextBtn.enabled = false;
    [self.myTableView.header beginRefreshing];
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
    _historyDict = [NSDictionary dictionaryWithDictionary:aDict];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return segmentMode.selectedSegmentIndex == 0 ?  dayArray.count : monthArray.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 40;
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
    
    NSDictionary *data = nil;
    
    if (segmentMode.selectedSegmentIndex == 0 ) {
        
        data = [NSDictionary dictionaryWithDictionary:[dayArray objectAtIndex:indexPath.row]];
    }else{
        
        data = [NSDictionary dictionaryWithDictionary:[monthArray objectAtIndex:indexPath.row]];
    }
    
    UILabel *lblName = [[UILabel alloc]initWithFrame:CGRectMake(40, 0, SCREEN_WIDTH - 40, 40)];
    lblName.text = [data objectForKey:@"tdesc"];
    lblName.font = [UIFont systemFontOfSize:13];
    UIView  *lineView = [[UIView alloc]initWithFrame:CGRectMake(0, 39, SCREEN_WIDTH, 1)];
    lineView.backgroundColor = MT_LINE_COLOR;
    [cell.contentView addSubview:lblName];
    [cell.contentView addSubview:lineView];
    UIImageView *selectImg = [[UIImageView alloc]initWithFrame:CGRectMake(10, 7.5, 25, 25)];
    [cell.contentView addSubview:selectImg];
    
    
    NSNumber *tId = [data objectForKey:@"tid"];
    if (![Common isBlankString:selectTid]) {
        
        if (selectTid != nil && tId.intValue == selectTid.intValue)
        {
            if (nextBtn.enabled == false) {
                nextBtn.enabled = true;
            }
            selectImg.image = [UIImage imageNamed:@"cellSelect"];
        }
        else
        {
            selectImg.image = [UIImage imageNamed:@"cellnormal"];
        }
    }else{
        selectImg.image = [UIImage imageNamed:@"cellnormal"];
    }
    
    
    
    return cell;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (segmentMode.selectedSegmentIndex == 0 ) {
        
        selectDict = [NSDictionary dictionaryWithDictionary:[dayArray objectAtIndex:indexPath.row]];
    }else{
        
        selectDict = [NSDictionary dictionaryWithDictionary:[monthArray objectAtIndex:indexPath.row]];
    }
    
    selectTid = [NSString stringWithFormat:@"%@",[selectDict objectForKey:@"tid"]];
   
    //    NSLog(@"%@",[dataArray objectAtIndex:currentIndex]);
    [tableView reloadData];
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
