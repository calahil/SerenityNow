--[[

	Energy Bar module
	
]]

if not Serenity then return end

Serenity.V.predictionSpellBase = 9

local function getPredictionAdjustment()

	if Serenity.V.playerclass == "HUNTER" then
		-- Account for Termination talent extra focus
		if UnitHealth("target") / UnitHealthMax("target") <= 0.25 then 
			return(select(5, GetTalentInfo(2, 12)) * 3) -- Termination base per point = 3
		end
	end	
	return (0)
end

local function getBarColor(prediction)

	if not prediction then prediction = 0 end

	-- class colored is turned on
	if Serenity.db.profile.frames.energybar.classcolored then
		if Serenity.db.profile.energybar.highwarn and (((UnitPower("player") + prediction) / UnitPowerMax("player")) >= Serenity.db.profile.energybar.highwarnthreshold) then
			-- class colored but over high threshold
			return Serenity.db.profile.frames.energybar.barcolorhigh
		elseif Serenity.db.profile.energybar.lowwarn and ((UnitPower("player") + prediction) < Serenity.GetMainSpellCost()) then
			-- Focus is lower than main shot
			return Serenity.db.profile.frames.energybar.barcolorlow
		else
			-- Tick coloring overrides the norm bar color but not high/low warnings
			if (Serenity.db.profile.energybar.ticks[1][1] == true) and (Serenity.F.EnergyBar["indicatorTick1"]) then
				local i, name, cost
				local tColor, tCost = nil, 0
				for i=1,5 do
					if (Serenity.db.profile.energybar.ticks[i][1] == true) and (Serenity.F.EnergyBar["indicatorTick"..i]) and (Serenity.db.profile.energybar.ticks[i][4] == true) then
						if i > 1 then
							name, _, _, cost = GetSpellInfo(Serenity.db.profile.energybar.ticks[i][2])
						end
						if (i == 1) or ((i > 1) and name and cost and (cost > 0)) then						
							if (i == 1) then
								if (UnitPower("player") >= Serenity.GetMainSpellCost()) then							
									tCost = Serenity.GetMainSpellCost()
									tColor = Serenity.db.profile.energybar.ticks[i][5]
								end								
							elseif (Serenity.db.profile.energybar.ticks[i][3] == true) and (UnitPower("player") >= (Serenity.GetMainSpellCost() + cost)) and ((Serenity.GetMainSpellCost() + cost) > tCost) then							
								tCost = Serenity.GetMainSpellCost() + cost
								tColor = Serenity.db.profile.energybar.ticks[i][5]								
							elseif (UnitPower("player") >= cost) and (cost > tCost) and (cost > tCost) and (Serenity.db.profile.energybar.ticks[i][3] ~= true) then							
								tCost = cost
								tColor = Serenity.db.profile.energybar.ticks[i][5]
							end
						end					
					end
				end
				
				if tColor then
					return tColor
				else
					return { (unpack(Serenity.V.classcolors[Serenity.V.playerclass])), 1 }
				end
			else
				-- class colored not over high threshold or high threshold is turned off
				return { (unpack(Serenity.V.classcolors[Serenity.V.playerclass])), 1 }
			end
		end

	-- class colored is not turned on
	elseif Serenity.db.profile.energybar.highwarn and (((UnitPower("player") + prediction) / UnitPowerMax("player")) >= Serenity.db.profile.energybar.highwarnthreshold) then
		-- over the threshold enabled, set to the high warning color	
		return Serenity.db.profile.frames.energybar.barcolorhigh
	elseif Serenity.db.profile.energybar.lowwarn and ((UnitPower("player") + prediction) < Serenity.GetMainSpellCost()) then
		-- Focus is lower than main shot
		return Serenity.db.profile.frames.energybar.barcolorlow
	else
		-- Tick coloring overrides the norm bar color but not high/low warnings
		if (Serenity.db.profile.energybar.ticks[1][1] == true) and (Serenity.F.EnergyBar["indicatorTick1"]) then
			local i, name, cost
			local tColor, tCost = nil, 0
			for i=1,5 do
				if (Serenity.db.profile.energybar.ticks[i][1] == true) and (Serenity.F.EnergyBar["indicatorTick"..i]) and (Serenity.db.profile.energybar.ticks[i][4] == true) then
					if i > 1 then
						name, _, _, cost = GetSpellInfo(Serenity.db.profile.energybar.ticks[i][2])
					end
					if (i == 1) or ((i > 1) and name and cost and (cost > 0)) then					
						if (i == 1) then
							if (UnitPower("player") >= Serenity.GetMainSpellCost()) then						
								tCost = Serenity.GetMainSpellCost()
								tColor = Serenity.db.profile.energybar.ticks[i][5]
							end							
						elseif (Serenity.db.profile.energybar.ticks[i][3] == true) and (UnitPower("player") >= (Serenity.GetMainSpellCost() + cost)) and ((Serenity.GetMainSpellCost() + cost) > tCost) then						
							tCost = Serenity.GetMainSpellCost() + cost
							tColor = Serenity.db.profile.energybar.ticks[i][5]							
						elseif (UnitPower("player") >= cost) and (cost > tCost) and (Serenity.db.profile.energybar.ticks[i][3] ~= true) then						
							tCost = cost
							tColor = Serenity.db.profile.energybar.ticks[i][5]
						end
					end					
				end
			end
			
			if tColor then
				return tColor
			else
				return Serenity.db.profile.frames.energybar.barcolor
			end
		else
			-- class colored not over high threshold or high threshold is turned off
			return Serenity.db.profile.frames.energybar.barcolor
		end
	end
end

local function updatePrediction()

	if Serenity.db.profile.energybar.enableprediction and Serenity.F.EnergyBar.playerIsCasting then

		local prediction = Serenity.V.predictionSpellBase + getPredictionAdjustment()
		local barColor = getBarColor(prediction)
		
		Serenity.F.EnergyBar.PredictionFrame:SetSize(
			(Serenity.F.EnergyBar:GetWidth() / 100) * prediction, Serenity.F.EnergyBar:GetHeight())

		Serenity.F.EnergyBar.PredictionFrame:ClearAllPoints()
		Serenity.F.EnergyBar.PredictionFrame:SetPoint("LEFT", Serenity.F.EnergyBar, "LEFT",
			Serenity.F.EnergyBar:GetWidth() / (select(2, Serenity.F.EnergyBar:GetMinMaxValues()) / Serenity.F.EnergyBar:GetValue()), 0)

		if (UnitPower("player") + prediction) > UnitPowerMax("player") then
			Serenity.F.EnergyBar.PredictionFrame:SetSize(
				(Serenity.F.EnergyBar:GetWidth() / 100) * (UnitPowerMax("player") - UnitPower("player")), Serenity.F.EnergyBar:GetHeight())			
		end
		
		Serenity.F.EnergyBar.PredictionFrame:SetStatusBarColor(barColor[1], barColor[2], barColor[3], 1)
		
		if ((UnitPowerMax("player") - UnitPower("player")) > 0) and (not UnitIsDeadOrGhost("player")) then
			Serenity.F.EnergyBar.PredictionFrame:SetAlpha(Serenity.F.EnergyBar:GetAlpha() * 0.6)
			Serenity.F.EnergyBar.PredictionFrame:Show()
		else
			Serenity.F.EnergyBar.PredictionFrame:Hide()
		end
	end
end

function Serenity.SetupEnergyBarModule()

	-- Destruction
	local i = 1
	if Serenity.F.StackBars then
		while Serenity.F.StackBars[i] ~= nil do
			Serenity.F.StackBars[i]:Hide()
			Serenity.F.StackBars[i]:UnregisterAllEvents()
			Serenity.F.StackBars[i]:SetScript("OnUpdate", nil)
			Serenity.F.StackBars[i]:SetParent(nil)
			Serenity.F.StackBars[i] = nil
			i = i + 1
		end
		Serenity.F.StackBars = nil
	end
	
	if Serenity.F.StackBarsHost then
		Serenity.F.StackBarsHost:Hide()
		Serenity.DeregisterMovableFrame("MOVER_STACKBARS")
		Serenity.F.StackBarsHost:SetParent(nil)
		Serenity.F.StackBarsHost = nil
	end
	
	if Serenity.F.EnergyBar then
		Serenity.F.EnergyBar:Hide()
		if Serenity.F.EnergyBar.autoShotFrame and Serenity.F.EnergyBar.autoShotFrame.smoother then
			Serenity.RemoveSmooth(Serenity.F.EnergyBar.autoShotFrame)
		end
		if Serenity.F.EnergyBar.smoother then
			Serenity.RemoveSmooth(Serenity.F.EnergyBar)
		end
		if Serenity.F.EnergyBar.PredictionFrame then			
			Serenity.F.EnergyBar:UnregisterEvent("UNIT_SPELLCAST_START")
			Serenity.F.EnergyBar:UnregisterEvent("UNIT_SPELLCAST_STOP")
			Serenity.F.EnergyBar:UnregisterEvent("UNIT_SPELLCAST_SUCCEEDED")
			Serenity.F.EnergyBar:UnregisterEvent("UNIT_SPELLCAST_FAILED")
		end		
		Serenity.DeregisterMovableFrame("MOVER_ENERGYBAR")
		Serenity.F.EnergyBar:SetParent(nil)
		Serenity.F.EnergyBar = nil
	end
		
	-- Construction
	if Serenity.db.profile.energybar.enabled then

		local ENERGYBAR_UPDATEINTERVAL = 0.07

		-- Create the Frame
		Serenity.F.EnergyBar = Serenity.MakeFrame("StatusBar", "SERENITY_ENERGYBAR", Serenity.db.profile.energybar.anchor[2] or UIParent)
		Serenity.F.EnergyBar:SetStatusBarTexture(Serenity.GetLibSharedMedia3():Fetch("statusbar", Serenity.db.profile.frames.energybar.bartexture))
		Serenity.F.EnergyBar:SetMinMaxValues(0, (UnitPowerMax("player") > 0) and UnitPowerMax("player") or 100)	
		Serenity.F.EnergyBar:SetStatusBarColor(Serenity.db.profile.frames.energybar.classcolored and
			(unpack({ unpack(Serenity.V["classcolors"][Serenity.V["playerclass"] ]), 1})) or unpack(Serenity.db.profile.frames.energybar.barcolor))
		Serenity.F.EnergyBar:SetSize(Serenity.db.profile.frames.energybar.width, Serenity.db.profile.frames.energybar.height)
		Serenity.F.EnergyBar:SetPoint(Serenity.GetActiveAnchor(Serenity.db.profile.energybar.anchor))
		Serenity.F.EnergyBar:SetAlpha(0)
		Serenity.F.EnergyBar:SetValue(UnitPower("player"))
		
		-- Create the Background and border if the user wants one
		Serenity.F.EnergyBar.background = Serenity.MakeBackground(Serenity.F.EnergyBar, Serenity.db.profile.frames.energybar)

		Serenity.RegisterMovableFrame(
			"MOVER_ENERGYBAR",
			Serenity.F.EnergyBar,
			Serenity.F.EnergyBar,
			Serenity.L["Energy Bar"],
			Serenity.db.profile.energybar,
			Serenity.SetupEnergyBarModule,
			Serenity.V["classspecific_defaults"][Serenity.V["playerclass"] ]["energybar"],
			Serenity.db.profile.frames.energybar
		)
		
		if Serenity.db.profile.energybar.smoothbar then
			Serenity.MakeSmooth(Serenity.F.EnergyBar)		
		end
		
		if Serenity.db.profile.energybar.energynumber then		
			Serenity.F.EnergyBar.value = Serenity.F.EnergyBar:CreateFontString(nil, "OVERLAY")
			Serenity.F.EnergyBar.value:SetJustifyH("CENTER")
			Serenity.F.EnergyBar.value:SetPoint("CENTER", Serenity.F.EnergyBar, "CENTER", Serenity.db.profile.frames.energybar.energyfontoffset,
				(Serenity.db.profile.energybar.shotbar == true) and 2 or 0)
			Serenity.F.EnergyBar.value:SetFont(Serenity.GetActiveFont(Serenity.db.profile.frames.energybar.energyfont))
			Serenity.F.EnergyBar.value:SetTextColor(unpack(Serenity.db.profile.frames.energybar.energyfontcolor))
			Serenity.F.EnergyBar.value:SetText(UnitPower("player"))
		end

		if Serenity.db.profile.energybar.targethealth then		
			Serenity.F.EnergyBar.targetHealthValue = Serenity.F.EnergyBar:CreateFontString(nil, "OVERLAY")
			Serenity.F.EnergyBar.targetHealthValue:SetJustifyH("LEFT")
			Serenity.F.EnergyBar.targetHealthValue:SetPoint("LEFT", Serenity.F.EnergyBar, "LEFT", 1 + Serenity.db.profile.frames.energybar.healthfontoffset,
				(Serenity.db.profile.energybar.shotbar == true) and 2 or 0)
			Serenity.F.EnergyBar.targetHealthValue:SetFont(Serenity.GetActiveFont(Serenity.db.profile.frames.energybar.healthfont))
			Serenity.F.EnergyBar.targetHealthValue:SetText("")
		end
		
		-- Setup prediction bar
		if Serenity.db.profile.energybar.enableprediction then		
			Serenity.F.EnergyBar.PredictionFrame = CreateFrame("StatusBar", nil, Serenity.F.EnergyBar)			
			Serenity.F.EnergyBar.PredictionFrame:SetStatusBarTexture(Serenity.F.EnergyBar:GetStatusBarTexture():GetTexture()) -- Use the main bar's texture
			Serenity.F.EnergyBar.PredictionFrame:SetMinMaxValues(0, 1)
			Serenity.F.EnergyBar.PredictionFrame:SetValue(1)
			Serenity.F.EnergyBar.PredictionFrame:SetFrameLevel(Serenity.F.EnergyBar:GetFrameLevel())
			Serenity.F.EnergyBar.PredictionFrame:SetSize(
				(Serenity.F.EnergyBar:GetWidth() / 100) * (Serenity.V.predictionSpellBase + getPredictionAdjustment()), Serenity.F.EnergyBar:GetHeight())		   
			Serenity.F.EnergyBar.PredictionFrame:Hide()
		end
		
		-- Setup Auto shot bar
		if Serenity.db.profile.energybar.shotbar then
			Serenity.F.EnergyBar.autoShotFrame = CreateFrame("StatusBar", nil, Serenity.F.EnergyBar)
			Serenity.F.EnergyBar.autoShotFrame:SetStatusBarTexture(Serenity.F.EnergyBar:GetStatusBarTexture():GetTexture()) -- Use the main bar's texture
			Serenity.F.EnergyBar.autoShotFrame:SetPoint("BOTTOMLEFT", Serenity.F.EnergyBar, "BOTTOMLEFT", 0, 0)
			Serenity.F.EnergyBar.autoShotFrame:SetMinMaxValues(0, UnitRangedDamage("player") * 100)
			Serenity.F.EnergyBar.autoShotFrame:SetSize(Serenity.F.EnergyBar:GetWidth(), 3)
			Serenity.F.EnergyBar.autoShotFrame:SetValue(UnitRangedDamage("player"))
			Serenity.F.EnergyBar.autoShotFrame:SetFrameLevel(Serenity.F.EnergyBar:GetFrameLevel() + 1)		
			Serenity.F.EnergyBar.autoShotFrame:SetStatusBarColor(unpack(Serenity.db.profile.frames.energybar.shotbarcolor))
			
			if Serenity.db.profile.energybar.smoothbarshotbar then
				Serenity.MakeSmooth(Serenity.F.EnergyBar.autoShotFrame)		
			end
			
			Serenity.F.EnergyBar.autoShotFrame.updateTimer = 0
			Serenity.F.EnergyBar.autoShotFrame:SetScript("OnUpdate", function(self, elapsed)
				self.updateTimer = self.updateTimer + elapsed
				if self.updateTimer <= 0.015 then return else self.updateTimer = 0 end
				self.updateTimer = 0				
				if (GetTime() < self:GetParent().autoShotEndTime) then
					self:SetValue((UnitRangedDamage("player") * 100) - ((self:GetParent().autoShotEndTime * 100) - (GetTime() * 100)))
				else
					self:SetValue(0)
					self:Hide()
				end
			end)
		end
		
		-- Setup Auto shot time
		if Serenity.db.profile.energybar.shottimer then
			Serenity.F.EnergyBar.autoShotValue = Serenity.F.EnergyBar:CreateFontString(nil, "OVERLAY")
			Serenity.F.EnergyBar.autoShotValue:SetFont(Serenity.GetActiveFont(Serenity.db.profile.frames.energybar.shottimerfont))
			Serenity.F.EnergyBar.autoShotValue:SetTextColor(unpack(Serenity.db.profile.frames.energybar.shottimerfontcolor))
			Serenity.F.EnergyBar.autoShotValue:SetPoint("BOTTOMRIGHT", Serenity.F.EnergyBar, "BOTTOMRIGHT", 1  + Serenity.db.profile.frames.energybar.shottimerfontoffset, 1)
			Serenity.F.EnergyBar.autoShotValue:SetJustifyH("BOTTOM")
		end

		-- Setup Indicator marks
		local name, cost
		for i=1,5 do
			if (Serenity.db.profile.energybar.ticks[i][1] == true) and ((Serenity.db.profile.energybar.ticks[i][6] == 0)
				or (Serenity.db.profile.energybar.ticks[i][6] == GetPrimaryTalentTree())) and (Serenity.db.profile.energybar.ticks[1][1] == true) then
				
				if i > 1 then
					name, _, _, cost = GetSpellInfo(Serenity.db.profile.energybar.ticks[i][2])
				end
				
				if (i == 1) or ((i > 1) and name and cost and (cost > 0)) then
					Serenity.F.EnergyBar["indicatorTick"..i] = Serenity.MakeFrame("Frame", "SERENITY_ENERGYBAR_TICK"..i, Serenity.F.EnergyBar)
					Serenity.F.EnergyBar["indicatorTick"..i]:SetSize(10, Serenity.F.EnergyBar:GetHeight() * 1.6)
					Serenity.F.EnergyBar["indicatorTick"..i].tex = Serenity.F.EnergyBar["indicatorTick"..i]:CreateTexture(nil, "OVERLAY")
					Serenity.F.EnergyBar["indicatorTick"..i].tex:SetAllPoints(Serenity.F.EnergyBar["indicatorTick"..i])
					Serenity.F.EnergyBar["indicatorTick"..i].tex:SetTexture("Interface\\CastingBar\\UI-CastingBar-Spark")	
					Serenity.F.EnergyBar["indicatorTick"..i].tex:SetBlendMode("ADD")
					Serenity.F.EnergyBar["indicatorTick"..i]:SetAlpha(1)
					Serenity.F.EnergyBar["indicatorTick"..i]:Hide()
				end
			end
		end
		
		-- Register Events to support the bar
		Serenity.F.EnergyBar:RegisterEvent("UNIT_SPELLCAST_START")
		Serenity.F.EnergyBar:RegisterEvent("UNIT_SPELLCAST_STOP")
		Serenity.F.EnergyBar:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")
		Serenity.F.EnergyBar:RegisterEvent("UNIT_SPELLCAST_FAILED")
		Serenity.F.EnergyBar:RegisterEvent("UNIT_MAXPOWER")
		Serenity.F.EnergyBar.autoShotStartTime = 0
		Serenity.F.EnergyBar.autoShotEndTime = 0
		Serenity.F.EnergyBar:SetScript("OnEvent", function(self, event, ...)
			-- 4.1 local timeStamp, subEvent, hideCaster, sourceGUID, sourceName, sourceFlags, destGUID, destName, destFlags, spellId, spellName, spellSchool, extraSpellID, extraSpellName, extraSchool, auraType = ...
			-- 4.2 local timeStamp, subEvent, hideCaster, sourceGUID, sourceName, sourceFlags, sourceFlags2, destGUID, destName, destFlags, destFlags2, spellId, spellName, spellSchool, extraSpellID, extraSpellName, extraSchool, auraType = ...
			local sourceUnit, spellName, spellId		
			if (Serenity.V.wowBuild >= 40200) then -- 4.2 patch ready
				sourceUnit, spellName, _, _, spellId = ...
			else -- 4.1
				sourceUnit, spellName, _, _, spellId = ...
			end
			if (event == "UNIT_SPELLCAST_START") and Serenity.db.profile.energybar.enableprediction then
			
				if (sourceUnit == "player") then						
					if (spellId  == 56641) or (spellId == 77767) then -- HUNTER: Steady Shot / Cobra Shot
						self.playerIsCasting = true
						updatePrediction()
					end
				end
			
			elseif (event == "UNIT_SPELLCAST_SUCCEEDED") and (spellId == 75) and (Serenity.db.profile.energybar.shotbar or Serenity.db.profile.energybar.shottimer) then -- HUNTER: Auto shot
			
				self.autoShotStartTime = GetTime()
				self.autoShotEndTime = self.autoShotStartTime + UnitRangedDamage("player")

				if Serenity.db.profile.energybar.shotbar then
					self.autoShotFrame:Show()
				end

				if Serenity.db.profile.energybar.shottimer then
					self.autoShotValue:SetFormattedText("%.1f", self.autoShotEndTime - GetTime()) -- "%.1f"
				end
			
			elseif (event == "UNIT_MAXPOWER") then
			
				self:SetMinMaxValues(0, UnitPowerMax("player"))
			
			elseif (event == "UNIT_SPELLCAST_STOP") or (event == "UNIT_SPELLCAST_FAILED") then
			
				if ((spellId  == 56641) or (spellId == 77767)) and Serenity.db.profile.energybar.enableprediction then -- HUNTER: Steady Shot / Cobra Shot			
					self.playerIsCasting = nil					
					self.PredictionFrame:Hide()
				end
			end
		end)
		
		-- Setup the script for handling the Timer Set
		Serenity.F.EnergyBar.updateTimer = 0		
		Serenity.F.EnergyBar:SetScript("OnUpdate", function(self, elapsed)
		
			self.updateTimer = self.updateTimer + elapsed
			
			if self.updateTimer < ENERGYBAR_UPDATEINTERVAL then return else self.updateTimer = 0 end
		
			-- Overrides take precidence over normal alpha
			if Serenity.db.profile.energybar.deadoverride and UnitIsDeadOrGhost("player") then			
				self:SetAlpha(Serenity.db.profile.energybar.deadoverridealpha)				
			elseif Serenity.db.profile.energybar.mountoverride and (IsMounted() or UnitUsingVehicle("player")) then			
				self:SetAlpha(Serenity.db.profile.energybar.mountoverridealpha)				
			elseif Serenity.db.profile.energybar.oocoverride and (not InCombatLockdown()) then			
				self:SetAlpha(Serenity.db.profile.energybar.oocoverridealpha)				
			elseif UnitPower("player") ~= UnitPowerMax("player") then			
				self:SetAlpha(Serenity.db.profile.energybar.activealpha)			
			else			
				self:SetAlpha(Serenity.db.profile.energybar.inactivealpha)
			end
			
			-- Handle status bar updating
			self:SetValue(UnitPower("player"))
			
			if Serenity.db.profile.energybar.energynumber and (self.value ~= nil) then
				self.value:SetText(UnitPower("player"))
			end

			self:SetStatusBarColor(unpack(getBarColor()))

			-- Update the prediction bar, if enabled
			updatePrediction()			
			
			-- Update Shot time
			if Serenity.db.profile.energybar.shottimer then
				if (not UnitIsDeadOrGhost("player")) and (GetTime() < self.autoShotEndTime) and InCombatLockdown() then
					self.autoShotValue:SetFormattedText("%.1f", self.autoShotEndTime - GetTime())
				else
					self.autoShotValue:SetText("")
				end
			end
			
			-- Handle Target Health Percentage
			if Serenity.db.profile.energybar.targethealth then			
				if (not UnitExists("target")) or (UnitIsDeadOrGhost("target")) then 
					self.targetHealthValue:SetText("")
				else
					if UnitHealth("target") / UnitHealthMax("target") >= .9 then					
						self.targetHealthValue:SetFormattedText("|cffffff00%d %%|r", (UnitHealth("target") / UnitHealthMax("target")) * 100)						
					elseif UnitHealth("target") / UnitHealthMax("target") >= .2 then					
						self.targetHealthValue:SetFormattedText("|cffffffff%d %%|r", (UnitHealth("target") / UnitHealthMax("target")) * 100)						
					else
						self.targetHealthValue:SetFormattedText("|cffff0000%d %%|r", (UnitHealth("target") / UnitHealthMax("target")) * 100)
					end
				end			
			end
			
			-- Handle indicator tick marks
			local i, name, cost			
			for i=1,5 do
				if (Serenity.db.profile.energybar.ticks[i][1] == true) and (self["indicatorTick"..i] ~= nil) and (Serenity.db.profile.energybar.ticks[1][1] == true) then
				
					if (i > 1) then
						name, _, _, cost = GetSpellInfo(Serenity.db.profile.energybar.ticks[i][2])
					end
					
					if (i == 1) or ((i > 1) and name and cost and (cost > 0)) then
						if i == 1 then
							self["indicatorTick"..i]:ClearAllPoints()
							self["indicatorTick"..i]:SetPoint("LEFT", self, "LEFT", Serenity.GetMainSpellCost() * (self:GetWidth() / select(2, self:GetMinMaxValues())) - 5, 0)
						else
							self["indicatorTick"..i]:ClearAllPoints()
							self["indicatorTick"..i]:SetPoint("LEFT", self, "LEFT", 
								( (Serenity.db.profile.energybar.ticks[i][3] == true) and (Serenity.GetMainSpellCost() + cost) or cost ) * 
								(self:GetWidth() / select(2, self:GetMinMaxValues())) - 5, 0)
						end
						self["indicatorTick"..i]:Show()
					else
						self["indicatorTick"..i]:Hide()
					end
				end
			end
		end)
		
		-- Construct the Stacks indicators		
		if not Serenity.db.profile.energybar.enablestacks then return end
		
		local STACKBARS_UPDATEINTERVAL = 0.15
		local numBars = 1
		local checkFunction = function(self) return end
		local stackSize = Serenity.db.profile.energybar.embedstacks and (Serenity.db.profile.frames.energybar.height * .85) or Serenity.db.profile.energybar.stackssize

		-- Setup the check functions for various specs
		if GetPrimaryTalentTree() == 1 then -- BM
	
			numBars = 5 -- Frenzy Stacks on pet for focus fire.		
			if (not select(5, GetTalentInfo(1, 6))) then return end -- Frenzy		
			checkFunction = function(self)
				local stacks = select(4, UnitAura("pet", GetSpellInfo(19615), nil, "HELPFUL")) or 0 -- 19615 = Frenzy Effect
				if stacks >= self.barIndex then
					self:SetAlpha((1 / self.totalBars) * self.barIndex)
					return true
				else
					self:SetAlpha(0)
				end
				return false
			end
		
		elseif GetPrimaryTalentTree() == 2 then -- MM
		
			numBars = 5 -- Ready, Set, Aim... on player		
			checkFunction = function(self)
				local proc = select(1, UnitAura("player", GetSpellInfo(82926), nil, "HELPFUL")) or false -- 82926 = Fire! proc
				local stacks = select(4, UnitAura("player", GetSpellInfo(82925), nil, "HELPFUL")) or 0 -- 82925 = Ready, Set, Aim...
				if proc or (stacks >= self.barIndex) then
					self:SetAlpha((1 / self.totalBars) * self.barIndex)
				else
					self:SetAlpha(0)
				end
			end
			
		elseif GetPrimaryTalentTree() == 3 then -- SV
		
			numBars = 2 -- LnL Proc
			if (not select(5, GetTalentInfo(3, 10))) then return end -- Lock n' Load		
			checkFunction = function(self)
				local stacks = select(4, UnitAura("player", GetSpellInfo(56342), nil, "HELPFUL")) or 0 -- 56342 = Lock n' Load proc		
				if stacks >= self.barIndex then
					self:SetAlpha((1 / self.totalBars) * self.barIndex)
				else
					self:SetAlpha(0)
				end
			end		
		end
		
		local gap = 0
		local totalWidth = ((stackSize + gap) * numBars) - gap
		
		-- Setup the host frame & mover if not embedded
		
		Serenity.F.StackBarsHost = Serenity.MakeFrame("Frame", "SERENITY_STACKBARS_HOST", Serenity.db.profile.energybar.embedstacks and Serenity.F.EnergyBar or (Serenity.db.profile.energybar.anchor_stacks[2] or UIParent))
		Serenity.F.StackBarsHost:SetSize(totalWidth, stackSize)
		Serenity.F.StackBarsHost:SetSize((stackSize + gap) * numBars - gap, stackSize)
		if Serenity.db.profile.energybar.embedstacks then
			Serenity.F.StackBarsHost:SetPoint("RIGHT", Serenity.F.EnergyBar, "TOPRIGHT")
		else
			Serenity.F.StackBarsHost:SetPoint(Serenity.GetActiveAnchor(Serenity.db.profile.energybar.anchor_stacks))
		end
		Serenity.F.StackBarsHost:SetAlpha(1)
		Serenity.F.StackBarsHost:Show()
			
		if not Serenity.db.profile.energybar.embedstacks then
			Serenity.RegisterMovableFrame(
				"MOVER_STACKBARS",
				Serenity.F.StackBarsHost,
				Serenity.F.StackBarsHost,
				Serenity.L["Stacks"],
				Serenity.db.profile.energybar,
				nil,
				Serenity.V["classspecific_defaults"][Serenity.V["playerclass"] ]["energybar"],
				nil,
				"_stacks"
			)
		end
		
		Serenity.F.StackBars = {}
		for i=1,numBars do
			Serenity.F.StackBars[i] = CreateFrame("Frame", nil, Serenity.F.StackBarsHost)
			Serenity.F.StackBars[i]:SetSize(stackSize, stackSize)
			
			if Serenity.db.profile.energybar.stacksreverse then
				Serenity.F.StackBars[i]:SetPoint("RIGHT", Serenity.F.StackBarsHost, "RIGHT", -((stackSize + gap) * (i - 1)), 0)
			else
				Serenity.F.StackBars[i]:SetPoint("LEFT", Serenity.F.StackBarsHost, "LEFT", ((stackSize + gap) * (i - 1)), 0)
			end

			Serenity.F.StackBars[i].stack = Serenity.F.StackBars[i]:CreateTexture(nil, "ARTWORK")
			Serenity.F.StackBars[i].stack:SetAllPoints(Serenity.F.StackBars[i])
			Serenity.F.StackBars[i].stack:SetTexture("Interface\\AddOns\\Serenity\\media\\graphics\\stack1.tga")
			Serenity.F.StackBars[i].stack:SetVertexColor(unpack(Serenity.db.profile.energybar.stackscolor))
			Serenity.F.StackBars[i].stack:Show()
			
			Serenity.F.StackBars[i].barIndex = i
			Serenity.F.StackBars[i].totalBars = numBars
			Serenity.F.StackBars[i].checkFunction = checkFunction
			Serenity.F.StackBars[i].updateTimer = 0		

			Serenity.F.StackBars[i]:SetScript("OnUpdate", function(self, elapsed)
				self.updateTimer = self.updateTimer + elapsed
				if self.updateTimer < STACKBARS_UPDATEINTERVAL then return else self.updateTimer = 0 end
				
				self.checkFunction(self)				
			end)

			Serenity.F.StackBars[i]:SetAlpha(0)
			Serenity.F.StackBars[i]:Show()		
		end	
	end
end
