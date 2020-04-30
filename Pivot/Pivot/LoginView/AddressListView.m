//
//  AddressListView.m
//  Pivot
//
//  Created by djh on 16/3/17.
//  Copyright © 2016年 bos. All rights reserved.
//

#import "AddressListView.h"
#import "Common.h"

@interface AddressListView ()<UITableViewDataSource,UITableViewDelegate>
@property (nonatomic, strong) UITableView *myTableView;
@property (nonatomic, strong) NSMutableArray *dataArray;
@end

@implementation AddressListView

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.myTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        self.myTableView.delegate = self;
        self.myTableView.dataSource = self;
        self.myTableView.separatorStyle     = UITableViewCellSeparatorStyleNone;
        
        UIView *line1 = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 1, frame.size.height)];
        line1.backgroundColor = MT_LINE_COLOR;
        UIView *line2 = [[UIView alloc]initWithFrame:CGRectMake(0, frame.size.height - 1, frame.size.width, 1)];
        line2.backgroundColor = MT_LINE_COLOR;
        UIView *line3 = [[UIView alloc]initWithFrame:CGRectMake(frame.size.width - 1, 0, 1, frame.size.height)];
        line3.backgroundColor = MT_LINE_COLOR;
        
        [self addSubview:self.myTableView];
        [self addSubview:line1];
        [self addSubview:line2];
        [self addSubview:line3];
    }
    
    return self;
}

- (void)reloadData
{
    self.dataArray = [[NSMutableArray alloc]init];
    int count = [Common getCurrenAddressCount];
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    for (int i = 1 ; i<count; i++) {
        NSString *key = [NSString stringWithFormat:@"ipAddress%d",i];
        NSString *ipAddress = [userDefault stringForKey:key];
        if (ipAddress != nil) {
            [self.dataArray addObject:ipAddress];
        }
        
    }
    [self.myTableView reloadData];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 30;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"alistcell"];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"alistcell"];
        cell.textLabel.font = [UIFont systemFontOfSize:12];
        UIView *line2 = [[UIView alloc]initWithFrame:CGRectMake(0, 29, self.frame.size.width, 1)];
        line2.backgroundColor = MT_LINE_COLOR;
        [cell.contentView addSubview:line2];
    }
    cell.textLabel.text = self.dataArray[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.delegate) {
        [self.delegate didSelectAddress:self.dataArray[indexPath.row]];
    }
    self.hidden = YES;
    
}
@end
