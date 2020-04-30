/*********************************************************************
 * 版权所有   magic_Zzz
 *
 * 文件名称： UserData.h 用户数据存储实体
 * 内容摘要： 用户数据存储实体
 * 其它说明： 头文件
 * 作 成 者： ZGD
 * 完成日期： 2016年03月08日
 * 修改记录1：
 * 修改日期：
 * 修 改 人：
 * 修改内容：
 * 修改记录2：
 **********************************************************************/

/***************************************************************************   *
 *   文件引用
 ***************************************************************************/
#import <Foundation/Foundation.h>

/***************************************************************************   *
 *   类引用
 ***************************************************************************/

/***************************************************************************   *
 *   宏定义
 ***************************************************************************/

/***************************************************************************   *
 *   常量
 ***************************************************************************/

/***************************************************************************   *
 *   类型定义
 ***************************************************************************/

/***************************************************************************   *
 *   类定义
 ***************************************************************************/
@interface UserData : NSObject
{
    NSString    *userId;            // 用户ID
    NSString    *password;          // 密码
    NSString    *loginName;         // 用户名字
    NSString    *mobilePhone;       // 用户电话
    NSString    *email;             // 用户邮箱
    NSString    *gender;            // 用户性别
    NSString    *dbName;            //
    NSString    *defDay;            //
    NSString    *defMonth;          //
    NSString    *deptId;            //
    NSString    *edate;             //
    NSString    *lastActive;        //
    NSString    *loginIp;           // 登录ip
    NSString    *loginTime;         // 登录时间
    NSString    *logoutTime;        // 登出时间
    NSString    *officeTel;         //
    NSString    *policy;            // 权限
    NSString    *rid;               //
    NSString    *sdate;             //
    NSString    *sessionId;         //
    NSString    *siteId;            //
    NSString    *state;             // 状态
    NSString    *sysUser;           // 系统用户
    NSString    *updateUser;        // 更新者
    NSString    *yxq;               //
    NSDictionary *enddate;          //
}



/***********************************************************************
* 方法名称： +(UserData *)getUserData
* 功能描述： 获取静态的用户信息
* 输入参数：
* 输出参数：
* 返 回 值：
***********************************************************************/
+ (UserData *)getUserData;

/***********************************************************************
 * 方法名称：- (void)signOutUser
 * 功能描述： 重置
 * 输入参数：
 * 输出参数：
 * 返 回 值：
 ***********************************************************************/
- (void)signOutUser;

/***********************************************************************
* 方法名称： - (void)initUserData:(NSDictionary *)userDict
* 功能描述： 登录时初始化Data
* 输入参数：
* 输出参数：
* 返 回 值：
***********************************************************************/
- (void)initUserData:(NSDictionary *)userDict;
 
@property (nonatomic, strong) NSString  *userId;            // 用户ID
@property (nonatomic, strong) NSString  *loginName;         // 用户名字
@property (nonatomic, strong) NSString  *password;          // 用户密码
@property (nonatomic, strong) NSString  *mobilePhone;       // 用户电话
@property (nonatomic, strong) NSString  *email;             // 用户邮箱
@property (nonatomic, strong) NSString  *gender;            // 用户性别
@property (nonatomic, strong) NSString  *dbName;            //
@property (nonatomic, strong) NSString  *defDay;            //
@property (nonatomic, strong) NSString  *defMonth;          //
@property (nonatomic, strong) NSString  *deptId;            //
@property (nonatomic, strong) NSString  *edate;             //
@property (nonatomic, strong) NSString  *lastActive;        //
@property (nonatomic, strong) NSString  *loginIp;           //
@property (nonatomic, strong) NSString  *loginTime;         //
@property (nonatomic, strong) NSString  *logoutTime;        //
@property (nonatomic, strong) NSString  *officeTel;         //
@property (nonatomic, strong) NSString  *policy;            //
@property (nonatomic, strong) NSString  *rid;               //
@property (nonatomic, strong) NSString  *sdate;             //
@property (nonatomic, strong) NSString  *sessionId;         //
@property (nonatomic, strong) NSString  *siteId;            //
@property (nonatomic, strong) NSString  *state;             //
@property (nonatomic, strong) NSString  *sysUser;           //
@property (nonatomic, strong) NSString  *updateUser;        //
@property (nonatomic, strong) NSString  *yxq;               //
@property (nonatomic, strong) NSDictionary *enddate;        //

@end