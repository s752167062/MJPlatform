package com.pro.sdk.aliPush;



import com.alibaba.sdk.android.push.CloudPushService;
import com.alibaba.sdk.android.push.CommonCallback;
import com.alibaba.sdk.android.push.noonesdk.PushServiceFactory;

import android.content.Context;
import android.util.Log;
public class AliPushMain {
    private static final String TAG = "longma";
    private static AliPushMain instance= null ;
	private Context mContext = null;
	private static CloudPushService mPushService;
	private static String deviceID = null;
	private boolean isSuccess = false;

	public static AliPushMain getInstance(){
		if(instance == null){
			instance = new AliPushMain();
		}
		return instance;
	}

	public void initWithCreate(Context context){
		this.mContext = context;
		initCloudChannel(context);
	}

    /**
     * 初始化云推送通道
     * @param applicationContext
     */
    private void initCloudChannel(Context context) {
        PushServiceFactory.init(context);
        mPushService = PushServiceFactory.getCloudPushService();
        mPushService.register(context, new CommonCallback() {
            @Override
            public void onSuccess(String response) {
                Log.d(TAG, "init cloudchannel success");
                deviceID = mPushService.getDeviceId();
                Log.d(TAG,deviceID);

                isSuccess = true;
            }
            @Override
            public void onFailed(String errorCode, String errorMessage) {
                Log.d(TAG, "init cloudchannel failed -- errorcode:" + errorCode + " -- errorMessage:" + errorMessage);
                isSuccess = true;
            }
        });
    }

    public static String getDeviceId(){
    	if (deviceID != null && !deviceID.equals("")){
    		return deviceID;
    	}
    	
    	return "";
    }

    public static void bindAccount(String accountID){
    	if (getInstance().isSuccess){
    		mPushService.bindAccount(accountID,null);
    	}
    }

    public static void unbindAccount(){
    	if (getInstance().isSuccess){
    		mPushService.unbindAccount(null);
    	}
    }

}