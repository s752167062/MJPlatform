package com.pro.sdk.liaobei;

public class LBSDKLua {
	
	public static void Jni_LBLogin(final String scope , final String state , final int callback) {
		LBSDKController.getInstance().mLBLogin(scope ,state ,callback);
	}
	
	public static void Jni_LBUrlShare(final String title , final String context , final String imgurl , final String weburl , final int time , final int callback) {
		LBSDKController.getInstance().mLBUrlShare(title ,context ,imgurl ,weburl ,time ,callback);
	}
	
	public static void Jni_LBImgShare(final String imagepath , final int callback) {
		LBSDKController.getInstance().mLBImgShare(imagepath ,callback);
	}
	
	public static void Jni_LBAppShare(final String title , final String context , final String imgurl , final String and_sc , final String ios_sc, final int time , final int callback) {
		LBSDKController.getInstance().mLBJumpAppShare(title ,context ,imgurl ,and_sc ,ios_sc ,time ,callback);
	}

	public static boolean Jni_LBClientExist(){
		return LBSDKController.getInstance().mLBClientExist();
	}
	
	// public static void Jni_LBTxtShare(final String msg, final int share_type){
	// 	LBSDKController.getInstance().mLBTxtShare(msg, share_type);
	// }
	
	// public static void Jni_LBUrlShare(final String title , final String desc , final String url, final int share_type,final int callback){
	// 	LBSDKController.getInstance().mLBUrlShare(title, desc, url, share_type, callback);
	// }
	
	// public static void Jni_LBImageShare(final String imagePath ,final int share_type, final int callback){
	// 	LBSDKController.getInstance().mLBImageShare(imagePath, share_type,callback);
	// }
	
	// public static void Jni_LBMergeImageShare(final String imagePath ,final String imagePath_samll , final int point_x ,final int point_y , final int size_width ,final int size_height ,final int share_type , final int callback){
	// 	LBSDKController.getInstance().mLBMergeImageShare(imagePath, imagePath_samll, point_x , point_y , size_width, size_height , share_type ,callback);
	// }
	
	// public static void Jni_LBMergeImageShareByJSON(final String json_data ,final int share_type ,final int callback){
	// 	LBSDKController.getInstance().mLBMergeImageShareByJSON(json_data ,share_type ,callback);
	// }
}
