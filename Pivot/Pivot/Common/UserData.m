/*********************************************************************
 * 版权所有   magic_Zzz
 *
 * 文件名称： UserData.h 用户数据存储实体
 * 内容摘要： 用户数据存储实体
 * 其它说明： 实现文件
 * 作 成 者： ZGD
 * 完成日期： 2016年03月08日
 * 修改记录1：
 * 修改日期：
 * 修 改 人：
 * 修改内容：
 * 修改记录2：
 **********************************************************************/

#import "UserData.h"
#import "JSONKit.h"
#import "NSObject+ObjectMap.h"
#import "Common.h"

@implementation UserData

@synthesize dbName;
@synthesize email;
@synthesize userId;
@synthesize defDay;
@synthesize defMonth;
@synthesize mobilePhone;
@synthesize loginName;
@synthesize gender;
@synthesize deptId;
@synthesize edate;
@synthesize lastActive;
@synthesize loginIp;
@synthesize loginTime;
@synthesize logoutTime;
@synthesize officeTel;
@synthesize password;
@synthesize enddate;
@synthesize policy;
@synthesize rid;
@synthesize sdate;
@synthesize sessionId;
@synthesize siteId;
@synthesize state;
@synthesize sysUser;
@synthesize updateUser;
@synthesize yxq;

static UserData *sui;

/***********************************************************************
* 方法名称： +(UserData *)getUserData
* 功能描述： 获取静态的用户信息
* 输入参数：
* 输出参数：
* 返 回 值：
***********************************************************************/
+ (UserData *)getUserData
{
    @synchronized(self) {
        if (!sui)
        {
            sui = [[UserData alloc] init];
        }

        return sui;
    }
}


/***********************************************************************
* 方法名称： - (void)initUserData:(NSDictionary *)userDict
* 功能描述： 登录时初始化Data
* 输入参数：
* 输出参数：
* 返 回 值：
***********************************************************************/
- (void)initUserData:(NSDictionary *)userDict
{
    NSString *jsonStr = [userDict JSONString];

    sui = [[UserData alloc] initWithJSONData:[jsonStr dataUsingEncoding:NSUTF8StringEncoding]];
}

- (void)signOutUser
{
    [Common shareInstence].token = @"";
    [Common shareInstence].userAccount = @"";
    sui.userId = @"";
    sui.password = @"";
    sui.loginName = @"";
    sui.mobilePhone = @"";
    sui.email = @"";
//    sui.userType = @"";
    sui.gender = @"";
    sui.dbName = @"";
    sui.defDay = @"";
    sui.defMonth = @"";
    sui.deptId = @"";
    sui.edate = @"";
    sui.lastActive = @"";
    sui.loginIp = @"";
    sui.loginTime = @"";
    sui.logoutTime = @"";
    sui.officeTel = @"";
    
    sui.policy = @"";
    sui.rid = @"";
    sui.sdate = @"";
    sui.sessionId = @"";
    sui.siteId = @"";
    sui.state = @"";
    sui.sysUser = @"";
    sui.updateUser = @"";
    sui.yxq = @"";
}

@end