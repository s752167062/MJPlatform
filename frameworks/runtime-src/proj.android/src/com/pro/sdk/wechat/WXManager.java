package com.pro.sdk.wechat;

import android.content.Intent;

import com.tencent.mm.opensdk.modelbase.BaseReq;
import com.tencent.mm.opensdk.openapi.IWXAPI;
import com.tencent.mm.opensdk.openapi.IWXAPIEventHandler;



public class WXManager {
	
	private static WXManager mWXManager = new WXManager();
	private IWXAPI api;
	
	public static WXManager instance() {
		return mWXManager;
	}
	
	public String GetAppID() {
		return "";//Constants.APP_ID;
	}
	
	public void SetApi(IWXAPI api) {
		this.api = api;
	}


	public boolean HandleIntent(Intent intent,IWXAPIEventHandler handler) {
		if(api == null) {
			return false;
		}
		return api.handleIntent(intent,handler);
	}

	public boolean IsWXAppInstalled() {
		if(api == null) {
			return false;
		}
		return api.isWXAppInstalled();
	}

	public boolean IsWXAppSupportAPI() {
		if(api == null) {
			return false;
		}
		return api.isWXAppSupportAPI();
	}
	
	public boolean SendReq(BaseReq req) {
		if(api == null) {
			return false;
		}
		return api.sendReq(req);
	}	
}
