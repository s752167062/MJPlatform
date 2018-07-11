package com.pro.nowpay;


public class NowPaySDKLua {
	public static void Jni_NowPay(final String json_pay , final int callback) {
		NowPayController.getInstance().nowPay(json_pay, callback);
	}
}
