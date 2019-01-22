package com.zhuzhi.zzqipai.aoeapi;

import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;

import com.aoetech.sharelibrary.openapi.AOETechManager;


public class AOEEntryActivity extends Activity {
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        Intent intent = getIntent();
        AOETechManager.getInstance().handleIntent(intent);
        finish();
    }
}
