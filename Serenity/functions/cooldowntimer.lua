--[[

	Shows a Cooldown on a frame or can be used as OmniCC for any frame with a cooldown set.
	
]]

if not Serenity then return end

local ICON_SIZE = 36 --the normal size for an icon (don't change this)
local DAY, HOUR, MINUTE = 86400, 3600, 60 --used for formatting text
local DAYISH, HOURISH, MINUTEISH = 3600 * 23.5, 60 * 59.5, 59.5 --used for formatting text at transition points
local HALFDAYISH, HALFHOURISH, HALFMINUTEISH = DAY/2 + 0.5, HOUR/2 + 0.5, MINUTE/2 + 0.5 --used for calculating next update times

local MIN_SCALE = 0.5 --the minimum scale we want to show cooldown counts at, anything below this will be hidden
local MIN_DURATION = 2.5 --the minimum duration to show cooldown text for
local EXPIRING_DURATION = 3 --the minimum number of seconds a cooldown must be to use to display in the expiring format

--returns both what text to display, and how long until the next update
function Serenity.getTimeText(s)

	local db = Serenity.profiles.frames.cooldowns
	
	--format text as seconds when below a minute
	if s < MINUTEISH then
		local seconds = tonumber(Serenity.Round(s))
		if seconds > EXPIRING_DURATION then
			return Serenity.RGBToHex(Serenity.GetActiveColor(db["secondscolor"]))..'%d|r', seconds, s - (seconds - 0.51)
		else
			return Serenity.RGBToHex(Serenity.GetActiveColor(db["expiringcolor"]))..'%.1f|r', s, 0.051
		end
	--format text as minutes when below an hour
	elseif s < HOURISH then
		local minutes = tonumber(Serenity.Round(s/MINUTE))
		return Serenity.RGBToHex(Serenity.GetActiveColor(db["minutescolor"]))..'%dm|r', minutes, minutes > 1 and (s - (minutes*MINUTE - HALFMINUTEISH)) or (s - MINUTEISH)
	--format text as hours when below a day
	elseif s < DAYISH then
		local hours = tonumber(Serenity.Round(s/HOUR))
		return Serenity.RGBToHex(Serenity.GetActiveColor(db["hourscolor"]))..'%dh|r', hours, hours > 1 and (s - (hours*HOUR - HALFHOURISH)) or (s - HOURISH)
	--format text as days
	else
		local days = tonumber(Serenity.Round(s/DAY))
		return Serenity.RGBToHex(Serenity.GetActiveColor(db["dayscolor"]))..'%dd|r', days,  days > 1 and (s - (days*DAY - HALFDAYISH)) or (s - DAYISH)
	end
end

local function Timer_Stop(self)
	self.enabled = nil
	self:Hide()
end

local function Timer_ForceUpdate(self)
	self.nextUpdate = 0
	self:Show()
end

local function Timer_OnSizeChanged(self, width, height)
	local fontScale = E.Round(width) / ICON_SIZE
	if fontScale == self.fontScale then
		return
	end

	self.fontScale = fontScale
	if fontScale < MIN_SCALE then
		self:Hide()
	else
		local db = Serenity.profiles.frames.cooldowns

		self.text:SetFont(Serenity.GetActiveFont(db["font"], 1), fontScale * Serenity.GetActiveFont(db["font"], 2), Serenity.GetActiveFont(db["font"], 3))
		self.text:SetShadowColor(Serenity.GetActiveColor(db["shadowcolor"]))
		self.text:SetShadowOffset(Serenity.GetActiveOffset(db["fontshadowoffset"]))
		if self.enabled then
			Timer_ForceUpdate(self)
		end
	end
end

local function Timer_OnUpdate(self, elapsed)

	if self.nextUpdate > 0 then
		self.nextUpdate = self.nextUpdate - elapsed
	else
		local remain = self.duration - (GetTime() - self.start)

		if remain > 0.01 then
			if (self.fontScale * self:GetEffectiveScale() / UIParent:GetScale()) < MIN_SCALE then
				self.text:SetText("")
				self.nextUpdate  = 1
			else
				local formatStr, time, nextUpdate = Serenity.getTimeText(remain)
				self.text:SetFormattedText(formatStr, time)
				self.nextUpdate = nextUpdate
			end
		else
			Timer_Stop(self)
		end
	end
end

local function Timer_Create(self)

	local scaler = CreateFrame('Frame', nil, self)
	scaler:SetAllPoints(self)

	local timer = CreateFrame('Frame', nil, scaler)
	timer:Hide()
	timer:SetAllPoints(scaler)
	timer:SetScript("OnUpdate", Timer_OnUpdate)

	local text = timer:CreateFontString(nil, "OVERLAY")
	text:SetPoint("CENTER", 1, 1)
	text:SetJustifyH("CENTER")
	timer.text = text

	Timer_OnSizeChanged(timer, scaler:GetSize())
	scaler:SetScript("OnSizeChanged", function(self, ...) Timer_OnSizeChanged(timer, ...) end)

	self.timer = timer
	return timer
end

--[[ I'll probably make OmniCC an option later and turn this on based on that.
OmniCC = true --hack to work around detection from other addons for OmniCC
hooksecurefunc(getmetatable(ActionButton1Cooldown).__index, 'SetCooldown', function(self, start, duration)
	if self.noOCC then return end
	--start timer
	if start > 0 and duration > MIN_DURATION then
		local timer = self.timer or Timer_Create(self)
		timer.start = start
		timer.duration = duration
		timer.enabled = true
		timer.nextUpdate = 0
		if timer.fontScale >= MIN_SCALE then timer:Show() end
	--stop timer
	else
		local timer = self.timer
		if timer then
			Timer_Stop(timer)
		end
	end
end)
]]