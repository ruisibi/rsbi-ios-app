/*********************************************************************
 * 版权所有   magic_Zzz
 *
 * 文件名称： PlotButtonListView
 * 内容摘要： 按扭列表view
 * 其它说明： 实现文件
 * 作 成 者： ZGD
 * 完成日期： 2016年03月22日
 * 修改记录1：
 * 修改日期：
 * 修 改 人：
 * 修改内容：
 * 修改记录2：
 **********************************************************************/

#import "PlotButtonListView.h"
#import "Common.h"
#import "RGHudModular.h"

@interface PlotButtonListView()<UITableViewDataSource,UITableViewDelegate>
@property (nonatomic, strong) UITableView  *myTableView;
@property (nonatomic, strong) NSMutableArray *dataArray;//按扭数组
@property (nonatomic, strong) NSMutableDictionary *selectedDict;// 选中的按扭
@end
@implementation PlotButtonListView
@synthesize myTableView;
@synthesize dataArray;
@synthesize selectedDict;

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        myTableView = [[UITableView alloc]initWithFrame:CGRectMake(5, 0, frame.size.width-10, frame.size.height)];
        self.myTableView.dataSource         = self;
        self.myTableView.delegate           = self;
        self.myTableView.backgroundColor    = [UIColor clearColor];
        self.myTableView.separatorStyle     = UITableViewCellSeparatorStyleNone;
        
        selectedDict = [NSMutableDictionary dictionaryWithCapacity:2];
        
        self.layer.masksToBounds = YES;
        self.layer.cornerRadius  = 8;
        self.layer.borderWidth   = 1;
        self.layer.borderColor   = MT_LINE_COLOR.CGColor;
        self.backgroundColor = MT_CELL_COLOR;
        [self addSubview:myTableView];
    }
    
    return self;
}


- (void)reloadSelectedCell:(NSDictionary *)sDict total:(NSArray *)arr
{
    dataArray = [NSMutableArray arrayWithArray:arr];
    selectedDict = [NSMutableDictionary dictionaryWithDictionary:sDict];
    [myTableView reloadData];
    
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
    return dataArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 10;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 30;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString         *CellIdentifier = @"btnCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone; //选中cell时无色

        cell.contentView.backgroundColor = [UIColor whiteColor];
        cell.layer.masksToBounds = YES;
        cell.layer.cornerRadius  = 8;
        cell.layer.borderColor   = [UIColor colorWithRed:29/255.0 green:174/255.0 blue:241/255.0 alpha:1].CGColor;
        cell.layer.borderWidth   = 0;
    }
    
    for(UIView *subView in cell.contentView.subviews ) {
        [subView removeFromSuperview];
    }
    
    UIImageView *imgBtn = [[UIImageView alloc]initWithFrame:CGRectMake(5, 6, 27, 18)];

    
    UILabel *lblName = [[UILabel alloc]initWithFrame:CGRectMake(35, 0, myTableView.frame.size.width - 35, 30)];
    id tDict = [dataArray objectAtIndex:indexPath.section];
    if ([tDict isKindOfClass:[NSDictionary class]]) {
        lblName.text = [tDict objectForKey:@"label"];
    }else if ([tDict isKindOfClass:[NSString class]]){
        lblName.text = tDict;
    }
  
    
    lblName.font = [UIFont systemFontOfSize:11];
    
    NSArray *ttArray = [selectedDict allKeys];
    
    BOOL flag = false;
    
    for (int j=0; j<ttArray.count; j++) {
        NSString *key = [ttArray objectAtIndex:j];
        NSNumber  *tNum  = [selectedDict objectForKey:key];
        if ( tNum != nil   && tNum.intValue == indexPath.section) {
            flag = true;
            imgBtn.image = [UIImage imageNamed:key];
            break;
        }
    }
    if (flag) {
        cell.layer.borderWidth   = 1;
        [cell.contentView addSubview:imgBtn];
    }else{
        cell.layer.borderWidth   = 0;
    }
    
    
    [cell.contentView addSubview:lblName];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    BOOL flag = false;
    NSArray *ttArray = [selectedDict allKeys];
    NSString *key = @"";
    for (int j=0; j<ttArray.count; j++) {
        NSString *ttkey = [ttArray objectAtIndex:j];
        NSNumber  *tNum  = [selectedDict objectForKey:ttkey];
        if ( tNum != nil   && tNum.intValue == indexPath.section) {
            flag = true;
            key  = ttkey;
            break;
        }
    }
    
    if (flag) {
        [selectedDict removeObjectForKey:key];
        
    }else{
        if ([selectedDict allKeys].count >= 6) {
            [[RGHudModular getRGHud] showAutoHudWithMessageDefault:@"展示过多,请取消其他选中"];
            return;
        }
       
        NSString *tmpStyle = @"plot";
        if (self.curStyle == ZZZPLOTSTYLE_HBar || self.curStyle == ZZZPLOTSTYLE_VBar || self.curStyle == ZZZPLOTSTYLE_Pie) {
            tmpStyle = @"barplot";
        }
        
        for (int j=0; j<=5; j++) {
            NSString *tkey = [NSString stringWithFormat:@"%@%d",tmpStyle,j];
            NSNumber *tttNum = [selectedDict objectForKey:tkey];
            if (tttNum == nil) {
                key = tkey;
                break;
            }
        }
        [selectedDict setObject:[NSNumber numberWithInt:indexPath.section] forKey:key];
    }
    if (self.delegate) {
        [self.delegate didChangeSelected:selectedDict];
    }
    [tableView reloadData];
}

@end
