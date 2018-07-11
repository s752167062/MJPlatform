//
//  YunCeng.h
//  YunCeng
//  ..
//  Created by chuanshi.zl on 15/5/19.
//  Copyright (c) 2015年 Alibaba Cloud Computing Ltd. All rights reserved.
//
#ifndef __IPHONE_5_0
#warning "This project uses features only available in iOS SDK 5.0 and later."
#endif

#ifdef __OBJC__
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "YunCeng.h"

FOUNDATION_EXPORT double YunCengVersionNumber;

FOUNDATION_EXPORT const unsigned char YunCengVersionString[];

typedef NS_ENUM(NSInteger, YC_CODE) {
    YC_OK = 0,	 /* *< Success */
    
    YC_ERR_NETWORK      = 1000,       /* 网络通信异常 */
    YC_ERR_NETWORK_CONN = 1001,       /* 网络连接失败 */
    
    YC_ERR_KEY            = 2000,     /* appkey错误 */
    YC_ERR_KEY_SECBUF     = 2001,
    YC_ERR_KEY_LEN_MISMATCH   = 2002,
    YC_ERR_KEY_CLEN_MISMATCH  = 2003,
    
    YC_ERR_API_PROXY = 3000,          /* 3000~3999 服务端错误 */
    YC_ERR_RESP      = 4000,            /* 服务端响应错误        */
    YC_ERR_FORMAT    = 4001,            /* 服务端返回内容格式异常  */
    
    YC_ERR_INTR       = 9000,         /* SDK内部错误          */
    YC_ERR_INTR_NOMEM = 9001,         /* 内存不足    */
    YC_ERR_TIMED_WAITING = 9002,      /* 任务进行中，需等待 */
    YC_ERR_BUFFER_TOO_SMALL = 9003,   /* 缓冲区太小 */
    YC_ERR_PARAMETER  = 9004          /* 参数错误 */
};

@interface YunCeng : NSObject

/*!
 *@brief 初始化云层SDK
 *@param appKey 控制台对应的appkey
 *@param token 玩家唯一标识，类似与手机号
 *@param token_rank 玩家等级标识 (0 - 100)
 *@return 函数成功返回0，否则返回错误码
 */
+(int) initEx:(const char *)appKey : (const char *) token : (int) token_rank;

/*!
 *@brief 获取动态IP地址
 *@param group_name 控制台上配置的用户分组ID
 *@param token 玩家唯一标识，类似与手机号
 *@param dport 控制台配置的转发端口
 *@param ip_buf 未开启隧道模式时，返回group_name对应的分组IP，开启隧道模式，则返回隧道IP
 *@param port_buf 未开启隧道模式时，返回传入的端口，开启隧道模式时，返回隧道端口
 *@return 当该函数调用成功时返回0，否则返回错误号码
 */
+(int) getNextIPByGroupNameEx : (const char *)group_name : (const char *)token : (const char *)dport : (char *)ip_buf : (int)ip_buf_len : (char *)port_buf : (int)port_buf_len; 

/*!
 *@brief 生成路由包
 *@param ip_map 控制台配置的IP映射
 *@param port 源站端口
 *@param route_pkg_buf 出参，路由包信息，请确保route_pkg指向的buf大小至少28字节
 *@param pkg_buf_len 表示 route_pkg的内存大小指针，函数返回时，该值会被修改为route_pkg的大小
 *@return 成功返回0，失败返回-1
 */
+(int) buildRoutePkg:(int) ip_map :(int) port : (unsigned char *) route_pkg_buf : (int *)pkg_buf_len;

/*! @brief 网络诊断
 * 注意：1、仅支持单线程调用；2、需要在getNextIPByGroupNameEx之后调用，否则会出现未知错误！！！
 *@param ip         入参，需要诊断的ip
 *@param port       入参，需要诊断的端口
 *@param callback   入参，回调Block，返回诊断数据
 *@return 成功返回0，失败返回其它
 */
+(int) startNetworkDiagnosis:(const char *)ip : (int)port : (void (^) (NSString* diagnosisResult))callback;

/** 获取签名token
 * 如果成功，返回签名，失败则返回nil 
 */
+ (NSString*) getSecToken;

/*! @brief UMID异步获取接口
 * 成功返回0，失败返回其它
 * @param listener 异步回调接口
 * @return YC_CODE
 */
//+ (int) getUMIDAsync: (void (^) (NSString* securityToken, NSError* error)) listener;

/*! @brief 初始化云层SDK
 * appKey 控制台对应的appkey
 * 函数成功返回0，否则返回错误码
 */
//+(int) init:(const char *)appKey;

/*! @brief 获取动态IP地址
 * group_name 控制台配置的分组ID
 * ip_buf 如果成获取IP，则返回控制台配置的IP节点
 * ip_buf_len ip_buf对应的大小
 * 如果成功则返回0，否则返回错误码
 */
//+(int) getNextIPByGroupName:(const char *)group_name : (char *) ip_buf : (int) ip_buf_len;

/** 获取动态IP地址及运营商信息
 * group_name 控制台上配置的用户分组ID
 * ip_buf 返回控制台配置的IP节点
 * ip_len 表示ip_buf的大小
 * ip_info_buf 返回出口IP的运营商信息buf
 * ip_info_len ip_inf_buf的大小
 */
//+(int) getNextIPInfoByGroupName:(const char *)group_name : (char *) ip_buf : (int) ip_len : (char *)ip_info_buf : (int) ip_info_len;
@end


FOUNDATION_EXPORT NSString *const YUNCENG_EXCEPTION_NAME;


@interface YunCengException : NSException {
}

@property(readonly) YC_CODE code;

-(instancetype) init:(YC_CODE) code;

+(instancetype) exceptionWithCode:(YC_CODE) code;
@end


#endif

/*! @brief 初始化云层SDK
 * appKey:控制台对应的appkey
 * token: 玩家唯一标识，类似与手机号
 * token_rank: 玩家等级标识 (0 - 100)
 * 函数成功返回0，否则返回错误码
 */
int YunCeng_InitEx(const char *app_key, const char *token, int token_rank);

/*! @brief 获取动态IP地址
 * group_name 分组ID
 * token 用户唯一标识
 * dport 服务器端口(通过后台配置的转发端口)
 * ip_buf 出参，存放动态获取的IP
 * ip_buf_len 入参，ip_buf缓存的大小
 * port_buf 出参，存在动态分配的端口
 * port_buf_len, 入参， port_buf缓存的大小
 * @return YC_CODE
 */
int YunCeng_GetNextIPByGroupNameEx(const char *group_name, const char * token, const char *dport, char *ip_buf, int ip_buf_len, char *port_buf, int port_buf_len);

/*! @brief 获取动态IP地址及运营商信息 
 * 成功返回0，失败返回-1
 * ip_map，控制台配置的IP映射
 * port 目标端口
 * route_pkg_buf 出参，路由包信息，请确保route_pkg指向的buf大小至少28字节
 * pkg_buf_len 表示 route_pkg的内存大小指针，函数返回时，该值会被修改为route_pkg的大小
 * @return YC_CODE
 */
int YunCeng_BuildRoutePkg(int ip_map, int port, unsigned char *route_pkg_buf, int *pkg_buf_len);

/*! @brief 初始化
 * app_key 控制台生成的appKey
 * @return YC_CODE
 */
//int YunCeng_Init(const char *app_key);

/*! @brief 获取动态IP地址
 * group_name
 * ip_buf 出参，存放获取的动态IP地址
 * ip_buf_len 入参，ip_buf的缓存的大小
 * @return YC_CODE
 */
//int YunCeng_GetNextIPByGroupName(const char *group_name, char *ip_buf, int ip_buf_len);

/*! @brief 获取动态IP地址及运营商信息 
 * group_name
 * ip_buf 出参，存放获取的动态IP地址
 * ip_buf_len, 入参, ip_buf缓存的大小
 * ip_buf_info 出参，端IP运营商信息
 * ip_info_buf_len, 入参，ip_buf_info缓存大小
 * @return YC_CODE
 */
//int YunCeng_GetNextIPInfoByGroupName(const char *group_name, char *ip_buf, int ip_buf_len, char *ip_info_buf, int ip_info_buf_len);
