--[[

	Icons module
	
]]

if not Serenity then return end

local function SetupIcons(parent, blocksName)

	local ICON_UPDATEINTERVAL = 0.05
	
	parent.Icons = {}
	
	local index = 1
	local i
	for i=1,#Serenity.db.profile.icons[blocksName].icons do
	
		if (Serenity.db.profile.icons[blocksName].icons[i][6] == 0) or (Serenity.db.profile.icons[blocksName].icons[i][6] == GetPrimaryTalentTree()) then -- Talent tree check

			parent.Icons[index] = Serenity.MakeFrame("Frame", nil, parent)
			parent.Icons[index]:SetAlpha(0) -- Don't want it to show on the UI when being constructed.
			parent.Icons[index]:SetSize(Serenity.db.profile.frames.icons[blocksName].iconsize, Serenity.db.profile.frames.icons[blocksName].iconsize)
			
			-- The icon and backdrop / border need a parent frame nested inside the top level icon frame for animations.			
			parent.Icons[index].agparent = CreateFrame("Frame", nil, parent.Icons[index])
			parent.Icons[index].agparent:SetAllPoints(parent.Icons[index])
			
			parent.Icons[index].agparent.Icon = parent.Icons[index].agparent:CreateTexture(nil, "BACKGROUND")
			
			if (Serenity.db.profile.icons[blocksName].icons[i][1]) then -- Spell
				local _, _, icon = GetSpellInfo(tonumber(Serenity.db.profile.icons[blocksName].icons[i][1]) or Serenity.db.profile.icons[blocksName].icons[i][1])
				parent.Icons[index].agparent.Icon:SetTexture(icon or "Interface\\ICONS\\INV_Misc_QuestionMark")
			else
				local _, _, _, _, _, _, _, _, _, itemTexture = GetItemInfo(tonumber(Serenity.db.profile.icons[blocksName].icons[i][2]) or Serenity.db.profile.icons[blocksName].icons[i][2])
				parent.Icons[index].agparent.Icon:SetTexture(itemTexture or "Interface\\ICONS\\INV_Misc_QuestionMark")
			end

			if Serenity.db.profile.frames.icons[blocksName].enabletexcoords then
				parent.Icons[index].agparent.Icon:SetTexCoord(unpack(Serenity.db.profile.frames.icons[blocksName].texcoords))
			end
			parent.Icons[index].agparent.Icon:SetAllPoints(parent.Icons[index].agparent)

			-- Create the Background and border if the user wants one (Parented to the Icon, to account for spin)
			parent.Icons[index].agparent.gapOffsets = Serenity.DeepCopy(parent.Icons[index].gapOffsets)
			parent.Icons[index].agparent.background = Serenity.MakeBackground(parent.Icons[index].agparent, Serenity.db.profile.frames.icons[blocksName], "icon")

			-- Manually adjust offsets because we parented to a sub-frame.
			parent.Icons[index].gapOffsets = Serenity.DeepCopy(parent.Icons[index].agparent.gapOffsets)

			-- Handle orientation
			if Serenity.db.profile.icons[blocksName].layout == "horizontal" then -- Horizontal			
				if not Serenity.db.profile.icons[blocksName].reverse then -- Normal direction				
					parent.Icons[index]:SetPoint("LEFT", parent, "LEFT", 
					-- WIDTH
					(((Serenity.db.profile.frames.icons[blocksName].iconsize + (Serenity.GetFrameOffset(parent.Icons[index], "LEFT", 1) + Serenity.GetFrameOffset(parent.Icons[index], "RIGHT", 1) + 2))
						* (index - 1))
						+ Serenity.GetFrameOffset(parent.Icons[index], "LEFT", 1))
					-- HEIGHT
					, 0)
				else -- Reversed direction				
					parent.Icons[index]:SetPoint("RIGHT", parent, "RIGHT",
					-- WIDTH
					-(((Serenity.db.profile.frames.icons[blocksName].iconsize + (Serenity.GetFrameOffset(parent.Icons[index], "LEFT", 1) + Serenity.GetFrameOffset(parent.Icons[index], "RIGHT", 1) + 2))
						* (index - 1))
						+ Serenity.GetFrameOffset(parent.Icons[index], "RIGHT", 1))
					-- HEIGHT
					, 0)
				end
			else -- Vertical			
				if Serenity.db.profile.icons[blocksName].reverse then -- Reversed direction				
					parent.Icons[index]:SetPoint("TOP", parent, "TOP", 
					-- WIDTH
					0,
					-- HEIGHT
					-(((Serenity.db.profile.frames.icons[blocksName].iconsize + (Serenity.GetFrameOffset(parent.Icons[index], "TOP", 1) + Serenity.GetFrameOffset(parent.Icons[index], "BOTTOM", 1) + 2))
						* (index - 1))
						+ Serenity.GetFrameOffset(parent.Icons[index], "TOP", 1))
					)					
				else -- Normal direction				
					parent.Icons[index]:SetPoint("BOTTOM", parent, "BOTTOM",
					-- WIDTH
					0,
					-- HEIGHT
					(((Serenity.db.profile.frames.icons[blocksName].iconsize + (Serenity.GetFrameOffset(parent.Icons[index], "TOP", 1) + Serenity.GetFrameOffset(parent.Icons[index], "BOTTOM", 1) + 2))
						* (index - 1))
						+ Serenity.GetFrameOffset(parent.Icons[index], "BOTTOM", 1))
					)
				end			
			end
			
			-- Setup the timer font if needed
			if Serenity.db.profile.icons[blocksName].icons[i][7] ~= "NONE" then
			
				parent.Icons[index].fntparent = CreateFrame("Frame", nil, parent.Icons[index])
				parent.Icons[index].fntparent:SetAllPoints(parent.Icons[index])
				parent.Icons[index].fntparent.value = parent.Icons[index].fntparent:CreateFontString(nil, "OVERLAY")
				
				-- Anchor the font according to specified position
				if Serenity.db.profile.icons[blocksName].icons[i][7] == "TOP" then
				
					parent.Icons[index].fntparent.value:SetJustifyH("CENTER")
					parent.Icons[index].fntparent.value:SetJustifyV("BOTTOM")
					parent.Icons[index].fntparent.value:SetPoint("BOTTOM", parent.Icons[index], "TOP", 0, (1) + Serenity.GetFrameOffset(parent.Icons[index], "TOP"))
				
				elseif Serenity.db.profile.icons[blocksName].icons[i][7] == "BOTTOM" then
				
					parent.Icons[index].fntparent.value:SetJustifyH("CENTER")
					parent.Icons[index].fntparent.value:SetJustifyV("TOP")
					parent.Icons[index].fntparent.value:SetPoint("TOP", parent.Icons[index], "BOTTOM", 0, (-1) + Serenity.GetFrameOffset(parent.Icons[index], "BOTTOM"))
				
				elseif Serenity.db.profile.icons[blocksName].icons[i][7] == "LEFT" then
				
					parent.Icons[index].fntparent.value:SetJustifyH("RIGHT")
					parent.Icons[index].fntparent.value:SetJustifyV("CENTER")
					parent.Icons[index].fntparent.value:SetPoint("RIGHT", parent.Icons[index], "LEFT", (-1) + Serenity.GetFrameOffset(parent.Icons[index], "LEFT"), 0)
				
				elseif Serenity.db.profile.icons[blocksName].icons[i][7] == "RIGHT" then
				
					parent.Icons[index].fntparent.value:SetJustifyH("LEFT")
					parent.Icons[index].fntparent.value:SetJustifyV("CENTER")
					parent.Icons[index].fntparent.value:SetPoint("LEFT", parent.Icons[index], "RIGHT", (1) + Serenity.GetFrameOffset(parent.Icons[index], "RIGHT"), 0)
				
				else -- CENTER
				
					parent.Icons[index].fntparent.value:SetJustifyH("CENTER")
					parent.Icons[index].fntparent.value:SetJustifyV("CENTER")
					parent.Icons[index].fntparent.value:SetPoint("CENTER", parent.Icons[index], "CENTER", 0, 0)				
				end
				
				parent.Icons[index].fntparent.value:SetFont(Serenity.GetActiveFont(Serenity.db.profile.frames.icons[blocksName].timefont))
				if Serenity.db.profile.frames.icons[blocksName].timerfontcolorstatic then
					parent.Icons[index].fntparent.value:SetTextColor(unpack(Serenity.db.profile.frames.icons[blocksName].timerfontcolor))
				end
				
				if Serenity.db.profile.frames.icons[blocksName].enabletimershadow then
					parent.Icons[index].fntparent.value:SetShadowColor(unpack(Serenity.db.profile.frames.icons[blocksName].timershadowcolor))
					parent.Icons[index].fntparent.value:SetShadowOffset(unpack(Serenity.db.profile.frames.icons[blocksName].timershadowoffset))
				end
				
				parent.Icons[index].fntparent.value:SetText("")
				parent.Icons[index].fntparent.value:SetAlpha(1)
			end
			
			parent.Icons[index].stacksparent = CreateFrame("Frame", nil, parent.Icons[index])
			parent.Icons[index].stacksparent:SetAllPoints(parent.Icons[index])
			parent.Icons[index].stacksparent.stacks = parent.Icons[index].stacksparent:CreateFontString(nil, "OVERLAY")			
			parent.Icons[index].stacksparent.stacks:SetJustifyH("RIGHT")
			parent.Icons[index].stacksparent.stacks:SetJustifyV("BOTTOM")
			parent.Icons[index].stacksparent.stacks:SetPoint("BOTTOMRIGHT", parent.Icons[index], "BOTTOMRIGHT", -3, 1)
			parent.Icons[index].stacksparent.stacks:SetFont(Serenity.GetActiveFont(Serenity.db.profile.frames.icons[blocksName].stackfont))
			parent.Icons[index].stacksparent.stacks:SetTextColor(unpack(Serenity.db.profile.frames.icons[blocksName].stackfontcolor), 1)
			parent.Icons[index].stacksparent.stacks:SetText("")
			parent.Icons[index].stacksparent.stacks:SetAlpha(1)
					
			parent.inActionFlags[index] = 0
			
			-- Script to control this individual icon
			parent.Icons[index].myIndex = index
			parent.Icons[index].updateTimer = 0
			--parent.Icons[index].myOrientation = Serenity.db.profile.icons[blocksName].layout
			--parent.Icons[index].myReverse = Serenity.db.profile.icons[blocksName].reverse
			--parent.Icons[index].myBaseSize = Serenity.db.profile.frames.icons[blocksName].iconsize
			--parent.Icons[index].myCurrentSize = Serenity.db.profile.frames.icons[blocksName].iconsize
			parent.Icons[index].iconTable = Serenity.db.profile.icons[blocksName].icons[i]
			--parent.Icons[index].myPoints = {parent.Icons[index]:GetPoint()}
			parent.Icons[index]:SetScript("OnUpdate", function(self, elapsed)
			
					self.updateTimer = self.updateTimer + elapsed				
					if self.updateTimer < ICON_UPDATEINTERVAL then return else self.updateTimer = 0 end

					if self.agparent.Icon:GetTexture() == "Interface\\ICONS\\INV_Misc_QuestionMark" then
						if (self.iconTable[1]) then -- Spell
							local _, _, icon = GetSpellInfo(tonumber(self.iconTable[1]) or self.iconTable[1])
							if icon then self.agparent.Icon:SetTexture(icon) end
						else
							local _, _, _, _, _, _, _, _, _, itemTexture = GetItemInfo(tonumber(self.iconTable[2]) or self.iconTable[2])
							if itemTexture then self.agparent.Icon:SetTexture(itemTexture) end
						end
					end
					
					local texture, duration, remaining, stacks = 
						Serenity.GetTimerInfo(self.iconTable[1], self.iconTable[2], self.iconTable[3], self.iconTable[4], self.iconTable[5])

					if texture and (not UnitIsDeadOrGhost("player")) then

						if self.iconTable[8] and (not self.flashTime) then
							self.flashTime = ((duration * .25) < 10) and (duration * .25) or 10
							self.flashChangeTime = .4
							self.flashCycles = ceil(self.flashTime / self.flashChangeTime)
							self.flashDown = true
						end
					
						if (not (self:GetParent().inActionFlags[self.myIndex] == 1)) or (self.isFlashing and (remaining > self.flashTime)) then
						
							if self.isFlashing then
								self.isFlashing = nil
								self.agparent:SetAlpha(1)
							end
						
							self:GetParent().inActionFlags[self.myIndex] = 1
							
							if self.iconTable[13] then 
								self.agparent:SetAlpha(self.iconTable[14])
							else
								self.agparent:SetAlpha(1)
							end
						end

						--[[self:ClearAllPoints()
						self:SetPoint(self.myPoints[1], self.myPoints[2], self.myPoints[3],
							(self.myOrientation == "horizontal") and GetTimerPos(self, self.myOrientation, self.myReverse, remaining, duration) or 0,
							(self.myOrientation == "vertical") and GetTimerPos(self, self.myOrientation, self.myReverse, remaining, duration) or 0)]]			

						-- Handle flashing.
						if self.iconTable[8] and (remaining <= self.flashTime) then
							if (not self.isFlashing) then
								self.isFlashing = true
							else
								local rt = (self.flashTime - remaining)
								self.flashDown = (mod(ceil(rt / self.flashChangeTime), 2) == 0) and true or nil
								local rct = mod(rt, self.flashChangeTime)
								self.agparent:SetAlpha(	self.flashDown and (((self.flashChangeTime / 1) * rct) * 10) or (1 - (((self.flashChangeTime / 1) * rct) * 10))	)
							end
						end
						
						-- Handle Alpha ramp up or down	
						if self.iconTable[13] and (not self.isFlashing) then
							self.agparent:SetAlpha(((self.iconTable[15] - self.iconTable[14]) - ((self.iconTable[15] - self.iconTable[14]) * (remaining / duration))) + self.iconTable[14]) 
						end
							
						-- Handle Growth
						--[[if self.iconTable[10] and (remaining <= (duration * self.iconTable[11])) then
							local newSize = ((self.iconTable[12] - 1) * (1 - (remaining / (duration * self.iconTable[11])))) * self.myBaseSize + self.myBaseSize
							if newSize ~= self.myCurrentSize then
								self.myCurrentSize = newSize
								self:SetSize(newSize, newSize)
							end
						elseif self.iconTable[10] and (self.myCurrentSize ~= self.myBaseSize) then
							self:SetSize(self.myBaseSize, self.myBaseSize)
						end]]
						
						-- Handle Animation
						--[[if self.iconTable[9] then
							local spinTime = ((duration * .25) < 5) and (duration * .25) or 5
							
							if (not self.ag) and remaining <= spinTime then							
								self.ag = self.agparent.Icon:CreateAnimationGroup()
								self.ag.spin = self.ag:CreateAnimation("Rotation")
								self.ag.spin:SetDuration(remaining - .1)
								self.ag.spin:SetDegrees(360)
								self.ag.spin:SetOrder(1)
								self.ag:Play()
								
							elseif self.ag and (remaining > spinTime) then							
								self.ag:Stop()
								self.ag = nil
							end
						end]]
						
						if not (self.iconTable[7] == "NONE") then
							self.fntparent.value:SetText(((duration <= 1.5) or (remaining < .1)) and "" or (Serenity.FormatTimeText(remaining, (remaining <= Serenity.db.profile.minfortenths) and true or false, not (Serenity.db.profile.frames.icons[blocksName].timerfontcolorstatic))))
						end
						self.stacksparent.stacks:SetText((stacks > 1) and tostring(stacks) or "")

					elseif (self:GetParent().inActionFlags[self.myIndex] == 1) then

						if self.isFlashing then
							self.isFlashing = nil
							self.agparent:SetAlpha(1)
						end
						
						--[[if self.ag then
							self.ag:Stop()
							self.ag = nil
						end]]
						
						if not (self.iconTable[7] == "NONE") or (remaining < .1) then
							self.fntparent.value:SetText("")
						end
						self.stacksparent.stacks:SetText("")
						self.agparent:SetAlpha(1)
						self:GetParent().inActionFlags[self.myIndex] = 0
					end
				end)
			parent.Icons[index]:SetAlpha(1)
			parent.Icons[index]:Show()
			index = index + 1
		end
	end
end

function Serenity.SetupIconsModule()

	if not Serenity.F.IconBlocks then Serenity.F.IconBlocks = {} end

	-- Destruction
	local i
	for i=1,#Serenity.F.IconBlocks do
		Serenity.F.IconBlocks[i]:Hide()
		Serenity.DeregisterMovableFrame("MOVER_ICONSET_"..Serenity.F.IconBlocks[i]:GetName())
		Serenity.F.IconBlocks[i]:SetParent(nil)
		Serenity.F.IconBlocks[i] = nil
	end

	-- Construction
	local ICONBLOCK_UPDATEINTERVAL = 0.125
	local key,val
	local index = 1
	for key,val in pairs(Serenity.db.profile.icons) do

		if Serenity.db.profile.icons[key].enabled and (#Serenity.db.profile.icons[key].icons > 0) then
	
			-- Create the Set Frame
			Serenity.F.IconBlocks[index] = Serenity.MakeFrame("Frame", "SERENITY_ICONBLOCK_"..key, Serenity.db.profile.icons[key].anchor[2] or UIParent)
			Serenity.F.IconBlocks[index]:SetSize(Serenity.db.profile.frames.icons[key].iconsize * (#Serenity.db.profile.icons[key].icons), Serenity.db.profile.frames.icons[key].iconsize) -- temporary size - need to fix it later.
			Serenity.F.IconBlocks[index]:SetPoint(Serenity.GetActiveAnchor(Serenity.db.profile.icons[key].anchor))
			Serenity.F.IconBlocks[index]:SetAlpha(0)
			
			-- Create the Background and border if the user wants one
			Serenity.F.IconBlocks[index].background = Serenity.MakeBackground(Serenity.F.IconBlocks[index], Serenity.db.profile.frames.icons[key])

			Serenity.RegisterMovableFrame(
				"MOVER_ICONSET_"..Serenity.F.IconBlocks[index]:GetName(),
				Serenity.F.IconBlocks[#Serenity.F.IconBlocks],
				Serenity.F.IconBlocks[#Serenity.F.IconBlocks],
				key,
				Serenity.db.profile.icons[key],
				index == 1 and Serenity.SetupIconsModule or nil, -- last one gets the setup function (below)
				Serenity.V["iconblock_defaults"],
				Serenity.db.profile.frames.icons[key]
			)
			
			-- Setup the script for handling the Icon Block
			Serenity.F.IconBlocks[index].inActionFlags = {}
			Serenity.F.IconBlocks[index].updateTimer = 0
			
			-- Setup the actual icons for the set before the set script
			SetupIcons(Serenity.F.IconBlocks[index], key)
			
			-- Now we can set a proper block frame size
			Serenity.F.IconBlocks[index]:SetSize(		
			((Serenity.db.profile.frames.icons[key].iconsize + -- WIDTH
				(Serenity.GetFrameOffset(Serenity.F.IconBlocks[index].Icons[1], "LEFT", 1) + Serenity.GetFrameOffset(Serenity.F.IconBlocks[index].Icons[1], "RIGHT", 1) + 2))
				* ((Serenity.db.profile.icons[key].layout == "vertical") and 1 or #Serenity.db.profile.icons[key].icons)) - 2,
--				- Serenity.GetFrameOffset(Serenity.F.IconBlocks[index].icons[1], "LEFT", 1) - Serenity.GetFrameOffset(Serenity.F.IconBlocks[index].icons[1], "RIGHT", 1) - 2,
			((Serenity.db.profile.frames.icons[key].iconsize + -- HEIGHT
				(Serenity.GetFrameOffset(Serenity.F.IconBlocks[index].Icons[1], "TOP", 1) + Serenity.GetFrameOffset(Serenity.F.IconBlocks[index].Icons[1], "BOTTOM", 1) + 2))
				* ((Serenity.db.profile.icons[key].layout == "horizontal") and 1 or #Serenity.db.profile.icons[key].icons)) - 2)
--				- Serenity.GetFrameOffset(Serenity.F.IconBlocks[index].icons[1], "LEFT", 1) - Serenity.GetFrameOffset(Serenity.F.IconBlocks[index].icons[1], "RIGHT", 1) - 2)
			
			Serenity.F.IconBlocks[index]:SetScript("OnUpdate", function(self, elapsed)
			
				self.updateTimer = self.updateTimer + elapsed
				
				if self.updateTimer < ICONBLOCK_UPDATEINTERVAL then return else self.updateTimer = 0 end
			
				-- Overrides take precidence over normal alpha
				if Serenity.db.profile.icons[key].deadoverride and UnitIsDeadOrGhost("player") then
				
					self:SetAlpha(Serenity.db.profile.icons[key].deadoverridealpha)
					
				elseif Serenity.db.profile.icons[key].mountoverride and (IsMounted() or UnitUsingVehicle("player")) then
				
					self:SetAlpha(Serenity.db.profile.icons[key].mountoverridealpha)
					
				elseif Serenity.db.profile.icons[key].oocoverride and (not InCombatLockdown()) then
				
					self:SetAlpha(Serenity.db.profile.icons[key].oocoverridealpha)
					
				elseif tContains(self.inActionFlags, 1) then -- Icons set their value based on activity.
				
					self:SetAlpha(Serenity.db.profile.icons[key].activealpha)
				
				else
				
					self:SetAlpha(Serenity.db.profile.icons[key].inactivealpha)
				end
			end)			
			
			index = index + 1
		end
	end
end
