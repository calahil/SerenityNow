--[[

	Enrage removal module (Tranq/Shiv stuff, Announces & magic effects frame)
	
]]

if not Serenity then return end

local enrageTexture = {
	["HUNTER"] = "Interface\\Icons\\Spell_Nature_Drowsy", -- 19801 (Tranq Shot)
}

local enrageAlerts = {
	92967, -- BWD: Maloriak 
	80084, -- BWD: Maimgor
	80158, --  SC: Warbringers
	91543, -- BWD: Arcanotron - Power Conversion
	81706, --  TV: Lockmaw - Venomous Rage
	36828, -- BOT: Crossfires
}

function Serenity.SetupEnrageModule(lockName)

	-- Deconstruction
	if Serenity.F.EnrageAlert then
		if (not lockName) or (lockName == "MOVER_ENRAGEALERT") then
			Serenity.F.EnrageAlert:Hide()
			Serenity.F.EnrageAlert:UnregisterAllEvents()
			Serenity.DeregisterMovableFrame("MOVER_ENRAGEALERT")
			Serenity.F.EnrageAlert:SetParent(nil)
			Serenity.F.EnrageAlert = nil
		end
	end
	
	if Serenity.F.EnrageAlertRemovables then
		if (not lockName) or (lockName == "MOVER_ENRAGEREMOVABLES") then
			Serenity.F.EnrageAlertRemovables:Hide()
			Serenity.DeregisterMovableFrame("MOVER_ENRAGEREMOVABLES")
			Serenity.F.EnrageAlertRemovables:SetParent(nil)
			Serenity.F.EnrageAlertRemovables = nil
		end
	end
	
	if not Serenity.db.profile.enrage.enabled then return end
	
	-- Construction
	local ENRAGE_UPDATEINTERVAL = 0.1

	if ((not lockName) or (lockName == "MOVER_ENRAGEALERT")) then
		-- Create the Frame
		Serenity.F.EnrageAlert = Serenity.MakeFrame("Frame", "SERENITY_ENRAGEALERT", Serenity.db.profile.enrage.anchor[2] or UIParent)
		Serenity.F.EnrageAlert:SetSize(Serenity.db.profile.frames.enrage.iconsize, Serenity.db.profile.frames.enrage.iconsize)
		Serenity.F.EnrageAlert:SetPoint(Serenity.GetActiveAnchor(Serenity.db.profile.enrage.anchor))

		Serenity.F.EnrageAlert.Icon = Serenity.F.EnrageAlert:CreateTexture(nil, "BACKGROUND")
		Serenity.F.EnrageAlert.Icon:SetTexture(enrageTexture[Serenity.V["playerclass"] ])
		if Serenity.db.profile.frames.enrage.enabletexcoords then
			Serenity.F.EnrageAlert.Icon:SetTexCoord(unpack(Serenity.db.profile.frames.enrage.texcoords))
		end
		Serenity.F.EnrageAlert.Icon:SetAllPoints(Serenity.F.EnrageAlert)

		-- Add sparkle to make it more noticable
		Serenity.F.EnrageAlert.shine = SpellBook_GetAutoCastShine()
		Serenity.F.EnrageAlert.shine:Show()
		Serenity.F.EnrageAlert.shine:SetParent(Serenity.F.EnrageAlert)
		Serenity.F.EnrageAlert.shine:SetSize(Serenity.db.profile.frames.enrage.iconsize + 3, Serenity.db.profile.frames.enrage.iconsize + 3)
		Serenity.F.EnrageAlert.shine:SetPoint("CENTER", Serenity.F.EnrageAlert, "CENTER")
		
		-- Create the Background and border if the user wants one
		Serenity.F.EnrageAlert.background = Serenity.MakeBackground(Serenity.F.EnrageAlert, Serenity.db.profile.frames.enrage)

		Serenity.F.EnrageAlert:SetAlpha(0)
		Serenity.F.EnrageAlert:Show()
		
		Serenity.RegisterMovableFrame(
			"MOVER_ENRAGEALERT",
			Serenity.F.EnrageAlert,
			Serenity.F.EnrageAlert,
			Serenity.L["Enrage Alert"],
			Serenity.db.profile.enrage,
			Serenity.SetupEnrageModule,
			Serenity.V["defaults"].profile.enrage,
			Serenity.db.profile.frames.enrage
		)
		
		Serenity.F.EnrageAlert.updateTimer = 0
		Serenity.F.EnrageAlert:SetScript("OnUpdate", function(self, elapsed)

			self.updateTimer = self.updateTimer + elapsed
		
			if self.updateTimer <= ENRAGE_UPDATEINTERVAL then return else self.updateTimer = 0 end
		
			if not Serenity.V["MoversLocked"] then return end

			if (not UnitExists("target")) or (UnitExists("target") and UnitIsFriend("player", "target")) or UnitIsDeadOrGhost("player") then
				AutoCastShine_AutoCastStop(self.shine)
				self:SetAlpha(0)
				self.amShowing = nil
				return
			else
				local x
				for x=1,#enrageAlerts do
					if UnitAura("target", GetSpellInfo(enrageAlerts[x]), nil, "HELPFUL") then
						if not self.amShowing then
							AutoCastShine_AutoCastStart(self.shine)
							self:SetAlpha(1)
							if Serenity.db.profile.enrage.enablesound then
								PlaySoundFile(Serenity.GetLibSharedMedia3():Fetch("sound", Serenity.db.profile.enrage.sound), Serenity.db.profile.masteraudio and "Master" or nil)
							end
							self.amShowing = true
							return
						else
							return
						end
					end
				end
			end
			self:SetAlpha(0)
			self.amShowing = nil
		end)
	end

	if ((not lockName) or (lockName == "MOVER_ENRAGEREMOVABLES")) then
		-- Notification setup
		if Serenity.db.profile.enrage.removednotify == true then
			Serenity.F.EnrageAlert:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
			Serenity.F.EnrageAlert:SetScript("OnEvent", function(self, event, ...)
				-- 4.1 local timeStamp, subEvent, hideCaster, sourceGUID, sourceName, sourceFlags, destGUID, destName, destFlags, spellId, spellName, spellSchool, extraSpellID, extraSpellName, extraSchool, auraType = ...
				-- 4.2 local timeStamp, subEvent, hideCaster, sourceGUID, sourceName, sourceFlags, sourceFlags2, destGUID, destName, destFlags, destFlags2, spellId, spellName, spellSchool, extraSpellID, extraSpellName, extraSchool, auraType = ...

				local subEvent, sourceGUID, destGUID, destName, spellId, spellName, extraSpellID, extraSpellName
				if (Serenity.V.wowBuild >= 40200) then -- 4.2 patch ready
					_, subEvent, _, sourceGUID, _, _, _, destGUID, destName, _, _, spellId, spellName, _, extraSpellID, extraSpellName = ...
				else -- 4.1
					_, subEvent, _, sourceGUID, _, _, destGUID, destName, _, spellId, spellName, _, extraSpellID, extraSpellName = ...
				end			
				if (subEvent == "SPELL_DISPEL") and (sourceGUID == UnitGUID("player")) and (destGUID ~= UnitGUID("pet")) then
					if Serenity.GetChatChan(Serenity.db.profile.enrage[strlower(Serenity.GetGroupType()).."chan"]) ~= "NONE" then
						--[[if UnitIsPlayer(destName) and UnitClass(destName) then
							destName = Serenity.RGBToHex(unpack(Serenity.V["classcolors"][select(2, UnitClass(destName))])) .. destName .. "\124r"
						end]] -- Can't color this way in SendChatMessage.... I'll touch back later.
						SendChatMessage("\124cff71d5ff|Hspell:" .. spellId .. "\124h[" .. spellName .. "]\124h\124r" .. Serenity.L["ENRAGEREMOVED"] .. "\124cff71d5ff\124Hspell:" .. extraSpellID .. "\124h[" .. extraSpellName .. "]\124h\124r"
							.. Serenity.L["ENRAGEREMOVEDFROM"] .. destName .. ".", Serenity.GetChatChan(Serenity.db.profile.enrage[strlower(Serenity.GetGroupType()).."chan"]), nil, GetUnitName("player"))
					end
				end
			end)
		end

		-- Removables setup
		if not Serenity.db.profile.enrage.enableremovables then return end
		
		Serenity.F.EnrageAlertRemovables = Serenity.MakeFrame("Frame", "SERENITY_ENRAGEALERT_REMOVABLES", Serenity.db.profile.enrage.anchor_removables[2] or UIParent)
		Serenity.F.EnrageAlertRemovables:SetSize(50,50) -- Temp size, we'll re-set this after we create the buff frames to get proper offsets
		Serenity.F.EnrageAlertRemovables:SetPoint(Serenity.GetActiveAnchor(Serenity.db.profile.enrage.anchor_removables))

		Serenity.F.EnrageAlertRemovables.buffFrames = {}
		
		local i
		for i=1,40 do
			Serenity.F.EnrageAlertRemovables.buffFrames[i] = Serenity.MakeFrame("Frame", nil, Serenity.F.EnrageAlertRemovables)
			Serenity.F.EnrageAlertRemovables.buffFrames[i]:SetSize(Serenity.db.profile.frames.enrage.iconsizeremovables, Serenity.db.profile.frames.enrage.iconsizeremovables)		
			Serenity.F.EnrageAlertRemovables.buffFrames[i]:SetPoint("CENTER", Serenity.F.EnrageAlertRemovables, "CENTER") -- Temporary

			Serenity.F.EnrageAlertRemovables.buffFrames[i].Icon = Serenity.F.EnrageAlertRemovables.buffFrames[i]:CreateTexture(nil, "BACKGROUND")
			Serenity.F.EnrageAlertRemovables.buffFrames[i].Icon:SetAllPoints(Serenity.F.EnrageAlertRemovables.buffFrames[i])
			Serenity.F.EnrageAlertRemovables.buffFrames[i].Icon:SetTexture("Interface\Icons\Spell_Nature_Drowsy") -- Temporary
			if Serenity.db.profile.frames.enrage.removablesenabletexcoords then
				Serenity.F.EnrageAlert.Icon:SetTexCoord(unpack(Serenity.db.profile.frames.enrage.removablestexcoords))
			end

			Serenity.F.EnrageAlertRemovables.buffFrames[i].background = Serenity.MakeBackground(Serenity.F.EnrageAlertRemovables.buffFrames[i], Serenity.db.profile.frames.enrage, "removables")
			
			Serenity.F.EnrageAlertRemovables.buffFrames[i]:ClearAllPoints() -- Now that we made the backdrop/border we have offsets to use.

			-- Flip expanding left to right or right to left depending on anchor point X
			local xPos = ((Serenity.db.profile.frames.enrage.iconsizeremovables +
						(Serenity.GetFrameOffset(Serenity.F.EnrageAlertRemovables.buffFrames[i], "LEFT", 1) + Serenity.GetFrameOffset(Serenity.F.EnrageAlertRemovables.buffFrames[i], "RIGHT", 1) + 2))
							* mod(i-1, 8))
			
			local yPos = (Serenity.db.profile.frames.enrage.iconsizeremovables +  -- Vertical Offset
						(Serenity.GetFrameOffset(Serenity.F.EnrageAlertRemovables.buffFrames[i], "TOP", 1) + Serenity.GetFrameOffset(Serenity.F.EnrageAlertRemovables.buffFrames[i], "BOTTOM", 1) + 2))
							* floor((i-1) / 8)

			if Serenity.db.profile.enrage.anchor_removables[4] >= 0 then
				Serenity.F.EnrageAlertRemovables.buffFrames[i]:SetPoint("TOPLEFT", Serenity.F.EnrageAlertRemovables, "TOPLEFT", xPos, -yPos)
			else
				Serenity.F.EnrageAlertRemovables.buffFrames[i]:SetPoint("TOPRIGHT", Serenity.F.EnrageAlertRemovables, "TOPRIGHT", -xPos, -yPos)
			end
							
			Serenity.F.EnrageAlertRemovables.buffFrames[i]:SetAlpha(1)
			Serenity.F.EnrageAlertRemovables.buffFrames[i]:Hide()
			Serenity.F.EnrageAlertRemovables.buffFrames[i].spellID = 0
			
			if Serenity.db.profile.enrage.removablestips then
				Serenity.F.EnrageAlertRemovables.buffFrames[i]:SetScript("OnEnter", function(self)
					if (self.spellID == 0) then return end
					local index
					for index=1,40 do
						if (select(11, UnitBuff("target", index)) == self.spellID) then
							GameTooltip:SetOwner(self)
							GameTooltip:SetUnitBuff("target", index)
							GameTooltip:Show()
							return
						end
					end
				end)
				Serenity.F.EnrageAlertRemovables.buffFrames[i]:SetScript("OnLeave", function(self)
					if self.spellID == 0 then return end
					GameTooltip:Hide()
				end)
			end
		end
		
		-- Now we can properly set the size of the parent frame for the buff icons because we now have offsets.
		Serenity.F.EnrageAlertRemovables:SetSize(		
			((Serenity.db.profile.frames.enrage.iconsizeremovables + -- WIDTH
				(Serenity.GetFrameOffset(Serenity.F.EnrageAlertRemovables.buffFrames[1], "LEFT", 1) + Serenity.GetFrameOffset(Serenity.F.EnrageAlertRemovables.buffFrames[1], "RIGHT", 1) + 2)) * 8) 
				- Serenity.GetFrameOffset(Serenity.F.EnrageAlertRemovables.buffFrames[1], "LEFT", 1) - Serenity.GetFrameOffset(Serenity.F.EnrageAlertRemovables.buffFrames[1], "RIGHT", 1) - 2,
			((Serenity.db.profile.frames.enrage.iconsizeremovables + -- HEIGHT
				(Serenity.GetFrameOffset(Serenity.F.EnrageAlertRemovables.buffFrames[1], "TOP", 1) + Serenity.GetFrameOffset(Serenity.F.EnrageAlertRemovables.buffFrames[1], "BOTTOM", 1) + 2)) * 5) 
				- Serenity.GetFrameOffset(Serenity.F.EnrageAlertRemovables.buffFrames[1], "LEFT", 1) - Serenity.GetFrameOffset(Serenity.F.EnrageAlertRemovables.buffFrames[1], "RIGHT", 1) - 2)

		-- Register the mover frame
		Serenity.RegisterMovableFrame(
			"MOVER_ENRAGEREMOVABLES",
			Serenity.F.EnrageAlertRemovables,
			Serenity.F.EnrageAlertRemovables,
			Serenity.L["Enrage Alert Removable Buffs"],
			Serenity.db.profile.enrage,
			Serenity.SetupEnrageModule,
			Serenity.V["defaults"].profile["enrage"],
			Serenity.db.profile.frames.enrage,
			"_removables"
		)
		
		Serenity.F.EnrageAlertRemovables.updateTimer = 0
		Serenity.F.EnrageAlertRemovables:SetScript("OnUpdate", function(self, elapsed, ...)
		
			self.updateTimer = self.updateTimer + elapsed		
			if self.updateTimer < ENRAGE_UPDATEINTERVAL then return else self.updateTimer = 0 end
			
			local i
			if (not UnitCanAttack("player", "target")) or (Serenity.db.profile.frames.enrage.removablespvponly and (Serenity.GetGroupType() ~= "ARENA") and (Serenity.GetGroupType() ~= "BATTLEGROUND")) then
				for i=1,40 do
					Serenity.F.EnrageAlertRemovables.buffFrames[i].spellID = 0
					Serenity.F.EnrageAlertRemovables.buffFrames[i]:Hide()
				end			
			else
				local j = 1
				for i=1,40 do			
					local name, rank, icon, count, debuffType, duration, expirationTime, unitCaster, isStealable, shouldConsolidate, spellId  = UnitBuff("target", i)
					if debuffType == "Magic" then
						Serenity.F.EnrageAlertRemovables.buffFrames[j].spellID = spellId
						Serenity.F.EnrageAlertRemovables.buffFrames[j].Icon:SetTexture(select(3, GetSpellInfo(spellId)))--"Interface\\Icons\\Spell_Nature_Drowsy")
						if Serenity.db.profile.frames.enrage.removablesenabletexcoords then
							Serenity.F.EnrageAlert.Icon:SetTexCoord(unpack(Serenity.db.profile.frames.enrage.removablestexcoords))
						end
						Serenity.F.EnrageAlertRemovables.buffFrames[j]:Show()
						j = j + 1
					end
				end			
				for i=j,40 do
					Serenity.F.EnrageAlertRemovables.buffFrames[i]:Hide()
					Serenity.F.EnrageAlertRemovables.buffFrames[i].spellID = 0
				end
			end
		end)
	end
end
