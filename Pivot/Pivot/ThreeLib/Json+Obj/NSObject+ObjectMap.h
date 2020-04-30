/*********************************************************************
 * 版权所有  Copyright (c) 2012 The Board of Trustees of The University of Alabama
 *
 * 文件名称： NSObject+ObjectMap.h
 * 内容摘要： 对象的操作工具类
 * 其它说明： 头文件
 * 作 成 者： The Board of Trustees of The University of Alabama
 * 完成日期： 2015年03月04日
 * 修改记录1：
 * 修改日期：
 * 修 改 人：
 * 修改内容：
 * 修改记录2：BSD版权权限（Uncertain）
 **********************************************************************/

#import <Foundation/Foundation.h>
#import <objc/runtime.h>

#define OMDateFormat @"yyyy-MM-dd'T'HH:mm:ss.SSS"
#define OMTimeZone @"UTC"


typedef NS_ENUM(NSInteger, CAPSDataType) {
    CAPSDataTypeJSON,
    CAPSDataTypeXML,
    CAPSDataTypeSOAP
};

@interface NSObject (ObjectMap)


/*****************************************************************************
 * 方法名称: -(NSDictionary *)propertyDictionary
 * 功能描述: 将对象的属性转换成字典
 * 输入参数:
 * 输出参数: NSDictionary
 * 返回值:
 * 其它说明:
 *****************************************************************************/
-(NSDictionary *)propertyDictionary;

/*****************************************************************************
 * 方法名称: -(NSString *)nameOfClass
 * 功能描述: 将对象名称返回
 * 输入参数:
 * 输出参数: NSString
 * 返回值:
 * 其它说明:
 *****************************************************************************/
-(NSString *)nameOfClass;


/*****************************************************************************
 * 方法名称: - (instancetype)initWithJSONData:(NSData *)data
 * 功能描述: 将JSONData转换成对象返回
 * 输入参数: data--jsonData类型参数
 * 输出参数: instancetype
 * 返回值:
 * 其它说明:
 *****************************************************************************/
- (instancetype)initWithJSONData:(NSData *)data;


/*****************************************************************************
 * 方法名称: - (instancetype)initWithXMLData:(NSData *)data
 * 功能描述: 将XMLData转换成对象返回
 * 输入参数: data--XMLData类型参数
 * 输出参数: instancetype
 * 返回值:
 * 其它说明:
 *****************************************************************************/
- (instancetype)initWithXMLData:(NSData *)data;


/*****************************************************************************
 * 方法名称: - (instancetype)initWithSOAPData:(NSData *)data
 * 功能描述: 将SOAPData转换成对象返回
 * 输入参数: data--SOAPData类型参数
 * 输出参数: instancetype
 * 返回值:
 * 其它说明:
 *****************************************************************************/
- (instancetype)initWithSOAPData:(NSData *)data;


/*****************************************************************************
 * 方法名称: - (instancetype)initWithObjectData:(NSData *)data type:(CAPSDataType)type
 * 功能描述:
 * 输入参数:
 * 输出参数: instancetype
 * 返回值:
 * 其它说明:
 *****************************************************************************/
- (instancetype)initWithObjectData:(NSData *)data type:(CAPSDataType)type;



#pragma mark - Top Level Array from JSON
/*****************************************************************************
 * 方法名称: + (NSArray *)arrayOfType:(Class)objectClass FromJSONData:(NSData *)data
 * 功能描述: 将JSONData转成对应（objectClass）的对象数组
 * 输入参数: objectClass--需要的对象class；data--JSONData
 * 输出参数: NSArray
 * 返回值:
 * 其它说明:
 *****************************************************************************/
+ (NSArray *)arrayOfType:(Class)objectClass FromJSONData:(NSData *)data;



#pragma mark - Serialized Data/Strings from Objects
/*****************************************************************************
 * 方法名称: -(NSData *)JSONData
 * 功能描述: 将对象转成JSONData
 * 输入参数:
 * 输出参数: NSData
 * 返回值:
 * 其它说明:
 *****************************************************************************/
-(NSData *)JSONData;

/*****************************************************************************
 * 方法名称: -(NSString *)OBJJSONString
 * 功能描述: 将对象转成JSONString
 * 输入参数:
 * 输出参数: NSString
 * 返回值:
 * 其它说明:
 *****************************************************************************/
-(NSString *)OBJJSONString;

/*****************************************************************************
 * 方法名称: -(NSData *)XMLData
 * 功能描述: 将对象转成JXMLData
 * 输入参数:
 * 输出参数: NSData
 * 返回值:
 * 其它说明:
 *****************************************************************************/
-(NSData *)XMLData;

/*****************************************************************************
 * 方法名称: -(NSString *)XMLString
 * 功能描述: 将对象转成XMLString
 * 输入参数:
 * 输出参数: NSString
 * 返回值:
 * 其它说明:
 *****************************************************************************/
-(NSString *)XMLString;

/*****************************************************************************
 * 方法名称: -(NSData *)SOAPData
 * 功能描述: 将对象转成SOAPData
 * 输入参数:
 * 输出参数: NSData
 * 返回值:
 * 其它说明:
 *****************************************************************************/
-(NSData *)SOAPData;

/*****************************************************************************
 * 方法名称: -(NSString *)SOAPString
 * 功能描述: 将对象转成SOAPString
 * 输入参数:
 * 输出参数: NSString
 * 返回值:
 * 其它说明:
 *****************************************************************************/
-(NSString *)SOAPString;

/*****************************************************************************
 * 方法名称: -(NSDictionary *)objectDictionary
 * 功能描述: 将对象转成Dictionary
 * 输入参数:
 * 输出参数: NSDictionary
 * 返回值:
 * 其它说明:
 *****************************************************************************/
-(NSDictionary *)objectDictionary;


#pragma mark - New Object with properties of another Object

/*****************************************************************************
 * 方法名称: -(id)initWithObject:(NSObject *)oldObject error:(NSError **)error
 * 功能描述: 将旧的对象（oldObject）生成新的对象返回
 * 输入参数:
 * 输出参数: id
 * 返回值:
 * 其它说明:
 *****************************************************************************/
-(id)initWithObject:(NSObject *)oldObject error:(NSError **)error;

#pragma mark - Base64 Encode/Decode

/*****************************************************************************
 * 方法名称: +(NSString *)encodeBase64WithData:(NSData *)objData
 * 功能描述: 加密转码
 * 输入参数:
 * 输出参数: NSString
 * 返回值:
 * 其它说明:
 *****************************************************************************/
+(NSString *)encodeBase64WithData:(NSData *)objData;

/*****************************************************************************
 * 方法名称: +(NSData *)base64DataFromString:(NSString *)string
 * 功能描述: 加密转码
 * 输入参数:
 * 输出参数: NSData
 * 返回值:
 * 其它说明:
 *****************************************************************************/
+(NSData *)base64DataFromString:(NSString *)string;

@end

@interface SOAPObject : NSObject
@property (nonatomic, retain) id Header;
@property (nonatomic, retain) id Body;
@end