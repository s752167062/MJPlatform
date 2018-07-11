package com.pro.sdk.aliPush;

import java.util.Map;

import com.alibaba.sdk.android.push.MessageReceiver;
import com.alibaba.sdk.android.push.notification.CPushMessage;

import android.content.Context;
import android.util.Log;

public class AliMessageReceiver extends MessageReceiver {
    // 消息接收部分的LOG_TAG
     public static final String TAG = "longma";
     @Override
     public void onNotification(Context context, String title, String summary, Map<String, String> extraMap) {
         // TODO 处理推送通知
         Log.e(TAG, "Receive notification, title: " + title + ", summary: " + summary + ", extraMap: " + extraMap);
     }
     @Override
     public void onMessage(Context context, CPushMessage cPushMessage) {
         Log.e(TAG, "onMessage, messageId: " + cPushMessage.getMessageId() + ", title: " + cPushMessage.getTitle() + ", content:" + cPushMessage.getContent());
     }
     @Override
     public void onNotificationOpened(Context context, String title, String summary, String extraMap) {
         Log.e(TAG, "onNotificationOpened, title: " + title + ", summary: " + summary + ", extraMap:" + extraMap);
     }
     @Override
     protected void onNotificationClickedWithNoAction(Context context, String title, String summary, String extraMap) {
         Log.e(TAG, "onNotificationClickedWithNoAction, title: " + title + ", summary: " + summary + ", extraMap:" + extraMap);
     }
     @Override
     protected void onNotificationReceivedInApp(Context context, String title, String summary, Map<String, String> extraMap, int openType, String openActivity, String openUrl) {
         Log.e(TAG, "onNotificationReceivedInApp, title: " + title + ", summary: " + summary + ", extraMap:" + extraMap + ", openType:" + openType + ", openActivity:" + openActivity + ", openUrl:" + openUrl);
     }
     @Override
     protected void onNotificationRemoved(Context context, String messageId) {
         Log.e(TAG, "onNotificationRemoved");
    }
}
