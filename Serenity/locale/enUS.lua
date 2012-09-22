--[[

	Localization for enUS and enGB.
	
]]

local AceLocale = LibStub:GetLibrary("AceLocale-3.0")
local L = AceLocale:NewLocale("Serenity", "enUS", true)
if not L then return end

-- General
L["SERENITY"] = "|cffabd473Serenity|r"
L["SERENITY_PRE"] = "|cffabd473Serenity:|r "
L["GREETING1"] = "|cffabd473Serenity %s|r - type /ser for help."
L["INCOMBATLOCKDOWN"] = "|cffff0000You can not do that while in combat!|r"

L["Durations"] = true
L["Cooldowns"] = true

-- Options LoD
L["OPT_LOD_ERR"] = "|cffff0000Options load on demand error!|r Reason = "
L["OPT_LOD_OK"] = "Options successfully loaded."
L["OPT_LOD_BUTTON_TEXT"] = "Load Options"
L["OPT_LOD_BUTTON_DESC"] = "Click the button to load all of Serenity's option panels."
L["Load on Demand Options"] = true

-- Slash Commands
L["SLASHDESC1"] = "|cffabd473Serenity %s|r slash command help:"
L["SLASHDESC2"] = "open configuration"
L["SLASHDESC3"] = "lock or unlock frame positions"
L["SLASHDESC4"] = "reset frames to default positions"
L["INVALIDSLASH"] = "|cffff0000Invalid command line option.|r"
L["SLASHFRAMEID"] = "Hovered frame's name is \"|cffFFD100%s|r\""

-- Movers (Movable Frames)
L["SERENITYLOCKED"] = "Frames are locked, type '/serenity lock' again to unlock."
L["SERENITYUNLOCKED"] = "Frames are unlocked and movable, type '/serenity lock' to re-lock."
L["MOVERSSETTODEFAULT"] = "Frame anchor points were reset to defaults."

-- Positions
L["TOP"] = true
L["BOTTOM"] = true
L["CENTER"] = true
L["LEFT"] = true
L["RIGHT"] = true
L["TOP/BOTTOM"] = true
L["MOVABLE"] = true

-- Targets
L["Target"] = true
L["Player"] = true
L["Pet"] = true
L["Focus"] = true
L["Mouse Over"] = true
L["Any Boss"] = true
L["Boss 1"] = true
L["Boss 2"] = true
L["Boss 3"] = true
L["Boss 4"] = true
L["Boss 5"] = true
L["Any Arena Enemy"] = true
L["Arena Enemy 1"] = true
L["Arena Enemy 2"] = true
L["Arena Enemy 3"] = true
L["Arena Enemy 4"] = true
L["Arena Enemy 5"] = true
L["Any Party Member"] = true
L["Any Party Pet"] = true
L["Any Raid Member"] = true
L["Any Raid Pet"] = true
L["Vehicle"] = true

-- Raid sizes
L["Raid 10"] = true
L["Raid 15"] = true
L["Raid 20"] = true
L["Raid 25"] = true
L["Raid 40"] = true
	
-- Chat Channels
L["Automatic"] = true
L["Whisper Self"] = true
L["Raid"] = true
L["Yell"] = true
L["Officer"] = true
L["Guild"] = true
L["Battleground"] = true
L["Party"] = true
L["Emote"] = true
L["Say"] = true
L["No Announce"] = true

-- Timer owners
L["Only Yours"] = true
L["Anyone's"] = true

-- Option panels (Main - pre LoD)
L["SERENITY_DESC"] = "A ulility to help classes by properly showing needed information."
L["General Settings"] = true
								
-- Options panel(Profiles - pre LoD)
L["Profiles"] = true

-- Energy Bar
L["Energy Bar"] = true

-- Enrage Alert
L["Enrage Alert"] = true
L["ENRAGEREMOVED"] = " removed "
L["ENRAGEREMOVEDFROM"] = " from "
L["Enrage Alert Removable Buffs"] = true

-- Crowd Control
L["Crowd Control"] = true

-- Indicators
L["Hunter's Mark Indicator"] = true
L["Aspect Indicator"] = true
L["Scare Beast Indicator"] = true

-- Misdirection
L[" finished."] = true
L[" cast on "] = true
L[" can not be cast on you when mounted!"] = true
L[" is transferring threat to you!"] = true
L[" threat transfer complete."] = true

-- Interrupts
L["Interrupted"] = true
L["on"] = true
L["'s"] = true

-- Alert Types
L["Buff"] = true
L["Debuff"] = true
L["Mana"] = true
L["Health"] = true
L["Spell Cast Start"] = true

-- Alerts
L["Alert Icons"] = true
L["ENTER NAME OR ID"] = true

-- Default Alerts for new installs
L["Rez Sickness"] = true
L["BH: Fel Flames"] = true
L["BWD: Parasitic Infection"] = true
L["BWD: Fixate (Toxitron)"] = true
L["BWD: Lightning Conductor"] = true
L["BWD: Shadow Conductor"] = true
L["BWD: Consuming Flames (Maloriak)"] = true
L["BWD: Fixate (Maloriak)"] = true
L["BWD: Flash Freeze"] = true
L["BWD: Dark Sludge"] = true
L["BWD: Sonic Breath"] = true
L["BWD: Roaring Flame"] = true
L["BWD: Searing Flame"] = true
L["BWD: Dominion"] = true
L["BWD: Stolen Power"] = true
L["BWD: Explosive Cinders"] = true
L["BOT: Waterlogged"] = true
L["BOT: Heart of Ice"] = true
L["BOT: Frost Beacon"] = true
L["BOT: Burning Blood"] = true
L["BOT: Gravity Core"] = true
L["BOT: Lightning Rod (Arion)"] = true
L["BOT: Blackout"] = true
L["BOT: Engulfing Magic"] = true
L["BOT: Twilight Meteorite"] = true
L["BOT: Devouring Flames"] = true

-- Stack bars / combo points
L["Stacks"] = true
