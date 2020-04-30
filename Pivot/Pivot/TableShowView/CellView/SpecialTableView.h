//
//  SpecialTableView
//  Custom
//
//  Created by tan on 13-1-22.
//  Copyright (c) 2013年 adways. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    kScrollMethodWithLeft = 0,//左边滚动
    kScrollMethodWithRight,//右边滚动
    kScrollMethodWithAll
}ScrollMethod;

#define kTableViewCellHeight 26

@interface SpecialTableView : UIView <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, retain) UITableView *leftTableView;
@property (nonatomic, retain) UITableView *rightTableView;
@property (nonatomic, retain) UIScrollView *leftScrollView;
@property (nonatomic, retain) UIScrollView *rightScrollView;
@property (nonatomic, retain) NSArray *dataArray;
@property (nonatomic, retain) NSDictionary *trDictionary;
@property (nonatomic, retain) NSArray *leftDataKeys;
@property (nonatomic, retain) NSArray *rightDataKeys;
@property (strong,nonatomic) NSString *currentYM;

//传递的leftDataKeys rightDataKeys我们是经过了判断的，他们每个长度不能在kScrollMethodWithLeft 和 kScrollMethodWithRight模式下不能越界,具体参看代码
- (id)initWithData:(NSArray *)dArray trDictionary:(NSDictionary *)trDict size:(CGSize)size scrollMethod:(ScrollMethod)sm leftDataKeys:(NSArray *)leftDataKeys rightDataKeys:(NSArray *)rightDataKeys;

-(void)reloadData:(NSArray *)dArray trDictionary:(NSDictionary *)trDict leftDataKeys:(NSArray *)leftDataKeys rightDataKeys:(NSArray *)rightDataKeys;

@end
