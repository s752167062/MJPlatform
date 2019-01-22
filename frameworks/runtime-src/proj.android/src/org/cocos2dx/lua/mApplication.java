package org.cocos2dx.lua;

import com.baidu.mapapi.SDKInitializer;
import com.pro.sdk.aliPush.AliPushMain;
import com.pro.sdk.baiduMap.LocationService;
import com.pro.sdk.liaobei.LBSDKController;
import android.app.Application;

public class mApplication extends Application {
	public LocationService locationService;
	
	@Override
	public void onCreate() {
		// TODO Auto-generated method stub
		super.onCreate();
		AliPushMain.getInstance().initWithCreate(this);
		
		locationService = new LocationService(getApplicationContext());
		SDKInitializer.initialize(getApplicationContext());

		LBSDKController.getInstance().initOnAppLication(this);
	}
}
