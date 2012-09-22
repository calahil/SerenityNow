--[[

	Interrupts module
	
]]

if not Serenity then return end

function Serenity.SetupInterruptsModule()

	-- Deconstruction
	if Serenity.F.Interrupts then
		Serenity.F.Interrupts:Hide()
		Serenity.F.Interrupts:UnregisterAllEvents() 
		Serenity.F.Interrupts:SetParent(nil)
		Serenity.F.Interrupts = nil		
	end

	-- Construction	
	if not Serenity.db.profile.interrupts.enable then return end
	
	if Serenity.db.profile.interrupts.enableannounce then
		Serenity.F.Interrupts = CreateFrame("Frame", "SERENITY_INTERRUPTS", UIParent) -- Handler frame, nothing more.			
		Serenity.F.Interrupts:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
		Serenity.F.Interrupts:SetScript("OnEvent", function(self, event, ...)
			-- 4.1 local timeStamp, subEvent, hideCaster, sourceGUID, sourceName, sourceFlags, destGUID, destName, destFlags, spellId, spellName, spellSchool, extraSpellID, extraSpellName, extraSchool, auraType = ...
			-- 4.2 local timeStamp, subEvent, hideCaster, sourceGUID, sourceName, sourceFlags, sourceFlags2, destGUID, destName, destFlags, destFlags2, spellId, spellName, spellSchool, extraSpellID, extraSpellName, extraSchool, auraType = ...
				
			local subEvent, sourceGUID, destName, spellId, spellName, extraSpellID, extraSpellName			
			if (Serenity.V.wowBuild >= 40200) then -- 4.2 patch ready
				_, subEvent, _, sourceGUID, _, _, _, _, destName, _, _, spellId, spellName, _, extraSpellID, extraSpellName = ...
			else -- 4.1
				_, subEvent, _, sourceGUID, _, _, _, destName, _, spellId, spellName, _, extraSpellID, extraSpellName = ...
			end
			
			if (subEvent == "SPELL_INTERRUPT") and (sourceGUID == UnitGUID("player")) then			
				if (Serenity.GetChatChan(Serenity.db.profile.interrupts[strlower(Serenity.GetGroupType()).."chan"]) ~= "NONE") then				
					SendChatMessage(Serenity.L["Interrupted"] .. " " .. destName .. Serenity.L["'s"] .. " |cff71d5ff|Hspell:" .. extraSpellID .. "|h[" .. extraSpellName .. "]|h|r!",
						Serenity.GetChatChan(Serenity.db.profile.interrupts[strlower(Serenity.GetGroupType()).."chan"]), nil, GetUnitName("player"))
				end
			elseif (subEvent == "SPELL_AURA_APPLIED") and (sourceGUID == UnitGUID("player")) and (spellId == 19503) then -- Scatter shot
				if (Serenity.GetChatChan(Serenity.db.profile.interrupts[strlower(Serenity.GetGroupType()).."chan"]) ~= "NONE") then
					SendChatMessage("|cff71d5ff|Hspell:" .. spellId .. "|h[" .. spellName .. "]|h|r " .. Serenity.L["on"] .. " " .. destName .. "!",
						Serenity.GetChatChan(Serenity.db.profile.interrupts[strlower(Serenity.GetGroupType()).."chan"]), nil, GetUnitName("player"))
				end
			end
		end)
	end
end
