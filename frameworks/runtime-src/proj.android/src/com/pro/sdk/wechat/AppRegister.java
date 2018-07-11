package com.pro.sdk.wechat;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;

public class AppRegister extends BroadcastReceiver {

	@Override
	public void onReceive(Context context, Intent intent) {
		WeCharSDKController.getInstance().reInitWrChar(context);
	}
}
