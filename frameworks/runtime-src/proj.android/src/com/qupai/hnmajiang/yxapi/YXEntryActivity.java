/**
 * 
 */
package com.qupai.hnmajiang.yxapi;

import com.pro.sdk.yixin.YXConstants;
import com.pro.sdk.yixin.YXSDKController;

import android.util.Log;
import android.widget.Toast;
import im.yixin.sdk.api.BaseReq;
import im.yixin.sdk.api.BaseResp;
import im.yixin.sdk.api.BaseYXEntryActivity;
import im.yixin.sdk.api.IYXAPI;
import im.yixin.sdk.api.SendAuthToYX;
import im.yixin.sdk.api.SendMessageToYX;
import im.yixin.sdk.api.YXAPIFactory;
import im.yixin.sdk.util.YixinConstants;

public class YXEntryActivity extends BaseYXEntryActivity {

	/*******************
	 * 返回第三方app根据app id创建的IYXAPI，
	 * 
	 * @return
	 */
	
//	@Override
//	protected void onStart() {
//		// TODO Auto-generated method stub
//		super.onStart();
//		System.out.println("yyyyyyyyyyyyyyyy urYXEntryActivity onStart");
//	}
//	
//	@Override
//	protected void onPause() {
//		// TODO Auto-generated method stub
//		super.onPause();
//		System.out.println("yyyyyyyyyyyyyyyy urYXEntryActivity onPause ");
//	}
	
	
	protected IYXAPI getIYXAPI() {
		return YXAPIFactory.createYXAPI(this, YXConstants.GetAPP_ID());//YixinConstants.TEST_APP_ID
	}

	/**
	 * 易信调用调用时的触发函数
	 */
	@Override
	public void onResp(BaseResp resp) {
		System.out.println("yyyyyyyyyy Yixin.SDK.YXEntryActivity" + "onResp called: errCode=" + resp.errCode + ",errStr=" + resp.errStr
				+ ",transaction=" + resp.transaction);
		switch (resp.getType()) {
		case YixinConstants.RESP_SEND_MESSAGE_TYPE:
			SendMessageToYX.Resp resp1 = (SendMessageToYX.Resp) resp;
			switch (resp1.errCode) {
			case BaseResp.ErrCode.ERR_OK:
				YXSDKController.getInstance().urlShareCallBackToLua(1, "YXSHARE_SUCCESS");
				YXSDKController.getInstance().imageShareCallBackToLua(1, "YXSHARE_SUCCESS");
				break;
			case BaseResp.ErrCode.ERR_COMM:
				YXSDKController.getInstance().urlShareCallBackToLua(0, "SHARE_FAILED");
				YXSDKController.getInstance().imageShareCallBackToLua(0, "SHARE_FAILED");
				break;
			case BaseResp.ErrCode.ERR_USER_CANCEL:
				YXSDKController.getInstance().urlShareCallBackToLua(2, "SHARE_USER_CALCEL");
				YXSDKController.getInstance().imageShareCallBackToLua(2, "SHARE_USER_CALCEL");
				break;
			case BaseResp.ErrCode.ERR_SENT_FAILED:
				YXSDKController.getInstance().urlShareCallBackToLua(0, "SHARE_FAILED");
				YXSDKController.getInstance().imageShareCallBackToLua(0, "SHARE_FAILED");
				break;
			default:
				YXSDKController.getInstance().urlShareCallBackToLua(0, "SHARE_DEFAULT_ERR");
				YXSDKController.getInstance().imageShareCallBackToLua(0, "SHARE_DEFAULT_ERR");
				break;
			}
			break;
		case YixinConstants.RESP_SEND_AUTH_TYPE:
			SendAuthToYX.Resp resp2 = (SendAuthToYX.Resp) resp;
			switch (resp2.errCode) {
			case BaseResp.ErrCode.ERR_OK:
				YXSDKController.getInstance().loginedCallBackToLua(1,resp2.code);
				break;
			case BaseResp.ErrCode.ERR_COMM:
				YXSDKController.getInstance().loginedCallBackToLua(0,"AUTO_FAILED");
				break;
			case BaseResp.ErrCode.ERR_USER_CANCEL:
				YXSDKController.getInstance().loginedCallBackToLua(2,"USER_CALCEL");
				break;
			case BaseResp.ErrCode.ERR_AUTH_DENIED:
				YXSDKController.getInstance().loginedCallBackToLua(2,"USER_CALCEL");
				break;
			default:
				YXSDKController.getInstance().loginedCallBackToLua(0,"AUTO_DEFAULT_ERR");
				break;
			}
		}
		
		//关闭中间界面
		this.finish();
	}

	/**
	 * 易信调用调用时的触发函数
	 */
	@Override
	public void onReq(BaseReq req) {
//		Log.i("YX-SDK-Client", "onReq called: transaction=" + req.transaction);
		switch (req.getType()) {
		case YixinConstants.RESP_SEND_MESSAGE_TYPE:
			SendMessageToYX.Req req1 = (SendMessageToYX.Req) req;
			Toast.makeText(YXEntryActivity.this, req1.message.title, Toast.LENGTH_LONG).show();
		}
	}
}
