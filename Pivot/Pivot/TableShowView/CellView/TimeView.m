//
//  TimeView.m
//  表格
//
//  Created by zzy on 14-5-6.
//  Copyright (c) 2014年 zzy. All rights reserved.
//
#define kCount 20
#import "TimeView.h"
#import "MyLabel.h"
#import "TimeCell.h"

@interface TimeView()<UITableViewDataSource,UITableViewDelegate>
{
    CGFloat top;
    NSArray *dataArray;
}
@property (nonatomic,strong) NSMutableArray *times;
@end

@implementation TimeView

- (id)initWithFrame:(CGRect)frame marginTop:(CGFloat)marginTop dataArray:(NSMutableArray *)arr
{
    self = [super initWithFrame:frame];
    if (self) {
      
//        for(int i=0;i<20;i++){
// 
//            MyLabel *timeLabel=[[MyLabel alloc]initWithFrame:CGRectMake(0, i*(kHeight+kHeightMargin), kWidth, (kHeight+kHeightMargin))];
////            timeLabel.backgroundColor=[UIColor yellowColor];
//            [timeLabel setVerticalAlignment:VerticalAlignmentTop];
//            timeLabel.textAlignment=NSTextAlignmentRight;
//            int currentTime=i*30+510;
//            timeLabel.text=[NSString stringWithFormat:@"%d:%02d",currentTime/60,currentTime%60];
//            [self addSubview:timeLabel];
//        
//        }
        dataArray = [NSArray arrayWithArray:arr];
       
        top = marginTop;
         self.timeTableView=[[UITableView alloc]initWithFrame:CGRectMake(0, 0, frame.size.width,frame.size.height) style:UITableViewStylePlain];
         self.timeTableView.delegate=self;
         self.timeTableView.dataSource=self;
         self.timeTableView.separatorStyle=UITableViewCellSeparatorStyleNone;
         self.timeTableView.bounces = NO;
        self.timeTableView.showsVerticalScrollIndicator = NO;
        self.timeTableView.backgroundColor = [UIColor clearColor];
        [self addSubview: self.timeTableView];
        
    }
    return self;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (self.delegate) {
        [self.delegate timeViewDidScroll:scrollView.contentOffset];
    }
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return dataArray.count;
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    
    return top;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return kHeight;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier=@"cell2";
    TimeCell *cell=[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if(cell==nil){
        
        cell=[[TimeCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    NSArray *arrTmp = [dataArray objectAtIndex:indexPath.row];
    if (![arrTmp.firstObject isKindOfClass:[NSDictionary class]]) {
        cell.timeLabel.detail= arrTmp.firstObject;
//        if([arrTmp.firstObject isKindOfClass:[NSNumber class]]) {
//            cell.timeLabel.numRoom.textAlignment = NSTextAlignmentRight;
//        }else{
//            cell.timeLabel.numRoom.textAlignment = NSTextAlignmentLeft;
//        }
        
        return cell;
    }
    NSString *type = [arrTmp.firstObject objectForKey:@"type"];
    cell.timeLabel.detail=[arrTmp.firstObject objectForKey:@"value"];
    if(type.intValue == 1) {
        cell.timeLabel.numRoom.textAlignment = NSTextAlignmentRight;
    }else{
        cell.timeLabel.numRoom.textAlignment = NSTextAlignmentLeft;
    }
    return cell;
}
@end
