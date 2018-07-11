package com.pro.sdk.yixin;

import im.yixin.sdk.api.BaseReq;
import im.yixin.sdk.api.IYXAPI;
import android.content.Intent;


public class YXManager {
	
	private static YXManager mYXManager = new YXManager();
	private IYXAPI api;
	
	public static YXManager instance() {
		return mYXManager;
	}
	
	public String GetAppID() {
		return "";//Constants.APP_ID;
	}
	
	public void SetApi(IYXAPI api) {
		this.api = api;
	}


//	public boolean HandleIntent(Intent intent,IYXAPIEventHandler handler) {
//		if(api == null) {
//			return false;
//		}
//		return api.handleIntent(intent,handler);
//	}

	public boolean IsYXAppInstalled() {
		if(api == null) {
			return false;
		}
//		return api.isYXAppInstalled();
		return api.isYXAppInstalled();
	}

	public boolean IsYXAppSupportAPI() {
		if(api == null) {
			return false;
		}
//		return api.isYXAppSupportAPI();
		return true;
	}
	
	public boolean SendReq(BaseReq req) {
		if(api == null) {
			return false;
		}
//		return api.sendReq(req);
		return api.sendRequest(req);
	}	
}
