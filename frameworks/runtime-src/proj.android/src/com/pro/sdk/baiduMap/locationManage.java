package com.pro.sdk.baiduMap;

import org.cocos2dx.lib.Cocos2dxHelper;
import org.cocos2dx.lib.Cocos2dxLuaJavaBridge;
import org.json.JSONObject;

import com.baidu.location.BDAbstractLocationListener;
import com.baidu.location.BDLocation;
import com.baidu.location.LocationClient;
import com.baidu.mapapi.model.LatLng;
import com.baidu.mapapi.utils.DistanceUtil;

import android.app.Activity;
import android.app.AlertDialog;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.net.Uri;
import android.os.Handler;
import android.os.Looper;
import android.util.Log;
import android.widget.Toast;


public class locationManage {
	private static locationManage instance = null;
    private Context mContext = null;
	public static locationManage getInstance(){
		if(instance ==null){
			instance = new locationManage();
		}
		return instance;
	}
	
    private String TAG = "longma_gps";
    private boolean location_Started = false;   //是否开启了百度定位
    private boolean location_valid = true;      //定位是否可用
    private int callback_lua = 0;               //LUA 回调
    public LocationService locationService = null;
    
    private double longitude = -1; //bd09ll 经度 ˙
    private double latitude = -1; //bd09ll 纬度
    private String country = ""; // 国家
    private String province = ""; // 省份
    private String city = ""; // 城市
    private String district = ""; // 区/县
    private String street = ""; //街道
    // private boolean tipOnce = true ; 
    
    
    /*** GPS 监听器*/
    private BDAbstractLocationListener locationListener = new BDAbstractLocationListener(){

            @Override
            public void onReceiveLocation(BDLocation location) {
         
                //获取定位结果
                String _time = location.getTime();    //获取定位时间
//                String locID = location.getLocationID();    //获取定位唯一ID，v7.2版本新增，用于排查定位问题
//                Integer locType = location.getLocType();    //获取定位类型
                latitude = location.getLatitude();    //获取纬度信息
                longitude = location.getLongitude();    //获取经度信息
//                float radius = location.getRadius();    //获取定位精准度
//              location.getAddrStr();    //获取地址信息
                country = location.getCountry();    //获取国家信息
//              location.getCountryCode();    //获取国家码
                city =  location.getCity();    //获取城市信息
                // location.getCityCode();    //获取城市码
                district = location.getDistrict();    //获取区县信息
                province = location.getProvince(); // 获取省份信息
                street = location.getStreet();    //获取街道信息
//              location.getStreetNumber();    //获取街道码
//              location.getLocationDescribe();    //获取当前位置描述信息
//              location.getPoiList();    //获取当前位置周边POI信息
//       
//              location.getBuildingID();    //室内精准定位下，获取楼宇ID
//              location.getBuildingName();    //室内精准定位下，获取楼宇名称
//              location.getFloor();    //室内精准定位下，获取当前位置所处的楼层信息
         
                if (location.getLocType() == BDLocation.TypeGpsLocation){
         
                    //当前为GPS定位结果，可获取以下信息
//                  location.getSpeed();    //获取当前速度，单位：公里每小时
//                  location.getSatelliteNumber();    //获取当前卫星数
//                  location.getAltitude();    //获取海拔高度信息，单位米
//                  location.getDirection();    //获取方向信息，单位度
                    Log.i(TAG,"gps 定位结果");
         
                } else if (location.getLocType() == BDLocation.TypeNetWorkLocation){
         
                    //当前为网络定位结果，可获取以下信息
//                  location.getOperators();    //获取运营商信息
         
                } else if (location.getLocType() == BDLocation.TypeOffLineLocation) {
         
                    //当前为网络定位结果
                    Log.i(TAG,"网络定位结果");
         
                } else if (location.getLocType() == BDLocation.TypeServerError) {
         
                    //当前网络定位失败
                    //可将定位唯一ID、IMEI、定位失败时间反馈至loc-bugs@baidu.com
                    Log.i(TAG,"当前网络定位失败");
         
                } else if (location.getLocType() == BDLocation.TypeNetWorkException) {
         
                    //当前网络不通
                    Log.i(TAG,"当前网络不通");
         
                } else if (location.getLocType() == BDLocation.TypeCriteriaException) {
         
                    //当前缺少定位依据，可能是用户没有授权，建议弹出提示框让用户开启权限
                    //可进一步参考onLocDiagnosticMessage中的错误返回码
                    location_valid = false;
                    
                    Log.i(TAG,"定位失败 可能用户没授权等等原因");
                  //   if (tipOnce && canShow ){
                  //   	tipOnce = false;
                  //   	((Activity) mContext).runOnUiThread(new Runnable() {
                		// 	@Override
                		// 	public void run() {
                		// 		popAlterDialog("未打开定位功能,请按照以下流程设置\n设置->权限管理->定位->允许");
                		// 	}
                		// });
                  //   }
                }
                
                if (longitude > 0.1 && latitude > 0.1){
                    location_valid =true;
                    // tipOnce = true;
                }
                do_Callback_LUA(getLastUpdateLocation());
                Log.i(TAG,String.format("定位结果 时间:%s 省份:%s 城市:%s 区/县:%s 街:%s 经度:%f 纬度:%f", _time,province,city,district,street,longitude,latitude));
            }
         
            /**
            * 回调定位诊断信息，开发者可以根据相关信息解决定位遇到的一些问题
            * 自动回调，相同的diagnosticType只会回调一次
            *
            * @param locType           当前定位类型
            * @param diagnosticType    诊断类型（1~9）
            * @param diagnosticMessage 具体的诊断信息释义
            */
            // @Override
            public void onLocDiagnosticMessage(int locType, int diagnosticType, String diagnosticMessage) {
         
                if (diagnosticType == LocationClient.LOC_DIAGNOSTIC_TYPE_BETTER_OPEN_GPS) {
         
                    //建议打开GPS
                    Log.i(TAG,"建议打开GPS");
         
                } else if (diagnosticType == LocationClient.LOC_DIAGNOSTIC_TYPE_BETTER_OPEN_WIFI) {
         
                    //建议打开wifi，不必连接，这样有助于提高网络定位精度！
                    Log.i(TAG,"建议打开WIFI");
         
                } else if (diagnosticType == LocationClient.LOC_DIAGNOSTIC_TYPE_NEED_CHECK_LOC_PERMISSION) {
         
                    //定位权限受限，建议提示用户授予APP定位权限！
                    Log.i(TAG,"建议授予权限");
         
                } else if (diagnosticType == LocationClient.LOC_DIAGNOSTIC_TYPE_NEED_CHECK_NET) {
         
                    //网络异常造成定位失败，建议用户确认网络状态是否异常！
                    Log.i(TAG,"网络异常");
         
                } else if (diagnosticType == LocationClient.LOC_DIAGNOSTIC_TYPE_NEED_CLOSE_FLYMODE) {
         
                    //手机飞行模式造成定位失败，建议用户关闭飞行模式后再重试定位！
                    Log.i(TAG,"飞行模式导致定位失败");
         
                } else if (diagnosticType == LocationClient.LOC_DIAGNOSTIC_TYPE_NEED_INSERT_SIMCARD_OR_OPEN_WIFI) {
         
                    //无法获取任何定位依据，建议用户打开wifi或者插入sim卡重试！
                    Log.i(TAG,"无法获取任何定位依据，建议用户打开wifi或者插入sim卡重试！");
         
                } else if (diagnosticType == LocationClient.LOC_DIAGNOSTIC_TYPE_NEED_OPEN_PHONE_LOC_SWITCH) {
         
                    //无法获取有效定位依据，建议用户打开手机设置里的定位开关后重试！
                    Log.i(TAG,"无法获取有效定位依据，建议用户打开手机设置里的定位开关后重试！！");
         
                } else if (diagnosticType == LocationClient.LOC_DIAGNOSTIC_TYPE_SERVER_FAIL) {
         
                    //百度定位服务端定位失败
                    //建议反馈location.getLocationID()和大体定位时间到loc-bugs@baidu.com
                    Log.i(TAG,"百度定位服务端定位失败 建议反馈location.getLocationID()和大体定位时间到loc-bugs@baidu.com");
         
                } else if (diagnosticType == LocationClient.LOC_DIAGNOSTIC_TYPE_FAIL_UNKNOWN) {
         
                    //无法获取有效定位依据，但无法确定具体原因
                    //建议检查是否有安全软件屏蔽相关定位权限
                    //或调用LocationClient.restart()重新启动后重试！
                    Log.i(TAG,"无法获取有效定位依据，但无法确定具体原因");
                }
            }
        
    };
    
    public void initOnCreate(Context context, LocationService lcs){
        mContext = context;
        locationService = lcs;
    }
    
    /** 开启GPS*/
    public void START_GPS(){
        Log.i(TAG,"开启GPS");
        if(this.location_Started){
            System.out.println(TAG + "// 位置服务已开启 无需重启");
            return ;
        }

        try{
        	locationService.registerListener( locationListener );    
            //注册监听函数
        	locationService.start();
            location_Started = true;
        }
        catch (Exception e){
            Log.i(TAG,"百度定位功能开启失败");
            e.printStackTrace();
        } 
    }

    /** 停止位置更新*/
    public void STOP_GPS(){
        if(location_Started){
            System.out.println(TAG + "// 停止GPS");
            try {
            	locationService.stop();
                location_Started = false;
                callback_lua = -1;
            } catch (Exception e) {
                 System.out.println(TAG + "// 停止GPS失败" );
                 e.printStackTrace();
            }
        }
    }   
    
    /** 是否开启了服务 */
    public boolean isLocationServerOpened(){
        return locationService.getClientIsStart();
    }
    
    public String getLastUpdateLocation(){
    	String ret = "";
    	try{
    		JSONObject json = new JSONObject();
    		json.put("lng",longitude);
    		json.put("lat", latitude);
    		json.put("country", country);
    		json.put("province", province);
    		json.put("city", city);
    		json.put("district", district);
    		json.put("street", street);
    		ret = json.toString();
    	}catch (Exception e){
    		e.printStackTrace();
    	}
        return ret;
    }
    
    public void do_Callback_LUA(final String msg_value){
        System.out.println(TAG + "// LUA  " + msg_value);
        if(this.callback_lua > 0 && msg_value != null ){
            try {
                Cocos2dxHelper.runOnGLThread(new Runnable() {
                    @Override
                    public void run() {
                        Cocos2dxLuaJavaBridge.callLuaFunctionWithString(callback_lua ,msg_value);//调用
                    }
                });
            } catch (Exception e) {
                System.out.println(" UR Localtion Change Call Back Faile xxxxx");
                e.printStackTrace();
            }
        }
    }
    
    public void popAlterDialog(String msgInfo) {
        new AlertDialog.Builder(mContext)
            .setTitle("提示")
            .setMessage(msgInfo)
            .setNegativeButton("取消", new DialogInterface.OnClickListener(){
                @Override
                public void onClick(DialogInterface dialog, int which) {
                    dialog.dismiss();
                }       
            })
            .setPositiveButton("设置",new DialogInterface.OnClickListener() {             
                @Override
                public void onClick(DialogInterface dialog, int which) {
                    //前往应用详情界面
                    try {
                        Uri packUri = Uri.parse("package:" + mContext.getPackageName());
                        Intent intent = new Intent(android.provider.Settings.ACTION_APPLICATION_DETAILS_SETTINGS,packUri);
                        intent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
                        mContext.startActivity(intent);
                    } catch (Exception e) {
                        Toast.makeText(mContext,"跳转失败", Toast.LENGTH_SHORT).show();
                    }
                    dialog.dismiss();
                }
            }).create().show();
    }

    public boolean isLocation_Started(){
        return this.location_Started;
    }

    public boolean isGps_valid(boolean showTips){
        Log.i(TAG,String.valueOf(showTips) + String.valueOf(this.location_valid));
        
        final Runnable runnable = new Runnable() {

			@Override
			public void run() {
				try{
	            	popAlterDialog("请授予定位权限!");
				}catch(Exception e){
					e.printStackTrace();
				}
			}
        		
    	};
        
        if (showTips && !this.location_valid){
        	new Thread() {
        		public void run() {
        			new Handler(Looper.getMainLooper()).post(runnable);//在子线程中直接去new 一个handler
        			}
        		}.start();
        }
        return this.location_valid;
    }
    
    private void show_GPS_Setting(final String tipsStr){
        ((Activity) mContext).runOnUiThread(new Runnable() {
            @Override
            public void run() {
                getInstance().popAlterDialog(tipsStr);
            }
        });
    }

    public static String getGPSLocation(){
    	if (!getInstance().location_Started){
    		getInstance().START_GPS();
    	}
    	return getInstance().getLastUpdateLocation();
    }
    
    public static void setCallFunc(int callback){
    	Log.i("longma_gps","callback" + String.valueOf(callback));
    	if (!getInstance().location_Started){
    		getInstance().START_GPS();
    	}
    	
    	getInstance().callback_lua = callback;
    }
    public static void stopGps(){
    	getInstance().STOP_GPS();
    }
    
    public static boolean getGps_isStarted(){
    	return getInstance().isLocation_Started();
    }

    //是否有授权 开启定位==
    //只能在开启启动百度地图sdk之后调用了
    public static boolean getGps_status(boolean showTips){
        return getInstance().isGps_valid(showTips);
    }
    
    public static String get_GPS_Distance(String lng1,String lat1,String lng2,String lat2){
//    	Log.i("longma_gps",lng1 + " : " + lat1 + ":" + lng2 + ":" + lat2);
    	LatLng p1 = new LatLng(Double.valueOf(lat1),Double.valueOf(lng1));
    	LatLng p2 = new LatLng(Double.valueOf(lat2),Double.valueOf(lng2));
    	double ret = DistanceUtil.getDistance(p1, p2);
    	return String.valueOf(ret);
    }

    public static void Show_APP_GPS_Setting(String stipsStr){
        getInstance().show_GPS_Setting(stipsStr);
    }
}



