--[[

	Serenity Defaults
	
]]

if not Serenity then return end

local key, val, key2, val2

-- Create a timer set defaults table to be used when a new timer set is made.
Serenity.V["timerset_defaults"] = {
	-- If these ever get changed, removed or added - update the blacklist in options!
	["enabled"] = true,
	["activealpha"] = .8,
	["inactivealpha"] = .5,
	["oocoverride"] = true,
	["oocoverridealpha"] = 0,
	["mountoverride"] = true,
	["mountoverridealpha"] = 0,
	["deadoverride"] = true,
	["deadoverridealpha"] = 0,
	["timers"] = {
		-- Spell name or ID, -- This field or the next MUST be nil (one or the other!)
		-- Item name or ID,
		-- Target (player, target, focus, pet, mouseover, raid, etc.)
		-- DURATION or COOLDOWN
		-- Owner (PLAYERS or ANY)
		-- Spec (0 for any, or 1, 2, 3 relative on talent panel)
		-- Timer text position
		-- Flash 0 / 1
		-- Spin 0 / 1
		-- Grow 0 / 1
		-- If Grow, % Remaining to start grow
		-- If Grow, Size to grow (100% - 200%) of size.
		-- Alpha 0 / 1 (if this is on, initial alpha value will be what the timer initially starts at, overriding default)
		-- If Alpha, Start value
		-- If Alpha, End value
	},
	["anchor"] = { "CENTER", nil, "CENTER", 0, -50 },
	["layout"] = "horizontal",
	["reverse"] = false,
}

Serenity.V["iconblock_defaults"] = {
	-- If these ever get changed, removed or added - update the blacklist in options!
	["enabled"] = true,
	["activealpha"] = .8,
	["inactivealpha"] = .5,
	["oocoverride"] = true,
	["oocoverridealpha"] = 0,
	["mountoverride"] = true,
	["mountoverridealpha"] = 0,
	["deadoverride"] = true,
	["deadoverridealpha"] = 0,
	["icons"] = {
		-- Spell name or ID, -- This field or the next MUST be nil (one or the other!)
		-- Item name or ID,
		-- Target (player, target, focus, pet, mouseover, raid, etc.)
		-- DURATION or COOLDOWN
		-- Owner (PLAYERS or ANY)
		-- Spec (0 for any, or 1, 2, 3 relative on talent panel)
		-- Timer text position
		-- Flash 0 / 1
		-- Alpha 0 / 1 (if this is on, initial alpha value will be what the icon initially starts at, overriding default)
		-- If Alpha, Start value
		-- If Alpha, End value
		-- 12 unused
		-- 13 unused
		-- 14 unused
		-- 15 unused
		-- Position 1 - max
	},
	["anchor"] = { "CENTER", nil, "CENTER", 0, -50 },
	["layout"] = "horizontal",
	["reverse"] = false,
}

Serenity.V["alert_defaults"] = {
	["enabled"] = true,
	["alerttype"] = "DEBUFF",
	["anchor"] = { "CENTER", nil, "CENTER", -80, 100 },
	["enablesound"] = true,
	["sound"] = "Raid Warning",
	["aura"] = Serenity.L["ENTER NAME OR ID"],
	["target"] = "target",
	["sparkles"] = true,
	["tooltips"] = true,
}

Serenity.V["alerticons_defaults"] = {
	["anchor"] = { "CENTER", nil, "CENTER", -120, 100 },
}

-- New timer default
Serenity.V["newtimer_default"] = { "NEW TIMER", nil, "player", "COOLDOWN", "PLAYERS", 0, "RIGHT", nil, nil, nil, .4, 1.4, nil, .4, 1 }

-- New icon timer default
Serenity.V["newicon_default"] = { "NEW ICON", nil, "player", "COOLDOWN", "PLAYERS", 0, "RIGHT", nil, nil, .4, 1, nil, nil, nil, nil, 9999}

-- These overwrite global defaults.
Serenity.V["classspecific_defaults"] = {
	["ALL"] = {
		["frames"] = {
			["alerts"] = {
				["icons"] = {
					enablebackdrop = false,
					colorbackdrop = false,
					backdropcolor = { 0, 0, 0, .5 },
					backdroptexture = "Solid",
					backdropoffsets = { -2, 2, 2, -2 },
					enableborder = false,
					bordercolor = { 1, 1, 1, 1 },
					bordertexture = "None",
					backdropinsets = { -2, -2, -2, -2 },
					iconsize = 32,
					edgesize = 16,
					tile = false,
					tilesize = 16,
					stackfont = { "Arial Narrow", 12, "OUTLINE" },
					stackfontcolor = { .05, 1, .96 },
					enabletexcoords = false,
					texcoords = { 0.08, 0.92, 0.08, 0.92 },
				},
			},
		},
		["alerts"] = {
			[Serenity.L["BWD: Parasitic Infection"] ] = {
				["enabled"] = true,
				["alerttype"] = "DEBUFF",
				["enablesound"] = true,
				["sound"] = "Raid Warning",
				["aura"] = 94679,
				["target"] = "player",
				["sparkles"] = true,
				["tooltips"] = true,
			},
			[Serenity.L["BWD: Fixate (Toxitron)"] ] = {
				["enabled"] = true,
				["alerttype"] = "DEBUFF",
				["enablesound"] = true,
				["sound"] = "Raid Warning",
				["aura"] = 80094,
				["target"] = "player",
				["sparkles"] = true,
				["tooltips"] = true,
			},
			[Serenity.L["BWD: Lightning Conductor"] ] = {
				["enabled"] = true,
				["alerttype"] = "DEBUFF",
				["enablesound"] = true,
				["sound"] = "Raid Warning",
				["aura"] = 91433,
				["target"] = "player",
				["sparkles"] = true,
				["tooltips"] = true,
			},
			[Serenity.L["BWD: Shadow Conductor"] ] = {
				["enabled"] = true,
				["alerttype"] = "DEBUFF",
				["enablesound"] = true,
				["sound"] = "Raid Warning",
				["aura"] = 92053,
				["target"] = "player",
				["sparkles"] = true,
				["tooltips"] = true,
			},
			[Serenity.L["BWD: Consuming Flames (Maloriak)"] ] = {
				["enabled"] = true,
				["alerttype"] = "DEBUFF",
				["enablesound"] = true,
				["sound"] = "Raid Warning",
				["aura"] = 77786,
				["target"] = "player",
				["sparkles"] = true,
				["tooltips"] = true,
			},
			[Serenity.L["BWD: Fixate (Maloriak)"] ] = {
				["enabled"] = true,
				["alerttype"] = "DEBUFF",
				["enablesound"] = true,
				["sound"] = "Raid Warning",
				["aura"] = 78617,
				["target"] = "player",
				["sparkles"] = true,
				["tooltips"] = true,
			},
			[Serenity.L["BWD: Dark Sludge"] ] = {
				["enabled"] = true,
				["alerttype"] = "DEBUFF",
				["enablesound"] = true,
				["sound"] = "Raid Warning",
				["aura"] = 92987,
				["target"] = "player",
				["sparkles"] = true,
				["tooltips"] = true,
			},
			[Serenity.L["BWD: Sonic Breath"] ] = {
				["enabled"] = true,
				["alerttype"] = "DEBUFF",
				["enablesound"] = true,
				["sound"] = "Raid Warning",
				["aura"] = 92407,
				["target"] = "player",
				["sparkles"] = true,
				["tooltips"] = true,
			},
			[Serenity.L["BWD: Roaring Flame"] ] = {
				["enabled"] = true,
				["alerttype"] = "DEBUFF",
				["enablesound"] = true,
				["sound"] = "Raid Warning",
				["aura"] = 92485,
				["target"] = "player",
				["sparkles"] = true,
				["tooltips"] = true,
			},
			[Serenity.L["BWD: Searing Flame"] ] = {
				["enabled"] = true,
				["alerttype"] = "DEBUFF",
				["enablesound"] = true,
				["sound"] = "Raid Warning",
				["aura"] = 92423,
				["target"] = "player",
				["sparkles"] = true,
				["tooltips"] = true,
			},
			[Serenity.L["BWD: Dominion"] ] = {
				["enabled"] = true,
				["alerttype"] = "DEBUFF",
				["enablesound"] = true,
				["sound"] = "Raid Warning",
				["aura"] = 79318,
				["target"] = "player",
				["sparkles"] = true,
				["tooltips"] = true,
			},
			[Serenity.L["BWD: Stolen Power"] ] = {
				["enabled"] = true,
				["alerttype"] = "BUFF",
				["enablesound"] = true,
				["sound"] = "Raid Warning",
				["aura"] = 80627,
				["target"] = "player",
				["sparkles"] = true,
				["tooltips"] = true,
			},
			[Serenity.L["BWD: Explosive Cinders"] ] = {
				["enabled"] = true,
				["alerttype"] = "DEBUFF",
				["enablesound"] = true,
				["sound"] = "Raid Warning",
				["aura"] = 79339,
				["target"] = "player",
				["sparkles"] = true,
				["tooltips"] = true,
			},
			[Serenity.L["BOT: Waterlogged"] ] = {
				["enabled"] = true,
				["alerttype"] = "DEBUFF",
				["enablesound"] = true,
				["sound"] = "Raid Warning",
				["aura"] = 82762,
				["target"] = "player",
				["sparkles"] = true,
				["tooltips"] = true,
			},
			[Serenity.L["BOT: Heart of Ice"] ] = {
				["enabled"] = true,
				["alerttype"] = "BUFF",
				["enablesound"] = true,
				["sound"] = "Raid Warning",
				["aura"] = 82665,
				["target"] = "player",
				["sparkles"] = true,
				["tooltips"] = true,
			},
			[Serenity.L["BOT: Frost Beacon"] ] = {
				["enabled"] = true,
				["alerttype"] = "DEBUFF",
				["enablesound"] = true,
				["sound"] = "Raid Warning",
				["aura"] = 93207,
				["target"] = "player",
				["sparkles"] = true,
				["tooltips"] = true,
			},
			[Serenity.L["BOT: Burning Blood"] ] = {
				["enabled"] = true,
				["alerttype"] = "BUFF",
				["enablesound"] = true,
				["sound"] = "Raid Warning",
				["aura"] = 82660,
				["target"] = "player",
				["sparkles"] = true,
				["tooltips"] = true,
			},
			[Serenity.L["BOT: Gravity Core"] ] = {
				["enabled"] = true,
				["alerttype"] = "DEBUFF",
				["enablesound"] = true,
				["sound"] = "Raid Warning",
				["aura"] = 92075,
				["target"] = "player",
				["sparkles"] = true,
				["tooltips"] = true,
			},
			[Serenity.L["BOT: Lightning Rod (Arion)"] ] = {
				["enabled"] = true,
				["alerttype"] = "DEBUFF",
				["enablesound"] = true,
				["sound"] = "Raid Warning",
				["aura"] = 83099,
				["target"] = "player",
				["sparkles"] = true,
				["tooltips"] = true,
			},
			[Serenity.L["BOT: Blackout"] ] = {
				["enabled"] = true,
				["alerttype"] = "DEBUFF",
				["enablesound"] = true,
				["sound"] = "Raid Warning",
				["aura"] = 86788,
				["target"] = "player",
				["sparkles"] = true,
				["tooltips"] = true,
			},
			[Serenity.L["BOT: Engulfing Magic"] ] = {
				["enabled"] = true,
				["alerttype"] = "BUFF",
				["enablesound"] = true,
				["sound"] = "Raid Warning",
				["aura"] = 86622,
				["target"] = "player",
				["sparkles"] = true,
				["tooltips"] = true,
			},
			[Serenity.L["BOT: Twilight Meteorite"] ] = {
				["enabled"] = true,
				["alerttype"] = "DEBUFF",
				["enablesound"] = true,
				["sound"] = "Raid Warning",
				["aura"] = 88518,
				["target"] = "player",
				["sparkles"] = true,
				["tooltips"] = true,
			},
			[Serenity.L["BOT: Devouring Flames"] ] = {
				["enabled"] = true,
				["alerttype"] = "DEBUFF",
				["enablesound"] = true,
				["sound"] = "Raid Warning",
				["aura"] = 86840,
				["target"] = "player",
				["sparkles"] = true,
				["tooltips"] = true,
			},
		},
	},
	["HUNTER"] = {
		["energybar"] = {
			["enabled"] = true,
			["shottimer"] = true,
			["anchor"] = { "CENTER", nil, "CENTER", 0, -170 },
			["anchor_stacks"] = { "CENTER", nil, "CENTER", 90, -100 },
			["enablestacks"] = true,
			["embedstacks"] = true,
			["stackssize"] = 40,
			["stackscolor"] = { 0.8, 0, 0 },
			["stacksreverse"] = false,
		},
		["timers"] = {
			-- Durations Set
			[Serenity.L["Durations"] ] = {
				["enabled"] = true,
				["activealpha"] = 1.0,
				["inactivealpha"] = .5,
				["oocoverride"] = true,
				["oocoverridealpha"] = 0,
				["mountoverride"] = true,
				["mountoverridealpha"] = 0,
				["deadoverride"] = true,
				["deadoverridealpha"] = 0,
				["timers"] = { -- Explained above in the timer set defaults
					{ 1978, nil, "target", "DURATION", "PLAYERS", 0, "RIGHT", nil, nil, nil, .4, 1.4, nil, .4, 1 }, -- Serpent Sting
					{ 82654, nil, "target", "DURATION", "ANY", 0, "RIGHT", nil, nil, nil, .4, 1.4, nil, .4, 1 }, -- Widow Venom
					{ 3045, nil, "player", "DURATION", "PLAYERS", 0, "RIGHT", nil, nil, nil, .4, 1.4, nil, .4, 1 }, -- Rapid Fire
					{ 34692, nil, "player", "DURATION", "PLAYERS", 1, "RIGHT", nil, nil, nil, .4, 1.4, nil, .4, 1 }, -- The Beast Within
					{ 32182, nil, "player", "DURATION", "ANY", 0, "RIGHT", nil, nil, nil, .4, 1.4, nil, .4, 1 }, -- Heroism
					{ 90355, nil, "player", "DURATION", "ANY", 0, "RIGHT", nil, nil, nil, .4, 1.4, nil, .4, 1 }, -- Ancient Hysteria
					{ 80353, nil, "player", "DURATION", "ANY", 0, "RIGHT", nil, nil, nil, .4, 1.4, nil, .4, 1 }, -- Time Warp
					{ 2825, nil, "player", "DURATION", "ANY", 0, "RIGHT", nil, nil, nil, .4, 1.4, nil, .4, 1 }, -- Blood Lust
					{ 136, nil, "pet", "DURATION", "PLAYERS", 0, "RIGHT", nil, nil, nil, .4, 1.4, nil, .4, 1 }, -- Mend Pet
					{ 53220, nil, "player", "DURATION", "PLAYERS", 2, "RIGHT", nil, nil, nil, .4, 1.4, nil, .4, 1 }, -- Improved Steady Shot
					{ 3674, nil, "target", "DURATION", "PLAYERS", 3, "RIGHT", nil, nil, nil, .4, 1.4, nil, .4, 1 }, -- Black Arrow
					{ 79633, nil, "player", "DURATION", "PLAYERS", 0, "RIGHT", nil, nil, nil, .4, 1.4, nil, .4, 1 }, -- Tol'vir Agility
				},
				["anchor"] = { "CENTER", nil, "CENTER", 0, -142 },
				["layout"] = "horizontal",
				["reverse"] = false,
			},
			-- Cooldowns Set
			[Serenity.L["Cooldowns"] ] = {
				["enabled"] = true,
				["activealpha"] = 1.0,
				["inactivealpha"] = .5,
				["oocoverride"] = true,
				["oocoverridealpha"] = 0,
				["mountoverride"] = true,
				["mountoverridealpha"] = 0,
				["deadoverride"] = true,
				["deadoverridealpha"] = 0,
				["timers"] = { -- Explained above in the timer set defaults
					{ 82726, nil, "player", "COOLDOWN", "PLAYERS", 1, "RIGHT", nil, nil, nil, .4, 1.4, nil, .4, 1 }, -- Fervor
					{ 19574, nil, "pet", "COOLDOWN", "PLAYERS", 1, "RIGHT", nil, nil, nil, .4, 1.4, nil, .4, 1 }, -- Bestial Wrath
					{ 1499, nil, "player", "COOLDOWN", "PLAYERS", 0, "RIGHT", nil, nil, nil, .4, 1.4, nil, .4, 1 }, -- Freezing Trap
					{ 90355, nil, "player", "COOLDOWN", "PLAYERS", 1, "RIGHT", nil, nil, nil, .4, 1.4, nil, .4, 1 }, -- Ancient Hysteria
					{ 90361, nil, "player", "COOLDOWN", "PLAYERS", 1, "RIGHT", nil, nil, nil, .4, 1.4, nil, .4, 1 }, -- Spirit Ment
					{ 3045, nil, "player", "COOLDOWN", "PLAYERS", 0, "RIGHT", nil, nil, nil, .4, 1.4, nil, .4, 1 }, -- Rapid Fire
					{ 3674, nil, "player", "COOLDOWN", "PLAYERS", 3, "RIGHT", nil, nil, nil, .4, 1.4, nil, .4, 1 }, -- Black Arrow
				},
				["anchor"] = { "CENTER", nil, "CENTER", 0, -198 },
				["layout"] = "horizontal",
				["reverse"] = false,
			},
		},
		["frames"] = {
			["timers"] = {
				[Serenity.L["Durations"] ] = {
					enablebackdrop = false,
					colorbackdrop = true,
					backdropcolor = { 0, 0, 0, .5 },
					backdroptexture = "Solid",
					backdropoffsets = { -2, 2, 2, -2 },
					enableborder = false,
					bordercolor = { 1, 1, 1, 1 },
					bordertexture = "None",
					backdropinsets = { -2, -2, -2, -2 },
					width = 250,
					height = 19,
					iconsize = 19,
					edgesize = 16,
					tile = false,
					tilesize = 16,
					timefont = { "Arial Narrow", 13, "OUTLINE" },
					timerfontcolorstatic = false,
					timerfontcolor = { 0.4, 0.4, 1 }, -- Yellow (Check this)
					enabletimershadow = false,
					timershadowcolor = { 0, 0, 0, 0.5 }, -- Black + 1/2 alpha
					timershadowoffset = { 2, -2 },
					stackfont = { "Arial Narrow", 12, "OUTLINE" },
					stackfontcolor = { .05, 1, .96 },					
					timerenablebackdrop = false,
					timercolorbackdrop = true,
					timerbackdropcolor = { 0, 0, 0, .5 },
					timerbackdroptexture = "Solid",
					timertile = false,
					timertilesize = 16,
					timerbackdropoffsets = { -2, 2, 2, -2 },
					timerbackdropinsets = { -2, -2, -2, -2 },
					timerenableborder = false,
					timerbordercolor = { 1, 1, 1, 1 },
					timerbordertexture = "None",
					timeredgesize = 16,
					enabletexcoords = false,
					texcoords = { 0.08, 0.92, 0.08, 0.92 },
				},
				[Serenity.L["Cooldowns"] ] = {
					enablebackdrop = false,
					colorbackdrop = true,
					backdropcolor = { 0, 0, 0, .5 },
					backdroptexture = "Solid",
					backdropoffsets = { -2, 2, 2, -2 },
					enableborder = false,
					bordercolor = { 1, 1, 1, 1 },
					bordertexture = "None",
					backdropinsets = { -2, -2, -2, -2 },
					width = 250,
					height = 19,
					iconsize = 19,
					edgesize = 16,
					tile = false,
					tilesize = 16,
					timefont = { "Arial Narrow", 13, "OUTLINE" },
					timerfontcolorstatic = false,
					timerfontcolor = { 0.4, 0.4, 1 }, -- Yellow (Check this)
					enabletimershadow = false,
					timershadowcolor = { 0, 0, 0, 0.5 }, -- Black + 1/2 alpha
					timershadowoffset = { 2, -2 },
					stackfont = { "Arial Narrow", 12, "OUTLINE" },
					stackfontcolor = { .05, 1, .96 },					
					timerenablebackdrop = false,
					timercolorbackdrop = true,
					timerbackdropcolor = { 0, 0, 0, .5 },
					timerbackdroptexture = "Solid",
					timertile = false,
					timertilesize = 16,
					timerbackdropoffsets = { -2, 2, 2, -2 },
					timerbackdropinsets = { -2, -2, -2, -2 },
					timerenableborder = false,
					timerbordercolor = { 1, 1, 1, 1 },
					timerbordertexture = "None",
					timeredgesize = 16,
					enabletexcoords = false,
					texcoords = { 0.08, 0.92, 0.08, 0.92 },
				},
			},
		},
	},
}

-- Create the defaults "profile" sub-key for AceDB
Serenity.V["defaults"] = {
	profile = {
		["newinstall"] = true,
		["masteraudio"] = true,
		["minfortenths"] = 4,
		["basetemplate"] = "Serenity",
		["energybar"] = {
			["enabled"] = false,
			["activealpha"] = 1,
			["inactivealpha"] = .8,
			["oocoverride"] = true,
			["oocoverridealpha"] = 0.2,
			["mountoverride"] = true,
			["mountoverridealpha"] = 0.2,
			["deadoverride"] = true,
			["deadoverridealpha"] = 0,
			["anchor"] = { "CENTER", nil, "CENTER", 0, -170 },
			["energynumber"] = true,
			["targethealth"] = true,
			["shottimer"] = false,
			["shotbar"] = false,
			["smoothbar"] = true,
			["smoothbarshotbar"] = true,
			["lowwarn"] = true,			
			["highwarn"] = true,
			["highwarnthreshold"] = .8,
			["enableprediction"] = true,
			["ticks"] = {
				{ true, "", true, false, {1,1,1,1}, 0 },
				{ false, "", true, false, {1,1,1,1}, 0 },
				{ false, "", true, false, {1,1,1,1}, 0 },
				{ false, "", true, false, {1,1,1,1}, 0 },
				{ false, "", true, false, {1,1,1,1}, 0 },
			},
		},
		["enrage"] = {
			["enabled"] = true,
			["enablesound"] = true,
			["sound"] = "Raid Warning",
			["removednotify"] = true,
			["solochan"] = "AUTO",
			["partychan"] = "AUTO",
			["raidchan"] = "AUTO",
			["arenachan"] = "AUTO",
			["pvpchan"] = "AUTO",
			["anchor"] = { "CENTER", nil, "CENTER", 0, 120 },
			["anchor_removables"] = { "CENTER", nil, "CENTER", 250, 250 },
			["enableremovables"] = true,
			["removablespvponly"] = true,
			["removablestips"] = true,
		},
		["crowdcontrol"] = {
			["enabled"] = true,
			["anchor"] = { "CENTER", nil, "CENTER", -190, -170 },
		},
		["indicators"] = {
			["enabled"] = true,
			["aspect_onlymissing"] = false,
			["aspect_onlycombat"] = false,
			["huntersmark_enable"] = true,
			["huntersmark_mfd"] = true,
			["anchor_huntersmark"] = { "CENTER", nil, "CENTER", 80, 100 },
			["aspect_enable"] = true,
			["anchor_aspect"] = { "CENTER", nil, "CENTER", 160, -170 },
			["scarebeast_enable"] = true,
			["anchor_scarebeast"] = { "CENTER", nil, "CENTER", 195, -170 },
		},
		["timers"] = {
		},
		["icons"] = {
		},
		["misdirection"] = {
			["enable"] = true,
			["enablemdcastannounce"] = true,
			["enablemdoverannounce"] = false,
			["enablemdtransferannounce"] = true,
			["enablemdmountwarn"] = true,
			["solochan"] = "SELFWHISPER",
			["partychan"] = "AUTO",
			["raidchan"] = "AUTO",
			["arenachan"] = "NONE",
			["pvpchan"] = "NONE",
			["targetframe"] = false,
			["petframe"] = true,
			["raidframes"] = true,
			["raidpetframes"] = true,
			["focusframe"] = true,
			["totframe"] = true,
			["partyframes"] = true,
			["partypetframe"] = true,
		},
		["interrupts"] = {
			["enable"] = true,
			["enableannounce"] = true,
			["solochan"] = "SELFWHISPER",
			["partychan"] = "AUTO",
			["raidchan"] = "AUTO",
			["arenachan"] = "AUTO",
			["pvpchan"] = "AUTO",
		},
		["alerts"] = {
		},
		["alerticons"] = {
			["anchor"] = { "CENTER", nil, "CENTER", -120, 100 },
		},
	},
}

-- Frames section from the Serenity template
Serenity.V["defaults"]["profile"]["frames"] = Serenity.DeepCopy(Serenity.V["templates"]["Serenity"]["frames"])
Serenity.V["defaults"]["profile"]["frames"]["icons"] = {} -- Clear the data here, we will add it under the set names - separately
Serenity.V["defaults"]["profile"]["frames"]["timers"] = {} -- Clear the data here, we will add it under the set names - separately

-- Energy bar per class
for key,val in pairs(Serenity.V["classspecific_defaults"][Serenity.V["playerclass"] ]["energybar"]) do
	Serenity.V["defaults"]["profile"]["energybar"][key] = Serenity.DeepCopy(Serenity.V["classspecific_defaults"][Serenity.V["playerclass"] ]["energybar"][key])
end -- ENERGY BAR DONE!

--[[
	Defaults need to be setup after the options table is defined in Ace (defaults that may be totally removed).
	If not, when you remove an object (as in timers), it will create a 'nil' table
	entry and totally fuck things up.
]]
function Serenity.newInstallSetup()
	if Serenity.db.profile["newinstall"] == false then return end
	
	-- Timer sets, merge class specific timer sets into the timer frames.
	for key,val in pairs(Serenity.V["classspecific_defaults"][Serenity.V["playerclass"] ]["timers"]) do
		for key2,val2 in pairs(Serenity.V["classspecific_defaults"][Serenity.V["playerclass"] ]["timers"][key]) do
			if not Serenity.db.profile.timers[key] then Serenity.db.profile.timers[key] = {} end
			Serenity.db.profile.timers[key][key2] = Serenity.DeepCopy(Serenity.V["classspecific_defaults"][Serenity.V["playerclass"] ]["timers"][key][key2])
		end
	end
	for key,val in pairs(Serenity.V["classspecific_defaults"][Serenity.V["playerclass"] ]["frames"]["timers"]) do
		for key2,val2 in pairs(Serenity.V["classspecific_defaults"][Serenity.V["playerclass"] ]["frames"]["timers"][key]) do
			if not Serenity.db.profile.frames.timers[key] then Serenity.db.profile.frames.timers[key] = {} end
			Serenity.db.profile.frames.timers[key][key2] = Serenity.DeepCopy(Serenity.V["classspecific_defaults"][Serenity.V["playerclass"] ]["frames"]["timers"][key][key2])
		end
	end
	-- TIMERS DONE!
	
	-- Alerts
	for key,val in pairs(Serenity.V["classspecific_defaults"]["ALL"]["alerts"]) do
		for key2,val2 in pairs(Serenity.V["classspecific_defaults"]["ALL"]["alerts"][key]) do
			if not Serenity.db.profile.alerts[key] then Serenity.db.profile.alerts[key] = {} end
			Serenity.db.profile.alerts[key][key2] = Serenity.DeepCopy(Serenity.V["classspecific_defaults"]["ALL"]["alerts"][key][key2])
		end
	end
	for key,val in pairs(Serenity.V["classspecific_defaults"]["ALL"]["frames"]["alerts"]) do
		for key2,val2 in pairs(Serenity.V["classspecific_defaults"]["ALL"]["frames"]["alerts"][key]) do
			if not Serenity.db.profile.frames.alerts[key] then Serenity.db.profile.frames.alerts[key] = {} end
			Serenity.db.profile.frames.alerts[key][key2] = Serenity.DeepCopy(Serenity.V["classspecific_defaults"]["ALL"]["frames"]["alerts"][key][key2])
		end
	end
	-- ALERTS DONE!
	
	Serenity.db.profile["newinstall"] = false
end
