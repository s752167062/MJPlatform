--@调试模式开关
--@Author   lpx
--@date     2018/04/02
--此文件只存放调试模式的标记，其他内容不能写

local TestConfig = class("TestConfig")

--是否测试模式
TestConfig.TestMode = 0--0 不开测试模式 1 开测试模式 2 连微信登录服

return TestConfig
