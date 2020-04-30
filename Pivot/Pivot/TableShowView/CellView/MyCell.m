//
//  MyCell.m
//  表格
//
//  Created by zzy on 14-5-6.
//  Copyright (c) 2014年 zzy. All rights reserved.
//


#import "MyCell.h"
#import "HeadView.h"


@interface MyCell()<HeadViewDelegate>
{
    UILabel *detailRoom;
    int curCount;
}
@end

@implementation MyCell

- (id)initCellWithCount:(int)count
{
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"dstcell"];
    if (self) {
        curCount = count;
        for(int i=0;i<count;i++){
        
            HeadView *headView=[[HeadView alloc]initWithFrame:CGRectMake(i*kWidth, 0, kWidth, kHeight)];
           
            [self.contentView addSubview:headView];
        }
        
    }
    return self;
}
-(void)headView:(HeadView *)headView point:(CGPoint)point
{
 
}

-(void)setMsgCellArray:(NSMutableArray *)arr
{
  _currentTime=arr;
    int count=(int)arr.count;
    if(count>0){
        if (count == curCount) {
            for (int i =0;i<count;i++) {
                HeadView *subView = self.contentView.subviews[i];
                subView.backgroundColor=[UIColor colorWithRed:249/255.0 green:249/255.0 blue:249/255.0 alpha:1];
                
                id value = arr[i];
                
                subView.detail = value;
//                if ([value isKindOfClass:[NSString class]]) {
//                    subView.numRoom.textAlignment = NSTextAlignmentLeft;
//                }else{
//                    subView.numRoom.textAlignment = NSTextAlignmentCenter;
//                }
                subView.numRoom.textAlignment = NSTextAlignmentCenter;
                subView.numRoom.backgroundColor = [UIColor clearColor];
            }
        }
        
    }else{
        
        for(HeadView *headView in self.contentView.subviews){
            
            headView.backgroundColor=[UIColor lightGrayColor];
        }
    }
}

- (void)setCellArray:(NSMutableArray *)arr
{
     _currentTime=arr;
    int count=(int)arr.count;
    if(count>0){
        if (count == curCount) {
            for (int i =0;i<count;i++) {
                HeadView *subView = self.contentView.subviews[i];
                subView.backgroundColor=[UIColor colorWithRed:249/255.0 green:249/255.0 blue:249/255.0 alpha:1];
                NSString *type = [arr[i] objectForKey:@"type"];
                NSString *value = [arr[i] objectForKey:@"value"];
                if(type.intValue == 1) {
                    subView.numRoom.textAlignment = NSTextAlignmentRight;
                    if (value.intValue == 0) {
                        subView.detail = @"0";
                    }else{
                        subView.detail = value;
                    }
                    
                }else{
                    subView.detail = value;
                    subView.numRoom.textAlignment = NSTextAlignmentLeft;
                }
                
                
            }
        }
       
    }else{
       
        for(HeadView *headView in self.contentView.subviews){
        
            headView.backgroundColor=[UIColor lightGrayColor];
        }
    }
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
