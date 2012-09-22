--[[

	Crowd Control module
	
]]

if not Serenity then return end

local function stopCCTimer(spellID, targetGUID)
	local i
	for i=1,4 do
		if (Serenity.F.CrowdControl.ccFrame[i].active == true) and (Serenity.F.CrowdControl.ccFrame[i].spellID == spellID) and (Serenity.F.CrowdControl.ccFrame[i].guid == targetGUID) then

			Serenity.F.CrowdControl.ccFrame[i]:SetAlpha(0)
			Serenity.F.CrowdControl.ccFrame[i].guid = 0
			Serenity.F.CrowdControl.ccFrame[i].spellID = 0
			Serenity.F.CrowdControl.ccFrame[i].active = false
			Serenity.F.CrowdControl.ccFrame[i].killtime = 0

			if Serenity.F.CrowdControl.ccFrame[i].timer then
				Serenity.F.CrowdControl.ccFrame[i].timer.enabled = nil
				Serenity.F.CrowdControl.ccFrame[i].timer:Hide()
			end
			break -- Found the right one, stop the loop
		end
	end
end

local function addCCTimer(spellID, targetGUID, expireTime)
	local i
	for i=2,4 do -- Position Wyvern first, as it's only a 30s duration.
		if (Serenity.F.CrowdControl.ccFrame[i].active == false) or (spellID == 19386) then -- Wyvern Sting

			if (spellID == 19386) then i = 1 end

			Serenity.F.CrowdControl.ccFrame[i].Icon:ClearAllPoints()
			Serenity.F.CrowdControl.ccFrame[i].Icon:SetAllPoints(Serenity.F.CrowdControl.ccFrame[i])
			Serenity.F.CrowdControl.ccFrame[i].Icon:SetTexture(select(3, GetSpellInfo(spellID)))
			if Serenity.db.profile.frames.crowdcontrol.enabletexcoords then
				Serenity.F.CrowdControl.ccFrame[i].Icon:SetTexCoord(unpack(Serenity.db.profile.frames.crowdcontrol.texcoords))
			end

			if Serenity.V["MoversLocked"] then
				Serenity.F.CrowdControl.ccFrame[i]:SetAlpha(1) 
			end

			Serenity.F.CrowdControl.ccFrame[i].killtime = GetTime() + expireTime + .2
			Serenity.F.CrowdControl.ccFrame[i].guid = targetGUID -- Need to know the target id associated with this frame.
			Serenity.F.CrowdControl.ccFrame[i].spellID = spellID
			Serenity.F.CrowdControl.ccFrame[i].active = true

			local timer = Serenity.F.CrowdControl.ccFrame[i].timer or Serenity.Timer_Create(Serenity.F.CrowdControl.ccFrame[i])
			timer.start = GetTime()
			timer.duration = expireTime
			timer.enabled = true
			timer.nextUpdate = 0
			timer:Show()
			break
		end
	end
end

local function refreshCCTimer(spellID, targetGUID, expireTime)
	local i
	for i=1,4 do
		if (Serenity.F.CrowdControl.ccFrame[i].active == true) and (Serenity.F.CrowdControl.ccFrame[i].spellID == spellID) and (Serenity.F.CrowdControl.ccFrame[i].guid == targetGUID) then

			Serenity.F.CrowdControl.ccFrame[i].killtime = GetTime() + expireTime + .2
			local timer = Serenity.F.CrowdControl.ccFrame[i].timer or Serenity.Timer_Create(Serenity.F.CrowdControl.ccFrame[i])
			timer.start = GetTime()
			timer.duration = expireTime
			timer.enabled = true
			timer.nextUpdate = 0
			timer:Show()
			break
		end
	end
end

function Serenity.SetupCrowdControlModule(lockName)

	-- Deconstruction
	if Serenity.F.CrowdControl then
		Serenity.F.CrowdControl:Hide()
		Serenity.F.CrowdControl.ccFrame[1]:UnregisterAllEvents()
		Serenity.DeregisterMovableFrame("MOVER_CROWDCONTROL")
		Serenity.F.CrowdControl:SetParent(nil)
		Serenity.F.CrowdControl = nil
	end

	if not Serenity.db.profile.crowdcontrol.enabled then return end

	-- Construction
	local CROWDCONTROL_UPDATEINTERVAL = 0.15

	-- Create the Frame
	Serenity.F.CrowdControl = Serenity.MakeFrame("Frame", "SERENITY_CROWDCONTROL", Serenity.db.profile.crowdcontrol.anchor[2] or UIParent)
	Serenity.F.CrowdControl:SetSize(50, 50) -- Temporary, will set it after we get offsets
	Serenity.F.CrowdControl:SetPoint(Serenity.GetActiveAnchor(Serenity.db.profile.crowdcontrol.anchor))

	Serenity.F.CrowdControl.ccFrame = {}
	
	local i
	for i=1,4 do -- Allocating 4 frames, more than enough, low overhead

		Serenity.F.CrowdControl.ccFrame[i] = Serenity.MakeFrame("Frame", nil, Serenity.F.CrowdControl)
		Serenity.F.CrowdControl.ccFrame[i]:SetSize(Serenity.db.profile.frames.crowdcontrol.iconsize, Serenity.db.profile.frames.crowdcontrol.iconsize)
		Serenity.F.CrowdControl.ccFrame[i]:SetPoint("CENTER", Serenity.F.CrowdControl, "CENTER") -- Temporary
		
		Serenity.F.CrowdControl.ccFrame[i].background = Serenity.MakeBackground(Serenity.F.CrowdControl.ccFrame[i], Serenity.db.profile.frames.crowdcontrol)
		
		Serenity.F.CrowdControl.ccFrame[i]:ClearAllPoints() -- Now that we made the backdrop/border we have offsets to use.

		local x = ((i-1) * (Serenity.GetFrameOffset(Serenity.F.CrowdControl.ccFrame[i], "LEFT", 1) + 
			Serenity.GetFrameOffset(Serenity.F.CrowdControl.ccFrame[i], "RIGHT", 1) + Serenity.db.profile.frames.crowdcontrol.iconsize + 2))
			
		if Serenity.db.profile.crowdcontrol.anchor[4] >= 0 then -- Expand to Right
			Serenity.F.CrowdControl.ccFrame[i]:SetPoint("TOPLEFT", Serenity.F.CrowdControl, "TOPLEFT", x, 0)
		else -- Expand to Left
			Serenity.F.CrowdControl.ccFrame[i]:SetPoint("TOPRIGHT", Serenity.F.CrowdControl, "TOPRIGHT", -x, 0)				
		end

		Serenity.F.CrowdControl.ccFrame[i].Icon = Serenity.F.CrowdControl.ccFrame[i]:CreateTexture(nil, "BACKGROUND")
		Serenity.F.CrowdControl.ccFrame[i].Icon:SetTexture("Interface\\Buttons\\UI-GroupLoot-Pass-Up") -- Temporary Texture
		
		if Serenity.db.profile.frames.crowdcontrol.enabletexcoords then
			Serenity.F.CrowdControl.ccFrame[i].Icon:SetTexCoord(unpack(Serenity.db.profile.frames.crowdcontrol.texcoords))
		end

		Serenity.F.CrowdControl.ccFrame[i]:SetAlpha(0)
		Serenity.F.CrowdControl.ccFrame[i]:Show()		
		Serenity.F.CrowdControl.ccFrame[i].guid = 0
		Serenity.F.CrowdControl.ccFrame[i].spellID = 0
		Serenity.F.CrowdControl.ccFrame[i].active = false
	end
	
	-- Properly set the host frame's size for the movers functionality
	Serenity.F.CrowdControl:SetSize(
		((Serenity.db.profile.frames.crowdcontrol.iconsize +
			(Serenity.GetFrameOffset(Serenity.F.CrowdControl.ccFrame[1], "LEFT", 1) + Serenity.GetFrameOffset(Serenity.F.CrowdControl.ccFrame[1], "RIGHT", 1) + 2)) * 3) - 
				Serenity.GetFrameOffset(Serenity.F.CrowdControl.ccFrame[1], "LEFT", 1) - Serenity.GetFrameOffset(Serenity.F.CrowdControl.ccFrame[1], "RIGHT", 1) - 2,
					Serenity.db.profile.frames.crowdcontrol.iconsize)
					
	-- Register the mover frame
	Serenity.RegisterMovableFrame(
		"MOVER_CROWDCONTROL",
		Serenity.F.CrowdControl,
		Serenity.F.CrowdControl,
		Serenity.L["Crowd Control"],
		Serenity.db.profile.crowdcontrol,
		Serenity.SetupCrowdControlModule,
		Serenity.V["defaults"].profile["crowdcontrol"],
		Serenity.db.profile.frames.crowdcontrol
	)
	
	-- First frame calls the update routine.
	Serenity.F.CrowdControl.ccFrame[1].updateTimer = 0
	Serenity.F.CrowdControl.ccFrame[1]:SetScript("OnUpdate", function(self, elapsed)

		self.updateTimer = self.updateTimer + elapsed
		if self.updateTimer > CROWDCONTROL_UPDATEINTERVAL then
			local i
			local j = 1
			for i=1,4 do
				if Serenity.F.CrowdControl.ccFrame[i].active == true then
					if (Serenity.F.CrowdControl.ccFrame[i].killtime < GetTime()) then
						stopCCTimer(Serenity.F.CrowdControl.ccFrame[i].spellID, Serenity.F.CrowdControl.ccFrame[i].guid)
					else
						local x = ((j-1) * (Serenity.GetFrameOffset(Serenity.F.CrowdControl.ccFrame[i], "LEFT", 1) + 
							Serenity.GetFrameOffset(Serenity.F.CrowdControl.ccFrame[i], "RIGHT", 1) + Serenity.db.profile.frames.crowdcontrol.iconsize + 2))
					
						if Serenity.db.profile.crowdcontrol.anchor[4] >= 0 then -- Expand to Right
							Serenity.F.CrowdControl.ccFrame[i]:SetPoint("TOPLEFT", Serenity.F.CrowdControl, "TOPLEFT", x, 0)
						else -- Expand to Left
							Serenity.F.CrowdControl.ccFrame[i]:SetPoint("TOPRIGHT", Serenity.F.CrowdControl, "TOPRIGHT", -x, 0)				
						end
						j = j + 1
					end
				end
			end
		end
	end)
	
	-- Event handler
	Serenity.F.CrowdControl.ccFrame[1]:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
	Serenity.F.CrowdControl.ccFrame[1]:SetScript("OnEvent", function(self, event, ...)
		-- 4.1 local timeStamp, subEvent, hideCaster, sourceGUID, sourceName, sourceFlags, destGUID, destName, destFlags, spellId, spellName, spellSchool, extraSpellID, extraSpellName, extraSchool, auraType = ...
		-- 4.2 local timeStamp, subEvent, hideCaster, sourceGUID, sourceName, sourceFlags, sourceFlags2, destGUID, destName, destFlags, destFlags2, spellId, spellName, spellSchool, extraSpellID, extraSpellName, extraSchool, auraType = ...
		local subEvent, sourceGUID, destGUID, destFlags, spellId
		if (Serenity.V.wowBuild >= 40200) then -- 4.2 patch ready
			_, subEvent, _, sourceGUID, _, _, _, destGUID, _, destFlags, _, spellId = ...
		else -- 4.1
			_, subEvent, _, sourceGUID, _, _, destGUID, _, destFlags, spellId = ...
		end		
		if (subEvent == "SPELL_AURA_APPLIED") and (sourceGUID == UnitGUID("player")) then
			if spellId == 3355 then -- Freezing trap Aura
				local i = (bit.band(destFlags, COMBATLOG_OBJECT_CONTROL_PLAYER) > 0) and 8 or (60 + (6 * select(5, GetTalentInfo(3, 5))))
				addCCTimer(1499, destGUID, i) -- account for trap mastery
			elseif spellId == 19386 then -- wyvern
				addCCTimer(19386, destGUID, 30) -- wyvern
			end
		elseif (subEvent == "SPELL_AURA_REFRESH") and (sourceGUID == UnitGUID("player")) then
			if spellId == 3355 then -- Freezing Trap Aura
				local i = (bit.band(destFlags, COMBATLOG_OBJECT_CONTROL_PLAYER) > 0) and 8 or (60 + (6 * select(5, GetTalentInfo(3, 5))))
				refreshCCTimer(1499, destGUID, i) -- account for trap mastery
			end
		elseif (subEvent == "SPELL_AURA_REMOVED") and (sourceGUID == UnitGUID("player")) then
			if spellId == 3355 then -- Freezing Trap Aura
				stopCCTimer(1499, destGUID)
			elseif spellId == 19386 then -- wyvern
				stopCCTimer(19386, destGUID) -- wyvern
			end
		end	
	end)
end
