package org.cocos2dx.lua;

import org.cocos2dx.lib.ResizeLayout;

import com.zhuzhi.zzqipai.R;

import android.app.Activity;
import android.content.pm.ActivityInfo;
import android.os.Bundle;
import android.view.Menu;
import android.view.MenuItem;
import android.view.ViewGroup;
import android.view.WindowManager;
import android.webkit.WebSettings;
import android.webkit.WebView;
import android.webkit.WebViewClient;

public class H5Activity extends Activity {

	protected ResizeLayout mFrameLayout = null;
	private WebView mWebView ;
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		
		String url = getIntent().getExtras().getString("url"); 
		int ori    = getIntent().getExtras().getInt("orientation");
		if(ori == 0) {
            setRequestedOrientation(ActivityInfo.SCREEN_ORIENTATION_SENSOR_LANDSCAPE);
        } else {
            setRequestedOrientation(ActivityInfo.SCREEN_ORIENTATION_SENSOR_PORTRAIT);
        }
        

        //2.Set the format of window : keep screen on
        getWindow().setFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON, WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON);
		
		
		// FrameLayout
        ViewGroup.LayoutParams framelayout_params =
            new ViewGroup.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT,
                                       ViewGroup.LayoutParams.MATCH_PARENT);
        mFrameLayout = new ResizeLayout(this);
        mFrameLayout.setLayoutParams(framelayout_params);
        
		setContentView(mFrameLayout);
		
		//h5
		mWebView = new WebView(this);
		mWebView.getSettings().setJavaScriptEnabled(true);//让浏览器支持javascript
		mWebView.getSettings().setUseWideViewPort(true); //将图片调整到适合webview的大小 
		mWebView.getSettings().setLoadWithOverviewMode(true); // 缩放至屏幕的大小

		mWebView.getSettings().setCacheMode(WebSettings.LOAD_CACHE_ELSE_NETWORK); //关闭webview中缓存 
		mWebView.getSettings().setAllowFileAccess(true); //设置可以访问文件 
		mWebView.getSettings().setJavaScriptCanOpenWindowsAutomatically(true); //支持通过JS打开新窗口 
		mWebView.getSettings().setLoadsImagesAutomatically(true); //支持自动加载图片
		mWebView.getSettings().setDefaultTextEncodingName("utf-8");//设置编码格式
		
		mWebView.setWebViewClient(new WebViewClient(){
			@Override
			public boolean shouldOverrideUrlLoading(WebView view, String url) {
				// TODO Auto-generated method stub
				System.out.println(">>>> h5 shouldOverrideUrlLoading " + url);
				if(url.startsWith("returnApp")){
					H5Activity.this.finish();
					return false;
				}
				view.loadUrl(url);
				return true;
			}
		});
		mWebView.loadUrl("http://www.baidu.com");
		
		mFrameLayout.addView(mWebView);
	}
	
	@Override
	protected void onResume() {
		// TODO Auto-generated method stub
		super.onResume();
		this.mWebView.onResume();
	}
	
	@Override
	protected void onPause() {
		// TODO Auto-generated method stub
		super.onPause();
		this.mWebView.onPause();
	}
	
	@Override
	protected void onDestroy() {
		// TODO Auto-generated method stub
		super.onDestroy();
		this.mWebView.destroy();
	}
	
	
	public void canGoBack(){
		this.mWebView.canGoBack();
	}
	
	public void goBack(){
		this.mWebView.goBack();
	}
	
	public void goForward(){
		this.mWebView.goForward();
	}
	
	public void clearData(){
		this.mWebView.clearCache(true);
		this.mWebView.clearHistory();
		this.mWebView.clearFormData();
	}
	
	
}

