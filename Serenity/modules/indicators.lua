--[[

	Indicators frames
	
]]

if not Serenity then return end

function Serenity.SetupIndicatorsModule(lockName)

	-- Deconstruction
	if Serenity.F.Indicators then
		-- Hunter's Mark
		if (not lockName) or (lockName == "MOVER_INDICATORS_HUNTERSMARK") then 
			Serenity.DeregisterMovableFrame("MOVER_INDICATORS_HUNTERSMARK")
			if Serenity.F.Indicators.HuntersMark then 
				Serenity.F.Indicators.HuntersMark:Hide()			
				Serenity.F.Indicators.HuntersMark:SetParent(nil)
				Serenity.F.Indicators.HuntersMark = nil
			end
		end
		-- Aspect
		if (not lockName) or (lockName == "MOVER_INDICATORS_ASPECT") then
			Serenity.DeregisterMovableFrame("MOVER_INDICATORS_ASPECT")
			if Serenity.F.Indicators.Aspect then 
				Serenity.F.Indicators.Aspect:Hide()
				Serenity.F.Indicators.Aspect:UnregisterAllEvents()
				Serenity.F.Indicators.Aspect:SetParent(nil)
				Serenity.F.Indicators.Aspect = nil
			end
		end
		-- Scare Beast
		if (not lockName) or (lockName == "MOVER_INDICATORS_SCAREBEAST") then
			Serenity.DeregisterMovableFrame("MOVER_INDICATORS_SCAREBEAST")
			if Serenity.F.Indicators.ScareBeast then 
				Serenity.F.Indicators.ScareBeast:Hide()			
				Serenity.F.Indicators.ScareBeast:SetParent(nil)
				Serenity.F.Indicators.ScareBeast = nil
			end
		end
	end

	if not Serenity.db.profile.indicators.enabled then return end
	
	if (not Serenity.F.Indicators) then Serenity.F.Indicators = {} end
	
	-- Construction
	local INDICATORS_UPDATEINTERVAL = 0.125
	
	-- Hunter's Mark
	if Serenity.db.profile.indicators.huntersmark_enable and (Serenity.V["playerclass"] == "HUNTER") and ((not lockName) or (lockName == "MOVER_INDICATORS_HUNTERSMARK")) then
	
		-- Create the Frame
		Serenity.F.Indicators.HuntersMark = Serenity.MakeFrame("Frame", "SERENITY_INDICATORS_HUNTERSMARK", Serenity.db.profile.indicators.anchor_huntersmark[2] or UIParent)
		Serenity.F.Indicators.HuntersMark:SetSize(Serenity.db.profile.frames.indicators.huntersmark_iconsize, Serenity.db.profile.frames.indicators.huntersmark_iconsize)
		Serenity.F.Indicators.HuntersMark:SetPoint(Serenity.GetActiveAnchor(Serenity.db.profile.indicators.anchor_huntersmark))

		Serenity.F.Indicators.HuntersMark.Icon = Serenity.F.Indicators.HuntersMark:CreateTexture(nil, "BACKGROUND")
		Serenity.F.Indicators.HuntersMark.Icon:SetTexture("Interface\\Icons\\Ability_Hunter_SniperShot") -- Hunter's Mark texture
		if Serenity.db.profile.frames.indicators.huntersmark_enabletexcoords then
			Serenity.F.Indicators.HuntersMark.Icon:SetTexCoord(unpack(Serenity.db.profile.frames.indicators.huntersmark_texcoords))
		end
		Serenity.F.Indicators.HuntersMark.Icon:SetAllPoints(Serenity.F.Indicators.HuntersMark)

		Serenity.F.Indicators.HuntersMark.shine = SpellBook_GetAutoCastShine()
		Serenity.F.Indicators.HuntersMark.shine:Show()
		Serenity.F.Indicators.HuntersMark.shine:SetParent(Serenity.F.Indicators.HuntersMark)
		Serenity.F.Indicators.HuntersMark.shine:SetSize(Serenity.db.profile.frames.indicators.huntersmark_iconsize + 3, Serenity.db.profile.frames.indicators.huntersmark_iconsize + 3)
		Serenity.F.Indicators.HuntersMark.shine:SetPoint("CENTER", Serenity.F.Indicators.HuntersMark, "CENTER")	
		
		Serenity.F.Indicators.HuntersMark.background = Serenity.MakeBackground(Serenity.F.Indicators.HuntersMark, Serenity.db.profile.frames.indicators, "huntersmark_")
		Serenity.F.Indicators.HuntersMark:SetAlpha(0)
		Serenity.F.Indicators.HuntersMark:Show()
		
		Serenity.RegisterMovableFrame(
			"MOVER_INDICATORS_HUNTERSMARK",
			Serenity.F.Indicators.HuntersMark,
			Serenity.F.Indicators.HuntersMark,
			Serenity.L["Hunter's Mark Indicator"],
			Serenity.db.profile.indicators,
			Serenity.SetupIndicatorsModule,
			Serenity.V.defaults.profile["indicators"],
			Serenity.db.profile.frames.indicators,
			"_huntersmark",
			"huntersmark_"
		)
	
		Serenity.F.Indicators.HuntersMark.updateTimer = 0
		Serenity.F.Indicators.HuntersMark:SetScript("OnUpdate", function(self, elapsed, ...)
	
			self.updateTimer = self.updateTimer + elapsed		
			if self.updateTimer < INDICATORS_UPDATEINTERVAL then return else self.updateTimer = 0 end
			if not Serenity.V["MoversLocked"] then return end

			if (not UnitExists("target")) or (not UnitReaction("player", "target")) or (UnitReaction("player", "target") > 4) or UnitIsDeadOrGhost("target") or UnitIsDeadOrGhost("player") or UnitInVehicle("player") then
					AutoCastShine_AutoCastStop(Serenity.F.Indicators.HuntersMark.shine)
					Serenity.F.Indicators.HuntersMark:SetAlpha(0)
			else
				local name, _, _, _, _, duration, expirationTime = UnitAura("target", GetSpellInfo(56303), nil, "HARMFUL") -- Any hunter's mark, not just player!
				local nameMFD, _, _, _, _, durationMFD, expirationTimeMFD = UnitAura("target", GetSpellInfo(88691), nil, "HARMFUL") -- Any MFD, not just player!

				-- Mark present and time is above threshold of 15s (HM) / 5s (MFD)
				if (name and ((expirationTime - GetTime()) >= 15)) or (nameMFD and ((expirationTimeMFD - GetTime()) >= 5)) or (nameMFD and Serenity.db.profile.indicators.huntersmark_mfd) then

					-- Hunter's Mark / MFD present with 15s/5s or more remaining duration on target
					AutoCastShine_AutoCastStop(Serenity.F.Indicators.HuntersMark.shine)
					Serenity.F.Indicators.HuntersMark:SetAlpha(0)

				-- Hunter's Mark present, didn't meet above condition, must be under 30s duration remaining.
				elseif name and not (nameMFD and ((expirationTimeMFD - GetTime()) >= 5)) then				
					if (Serenity.F.Indicators.HuntersMark.timer == nil) or (not Serenity.F.Indicators.HuntersMark.timer.enabled) then					
						local timer = Serenity.F.Indicators.HuntersMark.timer or Serenity.Timer_Create(Serenity.F.Indicators.HuntersMark)
						timer.start = GetTime()
						timer.duration = expirationTime - GetTime()
						timer.enabled = true
						timer.nextUpdate = 0
						timer:Show()
					end					
					if InCombatLockdown() then
						AutoCastShine_AutoCastStart(Serenity.F.Indicators.HuntersMark.shine)
					else
						AutoCastShine_AutoCastStop(Serenity.F.Indicators.HuntersMark.shine)
					end					
					Serenity.F.Indicators.HuntersMark:SetAlpha(1)

				-- Hunter's Mark not up but MFD present, didn't meet above conditions, must be under 5s duration remaining.
				elseif nameMFD then				
					if (Serenity.F.Indicators.HuntersMark.timer == nil) or (not Serenity.F.Indicators.HuntersMark.timer.enabled) then
						local timer = Serenity.F.Indicators.HuntersMark.timer or Serenity.Timer_Create(Serenity.F.Indicators.HuntersMark)
						timer.start = GetTime()
						timer.duration = expirationTimeMFD - GetTime()
						timer.enabled = true
						timer.nextUpdate = 0
						timer:Show()
					end					
					if InCombatLockdown() then
						AutoCastShine_AutoCastStart(Serenity.F.Indicators.HuntersMark.shine)
					else
						AutoCastShine_AutoCastStop(Serenity.F.Indicators.HuntersMark.shine)
					end					
					Serenity.F.Indicators.HuntersMark:SetAlpha(1)

				-- Mark is not present at all.
				else					
					if InCombatLockdown() then
						AutoCastShine_AutoCastStart(Serenity.F.Indicators.HuntersMark.shine)
					else
						AutoCastShine_AutoCastStop(Serenity.F.Indicators.HuntersMark.shine)
					end					
					Serenity.F.Indicators.HuntersMark:SetAlpha(1)					
					local timer = Serenity.F.Indicators.HuntersMark.timer or Serenity.Timer_Create(Serenity.F.Indicators.HuntersMark)
					timer.enabled = false
					timer:Hide()
				end
			end
		end)
	end
	
	-- Aspect/
	if Serenity.db.profile.indicators.aspect_enable and (Serenity.V["playerclass"] == "HUNTER") and ((not lockName) or (lockName == "MOVER_INDICATORS_ASPECT")) then
	
		-- Create the Frame
		Serenity.F.Indicators.Aspect = Serenity.MakeFrame("Frame", "SERENITY_INDICATORS_ASPECT", Serenity.db.profile.indicators.anchor_aspect[2] or UIParent)
		Serenity.F.Indicators.Aspect:SetSize(Serenity.db.profile.frames.indicators.aspect_iconsize, Serenity.db.profile.frames.indicators.aspect_iconsize)
		Serenity.F.Indicators.Aspect:SetPoint(Serenity.GetActiveAnchor(Serenity.db.profile.indicators.anchor_aspect))

		Serenity.F.Indicators.Aspect.Icon = Serenity.F.Indicators.Aspect:CreateTexture(nil, "BACKGROUND")
		Serenity.F.Indicators.Aspect.Icon:SetTexture("Interface\\Buttons\\UI-GroupLoot-Pass-Up")
		
		if Serenity.db.profile.frames.indicators.aspect_enabletexcoords then
			Serenity.F.Indicators.Aspect.Icon:SetTexCoord(unpack(Serenity.db.profile.frames.indicators.aspect_texcoords))
		end
		Serenity.F.Indicators.Aspect.Icon:SetAllPoints(Serenity.F.Indicators.Aspect)
	
		Serenity.F.Indicators.Aspect.shine = SpellBook_GetAutoCastShine()
		Serenity.F.Indicators.Aspect.shine:Show()
		Serenity.F.Indicators.Aspect.shine:SetParent(Serenity.F.Indicators.Aspect)
		Serenity.F.Indicators.Aspect.shine:SetSize(Serenity.db.profile.frames.indicators.aspect_iconsize + 3, Serenity.db.profile.frames.indicators.aspect_iconsize + 3)
		Serenity.F.Indicators.Aspect.shine:SetPoint("CENTER", Serenity.F.Indicators.Aspect, "CENTER")
		
		-- Create the Background and border if the user wants one
		Serenity.F.Indicators.Aspect.background = Serenity.MakeBackground(Serenity.F.Indicators.Aspect, Serenity.db.profile.frames.indicators, "aspect_")
		Serenity.F.Indicators.Aspect:SetAlpha(1)
		Serenity.F.Indicators.Aspect:Show()
		
		Serenity.RegisterMovableFrame(
			"MOVER_INDICATORS_ASPECT",
			Serenity.F.Indicators.Aspect,
			Serenity.F.Indicators.Aspect,
			Serenity.L["Aspect Indicator"],
			Serenity.db.profile.indicators,
			Serenity.SetupIndicatorsModule,
			Serenity.V.defaults.profile["indicators"],
			Serenity.db.profile.frames.indicators,
			"_aspect",
			"aspect_"
		)

		local function DoAspectUpdate(self)
			-- Set the proper texture for the current (or missing) aspect
			if (GetShapeshiftForm() > 0) then -- There is an aspect up
				local _, name = GetShapeshiftFormInfo(GetShapeshiftForm())
				local _, _, tex = GetSpellInfo(name)
				if self.Icon:GetTexture() ~= tex then
					self.Icon:SetTexture(tex)
				end
			elseif self.Icon:GetTexture() ~= "Interface\\Buttons\\UI-GroupLoot-Pass-Up" then
				self.Icon:SetTexture("Interface\\Buttons\\UI-GroupLoot-Pass-Up")
			end
			
			if InCombatLockdown() then
				if (GetShapeshiftForm() == 0) or (GetShapeshiftForm() == 3) or (GetShapeshiftForm() == 4) then -- missing or cheetah/pack
					Serenity.F.Indicators.Aspect:SetAlpha(1)
					AutoCastShine_AutoCastStart(Serenity.F.Indicators.Aspect.shine)
				elseif (not Serenity.db.profile.indicators.aspect_onlymissing) then -- good aspect, only missing not set
					Serenity.F.Indicators.Aspect:SetAlpha(1)
					AutoCastShine_AutoCastStop(Serenity.F.Indicators.Aspect.shine)
				else
					Serenity.F.Indicators.Aspect:SetAlpha(0)
					AutoCastShine_AutoCastStop(Serenity.F.Indicators.Aspect.shine)
				end
			else -- Not in combat!
				if ((GetShapeshiftForm() == 0) or (GetShapeshiftForm() == 3) or (GetShapeshiftForm() == 4)) and (not Serenity.db.profile.indicators.aspect_onlycombat) then -- missing or cheetah/pack
					Serenity.F.Indicators.Aspect:SetAlpha(1)
					AutoCastShine_AutoCastStop(Serenity.F.Indicators.Aspect.shine)
				elseif (not Serenity.db.profile.indicators.aspect_onlymissing) and (not Serenity.db.profile.indicators.aspect_onlycombat) then -- good aspect, only missing not set
					Serenity.F.Indicators.Aspect:SetAlpha(1)
					AutoCastShine_AutoCastStop(Serenity.F.Indicators.Aspect.shine)
				else
					Serenity.F.Indicators.Aspect:SetAlpha(0)
					AutoCastShine_AutoCastStop(Serenity.F.Indicators.Aspect.shine)
				end			
			end
		end
		
		Serenity.F.Indicators.Aspect.updateTimer = 0
		Serenity.F.Indicators.Aspect:SetScript("OnUpdate", function(self, elapsed, ...)	
			self.updateTimer = self.updateTimer + elapsed		
			if self.updateTimer < INDICATORS_UPDATEINTERVAL then return else self.updateTimer = 0 end
			if not Serenity.V["MoversLocked"] then return end			
			DoAspectUpdate(self)
		end)

--		Serenity.F.Indicators.Aspect:RegisterEvent("UPDATE_SHAPESHIFT_FORM")
--		Serenity.F.Indicators.Aspect:RegisterEvent("PLAYER_REGEN_ENABLED")
--		Serenity.F.Indicators.Aspect:RegisterEvent("PLAYER_REGEN_DISABLED")
--		Serenity.F.Indicators.Aspect:SetScript("OnEvent", function(self, event, ...)
--			Serenity.F.Indicators.Aspect:SetScript("OnUpdate", nil)
--			DoAspectUpdate(self)
--		end)
	end
	
	-- Scare Beast
	if Serenity.db.profile.indicators.scarebeast_enable and (Serenity.V["playerclass"] == "HUNTER") and ((not lockName) or (lockName == "MOVER_INDICATORS_SCAREBEAST")) then
	
		-- Create the Frame
		Serenity.F.Indicators.ScareBeast = Serenity.MakeFrame("Frame", "SERENITY_INDICATORS_SCAREBEAST", Serenity.db.profile.indicators.anchor_scarebeast[2] or UIParent)
		Serenity.F.Indicators.ScareBeast:SetSize(Serenity.db.profile.frames.indicators.scarebeast_iconsize, Serenity.db.profile.frames.indicators.scarebeast_iconsize)
		Serenity.F.Indicators.ScareBeast:SetPoint(Serenity.GetActiveAnchor(Serenity.db.profile.indicators.anchor_scarebeast))

		Serenity.F.Indicators.ScareBeast.Icon = Serenity.F.Indicators.ScareBeast:CreateTexture(nil, "BACKGROUND")
		Serenity.F.Indicators.ScareBeast.Icon:SetTexture("Interface\\Icons\\Ability_Druid_Cower")
		
		if Serenity.db.profile.frames.indicators.scarebeast_enabletexcoords then
			Serenity.F.Indicators.ScareBeast.Icon:SetTexCoord(unpack(Serenity.db.profile.frames.indicators.scarebeast_texcoords))
		end
		Serenity.F.Indicators.ScareBeast.Icon:SetAllPoints(Serenity.F.Indicators.ScareBeast)
	
		Serenity.F.Indicators.ScareBeast.shine = SpellBook_GetAutoCastShine()
		Serenity.F.Indicators.ScareBeast.shine:Show()
		Serenity.F.Indicators.ScareBeast.shine:SetParent(Serenity.F.Indicators.ScareBeast)
		Serenity.F.Indicators.ScareBeast.shine:SetSize(Serenity.db.profile.frames.indicators.scarebeast_iconsize + 3, Serenity.db.profile.frames.indicators.scarebeast_iconsize + 3)
		Serenity.F.Indicators.ScareBeast.shine:SetPoint("CENTER", Serenity.F.Indicators.ScareBeast, "CENTER")
		
		-- Create the Background and border if the user wants one
		Serenity.F.Indicators.ScareBeast.background = Serenity.MakeBackground(Serenity.F.Indicators.ScareBeast, Serenity.db.profile.frames.indicators, "scarebeast_")
		Serenity.F.Indicators.ScareBeast:SetAlpha(0)
		Serenity.F.Indicators.ScareBeast:Show()
		
		Serenity.RegisterMovableFrame(
			"MOVER_INDICATORS_SCAREBEAST",
			Serenity.F.Indicators.ScareBeast,
			Serenity.F.Indicators.ScareBeast,
			Serenity.L["Scare Beast Indicator"],
			Serenity.db.profile.indicators,
			Serenity.SetupIndicatorsModule,
			Serenity.V.defaults.profile["indicators"],
			Serenity.db.profile.frames.indicators,
			"_scarebeast",
			"scarebeast_"
		)

		Serenity.F.Indicators.ScareBeast.updateTimer = 0
		Serenity.F.Indicators.ScareBeast:SetScript("OnUpdate", function(self, elapsed, ...)
	
			self.updateTimer = self.updateTimer + elapsed		
			if self.updateTimer < INDICATORS_UPDATEINTERVAL then return else self.updateTimer = 0 end
			if not Serenity.V["MoversLocked"] then return end
		
			if (not UnitExists("target")) or (not IsUsableSpell(1513)) or (not UnitReaction("player", "target")) or (UnitReaction("player", "target") > 4) or 
				(GetSpellCooldown(1513) ~= 0) or UnitIsDeadOrGhost("target") or UnitIsDeadOrGhost("player") or UnitInVehicle("player") or 
				(IsSpellInRange(select(1, GetSpellInfo(1513)), "target") ~= 1) then
					AutoCastShine_AutoCastStop(Serenity.F.Indicators.ScareBeast.shine)
					Serenity.F.Indicators.ScareBeast:SetAlpha(0)
			else
				Serenity.F.Indicators.ScareBeast:SetAlpha(1)
				if InCombatLockdown() then
					AutoCastShine_AutoCastStart(Serenity.F.Indicators.ScareBeast.shine)
				else
					AutoCastShine_AutoCastStop(Serenity.F.Indicators.ScareBeast.shine)
				end
			end
		end)
	end
end
	