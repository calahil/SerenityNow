--[[

	Timers module
	
]]

if not Serenity then return end

local function GetTimerPos(self, orientation, reverse, timeLeft, timeMax)
	
	local timePercent = (timeLeft / timeMax) * 100
	local usableSize = ( (orientation == "horizontal") and self:GetParent():GetWidth() or self:GetParent():GetHeight() ) - self:GetWidth() -- the timer is a square base.
	--[[
		Calculate the amount of extra size if there is a backdrop on the timer itself.
		This is end dependant, meaning the 1st offset is the side the timer moves toward, not from.
	]]
	local backdropOffset1 = 0
	local backdropOffset2 = 0
	if orientation == "horizontal" then
		backdropOffset1 = Serenity.GetFrameOffset(self, reverse and "RIGHT" or "LEFT")
		backdropOffset2 = Serenity.GetFrameOffset(self, reverse and "LEFT" or "RIGHT")
	else
		backdropOffset1 = Serenity.GetFrameOffset(self, reverse and "TOP" or "BOTTOM")
		backdropOffset2 = Serenity.GetFrameOffset(self, reverse and "BOTTOM" or "TOP")
	end

	-- Return the value based on orientation and reverse (make it positive or negative, properly)
	if ((orientation == "horizontal") and (not reverse)) or ((orientation == "vertical") and (not reverse)) then	
		return floor((timePercent * ((usableSize + (backdropOffset1 + backdropOffset2)) / 100) ) - backdropOffset1)
	else
		return floor(-((timePercent * ((usableSize + (backdropOffset1 + backdropOffset2)) / 100) ) - backdropOffset1))
	end	
end

local function SetupTimers(parent, setsName)

	local TIMER_UPDATEINTERVAL = 0.04
	
	parent.Timers = {}
	
	local index = 1
	local i
	for i=1,#Serenity.db.profile.timers[setsName].timers do
	
		if (Serenity.db.profile.timers[setsName].timers[i][6] == 0) or (Serenity.db.profile.timers[setsName].timers[i][6] == GetPrimaryTalentTree()) then -- Talent tree check

			parent.Timers[index] = Serenity.MakeFrame("Frame", nil, parent)
			parent.Timers[index]:SetAlpha(0) -- Don't want it to show on the UI when being constructed.
			parent.Timers[index]:SetSize(Serenity.db.profile.frames.timers[setsName].iconsize, Serenity.db.profile.frames.timers[setsName].iconsize)
			
			-- Handle orientation
			if Serenity.db.profile.timers[setsName].layout == "horizontal" then -- Horizontal
			
				if not Serenity.db.profile.timers[setsName].reverse then -- Normal direction
				
					parent.Timers[index]:SetPoint("LEFT", parent, "LEFT", 0, 0)
					
				else -- Reversed direction
				
					parent.Timers[index]:SetPoint("RIGHT", parent, "RIGHT", 0, 0)
				end
			else -- Vertical
			
				if Serenity.db.profile.timers[setsName].reverse then -- Reversed direction
				
					parent.Timers[index]:SetPoint("TOP", parent, "TOP", 0, 0)
					
				else -- Normal direction
				
					parent.Timers[index]:SetPoint("BOTTOM", parent, "BOTTOM", 0, 0)
				end			
			end

			-- The Icon and backdrop / border need a parent frame nested inside the top level timer frame for animations.			
			parent.Timers[index].agparent = CreateFrame("Frame", nil, parent.Timers[index])
			parent.Timers[index].agparent:SetAllPoints(parent.Timers[index])
			
			parent.Timers[index].agparent.Icon = parent.Timers[index].agparent:CreateTexture(nil, "BACKGROUND")
			parent.Timers[index].agparent.Icon:SetTexture("Interface\\ICONS\\INV_Misc_QuestionMark") -- Just a place-holder, this will change in the timer script.
			if Serenity.db.profile.frames.timers[setsName].enabletexcoords then
				parent.Timers[index].agparent.Icon:SetTexCoord(unpack(Serenity.db.profile.frames.timers[setsName].texcoords))
			end
			parent.Timers[index].agparent.Icon:SetAllPoints(parent.Timers[index].agparent)

			-- Create the Background and border if the user wants one (Parented to the Icon, to account for spin)
			parent.Timers[index].agparent.gapOffsets = Serenity.DeepCopy(parent.Timers[index].gapOffsets)
			parent.Timers[index].agparent.background = Serenity.MakeBackground(parent.Timers[index].agparent, Serenity.db.profile.frames.timers[setsName], "timer")

			-- Manually adjust offsets because we parented to a sub-frame.
			parent.Timers[index].gapOffsets = Serenity.DeepCopy(parent.Timers[index].agparent.gapOffsets)

			-- Setup the timer font if needed
			if Serenity.db.profile.timers[setsName].timers[i][7] ~= "NONE" then
			
				parent.Timers[index].fntparent = CreateFrame("Frame", nil, parent.Timers[index])
				parent.Timers[index].fntparent:SetAllPoints(parent.Timers[index])
				parent.Timers[index].fntparent.value = parent.Timers[index].fntparent:CreateFontString(nil, "OVERLAY")
				
				-- Anchor the font according to specified position
				if Serenity.db.profile.timers[setsName].timers[i][7] == "TOP" then
				
					parent.Timers[index].fntparent.value:SetJustifyH("CENTER")
					parent.Timers[index].fntparent.value:SetJustifyV("BOTTOM")
					parent.Timers[index].fntparent.value:SetPoint("BOTTOM", parent.Timers[index], "TOP", 0, (1) + Serenity.GetFrameOffset(parent.Timers[index], "TOP"))
				
				elseif Serenity.db.profile.timers[setsName].timers[i][7] == "BOTTOM" then
				
					parent.Timers[index].fntparent.value:SetJustifyH("CENTER")
					parent.Timers[index].fntparent.value:SetJustifyV("TOP")
					parent.Timers[index].fntparent.value:SetPoint("TOP", parent.Timers[index], "BOTTOM", 0, (-1) + Serenity.GetFrameOffset(parent.Timers[index], "BOTTOM"))
				
				elseif Serenity.db.profile.timers[setsName].timers[i][7] == "LEFT" then
				
					parent.Timers[index].fntparent.value:SetJustifyH("RIGHT")
					parent.Timers[index].fntparent.value:SetJustifyV("CENTER")
					parent.Timers[index].fntparent.value:SetPoint("RIGHT", parent.Timers[index], "LEFT", (-1) + Serenity.GetFrameOffset(parent.Timers[index], "LEFT"), 0)
				
				elseif Serenity.db.profile.timers[setsName].timers[i][7] == "RIGHT" then
				
					parent.Timers[index].fntparent.value:SetJustifyH("LEFT")
					parent.Timers[index].fntparent.value:SetJustifyV("CENTER")
					parent.Timers[index].fntparent.value:SetPoint("LEFT", parent.Timers[index], "RIGHT", (1) + Serenity.GetFrameOffset(parent.Timers[index], "RIGHT"), 0)
				
				else -- CENTER
				
					parent.Timers[index].fntparent.value:SetJustifyH("CENTER")
					parent.Timers[index].fntparent.value:SetJustifyV("CENTER")
					parent.Timers[index].fntparent.value:SetPoint("CENTER", parent.Timers[index], "CENTER", 0, 0)				
				end
				
				parent.Timers[index].fntparent.value:SetFont(Serenity.GetActiveFont(Serenity.db.profile.frames.timers[setsName].timefont))
				if Serenity.db.profile.frames.timers[setsName].timerfontcolorstatic then
					parent.Timers[index].fntparent.value:SetTextColor(unpack(Serenity.db.profile.frames.timers[setsName].timerfontcolor))
				end
				
				if Serenity.db.profile.frames.timers[setsName].enabletimershadow then
					parent.Timers[index].fntparent.value:SetShadowColor(unpack(Serenity.db.profile.frames.timers[setsName].timershadowcolor))
					parent.Timers[index].fntparent.value:SetShadowOffset(unpack(Serenity.db.profile.frames.timers[setsName].timershadowoffset))
				end
				
				parent.Timers[index].fntparent.value:SetText("")
				parent.Timers[index].fntparent.value:SetAlpha(1)
			end
			
			
			parent.Timers[index].stacksparent = CreateFrame("Frame", nil, parent.Timers[index])
			parent.Timers[index].stacksparent:SetAllPoints(parent.Timers[index])
			parent.Timers[index].stacksparent.stacks = parent.Timers[index].stacksparent:CreateFontString(nil, "OVERLAY")			
			parent.Timers[index].stacksparent.stacks:SetJustifyH("RIGHT")
			parent.Timers[index].stacksparent.stacks:SetJustifyV("BOTTOM")
			parent.Timers[index].stacksparent.stacks:SetPoint("BOTTOMRIGHT", parent.Timers[index], "BOTTOMRIGHT", -3, 1)
			parent.Timers[index].stacksparent.stacks:SetFont(Serenity.GetActiveFont(Serenity.db.profile.frames.timers[setsName].stackfont))
			parent.Timers[index].stacksparent.stacks:SetTextColor(unpack(Serenity.db.profile.frames.timers[setsName].stackfontcolor), 1)
			parent.Timers[index].stacksparent.stacks:SetText("")
			parent.Timers[index].stacksparent.stacks:SetAlpha(1)
					
			parent.inActionFlags[index] = 0
			
			-- Script to control this individual timer
			parent.Timers[index].myIndex = index
			parent.Timers[index].noTexture = true
			parent.Timers[index].updateTimer = 0
			parent.Timers[index].myOrientation = Serenity.db.profile.timers[setsName].layout
			parent.Timers[index].myReverse = Serenity.db.profile.timers[setsName].reverse
			parent.Timers[index].myBaseSize = Serenity.db.profile.frames.timers[setsName].iconsize
			parent.Timers[index].myCurrentSize = Serenity.db.profile.frames.timers[setsName].iconsize
			parent.Timers[index].timerTable = Serenity.db.profile.timers[setsName].timers[i]
			parent.Timers[index].myPoints = {parent.Timers[index]:GetPoint()}
			parent.Timers[index]:SetScript("OnUpdate", function(self, elapsed)

					self.updateTimer = self.updateTimer + elapsed				
					if self.updateTimer < TIMER_UPDATEINTERVAL then return else self.updateTimer = 0 end				

					local texture, duration, remaining, stacks = 
						Serenity.GetTimerInfo(self.timerTable[1], self.timerTable[2], self.timerTable[3], self.timerTable[4], self.timerTable[5])

					if texture and (not UnitIsDeadOrGhost("player")) then

						if self.timerTable[8] and (not self.flashTime) then
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
						
							if self.noTexture then
								self.agparent.Icon:SetTexture(texture)
								self.noTexture = nil
							end

							self:GetParent().inActionFlags[self.myIndex] = 1
							
							if self.timerTable[13] then 
								self:SetAlpha(self.timerTable[14])
							else
								self:SetAlpha(1)
							end
						end

						self:ClearAllPoints()
						self:SetPoint(self.myPoints[1], self.myPoints[2], self.myPoints[3],
							(self.myOrientation == "horizontal") and GetTimerPos(self, self.myOrientation, self.myReverse, remaining, duration) or 0,
							(self.myOrientation == "vertical") and GetTimerPos(self, self.myOrientation, self.myReverse, remaining, duration) or 0)						

						-- Handle flashing.
						if self.timerTable[8] and (remaining <= self.flashTime) then
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
						if self.timerTable[13] and (not self.isFlashing) then
							self:SetAlpha(((self.timerTable[15] - self.timerTable[14]) - ((self.timerTable[15] - self.timerTable[14]) * (remaining / duration))) + self.timerTable[14]) 
						end
							
						-- Handle Growth
						if self.timerTable[10] and (remaining <= (duration * self.timerTable[11])) then
							local newSize = ((self.timerTable[12] - 1) * (1 - (remaining / (duration * self.timerTable[11])))) * self.myBaseSize + self.myBaseSize
							if newSize ~= self.myCurrentSize then
								self.myCurrentSize = newSize
								self:SetSize(newSize, newSize)
							end
						elseif self.timerTable[10] and (self.myCurrentSize ~= self.myBaseSize) then
							self:SetSize(self.myBaseSize, self.myBaseSize)
						end
						
						-- Handle Animation
						if self.timerTable[9] then
							local spinTime = ((duration * .25) < 5) and (duration * .25) or 5
							
							if (remaining <= spinTime) then
								if (not self.ag) then
									self.ag = self.agparent.Icon:CreateAnimationGroup()
									self.ag.spin = self.ag:CreateAnimation("Rotation")
								end
								self.ag.spin:SetDuration(remaining - .1)
								self.ag.spin:SetDegrees(360)
								self.ag.spin:SetOrder(1)
								self.ag:Play()
								
							elseif self.ag and (remaining > spinTime) then							
								self.ag:Stop()
							end
						end
						
						if not (self.timerTable[7] == "NONE") then
							self.fntparent.value:SetText(Serenity.FormatTimeText(remaining, (remaining <= Serenity.db.profile.minfortenths) and true or false, not (Serenity.db.profile.frames.timers[setsName].timerfontcolorstatic)))
						end
						self.stacksparent.stacks:SetText((stacks > 1) and tostring(stacks) or "")

					elseif (self:GetParent().inActionFlags[self.myIndex] == 1) then

						if self.isFlashing then
							self.isFlashing = nil
							self.agparent:SetAlpha(1)
						end
						
						if self.ag then
							self.ag:Stop()
							self.ag = nil
						end
						
						if not (self.timerTable[7] == "NONE") then
							self.fntparent.value:SetText("")
						end
						self.stacksparent.stacks:SetText("")
						self:SetAlpha(0)
						self:GetParent().inActionFlags[self.myIndex] = 0
					end
				end)
			
			parent.Timers[index]:Show()
			index = index + 1
		end
	end
end

function Serenity.SetupTimersModule()

	if not Serenity.F.TimerSets then Serenity.F.TimerSets = {} end

	-- Destruction	
	local i = 1
	if Serenity.F.TimerSets then
		while Serenity.F.TimerSets[i] ~= nil do
			Serenity.F.TimerSets[i]:Hide()
			Serenity.DeregisterMovableFrame("MOVER_TIMERSET_"..Serenity.F.TimerSets[i]:GetName())
			Serenity.F.TimerSets[i]:SetParent(nil)
			Serenity.F.TimerSets[i] = nil
			i = i + 1
		end
	end

	-- Construction
	local TIMERSET_UPDATEINTERVAL = 0.125
	local key,val
	local index = 1
	for key,val in pairs(Serenity.db.profile.timers) do

		if Serenity.db.profile.timers[key].enabled and (#Serenity.db.profile.timers[key].timers > 0) then
	
			-- Create the Set Frame
			Serenity.F.TimerSets[index] = Serenity.MakeFrame("Frame", "SERENITY_TIMERSET_"..key, Serenity.db.profile.timers[key].anchor[2] or UIParent)
			Serenity.F.TimerSets[index]:SetSize(Serenity.db.profile.frames.timers[key].width, Serenity.db.profile.frames.timers[key].height)
			Serenity.F.TimerSets[index]:SetPoint(Serenity.GetActiveAnchor(Serenity.db.profile.timers[key].anchor))
			Serenity.F.TimerSets[index]:SetAlpha(0)
			
			-- Create the Background and border if the user wants one
			Serenity.F.TimerSets[index].background = Serenity.MakeBackground(Serenity.F.TimerSets[index], Serenity.db.profile.frames.timers[key])

			Serenity.RegisterMovableFrame(
				"MOVER_TIMERSET_"..Serenity.F.TimerSets[index]:GetName(),
				Serenity.F.TimerSets[#Serenity.F.TimerSets],
				Serenity.F.TimerSets[#Serenity.F.TimerSets],
				key,
				Serenity.db.profile.timers[key],
				index == 1 and Serenity.SetupTimersModule or nil, -- last one gets the setup function (below)
				Serenity.V["timerset_defaults"],
				Serenity.db.profile.frames.timers[key]
			)
			
			-- Setup the script for handling the Timer Set
			Serenity.F.TimerSets[index].inActionFlags = {}
			Serenity.F.TimerSets[index].updateTimer = 0
			
			-- Setup the actual timers for the set before the set script
			SetupTimers(Serenity.F.TimerSets[index], key)
			
			Serenity.F.TimerSets[index]:SetScript("OnUpdate", function(self, elapsed)
			
				self.updateTimer = self.updateTimer + elapsed				
				if self.updateTimer < TIMERSET_UPDATEINTERVAL then return else self.updateTimer = 0 end
			
				-- Overrides take precidence over normal alpha
				if Serenity.db.profile.timers[key].deadoverride and UnitIsDeadOrGhost("player") then
				
					self:SetAlpha(Serenity.db.profile.timers[key].deadoverridealpha)
					
				elseif Serenity.db.profile.timers[key].mountoverride and (IsMounted() or UnitUsingVehicle("player")) then
				
					self:SetAlpha(Serenity.db.profile.timers[key].mountoverridealpha)
					
				elseif Serenity.db.profile.timers[key].oocoverride and (not InCombatLockdown()) then
				
					self:SetAlpha(Serenity.db.profile.timers[key].oocoverridealpha)
					
				elseif tContains(self.inActionFlags, 1) then -- Timers set their value based on activity.
				
					self:SetAlpha(Serenity.db.profile.timers[key].activealpha)
				
				else
				
					self:SetAlpha(Serenity.db.profile.timers[key].inactivealpha)
				end
			end)			
			
			index = index + 1
		end
	end
end
