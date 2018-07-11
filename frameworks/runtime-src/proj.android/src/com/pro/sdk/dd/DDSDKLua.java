package com.pro.sdk.dd;

public class DDSDKLua {
	
	public static void Jni_DDTxtShare(final String msg, final int share_type){
		DDSDKController.getInstance().mDDTxtShare(msg, share_type);
	}
	
	public static void Jni_DDUrlShare(final String title , final String desc , final String url, final int share_type,final int callback){
		DDSDKController.getInstance().mDDUrlShare(title, desc, url, share_type, callback);
	}
	
	public static void Jni_DDImageShare(final String imagePath ,final int share_type, final int callback){
		DDSDKController.getInstance().mDDImageShare(imagePath, share_type,callback);
	}
	
	public static void Jni_DDMergeImageShare(final String imagePath ,final String imagePath_samll , final int point_x ,final int point_y , final int size_width ,final int size_height ,final int share_type , final int callback){
		DDSDKController.getInstance().mDDMergeImageShare(imagePath, imagePath_samll, point_x , point_y , size_width, size_height , share_type ,callback);
	}
	
	public static void Jni_DDMergeImageShareByJSON(final String json_data ,final int share_type ,final int callback){
		DDSDKController.getInstance().mDDMergeImageShareByJSON(json_data ,share_type ,callback);
	}
	
	public static boolean Jni_DDCheckInstall(){
		return DDSDKController.getInstance().checkInstall();
	}
	
	public static boolean Jni_DDCheckSupport(){
		return DDSDKController.getInstance().checkSupport();
	}
}
