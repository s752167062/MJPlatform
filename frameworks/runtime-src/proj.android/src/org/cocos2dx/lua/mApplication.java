package org.cocos2dx.lua;

import com.pro.sdk.aliPush.AliPushMain;

import android.app.Application;

public class mApplication extends Application {
	@Override
	public void onCreate() {
		// TODO Auto-generated method stub
		super.onCreate();
		AliPushMain.getInstance().initWithCreate(this);
	}
}
