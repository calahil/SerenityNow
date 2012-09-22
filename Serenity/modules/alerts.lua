--[[

	Alerts module
	
]]

if not Serenity then return end

Serenity.V.totalAlertIcons = 0

-- Compares GUID values of the selected target or target group for a match
local function checkGUIDMatch(target, destGUID)

	local i, maxPlayers, inInstance, instanceType
	if (target == "raid") or (target == "raidpet") then	
		if GetNumRaidMembers() ~= 0 then
			if IsInInstance() then 
				maxPlayers = select(5, GetInstanceInfo()) 
			else
				maxPlayers = 40
			end

			for i=1,maxPlayers do
				if UnitExists(target..i) and (UnitGUID(target..i) == destGUID) then
					return(target..i)
				end
			end
		end
		return false

	elseif (target == "party") or (target == "partypet") then
		
		if (UnitGUID(target == "party" and "player" or "pet") == destGUID) then
			return(target == "party" and "player" or "pet")
		end
		for i=1,GetNumPartyMembers() do
			if UnitExists(target..i) and (UnitGUID(target..i) == destGUID) then
				return(target..i)
			end
		end
		return false
		
	elseif (target == "arena") then
	
		inInstance, instanceType = IsInInstance()
		if inInstance and instanceType == "arena" then
			for i=1,5 do
				if UnitExists(target..i) then
					return(target..i)
				end
			end
		end
		return false
		
	elseif (target == "boss") then
		for i=1,4 do
			if UnitExists(target..i) and (UnitGUID(target..i) == destGUID) then
				return(target..i)
			end
		end
		return false		
	end

	-- Last check is the exact target name
	if UnitExists(target) and (UnitGUID(target) == destGUID) then
		return(target)
	end
	return false -- No match
end

local function repositionFrames()
	local i
	local index = 1
	for i = 1, Serenity.V.totalAlertIcons do
		if Serenity.F.Alerts[i].active then
		
			Serenity.F.Alerts[i]:ClearAllPoints()

			-- Flip expanding left to right or right to left depending on anchor point X
			local xPos = ((Serenity.db.profile.frames.alerts.icons.iconsize +
						(Serenity.GetFrameOffset(Serenity.F.Alerts[1], "LEFT", 1) + Serenity.GetFrameOffset(Serenity.F.Alerts[1], "RIGHT", 1) + 2))
							* mod(index - 1, 5))
			
			local yPos = (Serenity.db.profile.frames.alerts.icons.iconsize +  -- Vertical Offset
						(Serenity.GetFrameOffset(Serenity.F.Alerts[1], "TOP", 1) + Serenity.GetFrameOffset(Serenity.F.Alerts[1], "BOTTOM", 1) + 2))
							* floor((index - 1) / 5)

			if Serenity.db.profile.alerticons.anchor[4] >= 0 then
				Serenity.F.Alerts[i]:SetPoint("TOPLEFT", Serenity.F.AlertIconsHost, "TOPLEFT", xPos, -yPos)
			else
				Serenity.F.Alerts[i]:SetPoint("TOPRIGHT", Serenity.F.AlertIconsHost, "TOPRIGHT", -xPos, -yPos)
			end
			index = index + 1
		end	
	end
end

local function stopDebuffAlert(self, spellID)

	if (self.active == true) and (self.spellID == spellID) then
		if self.hasSparkles then
			AutoCastShine_AutoCastStop(self.shine)
			self.shine:Hide()
		end
		
		self.Icon:Hide()

		self.stacks:Hide()
		self:SetAlpha(0)
		self.spellID = 0
		self.active = false
		self.killtime = 0
		
		if self.noTimeCheckFunc then
			self.noTimeCheckFunc = nil
		end
		
		if self.hasTip then
			self:EnableMouse(nil)
		end
		if self.timer then
			self.timer.enabled = nil
			self.timer:Hide()
		end
		
		repositionFrames()
	end
end

local function addDebuffAlert(self, spellID, expireTime, stacks, noTimeCheckFunc)

	if (self.active == false) then
	
		if self.soundFile then
			PlaySoundFile(Serenity.GetLibSharedMedia3():Fetch("sound", self.soundFile), Serenity.db.profile.masteraudio and "Master" or nil)
		end
							
		self.Icon:SetTexture(select(3, GetSpellInfo(spellID)))
		self.Icon:Show()

		if stacks and (stacks > 1) then 
			self.stacks:SetText(stacks)
			self.stacks:Show()
		else
			self.stacks:Hide()
		end

		if Serenity.V["MoversLocked"] then
			self:SetAlpha(1)
		end

		if noTimeCheckFunc then
			self.noTimeCheckFunc = noTimeCheckFunc
		end
		
		self.killtime = GetTime() + expireTime + .2
		self.spellID = spellID
		self.active = true
		
		if self.hasTip then
			self:EnableMouse(true)
		end
		
		if self.hasSparkles then
			self.shine:Show()
			AutoCastShine_AutoCastStart(self.shine)
		end

		local timer = self.timer or Serenity.Timer_Create(self)
		timer.start = GetTime()
		timer.duration = expireTime
		timer.enabled = true
		timer.nextUpdate = 0
		timer:Show()
		
		repositionFrames()
	end
end

local function refreshDebuffAlert(self, spellID, expireTime, stacks, whatEvent)

	if (self.active == true) and (self.spellID == spellID) then

		self.killtime = GetTime() + expireTime + .2

		self.Icon:Show()

		if stacks and (stacks > 1) then
			self.stacks:SetText(stacks)
			self.stacks:Show()
		else
			self.stacks:Hide()
		end

		local timer = self.timer or Serenity.Timer_Create(self)
		timer.start = GetTime()
		timer.duration = expireTime
		timer.enabled = true
		timer.nextUpdate = 0
		timer:Show()
		
		repositionFrames()
	end
end

function Serenity.SetupAlertsModule()

	if not Serenity.F.Alerts then Serenity.F.Alerts = {} end

	-- Destruction
	local i = 1
	while Serenity.F.Alerts[i] ~= nil do
		Serenity.F.Alerts[i]:Hide()
		Serenity.F.Alerts[i]:UnregisterAllEvents()
		Serenity.F.Alerts[i]:SetParent(nil)
		Serenity.F.Alerts[i] = nil
		i = i + 1
	end
	
	-- Clean up the mover frame	
	if Serenity.F.AlertIconsHost then
		Serenity.F.AlertIconsHost:Hide()
		Serenity.DeregisterMovableFrame("MOVER_ALERT_ICONS")
		Serenity.F.AlertIconsHost:SetParent(nil)
		Serenity.F.AlertIconsHost = nil
	end
	
	Serenity.V.totalAlertIcons = 0

	-- Construction
	local ALERT_UPDATEINTERVAL = 0.15
	local key,val
	local index = 1
	for key,val in pairs(Serenity.db.profile.alerts) do

		if Serenity.db.profile.alerts[key] and Serenity.db.profile.alerts[key].enabled then
	
			-- Create the host frame
			if (index == 1) then
				Serenity.F.AlertIconsHost = Serenity.MakeFrame("Frame", "SERENITY_ALERT_ICON_HOST", Serenity.db.profile.alerticons.anchor[2] or UIParent)
				Serenity.F.AlertIconsHost:SetSize(Serenity.db.profile.frames.alerts.icons.iconsize, Serenity.db.profile.frames.alerts.icons.iconsize) -- Temporary size
				Serenity.F.AlertIconsHost:SetPoint(Serenity.GetActiveAnchor(Serenity.db.profile.alerticons.anchor))
				Serenity.F.AlertIconsHost:SetAlpha(1)
				Serenity.F.AlertIconsHost:Show()
			end
	
			-- Create this Alert's Frame
			Serenity.F.Alerts[index] = Serenity.MakeFrame("Frame", "SERENITY_ALERT_ICON_"..key, Serenity.F.AlertIconsHost)
			Serenity.F.Alerts[index]:SetSize(Serenity.db.profile.frames.alerts.icons.iconsize, Serenity.db.profile.frames.alerts.icons.iconsize)
			Serenity.F.Alerts[index]:SetPoint("CENTER", Serenity.F.AlertIconsHost, "CENTER")
			Serenity.F.Alerts[index]:SetAlpha(0)
			
			Serenity.F.Alerts[index].Icon = Serenity.F.Alerts[index]:CreateTexture(nil, "BACKGROUND")
			Serenity.F.Alerts[index].Icon:SetTexture("Interface\\ICONS\\INV_Misc_QuestionMark") -- Just a place-holder
			if Serenity.db.profile.frames.alerts.icons.enabletexcoords then
				Serenity.F.Alerts[index].Icon:SetTexCoord(unpack(Serenity.db.profile.frames.alerts.icons.texcoords))
			end
			Serenity.F.Alerts[index].Icon:SetAllPoints(Serenity.F.Alerts[index])
			
			-- Create the Background and border if the user wants one
			Serenity.F.Alerts[index].background = Serenity.MakeBackground(Serenity.F.Alerts[index], Serenity.db.profile.frames.alerts.icons)

			-- Now we can properly set the size of the host frame for the alert icons because we now have offsets.
			if (index == 1) then
				Serenity.F.AlertIconsHost:SetSize(		
					((Serenity.db.profile.frames.alerts.icons.iconsize + -- WIDTH
						(Serenity.GetFrameOffset(Serenity.F.Alerts[1], "LEFT", 1) + Serenity.GetFrameOffset(Serenity.F.Alerts[1], "RIGHT", 1) + 2)) * 5) 
						- Serenity.GetFrameOffset(Serenity.F.Alerts[1], "LEFT", 1) - Serenity.GetFrameOffset(Serenity.F.Alerts[1], "RIGHT", 1) - 2,
						
					((Serenity.db.profile.frames.alerts.icons.iconsize + -- HEIGHT
						(Serenity.GetFrameOffset(Serenity.F.Alerts[1], "TOP", 1) + Serenity.GetFrameOffset(Serenity.F.Alerts[1], "BOTTOM", 1) + 2)) * 4) 
						- Serenity.GetFrameOffset(Serenity.F.Alerts[1], "LEFT", 1) - Serenity.GetFrameOffset(Serenity.F.Alerts[1], "RIGHT", 1) - 2)

				Serenity.RegisterMovableFrame(
					"MOVER_ALERT_ICONS",
					Serenity.F.AlertIconsHost,
					Serenity.F.AlertIconsHost,
					Serenity.L["Alert Icons"],
					Serenity.db.profile.alerticons,
					index == 1 and Serenity.SetupAlertsModule or nil,
					Serenity.V["alerticons_defaults"],
					nil) -- No background / Border ever on the mover frame
			end
			
			-- Setup Stacks
			Serenity.F.Alerts[index].stacks = Serenity.F.Alerts[index]:CreateFontString(nil, "OVERLAY")			
			Serenity.F.Alerts[index].stacks:SetJustifyH("RIGHT")
			Serenity.F.Alerts[index].stacks:SetJustifyV("BOTTOM")
			Serenity.F.Alerts[index].stacks:SetPoint("BOTTOMRIGHT", Serenity.F.Alerts[index], "BOTTOMRIGHT", -1, -3)
			Serenity.F.Alerts[index].stacks:SetFont(Serenity.GetActiveFont(Serenity.db.profile.frames.alerts.icons.stackfont))
			Serenity.F.Alerts[index].stacks:SetTextColor(unpack(Serenity.db.profile.frames.alerts.icons.stackfontcolor), 1)
			Serenity.F.Alerts[index].stacks:SetText("")
			Serenity.F.Alerts[index].stacks:SetAlpha(1)
			
			-- Setup the Sparkles if turned on for this Alert frame
			if Serenity.db.profile.alerts[key].sparkles then
				Serenity.F.Alerts[index].shine = SpellBook_GetAutoCastShine()
				Serenity.F.Alerts[index].shine:Hide()
				Serenity.F.Alerts[index].shine:SetParent(Serenity.F.Alerts[index])
				Serenity.F.Alerts[index].shine:SetSize(Serenity.db.profile.frames.alerts.icons.iconsize + 3, Serenity.db.profile.frames.alerts.icons.iconsize + 3)
				Serenity.F.Alerts[index].shine:SetPoint("CENTER", Serenity.F.Alerts[index], "CENTER")
			end
			
			-- Setup the script for handling the Alert
			Serenity.F.Alerts[index].updateTimer = 0
			Serenity.F.Alerts[index].active = false
			Serenity.F.Alerts[index].spellID = 0
			Serenity.F.Alerts[index].checkID = tonumber(Serenity.db.profile.alerts[key].aura) and Serenity.db.profile.alerts[key].aura or 0
			Serenity.F.Alerts[index].checkName = tonumber(Serenity.db.profile.alerts[key].aura) and "" or strupper(Serenity.db.profile.alerts[key].aura)
			Serenity.F.Alerts[index].hasTip = Serenity.db.profile.alerts[key].tooltips
			Serenity.F.Alerts[index].hasSparkles = Serenity.db.profile.alerts[key].sparkles
			Serenity.F.Alerts[index].soundFile = Serenity.db.profile.alerts[key].enablesound and Serenity.db.profile.alerts[key].sound or nil
			Serenity.F.Alerts[index].alertTrigger = Serenity.db.profile.alerts[key].alerttype
			Serenity.F.Alerts[index].target = Serenity.db.profile.alerts[key].target

			-- Setup Tooltips if turned on
			if Serenity.db.profile.alerts[key].tooltips then			
				Serenity.F.Alerts[index]:SetScript("OnEnter", function(self)
					if self.spellID == 0 then return end
					if (self.alertTrigger == "BUFF") or (self.alertTrigger == "DEBUFF") then
						local index
						for index=1,40 do
							if (select(11, UnitAura("player", index, "HARMFUL")) == self.spellID) then						
								GameTooltip:SetOwner(self)
								GameTooltip:SetUnitAura("player", index, "HARMFUL")
								GameTooltip:Show()
								return							
							elseif (select(11, UnitAura("player", index, "HELPFUL")) == self.spellID) then						
								GameTooltip:SetOwner(self)
								GameTooltip:SetUnitAura("player", index, "HELPFUL")
								GameTooltip:Show()
								return
							end
						end
					elseif (self.alertTrigger == "CAST") then
--						GameTooltip:SetOwner(self)
--						GameTooltip:SetSpell(self.spellID) 
--						GameTooltip:Show()
						return
					end
					self:EnableMouse(nil)
				end)
				Serenity.F.Alerts[index]:SetScript("OnLeave", function(self)
					if self.spellID == 0 then return end
					GameTooltip:Hide()
				end)
				Serenity.F.Alerts[index]:EnableMouse(nil)			
			end

			-- OnUpdate handler		
			Serenity.F.Alerts[index]:SetScript("OnUpdate", function(self, elapsed)			
				self.updateTimer = self.updateTimer + elapsed				
				if self.updateTimer < ALERT_UPDATEINTERVAL then return else self.updateTimer = 0 end			
				if self.active == true then
					if (self.killtime < GetTime()) then
						if self.noTimeCheckFunc and (not self.noTimeCheckFunc()) then						
							stopDebuffAlert(self, self.spellID)
						end
					else
						if Serenity.V["MoversLocked"] then
							self:SetAlpha(1)
						end
					end
				end
			end)
			
			-- Setup the event handler
			Serenity.F.Alerts[index]:SetScript("OnEvent", function(self, event, ...)
				-- 4.1 local timeStamp, subEvent, hideCaster, sourceGUID, sourceName, sourceFlags, destGUID, destName, destFlags, spellId, spellName, spellSchool, extraSpellID, extraSpellName, extraSchool, auraType = ...
				-- 4.2 local timeStamp, subEvent, hideCaster, sourceGUID, sourceName, sourceFlags, sourceFlags2, destGUID, destName, destFlags, destFlags2, spellId, spellName, spellSchool, extraSpellID, extraSpellName, extraSchool, auraType = ...
				
				if (self.alertTrigger == "BUFF") or (self.alertTrigger == "DEBUFF") then
				
					local timeStamp, subEvent, sourceName, destGUID, spellId, spellName
					if (Serenity.V.wowBuild >= 40200) then -- 4.2 patch ready
						timeStamp, subEvent, _, _, sourceName, _, _, destGUID, _, _, _, spellId, spellName = ...
					else -- 4.1
						timeStamp, subEvent, _, _, sourceName, _, destGUID, _, _, spellId, spellName = ...
					end
					local retTarget = checkGUIDMatch(self.target, destGUID)

					if (subEvent == "SPELL_AURA_APPLIED") and (retTarget) then
						if (spellId == self.checkID) or (strupper(spellName) == self.checkName) then
							if select(11, UnitAura(retTarget, GetSpellInfo(spellId), nil, "HARMFUL")) == spellId then
								addDebuffAlert(self, spellId, select(6, UnitAura(retTarget, GetSpellInfo(spellId), nil, "HARMFUL")),
									select(4, UnitAura(retTarget, GetSpellInfo(spellId), nil, "HARMFUL")), 
									(select(6, UnitAura(retTarget, GetSpellInfo(spellId), nil, "HARMFUL")) > .1) and nil or (function(self) return(select(6, UnitAura(retTarget, GetSpellInfo(spellId), nil, "HARMFUL"))) end)
								)
							else
								addDebuffAlert(self, spellId, select(6, UnitAura(retTarget, GetSpellInfo(spellId), nil, "HELPFUL")),
									select(4, UnitAura(retTarget, GetSpellInfo(spellId), nil, "HELPFUL")),
									(select(6, UnitAura(retTarget, GetSpellInfo(spellId), nil, "HELPFUL")) > .1) and nil or (function(self) return(select(6, UnitAura(retTarget, GetSpellInfo(spellId), nil, "HELPFUL"))) end)
								)
							end
						end

					elseif ((subEvent == "SPELL_AURA_REFRESH") or (subEvent == "SPELL_AURA_APPLIED_DOSE")) and (retTarget) then
						if (spellId == self.checkID) or (strupper(spellName) == self.checkName) then
							if select(11, UnitAura(retTarget, GetSpellInfo(spellId), nil, "HARMFUL")) == spellId then						
								refreshDebuffAlert(self, spellId, select(6, UnitAura(retTarget, GetSpellInfo(spellId), nil, "HARMFUL")),
									select(4, UnitAura(retTarget, GetSpellInfo(spellId), nil, "HARMFUL")))
							else
								refreshDebuffAlert(self, spellId, select(6, UnitAura(retTarget, GetSpellInfo(spellId), nil, "HELPFUL")),
									select(4, UnitAura(retTarget, GetSpellInfo(spellId), nil, "HELPFUL")))
							end
						end

					elseif (subEvent == "SPELL_AURA_REMOVED") and (retTarget) then
						if (spellId == self.checkID) or (strupper(spellName) == self.checkName) then
							stopDebuffAlert(self, spellId)
						end
					end
					
				elseif (self.alertTrigger == "CAST") then
				
					local unitID, spell, _, _, spellID = ...
					local retTarget = checkGUIDMatch(self.target, UnitGUID(unitID))
					
					if (event == "UNIT_SPELLCAST_START") and (retTarget) then
						if (spellID == self.checkID) or (strupper(spell) == self.checkName) then
							addDebuffAlert(self, spellID, select(7, GetSpellInfo(spellID)) / 1000 + .2, 0)
						end
					elseif (event == "UNIT_SPELLCAST_CHANNEL_START") and (retTarget) then
						if (spellID == self.checkID) or (strupper(spell) == self.checkName) then
							addDebuffAlert(self, spellID, select(7, GetSpellInfo(spellID)) / 1000 + .2, 0)
						end
					elseif (event == "UNIT_SPELLCAST_STOP") and (retTarget) then
						if (spellID == self.checkID) or (strupper(spell) == self.checkName) then
							stopDebuffAlert(self, spellID)
						end
					elseif (event == "UNIT_SPELLCAST_INTERRUPTED") and (retTarget) then
						if (spellID == self.checkID) or (strupper(spell) == self.checkName) then
							stopDebuffAlert(self, spellID)
						end
					elseif (event == "UNIT_SPELLCAST_FAILED") and (retTarget) then
						if (spellID == self.checkID) or (strupper(spell) == self.checkName) then
							stopDebuffAlert(self, spellID)
						end
					elseif (event == "UNIT_SPELLCAST_CHANNEL_STOP") and (retTarget) then
						if (spellID == self.checkID) or (strupper(spell) == self.checkName) then
							stopDebuffAlert(self, spellID)
						end
					end
					--[[elseif (event == "UNIT_SPELLCAST_SUCCEEDED") and (retTarget) then
						if (spellID == self.checkID) or (strupper(spell) == self.checkName) then
							stopDebuffAlert(self, spellID)
						end
					end]]
				end
			end)
			
			if (Serenity.F.Alerts[index].alertTrigger == "BUFF") or (Serenity.F.Alerts[index].alertTrigger == "DEBUFF") then
				Serenity.F.Alerts[index]:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
			elseif (Serenity.F.Alerts[index].alertTrigger == "CAST") then
				Serenity.F.Alerts[index]:RegisterEvent("UNIT_SPELLCAST_CHANNEL_START")
				Serenity.F.Alerts[index]:RegisterEvent("UNIT_SPELLCAST_START")
				--Serenity.F.Alerts[index]:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")
				Serenity.F.Alerts[index]:RegisterEvent("UNIT_SPELLCAST_STOP")
				Serenity.F.Alerts[index]:RegisterEvent("UNIT_SPELLCAST_INTERRUPTED")
				Serenity.F.Alerts[index]:RegisterEvent("UNIT_SPELLCAST_FAILED")
				Serenity.F.Alerts[index]:RegisterEvent("UNIT_SPELLCAST_CHANNEL_STOP")
			end

			index = index + 1
		end
	end
	Serenity.V.totalAlertIcons = index - 1
end
