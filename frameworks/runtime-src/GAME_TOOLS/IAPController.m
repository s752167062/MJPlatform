//
//  IAPController.m
//  HongZhong_mz
//
//  Created by SJ on 16/9/19.
//
//

#import <Foundation/Foundation.h>
#import "IAPController.h"

@interface IAPController()

@end

static IAPController* instance = nil;
@implementation IAPController


+ (IAPController *) getInstance{
    if(instance == nil){
        instance = [[IAPController alloc] init];
        [instance retain];
    }
    
    return instance;
}

-(id)init{
    if(self=[super init]){
       self.iapPayCallBack = nil ;
        NSLog(@"Add监听 ");
    }
    return self;
}

- (void)didInFinshLaunching{
    [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
}

//回调
- (void)doIAPPay_Callback_lua:(NSString*)p_receipt{
    if (self.iapPayCallBack != nil) {
        self.iapPayCallBack(p_receipt);
    }else{
        
    }
}

// 为场景注册 支付回调 同时检查是否存在 未处理的 凭证
- (void)START_IAP:(void(^)(NSString*))callfunc{
    self.iapPayCallBack = callfunc;
    [self check_Receipt];
}

// 切换场景后 暂停回调
- (void)PAUSE_IAP{
    self.iapPayCallBack = nil;
}


//检查凭证
-(void)check_Receipt{
    if (self.receipt != NULL || self.receipt.length > 0) {
        // 透传凭证到 lua
        [self doIAPPay_Callback_lua:self.receipt];
    }

}

//清除凭证
-(void)clean_Receipt{
    self.receipt = @"";
}


//支付
- (void)IAPPay:(NSString*)goodsid_in{
    productID = goodsid_in; //ProductId应该是事先在 itunesConnect中添加好的，已存在的付费项目。否则查询会失败。
    NSLog(@"商品ID  %@" , productID);
    
    if([SKPaymentQueue canMakePayments]){
        [self requestProductData:productID];
    }else{
        [self showAlertMessage:@"请先允许本程序内付费"];
        [self doIAPPay_Callback_lua:@"0,no permission for pay"];
    }
}


- (void)requestProductData:(NSString *)productIdentifier{
    NSLog(@"--请求对应的产品信息--");
    NSArray *product = [[NSArray alloc] initWithObjects:productIdentifier, nil ];
    
    NSSet *nsset = [NSSet setWithArray:product];
    SKProductsRequest *request = [[SKProductsRequest alloc] initWithProductIdentifiers:nsset];
    request.delegate = self;
    [request start];
    [self ShowAlertMsg:@"正在购买,请稍后..."] ;
//    [self doIAPPay_Callback_lua:@"0,wait for paying"];
}

- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response{
    NSLog(@"--收到产品反馈消息--");
    //[self CloseAlert];
    
    NSArray *product = response.products;
    if([product count] == 0){
        [self showAlertMessage:@"无法获取产品信息,请重试"];
        return;
    }
    
    NSLog(@"productID  :%@" , response.invalidProductIdentifiers);
    NSLog(@"产品付费数量 :%d" , [product count]);
    
    SKProduct *p = nil;
    for (SKProduct *pro in product) {
        NSLog(@"%@", [pro description]);
        NSLog(@"%@", [pro localizedTitle]);
        NSLog(@"%@", [pro localizedDescription]);
        NSLog(@"%@", [pro price]);
        NSLog(@"%@", [pro productIdentifier]);
        
        if([pro.productIdentifier isEqualToString:productID]){
            p = pro;
        }
    }
    
    SKPayment *payment = [SKPayment paymentWithProduct:p];
    
    NSLog(@"--发送购买请求--");
    [[SKPaymentQueue defaultQueue] addPayment:payment];
}

- (void)request:(SKRequest *)request didFailWithError:(NSError *)error{
    NSLog(@"--错误--:%@", error);
    [self CloseAlert];
    [self showAlertMessage:[error localizedDescription]];
}

- (void)requestDidFinish:(SKRequest *)request{
    NSLog(@"--反馈信息结束--:%@",request);
}


-(NSString*)DataTOjsonString:(id)object
{
    NSString *jsonString = nil;
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:object
                                                       options:NSJSONWritingPrettyPrinted // Pass 0 if you don't care about the readability of the generated string
                                                         error:&error];
    if (! jsonData) {
        NSLog(@"Got an error: %@", error);
    } else {
        jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
    return jsonString;
}

- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions{
    NSLog(@"JIAOYIJIEGUO");
    if([transactions count] <= 0 )
    {
         [self CloseAlert];
    }
    for(SKPaymentTransaction *tran in transactions){
        
        switch (tran.transactionState) {
            case SKPaymentTransactionStatePurchased:
                NSLog(@"交易完成");
                [self showAlertMessage:@"支付完成" ];
                self.receipt = [tran.transactionReceipt base64Encoding];

                [self checkReceiptIsValid];//把self.receipt发送到服务器验证是否有效
                [self completeTransaction:tran];
                break;
            case SKPaymentTransactionStatePurchasing:
                NSLog(@"商品添加进列表");
                break;
            case SKPaymentTransactionStateRestored:
                NSLog(@"已经购买过商品");
                [self completeTransaction:tran];
                break;
            case SKPaymentTransactionStateFailed:
                [self failedTransaction:tran];
                break;
            default:
                NSLog(@"Unexpected transaction state %@", @(tran.transactionState)); // for debug
                [self CloseAlert];
                break;
        }
    }
}

//交易结束
- (void)completeTransaction:(SKPaymentTransaction *)transaction{
    NSLog(@"交易结束");
    [self CloseAlert];
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];//执行后APPSTORE 才不会重复发
}

//失败
- (void)failedTransaction:(SKPaymentTransaction *)transaction {
    NSLog(@"交易失败");
    [self CloseAlert];
    if (transaction.error != NULL) {
        switch (transaction.error.code) {
#ifdef __IPHONE_11_0
            case 0:
                NSLog(@"用户取消支付");
                [self showAlertMessage: @"取消支付"];
                break;
#endif
            case SKErrorPaymentInvalid:
                [self showAlertMessage: @"订单无效(如有疑问，可以询问苹果客服)"];
                break;
            case SKErrorPaymentNotAllowed:
                [self showAlertMessage: @"当前苹果设备无法购买商品(如有疑问，可以询问苹果客服)"];
                break;
            case SKErrorStoreProductNotAvailable:
                [self showAlertMessage: @"当前商品不可用" ];
                break;
            case SKErrorPaymentCancelled:
                NSLog(@"用户取消支付");
                [self showAlertMessage: @"取消支付"];
                break;
            case SKErrorClientInvalid:
                [self showAlertMessage: @"当前苹果账户无法购买商品(如有疑问，可以询问苹果客服)"];
                break;
//            case SKErrorCloudServicePermissionDenied:
//                [self showAlertMessage: @"用户不允许访问云服务信息(如有疑问，可以询问苹果客服)"];
//                break;
//            case SKErrorCloudServiceNetworkConnectionFailed:
//                [self showAlertMessage: @"设备无法连接到云服务(如有疑问，可以询问苹果客服)"];
//                break;
//            case SKErrorCloudServiceRevoked:
//                [self showAlertMessage: @"用户已取消使用此云服务的权限(如有疑问，可以询问苹果客服)"];
//                break;
            default:
                NSLog(@"未知错误");
                [self showAlertMessage: [NSString stringWithFormat:@"购买失败未知错误 :%ld" , transaction.error.code ]];
                break;
        }

    }
    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
}

//向服务器验证Apple服务器返回的购买凭证的有效性
- (void)checkReceiptIsValid{
    //把self.receipt发送到服务器验证是否有效
    if (self.receipt && self.receipt.length > 0) {
        // 透传凭证到 lua
        [self doIAPPay_Callback_lua:self.receipt];
    }else{
        NSLog(@"凭证 nullptr");
    }
    
    /**
     发送凭证失败的处理
     如果出现网络问题，导致无法验证。我们需要持久化保存购买凭证，在用户下次启动APP的时候在后台向服务器再一次发起验证，直到成功然后移除该凭证。
     保证如下define可在全局访问：*/
}



- (void)viewDidLoad{
    NSLog(@"Add监听 ViewDidLoad ");
    [super viewDidLoad];
    [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
}

- (void)dealloc{
    NSLog(@"移除监听 ViewDidLoad ");
    [[SKPaymentQueue defaultQueue] removeTransactionObserver:self];
    [super dealloc];
}



///////////////////////////////////////////////////////////////////////////////////////////////
- (void)showAlertMessage:(NSString*)msg{
    UIAlertView * mAlert = [[UIAlertView alloc] initWithTitle:@"提示"
                                                      message:msg
                                                     delegate:nil
                                            cancelButtonTitle:@"确定"
                                            otherButtonTitles:nil, nil];
    [mAlert show];
}


-(void)ShowAlertMsg:(NSString *)message{
    
    if (remoteAlertView) {
        [remoteAlertView release];
    }
    remoteAlertView =  [[UIAlertView alloc] initWithTitle:@"提示"
                                                  message:message
                                                 delegate:self
                                        cancelButtonTitle:nil
                                        otherButtonTitles:nil, nil ];
    
    UIActivityIndicatorView *aiView = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(125.0, 80.0, 30.0, 30.0)];
    aiView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
    //check if os version is 7 or above. ios7.0及以上UIAlertView弃用了addSubview方法
    if ([[[UIDevice currentDevice] systemVersion] compare:@"7.0"] != NSOrderedAscending) {
        [remoteAlertView setValue:aiView forKey:@"accessoryView"];
    }else{
        [remoteAlertView addSubview:aiView];
    }
    [remoteAlertView show];
    [aiView startAnimating];
    [aiView release];
}

- (void)CloseAlert{
    if (remoteAlertView) {
        [remoteAlertView dismissWithClickedButtonIndex:0 animated:YES];
        [remoteAlertView release];
        remoteAlertView = nullptr;
    }
}


@end
