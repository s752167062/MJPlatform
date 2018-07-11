package com.pro.sdk.wechat;
/**
 * AndroidManifest.xml 中添加
 * 		<activity android:exported="true" android:launchMode="singleTop" android:name=".wxapi.WXEntryActivity"/> 
    	<activity android:exported="true" android:launchMode="singleTop" android:name=".wxapi.WXPayEntryActivity"/>
         
         <receiver android:name="com.pro.sdk.wechat.AppRegister">
            <intent-filter>
                <action android:name="com.tencent.mm.plugin.openapi.Intent.ACTION_REFRESH_WXAPP"/>
            </intent-filter>
        </receiver>
        
 * */
public class WeChatSDKLua {
	
	public static void Jni_WeChatLogin(final int callback) {
		WeCharSDKController.getInstance().mWeChatLogin(callback);
	}
	
	public static void Jni_WeChatTxtShare(final String msg, final int share_type){
		WeCharSDKController.getInstance().mWeChatTxtShare(msg, share_type);
	}
	
	public static void Jni_WeChatUrlShare(final String title , final String desc , final String url, final int share_type,final int callback){
		WeCharSDKController.getInstance().mWeChatUrlShare(title, desc, url, share_type, callback);
	}
	
	public static void Jni_WeChatImageShare(final String imagePath ,final int share_type, final int callback){
		WeCharSDKController.getInstance().mWeChatImageShare(imagePath, share_type,callback);
	}
	
	public static void Jni_WeChatMergeImageShare(final String imagePath ,final String imagePath_samll , final int point_x ,final int point_y , final int size_width ,final int size_height ,final int share_type , final int callback){
		WeCharSDKController.getInstance().mWeChatMergeImageShare(imagePath, imagePath_samll, point_x , point_y , size_width, size_height , share_type ,callback);
	}
	
	public static void Jni_WeChatMergeImageShareByJSON(final String json_data ,final int share_type ,final int callback){
		WeCharSDKController.getInstance().mWeChatMergeImageShareByJSON(json_data ,share_type ,callback);
	}

	public static boolean Jni_WeChatClientExit(){
		return WeCharSDKController.getInstance().mWeChatClientExit();
	}
	
	//
	public static void Jni_WeChatMiniProjectShareByJSON(final String json_data ,final int callback){
		WeCharSDKController.getInstance().mWeChatMiniProShare(json_data ,callback);
	}
	
	public static String Jni_WeChatCheckLaunchData(){
		return WeCharSDKController.getInstance().getLaunchData();
	}
	
	public static void Jni_WeChatCleanLaunchData(){
		WeCharSDKController.getInstance().setLaunchData(null);
	}
	
	public static void Jni_WeChatSetLaunchCallback(final int callback){
		WeCharSDKController.getInstance().setLaunchCallback(callback);
	}
}
