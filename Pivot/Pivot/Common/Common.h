//
//  Common.h
//  Pivot
//
//  Created by djh on 16/3/1.
//  Copyright © 2016年 bos. All rights reserved.
//

#import <Foundation/Foundation.h>
// 常量
#define kWidth 100
#define kHeight 40
#define SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width
#define SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height
#define MT_FONT [UIFont systemFontOfSize:15]
#define MT_LINE_WIDTH 1
#define RGB(r, g, b)    [UIColor colorWithRed:(r)/255.f green:(g)/255.f blue:(b)/255.f alpha:1.f]
//线条颜色
#define MT_LINE_COLOR [UIColor colorWithRed:241/255.0 green:241/255.0 blue:241/255.0 alpha:1]

//cell颜色
#define MT_CELL_COLOR [UIColor colorWithRed:253/255.0 green:253/255.0 blue:253/255.0 alpha:1]
//表头背景
#define MT_HEADER_BG [UIColor colorWithRed:221/255.0 green:221/255.0 blue:221/255.0 alpha:1]

//--------------- 接口相关 --------------------
#define WEB_SERVICE_HOST @“http://bi.rosetech.cn"

//登录
#define WEB_SERVICE_LOGIN(ipAddress) [NSString stringWithFormat:@"%@/app/Login!login.action", ipAddress]

// 注销 userId
#define WEB_SERVICE_LOGOUT(ipAddress) [NSString stringWithFormat:@"%@/app/Login!logout.action", ipAddress]

// 首页菜单
#define WEB_SERVICE_MAINLIST(ipAddress) [NSString stringWithFormat:@"%@/app/Menus!topMenu.action", ipAddress]

// 主题列表
#define WEB_SERVICE_SUBLIST(ipAddress) [NSString stringWithFormat:@"%@/app/Subject!list.action", ipAddress]

// 获取指标 tableid=23 
#define WEB_SERVICE_CUBEKPI(ipAddress) [NSString stringWithFormat:@"%@/app/Cube!getKpi.action", ipAddress]

// 获取维度 tableid=26
#define WEB_SERVICE_CUBEDIM(ipAddress) [NSString stringWithFormat:@"%@/app/Cube!getDim.action", ipAddress]

// 返回表格数据 pageInfo
#define WEB_SERVICE_COMPTABLE(ipAddress) [NSString stringWithFormat:@"%@/app/CompView!viewTable.action", ipAddress]

// 返回图形数据 pageInfo
#define WEB_SERVICE_COMPVIEW(ipAddress) [NSString stringWithFormat:@"%@/app/CompView!viewChart.action", ipAddress]

// 保存一个多维配置信息  pageInfo
#define WEB_SERVICE_SAVEINFO(ipAddress) [NSString stringWithFormat:@"%@/app/Usave!save.action", ipAddress]

// 获取保存的多维配置信息列表
#define WEB_SERVICE_SAVELIST(ipAddress) [NSString stringWithFormat:@"%@/app/Usave!list.action", ipAddress]

// 获取单个多维配置信息详情
#define WEB_SERVICE_SAVEDETAIL(ipAddress) [NSString stringWithFormat:@"%@/app/Usave!get.action", ipAddress]

// 删除保存的多维配置信息
#define WEB_SERVICE_SAVEDEL(ipAddress) [NSString stringWithFormat:@"%@/app/Usave!delete.action", ipAddress]
//Usave!update.action

// 更新保存的多维配置信息
#define WEB_SERVICE_SAVEUPDATE(ipAddress) [NSString stringWithFormat:@"%@/app/Usave!update.action", ipAddress]

//  获取报表目录
#define WEB_SERVICE_REPORTLISTCATA(ipAddress) [NSString stringWithFormat:@"%@/app/Report!listCata.action", ipAddress]

//  获取报表列表?cataId=1
#define WEB_SERVICE_REPORTLIST(ipAddress) [NSString stringWithFormat:@"%@/app/Report!listReport.action", ipAddress]


//  查询收藏夹报表列表
#define WEB_SERVICE_COLLECTLIST(ipAddress) [NSString stringWithFormat:@"%@/app/Collect!list.action", ipAddress]

//  从收藏夹移除报表
#define WEB_SERVICE_COLLECTDEL(ipAddress) [NSString stringWithFormat:@"%@/app/Collect!delete.action", ipAddress]

//  添加报表到收藏夹
#define WEB_SERVICE_COLLECTADD(ipAddress) [NSString stringWithFormat:@"%@/app/Collect!add.action", ipAddress]


//  维度筛选  dimId=col_id &tid=表ID
#define WEB_SERVICE_DIMFILTER(ipAddress) [NSString stringWithFormat:@"%@/app/DimFilter.action", ipAddress]

//  获取用户信息
#define WEB_SERVICE_USERINFO(ipAddress) [NSString stringWithFormat:@"%@/app/UInfo.action", ipAddress]

//------------- 推送相关 ---------------//
//  查询推送信息列表
#define WEB_SERVICE_PUSHLIST(ipAddress) [NSString stringWithFormat:@"%@/app/Push!list.action", ipAddress]

//  查询推送主题
#define WEB_SERVICE_PUSHSUBJECT(ipAddress) [NSString stringWithFormat:@"%@/app/Push!listPushSubject.action", ipAddress]

//  保存推送信息
#define WEB_SERVICE_PUSHSAVE(ipAddress) [NSString stringWithFormat:@"%@/app/Push!save.action", ipAddress]

//   更新推送信息
#define WEB_SERVICE_PUSHUPDATE(ipAddress) [NSString stringWithFormat:@"%@/app/Push!update.action", ipAddress]

//  删除推送配置信息
#define WEB_SERVICE_PUSHDEL(ipAddress) [NSString stringWithFormat:@"%@/app/Push!del.action", ipAddress]

//  获取推送配置信息
#define WEB_SERVICE_PUSHGET(ipAddress) [NSString stringWithFormat:@"%@/app/Push!get.action", ipAddress]

//  获取推送数据列表
#define WEB_SERVICE_LISTMSG(ipAddress) [NSString stringWithFormat:@"%@/app/Push!listMsg.action", ipAddress]

//  获取推送数据json
#define WEB_SERVICE_MSGDETAIL(ipAddress) [NSString stringWithFormat:@"%@/app/Push!getMsg.action", ipAddress]

//  更新数据为已读
#define WEB_SERVICE_MSG2READ(ipAddress) [NSString stringWithFormat:@"%@/app/Push!msg2Read.action", ipAddress]

//  删除消息
#define WEB_SERVICE_DELMSG(ipAddress) [NSString stringWithFormat:@"%@/app/Push!delMsg.action", ipAddress]

//  停用推送
#define WEB_SERVICE_STOPPUSH(ipAddress) [NSString stringWithFormat:@"%@/app/Push!stopPush.action", ipAddress]

//  启用推送
#define WEB_SERVICE_STARTPUSH(ipAddress) [NSString stringWithFormat:@"%@/app/Push!startPush.action", ipAddress]

//  更新推送id
#define WEB_SERVICE_UPDATECHANNEL(ipAddress) [NSString stringWithFormat:@"%@/app/Push!updateChennel.action", ipAddress]

//图表样式
typedef enum {
    ZZZPLOTSTYLE_Scatter = 0,// 曲线
    ZZZPLOTSTYLE_HBar,// 竖柱状图
    ZZZPLOTSTYLE_Pie,// 饼状图
    ZZZPLOTSTYLE_VBar,// 横柱状图
    ZZZPLOTSTYLE_Area,// 面积
    ZZZPLOTSTYLE_Radar// 雷达
} ZZZPLOTSTYLE;
typedef void  (^RSYDoneBlock)(NSDictionary *aDict);//按钮点击回调
@interface Common : NSObject
/***********************************************************************
 * 方法名称： + (Common *)shareInstence;
 * 功能描述： 获取静态的信息
 * 输入参数：
 * 输出参数：
 * 返 回 值：
 ***********************************************************************/
+ (Common *)shareInstence;
@property (nonatomic, strong) NSString  *token;            // tokenID
@property (nonatomic, strong) NSString  *userAccount;            // 用户账号
@property (nonatomic)         BOOL      isLogin;//   token是否可用

/***********************************************************************
 * 方法名称： + (BOOL) isBlankString:(NSString *)string
 * 功能描述： 判断字符串string是否为空
 * 输入参数：
 * 输出参数：
 * 返 回 值：BOOL
 ***********************************************************************/
+ (BOOL)isBlankString:(NSString *)string;


/***********************************************************************
 * 方法名称： + (NSString *)GetServiceHost
 * 功能描述： 返回服务器地址
 * 输入参数：
 * 输出参数：
 * 返 回 值： 服务器地址
 ***********************************************************************/
+ (NSString *)GetServiceHost;

/***********************************************************************
 * 方法名称： + (NSString *)errorString:(NSString *)str
 * 功能描述： 返回错误码
 * 输入参数：
 * 输出参数：
 * 返 回 值：str 错误码
 ***********************************************************************/
+ (NSString *)errorString:(NSString *)str;

/***********************************************************************
 * 方法名称： +(int)getYMax:(int)maxY
 * 功能描述： 返回刻度最大值
 * 输入参数：
 * 输出参数：
 * 返 回 值：str 错误码
 ***********************************************************************/
+(int)getYMax:(int)maxY;

/***********************************************************************
 * 方法名称： +(int)getYMax:(int)maxY
 * 功能描述： 返回刻度最大值
 * 输入参数：
 * 输出参数：
 * 返 回 值：str 错误码
 *****************a******************************************************/
+(float)getYMaxFloat:(float)maxY;

/***********************************************************************
 * 方法名称： +(NSString *)getStringByInt:(int)num withMax:(int)max
 * 功能描述： 转换数字到字符
 * 输入参数：
 * 输出参数：
 * 返 回 值：str 字符
 ***********************************************************************/
+(NSString *)getStringByInt:(float)num withMax:(float)max;

/***********************************************************************
 * 方法名称： getCurrenAddressCount
 * 功能描述： 获取当前服务器数量
 * 输入参数：
 * 输出参数：
 * 返 回 值：
 ***********************************************************************/
+(int)getCurrenAddressCount;

/***********************************************************************
 * 方法名称： saveHost
 * 功能描述： 存储服务器
 * 输入参数：
 * 输出参数：
 * 返 回 值：
 ***********************************************************************/
+(void)saveHost:(NSString *)iphost;

/***********************************************************************
 * 方法名称： +(NSDate*) convertDateFromString:(NSString*)uiDate withFormat:(NSString *)format
 * 功能描述： string转date
 * 输入参数：
 * 输出参数：
 * 返 回 值：
 ***********************************************************************/
+(NSDate*) convertDateFromString:(NSString*)uiDate withFormat:(NSString *)format;

/***********************************************************************
 * 方法名称： converKpiJson
 * 功能描述： 转化成公用的kpijson
 * 输入参数：
 * 输出参数：
 * 返 回 值：
 ***********************************************************************/
+(NSDictionary *)converKpiJson:(NSDictionary *)aDict;

/***********************************************************************
 * 方法名称： converRowsJson
 * 功能描述： 转化成公用的RowsJson
 * 输入参数：
 * 输出参数：
 * 返 回 值：
 ***********************************************************************/
+(NSDictionary *)converRowsJson:(NSDictionary *)aDict;

/***********************************************************************
 * 方法名称： converColsJson
 * 功能描述： 转化成公用的ColsJson
 * 输入参数：
 * 输出参数：
 * 返 回 值：
 ***********************************************************************/
+(NSDictionary *)converColsJson:(NSDictionary *)aDict;


/***********************************************************************
 * 方法名称： converParamsJson
 * 功能描述： 转化成公用的查询条件
 * 输入参数：
 * 输出参数：
 * 返 回 值：
 ***********************************************************************/
+(NSDictionary *)converParamsJson:(NSDictionary *)aDict;


/***********************************************************************
 * 方法名称： formatTimeWithStr
 * 功能描述： 格式化日期
 * 输入参数：
 * 输出参数：
 * 返 回 值：
 ***********************************************************************/
+(NSString *)formatTimeWithStr:(NSString *)dateStr;


/***********************************************************************
 * 方法名称： formatTimeWithStr
 * 功能描述： 格式化日期
 * 输入参数：
 * 输出参数：
 * 返 回 值：
 ***********************************************************************/
+(NSString *)formatDetailTimeWithStr:(NSString *)dateStr;
@end
