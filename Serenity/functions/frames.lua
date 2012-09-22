--[[

	Frame functions.
	
]]

if not Serenity then return end

function Serenity.GetFrameOffset(frame, side, absolute)
	if (not frame.gapOffsets) then return(0) end
	if side == "TOP" then return frame.gapOffsets[3]
	elseif side == "BOTTOM" then return absolute and frame.gapOffsets[4] or (-frame.gapOffsets[4])
	elseif side == "LEFT" then return absolute and frame.gapOffsets[1] or (-frame.gapOffsets[1])
	elseif side == "RIGHT" then	return frame.gapOffsets[2]
	end
	return(0)	
end

-- Basicly a wrapper for CreateFrame()
function Serenity.MakeFrame(...)
	local frame = CreateFrame(...)
	frame.gapOffsets = { 0, 0, 0, 0 } -- L, R, T, B
	return frame
end

function Serenity.MakeBackground(parent, d, pre)

	-- Allow for duplicate entries for multiple frame options by just adding in a preface to the options and specifying it upon creation
	local data = {}
	if pre then
		local key,val
		for key,val in pairs(d) do
			-- Only copy items with the "pre" preface.
			if strsub(key, 1, #pre) == pre then
				data[strsub(key, #pre + 1)] = Serenity.DeepCopy(d[key])				
			end
		end
	else
		data = d
	end

	-- Allow MakeBackdrop to always be called and set itself up only if needed
	if (parent == nil) or (data == nil) or ((not data.enablebackdrop) and (not data.enableborder)) then return nil end

	local background = CreateFrame("Frame", nil, parent)
	background:SetFrameStrata("MEDIUM")
	background:SetFrameLevel(((parent:GetFrameLevel()-1) >= 0) and (parent:GetFrameLevel()-1) or 0)

	if data.enablebackdrop and data.enableborder then -- Backdrop and border

		background:SetBackdrop( {bgFile = Serenity.GetLibSharedMedia3():Fetch("background", data.backdroptexture),
			tile = data.tile, tileSize = data.tile and data.tilesize or 0,
			edgeFile = Serenity.GetLibSharedMedia3():Fetch("border", data.bordertexture),
			edgeSize = data.edgesize,
			insets = { left = data.backdropinsets[1], right = data.backdropinsets[2], top = data.backdropinsets[3], bottom = data.backdropinsets[4] }
		})
		background:SetPoint("TOPLEFT", -(data.edgesize) + data.backdropinsets[1], data.edgesize + data.backdropinsets[3])
		background:SetPoint("BOTTOMRIGHT", data.edgesize + data.backdropinsets[2], -(data.edgesize) + data.backdropinsets[4])
		
		-- Add another layer when a border and backdrop are both enabled.
		--[[
		background.backdrop = CreateFrame("Frame", nil, parent)
		background.backdrop:SetBackdrop({bgFile = Serenity.GetLibSharedMedia3():Fetch("background", data.backdroptexture),
			tile = data.tile, tileSize = data.tile and data.tilesize or 0,
		})
		background.backdrop:SetPoint("TOPLEFT", data.backdropoffsets[1], data.backdropoffsets[2])
		background.backdrop:SetPoint("BOTTOMRIGHT", data.backdropoffsets[3], data.backdropoffsets[4])
		background.backdrop:SetFrameStrata("BACKGROUND")]]
		
		parent.gapOffsets[1] = max(abs((-(data.edgesize)) + data.backdropinsets[1]),
			((data.backdropoffsets[1] < 0) and abs(data.backdropoffsets[1]) or 0)) -- LEFT
		parent.gapOffsets[2] = max(abs(( (data.edgesize)) + data.backdropinsets[2]),
			((data.backdropoffsets[3] > 0) and abs(data.backdropoffsets[3]) or 0)) -- RIGHT
		parent.gapOffsets[3] = max(abs(( (data.edgesize)) + data.backdropinsets[3]),
			((data.backdropoffsets[2] > 0) and abs(data.backdropoffsets[2]) or 0)) -- TOP
		parent.gapOffsets[4] = max(abs((-(data.edgesize)) + data.backdropinsets[4]),
			((data.backdropoffsets[4] < 0) and abs(data.backdropoffsets[4]) or 0)) -- BOTTOM		
		
	elseif data.enablebackdrop then -- Backdrop only
	
		background:SetBackdrop({bgFile = Serenity.GetLibSharedMedia3():Fetch("background", data.backdroptexture),
			tile = data.tile, tileSize = data.tile and data.tilesize or 0,
		})
		background:SetPoint("TOPLEFT", data.backdropoffsets[1], data.backdropoffsets[2])
		background:SetPoint("BOTTOMRIGHT", data.backdropoffsets[3], data.backdropoffsets[4])

		parent.gapOffsets[1] = (data.backdropoffsets[1] < 0) and abs(data.backdropoffsets[1]) or 0 -- LEFT
		parent.gapOffsets[2] = (data.backdropoffsets[3] > 0) and abs(data.backdropoffsets[3]) or 0 -- RIGHT
		parent.gapOffsets[3] = (data.backdropoffsets[2] > 0) and abs(data.backdropoffsets[2]) or 0 -- TOP
		parent.gapOffsets[4] = (data.backdropoffsets[4] < 0) and abs(data.backdropoffsets[4]) or 0 -- BOTTOM
		
	else -- Border only
	
		background:SetBackdrop( {
			edgeFile = Serenity.GetLibSharedMedia3():Fetch("border", data.bordertexture),
			edgeSize = data.edgesize,
			insets = { left = data.backdropinsets[1], right = data.backdropinsets[2], top = data.backdropinsets[3], bottom = data.backdropinsets[4] }
		})
		background:SetPoint("TOPLEFT", -(data.edgesize) + data.backdropinsets[1], data.edgesize + data.backdropinsets[3])
		background:SetPoint("BOTTOMRIGHT", data.edgesize + data.backdropinsets[2], -(data.edgesize) + data.backdropinsets[4])
		
		parent.gapOffsets[1] = abs((-(data.edgesize)) + data.backdropinsets[1]) -- LEFT
		parent.gapOffsets[2] = abs(( (data.edgesize)) + data.backdropinsets[2]) -- RIGHT
		parent.gapOffsets[3] = abs(( (data.edgesize)) + data.backdropinsets[3]) -- TOP
		parent.gapOffsets[4] = abs((-(data.edgesize)) + data.backdropinsets[4]) -- BOTTOM
		
	end

	if data.enablebackdrop and data.colorbackdrop then 
		if background.backdrop then
			background.backdrop:SetBackdropColor(unpack(data.backdropcolor))
		else
			background:SetBackdropColor(unpack(data.backdropcolor))
		end
	end
	
	if data.enableborder then background:SetBackdropBorderColor(unpack(data.bordercolor)) end

	return background
end

function Serenity.ApplyTemplate(templateName, ...)
	if not Serenity.V["templates"][templateName] then return end

	local key, val
	-- Energy Bar
	for key,val in pairs(Serenity.V["templates"][templateName]["frames"]["energybar"]) do
		Serenity.db.profile.frames.energybar[key] = Serenity.DeepCopy(Serenity.V["templates"][templateName]["frames"]["energybar"][key])
	end
	-- Enrage
	for key,val in pairs(Serenity.V["templates"][templateName]["frames"]["enrage"]) do
		Serenity.db.profile.frames.enrage[key] = Serenity.DeepCopy(Serenity.V["templates"][templateName]["frames"]["enrage"][key])
	end
	-- Crowd Control
	for key,val in pairs(Serenity.V["templates"][templateName]["frames"]["crowdcontrol"]) do
		Serenity.db.profile.frames.crowdcontrol[key] = Serenity.DeepCopy(Serenity.V["templates"][templateName]["frames"]["crowdcontrol"][key])
	end
	-- Indicators
	for key,val in pairs(Serenity.V["templates"][templateName]["frames"]["indicators"]) do
		Serenity.db.profile.frames.indicators[key] = Serenity.DeepCopy(Serenity.V["templates"][templateName]["frames"]["indicators"][key])
	end
	-- Alerts
	for key,val in pairs(Serenity.V["templates"][templateName]["frames"]["alerts"]) do
		Serenity.db.profile.frames.alerts.icons[key] = Serenity.DeepCopy(Serenity.V["templates"][templateName]["frames"]["alerts"][key])
	end
	-- Timers
	for key,val in pairs(Serenity.db.profile.frames.timers) do
		Serenity.db.profile.frames.timers[key] = Serenity.DeepCopy(Serenity.V["templates"][templateName]["frames"]["timers"])
	end
	-- Timer Icons
	for key,val in pairs(Serenity.db.profile.frames.icons) do
		Serenity.db.profile.frames.icons[key] = Serenity.DeepCopy(Serenity.V["templates"][templateName]["frames"]["icons"])
print("icon key: ", key)
	end
end
