/*********************************************************************
 * 版权所有   magic_Zzz
 *
 * 文件名称： PushSettingViewController
 * 内容摘要： 推送信息设置
 * 其它说明： 实现文件
 * 作 成 者： ZGD
 * 完成日期： 2016年03月22日
 * 修改记录1：
 * 修改日期：
 * 修 改 人：
 * 修改内容：
 * 修改记录2：
 **********************************************************************/

#import "PushSettingViewController.h"
#import "Common.h"
#import "AFNetworking.h"
#import "StoreConfigPopView.h"
#import "KLCPopup.h"
#import "ParameterListViewController.h"
#import "PushFilterViewController.h"
#import "RGHudModular.h"
#import "PushDateSetViewController.h"
#import "JSONKit.h"
#import "DataPushViewController.h"

@interface PushSettingViewController ()<UITableViewDataSource,UITableViewDelegate,ParameterSelectDelegate>
{
    NSArray *nameArray;// 名字数组
    NSMutableDictionary *selectDict;// 选择好的度量
    NSString *saveName;
    NSString *saveID;
    NSString *currentUnit;//单位
}

@property (weak, nonatomic) IBOutlet UITableView *myTableView;

@end

@implementation PushSettingViewController
@synthesize myTableView;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    saveID = @"";
    saveName = @"";
    currentUnit = @"";
    self.navigationItem.title = @"推送信息设置";
    
    nameArray = [[NSArray alloc]initWithObjects:@"推送维度",@"推送度量",@"筛选条件",@"推送时间", nil];
    
    selectDict = [NSMutableDictionary dictionaryWithCapacity:4];//dict0,dict1,dict2,dict3
    
    // 右上角按钮
    UIImage *imgRight = [UIImage imageNamed:@"btn_save"];
    UIButton *rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    rightBtn.frame = CGRectMake(0, 0, imgRight.size.width, imgRight.size.height);
    [rightBtn setBackgroundImage:imgRight forState:UIControlStateNormal];
    [rightBtn addTarget:self action:@selector(clickSave) forControlEvents:UIControlEventTouchUpInside];
    
    [self.navigationItem setRightBarButtonItem:[[UIBarButtonItem alloc]initWithCustomView:rightBtn]];
    
    
    // 初始化列表
    self.myTableView.showsVerticalScrollIndicator = FALSE;
    self.myTableView.dataSource         = self;
    self.myTableView.delegate           = self;
    self.myTableView.backgroundColor    = [UIColor whiteColor];
    self.myTableView.separatorStyle     = UITableViewCellSeparatorStyleNone;
    
    
    [myTableView reloadData];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        //刷新完成
        if ([self hasHistory]) {// 有历史数据就还原配置
            NSLog(@"历史记录:%@",self.historyDict);
            
            saveID = [NSString stringWithFormat:@"%@",[self.historyDict objectForKey:@"id"]];
            saveName = [NSString stringWithFormat:@"%@",[self.historyDict objectForKey:@"title"]];
            // 维度相关
            NSDictionary *dim = [self.historyDict objectForKey:@"dim"];
            if (dim != nil) {
                NSMutableDictionary *dimTmp = [NSMutableDictionary dictionaryWithDictionary:dim];
                if ([dimTmp objectForKey:@"type"] != nil) {
                    [dimTmp setObject:[dimTmp objectForKey:@"type"] forKey:@"dim_type"];
                }
                if ([dimTmp objectForKey:@"colname"] != nil) {
                    [dimTmp setObject:[dimTmp objectForKey:@"colname"] forKey:@"col_name"];
                }
                if ([dimTmp objectForKey:@"dimdesc"] != nil) {
                    [dimTmp setObject:[dimTmp objectForKey:@"dimdesc"] forKey:@"text"];
                }
                [selectDict setObject:dimTmp forKey:@"dict0"];
            }
            
            // 度量相关
            NSArray *kpi  = [self.historyDict objectForKey:@"kpiJson"];
            if (kpi != nil) {
                if (kpi.count == 0) {
                    return ;
                }
                NSMutableDictionary *kpiJson = [NSMutableDictionary dictionaryWithDictionary:kpi.firstObject];
                if ([kpiJson objectForKey:@"kpi_id"]!= nil) {
                    [kpiJson setObject:[kpiJson objectForKey:@"kpi_id"] forKey:@"col_id"];
                }
                if ([kpiJson objectForKey:@"kpi_name"]!= nil) {
                    [kpiJson setObject:[kpiJson objectForKey:@"kpi_name"] forKey:@"text"];
                }
                
                if ([kpiJson objectForKey:@"unit"] != nil) {
                    currentUnit = [kpiJson objectForKey:@"unit"];
                }
                // 度量筛选相关
                if ([kpiJson objectForKey:@"opt"] != nil) {
                    NSMutableDictionary *ttDict = [NSMutableDictionary dictionaryWithCapacity:3];
                    [ttDict setObject:[kpiJson objectForKey:@"opt"] forKey:@"opt"];
                    if ([kpiJson objectForKey:@"val1"] != nil) {
                        [ttDict setObject:[kpiJson objectForKey:@"val1"] forKey:@"val1"];
                    }
                    if ([kpiJson objectForKey:@"val2"] != nil) {
                        [ttDict setObject:[kpiJson objectForKey:@"val2"] forKey:@"val2"];
                    }
                    [selectDict setObject:ttDict forKey:@"dict2"];
                    [kpiJson removeObjectForKey:@"opt"];
                    [kpiJson removeObjectForKey:@"val1"];
                    [kpiJson removeObjectForKey:@"val2"];
                }
                
                [selectDict setObject:kpiJson forKey:@"dict1"];
            }
            
            // 时间筛选
            NSDictionary *job  = [self.historyDict objectForKey:@"job"];
            if (job != nil) {
                [selectDict setObject:job forKey:@"dict3"];
            }
            [myTableView reloadData];
        }
    });
    // Do any additional setup after loading the view from its nib.
}

/***********************************************************************
 * 方法名称： hasHistory
 * 功能描述： 是否有历史数据就还原配置
 * 输入参数：
 * 输出参数：
 * 返 回 值：
 ***********************************************************************/
-(BOOL)hasHistory
{
    BOOL flag = NO;
    if (self.historyDict != nil) {// 有历史数据就还原配置
        NSString *cTid = [NSString stringWithFormat:@"%@",[self.historyDict objectForKey:@"tid"]];
        if ([cTid isEqualToString:self.tid]) {
            flag = YES;
        }
    }
    return flag;
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
    return nameArray.count;
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
    return 70;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString         *CellIdentifier = @"psCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone; //选中cell时无色
        cell.accessoryType  = UITableViewCellAccessoryDisclosureIndicator;
        cell.contentView.backgroundColor = MT_CELL_COLOR;
    }
    for(UIView *subView in cell.contentView.subviews ) {
        [subView removeFromSuperview];
    }
    
    UILabel *lblTitle = [[UILabel alloc]initWithFrame:CGRectMake(10, 0, 64, 70)];
    lblTitle.text = [nameArray objectAtIndex:indexPath.section];
    lblTitle.font = [UIFont systemFontOfSize:14];
    lblTitle.textAlignment = NSTextAlignmentCenter;
    lblTitle.numberOfLines = 2;
    [cell.contentView addSubview:lblTitle];
    
    UILabel *lblInfo = [[UILabel alloc]initWithFrame:CGRectMake(SCREEN_WIDTH - 200, 0, 170, 70)];
    lblInfo.textColor = [UIColor colorWithRed:64/255.0 green:63/255.0 blue:63/255.0 alpha:1];
    lblInfo.textAlignment = NSTextAlignmentRight;
    
    lblInfo.font = [UIFont systemFontOfSize:14];
//    lblInfo.adjustsFontSizeToFitWidth = true;
    NSDictionary *tmpStr = [selectDict objectForKey:[NSString stringWithFormat:@"dict%d",(int)indexPath.section]];
    if (tmpStr != nil) {
        if (indexPath.section == 0 || indexPath.section == 1) {
            if ([tmpStr objectForKey:@"text"] == nil) {
                lblInfo.text = @"空";
            }else{
                
                CGSize labelsize = [self sizeWithString:[tmpStr objectForKey:@"text"] font:[UIFont systemFontOfSize:14]];
                lblInfo.frame = CGRectMake(SCREEN_WIDTH - 30 - labelsize.width, 0.0, labelsize.width, 70 );
                
                lblInfo.text = [tmpStr objectForKey:@"text"];
                
                UIButton *btnDel = [[UIButton alloc]initWithFrame:CGRectMake(SCREEN_WIDTH - 30 - labelsize.width - 35, 20, 30, 30)];
                [btnDel setImage:[UIImage imageNamed:@"btn_del"] forState:UIControlStateNormal];
                [btnDel addTarget:self action:@selector(delSelected:) forControlEvents:UIControlEventTouchUpInside];
                btnDel.tag = indexPath.section;
                [cell.contentView addSubview:btnDel];
                
            }
        }else if(indexPath.section == 2){//筛选条件
            if ([tmpStr objectForKey:@"opt"] == nil) {
                lblInfo.text = @"空";
            }else{
                NSDictionary *tmpStr2 = [selectDict objectForKey:@"dict1"];
                NSString *aStr = [NSString stringWithFormat:@"%@ %@ %@%@",[tmpStr2 objectForKey:@"text"],[tmpStr objectForKey:@"opt"],[tmpStr objectForKey:@"val1"],currentUnit];
                if ([[tmpStr objectForKey:@"opt"] isEqualToString:@"between"]) {
                    aStr = [NSString stringWithFormat:@"%@ %@ %@%@ and %@%@",[tmpStr2 objectForKey:@"text"],[tmpStr objectForKey:@"opt"],[tmpStr objectForKey:@"val1"],currentUnit,[tmpStr objectForKey:@"val2"],currentUnit];
                }
                
                CGSize labelsize = [self sizeWithString:aStr font:[UIFont systemFontOfSize:14]];
                lblInfo.frame = CGRectMake(SCREEN_WIDTH - 30 - labelsize.width, 0.0, labelsize.width, 70 );
                
                lblInfo.text = aStr;
                
                UIButton *btnDel = [[UIButton alloc]initWithFrame:CGRectMake(SCREEN_WIDTH - 30 - labelsize.width - 35, 20, 30, 30)];
                [btnDel setImage:[UIImage imageNamed:@"btn_del"] forState:UIControlStateNormal];
                [btnDel addTarget:self action:@selector(delSelected:) forControlEvents:UIControlEventTouchUpInside];
                btnDel.tag = indexPath.section;
                [cell.contentView addSubview:btnDel];
                
            }
        }else{
            if ([tmpStr objectForKey:@"hour"] == nil) {
                lblInfo.text = @"空";
            }else{
                
                NSString *aStr = [NSString stringWithFormat:@"每天：%@点%@分",[tmpStr objectForKey:@"hour"],[tmpStr objectForKey:@"minute"]];
                if (self.pushType == 1) {
                    aStr = [NSString stringWithFormat:@"每月：%@号%@点%@分",[tmpStr objectForKey:@"day"],[tmpStr objectForKey:@"hour"],[tmpStr objectForKey:@"minute"]];
                }
                
                CGSize labelsize = [self sizeWithString:aStr font:[UIFont systemFontOfSize:14]];
                lblInfo.frame = CGRectMake(SCREEN_WIDTH - 30 - labelsize.width, 0.0, labelsize.width, 70 );
                
                lblInfo.text = aStr;
                
                UIButton *btnDel = [[UIButton alloc]initWithFrame:CGRectMake(SCREEN_WIDTH - 30 - labelsize.width - 35, 20, 30, 30)];
                [btnDel setImage:[UIImage imageNamed:@"btn_del"] forState:UIControlStateNormal];
                [btnDel addTarget:self action:@selector(delSelected:) forControlEvents:UIControlEventTouchUpInside];
                btnDel.tag = indexPath.section;
                [cell.contentView addSubview:btnDel];
                
            }
        }
        
    }else{
        lblInfo.text = @"空";
    }
    
    
    [cell.contentView addSubview:lblInfo];
    
    UIView  *lineView = [[UIView alloc]initWithFrame:CGRectMake(0, 69, SCREEN_WIDTH, 1)];
    lineView.backgroundColor = MT_LINE_COLOR;
    UIView  *lineView1 = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 1)];
    lineView1.backgroundColor = MT_LINE_COLOR;
    [cell.contentView addSubview:lineView];
    [cell.contentView addSubview:lineView1];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0 || indexPath.section == 1) {
        ParameterListViewController *plvc = [[ParameterListViewController alloc] initWithNibName:@"ParameterListViewController" bundle:nil];
        plvc.selectTid = self.tid;
        plvc.delegate = self;
        switch (indexPath.section) {
            case 0:
                plvc.currentType = ParameterTypeWeiDuPush;// 维度
                plvc.defDict     = [selectDict objectForKey:@"dict0"];
                break;
            case 1:
                plvc.currentType = ParameterTypeDuliang;// 行标签
                plvc.defDict     = [selectDict objectForKey:@"dict1"];
                break;
            default:
                break;
        }
        [self.navigationController pushViewController:plvc animated:true];
    }
    
    if (indexPath.section == 2) {
        NSDictionary *tmpStr = [selectDict objectForKey:@"dict1"];
        if (tmpStr == nil) {
            [[RGHudModular getRGHud]showAutoHudWithMessageDefault:@"请先选择度量"];
            return;
        }
        PushFilterViewController *pfvc = [[PushFilterViewController alloc]initWithNibName:@"PushFilterViewController" bundle:nil];
        pfvc.cunit = currentUnit;
        pfvc.duliang = [tmpStr objectForKey:@"text"];
        NSDictionary *tmpStr2 = [selectDict objectForKey:@"dict2"];
        if (tmpStr2 != nil) {
            pfvc.defDict = tmpStr2;
        }
        pfvc.block = ^(NSDictionary *aDict){
            [selectDict setObject:aDict forKey:@"dict2"];
            [self.myTableView reloadData];
        };
        [self.navigationController pushViewController:pfvc animated:true];
    }
    
    if (indexPath.section == 3) {
        PushDateSetViewController *pdsvc = [[PushDateSetViewController alloc]initWithNibName:@"PushDateSetViewController" bundle:nil];
        pdsvc.pushType = self.pushType;
        NSDictionary *tmpStr = [selectDict objectForKey:@"dict3"];
        if (tmpStr != nil) {
            pdsvc.defDict = tmpStr;
        }
        pdsvc.block = ^(NSDictionary *aDict){
            [selectDict setObject:aDict forKey:@"dict3"];
            [self.myTableView reloadData];
        };
        [self.navigationController pushViewController:pdsvc animated:true];
    }
}

/***********************************************************************
 * 方法名称：- (void)didSelectDict:(NSDictionary *)tDict pType:(ParameterType)pType
 * 功能描述： 代理方法选择了某个参数
 * 输入参数：
 * 输出参数：
 * 返 回 值：
 ***********************************************************************/
-(void)didSelectDict:(NSDictionary *)tDict pType:(ParameterType)pType
{
    switch (pType) {
    
        case ParameterTypeWeiDuPush:
            [selectDict setObject:tDict forKey:@"dict0"];// 行标签
            break;
        case ParameterTypeDuliang:
            currentUnit = [tDict objectForKey:@"unit"];
            [selectDict setObject:tDict forKey:@"dict1"];// 度量
            break;
        default:
            break;
    }
    
    [myTableView reloadData];
}

/***********************************************************************
 * 方法名称：- (void)delSelected:(UIButton *)sender
 * 功能描述： // 删除已选的参数
 * 输入参数：
 * 输出参数：
 * 返 回 值：
 ***********************************************************************/
- (void)delSelected:(UIButton *)sender
{
    [selectDict removeObjectForKey:[NSString stringWithFormat:@"dict%d",(int)sender.tag]];
    if (sender.tag == 1) {
        [selectDict removeObjectForKey:[NSString stringWithFormat:@"dict%d",2]];
    }
    [myTableView reloadData];
}

/***********************************************************************
 * 方法名称： - (CGSize)sizeWithString:(NSString *)string font:(UIFont *)font
 * 功能描述： 定义成方法方便多个label调用 增加代码的复用性
 * 输入参数：
 * 输出参数：
 * 返 回 值：
 ***********************************************************************/
- (CGSize)sizeWithString:(NSString *)string font:(UIFont *)font
{
    CGRect rect = [string boundingRectWithSize:CGSizeMake(SCREEN_WIDTH - 150, 30)//限制最大的宽度和高度
                                       options:NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesFontLeading  |NSStringDrawingUsesLineFragmentOrigin//采用换行模式
                                    attributes:@{NSFontAttributeName: font}//传人的字体字典
                                       context:nil];
    
    return rect.size;
}

/***********************************************************************
 * 方法名称：clickSave
 * 功能描述： // 保存选择项
 * 输入参数：
 * 输出参数：
 * 返 回 值：
 ***********************************************************************/
- (void)clickSave
{
    if (![Common isBlankString:saveID]) {
        
        [self clickDoneWithName:saveName];
        
        return;
    }
    KLCPopupLayout layout = KLCPopupLayoutMake(KLCPopupHorizontalLayoutCenter, KLCPopupVerticalLayoutCenter);
    StoreConfigPopView *scpv = [[StoreConfigPopView alloc]initWithDelegate:self];
    KLCPopup *popup = [KLCPopup popupWithContentView:scpv
                                            showType:KLCPopupShowTypeSlideInFromTop
                                         dismissType:KLCPopupDismissTypeSlideOutToBottom
                                            maskType:KLCPopupMaskTypeDimmed
                            dismissOnBackgroundTouch:YES
                               dismissOnContentTouch:NO];
    [popup showWithLayout:layout];
    
    
}

/***********************************************************************
 * 方法名称：- (void)clickDoneWithName:(NSString *)name
 * 功能描述： 确定代理事件
 * 输入参数：
 * 输出参数：
 * 返 回 值：
 ***********************************************************************/
- (void)clickDoneWithName:(NSString *)name
{
    NSDictionary *kpiDict = [selectDict objectForKey:@"dict1"];
    if (kpiDict == nil) {
        [[RGHudModular getRGHud]showAutoHudWithMessageDefault:@"您至少需要配置一个度量"];
        [self.view dismissPresentingPopup];
        return;
    }
    // 推送时间设置
    if ([selectDict objectForKey:@"dict3"] == nil ) {
        [[RGHudModular getRGHud]showAutoHudWithMessageDefault:@"推送时间不能为空"];
        [self.view dismissPresentingPopup];
        return;
    }
    saveName = name;
    AFHTTPRequestOperationManager   *manager    = [AFHTTPRequestOperationManager manager];
    //    manager.requestSerializer  = [AFJSONRequestSerializer serializer];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    NSMutableDictionary     *parameters =[NSMutableDictionary dictionaryWithCapacity:2];
    // 组合pageInfo字符串
    NSMutableDictionary * pageInfo = [NSMutableDictionary dictionaryWithCapacity:2];
    [pageInfo setObject:self.tid forKey:@"tid"];
    [pageInfo setObject:@"day" forKey:@"pushType"];
    if (self.pushType == 1) {
        [pageInfo setObject:@"month" forKey:@"pushType"];
    }
    //维度配置
    if ([selectDict objectForKey:@"dict0"] != nil) {
        NSMutableDictionary *dim = [NSMutableDictionary dictionaryWithDictionary:[selectDict objectForKey:@"dict0"]];
        if ([dim objectForKey:@"dim_type"] != nil) {
            [dim setObject:[dim objectForKey:@"dim_type"] forKey:@"type"];
        }
        if ([dim objectForKey:@"col_name"] != nil) {
            [dim setObject:[dim objectForKey:@"col_name"] forKey:@"colname"];
        }
        if ([dim objectForKey:@"text"] != nil) {
            [dim setObject:[dim objectForKey:@"text"] forKey:@"dimdesc"];
        }
        [pageInfo setObject:dim forKey:@"dim"];
    }
    
    //kpi
    NSMutableDictionary *kpiJson = [NSMutableDictionary dictionaryWithDictionary:kpiDict];
    NSString *kpi_id = [kpiJson objectForKey:@"col_id"];
    NSString *kpi_name = [kpiJson objectForKey:@"text"];
    [kpiJson setObject:kpi_id forKey:@"kpi_id"];
    [kpiJson setObject:kpi_name forKey:@"kpi_name"];
    if ([selectDict objectForKey:@"dict2"] != nil) {
        NSDictionary *sxDict = [selectDict objectForKey:@"dict2"];
        if (sxDict.allKeys.count != 0) {
            [kpiJson setObject:[sxDict objectForKey:@"opt"] forKey:@"opt"];
            if ([[sxDict objectForKey:@"opt"] isEqualToString:@"between"]) {
                [kpiJson setObject:[sxDict objectForKey:@"val1"] forKey:@"val1"];
                [kpiJson setObject:[sxDict objectForKey:@"val2"] forKey:@"val2"];
            }else{
                [kpiJson setObject:[sxDict objectForKey:@"val1"] forKey:@"val1"];
            }
        }
    }
    
    if ([selectDict objectForKey:@"dict3"] != nil ) {
        [pageInfo setObject:[selectDict objectForKey:@"dict3"] forKey:@"job"];
    }
    [pageInfo setObject:@[kpiJson] forKey:@"kpiJson"];
    NSLog(@"---传入-%@",[pageInfo JSONString]);
    NSString *urlString = WEB_SERVICE_PUSHSAVE([Common GetServiceHost]);
    if (![Common isBlankString:saveID]) {
        urlString = WEB_SERVICE_PUSHUPDATE([Common GetServiceHost]);
        [parameters setObject:saveID forKey:@"id"];
    }
    
    [parameters setObject:[Common shareInstence].token forKey:@"token"];
    [parameters setObject:name forKey:@"pageName"];
    [parameters setObject:[pageInfo JSONString] forKey:@"pageInfo"];
    
    [manager POST:urlString parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        [[RGHudModular getRGHud] showAutoHudWithMessageDefault:@"保存成功"];
        NSLog(@"保存返回值----- %@",responseObject);
        [self.view dismissPresentingPopup];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        // 判断token是否可用
        NSString *errStr = operation.responseString;
        
        NSLog(@"----得到的errstr%@",errStr);
        if (![Common isBlankString:errStr]&& [errStr isEqualToString:@"\r\n{error:'用户未登录。'}"]) {
            [[RGHudModular getRGHud] showAutoHudWithMessageDefault:@"用户登录失效,请重新登录"];
            [Common shareInstence].isLogin = NO;
            [self.navigationController popToRootViewControllerAnimated:false];
            return ;
        }
        
        if (errStr.integerValue != 0) {
            saveID = [NSString stringWithFormat:@"%@",errStr];
            [[RGHudModular getRGHud] showAutoHudWithMessageDefault:@"保存成功"];
            [self backToListView];
        }else{
            [[RGHudModular getRGHud] showAutoHudWithMessageDefault:@"网络错误"];
        }
        
    }];
}

// 返回列表页面
-(void)backToListView
{
    NSArray *controlls = self.navigationController.viewControllers;
    if (controlls.count != 0 ) {
        for (int i = (int)controlls.count - 1; i>=0; i--) {
            UIViewController *tmpControl = controlls[i];
            if ([tmpControl isKindOfClass:[DataPushViewController class]]) {
                DataPushViewController *dpvc = (DataPushViewController *)tmpControl;
                [dpvc reloadMyTable];
                NSLog(@"此时应该跳转");
                [self.navigationController popToViewController:dpvc animated:YES];
                break;
            }
        }
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
