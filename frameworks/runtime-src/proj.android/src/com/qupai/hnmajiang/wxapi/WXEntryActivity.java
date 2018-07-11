package com.qupai.hnmajiang.wxapi;

import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;

import com.pro.sdk.wechat.WXManager;
import com.pro.sdk.wechat.WeCharSDKController;
import com.tencent.mm.opensdk.constants.ConstantsAPI;
import com.tencent.mm.opensdk.modelbase.BaseReq;
import com.tencent.mm.opensdk.modelbase.BaseResp;
import com.tencent.mm.opensdk.modelmsg.LaunchFromWX;
import com.tencent.mm.opensdk.modelmsg.SendAuth;
import com.tencent.mm.opensdk.modelmsg.ShowMessageFromWX;
import com.tencent.mm.opensdk.modelmsg.WXAppExtendObject;
import com.tencent.mm.opensdk.modelmsg.WXMediaMessage;
import com.tencent.mm.opensdk.openapi.IWXAPIEventHandler;
import org.cocos2dx.lua.AppActivity;



public class WXEntryActivity extends Activity implements IWXAPIEventHandler{

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		System.out.println("UR ** WXEntryActivity onCreate **");
		super.onCreate(savedInstanceState);
		WXManager.instance().HandleIntent(getIntent(),this);
	}
	
	 @Override
	    protected void onPause() {
	    	// TODO Auto-generated method stub
	    	super.onPause();
	    	System.out.println("UR ** WXEntryActivity onPause **");
	    }
	    
	    @Override
	    protected void onRestart() {
	    	// TODO Auto-generated method stub
	    	super.onRestart();
	    	System.out.println("UR ** WXEntryActivity onRestart **");
	    }
	    
	    @Override
	    protected void onResume() {
	    	// TODO Auto-generated method stub
	    	super.onResume();
	    	System.out.println("UR ** WXEntryActivity onResume **");
	    }
	    
	    @Override
	    protected void onDestroy() {
	    	// TODO Auto-generated method stub
	    	super.onDestroy();
	    	System.out.println("UR ** WXEntryActivity onDestroy **");
	    }
	    
	    
	    
	@Override
	public void onReq(BaseReq req) {
		// TODO Auto-generated method stub
		System.out.println("UR ** WXEntryActivity onReq ** type： " + req.getType());
		if (req.getType() == ConstantsAPI.COMMAND_SHOWMESSAGE_FROM_WX) {
			WXMediaMessage wxMsg = ((ShowMessageFromWX.Req) req).message;		
			WXAppExtendObject obj = (WXAppExtendObject) wxMsg.mediaObject;
			System.out.println("UR ** WXEntryActivity " + obj.extInfo );
			WeCharSDKController.getInstance().setLaunchData(obj.extInfo);
			
			Intent intent = new Intent(this,AppActivity.class);
			intent.putExtra("msgFromWX", obj.extInfo);
			startActivity(intent);
			
		}else if(req.getType() == ConstantsAPI.COMMAND_GETMESSAGE_FROM_WX){
			System.out.println("UR ** WXEntryActivity  COMMAND_GETMESSAGE_FROM_WX ");
	
			Intent intent = new Intent(this,AppActivity.class);
			intent.putExtra("msgFromWX", getIntent());
			startActivity(intent);
		}
		this.finish();
	}

	@Override
	public void onResp(BaseResp resp) {
		System.out.println("UR ** WXEntryActivity onResp **");
		//授权
		if (resp.getType() == ConstantsAPI.COMMAND_SENDAUTH) {
			switch (resp.errCode) {
			case BaseResp.ErrCode.ERR_SENT_FAILED:
				//授权发生错误
				System.out.println("UR ** //授权发生错误 **");
				WeCharSDKController.getInstance().loginedCallBackToLua(0,"AUTO_FAILED");
				break;
			case BaseResp.ErrCode.ERR_USER_CANCEL:
				//用户取消授权
				System.out.println("UR ** //用户取消授权 **");
				WeCharSDKController.getInstance().loginedCallBackToLua(2,"USER_CALCEL");
				break;
			case BaseResp.ErrCode.ERR_OK:
				System.out.println("UR ** //OK用户同意授权 **");
				SendAuth.Resp back = (SendAuth.Resp)resp;  				//用户同意授权
				WeCharSDKController.getInstance().loginedCallBackToLua(1,back.code);//code xxx
				break;
			case BaseResp.ErrCode.ERR_UNSUPPORT:
				System.out.println("UR ** //授权无效 **");
				WeCharSDKController.getInstance().loginedCallBackToLua(2,"USER_CALCEL");
				break;
			default:
				//授权发生错误
				System.out.println("UR ** //授权发生错误 D**");
				WeCharSDKController.getInstance().loginedCallBackToLua(0,"AUTO_DEFAULT_ERR");
				break;
			}
			
		}
		// 分享
		else if (resp.getType() == ConstantsAPI.COMMAND_SENDMESSAGE_TO_WX)
		{
			switch (resp.errCode) {
			case BaseResp.ErrCode.ERR_OK:
				WeCharSDKController.getInstance().urlShareCallBackToLua(1, "SHARE_SUCCESS");
				WeCharSDKController.getInstance().imageShareCallBackToLua(1, "SHARE_SUCCESS");
				break;
			case BaseResp.ErrCode.ERR_USER_CANCEL:
				WeCharSDKController.getInstance().urlShareCallBackToLua(2, "SHARE_USER_CALCEL");
				WeCharSDKController.getInstance().imageShareCallBackToLua(2, "SHARE_USER_CALCEL");
				break;
			case BaseResp.ErrCode.ERR_UNSUPPORT:
				WeCharSDKController.getInstance().urlShareCallBackToLua(2, "SHARE_USER_CALCEL");
				WeCharSDKController.getInstance().imageShareCallBackToLua(2, "SHARE_USER_CALCEL");
				break;
			case BaseResp.ErrCode.ERR_SENT_FAILED:
				WeCharSDKController.getInstance().urlShareCallBackToLua(0, "SHARE_FAILED");
				WeCharSDKController.getInstance().imageShareCallBackToLua(0, "SHARE_FAILED");
				break;
			default:
				WeCharSDKController.getInstance().urlShareCallBackToLua(0, "SHARE_DEFAULT_ERR");
				WeCharSDKController.getInstance().imageShareCallBackToLua(0, "SHARE_DEFAULT_ERR");
				break;
			}
		}
		
		this.finish();
	}

}
