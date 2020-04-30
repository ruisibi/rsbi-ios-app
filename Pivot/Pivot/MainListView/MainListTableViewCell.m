/*********************************************************************
 * 版权所有   magic_Zzz
 *
 * 文件名称： MainListTableViewCell
 * 内容摘要： 主列表cell
 * 其它说明： 实现文件
 * 作 成 者： ZGD
 * 完成日期： 2016年03月08日
 * 修改记录1：
 * 修改日期：
 * 修 改 人：
 * 修改内容：
 * 修改记录2：
 **********************************************************************/

#import "MainListTableViewCell.h"
#import "Common.h"
#import "UIImageView+WebCache.h"

@interface MainListTableViewCell ()
{
    UIImageView *imgHeader;// 图标
    UILabel     *lblTitle;// 标题
    UILabel     *lblDesc;// 描述
}
@end
@implementation MainListTableViewCell

//height 80
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        imgHeader = [[UIImageView alloc]initWithFrame:CGRectMake(10, 15, 50,50)];
 
        lblTitle  = [[UILabel alloc]initWithFrame:CGRectMake(70, 15, frame.size.width - 80, 25)];

        lblDesc   = [[UILabel alloc]initWithFrame:CGRectMake(70, 40, frame.size.width - 80, 35)];
//        lblDesc.textColor = [UIColor lightGrayColor];
        lblDesc.font = [UIFont systemFontOfSize:13];
        lblDesc.numberOfLines = 2;
        
        UIView  *lineView = [[UIView alloc]initWithFrame:CGRectMake(0, 79, frame.size.width, 1)];
        lineView.backgroundColor = MT_LINE_COLOR;
        
        UIView  *lineView1 = [[UIView alloc]initWithFrame:CGRectMake(0, 0, frame.size.width, 1)];
        lineView1.backgroundColor = MT_LINE_COLOR;
        self.contentView.backgroundColor = MT_CELL_COLOR;
        
        [self.contentView addSubview:imgHeader];
        [self.contentView addSubview:lblTitle];
        [self.contentView addSubview:lblDesc];
        [self.contentView addSubview:lineView];
        [self.contentView addSubview:lineView1];
    }
    return self;
}
- (void)awakeFromNib {
    
}

- (void)setCellDict:(NSDictionary *)dict
{
    lblTitle.text = [dict objectForKey:@"name"];
    lblDesc.text = [dict objectForKey:@"note"];
    NSString *urlStr = [NSString stringWithFormat:@"%@/%@",[Common GetServiceHost],[dict objectForKey:@"pic"]];
//    NSLog(@"图片地址:%@",urlStr);
    [imgHeader sd_setImageWithURL:[NSURL URLWithString:urlStr] placeholderImage:nil options:SDWebImageRefreshCached];
//    [imgHeader sd_setImageWithURL:[NSURL URLWithString:urlStr]];
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
