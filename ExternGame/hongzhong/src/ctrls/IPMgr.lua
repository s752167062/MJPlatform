
-- author longma
-- 用于获取公网IP

local IPMgr = {}
local schedulerID = nil

local IPTab = {
    -- "https://ipip.yy.com/get_ip_info.php",
    "http://2017.ip138.com/ic.asp",
    -- "http://whois.pconline.com.cn/ipJson.jsp?callback={IP:255.255.255.255}",
    "http://www.whatismyip.com.tw",
}
function IPMgr:init()
    -- Util.getPublicIP(handler(self,self.fromNetwork))
    self.curNum = 1
    Util.getStringFromUrl(IPTab[self.curNum],handler(self,self.fromNetwork),true)
end 

function IPMgr:fromNetwork(respone)
    if respone ~= nil then
        -- local start = string.find(respone , "[" , 1 , true)
        -- local endp = string.find(respone , "]" , 1 , true)
        local str = ""
        respone:gsub("%d+%.%d+%.%d+%.%d+",function(a)
            str = a
        end)

        if str ~= nil and str ~= "" then
            -- local str = string.sub(respone,start + 1,endp -1)
            cclog("longma IP "..str)
            if str ~= "0.0.0.0" then
                PlayerInfo.ip = str
            end 
            self:stopScheduler()
        end
        cclog("正常")
    elseif PlayerInfo.ip == nil or PlayerInfo.ip == "" then 
        cclog("timeout")
        self:startScheduler()
    end
end 

function IPMgr:startScheduler()
	if schedulerID ~= nil then return end 
	cclog("longma IPMgr:startScheduler")
	local scheduler = cc.Director:getInstance():getScheduler()
	schedulerID = scheduler:scheduleScriptFunc(function()
        self.curNum = self.curNum + 1
        self.curNum = (self.curNum -1 ) % #IPTab + 1
		Util.getStringFromUrl(IPTab[self.curNum],handler(self,self.fromNetwork),true)
	end ,5,false)

end 

function IPMgr:stopScheduler()
	cclog("longma IPMgr:stopScheduler")
	if schedulerID then 
		local scheduler = cc.Director:getInstance():getScheduler()
		scheduler:unscheduleScriptEntry(schedulerID)
		schedulerID = nil
	end 
end 
return IPMgr