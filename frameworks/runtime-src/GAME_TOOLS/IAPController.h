
//
//  IAPController.h
//  HongZhong_mz
//
//  Created by SJ on 16/9/19.
//
//

#ifndef IAPController_h
#define IAPController_h
#import <UIKit/UIKit.h>
#import <StoreKit/StoreKit.h>

typedef void(^IAPPayCallBack)(NSString*);

@interface IAPController : UIViewController<SKPaymentTransactionObserver,SKProductsRequestDelegate,UIAlertViewDelegate>{
//    NSString *receipt ;
    NSString *productID ;
    UIAlertView *remoteAlertView;
}

+ (IAPController *) getInstance;

@property (nonatomic, readwrite, retain) id GViewController;
@property (nonatomic ,strong) IAPPayCallBack iapPayCallBack;
@property (nonatomic ,strong) NSString *receipt ;

- (void)IAPPay:(NSString*)goodsid_in;

- (void)START_IAP:(void(^)(NSString*))callfunc; // 为场景注册 支付回调
- (void)PAUSE_IAP;                              // 切换场景后 暂停回调

- (void)check_Receipt;
- (void)clean_Receipt;

- (void)didInFinshLaunching;
- (void)doIAPPay_Callback_lua:(NSString*)p_receipt;

@end

#endif /* IAPController_h */
