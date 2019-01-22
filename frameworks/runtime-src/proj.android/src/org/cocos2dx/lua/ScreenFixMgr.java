package org.cocos2dx.lua;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.io.InputStream;

import android.widget.FrameLayout;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import android.app.Activity;
import android.content.Context;
import android.content.res.AssetManager;
import android.hardware.Sensor;
import android.hardware.SensorEvent;
import android.hardware.SensorEventListener;
import android.hardware.SensorManager;
import android.os.Build;
import android.os.Handler;
import android.os.Message;
import android.view.Display;
import android.view.WindowManager;
import android.view.View;
import android.widget.FrameLayout;

public class ScreenFixMgr {
	static private ScreenFixMgr instance;
	static public ScreenFixMgr getInstance(){
		if(instance == null){
			instance = new ScreenFixMgr();
		}
		return instance;
	}
	
	private Context mContext;
	private FrameLayout framelayout;
	private boolean canFix = false;
	
	private float ratio = 1136/640;
	private boolean ratiofix = false;
	private int offsetl = 0;
	private int offsetr = 0;
	private boolean reverse = false;
	
	private OrientationSensorListener listener;
    private SensorManager sm;
    private Sensor sensor;
    
    
    public void setActivityFramelayout(FrameLayout view){
    	this.framelayout = view;
    }
    
	public void init(Context context){
		this.mContext = context;
		try {
			String screenfix = this.readFile();
			if(screenfix == null || screenfix.equals("")){
				System.out.println(" >>>> ScreenFixMgr init screenfix.json null");
				return;
			}
			JSONArray obj = new JSONArray(screenfix);
			if(obj != null && obj.length() >0){
				this.canFix = true;
				
				boolean found = false;
				for (int i = 1; i < obj.length(); i++) {
					JSONObject item = obj.getJSONObject(i);
					if(item != null){
						String pname = item.getString("name");
						if(pname != null && pname.equals(Build.MODEL)){
							ratio   = Float.parseFloat(item.getString("ratio"));
							offsetl = item.getInt("offset_l");
							offsetr = item.getInt("offset_r");
							ratiofix= item.getBoolean("ratiofix"); 
							found = true;
							break;
						}
					}
				}
				if(found == false){
					//没有找到指定要如何处理的设备 使用默认的配置
					JSONObject item = obj.getJSONObject(0);
					if(item != null){
						ratio   = Float.parseFloat(item.getString("ratio"));
						offsetl = item.getInt("offset_l");
						offsetr = item.getInt("offset_r");		
						ratiofix= item.getBoolean("ratiofix");
					}
				}
				
				/***/   
		        sm = (SensorManager) ((Activity)this.mContext).getSystemService(Context.SENSOR_SERVICE);
		        sensor = sm.getDefaultSensor(Sensor.TYPE_ACCELEROMETER);
		        listener = new OrientationSensorListener(new Handler(){
		            @Override
		            public void handleMessage(Message msg) {
		                if (msg.what == 888) {
		                	try{
		                		int orientation = msg.arg1;
			                    if (orientation > 69 && orientation < 135) {
			                    	System.out.println(">>>>>"+ "横屏翻转: " + orientation);
			                    	reverse = true;
			                    	layoutFix(ratio, offsetl , offsetr , ratiofix , reverse);
			                    	
			                    } else if (orientation > 135 && orientation < 247) {
			                    	System.out.println(">>>>>"+ "竖屏翻转: " + orientation);

			                    } else if (orientation > 247 && orientation < 315) {
			                    	System.out.println(">>>>>"+ "横屏: " + orientation);
			                    	reverse = false;
			                    	layoutFix(ratio, offsetl , offsetr , ratiofix , reverse);
			                    	
			                    } else if ((orientation > 315 && orientation < 360) || (orientation > 0 && orientation < 69)) {
			                    	System.out.println(">>>>>"+ "竖屏: " + orientation);
			                    	
			                    }
		                	}catch(Exception e){
		                		System.out.println(" >>>> ScreenFixMgr handleMessage JSONException");
		                		e.printStackTrace();
		                	}
		                }
		                super.handleMessage(msg);
		            }
		        });
		        
		        /**/
		        layoutFix(ratio,  offsetl , offsetr, ratiofix , reverse);
		        System.out.println(" >>>> ScreenFixMgr init layoutFix");
			}
			
		}catch (JSONException e) {
			// TODO: handle exception
			System.out.println(" >>>> ScreenFixMgr init JSONException");
			e.printStackTrace();
		}catch (Exception e) {
			// TODO: handle exception
			System.out.println(" >>>> ScreenFixMgr init Exception");
			e.printStackTrace();
		}
		
	}
	
	public void onResume(){
		try{
			sm.registerListener(listener, sensor, SensorManager.SENSOR_DELAY_UI);
		}catch (Exception e) {
			// TODO: handle exception
			e.printStackTrace();
		}	
	}
	
	public void onPause(){
		try{
			sm.unregisterListener(listener);
		}catch (Exception e) {
			// TODO: handle exception
			e.printStackTrace();
		}
	}
	

	public void layoutFix(float ratio , int offsetl ,  int offsetr , boolean ratiofix , boolean reverse){
    	/* fix 宽高 */
		if(this.framelayout == null){
			return ;
		}
		
        WindowManager m = ((Activity)this.mContext).getWindowManager(); 
        Display d = m.getDefaultDisplay();//为获取屏幕宽、高 
        // android.view.WindowManager.LayoutParams p = ((Activity)this.mContext).getWindow().getAttributes();//获取对话框当前的参数值 
        int fheight = d.getHeight();
        int fwidth  = d.getWidth();
        
        System.out.println(">>>>> ScreenFixMgr " + fwidth +" " + fheight + " " + fwidth/fheight);
        if(fwidth/fheight - 1136/640 > 0){
        	float alp = fwidth/fheight ;
        	if(alp - ratio > 0){
        		int ratiooffset = 0;
        		if(ratiofix == true){
        			ratiooffset = (int)(fwidth - ratio * fheight);
        		}
        		
        		FrameLayout.LayoutParams lp = (FrameLayout.LayoutParams)this.framelayout.getLayoutParams();
        		System.out.println(">>>>> ScreenFixMgr  surfaceview lp " + lp.width +" " + lp.height );
        		if(reverse == true){
            		lp.setMargins(offsetr + ratiooffset , 0, offsetl + ratiooffset, 0);
        		}else{
        			lp.setMargins(offsetl + ratiooffset , 0, offsetr + ratiooffset, 0);
        		}
        		
        		this.framelayout.setLayoutParams(lp);
        	}
        }
        
    }
	
	
	
	public String readFile(){
		//1 优先update 文件夹下
		String files_dir_path =  this.mContext.getFilesDir().getAbsolutePath();
		if(files_dir_path.endsWith("/")){
			files_dir_path += "update/src/AppPlatform/cocos/screenfix.json" ;
		}else{
			files_dir_path += "/update/src/AppPlatform/cocos/screenfix.json" ;
		}
		
		File xxxffile = new File(files_dir_path);
		if(xxxffile.exists() && xxxffile.isFile()){
			try {
				FileInputStream in = new FileInputStream(xxxffile);
				return r_File(in);
			} catch (FileNotFoundException e) {
				// TODO Auto-generated catch block
				System.out.println(" >>>> ScreenFixMgr screenfix FileNotFoundException");
				e.printStackTrace();
				return "";
			}
			
		}
		
		//2 本地
		AssetManager am = mContext.getAssets();
		InputStream in;
		try {
			in = am.open("src/AppPlatform/cocos/screenfix.json");
			return r_File(in);
			
		} catch (IOException e) {
			// TODO Auto-generated catch block
			System.out.println(" >>>> ScreenFixMgr AssetManager screenfix IOException");
			e.printStackTrace();
			return "";
		}
		
	} 
	
	public String r_File(InputStream in){
		try {
			byte b[] = new byte[1024];   
	        int len = 0;   
	        int temp=0;          			//所有读取的内容都使用 temp 接收   
	        while((temp=in.read())!=-1){    //当没有读取完时，继续读取   
	            if(len >= b.length){
	            	System.out.println("  coco UR size up to"  + b.length + 1024);
	            	byte temp_b[] =  new byte[b.length + 1024];
	            	for(int i = 0 ; i< b.length ; i++){
	            		temp_b[i] = b[i];
	            	}
	            	b = temp_b;
	            }
	        	b[len]=(byte)temp;   
	            len++;   
	        }   
	        in.close();   
	        
	        String s = new String(b,0,len);
	        System.out.println(" coco ur length "+ s.length());
	        return s;
		} catch (IOException e) {
			// TODO: handle exception
			e.printStackTrace();
			return "";
		}
	}
	
}

class OrientationSensorListener implements SensorEventListener {

    private static final int DATA_X = 0;
    private static final int DATA_Y = 1;
    private static final int DATA_Z = 2;

    public static final int ORIENTATION_UNKNOWN = -1;

    private Handler rotateHandler;

    public OrientationSensorListener(Handler handler) {
        rotateHandler = handler;
    }

    @Override
    public void onSensorChanged(SensorEvent sensorEvent) {
        float[] values = sensorEvent.values;
        int orientation = ORIENTATION_UNKNOWN;
        float X = -values[DATA_X];
        float Y = -values[DATA_Y];
        float Z = -values[DATA_Z];
        float magnitude = X * X + Y * Y;
        // Don't trust the angle if the magnitude is small compared to the y value
        if (magnitude * 4 >= Z * Z) {
            float OneEightyOverPi = 57.29577957855f;
            float angle = (float) Math.atan2(-Y, X) * OneEightyOverPi;
            orientation = 90 - (int) Math.round(angle);
            // normalize to 0 - 359 range
            while (orientation >= 360) {
                orientation -= 360;
            }
            while (orientation < 0) {
                orientation += 360;
            }
        }

        if (rotateHandler != null) {
            rotateHandler.obtainMessage(888, orientation, 0).sendToTarget();
        }

    }

    @Override
    public void onAccuracyChanged(Sensor sensor, int i) {

    }
}
