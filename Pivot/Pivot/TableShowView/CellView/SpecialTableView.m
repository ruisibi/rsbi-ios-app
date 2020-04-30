//
//  SpecialTableView.m
//  Custom
//
//  Created by tan on 13-1-22.
//  Copyright (c) 2013年 adways. All rights reserved.
//


#import "SpecialTableView.h"


#define TitleWidth 100
#define RightTitleHeight 30
#define RightBottomTitleHeight 30

@implementation SpecialTableView

@synthesize leftScrollView = _leftScrollView;
@synthesize leftTableView = _leftTableView;
@synthesize rightScrollView = _rightScrollView;
@synthesize rightTableView = _rightTableView;
@synthesize dataArray = _dataArray;
@synthesize trDictionary = _trDictionary;
@synthesize leftDataKeys = _leftDataKeys;
@synthesize rightDataKeys = _rightDataKeys;
@synthesize currentYM;
-(void)reloadData:(NSArray *)dArray trDictionary:(NSDictionary *)trDict leftDataKeys:(NSArray *)leftDataKeys rightDataKeys:(NSArray *)rightDataKeys{
    self.dataArray = [NSArray arrayWithArray:dArray];
    self.trDictionary = [NSDictionary dictionaryWithDictionary:trDict];
    self.leftDataKeys = [NSArray arrayWithArray:leftDataKeys];
    self.rightDataKeys = [NSArray arrayWithArray:rightDataKeys];
    _leftTableView.delegate = self;
    _leftTableView.dataSource = self;
    _rightTableView.delegate=self;
    _rightTableView.delegate=self;
    [_leftTableView reloadData];
    [_rightTableView reloadData];
    
}
- (id)initWithData:(NSArray *)dArray trDictionary:(NSDictionary *)trDict size:(CGSize)size scrollMethod:(ScrollMethod)sm leftDataKeys:(NSArray *)leftDataKeys rightDataKeys:(NSArray *)rightDataKeys {
    if (self = [super initWithFrame:CGRectMake(0, 0, size.width, size.height)]) {
        //data
        self.dataArray = [NSArray arrayWithArray:dArray];
        self.trDictionary = [NSDictionary dictionaryWithDictionary:trDict];
        self.leftDataKeys = [NSArray arrayWithArray:leftDataKeys];
        self.rightDataKeys = [NSArray arrayWithArray:rightDataKeys];
        
        float leftWidth = 0;//左边tableview的宽度
        float rightWidth = 0;//右边tableview的宽度
        for (NSString *trKey in _leftDataKeys) {
            float trWidth = [[trDict objectForKey:trKey] floatValue];
            leftWidth += trWidth;
        }
        for (NSString *trKey in _rightDataKeys) {
            float trWidth = [[trDict objectForKey:trKey] floatValue];
            rightWidth += trWidth;
        }
        
        //scrollview
        float leftScrollWidth = 0;
        float rightScrollWidth = 0;
        @try {
            if (sm == kScrollMethodWithLeft) {
                if (rightWidth > size.width) {
                    @throw [NSException exceptionWithName:@"width small" reason:@"" userInfo:nil];
                }
                rightScrollWidth = rightWidth;
                leftScrollWidth = size.width - rightScrollWidth;
            } else if (sm == kScrollMethodWithRight) {
                if (leftWidth > size.width) {
                    @throw [NSException exceptionWithName:@"width small" reason:@"" userInfo:nil];
                }
                leftScrollWidth = leftWidth;
                rightScrollWidth = size.width - leftScrollWidth;
            } else {
                leftScrollWidth = rightScrollWidth = size.width / 2.0;
            }
        }
        @catch (NSException *exception) {
//            NSLog(@"ERROR:%@", exception.name);
            NSAssert(false, @"width small");
        }
    
        UIScrollView *leftScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, leftScrollWidth, 250)];
        [leftScrollView setShowsHorizontalScrollIndicator:FALSE];
        [leftScrollView setShowsVerticalScrollIndicator:FALSE];
        
        self.leftScrollView = leftScrollView;
//        [leftScrollView release];
        
        UIScrollView *rightScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(leftScrollWidth, 0, rightScrollWidth,250)];
        [rightScrollView setShowsHorizontalScrollIndicator:FALSE];
        [rightScrollView setShowsVerticalScrollIndicator:FALSE];
        self.rightScrollView = rightScrollView;
//        [rightScrollView release];
        
        //tableView
        UITableView *leftTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, leftWidth, size.height)];
        leftTableView.delegate = self;
        leftTableView.dataSource = self;
        [leftTableView setShowsHorizontalScrollIndicator:NO];
        [leftTableView setShowsVerticalScrollIndicator:NO];
        self.leftTableView = leftTableView;
//        [leftTableView release];
        
        UITableView *rightTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, rightWidth, size.height)];
        rightTableView.delegate = self;
        rightTableView.dataSource = self;
        [rightTableView setShowsHorizontalScrollIndicator:NO];
        [rightTableView setShowsVerticalScrollIndicator:NO];
        self.rightTableView = rightTableView;
//        [rightTableView release];
        
        [self.leftScrollView addSubview:_leftTableView];
        [self.rightScrollView addSubview:_rightTableView];
        [self.leftScrollView setContentSize:_leftTableView.frame.size];
        [self.rightScrollView setContentSize:_rightTableView.frame.size];
//        self.leftScrollView.contentSize=CGSizeMake(leftScrollWidth, 0);
//        self.rightScrollView.contentSize=CGSizeMake(leftScrollWidth, 0);
        self.leftScrollView.alwaysBounceVertical = NO;
        self.rightScrollView.alwaysBounceVertical = NO;
        [self addSubview:_leftScrollView];
        [self addSubview:_rightScrollView];
    }
    return self;
}

#pragma mark - Custom TableView Content

- (UIView *)viewWithLeftContent:(NSInteger)index {
//    NSLog(@"%s",__FUNCTION__);
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _leftTableView.frame.size.width, kTableViewCellHeight)] ;
    NSDictionary *rowDict = [_dataArray objectAtIndex:index];
    @try {
        float x=0;
        for (NSString *key in _leftDataKeys) {
            float width = [[_trDictionary objectForKey:key] floatValue];
            NSString *value = [rowDict objectForKey:key];
            UIImageView *imgTagert1= [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 1, 26) ];
            imgTagert1.image=[UIImage imageNamed:@"suxian.png"];
            UIImageView *imgTagert2= [[UIImageView alloc]initWithFrame:CGRectMake(59, 0, 1, 26) ];
            imgTagert2.image=[UIImage imageNamed:@"suxian.png"];
// TODO: 初始化内部label 可以自定义
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(x, 0, width, kTableViewCellHeight)];
            label.contentMode = UIViewContentModeCenter;
            label.textAlignment = NSTextAlignmentCenter;
            label.text = value;
            label.font = [UIFont systemFontOfSize:13.0];
            if (index%2==0) {
                label.backgroundColor=[UIColor colorWithRed:239/255.0 green:239/255.0 blue:239/255.0 alpha:1];
            }
            [view addSubview:label];
            
            UIImageView *imgTagert= [[UIImageView alloc]initWithFrame:CGRectMake(0, 26, 160, 1) ];
            imgTagert.image=[UIImage imageNamed:@"hengLine.png"];
            [view addSubview:imgTagert];
            
            
            UIImageView *imgTagert3= [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 160, 1) ];
            imgTagert3.image=[UIImage imageNamed:@"hengLine.png"];
            [view addSubview:imgTagert3];
            
            [view addSubview:imgTagert1];
            [view addSubview:imgTagert2];
//            [view addSubview:imgTagert3];
//            [label release];
            
            x += width;
        }
    }
    @catch (NSException *exception) {
        
    }
    return view;
}

- (UIView *)viewWithRightContent:(NSInteger)index {
//    NSLog(@"%s",__FUNCTION__);
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _rightTableView.frame.size.width, kTableViewCellHeight)] ;
    NSDictionary *rowDict = [_dataArray objectAtIndex:index];
    @try {
        float x=0;
        for (NSString *key in _rightDataKeys) {
            float width = [[_trDictionary objectForKey:key] floatValue];
            NSString *value = [rowDict objectForKey:key];
            
// TODO: 初始化内部label 可以自定义
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(x, 0, width, kTableViewCellHeight)];
            label.contentMode = UIViewContentModeCenter;
            label.textAlignment = NSTextAlignmentCenter;
            label.text = value;
            label.font = [UIFont systemFontOfSize:13.0];
            if (index%2==0) {
                 label.backgroundColor=[UIColor colorWithRed:239/255.0 green:239/255.0 blue:239/255.0 alpha:1];
            }
           
            
            UIImageView *imgTagert1= [[UIImageView alloc]initWithFrame:CGRectMake(1299, 0, 1, 26) ];
            imgTagert1.image=[UIImage imageNamed:@"suxian.png"];
            UIImageView *imgTagert2= [[UIImageView alloc]initWithFrame:CGRectMake(0, 179, 2200, 1) ];
            imgTagert2.image=[UIImage imageNamed:@"hengLine.png"];
            [view addSubview:label];
            for (int i=0; i<25; i++) {
                UIImageView *imgTagert3= [[UIImageView alloc]initWithFrame:CGRectMake(i*100, 0, 1, 26) ];
                imgTagert3.image=[UIImage imageNamed:@"suxian.png"];
                  [view addSubview:imgTagert3];
            }
            
             //NSLog(@"index1 == %d",index);
            UIImageView *imgTagert= [[UIImageView alloc]initWithFrame:CGRectMake(0, 26,2200, 1) ];
            imgTagert.image=[UIImage imageNamed:@"hengLine.png"];
            [view addSubview:imgTagert];
            
            UIImageView *imgTagert4= [[UIImageView alloc]initWithFrame:CGRectMake(0, 0,2200, 1) ];
            imgTagert4.image=[UIImage imageNamed:@"hengLine.png"];
            [view addSubview:imgTagert4];
//            for (int i=0; i<_dataArray.count; i++) {
          
//            }
            [view addSubview:imgTagert1];
//            [view addSubview:imgTagert2];
//            [view addSubview:imgTagert3];
//            [label release];
            
            x += width;
        }
    }
    @catch (NSException *exception) {
        
    }
  
//    UIImageView *imgTagert= [[UIImageView alloc]initWithFrame:CGRectMake(0, 26*index, 2200, 1) ];
//    imgTagert.image=[UIImage imageNamed:@"hengLine.png"];
//    [view addSubview:imgTagert];
    
    return view;
}

#pragma mark - TableView DataSource Methods

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    static NSString *SimpleTableIdentifier = @"SimpleTableIdentifier";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:SimpleTableIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                       reuseIdentifier: SimpleTableIdentifier];
    }
    UIView *view;
//    [tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
   
    if ([tableView isEqual:_leftTableView]) {
        view = [self viewWithLeftContent:indexPath.row];
        
    } else {
        view = [self viewWithRightContent:indexPath.row];
    }
    
   
//    NSLog(@"size ：%f",view.size.width);
    
    while ([cell.contentView.subviews lastObject] != nil) {
        [(UIView*)[cell.contentView.subviews lastObject] removeFromSuperview];
    }
    cell.selectionStyle = NO;
//    NSLog(@"重绘了cell  %d",indexPath.row);
//    tableView.separatorStyle = NO;
//    UIImageView *bgImageView= [[UIImageView alloc]initWithFrame:CGRectMake(0, 26*indexPath.row, 2200, 1) ];
//     cell.backgroundColor=[UIColor colorWithPatternImage:[UIImage imageNamed:@"hengLine.png"]];
//    bgImageView.image=[UIImage imageNamed:@"hengLine.png"];
//    cell.backgroundView=bgImageView;
//    [cell.contentView addSubview:bgImageView];
    [cell.contentView addSubview:view];
    CGRect frame = cell.frame;
    frame.size = view.frame.size;
    cell.frame = frame;
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _dataArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 60;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
//      [tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    tableView.separatorStyle = NO;
    if ([tableView isEqual:_leftTableView]) {
        if (section == 0)
        {
            UIView* header = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 100, 60)];
            header.backgroundColor = [UIColor whiteColor];
            UILabel* productLineLbl = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 60, 60)];

            productLineLbl.textColor=[UIColor whiteColor];
            productLineLbl.text = @"生产线";
            productLineLbl.numberOfLines = [productLineLbl.text length];
            productLineLbl.textAlignment = NSTextAlignmentCenter;
            productLineLbl.backgroundColor=[UIColor colorWithRed:95/255.0 green:156/255.0 blue:200/255.0 alpha:1];
            
            [header addSubview:productLineLbl];
           
            return header;
        }
        else
        {
            return nil;
        }
    }
    else {
        if (section == 0)
        {
            UIView* header = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 800, 30)];
            header.backgroundColor = [UIColor colorWithRed:223/255.0 green:248/255.0 blue:255/255.0 alpha:1];
            
//            //月份
//            UILabel* lastMonthLbl = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 9*TitleWidth, RightTitleHeight)];
//            lastMonthLbl.text = [WordLocalization getWordByKey:@"qianyue"];
//            lastMonthLbl.textColor=[UIColor colorWithRed:64/255.0 green:170/255.0 blue:254/255.0 alpha:1];
//            lastMonthLbl.textAlignment = NSTextAlignmentCenter;
//            lastMonthLbl.backgroundColor = [UIColor colorWithRed:223/255.0 green:248/255.0 blue:255/255.0 alpha:1];
        
//            UILabel* thisMonthLbl = [[UILabel alloc] initWithFrame:CGRectMake(9*TitleWidth, 0, 11*TitleWidth, RightTitleHeight)];
           UILabel* thisMonthLbl = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 11*TitleWidth, RightTitleHeight)];
            //当月
//            NSLog(@"当前月份：%@",currentYM);
//            thisMonthLbl.text = [WordLocalization getWordByKey:@"dangyue"];
//            if([[WordLocalization getWordCNJP] isEqualToString:@"CN"]){
//            thisMonthLbl.text = [NSString stringWithFormat:@"%@年%@月%@日为止的累计值",[currentYM substringToIndex:4], [[currentYM substringToIndex:6] substringFromIndex:4],[currentYM substringFromIndex:6]];
//            }else{
//            thisMonthLbl.text = [NSString stringWithFormat:@"%@年%@月%@日までの累積値",[currentYM substringToIndex:4], [[currentYM substringToIndex:6] substringFromIndex:4],[currentYM substringFromIndex:6]];
//            }
            
            
            thisMonthLbl.textColor=[UIColor colorWithRed:64/255.0 green:170/255.0 blue:254/255.0 alpha:1];
            thisMonthLbl.textAlignment = NSTextAlignmentCenter;
            
            UILabel* nextMonthLbl = [[UILabel alloc] initWithFrame:CGRectMake(11*TitleWidth, 0, TitleWidth, RightTitleHeight)];
            nextMonthLbl.text = @"下月";
                  nextMonthLbl.textColor=[UIColor colorWithRed:64/255.0 green:170/255.0 blue:254/255.0 alpha:1];
            nextMonthLbl.textAlignment = NSTextAlignmentCenter;
            UILabel* nextNextMonthLbl = [[UILabel alloc] initWithFrame:CGRectMake(12*TitleWidth, 0, TitleWidth, RightTitleHeight)];
            nextNextMonthLbl.text = @"下下月";
            nextNextMonthLbl.textColor=[UIColor colorWithRed:64/255.0 green:170/255.0 blue:254/255.0 alpha:1];
            nextNextMonthLbl.textAlignment = NSTextAlignmentCenter;
            //添加分割线
            UIImageView *imgTagert1= [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 1, RightTitleHeight) ];
            imgTagert1.image=[UIImage imageNamed:@"suxian.png"];
            UIImageView *imgTagert2= [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 2500, 1) ];
            imgTagert2.image=[UIImage imageNamed:@"hengLine.png"];
            UIImageView *imgTagert3= [[UIImageView alloc]initWithFrame:CGRectMake(0, RightTitleHeight-1, 2500, 1) ];
            imgTagert3.image=[UIImage imageNamed:@"hengLine.png"];
            UIImageView *imgTagert4= [[UIImageView alloc]initWithFrame:CGRectMake(1100,0, 1, RightTitleHeight) ];
            imgTagert4.image=[UIImage imageNamed:@"suxian.png"];
            UIImageView *imgTagert5= [[UIImageView alloc]initWithFrame:CGRectMake(1200,0, 1, RightTitleHeight) ];
            imgTagert5.image=[UIImage imageNamed:@"suxian.png"];
            UIImageView *imgTagert6= [[UIImageView alloc]initWithFrame:CGRectMake(1299,0, 1, RightTitleHeight) ];
            imgTagert6.image=[UIImage imageNamed:@"suxian.png"];
//            [header addSubview:lastMonthLbl];
            [header addSubview:thisMonthLbl];
            [header addSubview:nextMonthLbl];
            [header addSubview:nextNextMonthLbl];
            [header addSubview:imgTagert1];
            [header addSubview:imgTagert2];
            [header addSubview:imgTagert3];
            [header addSubview:imgTagert4];
            [header addSubview:imgTagert5];
            [header addSubview:imgTagert6];
            //具体项目
            //上月
            
            //当月
            UILabel* thisSalePlanLbl = [[UILabel alloc] initWithFrame:CGRectMake(0, RightTitleHeight, TitleWidth, RightBottomTitleHeight)];
            thisSalePlanLbl.text = @"单元";
            thisSalePlanLbl.textAlignment = NSTextAlignmentCenter;
            thisSalePlanLbl.backgroundColor = [UIColor whiteColor];
            //            lastSalePlanLbl.backgroundColor =col;
            
            thisSalePlanLbl.font=[UIFont fontWithName:@"Arial" size:15];
            
            [header addSubview:thisSalePlanLbl];
            
            UIImageView *imga= [[UIImageView alloc]initWithFrame:CGRectMake(0,30, 1, 30) ];
            imga.image=[UIImage imageNamed:@"suxian.png"];
            [header addSubview:imga];
            
            
            UILabel* thisNOrderLbl = [[UILabel alloc] initWithFrame:CGRectMake(TitleWidth, RightTitleHeight, TitleWidth, RightBottomTitleHeight)];
            thisNOrderLbl.text = @"xxx";
            thisNOrderLbl.textAlignment = NSTextAlignmentCenter;
            thisNOrderLbl.backgroundColor = [UIColor whiteColor];
            //            lastSalePlanLbl.backgroundColor =col;
            thisNOrderLbl.font=[UIFont fontWithName:@"Arial" size:15];
            //            UIImage *img=[UIImage imageNamed:@"tableHeaderBg.png"];
//            thisNOrderLbl.backgroundColor = [UIColor colorWithPatternImage:img];
           
            [header addSubview:thisNOrderLbl];
            
            UILabel* thisSaleIndeedLbl = [[UILabel alloc] initWithFrame:CGRectMake(2*TitleWidth, RightTitleHeight, TitleWidth, RightBottomTitleHeight)];
            thisSaleIndeedLbl.text = @"xx3";
            thisSaleIndeedLbl.textAlignment = NSTextAlignmentCenter;
            thisSaleIndeedLbl.backgroundColor = [UIColor whiteColor];
            //            lastSalePlanLbl.backgroundColor =col;
            thisSaleIndeedLbl.font=[UIFont fontWithName:@"Arial" size:15];
            //            UIImage *img=[UIImage imageNamed:@"tableHeaderBg.png"];
//            thisSaleIndeedLbl.backgroundColor = [UIColor colorWithPatternImage:img];
            [header addSubview:thisSaleIndeedLbl];

            
            UILabel* thisSaleRateLbl = [[UILabel alloc] initWithFrame:CGRectMake(3*TitleWidth, RightTitleHeight, TitleWidth, RightBottomTitleHeight)];
            thisSaleRateLbl.text = @"xx3";
            thisSaleRateLbl.textAlignment = NSTextAlignmentCenter;
            thisSaleRateLbl.backgroundColor = [UIColor whiteColor];
            //            lastSalePlanLbl.backgroundColor =col;
            thisSaleRateLbl.font=[UIFont fontWithName:@"Arial" size:15];
            //            UIImage *img=[UIImage imageNamed:@"tableHeaderBg.png"];
//            thisSaleRateLbl.backgroundColor = [UIColor colorWithPatternImage:img];
            [header addSubview:thisSaleRateLbl];

            
            UILabel* thisProductPlanLbl = [[UILabel alloc] initWithFrame:CGRectMake(4*TitleWidth, RightTitleHeight, TitleWidth, RightBottomTitleHeight)];
            thisProductPlanLbl.text = @"xx3";
            thisProductPlanLbl.textAlignment = NSTextAlignmentCenter;
            thisProductPlanLbl.backgroundColor = [UIColor whiteColor];
            //            lastSalePlanLbl.backgroundColor =col;
            thisProductPlanLbl.font=[UIFont fontWithName:@"Arial" size:15];
            //            UIImage *img=[UIImage imageNamed:@"tableHeaderBg.png"];
//            thisProductPlanLbl.backgroundColor = [UIColor colorWithPatternImage:img];
            [header addSubview:thisProductPlanLbl];

            
            UILabel* thisProductIndeedLbl = [[UILabel alloc] initWithFrame:CGRectMake(5*TitleWidth, RightTitleHeight, TitleWidth, RightBottomTitleHeight)];
            thisProductIndeedLbl.text = @"xx3";
            thisProductIndeedLbl.textAlignment = NSTextAlignmentCenter;
            thisProductIndeedLbl.backgroundColor = [UIColor whiteColor];
            //            lastSalePlanLbl.backgroundColor =col;
            thisProductIndeedLbl.font=[UIFont fontWithName:@"Arial" size:15];
            //            UIImage *img=[UIImage imageNamed:@"tableHeaderBg.png"];
//            thisProductIndeedLbl.backgroundColor = [UIColor colorWithPatternImage:img];
            [header addSubview:thisProductIndeedLbl];
            
            UILabel* thisProductRateLbl = [[UILabel alloc] initWithFrame:CGRectMake(6*TitleWidth, RightTitleHeight, TitleWidth, RightBottomTitleHeight)];
            thisProductRateLbl.text = @"xx3";
            thisProductRateLbl.textAlignment = NSTextAlignmentCenter;
            thisProductRateLbl.backgroundColor = [UIColor whiteColor];
            //            lastSalePlanLbl.backgroundColor =col;
            thisProductRateLbl.font=[UIFont fontWithName:@"Arial" size:15];
            //            UIImage *img=[UIImage imageNamed:@"tableHeaderBg.png"];
//            thisProductRateLbl.backgroundColor = [UIColor colorWithPatternImage:img];
            [header addSubview:thisProductRateLbl];
            
            UILabel* thisStoreQuantityLbl = [[UILabel alloc] initWithFrame:CGRectMake(7*TitleWidth, RightTitleHeight, TitleWidth, RightBottomTitleHeight)];
           
                thisStoreQuantityLbl.text = @"xx3";
          
            
            thisStoreQuantityLbl.textAlignment = NSTextAlignmentCenter;
            thisStoreQuantityLbl.backgroundColor = [UIColor whiteColor];
            //            lastSalePlanLbl.backgroundColor =col;
            thisStoreQuantityLbl.font=[UIFont fontWithName:@"Arial" size:15];
            //            UIImage *img=[UIImage imageNamed:@"tableHeaderBg.png"];
//            thisStoreQuantityLbl.backgroundColor = [UIColor colorWithPatternImage:img];
            [header addSubview:thisStoreQuantityLbl];
            
            UILabel* thisStoreMonthLbl = [[UILabel alloc] initWithFrame:CGRectMake(8*TitleWidth, RightTitleHeight, TitleWidth, RightBottomTitleHeight)];
            
                thisStoreMonthLbl.text = @"xx3";
           
          
            thisStoreMonthLbl.textAlignment = NSTextAlignmentCenter;
            thisStoreMonthLbl.backgroundColor = [UIColor whiteColor];
            //            lastSalePlanLbl.backgroundColor =col;
            thisStoreMonthLbl.font=[UIFont fontWithName:@"Arial" size:15];
            //            UIImage *img=[UIImage imageNamed:@"tableHeaderBg.png"];
//            thisStoreMonthLbl.backgroundColor = [UIColor colorWithPatternImage:img];
            [header addSubview:thisStoreMonthLbl];
            
            UILabel* thisDLRStoreQuantityLbl = [[UILabel alloc] initWithFrame:CGRectMake(9*TitleWidth, RightTitleHeight, TitleWidth, RightBottomTitleHeight)];
           
                thisDLRStoreQuantityLbl.text = @"xx3";
            
           
            thisDLRStoreQuantityLbl.textAlignment = NSTextAlignmentCenter;
            thisDLRStoreQuantityLbl.backgroundColor = [UIColor whiteColor];
            //            lastSalePlanLbl.backgroundColor =col;
            thisDLRStoreQuantityLbl.font=[UIFont fontWithName:@"Arial" size:15];
            //            UIImage *img=[UIImage imageNamed:@"tableHeaderBg.png"];
//            thisDLRStoreQuantityLbl.backgroundColor = [UIColor colorWithPatternImage:img];
            [header addSubview:thisDLRStoreQuantityLbl];
            
            UILabel* thisDLRStoreMonthLbl = [[UILabel alloc] initWithFrame:CGRectMake(10*TitleWidth, RightTitleHeight, TitleWidth, RightBottomTitleHeight)];
      
                thisDLRStoreMonthLbl.text = @"xx3";
          
            
         
            thisDLRStoreMonthLbl.textAlignment = NSTextAlignmentCenter;
            thisDLRStoreMonthLbl.backgroundColor = [UIColor whiteColor];
            //            lastSalePlanLbl.backgroundColor =col;
            thisDLRStoreMonthLbl.font=[UIFont fontWithName:@"Arial" size:15];
            //            UIImage *img=[UIImage imageNamed:@"tableHeaderBg.png"];
//            thisDLRStoreMonthLbl.backgroundColor = [UIColor colorWithPatternImage:img];
            [header addSubview:thisDLRStoreMonthLbl];
            
            //下月
            UILabel* nextSalePlanLbl = [[UILabel alloc] initWithFrame:CGRectMake(11*TitleWidth, RightTitleHeight, TitleWidth, RightBottomTitleHeight)];
            nextSalePlanLbl.text = @"xx3";
            nextSalePlanLbl.textAlignment = NSTextAlignmentCenter;
            nextSalePlanLbl.backgroundColor = [UIColor whiteColor];
            //            lastSalePlanLbl.backgroundColor =col;
            nextSalePlanLbl.font=[UIFont fontWithName:@"Arial" size:15];
            //            UIImage *img=[UIImage imageNamed:@"tableHeaderBg.png"];
//            nextSalePlanLbl.backgroundColor = [UIColor colorWithPatternImage:img];
            [header addSubview:nextSalePlanLbl];
            
            //下下月
            UILabel* nextNextSalePlanLbl = [[UILabel alloc] initWithFrame:CGRectMake(12*TitleWidth, RightTitleHeight, TitleWidth, RightBottomTitleHeight)];
            nextNextSalePlanLbl.text =  @"xx3";
            nextNextSalePlanLbl.textAlignment = NSTextAlignmentCenter;
            nextNextSalePlanLbl.backgroundColor = [UIColor whiteColor];
            //            lastSalePlanLbl.backgroundColor =col;
            nextNextSalePlanLbl.font=[UIFont fontWithName:@"Arial" size:15];
            //            UIImage *img=[UIImage imageNamed:@"tableHeaderBg.png"];
//            nextNextSalePlanLbl.backgroundColor = [UIColor colorWithPatternImage:img];
            [header addSubview:nextNextSalePlanLbl];
            
            for (int i=0; i<15; i++) {
                UIImageView *imga8= [[UIImageView alloc]initWithFrame:CGRectMake(100*i,30, 1, RightTitleHeight) ];
                imga8.image=[UIImage imageNamed:@"suxian.png"];
                [header addSubview:imga8];
            }
            UIImageView *imgaa= [[UIImageView alloc]initWithFrame:CGRectMake(1299,30, 1, RightTitleHeight) ];
            imgaa.image=[UIImage imageNamed:@"suxian.png"];
            [header addSubview:imgaa];
            return header;
        }
        else
        {
            return nil;
        }
    }
    
}

#pragma mark - TableView Delegate Methods

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return kTableViewCellHeight;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([tableView isEqual:_leftTableView]) {
        [self.rightTableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
    } else {
        [self.leftTableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
    }
}


#pragma mark - ScrollView Delegate 

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if ([scrollView isEqual:_leftTableView]) {
        self.rightTableView.contentOffset = _leftTableView.contentOffset;
    } else {
        self.leftTableView.contentOffset = _rightTableView.contentOffset;
    }
}

@end
