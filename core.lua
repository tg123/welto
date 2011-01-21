local WelTo = LibStub:NewLibrary("WelTo-1.0", 1)
WelTo.frame = CreateFrame("Frame")
LibStub:GetLibrary('LibWho-2.0'):Embed(WelTo)

local GuildName = nil

WelTo.frame:RegisterEvent("CHAT_MSG_SYSTEM")
WelTo.frame:RegisterEvent("PLAYER_GUILD_UPDATE")
WelTo.frame:RegisterEvent("PLAYER_ENTERING_WORLD")
WelTo.frame:SetScript("OnEvent", function(self, event, name, ...)
	if event == "CHAT_MSG_SYSTEM" then
		local _,_,gname,_ = strfind(name, string.gsub(ERR_GUILD_JOIN_S,"%%s","%(%.%+%)"));
		if gname then
			local user,time = WelTo:UserInfo(gname, { callback = 'UserDataReturned'} )
			if user then
				WelTo:UserDataReturned(user, time)
			end
		end
	elseif event == "PLAYER_GUILD_UPDATE" or event == "PLAYER_ENTERING_WORLD" then
		GuildName = GetGuildInfo("player")	
	end
		
end)

function WelTo:RandText()
	return self.Text[math.random(table.getn(self.Text))]
end

function WelTo:UserDataReturned(user, time)
	if not GuildName then
		return
	end

	local s = WelTo:RandText()
	s = string.gsub(s,"%%level",user.Level);
	s = string.gsub(s,"%%name",user.Name);
	s = string.gsub(s,"%%guild",GuildName);
	s = string.gsub(s,"%%race",user.Race);
	s = string.gsub(s,"%%class",user.Class);
	s = string.gsub(s,"%%zone",user.Zone); 
	SendChatMessage(s , "GUILD");
end

math.random(GetTime()*1000);
