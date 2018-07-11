package com.pro.nowpay;

import java.io.IOException;
import java.io.InputStream;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.Locale;

import org.cocos2dx.lib.Cocos2dxHelper;
import org.cocos2dx.lib.Cocos2dxLuaJavaBridge;
import org.json.JSONException;
import org.json.JSONObject;

import android.app.Activity;
import android.app.AlertDialog;
import android.content.Context;
import android.content.DialogInterface;
import android.content.DialogInterface.OnClickListener;
import android.content.Intent;
import android.content.res.AssetManager;
import android.widget.Toast;

import com.ipaynow.wechatpay.plugin.api.WechatPayPlugin;
import com.ipaynow.wechatpay.plugin.manager.route.dto.ResponseParams;
import com.ipaynow.wechatpay.plugin.manager.route.impl.ReceivePayResult;
import com.ipaynow.wechatpay.plugin.utils.PreSignMessageUtil;

/***
 * 添加配置
 * 		<activity
		    android:name="com.ipaynow.wechatpay.plugin.inner_plugin.wechat_plugin.activity.WeChatNotifyActivity"
		    android:configChanges="orientation|keyboardHidden|keyboard|smallestScreenSize|locale|screenLayout"
		    android:screenOrientation="behind"
		    android:theme="@android:style/Theme.Translucent" >
		</activity>
		
		在 MainActivity 调用 init 和 onActivityResult
		 
 * 
 * */

public class NowPayController implements ReceivePayResult {

	private static NowPayController instance = null;
	public static NowPayController getInstance() {
		if (instance == null) {
			instance = new NowPayController();
		}
		return instance;
	}
	private String PAY_ID = "";
	private String PAY_KEY= "";
		
	private Context mContext;
	private int payCallback_lua = -1;
	
	private String preSignStr = null;
	private PreSignMessageUtil preSign = new PreSignMessageUtil();

	public void init(final Context context) {
		this.mContext = context;
		this.initAPPID_SERCRET();
		((Activity) context).runOnUiThread(new Runnable() {
			@Override
			public void run() {
				// TODO Auto-generated method stub
				WechatPayPlugin.getInstance().init(context);
			}
		});
	}

	// 微信key
	private void initAPPID_SERCRET() {
		AssetManager am = this.mContext.getAssets();
		try {
			InputStream in = am.open("src/cocos/properties.txt");

			byte[] buffer = new byte[in.available()];
			in.read(buffer);
			in.close();

			String content = new String(buffer);
			System.out.println("UR NOW PAY : " + content);
			if (content != null && content.length() > 0) {
				final String str_start = "#START_NOWPAY_ID:";
				int app_start = content.indexOf(str_start) + str_start.length();
				int app_end = content.indexOf(":END_NOWPAY_ID#");
				String AppID = content.substring(app_start, app_end);

				final String str_start_s = "#START_NOWPAY_KEY:";
				int ser_start = content.indexOf(str_start_s)+ str_start_s.length();
				int ser_end = content.indexOf(":END_NOWPAY_KEY#");
				String AppKEY = content.substring(ser_start, ser_end);

				
				if (AppID != null && AppID.length() > 0 && AppKEY != null && AppKEY.length() > 0) {
					System.out.println("UR ** INIT_WECHAT PAY A ** " + AppID);
					System.out.println("UR ** INIT_WECHAT PAY K ** " + AppKEY);
					this.PAY_ID = AppID;
					this.PAY_KEY= AppKEY;
				} else {
					this.showAlert(" UR : nowpay 内容异常 ");
				}
			}
		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
			System.out.println("UR ** OPEN properties ERR **");
		}

	}		
		
	// { name ,price , userdata ,server_time , goodsid , notifyUrl ,extr_data }  
	public void nowPay(final String pay_Json , final int callback_lua) {
		this.payCallback_lua = callback_lua ;
		System.out.println(" UR : pay_Json " + pay_Json);
		try {
			JSONObject json = new JSONObject(pay_Json);
			String name 		= json.getString("name");
			String price 		= json.getString("price");
			String userdata 	= json.getString("userdata");
			String server_time 	= json.getString("server_time");
			String goodsid		= json.getString("goodsid");
			String notifyUrl	= json.getString("notifyUrl");
			String extr_data	= json.getString("extr_data");
			
			String errmsg = null ;
			if(name == null || name.equals("")){
				name = "房卡";
			}
			if(price == null || price.equals("")){
				errmsg = "支付出错,ERR 02 PRICE";
			}
			if(userdata == null || userdata.equals("")){
				errmsg = "支付出错,ERR 03 USERDATA";
			}
			if(notifyUrl == null || notifyUrl.equals("")){
				errmsg = "支付出错,ERR 04 NOTIFYURL";
			}
			if(goodsid == null || goodsid.equals("")){
				errmsg = "支付出错,ERR 05 GOODSID";
			}
			if(errmsg != null){
				this.showAlert(errmsg);
				return ;
			}
		
			String no = new SimpleDateFormat("yyyyMMddHHmmss", Locale.CHINA).format(new Date());
			if (server_time != null && !server_time.equals("")) {
				no = server_time ;
				System.out.println("UR service time : " + server_time);
			}
			String new_no = userdata + no ; 
			System.out.println("UR : no " + new_no);
				
			preSign.appId = this.PAY_ID;
			preSign.mhtOrderNo 			= new_no ;
			preSign.mhtOrderName 		= name;
			preSign.mhtOrderType 		= "01";
			preSign.mhtCurrencyType 	= "156"; 	// 币种类型 :156 人民币
			preSign.mhtOrderAmt 		= price;
			preSign.mhtOrderDetail 		= "66" ;	//userData;
			preSign.mhtOrderTimeOut 	= "3600";
			preSign.mhtOrderStartTime 	= no;
			preSign.notifyUrl 			= notifyUrl;
			preSign.mhtCharset 			= "UTF-8";
			preSign.mhtReserved 		= String.format("%s#%s#%s", userdata , this.PAY_KEY , goodsid); // 商户透传参数
			
			//扩展用
			if(extr_data != null && !extr_data.equals("")){
				preSign.mhtReserved = String.format("%s#%s", preSign.mhtReserved ,extr_data);
			}
			goToPay("13");
			
		} catch (JSONException e) {
			e.printStackTrace();
			this.showAlert("UR 解析支付数据存在问题");
			// TODO: handle exception
		} catch (Exception e) {
			// TODO: handle exception
			e.printStackTrace();
			this.showAlert("UR 支付出现异常");
		}
		
	}

	private void goToPay(String flag) {
		preSign.payChannelType = flag; // 微信支付:13 定值
		preSignStr = preSign.generatePreSignMessage();
		if(preSignStr == null || "".equals(preSignStr)){
			this.showAlert(" ERR 支付参数不全");
			return ;
		}

		String sec = Md5Util.md5(this.PAY_KEY);
		String strSign = Md5Util.md5(preSignStr + "&" + sec);
		String result = preSignStr + "&mhtSignature="+ strSign  +"&mhtSignType=MD5" ;		
		
		this.doPayResult(result);
	}

	public void doPayResult(final String result){
		((Activity)this.mContext).runOnUiThread(new Runnable() {
			
			@Override
			public void run() {
				// TODO Auto-generated method stub 
				WechatPayPlugin.getInstance().setCallResultActivity((Activity)mContext)	// 传入回调用的Activity对象
											 .setCallResultReceiver(NowPayController.this)		// 传入继承了通知接口的类
											 .pay(result);								// 传入请求数据
			}
		});
	}
	
	public void payCallBackToLua(final int code ,final String msg){
		if(payCallback_lua > 0 ){
			try {
				Cocos2dxHelper.runOnGLThread(new Runnable() {
					@Override
					public void run() {
						Cocos2dxLuaJavaBridge.callLuaFunctionWithString(payCallback_lua,String.format("%d,%s", code, msg));	// 调用
						Cocos2dxLuaJavaBridge.releaseLuaFunction(payCallback_lua);
						payCallback_lua = -1 ;
					}
				});
			} catch (Exception e) {
				System.out.println(" UR payCallBackToLua Call Back Faile xxxxx");
				this.showAlert(" UR : payCallBackToLua Call Back Faile ");
				e.printStackTrace();
			}
		}else{
			System.out.println(" UR payCallBackToLua -1 ");
		}
	}
	
	@Override
	public void onIpaynowTransResult(ResponseParams resp) {
		String respCode = resp.respCode;
		String errorCode = resp.errorCode;
		String respMsg = resp.respMsg;

		if (respCode.equals("00")) {
			payCallBackToLua(1, "PayResultSuccess"); 
			System.out.println("YJ 交易状态:成功");
		} 
		else if (respCode.equals("02")) {
			payCallBackToLua(0, "PayResultCancel"); 
			System.out.println("YJ 交易状态:取消");
		} 
		else if (respCode.equals("01")) {
			payCallBackToLua(0, "PayResultFail   errcode:" + errorCode + "   desc:"+ respMsg); 
			System.out.println("YJ 交易状态:失败   错误码:" + errorCode + "   原因:"+ respMsg);
		} 
		else if (respCode.equals("03")) {
			payCallBackToLua(0, "PayResultUnknown   errcode:" + errorCode + "   desc:"+ respMsg); 
			System.out.println("YJ 交易状态:未知   错误码:" + errorCode + "   原因:"+ respMsg);
		}
		else{
			payCallBackToLua(0, "PayResultDefault");
		}
	}
	
	public void onActivityResult(int requestCode , int resultCode ,Intent data){
		if (data == null) {
            return;
        }
        boolean show = false ;
        String respCode = data.getExtras().getString("respCode");
        String errorCode = data.getExtras().getString("errorCode");
        String respMsg = data.getExtras().getString("respMsg");
        StringBuilder temp = new StringBuilder();
        if(respCode != null){
            if (respCode.equals("00")) {
                show = true ;
                temp.append("交易状态:成功");
            } else if (respCode.equals("02")) {
                temp.append("交易状态:取消");
            } else if (respCode.equals("01") && respMsg != null ) {
                show = true ;
                temp.append("交易状态:失败")
                	.append("\n")
                	.append("错误码:")
                    .append(errorCode)
                    .append("原因:" + respMsg);
            } else if (respCode.equals("03") && respMsg != null ) {
            	show = true ;
            	temp.append("交易状态:未知")
                	.append("\n")
                	.append("错误码:")
                    .append(errorCode)
                    .append("原因:" + respMsg);
            }
            if(show){
                Toast.makeText(this.mContext, temp.toString(), Toast.LENGTH_LONG).show();
            }
            
        }
	}
	
	
	/**********************************
	 * other
	 */
	public void showAlert(final String msg) {
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
					}
				});
				dlg.show();
			}
		});
	}
}
