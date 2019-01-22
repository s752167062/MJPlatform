package com.pro.sdk.liaobei;

import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.security.MessageDigest;

import org.cocos2dx.lib.Cocos2dxHelper;
import org.cocos2dx.lib.Cocos2dxLuaJavaBridge;

import android.app.Activity;
import android.app.AlertDialog;
import android.app.Application;
import android.content.Context;
import android.content.DialogInterface;
import android.content.DialogInterface.OnClickListener;
import android.content.pm.ApplicationInfo;
import android.content.pm.PackageInfo;
import android.content.pm.PackageManager;
import android.content.pm.Signature;
import android.content.res.AssetManager;
import android.graphics.Bitmap;
import android.graphics.Bitmap.CompressFormat;
import android.graphics.BitmapFactory;

import com.aoetech.sharelibrary.auth.AOEAuthResultListener;
import com.aoetech.sharelibrary.auth.AuthReq;
import com.aoetech.sharelibrary.openapi.AOETechManager;
import com.aoetech.sharelibrary.share.AOEShareResultListener;
import com.aoetech.sharelibrary.share.AppShareMessage;
import com.aoetech.sharelibrary.share.ImageMessage;
import com.aoetech.sharelibrary.share.PictureShareMessage;
import com.aoetech.sharelibrary.share.WebShareMessage;

public class LBSDKController {
	private static LBSDKController instance = null;

	public static LBSDKController getInstance() {
		if (instance == null) {
			instance = new LBSDKController();
		}
		return instance;
	}

	private Context mContext = null;
	private Application app = null;
	//聊呗
	private AOETechManager mManager = AOETechManager.getInstance();

	private boolean isRequireLogin = false;
	// 回调函数
	private int loginCallback = -1;
	private int urlShareCallback = -1;
	private int appShareCallback = -1;
	private int imgShareCallback = -1;

	// 初始化
	public void initLB(Context context, boolean check) {
		this.mContext = context;
		if (check) {
			// 检查签名
			if(!isApkInDebug(this.mContext)){
				System.out.println(" UR RELEASE ");
				
				boolean is_true_sign = this.checkSign(LBConstants.GetAPP_SIGN());
				if (is_true_sign == false) {
					this.showAlert("FFFFFFFFFFFFFF", true);
					return;
				}
			}else{
				this.showAlert(" UR : 注意 debug 包无法正常微信登陆", false);
			}
		}

		
	}
	
	public void initOnAppLication(Application app){
		try {
			this.app = app;
			//聊呗
			mManager.init(app, LBConstants.GetAPP_ID());
		} catch (Exception e) {
			// TODO: handle exception
			e.printStackTrace();
		}
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
			System.out.println("UR LBSDK : " + content);
			if (content != null && content.length() > 0) {
				final String str_start = "#START_LBAPPID:";
				int app_start = content.indexOf(str_start) + str_start.length();
				int app_end = content.indexOf(":END_LBAPPID#");
				String AppID = content.substring(app_start, app_end);

				final String str_start_s = "#START_LBSECRET:";
				int ser_start = content.indexOf(str_start_s)+ str_start_s.length();
				int ser_end = content.indexOf(":END_LBSECRET#");
				String AppSecret = content.substring(ser_start, ser_end);

				if (AppID != null && AppID.length() > 0 && AppSecret != null
						&& AppSecret.length() > 0) {
					LBConstants.SetAPP_ID(AppID);
					LBConstants.SetSECRET(AppSecret);
				} else {
					LBConstants.SetAPP_ID("");
					LBConstants.SetSECRET("");
					this.showAlert(" UR : LB 内容异常 ", false);
				}

			} else {
				this.showAlert(" UR : LB 文件不存在 ", false);
			}
		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
			System.out.println("UR ** OPEN properties ERR **");
			this.showAlert(" UR : LB 文件不存在 ", false);
		}

	}

	

	public void mLBLogin(final String scope , final String state , final int callback) {
		loginCallback = callback;
		((Activity) mContext).runOnUiThread(new Runnable() {
			@Override
			public void run() {
				// TODO Auto-generated method stub
				try {
					AOETechManager mManager = AOETechManager.getInstance();
					// 登录
					if (mManager.isMYInstall()) {
						isRequireLogin = true;
						String scope_ = scope.equals("") ? "snsapi_userinfo" : scope;
						String state_ = state.equals("") ? "zn_lbsdk" : state;
						
						System.out.println(">>>> laobei scope_ "+ scope_);
						System.out.println(">>>> laobei state_ "+ state_);
						
						AuthReq req = new AuthReq().scope(scope_).state(state_);
						mManager.doAuth(req,new AOEAuthResultListener() {
		                    @Override
		                    public void onStart() {
		                        System.out.println(">>>>>> liaobei sdk login auth start");
		                    }


		                    @Override
		                    public void onResult(int resultCode, String resultString) {
		                    	System.out.println(String.format(">>>>>> liaobei sdk login auth onResult : %d , %s" , resultCode ,resultString));
		                    	if(resultCode == 0){
		                    		LBSDKController.getInstance().loginedCallBackToLua(1, resultString);
		                    	}else if(resultCode == -2){
		                    		LBSDKController.getInstance().loginedCallBackToLua(-2, resultString);
		                    	}else{
		                    		LBSDKController.getInstance().loginedCallBackToLua(resultCode, resultString);
		                    	}
		                    	
		                    }
		                    @Override
		                    public void onCancel() {
		                    	LBSDKController.getInstance().loginedCallBackToLua(-2, "用户取消授权");
		                    }
		                    
		                    @Override
		                    public void onError(int resultCode, String resultString){
		                    	LBSDKController.getInstance().loginedCallBackToLua(resultCode, resultString);
		                    }

		                });
					}
				} catch (Exception e) {
					// TODO: handle exception
					e.printStackTrace();
				}
			}
		});
	}
	
	public void mLBUrlShare(final String title , final String content , final String imgurl , final String weburl , final int time , final int callback){
		this.urlShareCallback = callback;
		
		((Activity) mContext).runOnUiThread(new Runnable() {
			@Override
			public void run() {
				// TODO Auto-generated method stub
				try {
					System.out.println(">>>> liaobei " + title);
					System.out.println(">>>> liaobei " + content);
					System.out.println(">>>> liaobei " + imgurl);
					System.out.println(">>>> liaobei " + weburl);

					AOETechManager mManager = AOETechManager.getInstance(); 
					WebShareMessage message = new WebShareMessage().shareTitle(title)//标题 
							.shareContent(content)//内容
							.shareImage(imgurl)//图片链接地址 
							.shareHttpUrl(weburl);//分享链接 
					
					mManager.share(message,new AOEShareResultListener(){ 
						
							@Override
							public void onStart() { 
								System.out.println(">>>>> liaobei onStart");
							}
							@Override
							public void onOK() {
								System.out.println(">>>>> liaobei onOK");
								LBSDKController.getInstance().urlShareCallBackToLua(1, "success");
							}
							@Override
							public void onError(int errorCode, String errorString) { 
								System.out.println(">>>>> liaobei  share onErrorerrorCode : " + errorCode + " ; errorString :" + errorString);
								LBSDKController.getInstance().urlShareCallBackToLua(errorCode, errorString);
							}
							@Override
							public void onCancel() {
								System.out.println(">>>>> liaobei cancel");
								LBSDKController.getInstance().urlShareCallBackToLua(-2, "cancel");
							}
					});
				} catch (Exception e) {
					// TODO: handle exception
					e.printStackTrace();
				}
			}
		});
	
	}
	
	public void mLBImgShare(final String imagePath , final int callback){
		this.imgShareCallback = callback;
		((Activity) mContext).runOnUiThread(new Runnable() {
			@Override
			public void run() {
				// TODO Auto-generated method stub
				try {
					System.out.println(">>>> liaobei " + imagePath);
					
					Bitmap bmp = BitmapFactory.decodeFile(imagePath);
					if (bmp == null) {
						System.out.println("UR BitmapFactory NULL");
						// "分享图片失败";
						LBSDKController.getInstance().imageShareCallBackToLua(-1, "ImageFile decode Faile!");
						return;
					}

					ImageMessage imageMessage = new ImageMessage(bmp);//可以是 bitmap 或者图片 url 连接
					PictureShareMessage message = new PictureShareMessage().imageMessage(imageMessage) ;
					
					AOETechManager mManager = AOETechManager.getInstance(); 
					mManager.share(message,new AOEShareResultListener(){ 
						
							@Override
							public void onStart() { 
								System.out.println(">>>>> liaobei onStart");
							}
							@Override
							public void onOK() {
								System.out.println(">>>>> liaobei onOK");
								LBSDKController.getInstance().imageShareCallBackToLua(1, "success");
							}
							@Override
							public void onError(int errorCode, String errorString) { 
								System.out.println(">>>>> liaobei  share onErrorerrorCode : " + errorCode + " ; errorString :" + errorString);
								LBSDKController.getInstance().imageShareCallBackToLua(errorCode, errorString);
							}
							@Override
							public void onCancel() {
								System.out.println(">>>>> liaobei cancel");
								LBSDKController.getInstance().imageShareCallBackToLua(-2, "cancel");
							}
					});
				} catch (Exception e) {
					// TODO: handle exception
					e.printStackTrace();
				}
			}
		});
	}
	
	public void mLBJumpAppShare(final String title , final String content , final String imgurl , final String android_scheme , final String ios_scheme , final int time , final int callback){
		this.appShareCallback = callback;
		((Activity) mContext).runOnUiThread(new Runnable() {
			@Override
			public void run() {
				// TODO Auto-generated method stub
				try {

					AOETechManager mManager = AOETechManager.getInstance(); 
					AppShareMessage message = new AppShareMessage().shareTitle(title)//标题 
							.shareContent(content)//内容
							.shareImage(imgurl)//图片链接地址 
							.shareAppIosSchemeUrl(ios_scheme)
							.shareAppAndSchemeUrl(android_scheme);
					
					mManager.share(message,new AOEShareResultListener(){ 
						
							@Override
							public void onStart() { 
								System.out.println(">>>>> liaobei onStart");
							}
							@Override
							public void onOK() {
								System.out.println(">>>>> liaobei onOK");
							}
							@Override
							public void onError(int errorCode, String errorString) { 
								System.out.println(">>>>> liaobei  share onErrorerrorCode : " + errorCode + " ; errorString :" + errorString);
							}
							@Override
							public void onCancel() {
								System.out.println(">>>>> liaobei cancel");
							}
					});
				} catch (Exception e) {
					// TODO: handle exception
					e.printStackTrace();
				}
			}
		});

	}
	
	public boolean mLBClientExist(){
		return AOETechManager.getInstance().isMYInstall();
	}

	/******************************************************************
	 * 
	 * API 回调
	 * 
	 * ****************************************************************/
	public void loginedCallBackToLua(final int code, final String token) {
		isRequireLogin = false;
		if (loginCallback != -1) {
			try {
				Cocos2dxHelper.runOnGLThread(new Runnable() {
					@Override
					public void run() {
						Cocos2dxLuaJavaBridge.callLuaFunctionWithString(loginCallback,String.format("%d#%s", code, token));// 调用
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
						Cocos2dxLuaJavaBridge.callLuaFunctionWithString(urlShareCallback,String.format("%d#%s", code, msg));// 调用
						Cocos2dxLuaJavaBridge.releaseLuaFunction(urlShareCallback);
						urlShareCallback = -1; 
					}
				});
			} catch (Exception e) {
				System.out.println(" UR url share Call Back Faile xxxxx");
				this.showAlert(" UR : url share Call Back Faile ", false);
				e.printStackTrace();
			}
		}else{
			System.out.println("UR share url Call Back NULL xxxxx");
		}
	}

	public void imageShareCallBackToLua(final int code, final String msg){
		if (imgShareCallback != -1) {
			try {
				Cocos2dxHelper.runOnGLThread(new Runnable() {
					@Override
					public void run() {
						Cocos2dxLuaJavaBridge.callLuaFunctionWithString(imgShareCallback,String.format("%d#%s", code, msg));// 调用
						Cocos2dxLuaJavaBridge.releaseLuaFunction(imgShareCallback);
						imgShareCallback = -1; 
					}
				});
			} catch (Exception e) {
				System.out.println(" UR img share Call Back Faile xxxxx");
				this.showAlert(" UR : img share Call Back Faile ", false);
				e.printStackTrace();
			}
		}else{
			System.out.println("UR share img Call Back NULL xxxxx");
		}
	}
	public void appShareCallBackToLua(final int code, final String msg) {
		if (appShareCallback != -1) {
			try {
				Cocos2dxHelper.runOnGLThread(new Runnable() {
					@Override
					public void run() {
						Cocos2dxLuaJavaBridge.callLuaFunctionWithString(appShareCallback,String.format("%d#%s", code, msg));// 调用
						Cocos2dxLuaJavaBridge.releaseLuaFunction(appShareCallback);
						appShareCallback = -1; 
					}
				});
			} catch (Exception e) {
				System.out.println(" UR app share Call Back Faile xxxxx");
				this.showAlert(" UR : app share Call Back Faile ", false);
				e.printStackTrace();
			}
		}else{
			System.out.println("UR share app Call Back NULL xxxxx");
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
