//
//  MessageDetailViewController.m
//  Pivot
//
//  Created by djh on 16/5/24.
//  Copyright © 2016年 bos. All rights reserved.
//

#import "MessageDetailViewController.h"
#import "JSONKit.h"
#import "HeadView.h"
#import "TimeView.h"
#import "MyCell.h"

@interface MessageDetailViewController ()<UITableViewDataSource,UITableViewDelegate,TimeViewDelegate>

@property (nonatomic,strong) UIView *myHeadView;
@property (nonatomic,strong) UITableView *myTableView;
@property (nonatomic,strong) TimeView *timeView;

@end

@implementation MessageDetailViewController
@synthesize dataArray;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
     
    [self initTableView];
    [self.myTableView reloadData];
    self.navigationItem.title = @"消息详细";
    UILabel *titleLbl = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 45)];
    titleLbl.text = self.titleStr;
    titleLbl.font = [UIFont systemFontOfSize:15];
    titleLbl.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:titleLbl];
    
    UILabel *lblTime = [[UILabel alloc]initWithFrame:CGRectMake(10, 45, 250, 20)];
    lblTime.text = [NSString stringWithFormat:@"推送时间：%@",self.pushTime] ;
    lblTime.textColor = [UIColor lightGrayColor];
    lblTime.font = [UIFont systemFontOfSize:13];
    [self.view addSubview:lblTime];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)initTableView
{
    float marginTop = 65;
    float headerHeight = 40;
    
    NSArray *contentArr = dataArray.firstObject;
    
    if (contentArr.count == 0) {
        return;
    }
    
    UIView *tableViewHeadView=[[UIView alloc]initWithFrame:CGRectMake(0, marginTop, (contentArr.count-1)*kWidth, headerHeight)];
    self.myHeadView=tableViewHeadView;
    NSString *tmpTitle = @"";
    NSArray *arr = dataArray.firstObject;
    
    tmpTitle = arr.firstObject;
    
    for (int j=1; j<arr.count; j++) {
        NSString *ttDict = [arr objectAtIndex:j];
        
        HeadView *headView=[[HeadView alloc]initWithFrame:CGRectMake((j-1)*kWidth,0, kWidth, headerHeight)];
        
        headView.detail=ttDict;
        headView.backgroundColor = [UIColor colorWithRed:239/255.0 green:239/255.0 blue:239/255.0 alpha:1];
        
        [tableViewHeadView addSubview:headView];
        
    }
    
    UITableView *tableView=[[UITableView alloc]initWithFrame:CGRectMake(0, 0, self.myHeadView.frame.size.width, SCREEN_HEIGHT - 65 - marginTop) style:UITableViewStylePlain];
    tableView.delegate=self;
    tableView.dataSource=self;
    tableView.bounces=NO;
    tableView.backgroundColor = [UIColor clearColor];
    tableView.separatorStyle=UITableViewCellSeparatorStyleNone;
    self.myTableView=tableView;
    
    UIScrollView *myScrollView=[[UIScrollView alloc]initWithFrame:CGRectMake(kWidth, marginTop, SCREEN_WIDTH-kWidth, SCREEN_HEIGHT -  20)];
    [myScrollView addSubview:tableView];
    myScrollView.backgroundColor = [UIColor clearColor];
    myScrollView.bounces=NO;
    myScrollView.contentSize=CGSizeMake(self.myHeadView.frame.size.width,0);
    [self.view addSubview:myScrollView];
    NSMutableArray *timeArr = [NSMutableArray arrayWithArray:dataArray];
    [timeArr removeObjectAtIndex:0];
    
    self.timeView =[[TimeView alloc]initWithFrame:CGRectMake(0, headerHeight + marginTop, kWidth, SCREEN_HEIGHT-104) marginTop:0 dataArray:timeArr];
    self.timeView.delegate = self;
    self.timeView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:self.timeView];
    
    HeadView *headView=[[HeadView alloc]initWithFrame:CGRectMake(0, marginTop, kWidth, headerHeight)];
    ;
    headView.detail=tmpTitle;
    headView.backgroundColor = [UIColor colorWithRed:239/255.0 green:239/255.0 blue:239/255.0 alpha:1];
    [self.view  addSubview:headView];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return dataArray.count - 1;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier=@"msgcell";
    
    MyCell *cell=[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    NSMutableArray *ttArray = [NSMutableArray arrayWithArray:dataArray];
    [ttArray removeObjectAtIndex:0];
    
    NSMutableArray *arrTmp = [NSMutableArray arrayWithArray:ttArray[indexPath.row]];
    if(cell==nil){
        
        cell=[[MyCell alloc]initCellWithCount:(int)arrTmp.count-1];
        
        cell.selectionStyle=UITableViewCellSelectionStyleNone;
        
        cell.backgroundColor = [UIColor clearColor];
        
    }
    
    [arrTmp removeObjectAtIndex:0];
    [cell setMsgCellArray:arrTmp];
    
    cell.index = (int)indexPath.row;
    
    return cell;
}
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    
    return self.myHeadView;
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    
    return 40;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return kHeight;
}
-(void)myHeadView:(HeadView *)headView point:(CGPoint)point
{
    
}
-(void)timeViewDidScroll:(CGPoint)offset
{
    CGPoint tmpOffset = self.myTableView.contentOffset;
    tmpOffset.y = offset.y;
    
    self.myTableView.contentOffset = tmpOffset;
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat offsetY= self.myTableView.contentOffset.y;
    CGPoint timeOffsetY=self.timeView.timeTableView.contentOffset;
    timeOffsetY.y=offsetY;
    self.timeView.timeTableView.contentOffset=timeOffsetY;
    if(offsetY==0){
        self.timeView.timeTableView.contentOffset=CGPointZero;
    }
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
