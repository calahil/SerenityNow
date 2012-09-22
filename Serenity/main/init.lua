--[[
	Serenity

	by JS - US-Blackhand
]]

--Check to be sure the class of the player is supported by Serenity
--In the future, I plan to support all classes.
if not tContains({"HUNTER"}, select(2, UnitClass("player"))) then Serenity = nil;return end

if Serenity then
	print("*** SOMETHING IS CONFLICTING WITH SERENITY ***")
	print("ERROR! THERE IS ALREADY A \"SERENITY\" GLOBAL DEFINED!")
	return
end

Serenity = LibStub("AceAddon-3.0"):NewAddon("Serenity", "AceConsole-3.0", "AceEvent-3.0")

Serenity.F = {} 	-- Frames
Serenity.V = {} 	-- Variables
Serenity.L = {} 	-- Locale

-- saved variables are under Serenity.db.profile
