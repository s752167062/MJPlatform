package com.pro.sdk.wechat;

import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.security.MessageDigest;

import org.cocos2dx.lib.Cocos2dxHelper;
import org.cocos2dx.lib.Cocos2dxLuaJavaBridge;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import android.app.Activity;
import android.app.AlertDialog;
import android.content.Context;
import android.content.DialogInterface;
import android.content.DialogInterface.OnClickListener;
import android.content.Intent;
import android.content.pm.ApplicationInfo;
import android.content.pm.PackageInfo;
import android.content.pm.PackageManager;
import android.content.pm.Signature;
import android.content.res.AssetManager;
import android.graphics.Bitmap;
import android.graphics.Bitmap.CompressFormat;
import android.graphics.Bitmap.Config;
import android.graphics.BitmapFactory;
import android.graphics.Canvas;
import android.graphics.Color;
import android.graphics.Paint;
import android.graphics.Typeface;
import android.graphics.PorterDuff.Mode;
import android.graphics.PorterDuffXfermode;
import android.net.Uri;

import com.tencent.mm.opensdk.modelmsg.SendAuth;
import com.tencent.mm.opensdk.modelmsg.SendMessageToWX;
import com.tencent.mm.opensdk.modelmsg.WXImageObject;
import com.tencent.mm.opensdk.modelmsg.WXMediaMessage;
import com.tencent.mm.opensdk.modelmsg.WXMiniProgramObject;
import com.tencent.mm.opensdk.modelmsg.WXTextObject;
import com.tencent.mm.opensdk.modelmsg.WXWebpageObject;
import com.tencent.mm.opensdk.openapi.IWXAPI;
import com.tencent.mm.opensdk.openapi.WXAPIFactory;
import com.zhuzhi.zzqipai.R;

public class WeCharSDKController {
	private static WeCharSDKController instance = null;

	public static WeCharSDKController getInstance() {
		if (instance == null) {
			instance = new WeCharSDKController();
		}
		return instance;
	}

	private Context mContext = null;
	private IWXAPI api;

	private boolean isRequireLogin = false;
	// 回调函数
	private int loginCallback = -1;
	private int urlShareCallback = -1;
	private int imageShareCallback = -1;
	private int miniProjectShareCallback  = -1;
	private int miniProjectLaunchCallback = -1;
	
	private String launchdata = null; 

	// 初始化
	public void initWeChar(Context context, boolean check) {
		this.mContext = context;
		if (check) {
			// 检查签名
			if(!isApkInDebug(this.mContext)){
				System.out.println(" UR RELEASE ");
				
				boolean is_true_sign = this.checkSign(Constants.GetAPP_SIGN());
				if (is_true_sign == false) {
					this.showAlert("FFFFFFFFFFFFFF", true);
					return;
				}
			}else{
				this.showAlert(" UR : 注意 debug 包无法正常微信登陆", false);
			}
		}

		this.initAPPID_SERCRET();// 获取微信 appid 和 sercret

		api = WXAPIFactory.createWXAPI(context, Constants.GetAPP_ID(), true);
		api.registerApp(Constants.GetAPP_ID());
		WXManager.instance().SetApi(api);
	}

	// RE 初始化
	public void reInitWrChar(Context context){
		api = WXAPIFactory.createWXAPI(context, Constants.GetAPP_ID(), true);
		api.registerApp(Constants.GetAPP_ID());
		WXManager.instance().SetApi(api);
	}
	// 微信key
	private void initAPPID_SERCRET() {
		AssetManager am = this.mContext.getAssets();
		try {
			InputStream in = am.open("src/AppPlatform/cocos/properties.txt");

			byte[] buffer = new byte[in.available()];
			in.read(buffer);
			in.close();

			String content = new String(buffer);
			System.out.println("UR WeChatSDK : " + content);
			if (content != null && content.length() > 0) {
				final String str_start = "#START_WXAPPID:";
				int app_start = content.indexOf(str_start) + str_start.length();
				int app_end = content.indexOf(":END_WXAPPID#");
				String AppID = content.substring(app_start, app_end);

				final String str_start_s = "#START_WXSECRET:";
				int ser_start = content.indexOf(str_start_s)+ str_start_s.length();
				int ser_end = content.indexOf(":END_WXSECRET#");
				String AppSecret = content.substring(ser_start, ser_end);

				final String str_packname = "#WX_PACKGENAME:";
				int spack_start = content.indexOf(str_packname)+ str_packname.length();
				int spack_end = content.indexOf(":WX_PACKGENAME#");
				String AppPackName = content.substring(spack_start, spack_end);
				
				if (AppID != null && AppID.length() > 0 && AppSecret != null
						&& AppSecret.length() > 0) {
					
					System.out.println("UR ** INIT_WECHAT  A ** " + AppID);
					System.out.println("UR ** INIT_WECHAT  S ** " + AppSecret);
					Constants.SetAPP_ID(AppID);
					Constants.SetSECRET(AppSecret);
				} else {
					Constants.SetAPP_ID("");
					Constants.SetSECRET("");
					this.showAlert(" UR : WeChat 内容异常 ", false);
				}
				
				//检查包名：
				if(!this.checkPackName(AppPackName)){
					this.showAlert(" UR : 请检查微信key值先关内容 ，否则无法正常登陆", false);
				}

			} else {
				this.showAlert(" UR : WeChat 文件不存在 ", false);
			}
		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
			System.out.println("UR ** OPEN properties ERR **");
			this.showAlert(" UR : WeChat 文件不存在 ", false);
		}

	}

	// TXT 分享
	public boolean mWeChatTxtShare(final String msg, final int share_type) {
		if (msg == null || msg.length() <= 0) {
			// 回调
			return false;
		}
		((Activity) mContext).runOnUiThread(new Runnable() {

			@Override
			public void run() {
				// TODO Auto-generated method stub
				WXTextObject textobj = new WXTextObject();
				textobj.text = msg;

				WXMediaMessage wxmsg = new WXMediaMessage();
				wxmsg.mediaObject = textobj;
				wxmsg.description = msg;
				
				SendMessageToWX.Req req = new SendMessageToWX.Req();
				req.transaction = buildTransaction("text");
				req.message = wxmsg;
				if (share_type == 1) {
					req.scene = SendMessageToWX.Req.WXSceneTimeline;// 盆友圈
				} else {
					req.scene = SendMessageToWX.Req.WXSceneSession;
				}
				boolean reselt = WXManager.instance().SendReq(req);
				if (!reselt) {
					// 失败回调
					System.out.println(" UR 文本分享失败");
					boolean retry = false;
					int typetimes = 0;
					while(!retry && typetimes < 10){
						typetimes += 1;
						retry = WXManager.instance().SendReq(req);
					}
				}
			}
		});
		return true;
	}		
		
	// URL 分享
	public void mWeChatUrlShare(final String title, final String desc,
			final String url, final int share_type, final int callback) {
		if (url == null || url.length() <= 0) {
			// 回调
			this.urlShareCallBackToLua(-1, "URL A Null Value!");
			return;
		}
		((Activity) mContext).runOnUiThread(new Runnable() {

			@Override
			public void run() {
				// TODO Auto-generated method stub
				urlShareCallback = callback; // lua回调函数
				imageShareCallback = -1;
				miniProjectShareCallback =-1;

				Bitmap thumb = BitmapFactory.decodeResource(
						mContext.getResources(), R.drawable.icon);

				WXWebpageObject link = new WXWebpageObject();
				link.webpageUrl = url;

				WXMediaMessage msg = new WXMediaMessage(link);
				msg.title = title;
				msg.description = desc;
				msg.thumbData = bmpToByteArray(thumb, true);

				SendMessageToWX.Req req = new SendMessageToWX.Req();
				req.transaction = buildTransaction("webpage");
				req.message = msg;
				if (share_type == 1) {
					req.scene = SendMessageToWX.Req.WXSceneTimeline;// 盆友圈
				} else {
					req.scene = SendMessageToWX.Req.WXSceneSession;
				}
				boolean reselt = WXManager.instance().SendReq(req);
				if (!reselt) {
					// 失败回调
					boolean retry = false;
					int typetimes = 0;
					while(!retry && typetimes < 10){
						typetimes += 1;
						retry = WXManager.instance().SendReq(req);
					}
					if(!retry){
						urlShareCallBackToLua(0, "WeChat_Url_Share_Failed");
					}
				}
			}
		});
	}

	// 图片分享
	public void mWeChatImageShare(final String imagePath, final int share_type,
			final int callback) {
		if (imagePath == null || imagePath.length() <= 0) {
			this.imageShareCallBackToLua(-1, "ImageFilePath A Null Value!");
			return;
		}
		((Activity) mContext).runOnUiThread(new Runnable() {

			@Override
			public void run() {
				imageShareCallback = callback;
				urlShareCallback = -1;
				miniProjectShareCallback = -1;
				// TODO Auto-generated method stub
				Bitmap bmp = BitmapFactory.decodeFile(imagePath);
				if (bmp == null) {
					System.out.println("UR BitmapFactory NULL");
					// "分享图片失败";
					imageShareCallBackToLua(-1, "ImageFile decode Faile!");
					return;
				}

				WXImageObject imgobj = new WXImageObject(bmp);
				WXMediaMessage msg = new WXMediaMessage();
				msg.mediaObject = imgobj;

				Bitmap thumbBmp = Bitmap
						.createScaledBitmap(bmp, 240, 160, true);
				bmp.recycle();

				msg.thumbData = bmpToByteArray(thumbBmp, true);

				SendMessageToWX.Req req = new SendMessageToWX.Req();
				req.transaction = buildTransaction("img");
				req.message = msg;
				if (share_type == 1) {
					req.scene = SendMessageToWX.Req.WXSceneTimeline;// 盆友圈
				} else {
					req.scene = SendMessageToWX.Req.WXSceneSession;
				}

				boolean result = api.sendReq(req);
				if (!result) {
					// "分享图片失败"
					boolean retry = false;
					int typetimes = 0;
					while(!retry && typetimes < 10){
						typetimes += 1;
						retry = WXManager.instance().SendReq(req);
					}
					if(!retry){
						imageShareCallBackToLua(0, "WeChat_Image_Share_Failed");
					}
				}
			}
		});

	}

	// 合图分享
	public void mWeChatMergeImageShare(final String bg_path,
			final String codepath, final int point_x, final int point_y,
			final int size_width, final int size_height, final int share_type,
			final int callback) {
		if (bg_path == null || codepath == null) {
			// "分享图片失败,没有资源图片"
			this.imageShareCallBackToLua(-1, "ImageFilePath A Null Value!");
			return;
		}
		((Activity) mContext).runOnUiThread(new Runnable() {

			@Override
			public void run() {
				imageShareCallback = callback;
				miniProjectShareCallback =-1;
				urlShareCallback =-1;
				// TODO Auto-generated method stub
				System.out.println("\nUR PATH " + bg_path);
				System.out.println("\nUR PATH " + codepath);
				System.out.println("\nUR point_x " + point_x);
				System.out.println("\nUR point_y " + point_y);
				System.out.println("\nUR size_width " + size_width);
				System.out.println("\nUR size_height " + size_height);

				Bitmap bg_bmp = null;
				Bitmap thumb_bmp = null;

				try {
					AssetManager am = mContext.getResources().getAssets();
					if (bg_path.startsWith("assets")) {
						InputStream is = am.open(bg_path.replaceAll("assets/",
								""));
						bg_bmp = BitmapFactory.decodeStream(is);
						is.close();
					} else {
						bg_bmp = BitmapFactory.decodeFile(bg_path);
					}

					if (codepath.startsWith("assets")) {
						InputStream is = am.open(codepath.replaceAll("assets/",
								""));
						thumb_bmp = BitmapFactory.decodeStream(is);
						is.close();
					} else {
						thumb_bmp = BitmapFactory.decodeFile(codepath);
					}
				} catch (IOException e) {
					e.printStackTrace();
					System.out.println("UR 获取失败");
					imageShareCallBackToLua(-1, "ImageFile decode Faile!");
					//
					return;
				}

				if (bg_bmp == null || thumb_bmp == null) {
					System.out.println("UR BitmapFactory NULL");
					imageShareCallBackToLua(-1, "ImageFile decode Faile! null");
					//
					return;
				}
				Bitmap code_bmp = Bitmap.createScaledBitmap(thumb_bmp,
						size_width, size_height, true);

				Bitmap togetherbitmap = bg_bmp.copy(Config.ARGB_8888, true);
				Canvas canvas = new Canvas(togetherbitmap);
				Paint paint = new Paint();
				paint.setTypeface(Typeface.create(Typeface.DEFAULT_BOLD, Typeface.BOLD));
				paint.setXfermode(new PorterDuffXfermode(Mode.SRC_IN));
				canvas.drawBitmap(code_bmp, point_x, point_y, paint);// 开始绘制的位置
																		// (bg_bmp.getWidth()
																		// -
																		// size_width
																		// - 20f
																		// ,
																		// bg_bmp.getHeight()
																		// -
																		// size_height
																		// -
																		// 90f)

				WXImageObject imgobj = new WXImageObject(togetherbitmap);
				WXMediaMessage msg = new WXMediaMessage();
				msg.mediaObject = imgobj;

				Bitmap thumbBmp = Bitmap.createScaledBitmap(thumb_bmp, 160,
						240, true);
				msg.thumbData = bmpToByteArray(thumbBmp, true);

				SendMessageToWX.Req req = new SendMessageToWX.Req();
				req.transaction = buildTransaction("img");
				req.message = msg;
				if (share_type == 1) {
					req.scene = SendMessageToWX.Req.WXSceneTimeline;
				} else {
					req.scene = SendMessageToWX.Req.WXSceneSession;
				}
				boolean result = api.sendReq(req);
				if (!result) {
					boolean retry = false;
					int typetimes = 0;
					while(!retry && typetimes < 10){
						typetimes += 1;
						retry = WXManager.instance().SendReq(req);
					}
					if(!retry){
						imageShareCallBackToLua(0, "WeChat_Image_Share_Failed");
					}
					return;
				}
			}
		});

	}

	public void mWeChatMergeImageShareByJSON(final String json_data,
			final int share_type, final int callback) {
		if (json_data == null || json_data.equals("")) {
			// "分享图片失败,没有资源图片"
			System.out.println(" UR 分享图片失败,没有资源图片JSON 数据");
			this.imageShareCallBackToLua(-1, "Image JSON A Null Value!");
			return;
		}
		imageShareCallback = callback;
		miniProjectShareCallback = -1;
		urlShareCallback = -1;
		((Activity) mContext).runOnUiThread(new Runnable() {
			@Override
			public void run() {
				// TODO Auto-generated method stub
				// 解析数据合图
				System.out.println(" UR 开始解析数据合图");
				try {
					JSONArray jarray = new JSONArray(json_data);
					if (jarray != null && jarray.length() > 1) {

						Canvas canvas = null;
						Bitmap togetherbitmap = null;
						for (int i = 0; i < jarray.length(); i++) {
							JSONObject item = (JSONObject) jarray.get(i);
							String data = item.getString("data");
							String color_code = item.getString("color_code");
							int type = item.getInt("type");
							int p_x = item.getInt("p_x");
							int p_y = item.getInt("p_y");
							int size_w = item.getInt("size_w");
							int size_h = item.getInt("size_h");
							int font_s = item.getInt("font_size");

							System.out.println(String
									.format("UR JSON ITEM DATA : %s , %s ,%d ,%d ,%d ,%d ,%d ,%d",
											data, color_code, type, p_x, p_y,
											size_w, size_h, font_s));
							if (i == 0) {
								if (type == 1 || data.equals("")) {// //必须是图 0 ,
																	// 1 文本
									showAlert("JSON 首个合图数据必须是图片", false);
									return;
								}
								// 开始绘制
								Bitmap image_1_bg = createBitmapByPath(data);
								if(image_1_bg == null){
									return;
								}
								togetherbitmap = image_1_bg.copy(
										Config.ARGB_8888, true);
								canvas = new Canvas(togetherbitmap);

							} else {
								// 画笔
								Paint paint = new Paint();
								paint.setTypeface(Typeface.create(Typeface.DEFAULT_BOLD, Typeface.BOLD));
								paint.setColor(Color.parseColor(color_code));
								paint.setTextSize(font_s);
								paint.setXfermode(new PorterDuffXfermode(
										Mode.SRC_IN));

								if (type == 0) {// 绘制图片
									Bitmap bit = createBitmapByPath(data);
									if(bit != null){
										Bitmap image_ = Bitmap.createScaledBitmap(bit, size_w,size_h, true);
										canvas.drawBitmap(image_, p_x, p_y, paint);
									}	
								} else {// 绘制文本
										// 画文本
									canvas.drawText(data, p_x, p_y, paint);
								}
							}
						}

						// 绘制结束
						WXImageObject imgobj = new WXImageObject(togetherbitmap);
						WXMediaMessage msg = new WXMediaMessage();
						msg.mediaObject = imgobj;

						Bitmap thumbBmp = Bitmap.createScaledBitmap(
								togetherbitmap, 160, 240, true);
						msg.thumbData = bmpToByteArray(thumbBmp, true);

						SendMessageToWX.Req req = new SendMessageToWX.Req();
						req.transaction = buildTransaction("img");
						req.message = msg;
						if (share_type == 1) {
							req.scene = SendMessageToWX.Req.WXSceneTimeline;
						} else {
							req.scene = SendMessageToWX.Req.WXSceneSession;
						}
						boolean result = api.sendReq(req);
						if (!result) {
							imageShareCallBackToLua(0,
									"WeChat_Image_Share_Failed");
							return;
						}

					} else {
						System.out.println(" UR 无合图相关数据");
						imageShareCallBackToLua(-1, "WeChat_merge data <= 1");
					}

				} catch (JSONException e) {
					// TODO Auto-generated catch block
					System.out.println(" UR 解析合图的JSON数据失败");
					imageShareCallBackToLua(-1,
							"WeChat_share serializa json data_Failed");
					e.printStackTrace();
				} catch (IOException e) {
					System.out.println("UR 获取失败");
					imageShareCallBackToLua(-1, "ImageFile decode Faile!");
					e.printStackTrace();
				}
			}
		});
	}

	public void mWeChatLogin(final int callback) {
		// if(isRequireLogin){
		// System.out.println(" UR 忽略重复的点击登录");
		// return ;
		// }

		loginCallback = callback;
		((Activity) mContext).runOnUiThread(new Runnable() {
			@Override
			public void run() {
				// TODO Auto-generated method stub
				// 登录
				if (WXManager.instance().IsWXAppInstalled()) {
					isRequireLogin = true;
					final SendAuth.Req req = new SendAuth.Req();
					req.scope = "snsapi_userinfo";
					req.state = "wechat_sdk_demo";
					boolean result = api.sendReq(req);
					if (!result) {
						// "获取授权失败"
						isRequireLogin = false;
						loginedCallBackToLua(0, "Send_AuthReq_ERR");
					}
				} else {
					Uri uri = Uri.parse("http://weixin.qq.com/");
					Intent intent = new Intent(Intent.ACTION_VIEW, uri);
					mContext.startActivity(intent);
				}
			}
		});
	}
	
	public void mWeChatMiniProShare(final String json_data ,final int callback){
		if (json_data == null || json_data.equals("")) {
			this.miniProjectShareCallBackToLua(-1, "mini share JSON A Null Value!");
			return;
		}
		miniProjectShareCallback = callback;
		imageShareCallback =-1;
		urlShareCallback= -1;

		((Activity)mContext).runOnUiThread(new Runnable() {
			
			@Override
			public void run() {
				// TODO Auto-generated method stub
				try {
					JSONObject jsonobj = new JSONObject(json_data);
					if (jsonobj != null) {
						String wx_miniBase 	= jsonobj.getString("wx_miniBase");
						String webUrl 		= jsonobj.getString("webUrl");
						String path 		= jsonobj.getString("path");
						String parament 	= jsonobj.getString("parament");
						String title 		= jsonobj.getString("title");
						String desc 		= jsonobj.getString("desc");
						String imagepath 	= jsonobj.getString("image");
						JSONArray jarray    = jsonobj.getJSONArray("mergeData")	;
						
						//share
						WXMiniProgramObject miniProgramObj = new WXMiniProgramObject();
						miniProgramObj.webpageUrl 	= webUrl; 		// 兼容低版本的网页链接
						miniProgramObj.userName 	= wx_miniBase;  // 小程序原始id
						miniProgramObj.path = path + parament ;     // "/pages/media";            //小程序页面路径
						
						WXMediaMessage msg = new WXMediaMessage(miniProgramObj);
						msg.title = title;                    // 小程序消息title
						msg.description = desc;               // 小程序消息desc
						msg.messageExt  = "";				  // 扩展参数
						
						// 小程序消息封面图片，小于128k
						Bitmap bmp;
						if(imagepath==null || imagepath.equals("")){
							bmp = BitmapFactory.decodeResource(mContext.getResources(), R.drawable.icon).copy(
									Config.ARGB_8888, true); ;  									
						}else{
							bmp = createBitmapByPath(imagepath).copy(
									Config.ARGB_8888, true);;	
						}

						//合图
						if (jarray != null && jarray.length() > 1) {
							Canvas canvas = new Canvas(bmp);
							for (int i = 0; i < jarray.length(); i++) {
								JSONObject item = (JSONObject) jarray.get(i);
								String data = item.getString("data");
								String color_code = item.getString("color_code");
								int type = item.getInt("type");
								int p_x = item.getInt("p_x");
								int p_y = item.getInt("p_y");
								int size_w = item.getInt("size_w");
								int size_h = item.getInt("size_h");
								int font_s = item.getInt("font_size");

								System.out.println(String.format("UR JSON ITEM DATA : %s , %s ,%d ,%d ,%d ,%d ,%d ,%d",data, color_code, type, p_x, p_y,size_w, size_h, font_s));
								
								// 画笔
								Paint paint = new Paint();
								paint.setTypeface(Typeface.create(Typeface.DEFAULT_BOLD, Typeface.BOLD));
								paint.setColor(Color.parseColor(color_code));
								paint.setTextSize(font_s);
								paint.setXfermode(new PorterDuffXfermode(
											Mode.SRC_IN));

								if (type == 0) {// 绘制图片
									Bitmap bit = createBitmapByPath(data);
									if(bit != null){
										Bitmap image_ = Bitmap.createScaledBitmap(bit, size_w, size_h, true);
										if(image_ != null){
											canvas.drawBitmap(image_, p_x, p_y, paint);
										}
									}
								} else {// 绘制文本
									canvas.drawText(data, p_x, p_y, paint);
								}
								
							}
						}
						
						msg.thumbData = bmpToByteArray(bmp, true);

						SendMessageToWX.Req req = new SendMessageToWX.Req();
						req.transaction = buildTransaction("webpage");
						req.message = msg;
						req.scene = SendMessageToWX.Req.WXSceneSession;  // 目前支持会话
						boolean result = api.sendReq(req);
						if (!result) {
							miniProjectShareCallBackToLua(-1, "WeChat_mini share failed");
						}

					}else{
						System.out.println(" UR 无合图相关数据");
						miniProjectShareCallBackToLua(-1, "WeChat_mini data <= 1");
					}

				} catch (JSONException e) {
					// TODO Auto-generated catch block
					System.out.println(" UR 解析合图的JSON数据失败");
					miniProjectShareCallBackToLua(-1,"WeChat_mini share serializa json data_Failed");
					e.printStackTrace();
				} catch (IOException e) {
					System.out.println("UR 获取失败");
					miniProjectShareCallBackToLua(-1, "ImageFile decode Faile!");
					e.printStackTrace();
				}
				
			}
		});
	}
	public void setLaunchCallback(final int callback){
		this.miniProjectLaunchCallback = callback;
		if(this.launchdata != null && !this.launchdata.equals("")){
			this.miniProjectLaunchCallBackToLua(this.launchdata);
			this.launchdata = "";
		}
	}
	
	public String getLaunchData(){
		if(this.launchdata == null){
			return "";
		}
		return this.launchdata;
	}
	
	public void setLaunchData(String data){
		this.launchdata = data;
		if( this.miniProjectLaunchCallback != -1){
			this.miniProjectLaunchCallBackToLua(this.launchdata);
			this.launchdata = "";
		}
	}

	public boolean mWeChatClientExit(){
		return WXManager.instance().IsWXAppInstalled();
	}

	/******************************************************************
	 * 
	 * API 回调
	 * 
	 * ****************************************************************/
	public void loginedCallBackToLua(final int code, final String token) {
		System.out.println("UR Login Call Back TOKEN  :" + token);
		isRequireLogin = false;
		if (loginCallback != -1) {
			try {
				Cocos2dxHelper.runOnGLThread(new Runnable() {
					@Override
					public void run() {
						Cocos2dxLuaJavaBridge.callLuaFunctionWithString(loginCallback,String.format("%d,%s", code, token));// 调用
						Cocos2dxLuaJavaBridge.releaseLuaFunction(loginCallback);
						loginCallback = -1; 
					}
				});
			} catch (Exception e) {
				System.out.println(" UR Login Call Back Faile xxxxx");
				this.showAlert(" UR : Login Call Back Faile ", false);
				e.printStackTrace();
			}
		}else{
			System.out.println("UR Login Call Back NULL xxxxx");
		}
	}

	public void urlShareCallBackToLua(final int code, final String msg) {
		if (urlShareCallback != -1) {
			try {
				Cocos2dxHelper.runOnGLThread(new Runnable() {
					@Override
					public void run() {
						Cocos2dxLuaJavaBridge.callLuaFunctionWithString(urlShareCallback,String.format("%d,%s", code, msg));// 调用
						Cocos2dxLuaJavaBridge.releaseLuaFunction(urlShareCallback);
						urlShareCallback = -1;
					}
				});
			} catch (Exception e) {
				System.out.println("Share Call Back Faile xxxxx");
				this.showAlert(" UR : Share Call Back Faile ", false);
				e.printStackTrace();
			}
		}
	}

	public void imageShareCallBackToLua(final int code, final String msg) {
		if (imageShareCallback != -1) {
			try {
				Cocos2dxHelper.runOnGLThread(new Runnable() {
					@Override
					public void run() {
						Cocos2dxLuaJavaBridge.callLuaFunctionWithString(imageShareCallback,String.format("%d,%s", code, msg));// 调用
						Cocos2dxLuaJavaBridge.releaseLuaFunction(imageShareCallback);
						imageShareCallback = -1;
					}
				});
			} catch (Exception e) {
				System.out.println("Share Call Back Faile xxxxx");
				this.showAlert(" UR : Share Call Back Faile ", false);
				e.printStackTrace();
			}
		}
	}
	
	public void miniProjectShareCallBackToLua(final int code, final String msg) {
		if (miniProjectShareCallback != -1) {
			try {
				Cocos2dxHelper.runOnGLThread(new Runnable() {
					@Override
					public void run() {
						Cocos2dxLuaJavaBridge.callLuaFunctionWithString(miniProjectShareCallback,String.format("%d,%s", code, msg));// 调用
						Cocos2dxLuaJavaBridge.releaseLuaFunction(miniProjectShareCallback);
						miniProjectShareCallback = -1;
					}
				});
			} catch (Exception e) {
				System.out.println("Share Call Back Faile xxxxx");
				this.showAlert(" UR : Share Call Back Faile ", false);
				e.printStackTrace();
			}
		}
	}
	
	public void miniProjectLaunchCallBackToLua(final String msg) {
		if (miniProjectLaunchCallback != -1) {
			try {
				Cocos2dxHelper.runOnGLThread(new Runnable() {
					@Override
					public void run() {
						Cocos2dxLuaJavaBridge.callLuaFunctionWithString(miniProjectLaunchCallback,msg);// 调用
					}
				});
			} catch (Exception e) {
				System.out.println("launch Call Back Faile xxxxx");
				this.showAlert(" UR : launch Call Back Faile ", false);
				e.printStackTrace();
			}
		}
	}


	/******************************************************************
	 * 
	 * other
	 * 
	 ******************************************************************/

	public static String buildTransaction(final String type) {
		return (type == null) ? String.valueOf(System.currentTimeMillis())
				: type + System.currentTimeMillis();
	}

	public static byte[] bmpToByteArray(final Bitmap bmp,
			final boolean needRecycle) {
		ByteArrayOutputStream output = new ByteArrayOutputStream();
		bmp.compress(CompressFormat.JPEG, 80, output);
		if (needRecycle) {
			bmp.recycle();
		}

		byte[] result = output.toByteArray();
		try {
			output.close();
		} catch (Exception e) {
			e.printStackTrace();
		}
		return result;
	}

	public void showAlert(final String msg, final boolean exit_game) {
		((Activity) this.mContext).runOnUiThread(new Runnable() {

			@Override
			public void run() {
				// TODO Auto-generated method stub
				AlertDialog.Builder dlg = new AlertDialog.Builder(mContext);
				dlg.setTitle("提示");
				dlg.setMessage(msg);
				dlg.setPositiveButton("确定", new OnClickListener() {

					@Override
					public void onClick(DialogInterface arg0, int arg1) {
						// TODO Auto-generated method stub
						// 提示的点击事件
						if (exit_game) {
							System.exit(0);
						}
					}
				});
				dlg.show();
			}
		});
	}

	private boolean checkSign(String sign_key) {
		try {
			PackageInfo packageInfo = this.mContext.getPackageManager()
					.getPackageInfo(this.mContext.getPackageName(),
							PackageManager.GET_SIGNATURES);
			Signature[] signs = packageInfo.signatures;
			Signature sign = signs[0];
			if (!sign_key.equalsIgnoreCase(doFingerprint(sign.toByteArray(),
					"MD5"))) {
				return false;
			}
		} catch (Exception e) {
			e.printStackTrace();
		}
		return true;
	}
	
	private boolean checkPackName(String packname){
		try {
			return this.mContext.getPackageName().equals(packname);
		} catch (Exception e) {
			e.printStackTrace();
		}
		return false;
	}

	private boolean isApkInDebug(Context context) {
		try {
			ApplicationInfo info = context.getApplicationInfo();
			return (info.flags & ApplicationInfo.FLAG_DEBUGGABLE) != 0;
		} catch (Exception e) {
			e.printStackTrace();
			return false;
		}
	}

	private String doFingerprint(byte[] certificateBytes, String algorithm)
			throws Exception {
		MessageDigest md = MessageDigest.getInstance(algorithm);
		md.update(certificateBytes);
		byte[] digest = md.digest();

		String toRet = "";
		for (int i = 0; i < digest.length; i++) {
			// if (i != 0) {
			// toRet += ":";
			// }
			int b = digest[i] & 0xff;
			String hex = Integer.toHexString(b);
			if (hex.length() == 1) {
				toRet += "0";
			}
			toRet += hex;
		}

		System.out.println(" UR S_ :" + toRet);
		return toRet;
	}

	private Bitmap createBitmapByPath(String path) throws IOException {
		if(path == null || path.equals("")){
			return null;
		}
		Bitmap image_1_bg;
		AssetManager am = mContext.getResources().getAssets();
		if (path.startsWith("assets")) {
			InputStream is = am.open(path.replaceAll("assets/", ""));
			image_1_bg = BitmapFactory.decodeStream(is);
			is.close();
		} else {
			image_1_bg = BitmapFactory.decodeFile(path);
		}

		return image_1_bg;
	}

}
