--[[

	General functions
	
]]

if not Serenity then return end

function Serenity.GetActiveAnchor(anchor)
	return anchor[1], anchor[2] == nil and UIParent or anchor[2], anchor[3], anchor[4], anchor[5]
end

function Serenity.GetActiveFont(key, index)
	local f1, f2, f3 = unpack(key)
	if index then
		if index == 1 then
			return (Serenity.GetLibSharedMedia3():Fetch("font", f1))
		else
			return key[index]
		end
	end	
	return Serenity.GetLibSharedMedia3():Fetch("font", f1), f2, f3
end

function Serenity.GetMatchTableValSimple(wTable, toMatch, returnIndex)
	local i
	for i=1,#wTable do
		if wTable[i] == toMatch then return (returnIndex and i or wTable[i]) end
	end
	return nil
end

function Serenity.GetMatchTableVal(wTable, colMatch, colReturn, toMatch)
	local i
	for i=1,#wTable do
		if wTable[i][colMatch] == toMatch then return wTable[i][colReturn] end
	end
	return nil
end

function Serenity.GetMatchTablePosition(wTable, colMatch, toMatch)
	local i
	for i=1,#wTable do
		if wTable[i][colMatch] == toMatch then return(i) end
	end
	return nil
end

--Return rounded number
function Serenity.Round(v, decimals)
	if not decimals then decimals = 0 end
    return (("%%.%df"):format(decimals)):format(v)
end

--Truncate a number off to n places
function Serenity.Truncate(v, decimals)
	if not decimals then decimals = 0 end
    return v - (v % (0.1 ^ decimals))
end

function Serenity.ParseItemLink(itemLink)
	if not itemLink then return "" end
	return string.find(itemLink, "|?c?f?f?(%x*)|?H?([^:]*):?(%d+):?(%d*):?(%d*):?(%d*):?(%d*):?(%d*):?(%-?%d*):?(%-?%d*):?(%d*)|?h?%[?([^%[%]]*)%]?|?h?|?r?")
end
		
--RGB to Hex
function Serenity.RGBToHex(r, g, b)
	r = r <= 1 and r >= 0 and r or 0
	g = g <= 1 and g >= 0 and g or 0
	b = b <= 1 and b >= 0 and b or 0
	return string.format("\124cff%02x%02x%02x", r*255, g*255, b*255)
end

--Hex to RGB
function Serenity.HexToRGB(hex)
	local rhex, ghex, bhex = string.sub(hex, 1, 2), string.sub(hex, 3, 4), string.sub(hex, 5, 6)
	return tonumber(rhex, 16), tonumber(ghex, 16), tonumber(bhex, 16)
end

function Serenity.UnpackColors(color)
	if color.a then
		return color.r and color.r or 0, color.g and color.g or 0, color.b and color.b or 0, color.a
	else
		return color.r and color.r or 0, color.g and color.g or 0, color.b and color.b or 0
	end
end

local DAY, HOUR, MINUTE = 86400, 3600, 60 --used for formatting text
local DAYISH, HOURISH, MINUTEISH = 3600 * 23.5, 60 * 59.5, 59.5 --used for formatting text at transition points
local EXPIRING_DURATION = 3.2 --the minimum number of seconds a cooldown must be to use to display in the expiring format

function Serenity.FormatTimeText(val, tenths, autoColor, timeIndicator)

	local db = Serenity.db.profile.frames.cooldowns

	-- Expiring
	if (val <= EXPIRING_DURATION) then	
		if tenths then
			return autoColor and format(Serenity.RGBToHex(unpack(db["expiringcolor"]))..'%.1f%s|r', val, timeIndicator and "" or "") or 
				format("%.1f%s", val, timeIndicator and "" or "")
		else
			return autoColor and format(Serenity.RGBToHex(unpack(db["expiringcolor"]))..'%d%s|r', val, timeIndicator and "" or "") or 
				format('%d%s', val, timeIndicator and "" or "")
		end	
	
	-- Format seconds
	elseif (val <= MINUTEISH) then
		if tenths then
			return autoColor and format(Serenity.RGBToHex(unpack(db["secondscolor"]))..'%.1f%s|r', val, timeIndicator and "" or "") or 
				format("%.1f%s", val, timeIndicator and "" or "")
		else
			return autoColor and format(Serenity.RGBToHex(unpack(db["secondscolor"]))..'%d%s|r', tonumber(Serenity.Round(val)), timeIndicator and "" or "") or 
				format('%d%s', tonumber(Serenity.Round(val)), timeIndicator and "" or "")
		end

	-- Format Minutes
	elseif (val <= HOURISH ) then
		return autoColor and format(Serenity.RGBToHex(unpack(db["minutescolor"]))..'%d%s|r', tonumber(Serenity.Round(val/MINUTE)), timeIndicator and "m" or "") or 
			format('%d%s', tonumber(Serenity.Round(val/MINUTE)), timeIndicator and "m" or "")

	-- Format Hours
	elseif (val <= DAYISH ) then
		return autoColor and format(Serenity.RGBToHex(unpack(db["hourscolor"]))..'%d%s|r', tonumber(Serenity.Round(val/HOUR)), timeIndicator and "h" or "") or 
			format('%d%s', tonumber(Serenity.Round(val/HOUR)), timeIndicator and "h" or "")

	-- Format Days
	else
		return autoColor and format(Serenity.RGBToHex(unpack(db["dayscolor"]))..'%d%s|r', tonumber(Serenity.Round(val/DAY)), timeIndicator and "d" or "") or 
			format('%d%s', tonumber(Serenity.Round(val/DAY)), timeIndicator and "d" or "")
	end
end
--[[
	Returns the proper chat channel to display a chat message in.
	Returns the same channel passed, unless it's a "SELFWHISPER" or
	value of 1.  Whispers make sure to hide the outgoing whisper so you
	do not need to see double messages, especially for "SELFWHISPER".
]]
function Serenity.GetChatChan(chan)

	local function HideOutgoing(self, event, msg, author, ...)
		if author == GetUnitName("player") then
			ChatFrame_RemoveMessageEventFilter("CHAT_MSG_WHISPER_INFORM", HideOutgoing)
    		return true
		end
	end

	if chan ~= "AUTO" then	
		if chan == "SELFWHISPER" then
			ChatFrame_AddMessageEventFilter("CHAT_MSG_WHISPER_INFORM", HideOutgoing)
			return("WHISPER")
		end		
		return(chan)
	end

	-- Auto roll-down
	local zoneType = select(2, IsInInstance())
	if zoneType == "pvp" or zoneType == "arena" then
	
		return "BATTLEGROUND"

	elseif GetNumRaidMembers() > 0 then

		return "RAID"

	elseif GetNumPartyMembers() > 0 then

		return "PARTY"
	else
		ChatFrame_AddMessageEventFilter("CHAT_MSG_WHISPER_INFORM", HideOutgoing)
		return "WHISPER" -- default to whisper as last resort unless directly specified
	end
end

function Serenity.GetGroupType()

	local zoneType = select(2, IsInInstance())
	if zoneType == "arena" then	
		return "ARENA"		
	elseif zoneType == "pvp" then	
		return "PVP" -- was "BATTLEGROUND"
	elseif GetNumRaidMembers() > 0 then
		return "RAID"
	elseif GetNumPartyMembers() > 0 then
		return "PARTY"
	else
		return "SOLO"
	end	
end

 function Serenity.RemoveInterfaceOptions(ACD3Parent, ACD3Child, BlizzParent, BlizzChild)
 
	-- Kill AceConfigDialog3 stuff
	if (ACD3Parent ~= nil) then -- Don't touch ACD3 if no parent specified.
		local ACD3 = LibStub("AceConfigDialog-3.0")		
		if (ACD3Child == nil) then -- Assume we are removing the whole panel if no child was specified
			bChildPanel = false
			ACD3.BlizOptions[ACD3Parent] = nil
		else
			ACD3.BlizOptions[ACD3Parent][ACD3Parent.."\001".. ACD3Child] = nil -- Untested - raw from wowwiki! (I don't use this in Serenity)
		end
	end
	
	-- Kill specific Blizzard stuff
	local Key, Value
	if (BlizzChild ~= nil) then
		for Key,Value in pairs(INTERFACEOPTIONS_ADDONCATEGORIES) do
			if (Value.parent == BlizzParent) and (Value.name == BlizzChild) then
				tremove(INTERFACEOPTIONS_ADDONCATEGORIES, Key)
			end
		end
	end	
 	InterfaceAddOnsList_Update()
 end

function Serenity.Timer_OnSizeChanged(self, width, height)

	self.text:SetFont(Serenity.GetActiveFont(Serenity.db.profile.frames.cooldowns.font))
	if Serenity.db.profile.frames.cooldowns.enableshadow then
		self.text:SetShadowColor(unpack(Serenity.db.profile.frames.cooldowns.shadowcolor))
		self.text:SetShadowOffset(unpack(Serenity.db.profile.frames.cooldowns.fontshadowoffset))
	end
	if self.enabled then
		self.nextUpdate = 0
		self:Show()
	end
end

function Serenity.Timer_OnUpdate(self, elapsed)

	if self.nextUpdate > 0 then
		self.nextUpdate = self.nextUpdate - elapsed
	else
		local remain = self.duration - (GetTime() - self.start)
		if floor(remain + 0.1) > 0 then
			self.text:SetText(Serenity.FormatTimeText(remain, false, true, true))
			self.nextUpdate = 0.1
		else
			self.enabled = nil
			self:Hide()
		end
	end
end

function Serenity.Timer_Create(self)

	local scaler = CreateFrame('Frame', nil, self)
	scaler:SetAllPoints(self)

	local timer = CreateFrame('Frame', nil, scaler)
	timer:Hide()
	timer:SetAllPoints(scaler)
	timer:SetScript("OnUpdate", Serenity.Timer_OnUpdate)

	local text = timer:CreateFontString(nil, 'OVERLAY')
	text:SetPoint("CENTER", (floor(self:GetWidth() + 0.5) / 30) * 2, 0) -- 2px offset based on 18px font and 30px standard icon width
	text:SetJustifyH("CENTER")
	text:SetJustifyV("CENTER")
	timer.text = text

	Serenity.Timer_OnSizeChanged(timer, scaler:GetSize())
	scaler:SetScript("OnSizeChanged", function(self, ...) Serenity.Timer_OnSizeChanged(timer, ...) end)

	self.timer = timer
	return timer
end

function Serenity.CheckForDebuff(spell, target, owner)
	local name, rank, icon, count, debuffType, duration, expirationTime, unitCaster, isStealable, shouldConsolidate, spellId = 
		UnitAura(target, tonumber(spell) and GetSpellInfo(tonumber(spell)) or spell, nil, (owner == "PLAYERS") and "PLAYER|HARMFUL" or "HARMFUL")		
		
	return (name and icon or nil), (name and duration or 0), ((name and (expirationTime - GetTime()) > 0) and math.max(expirationTime - GetTime(), 0) or 0), (count)
end

function Serenity.CheckForBuff(spell, target, owner)
	local name, rank, icon, count, debuffType, duration, expirationTime, unitCaster, isStealable, shouldConsolidate, spellId = 
		UnitAura(target, tonumber(spell) and GetSpellInfo(tonumber(spell)) or spell, nil, (owner == "PLAYERS") and "PLAYER|HELPFUL" or "HELPFUL")		
		
	return (name and icon or nil), (name and duration or 0), ((name and (expirationTime - GetTime()) > 0) and math.max(expirationTime - GetTime(), 0) or 0), (count)
end

--[[
	Wrapper to check for a timer's presence.
	
	returns:
	1 - spell's or item's texture if found or nil,
	2 - full duration time of the spell or item
	3 - remaining time on the cooldown or duration
	4 - stacks of the aura or 0 for none or n/a
]]
function Serenity.GetTimerInfo(spell, item, target, timerType, owner)

	local i, icon, duration, remaining, stacks, itemName, itemLink, itemTexture, startTime, enable, name, rank, maxPlayers, inInstance, instanceType

	-- ITEM COOLDOWN
	if item then		
		itemName, itemLink, _, _, _, _, _, _, _, itemTexture = GetItemInfo(tonumber(item) or item)
		if not itemLink then return (nil), (0), (0), (0) end
		startTime, duration, enable = GetItemCooldown(select(5,Serenity.ParseItemLink(itemLink))) -- Why the hell doesn't GetItemInfo return the ID
		return (itemName and itemTexture or nil), (itemName and duration or 0), (itemName and math.max(startTime + duration - GetTime(), 0) or 0), (0) -- no stacks needed for an item		
	end
	
	-- SPELL COOLDOWN (this is only for player spells - including pet spells)
	if (timerType == "COOLDOWN") then	
		name, rank, icon = GetSpellInfo(tonumber(spell) or spell)
		if not name then return (nil), (0), (0), (0) end
		startTime, duration, enable = GetSpellCooldown(name)
		-- Need to hack this code a bit, because if we are on GCD it will trigger this to have a duration.
		-- Assuming the duration cannot be less than 1.51, we can override the issues with a simple hack.
		if duration and (duration > 1.5) then
			return (duration == 0 and nil or icon), (duration == 0 and 0 or duration), (duration == 0 and 0 or math.max(startTime + duration - GetTime(), 0)), (0)
		else
			return (nil), (0), (0), (0) -- easy!
		end
	end
	
	-- SPELL DURATION (This is the tricky one dealing with hostile vs. friendly and full checks like all of raid/party, etc.)
	if (target == "raid") or (target == "raidpet") then
	
		if GetNumRaidMembers() ~= 0 then
			if IsInInstance() then maxPlayers = select(5, GetInstanceInfo()) else
				maxPlayers = 40
			end			
			for i=1,maxPlayers do
				if UnitExists(target..i) then
					if owner ~= "PLAYERS" then -- Player can not debuff a friendly unit, unless mind controlled or such!
						icon, duration, remaining, stacks = Serenity.CheckForDebuff(spell, target..i, owner)
						if icon then return (icon), (duration), (remaining), (stacks) end
					end
					
					icon, duration, remaining, stacks = Serenity.CheckForBuff(spell, target..i, owner)
					if icon then return (icon), (duration), (remaining), (stacks) end
				end
			end
		end
		return (nil), (0), (0), (0)
		
	elseif (target == "party") or (target == "partypet") then
	
		if owner ~= "PLAYERS" then
			icon, duration, remaining, stacks = Serenity.CheckForDebuff(spell, target == "party" and "player" or "pet", owner)
			if icon then return (icon), (duration), (remaining), (stacks) end
		end
	
		icon, duration, remaining, stacks = Serenity.CheckForBuff(spell, target == "party" and "player" or "pet", owner)
		if icon then return (icon), (duration), (remaining), (stacks) end
		
		for i=1,GetNumPartyMembers() do
			if owner ~= "PLAYERS" then
				icon, duration, remaining, stacks = Serenity.CheckForDebuff(spell, target..i, owner)
				if icon then return (icon), (duration), (remaining), (stacks) end
			end
			
			icon, duration, remaining, stacks = Serenity.CheckForBuff(spell, target..i, owner)
			if icon then return (icon), (duration), (remaining), (stacks) end
		end
		return (nil), (0), (0), (0)
		
	elseif (target == "arena") then
	
		inInstance, instanceType = IsInInstance()
		if inInstance and instanceType == "arena" then
			for i=1,5 do
				if UnitExists(target..i) then
					icon, duration, remaining, stacks = Serenity.CheckForDebuff(spell, target..i, owner)
					if icon then return (icon), (duration), (remaining), (stacks) end
					
					icon, duration, remaining, stacks = Serenity.CheckForBuff(spell, target..i, owner)
					if icon then return (icon), (duration), (remaining), (stacks) end
				end
			end
		end
		return (nil), (0), (0), (0)
		
	elseif (target == "boss") then
		for i=1,4 do
			if UnitExists(target..i) then
				icon, duration, remaining, stacks = Serenity.CheckForDebuff(spell, target..i, owner)
				if icon then return (icon), (duration), (remaining), (stacks) end
			
				icon, duration, remaining, stacks = Serenity.CheckForBuff(spell, target..i, owner)
				if icon then return (icon), (duration), (remaining), (stacks) end
			end
		end
		return (nil), (0), (0), (0)
	end
	
	-- Lastly we check the exact target for a debuff first then buff
	icon, duration, remaining, stacks = Serenity.CheckForDebuff(spell, target, owner)
	if icon then return (icon), (duration), (remaining), (stacks) end
	
	icon, duration, remaining, stacks = Serenity.CheckForBuff(spell, target, owner)
	if icon then return (icon), (duration), (remaining), (stacks) end
	
	-- Nothing found for the spell given
	return (nil), (0), (0), (0)
end
