package com.pro.sdk.yixin;

public class YXSDKLua {
	
	public static void Jni_YXLogin(final int callback) {
		YXSDKController.getInstance().mYXLogin(callback);
	}
	
	public static void Jni_YXTxtShare(final String msg, final int share_type){
		YXSDKController.getInstance().mYXTxtShare(msg, share_type);
	}
	
	public static void Jni_YXUrlShare(final String title , final String desc , final String url, final int share_type,final int callback){
		YXSDKController.getInstance().mYXUrlShare(title, desc, url, share_type, callback);
	}
	
	public static void Jni_YXImageShare(final String imagePath ,final int share_type, final int callback){
		YXSDKController.getInstance().mYXImageShare(imagePath, share_type,callback);
	}
	
	public static void Jni_YXMergeImageShare(final String imagePath ,final String imagePath_samll , final int point_x ,final int point_y , final int size_width ,final int size_height ,final int share_type , final int callback){
		YXSDKController.getInstance().mYXMergeImageShare(imagePath, imagePath_samll, point_x , point_y , size_width, size_height , share_type ,callback);
	}
	
	public static void Jni_YXMergeImageShareByJSON(final String json_data ,final int share_type ,final int callback){
		YXSDKController.getInstance().mYXMergeImageShareByJSON(json_data ,share_type ,callback);
	}

	public static boolean Jni_YXClientExit(){
		return YXSDKController.getInstance().isYXClientExit();
	}
}
