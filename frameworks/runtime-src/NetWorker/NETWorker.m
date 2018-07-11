//
//  NETWorker.m
//  YYDemo
//
//  Created by SJ on 2017/4/25.
//  Copyright © 2017年 SJ. All rights reserved.
//
//
//  通知的使用
//      创建通知          [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(internetConnection) name:kReachabilityChangedNotification object:nil];
//      发送              [[NSNotificationCenter defaultCenter]postNotificationName:@"netStatus" object:nil userInfo:@{@"netType":@"notReachable"}];  --在 internetConnection 方法中发送
//      接受               [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(doWork:) name:@"netStatus" object:nil];
//                              -(void)doWork:(NSNotification*)text
//


#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "NETWorker.h"

#import "Reachability.h"
#import <CoreTelephony/CTCarrier.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>

//ipv6 检查
#define IOS_CELLULAR    @"pdp_ip0"
#define IOS_WIFI        @"en0"
#define IOS_VPN         @"utun0"
#define IP_ADDR_IPv4    @"ipv4"
#define IP_ADDR_IPv6    @"ipv6"
#import <ifaddrs.h>
#import <arpa/inet.h>
#import <net/if.h>

//网路状态
typedef enum NET_STATE{
    NETM_STATE_DISABLE  = 1000 ,
    NETM_STATE_WIFI     = 1001 ,
    NETM_STATE_MOBILE   = 1002 ,
    NETM_STATE_DEFAULT  = 1003 ,
}NET_STATE;

//网络类型
typedef enum NET_TYPE{
    NETM_TYPE_NULL   = 10000 ,
    NETM_TYPE_2G     = 10002 ,
    NETM_TYPE_3G     = 10003 ,
    NETM_TYPE_4G     = 10004 ,
    NETM_TYPE_WIFI   = 10010 ,
    NETM_TYPE_DEFAULT= 10011 ,
}NET_TYPE;

//回调
typedef void(^NetStatusCallBack)(int);




@interface NETWorker (){
    NET_STATE net_status ;
    NET_TYPE  net_type   ;
    bool is_ipv6 ;
}

@property (nonatomic ,strong) NetStatusCallBack statusCallback;
@property(nonatomic  ,strong) Reachability *reachability;

//@property (nonatomic) NET_STATE net_status ;
//@property (nonatomic) NET_TYPE  net_type   ;

@end

@implementation NETWorker

static NETWorker* instance = NULL;

+(NETWorker*) getInstance{
    if (instance == NULL) {
        instance = [[NETWorker alloc] init];
    }
    return instance;
}

-(id)init{
    if (self = [super init]) {
        NSLog(@" NETWorker 初始化");
        
        self->net_status = NETM_STATE_DISABLE;
        self->net_type   = NETM_TYPE_NULL;
        
        is_ipv6 = false;
        [self checkIPV];//网络检查是否是 ipv6
    }
    return self;
}

- (void)dealloc {
    [super dealloc];
}


- (void) registerNetWorkListener:(void(^)(int))callfunc{
    if(callfunc != nil){
        self.statusCallback = callfunc ;
    }
}

- (void) unregisterNetWorkListener{
    self.statusCallback = nil;
}


- (bool) isNetEnable{
    return net_status != NETM_STATE_DISABLE;
}

- (int) getNetWorkType{
    return [self getNetconnType];
}


- (void) onNetWorkStatusChangeCallBack:(int)status{
    NSLog(@" >> onNetWorkStatusChangeCallBack %d",status);
    if (status && self.statusCallback) {
        self.statusCallback(status);
    }
}



///////////////// launch
- (BOOL) application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions{
    
    //创建通知
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(internetConnection) name:kReachabilityChangedNotification object:nil];
    
    //初始化可达性
    self.reachability = [Reachability reachabilityForInternetConnection];
    [self.reachability startNotifier];    //开始监听
    [self internetConnection];

    return true;
}


-(void)internetConnection
{   //网络连接现状
    [self checkIPV];//网络切换重新检查是否是 ipv6
    NetworkStatus status =[self.reachability currentReachabilityStatus];
    switch (status) {
        case NotReachable:
            NSLog(@"没有网络");
            self->net_status = NETM_STATE_DISABLE;
            break;
        case ReachableViaWiFi:
            NSLog(@"wifi连接");
            self->net_status = NETM_STATE_WIFI;
            break;
        case ReachableViaWWAN:
            NSLog(@"移动蜂窝网络");
            self->net_status = NETM_STATE_MOBILE;
            break;
        default:
            self->net_status = NETM_STATE_DEFAULT;
            NSLog(@"默认不知道是啥网络");
            break;
    }
    
    [self onNetWorkStatusChangeCallBack: self->net_status];
    
}

- (int)getNetconnType{
    
    NSString *netconnType = @"";
    Reachability *reach = [Reachability reachabilityWithHostName:@"www.apple.com"];
    
    switch ([reach currentReachabilityStatus]) {
        case NotReachable:{
            netconnType = @"没有网络";
            self->net_type = NETM_TYPE_NULL;
            break;
        }
        case ReachableViaWiFi:{
            netconnType = @"Wifi";
            self->net_type = NETM_TYPE_WIFI;
            break;
        }
        case ReachableViaWWAN:{
            // // 手机自带网络 获取手机网络类型
            CTTelephonyNetworkInfo *info = [[CTTelephonyNetworkInfo alloc] init];
            NSString *currentStatus = info.currentRadioAccessTechnology;
            
            if ([currentStatus isEqualToString:@"CTRadioAccessTechnologyGPRS"]) {
                self->net_type = NETM_TYPE_2G;
                netconnType = @"GPRS";
            }else if ([currentStatus isEqualToString:@"CTRadioAccessTechnologyEdge"]) {
                self->net_type = NETM_TYPE_2G;
                netconnType = @"2.75G EDGE";
            }else if ([currentStatus isEqualToString:@"CTRadioAccessTechnologyWCDMA"]){
                self->net_type = NETM_TYPE_3G;
                netconnType = @"3G";
            }else if ([currentStatus isEqualToString:@"CTRadioAccessTechnologyHSDPA"]){
                self->net_type = NETM_TYPE_3G;
                netconnType = @"3.5G HSDPA";
            }else if ([currentStatus isEqualToString:@"CTRadioAccessTechnologyHSUPA"]){
                self->net_type = NETM_TYPE_3G;
                netconnType = @"3.5G HSUPA";
            }else if ([currentStatus isEqualToString:@"CTRadioAccessTechnologyCDMA1x"]){
                self->net_type = NETM_TYPE_2G;
                netconnType = @"2G";
            }else if ([currentStatus isEqualToString:@"CTRadioAccessTechnologyCDMAEVDORev0"]){
                self->net_type = NETM_TYPE_3G;
                netconnType = @"3G";
            }else if ([currentStatus isEqualToString:@"CTRadioAccessTechnologyCDMAEVDORevA"]){
                self->net_type = NETM_TYPE_3G;
                netconnType = @"3G";
            }else if ([currentStatus isEqualToString:@"CTRadioAccessTechnologyCDMAEVDORevB"]){
                self->net_type = NETM_TYPE_3G;
                netconnType = @"3G";
            }else if ([currentStatus isEqualToString:@"CTRadioAccessTechnologyeHRPD"]){
                self->net_type = NETM_TYPE_3G;
                netconnType = @"HRPD";
            }else if ([currentStatus isEqualToString:@"CTRadioAccessTechnologyLTE"]){
                self->net_type = NETM_TYPE_4G;
                netconnType = @"4G";
            }
            break;
        }
        default:{
            netconnType = @"默认不知道啥类型的网络";
            self->net_type = NETM_TYPE_DEFAULT;
            break;
        }
    }
    
    return self->net_type;
}


///////////////// ipv6
- (NSDictionary *)getIPAddresses
{
    NSMutableDictionary *addresses = [NSMutableDictionary dictionaryWithCapacity:8];
    // retrieve the current interfaces - returns 0 on success
    struct ifaddrs *interfaces;
    if(!getifaddrs(&interfaces)) {
        // Loop through linked list of interfaces
        struct ifaddrs *interface;
        for(interface=interfaces; interface; interface=interface->ifa_next) {
            if(!(interface->ifa_flags & IFF_UP) /* || (interface->ifa_flags & IFF_LOOPBACK) */ ) {
                continue; // deeply nested code harder to read
            }
            const struct sockaddr_in *addr = (const struct sockaddr_in*)interface->ifa_addr;
            char addrBuf[ MAX(INET_ADDRSTRLEN, INET6_ADDRSTRLEN) ];
            if(addr && (addr->sin_family==AF_INET || addr->sin_family==AF_INET6)) {
                NSString *name = [NSString stringWithUTF8String:interface->ifa_name];
                NSString *type;
                if(addr->sin_family == AF_INET) {
                    if(inet_ntop(AF_INET, &addr->sin_addr, addrBuf, INET_ADDRSTRLEN)) {
                        type = IP_ADDR_IPv4;
                        NSLog(@"ipv4 %@",name);
                    }
                } else {
                    const struct sockaddr_in6 *addr6 = (const struct sockaddr_in6*)interface->ifa_addr;
                    if(inet_ntop(AF_INET6, &addr6->sin6_addr, addrBuf, INET6_ADDRSTRLEN)) {
                        type = IP_ADDR_IPv6;
                        NSLog(@"ipv6 %@",name);
                    }
                }
                if(type) {
                    NSString *key = [NSString stringWithFormat:@"%@/%@", name, type];
                    addresses[key] = [NSString stringWithUTF8String:addrBuf];
                }
            }
        }
        // Free memory
        freeifaddrs(interfaces);
    }
    return [addresses count] ? addresses : nil;
    
}


- (void)checkIPV
{
    NSArray *searchArray =
    @[ IOS_VPN @"/" IP_ADDR_IPv6,
       IOS_VPN @"/" IP_ADDR_IPv4,
       IOS_WIFI @"/" IP_ADDR_IPv6,
       IOS_WIFI @"/" IP_ADDR_IPv4,
       IOS_CELLULAR @"/" IP_ADDR_IPv6,
       IOS_CELLULAR @"/" IP_ADDR_IPv4 ] ;
    
    NSDictionary *addresses = [self getIPAddresses];
    if (addresses == nil) {
        is_ipv6 = NO;
        return ;
    }
    NSLog(@"addresses: %@", addresses);
    
    __block BOOL isIpv6 = NO;
    [searchArray enumerateObjectsUsingBlock:^(NSString *key, NSUInteger idx, BOOL *stop)
     {
         
         NSLog(@"---%@---%@---",key, addresses[key] );
         
         if ([key rangeOfString:@"ipv6"].length > 0  && ![[NSString stringWithFormat:@"%@",addresses[key]] hasPrefix:@"(null)"] ) {
             
             if ( ![addresses[key] hasPrefix:@"fe80"]) {
                 isIpv6 = YES;
             }
         }
         
     } ];
    
    is_ipv6 = isIpv6;
}

- (bool)isIPV6_NET
{
    return is_ipv6;
}

///////////////// other

- (void)showAlertMessage:(NSString*)msg{
    UIAlertView * mAlert = [[UIAlertView alloc] initWithTitle:@"提示" message:msg delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    [mAlert show];
}

@end
