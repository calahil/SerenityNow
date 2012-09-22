--[[

	Movable frame handling

]]

if not Serenity then return end

Serenity.V["MoversLocked"] = true
Serenity.F.moverFrames = {}

local movers = Serenity.F.moverFrames

local moverName = 1 -- name that will be given to the mover frame that gets created to identify it
local sourceFrame = 2 -- frame to hide so that we can put up a movement frame
local sizeFrame = 3 -- frame we will use to get the size for the mover frame
local moverTitle = 4 -- title of the mover frame
local moverFrame = 5 -- the mover frame
local moverAnchor = 6 -- table for settings like anchor points (root key, the key before .anchor)
local setupCaller = 7 -- function that will be called to reconfigure the frame, or nil if not needed
local frameDefaults = 8 -- full key path in V["defaults"] (for example) where defaults for positions can be found (root key)
local frameSettings = 9 -- full key path to where the source frame's settings can be found (Serenity.db.frames.timers.<set name> for example)
local anchorKeyPost = 10
local bgKeyPre = 11

--[[
	Registers a frame as being movable when Serenity is unlocked.
]]
function Serenity.RegisterMovableFrame(moverName1, sourceFrame1, sizeFrame1, MoverText1, moverAnchor1, setupCaller1, defaultPositions1, frameSettings1, anchorKeyPost1, bgKeyPre1)

	if not anchorKeyPost1 then anchorKeyPost1 = "" end

	local c = #movers + 1
	local i
	for i=1,#movers do
		if movers[i][moverName] == moverName1 then
			Serenity:Print("\""..moverName1.."\"".." exists, Serenity.RegisterMovableFrame(...) failed!")
			return
		end
	end
	
	movers[c] = { moverName1, sourceFrame1, sizeFrame1, MoverText1, {}, moverAnchor1, setupCaller1, defaultPositions1, frameSettings1, anchorKeyPost1, bgKeyPre1 }
	
	return(c)
end

function Serenity.DeregisterMovableFrame(n)
	local i
	for i=1,#Serenity.F.moverFrames do
		if Serenity.F.moverFrames[i][moverName] == n then
			table.remove(Serenity.F.moverFrames, i)
			return
		end
	end
	-- Returns silently if no mover is found with given name.
end

function Serenity.UnlockAllMovers()

	local i, c
	for i=1,#movers do
		if movers[i][sourceFrame][1] ~= nil then
			c = 1
			while movers[i][sourceFrame][c] ~= nil do
				movers[i][sourceFrame][c]:Hide()
				c = c + 1
			end
		else
			movers[i][sourceFrame]:Hide()
		end
	end

	for i=1,#movers do
		movers[i][moverFrame] = Serenity.MakeFrame("Frame", movers[i][moverName], movers[i][moverAnchor]["anchor"..movers[i][anchorKeyPost] ][2] == nil and UIParent or movers[i][moverAnchor]["anchor"..movers[i][anchorKeyPost] ][2])
		
		movers[i][moverFrame]:SetSize(movers[i][sizeFrame]:GetWidth(), movers[i][sizeFrame]:GetHeight())
		movers[i][moverFrame]:SetPoint(Serenity.GetActiveAnchor(movers[i][moverAnchor]["anchor"..movers[i][anchorKeyPost] ]))
		
		movers[i][moverFrame].artwork = movers[i][moverFrame]:CreateTexture()
		movers[i][moverFrame].artwork:SetAllPoints(movers[i][moverFrame])
		movers[i][moverFrame].artwork:SetTexture(unpack(Serenity.db.profile.frames.movers["foreground"]))
		movers[i][moverFrame].artwork:SetAlpha(.8)
		
		-- Apply the same border and background effects to the mover so the user has a better idea of positioning with them shown.
		if movers[i][sourceFrame].background and frameSettings then
			movers[i][moverFrame].background = Serenity.MakeBackground(movers[i][moverFrame], movers[i][frameSettings], movers[i][bgKeyPre])
		end
		
		movers[i][moverFrame].value = movers[i][moverFrame]:CreateFontString(nil, "OVERLAY", movers[i][moverFrame])
		movers[i][moverFrame].value:SetJustifyH("CENTER")
		movers[i][moverFrame].value:SetPoint("BOTTOM", movers[i][moverFrame], "TOP", 0, 2)
		movers[i][moverFrame].value:SetFont(Serenity.GetActiveFont(Serenity.db.profile.frames.movers["titlefont"]))
		movers[i][moverFrame].value:SetTextColor(unpack(Serenity.db.profile.frames.movers["titlefontcolor"]))
		movers[i][moverFrame].value:SetText(movers[i][moverTitle])

		movers[i][moverFrame]:Show()
		movers[i][moverFrame]:EnableMouse(true)
		movers[i][moverFrame]:RegisterForDrag("LeftButton", "RightButton")
		movers[i][moverFrame]:SetScript("OnDragStart", movers[i][moverFrame].StartMoving)
		movers[i][moverFrame]:SetScript("OnDragStop", movers[i][moverFrame].StopMovingOrSizing)
		movers[i][moverFrame]:SetMovable(true)
		movers[i][moverFrame]:SetClampedToScreen()
	end
end

function Serenity.LockAllMovers()

	local i = #movers
	while (i > 0) and movers[i] do

		movers[i][moverAnchor]["anchor"..movers[i][anchorKeyPost] ][1], movers[i][moverAnchor]["anchor"..movers[i][anchorKeyPost] ][2], movers[i][moverAnchor]["anchor"..movers[i][anchorKeyPost] ][3], 
			movers[i][moverAnchor]["anchor"..movers[i][anchorKeyPost] ][4], movers[i][moverAnchor]["anchor"..movers[i][anchorKeyPost] ][5] = movers[i][moverFrame]:GetPoint()
			
		if movers[i][moverAnchor]["anchor"..movers[i][anchorKeyPost] ][2] == UIParent then movers[i][moverAnchor]["anchor"..movers[i][anchorKeyPost] ][2] = nil end

		-- Destroy the mover frames
		movers[i][moverFrame]:StopMovingOrSizing()
		movers[i][moverFrame]:SetMovable(false)
		movers[i][moverFrame]:EnableMouse(false)
		movers[i][moverFrame]:RegisterForDrag()
		movers[i][moverFrame]:Hide()
		movers[i][moverFrame].background = nil
		movers[i][moverFrame].value = nil
		movers[i][moverFrame]:SetParent(nil)		
		movers[i][moverFrame] = {}

		-- Run the setup function if one was given to do any frame updating because of the move.
		-- If a Setup function is given, that setup function needs to de-register the mover frame properly.
		if movers[i][setupCaller] then 
			movers[i][setupCaller](movers[i][moverName])
		else
			tremove(movers, i)
		end
		i = i - 1
	end
end

-- Used to show live changed when mover options are changed
function Serenity.RedrawLiveMovers()
	if not Serenity.V["MoversLocked"] then
		Serenity.LockAllMovers()
		Serenity.UnlockAllMovers()
	end
end

function Serenity.ToggleMoversLock()
	Serenity.V["MoversLocked"] = not Serenity.V["MoversLocked"]
	if Serenity.V["MoversLocked"] then -- LOCK
		print(Serenity.L["SERENITY_PRE"]..Serenity.L["SERENITYLOCKED"])
		Serenity.LockAllMovers()
	else -- UNLOCK
		print(Serenity.L["SERENITY_PRE"]..Serenity.L["SERENITYUNLOCKED"])
		Serenity.UnlockAllMovers()
	end
end

function Serenity.SetDefaultMoversPositions()
	local i
	local relock = false
	if Serenity.V["MoversLocked"] then
		relock = true
		Serenity.V["MoversLocked"] = not Serenity.V["MoversLocked"]
		Serenity.UnlockAllMovers()		
	end	
	for i=1,#movers do
		movers[i][moverFrame]:ClearAllPoints()
		movers[i][moverFrame]:SetPoint(Serenity.GetActiveAnchor(movers[i][frameDefaults]["anchor"..movers[i][anchorKeyPost] ]))
	end
	if relock then
		Serenity.V["MoversLocked"] = not Serenity.V["MoversLocked"]
		Serenity.LockAllMovers()	
	end
end
