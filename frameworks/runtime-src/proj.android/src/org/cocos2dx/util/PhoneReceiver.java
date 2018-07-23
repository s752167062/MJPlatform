package org.cocos2dx.util;

import android.app.Service;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.telephony.PhoneStateListener;
import android.telephony.TelephonyManager;

public class PhoneReceiver extends BroadcastReceiver {

	@Override
	public void onReceive(Context context, Intent intent) {
		if(!intent.getAction().equals(Intent.ACTION_NEW_OUTGOING_CALL)){
			// 来电
			System.out.println(" >>> 来电");
			TelephonyManager tm = (TelephonyManager) context.getSystemService(Service.TELEPHONY_SERVICE);
			tm.listen(listener, PhoneStateListener.LISTEN_CALL_STATE);
		}
		
	}
	
	// 设置一个监听器
	PhoneStateListener listener = new PhoneStateListener() {

		@Override
		public void onCallStateChanged(int state, String incomingNumber) {
			// 注意，方法必须写在super方法后面，否则incomingNumber无法获取到值。
			super.onCallStateChanged(state, incomingNumber);
			// switch (state) {
			// case TelephonyManager.CALL_STATE_IDLE:
			// 	System.out.println(" >>> 挂断");
			// 	GameToolsController.getInstance().onResume();
			// 	break;
			// case TelephonyManager.CALL_STATE_OFFHOOK:
			// 	System.out.println(" >>> 接听");
			// 	GameToolsController.getInstance().onPause();
			// 	break;
			// case TelephonyManager.CALL_STATE_RINGING:
			// 	System.out.println(" >>> 响铃:来电号码" + incomingNumber);
			// 	GameToolsController.getInstance().onPause();
			// 	// 输出来电号码
			// 	break;
			// }
		}
	};

}