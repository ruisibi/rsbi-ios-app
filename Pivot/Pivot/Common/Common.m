//
//  Common.m
//  Pivot
//
//  Created by djh on 16/3/1.
//  Copyright © 2016年 bos. All rights reserved.
//

#import "Common.h"
#import "JSONKit.h"
#import <UIKit/UIKit.h>
@implementation Common
static Common *sui;

+ (Common *)shareInstence
{
    @synchronized(self) {
        if (!sui)
        {
            sui = [[Common alloc] init];
        }
        
        return sui;
    }
}

/***********************************************************************
 * 方法名称： + (BOOL) isBlankString:(NSString *)string
 * 功能描述： 判断字符串string是否为空
 * 输入参数：
 * 输出参数：
 * 返 回 值：BOOL
 ***********************************************************************/
+ (BOOL)isBlankString:(NSString *)string
{
    if ((string == nil) || (string == NULL))
    {
        return YES;
    }
    
    if ([string isKindOfClass:[NSNull class]])
    {
        return YES;
    }
    
    if ([string isEqualToString:@""]) {
        return YES;
    }
    if ([[string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length] == 0)
    {
        return YES;
    }
    
    return NO;
}

+ (NSString *)errorString:(NSString *)str
{
    NSString *tmpStr = [str stringByReplacingOccurrencesOfString:@"\r" withString:@""];
    NSString *tmpStr2 = [tmpStr stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    NSDictionary *data2 = [tmpStr2 objectFromJSONStringWithParseOptions:JKParseOptionLooseUnicode];
    return [data2 objectForKey:@"error"];
}

+ (NSString *)GetServiceHost
{
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    NSString *ipAddress = [userDefault stringForKey:@"ipAddress0"];
    if ([Common isBlankString:ipAddress]) {
        ipAddress = @"http://bi.rosetech.cn";
        
    }
    return ipAddress;
}

+(int)getCurrenAddressCount
{
    int count = 0;
    BOOL flag = YES;
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    while (flag) {
        count = count + 1;
        NSString *key = [NSString stringWithFormat:@"ipAddress%d",count];
        NSString *ipAddress = [userDefault stringForKey:key];
        if (ipAddress == nil) {
            flag = false;
        }
    }
    return count;
}

+(NSDate*) convertDateFromString:(NSString*)uiDate withFormat:(NSString *)format
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init] ;
    [formatter setDateFormat:format];
    NSDate *date=[formatter dateFromString:uiDate];
    return date;
}

+(void)saveHost:(NSString *)iphost
{
    int count = [Common getCurrenAddressCount];
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    [userDefault setObject:iphost forKey:@"ipAddress0"];
    
    BOOL flag = false;
    for (int i = 1; i<=count; i++) {
        NSString *key = [NSString stringWithFormat:@"ipAddress%d",i];
        NSString *ipAddress = [userDefault stringForKey:key];
        if (ipAddress != nil && [ipAddress isEqualToString:iphost]) {
            flag = YES;
            break;
        }
    }
    if (flag == false) {
        [userDefault setObject:iphost forKey:[NSString stringWithFormat:@"ipAddress%d",count]];
    }
}

+(int)getYMax:(int)maxY{
    
    int a=10;
//     NSLog(@"初始maxY:%d",maxY);
    for(int i=0;maxY>a;i++){
        a=a*10;
    }
   
    if(a>10){
        a=a/10;
    }
    int adx=a;
  
    while(maxY>a){
        a=a+adx;
    }
   
    if((a-maxY)<0.15*adx){   //2.1版本从2.0下调
        a=a+adx;
    }
  
    // 2.1版本新加修正内容  是否会影响之前模块 需要测试
    //第4次修正，返回值与传入参数比例过于接近，需要修正
    if((a-maxY)<maxY*0.1){
        //大刻度只修正一半
        if(a/adx<5){
            a=a+adx/2;
        }else{
            a=a+adx;
        }
    }
    
    return a;
}

+(float)getYMaxFloat:(float)maxY
{
    
    int tMax = maxY*10;
    
    if (tMax%1 >1) {
        return maxY + 0.1;
    }
    
    int tMax2 = maxY*100;
    if (tMax2 > 1) {
        return maxY + 0.01;
    }
    
    int tMax3 = maxY*1000;
    if (tMax3 > 1) {
        return maxY + 0.001;
    }
    
    int tMax4 = maxY*10000;
    if (tMax4 > 1) {
        return maxY + 0.0001;
    }
    
    return 1;
}

+(NSString *)getStringByInt:(float)num withMax:(float)max
{
    
    NSString *str = @"";
    if (max < 1) {
        str = [NSString stringWithFormat:@"%0.4f",num];
    }
    int lastNum = num;
    if (max < 1000 && max >=1) {
        str = [NSString stringWithFormat:@"%d",lastNum];
    }
    if (max>1000 && max <= 100000) {
        
        if (lastNum%1000 != 0) {
            str = [NSString stringWithFormat:@"%0.1fk",lastNum/1000.0];
        }else{
            str = [NSString stringWithFormat:@"%dk",lastNum/1000];
        }
    }
    if (max >= 100000 && max < 10000000) {
        if (lastNum%10000 != 0) {
            str = [NSString stringWithFormat:@"%0.1f万",lastNum/10000.0];
        }else{
            str = [NSString stringWithFormat:@"%d万",lastNum/10000];
        }
    }
    if (max >= 10000000 && max < 1000000000) {
        if (lastNum%1000000 != 0) {
            str = [NSString stringWithFormat:@"%0.1f百万",lastNum/1000000.0];
        }else{
            str = [NSString stringWithFormat:@"%d百万",lastNum/1000000];
        }
    }
    if (max >= 1000000000 ) {
        if (lastNum%10000000 != 0) {
            str = [NSString stringWithFormat:@"%0.1f千万",lastNum/10000000.0];
        }else{
            str = [NSString stringWithFormat:@"%d千万",lastNum/10000000];
        }
    }
    
    return str;
}

-(CGFloat)titleSize
{
    CGFloat size;
    
#if TARGET_IPHONE_SIMULATOR || TARGET_OS_IPHONE
    switch ( UI_USER_INTERFACE_IDIOM() ) {
        case UIUserInterfaceIdiomPad:
            size = 24.0;
            break;
            
        case UIUserInterfaceIdiomPhone:
            size = 16.0;
            break;
            
        default:
            size = 12.0;
            break;
    }
#else
    size = 24.0;
#endif
    
    return size;
}

/***********************************************************************
 * 方法名称： converKpiJson
 * 功能描述： 转化成公用的kpijson
 * 输入参数：
 * 输出参数：
 * 返 回 值：
 ***********************************************************************/
+(NSDictionary *)converKpiJson:(NSDictionary *)aDict
{
    NSMutableDictionary *tmpDict = [NSMutableDictionary dictionaryWithDictionary:aDict];
    
    NSString *kpiId = [tmpDict objectForKey:@"kpi_id"];
    if (kpiId == nil) {
        [tmpDict setObject:[tmpDict objectForKey:@"col_id"] forKey:@"kpi_id"];
        [tmpDict setObject:[tmpDict objectForKey:@"text"] forKey:@"kpi_name"];
    }else{
        [tmpDict setObject:[tmpDict objectForKey:@"kpi_id"] forKey:@"col_id"];
        [tmpDict setObject:[tmpDict objectForKey:@"kpi_name"] forKey:@"text"];
    }
    
    return tmpDict;
}

/***********************************************************************
 * 方法名称： converRowsJson
 * 功能描述： 转化成公用的RowsJson
 * 输入参数：
 * 输出参数：
 * 返 回 值：
 ***********************************************************************/
+(NSDictionary *)converRowsJson:(NSDictionary *)aDict
{
    NSMutableDictionary *tmpDict = [NSMutableDictionary dictionaryWithDictionary:aDict];
    
    NSString *col_name = [tmpDict objectForKey:@"col_name"];
    if ([Common isBlankString:col_name]) {// 为空时
        NSString *tname = [tmpDict objectForKey:@"dimdesc"];
        if (![Common isBlankString:tname]) {
            [tmpDict setObject:tname forKey:@"text"];
        }
        NSString *type = [tmpDict objectForKey:@"type"];
        if (![Common isBlankString:type]) {
            [tmpDict setObject:type forKey:@"dim_type"];
        }
        NSString *colname = [tmpDict objectForKey:@"colname"];
        NSString *dim_name = [tmpDict objectForKey:@"dim_name"];
        NSNumber *col_id = [tmpDict objectForKey:@"id"];
        if (![Common isBlankString:colname]) {
            [tmpDict setObject:colname forKey:@"col_name"];
        }
        if (![Common isBlankString:dim_name]) {
            [tmpDict setObject:dim_name forKey:@"groupname"];
        }
        if (col_id != nil) {
            [tmpDict setObject:col_id forKey:@"col_id"];
        }
        
    }else{
        NSString *tname = [tmpDict objectForKey:@"text"];
        NSString *type = [tmpDict objectForKey:@"dim_type"];
        NSString *colname = [tmpDict objectForKey:@"col_name"];
        NSString *dim_name = [tmpDict objectForKey:@"groupname"];
        [tmpDict setObject:tname forKey:@"name"];
        [tmpDict setObject:tname forKey:@"dimdesc"];
        [tmpDict setObject:type forKey:@"type"];
        [tmpDict setObject:colname forKey:@"colname"];
        [tmpDict setObject:dim_name forKey:@"dim_name"];
        
    }
    
    return tmpDict;
}

/***********************************************************************
 * 方法名称： converColsJson
 * 功能描述： 转化成公用的ColsJson
 * 输入参数：
 * 输出参数：
 * 返 回 值：
 ***********************************************************************/
+(NSDictionary *)converColsJson:(NSDictionary *)aDict
{
    NSMutableDictionary *tmpDict = [NSMutableDictionary dictionaryWithDictionary:aDict];
    NSString *col_name = [tmpDict objectForKey:@"col_name"];
    if ([Common isBlankString:col_name]) {// 为空时
        NSString *colname = [tmpDict objectForKey:@"colname"];
        NSString *type = [tmpDict objectForKey:@"type"];
        NSString *name = [tmpDict objectForKey:@"name"];
        
        if (![Common isBlankString:colname]) {
            [tmpDict setObject:colname forKey:@"col_name"];
        }
        if (![Common isBlankString:type]) {
            [tmpDict setObject:type forKey:@"dim_type"];
        }
        if (![Common isBlankString:name]) {
            [tmpDict setObject:name forKey:@"text"];
        }
        
    }else{
        NSString *tname = [tmpDict objectForKey:@"text"];
        NSString *type = [tmpDict objectForKey:@"dim_type"];
        NSString *colname = [tmpDict objectForKey:@"col_name"];
        [tmpDict setObject:tname forKey:@"name"];
        [tmpDict setObject:tname forKey:@"dimdesc"];
        [tmpDict setObject:type forKey:@"type"];
        [tmpDict setObject:colname forKey:@"colname"];
    
    }

    
    return tmpDict;
}

/***********************************************************************
 * 方法名称： converParamsJson
 * 功能描述： 转化成公用的查询条件
 * 输入参数：
 * 输出参数：
 * 返 回 值：
 ***********************************************************************/
+(NSDictionary *)converParamsJson:(NSDictionary *)aDict
{
    NSMutableDictionary *tmpDict = [NSMutableDictionary dictionaryWithDictionary:aDict];
    NSString *col_name = [tmpDict objectForKey:@"col_name"];
    if ([Common isBlankString:col_name]) {// 为空时
        NSString *colname = [tmpDict objectForKey:@"colname"];
        NSString *type = [tmpDict objectForKey:@"type"];
        NSString *name = [tmpDict objectForKey:@"name"];
        
        if (![Common isBlankString:colname]) {
            [tmpDict setObject:colname forKey:@"col_name"];
        }
        if (![Common isBlankString:type]) {
            [tmpDict setObject:type forKey:@"dim_type"];
        }
        if (![Common isBlankString:name]) {
            [tmpDict setObject:name forKey:@"text"];
        }
    }else{
        NSString *tname = [tmpDict objectForKey:@"text"];
        NSString *type = [tmpDict objectForKey:@"dim_type"];
        NSString *colname = [tmpDict objectForKey:@"col_name"];
        [tmpDict setObject:tname forKey:@"name"];
        [tmpDict setObject:type forKey:@"type"];
        [tmpDict setObject:colname forKey:@"colname"];
    
    }
    
    return tmpDict;
}

+(NSString *)formatTimeWithStr:(NSString *)dateStr
{
    NSTimeInterval time=[dateStr doubleValue]/1000;//因为时差问题要加8小时 == 28800 sec
    
    NSDate *detaildate=[NSDate dateWithTimeIntervalSince1970:time];
    //实例化一个NSDateFormatter对象
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    //设定时间格式,这里可以设置成自己需要的格式
    [dateFormatter setDateFormat:@"yy/M/d"];
    
  
    //用[NSDate date]可以获取系统当前时间
    NSString *currentDateStr = [dateFormatter stringFromDate:detaildate];
    
    return currentDateStr;
}
+(NSString *)formatDetailTimeWithStr:(NSString *)dateStr
{
    NSTimeInterval time=[dateStr doubleValue]/1000;//因为时差问题要加8小时 == 28800 sec
    
    NSDate *detaildate=[NSDate dateWithTimeIntervalSince1970:time];
    //实例化一个NSDateFormatter对象
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    //设定时间格式,这里可以设置成自己需要的格式
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    
    //用[NSDate date]可以获取系统当前时间
    NSString *currentDateStr = [dateFormatter stringFromDate:detaildate];
    
    return currentDateStr;
}
@end
