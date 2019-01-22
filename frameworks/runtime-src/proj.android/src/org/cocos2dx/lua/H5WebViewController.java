package org.cocos2dx.lua;

import android.content.Context;
import android.content.Intent;

public class H5WebViewController {
	private static H5WebViewController instance ;
	public static H5WebViewController getInstance(){
		if(instance == null){
			instance = new H5WebViewController();
		}
		
		return instance;
	}
	
	
	private Context mContext;
	public void init(Context mContext){
		this.mContext = mContext;
	}
	
	public void start2Activity(String url ,int ori){
		Intent intent = new Intent(this.mContext, H5Activity.class);
		intent.putExtra("orientation", ori);
		intent.putExtra("url", url);
		this.mContext.startActivity(intent);
	}
	
	//
	public static void Jni_StartH5Activity(String url ,int ori){
		 H5WebViewController.getInstance().start2Activity(url, ori);
	}
}
