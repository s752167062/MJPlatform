1. Resources  文件夹是新建的文件夹用于存放资源 ， 在 Build Phases 下的 Copy Bundle Resources 中添加后 会copy添加的内容到 .app 中

2. VoiceConvert 是相关.a 和配置代码 ，完整导入即可

3. 编译设置 
-- Build Settings 
Search Paths 
	添加 Header Search Paths  : 头文件索引  $(PROJECT_DIR)/VoiceConvert
	添加 Library Search Paths : 库文件索引  $(PROJECT_DIR)/VoiceConvert/lib

Build Options 
	Enadle Bitcode : No


-- Build Phases
Link Binary With Libraries
	添加音频 AVFoundation.framework


4. 添加权限
Privacy - Microphone Usage Description
