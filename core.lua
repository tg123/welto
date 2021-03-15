--[[
	name, rankName, rankIndex, level, classDisplayName, zone, publicNote, officerNote, 
	isOnline, status, class, achievementPoints, achievementRank, isMobile, canSoR, repStanding, GUID = GetGuildRosterInfo(index)
	numTotalGuildMembers, numOnlineGuildMembers, numOnlineAndMobileMembers = GetNumGuildMembers()
	guildName, guildRankName, guildRankIndex, realm = GetGuildInfo(unit)
	ERR_GUILD_JOIN_S = "%s加入了公会。"
]] --

-- 自定义欢迎文本表
local welcomeText = {
	'你好啊，%name，你一定是一个厉害的%class吧',
	'嗨！我们又多了一位%class朋友，大家欢迎%name。',
	'听说加入%guild后%name再也不是移动荣誉了……',
	'纳鲁没有忘记%name，指引他来到%guild。',
	'%name你是来帮我我们打败燃烧军团的吧！',
	'%name上个月你就%level吧怎么还%level阿？',
	'花儿对你笑，%name，我代表花儿欢迎你。',
	'听到家乡的声音了么%name。',
	'%name听起来像个%class',
	'%name，听起来很好吃啊……',
	'%name，你是不是美女阿？',
	'欢迎来到%guild，我们这个面包由依然平淡提供。',
	'作为%class，%name你一定知道怎么制造灭团的~',
	'欢迎来到%guild，这里就是你的家，拿着这个炉石，%name，它是给你的。'
}
-- 随机读取欢迎语函数
local function RandomWelcomeText()
	return welcomeText[math.random(table.getn(welcomeText))]
end
--替换随机欢迎语中的姓名、职业、等级并广播到公会频道函数
local function Broadcast(name, level, class, guild)
	local s = RandomWelcomeText()
	s = string.gsub(s, '%%level', level)
	s = string.gsub(s, '%%name', name)
	s = string.gsub(s, '%%guild', guild)
	s = string.gsub(s, '%%class', class)

	SendChatMessage(s, 'GUILD')
end

do
	local f = CreateFrame('Frame')
	local str = GUILDEVENT_TYPE_JOIN:gsub('%%s', '')
	f:RegisterEvent('CHAT_MSG_SYSTEM')
	f:SetScript(
		'OnEvent',
		function(self, event, msg)
			if msg:find(str) then
				local name = msg:gsub(str, '')
				name = Ambiguate(name, 'guild')
				if not UnitIsUnit(name, 'player') then
					C_Timer.After(
						random(1000) / 1000,
						function()
							SendChatMessage(('欢迎%s加入公会！'):format(name), 'GUILD')
						end
					)
				end
			end
		end
	)
end

-- 在指定事件发生时广播随机欢迎语，插件核心
local guild
local name
local level
local connected
local class
local Welcomeframe = CreateFrame('Frame', nil, UIparent)
Welcomeframe:RegisterEvent('CHAT_MSG_SYSTEM')
Welcomeframe:RegisterEvent('PLAYER_GUILD_UPDATE')
Welcomeframe:RegisterEvent('PLAYER_ENTERING_WORLD')
Welcomeframe:SetScript(
	'OnEvent',
	function(self, event, name, ...)
		if event == 'CHAT_MSG_SYSTEM' then
			local newMemberName = string.match(name, string.gsub(ERR_GUILD_JOIN_S, '%%s', '%(%.%+%)')) -- 取新入会成员名字
			print(newMemberName) -- check
			if newMemberName then
				local numTotalGuildMembers,
					numOnlineGuildMembers,
					_ = GetNumGuildMembers() -- 取公会在线人数
				print(numTotalGuildMembers) -- check
				for i = 1, numTotalGuildMembers do -- 取在线成员的信息
					local name,
						_,
						_,
						level,
						_,
						_,
						_,
						_,
						connected,
						_,
						class,
						_,
						_,
						_,
						_,
						_,
						guid = GetGuildRosterInfo(i)
					if not connected then
						return
					end

					print(numOnlineGuildMembers .. ' ' .. 'OnLine') -- check
					if (newMemberName == name) then -- 比对新入会成员姓名和在线的已有成员姓名
						print(newMemberName) -- check
						C_Timer.After(
							3,
							function()
								Broadcast(name, level, class, guild)
							end
						) -- Delay3秒后调用广播函数，实现广播
					end
				end
			end
		elseif event == 'PLAYER_GUILD_UPDATE' or event == 'PLAYER_ENTERING_WORLD' then
			guild = GetGuildInfo('player') -- 更新公会名
		end
	end
)
