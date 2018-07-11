package com.pro.sdk.wechat;

public class Constants {
	private static  String APP_ID  = "" ;
	private static  String MCH_ID  = "1340755901" ;
	private static  String API_KEY = "05bAAE67E11E1AC36161A50B0FA55480" ;
	private static  String AppSecret = "" ;
	private static  String APP_SIGN  = "18f0ea1d06e9e7ab58ae1c5f464b1839" ;// 签名字段
	
	public static void SetAPP_ID(String appid){
		APP_ID = appid;
	}
	
	public static String GetAPP_ID(){
		return APP_ID;
	}
	
	public static void SetSECRET(String Secret){
		AppSecret = Secret;
	}
	
	public static String GetSECRET(){
		return AppSecret;
	}
	
	public static String GetMCH_ID(){
		return MCH_ID;
	}
	
	public static String GetAPI_KEY(){
		return API_KEY;
	}
	
	public static String GetAPP_SIGN(){
		return APP_SIGN;
	}
	
	
}
