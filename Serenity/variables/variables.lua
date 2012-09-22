--[[

	Serenity Global Variables
	
]]

if not Serenity then return end

Serenity.V["addonname"] = select(1, ...)
Serenity.V["longversion"] = GetAddOnMetadata( ..., "Version" ):match( "^([%d.]+)" )
Serenity.V["shortversion"] = strsub(Serenity.V["longversion"], 7)
Serenity.V["playerclass"] = select(2, UnitClass("player"))
Serenity.V["wowBuild"] = tonumber(select(4, GetBuildInfo()), 10)

Serenity.V["timerpositions"] = {
	["TOP"] = Serenity.L["TOP"],
	["CENTER"] = Serenity.L["CENTER"],
	["BOTTOM"] = Serenity.L["BOTTOM"],
	["LEFT"] = Serenity.L["LEFT"],
	["RIGHT"] = Serenity.L["RIGHT"],
}

Serenity.V["chatchannels"] = {
	["AUTO"] = Serenity.L["Automatic"],
	["RAID"] = Serenity.L["Raid"],
	["YELL"] = Serenity.L["Yell"],
	["OFFICER"] = Serenity.L["Officer"],
	["GUILD"] = Serenity.L["Guild"],
	["BATTLEGROUND"] = Serenity.L["Battleground"],
	["PARTY"] = Serenity.L["Party"],
	["EMOTE"] = Serenity.L["Emote"],
	["SAY"] = Serenity.L["Say"],
	["SELFWHISPER"] = Serenity.L["Whisper Self"],
	["NONE"] = Serenity.L["No Announce"],
}

Serenity.V["timerowners"] = {
	["PLAYERS"] = Serenity.L["Only Yours"],
	["ANY"] = Serenity.L["Anyone's"],
}

Serenity.V["alerttypes"] = {
	["BUFF"] = Serenity.L["Buff"],
	["DEBUFF"] = Serenity.L["Debuff"],
--	["MANA"] = Serenity.L["Mana"],
--	["HEALTH"] = Serenity.L["Health"],
	["CAST"] = Serenity.L["Spell Cast Start"],
}

Serenity.V["classcolors"] = {
	["DEATHKNIGHT"] = { .77, .12, .24 },
	["DRUID"] = { 1, .49, .04 },
	["HUNTER"] = { .67, .84, .45 },
	["MAGE"] = { .41, .80, 1 },
	["PALADIN"] = { .96, .55, .73 },
	["PRIEST"] = { .83, .83, .83 },
	["ROGUE"] = { 1, .95, .32 },
	["SHAMAN"] = {  .16, .31, .61 },
	["WARLOCK"] = { .58, .51, .79 },
	["WARRIOR"] = { .78, .61, .43 },
}

Serenity.V["targets"] = {
	["target"] = Serenity.L["Target"],
	["player"] = Serenity.L["Player"],
	["pet"] = Serenity.L["Pet"],
	["focus"] = Serenity.L["Focus"],
	["mouseover"] = Serenity.L["Mouse Over"],
	["boss"] = Serenity.L["Any Boss"],
	["boss1"] = Serenity.L["Boss 1"],
	["boss2"] = Serenity.L["Boss 2"],
	["boss3"] = Serenity.L["Boss 3"],
	["boss4"] = Serenity.L["Boss 4"],
	["arena"] = Serenity.L["Any Arena Enemy"],
	["arena1"] = Serenity.L["Arena Enemy 1"],
	["arena2"] = Serenity.L["Arena Enemy 2"],
	["arena3"] = Serenity.L["Arena Enemy 3"],
	["arena4"] = Serenity.L["Arena Enemy 4"],
	["arena5"] = Serenity.L["Arena Enemy 5"],
	["party"] = Serenity.L["Any Party Member"],
	["partypet"] = Serenity.L["Any Party Pet"],
	["raid"] = Serenity.L["Any Raid Member"],
	["raidpet"] = Serenity.L["Any Raid Pet"],
	["vehicle"] = Serenity.L["Vehicle"],
}

Serenity.V["raidsizes"] = {
	["10"] = Serenity.L["Raid 10"],
	["15"] = Serenity.L["Raid 15"],
	["20"] = Serenity.L["Raid 20"],
	["25"] = Serenity.L["Raid 25"],
	["40"] = Serenity.L["Raid 40"],
}

Serenity.V["templates"] = {
	["Serenity"] = {
		["frames"] = {
			["movers"] = {
				["titlefont"] = { "Arial Narrow", 15, "OUTLINE" },
				["titlefontcolor"] = { 1, 1, 1, 1 }, -- White
				["foreground"] = { 0, .5, 0, .8 }, -- Green
			},
			["cooldowns"] = {
				["font"] = { "Arial Narrow", 18, "OUTLINE" },
				["expiringcolor"] = { 1, 0, 0 }, -- Red
				["secondscolor"] = { 1, 1, 0 },
				["minutescolor"] = { 1, 1, 1 }, -- White
				["hourscolor"] = { 0.4, 1, 1 },
				["dayscolor"] = { 0.4, 0.4, 1 },
				["shadowcolor"] = { 0, 0, 0, 0.5 }, -- Black + 1/2 alpha
				["enableshadow"] = true,
				["fontshadowoffset"] = { 2, -2 },
			},
			["energybar"] = {
				width = 250,
				height = 19,
				energyfont = { "Big Noodle", 17, "OUTLINE" },
				energyfontoffset = 0,
				healthfont = { "Big Noodle", 14, "OUTLINE" },
				healthfontoffset = 0,
				energyfontcolor = { 1, 1, 1, 1 },
				shottimerfont = { "Arial Narrow", 12, "OUTLINE" },
				shottimerfontcolor = { 1, 1, 1, 1 },
				shottimerfontoffset = 0,
				bartexture = "Blizzard",
				classcolored = true,
				barcolor = { 0.6, 0.6, 0.6, 1},
				barcolorlow = { 1, 0, 0, 1},
				barcolorhigh = { 1, 0.55, 0, 1},
				shotbarcolor = { 1, 1, 1, 1},
				enablebackdrop = true,
				colorbackdrop = true,
				backdropcolor = { 0, 0, 0, .5 },
				backdroptexture = "Solid",
				backdropoffsets = { -2, 2, 2, -2 },
				enableborder = false,
				bordercolor = { 1, 1, 1, 1 },
				bordertexture = "None",
				backdropinsets = { -2, -2, -2, -2 },
				edgesize = 16,
				tile = false,
				tilesize = 16,
			},
			["enrage"] = {
				iconsize = 40,
				iconsizeremovables = 24,
				enablebackdrop = false,
				colorbackdrop = false,
				backdropcolor = { 0, 0, 0, .5 },
				backdroptexture = "Solid",
				backdropoffsets = { -2, 2, 2, -2 },
				enableborder = false,
				bordercolor = { 1, 1, 1, 1 },
				bordertexture = "None",
				backdropinsets = { -2, -2, -2, -2 },
				edgesize = 16,
				tile = false,
				tilesize = 16,
				enabletexcoords = false,
				texcoords = { 0.08, 0.92, 0.08, 0.92 },
				removablesenablebackdrop = false,
				removablescolorbackdrop = false,
				removablesbackdropcolor = { 0, 0, 0, .5 },
				removablesbackdroptexture = "Solid",
				removablesbackdropoffsets = { -2, 2, 2, -2 },
				removablesenableborder = false,
				removablesbordercolor = { 1, 1, 1, 1 },
				removablesbordertexture = "None",
				removablesbackdropinsets = { -2, -2, -2, -2 },
				removablesedgesize = 16,
				removablestile = false,
				removablestilesize = 16,
				removablesenabletexcoords = false,
				removablestexcoords = { 0.08, 0.92, 0.08, 0.92 },
			},
			["crowdcontrol"] = {
				iconsize = 30,
				enablebackdrop = false,
				colorbackdrop = false,
				backdropcolor = { 0, 0, 0, .5 },
				backdroptexture = "Solid",
				backdropoffsets = { -2, 2, 2, -2 },
				enableborder = false,
				bordercolor = { 1, 1, 1, 1 },
				bordertexture = "None",
				backdropinsets = { -2, -2, -2, -2 },
				edgesize = 16,
				tile = false,
				tilesize = 16,
				enabletexcoords = false,
				texcoords = { 0.08, 0.92, 0.08, 0.92 },
			},
			["indicators"] = {
				huntersmark_iconsize = 40,
				huntersmark_enablebackdrop = false,
				huntersmark_colorbackdrop = false,
				huntersmark_backdropcolor = { 0, 0, 0, .5 },
				huntersmark_backdroptexture = "Solid",
				huntersmark_backdropoffsets = { -2, 2, 2, -2 },
				huntersmark_enableborder = false,
				huntersmark_bordercolor = { 1, 1, 1, 1 },
				huntersmark_bordertexture = "None",
				huntersmark_backdropinsets = { -2, -2, -2, -2 },
				huntersmark_edgesize = 16,
				huntersmark_tile = false,
				huntersmark_tilesize = 16,
				huntersmark_enabletexcoords = false,
				huntersmark_texcoords = { 0.08, 0.92, 0.08, 0.92 },
				aspect_iconsize = 30,
				aspect_enablebackdrop = false,
				aspect_colorbackdrop = false,
				aspect_backdropcolor = { 0, 0, 0, .5 },
				aspect_backdroptexture = "Solid",
				aspect_backdropoffsets = { -2, 2, 2, -2 },
				aspect_enableborder = false,
				aspect_bordercolor = { 1, 1, 1, 1 },
				aspect_bordertexture = "None",
				aspect_backdropinsets = { -2, -2, -2, -2 },
				aspect_edgesize = 16,
				aspect_tile = false,
				aspect_tilesize = 16,
				aspect_enabletexcoords = false,
				aspect_texcoords = { 0.08, 0.92, 0.08, 0.92 },
				scarebeast_iconsize = 30,
				scarebeast_enablebackdrop = false,
				scarebeast_colorbackdrop = false,
				scarebeast_backdropcolor = { 0, 0, 0, .5 },
				scarebeast_backdroptexture = "Solid",
				scarebeast_backdropoffsets = { -2, 2, 2, -2 },
				scarebeast_enableborder = false,
				scarebeast_bordercolor = { 1, 1, 1, 1 },
				scarebeast_bordertexture = "None",
				scarebeast_backdropinsets = { -2, -2, -2, -2 },
				scarebeast_edgesize = 16,
				scarebeast_tile = false,
				scarebeast_tilesize = 16,
				scarebeast_enabletexcoords = false,
				scarebeast_texcoords = { 0.08, 0.92, 0.08, 0.92 },			
			},
			["timers"] = { -- Defaults for newly created timer objects
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
				timefont = { "Arial Narrow", 13, "" },
				timerfontcolorstatic = false,
				timerfontcolor = { 0.4, 0.4, 1 }, -- Yellow (Check this)
				enabletimershadow = false,
				timershadowcolor = { 0, 0, 0, 0.5 }, -- Black + 1/2 alpha
				timershadowoffset = { 2, -2 },
				stackfont = { "Arial Narrow", 12, "OUTLINE" },
				stackfontcolor = { .05, 1, .96 },
				timerenablebackdrop = false,
				timercolorbackdrop = false,
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
			["icons"] = { -- Defaults for newly created timer icon objects
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
				timefont = { "Arial Narrow", 13, "OUTLINE" },
				timerfontcolorstatic = false,
				timerfontcolor = { 0.4, 0.4, 1 }, -- Yellow (Check this)
				enabletimershadow = false,
				timershadowcolor = { 0, 0, 0, 0.5 }, -- Black + 1/2 alpha
				timershadowoffset = { 2, -2 },
				stackfont = { "Arial Narrow", 12, "OUTLINE" },
				stackfontcolor = { .05, 1, .96 },
				iconenablebackdrop = false,
				iconcolorbackdrop = true,
				iconbackdropcolor = { 0, 0, 0, .5 },
				iconbackdroptexture = "Solid",
				icontile = false,
				icontilesize = 16,
				iconbackdropoffsets = { -2, 2, 2, -2 },
				iconbackdropinsets = { -2, -2, -2, -2 },
				iconenableborder = false,
				iconbordercolor = { 1, 1, 1, 1 },
				iconbordertexture = "None",
				iconedgesize = 16,
				enabletexcoords = false,
				texcoords = { 0.08, 0.92, 0.08, 0.92 },
			},
			["alerts"] = {
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
}

--[[
	Add in the TukUI template
	* TukUI should be an optional dependancy in the TOC file.
]]
local TukUI_T, TukUI_C, TukUI_L
local TukBackdropColor = { .07, .07, .07 }
local TukBorderColor = { .23, .23, .23 }
if IsAddOnLoaded("Tukui") --[[and strsub(GetAddOnMetadata("Tukui", "Version"), 1, 2) == "13."]] then
	TukUI_T, TukUI_C, TukUI_L = unpack(Tukui)
	TukBackdropColor = TukUI_C["media"].backdropcolor
	TukBorderColor = TukUI_C["media"].bordercolor
	TukUI_T, TukUI_C, TukUI_L = nil, nil, nil
end
	
Serenity.V["templates"]["TukUI"] = Serenity.DeepCopy(Serenity.V["templates"]["Serenity"])

Serenity.V["templates"]["TukUI"]["frames"]["energybar"]["classcolored"] = false
Serenity.V["templates"]["TukUI"]["frames"]["energybar"]["barcolor"] = { 0.6, 0.6, 0.6, 1}
Serenity.V["templates"]["TukUI"]["frames"]["energybar"]["enablebackdrop"] = true
Serenity.V["templates"]["TukUI"]["frames"]["energybar"]["backdroptexture"] = "Solid"
Serenity.V["templates"]["TukUI"]["frames"]["energybar"]["colorbackdrop"] = true
Serenity.V["templates"]["TukUI"]["frames"]["energybar"]["backdropcolor"] = TukBackdropColor
Serenity.V["templates"]["TukUI"]["frames"]["energybar"]["backdropoffsets"] = { -3, 3, 3, -3 }
Serenity.V["templates"]["TukUI"]["frames"]["energybar"]["enableborder"] = true
Serenity.V["templates"]["TukUI"]["frames"]["energybar"]["bordercolor"] = TukBorderColor
Serenity.V["templates"]["TukUI"]["frames"]["energybar"]["bordertexture"] = "Solid"
Serenity.V["templates"]["TukUI"]["frames"]["energybar"]["backdropinsets"] = { -1, 1, 1, -1 }
Serenity.V["templates"]["TukUI"]["frames"]["energybar"]["edgesize"] = 1
Serenity.V["templates"]["TukUI"]["frames"]["energybar"]["tile"] = false
Serenity.V["templates"]["TukUI"]["frames"]["energybar"]["tilesize"] = 1

Serenity.V["templates"]["TukUI"]["frames"]["enrage"]["enablebackdrop"] = true
Serenity.V["templates"]["TukUI"]["frames"]["enrage"]["colorbackdrop"] = true
Serenity.V["templates"]["TukUI"]["frames"]["enrage"]["backdropcolor"] = TukBackdropColor
Serenity.V["templates"]["TukUI"]["frames"]["enrage"]["backdroptexture"] = "Solid"
Serenity.V["templates"]["TukUI"]["frames"]["enrage"]["backdropoffsets"] = { -3, 3, 3, -3 }
Serenity.V["templates"]["TukUI"]["frames"]["enrage"]["enableborder"] = true
Serenity.V["templates"]["TukUI"]["frames"]["enrage"]["bordercolor"] = TukBorderColor
Serenity.V["templates"]["TukUI"]["frames"]["enrage"]["backdropinsets"] = { -1, 1, 1, -1 }
Serenity.V["templates"]["TukUI"]["frames"]["enrage"]["edgesize"] = 1
Serenity.V["templates"]["TukUI"]["frames"]["enrage"]["tile"] = false
Serenity.V["templates"]["TukUI"]["frames"]["enrage"]["tilesize"] = 1
Serenity.V["templates"]["TukUI"]["frames"]["enrage"]["enabletexcoords"] = true
Serenity.V["templates"]["TukUI"]["frames"]["enrage"]["texcoords"] = { 0.08, 0.92, 0.08, 0.92 }
Serenity.V["templates"]["TukUI"]["frames"]["enrage"]["removablesenablebackdrop"] = true
Serenity.V["templates"]["TukUI"]["frames"]["enrage"]["removablescolorbackdrop"] = true
Serenity.V["templates"]["TukUI"]["frames"]["enrage"]["removablesbackdropcolor"] = TukBackdropColor
Serenity.V["templates"]["TukUI"]["frames"]["enrage"]["removablesbackdroptexture"] = "Solid"
Serenity.V["templates"]["TukUI"]["frames"]["enrage"]["removablesbackdropoffsets"] = { -3, 3, 3, -3 }
Serenity.V["templates"]["TukUI"]["frames"]["enrage"]["removablesenableborder"] = true
Serenity.V["templates"]["TukUI"]["frames"]["enrage"]["removablesbordercolor"] = TukBorderColor
Serenity.V["templates"]["TukUI"]["frames"]["enrage"]["removablesbordertexture"] = "Solid"
Serenity.V["templates"]["TukUI"]["frames"]["enrage"]["removablesbackdropinsets"] = { -1, 1, 1, -1 }
Serenity.V["templates"]["TukUI"]["frames"]["enrage"]["removablesedgesize"] = 1
Serenity.V["templates"]["TukUI"]["frames"]["enrage"]["removablestile"] = false
Serenity.V["templates"]["TukUI"]["frames"]["enrage"]["removablestilesize"] = 1
Serenity.V["templates"]["TukUI"]["frames"]["enrage"]["removablesenabletexcoords"] = true
Serenity.V["templates"]["TukUI"]["frames"]["enrage"]["removablestexcoords"] = { 0.08, 0.92, 0.08, 0.92 }

Serenity.V["templates"]["TukUI"]["frames"]["crowdcontrol"]["enablebackdrop"] = true
Serenity.V["templates"]["TukUI"]["frames"]["crowdcontrol"]["colorbackdrop"] = true
Serenity.V["templates"]["TukUI"]["frames"]["crowdcontrol"]["backdropcolor"] = TukBackdropColor
Serenity.V["templates"]["TukUI"]["frames"]["crowdcontrol"]["backdroptexture"] = "Solid"
Serenity.V["templates"]["TukUI"]["frames"]["crowdcontrol"]["backdropoffsets"] = { -3, 3, 3, -3 }
Serenity.V["templates"]["TukUI"]["frames"]["crowdcontrol"]["enableborder"] = true
Serenity.V["templates"]["TukUI"]["frames"]["crowdcontrol"]["bordercolor"] = TukBorderColor
Serenity.V["templates"]["TukUI"]["frames"]["crowdcontrol"]["bordertexture"] = "Solid"
Serenity.V["templates"]["TukUI"]["frames"]["crowdcontrol"]["backdropinsets"] = { -1, 1, 1, -1 }
Serenity.V["templates"]["TukUI"]["frames"]["crowdcontrol"]["edgesize"] = 1
Serenity.V["templates"]["TukUI"]["frames"]["crowdcontrol"]["tile"] = false
Serenity.V["templates"]["TukUI"]["frames"]["crowdcontrol"]["tilesize"] = 1
Serenity.V["templates"]["TukUI"]["frames"]["crowdcontrol"]["enabletexcoords"] = true
Serenity.V["templates"]["TukUI"]["frames"]["crowdcontrol"]["texcoords"] = { 0.08, 0.92, 0.08, 0.92 }

Serenity.V["templates"]["TukUI"]["frames"]["indicators"]["huntersmark_enablebackdrop"] = true
Serenity.V["templates"]["TukUI"]["frames"]["indicators"]["huntersmark_colorbackdrop"] = true
Serenity.V["templates"]["TukUI"]["frames"]["indicators"]["huntersmark_backdropcolor"] = TukBackdropColor
Serenity.V["templates"]["TukUI"]["frames"]["indicators"]["huntersmark_backdroptexture"] = "Solid"
Serenity.V["templates"]["TukUI"]["frames"]["indicators"]["huntersmark_backdropoffsets"] = { -3, 3, 3, -3 }
Serenity.V["templates"]["TukUI"]["frames"]["indicators"]["huntersmark_enableborder"] = true
Serenity.V["templates"]["TukUI"]["frames"]["indicators"]["huntersmark_bordercolor"] = TukBorderColor
Serenity.V["templates"]["TukUI"]["frames"]["indicators"]["huntersmark_bordertexture"] = "Solid"
Serenity.V["templates"]["TukUI"]["frames"]["indicators"]["huntersmark_backdropinsets"] = { -1, 1, 1, -1 }
Serenity.V["templates"]["TukUI"]["frames"]["indicators"]["huntersmark_edgesize"] = 1
Serenity.V["templates"]["TukUI"]["frames"]["indicators"]["huntersmark_tile"] = false
Serenity.V["templates"]["TukUI"]["frames"]["indicators"]["huntersmark_tilesize"] = 1
Serenity.V["templates"]["TukUI"]["frames"]["indicators"]["huntersmark_enabletexcoords"] = true
Serenity.V["templates"]["TukUI"]["frames"]["indicators"]["huntersmark_texcoords"] = { 0.08, 0.92, 0.08, 0.92 }
Serenity.V["templates"]["TukUI"]["frames"]["indicators"]["aspect_enablebackdrop"] = true
Serenity.V["templates"]["TukUI"]["frames"]["indicators"]["aspect_colorbackdrop"] = true
Serenity.V["templates"]["TukUI"]["frames"]["indicators"]["aspect_backdropcolor"] = TukBackdropColor
Serenity.V["templates"]["TukUI"]["frames"]["indicators"]["aspect_backdroptexture"] = "Solid"
Serenity.V["templates"]["TukUI"]["frames"]["indicators"]["aspect_backdropoffsets"] = { -3, 3, 3, -3 }
Serenity.V["templates"]["TukUI"]["frames"]["indicators"]["aspect_enableborder"] = true
Serenity.V["templates"]["TukUI"]["frames"]["indicators"]["aspect_bordercolor"] = TukBorderColor
Serenity.V["templates"]["TukUI"]["frames"]["indicators"]["aspect_bordertexture"] = "Solid"
Serenity.V["templates"]["TukUI"]["frames"]["indicators"]["aspect_backdropinsets"] = { -1, 1, 1, -1 }
Serenity.V["templates"]["TukUI"]["frames"]["indicators"]["aspect_edgesize"] = 1
Serenity.V["templates"]["TukUI"]["frames"]["indicators"]["aspect_tile"] = false
Serenity.V["templates"]["TukUI"]["frames"]["indicators"]["aspect_tilesize"] = 1
Serenity.V["templates"]["TukUI"]["frames"]["indicators"]["aspect_enabletexcoords"] = true
Serenity.V["templates"]["TukUI"]["frames"]["indicators"]["aspect_texcoords"] = { 0.08, 0.92, 0.08, 0.92 }
Serenity.V["templates"]["TukUI"]["frames"]["indicators"]["scarebeast_enablebackdrop"] = true
Serenity.V["templates"]["TukUI"]["frames"]["indicators"]["scarebeast_colorbackdrop"] = true
Serenity.V["templates"]["TukUI"]["frames"]["indicators"]["scarebeast_backdropcolor"] = TukBackdropColor
Serenity.V["templates"]["TukUI"]["frames"]["indicators"]["scarebeast_backdroptexture"] = "Solid"
Serenity.V["templates"]["TukUI"]["frames"]["indicators"]["scarebeast_backdropoffsets"] = { -3, 3, 3, -3 }
Serenity.V["templates"]["TukUI"]["frames"]["indicators"]["scarebeast_enableborder"] = true
Serenity.V["templates"]["TukUI"]["frames"]["indicators"]["scarebeast_bordercolor"] = TukBorderColor
Serenity.V["templates"]["TukUI"]["frames"]["indicators"]["scarebeast_bordertexture"] = "Solid"
Serenity.V["templates"]["TukUI"]["frames"]["indicators"]["scarebeast_backdropinsets"] = { -1, 1, 1, -1 }
Serenity.V["templates"]["TukUI"]["frames"]["indicators"]["scarebeast_edgesize"] = 1
Serenity.V["templates"]["TukUI"]["frames"]["indicators"]["scarebeast_tile"] = false
Serenity.V["templates"]["TukUI"]["frames"]["indicators"]["scarebeast_tilesize"] = 1
Serenity.V["templates"]["TukUI"]["frames"]["indicators"]["scarebeast_enabletexcoords"] = true
Serenity.V["templates"]["TukUI"]["frames"]["indicators"]["scarebeast_texcoords"] = { 0.08, 0.92, 0.08, 0.92 }

Serenity.V["templates"]["TukUI"]["frames"]["timers"]["enablebackdrop"] = true
Serenity.V["templates"]["TukUI"]["frames"]["timers"]["colorbackdrop"] = true
Serenity.V["templates"]["TukUI"]["frames"]["timers"]["backdropcolor"] = TukBackdropColor
Serenity.V["templates"]["TukUI"]["frames"]["timers"]["backdroptexture"] = "Solid"
Serenity.V["templates"]["TukUI"]["frames"]["timers"]["backdropoffsets"] = { -3, 3, 3, -3 }
Serenity.V["templates"]["TukUI"]["frames"]["timers"]["enableborder"] = true
Serenity.V["templates"]["TukUI"]["frames"]["timers"]["bordercolor"] = TukBorderColor
Serenity.V["templates"]["TukUI"]["frames"]["timers"]["bordertexture"] = "Solid"
Serenity.V["templates"]["TukUI"]["frames"]["timers"]["backdropinsets"] = { -1, 1, 1, -1 }
Serenity.V["templates"]["TukUI"]["frames"]["timers"]["edgesize"] = 1
Serenity.V["templates"]["TukUI"]["frames"]["timers"]["tile"] = false
Serenity.V["templates"]["TukUI"]["frames"]["timers"]["tilesize"] = 1
Serenity.V["templates"]["TukUI"]["frames"]["timers"]["timerenablebackdrop"] = true
Serenity.V["templates"]["TukUI"]["frames"]["timers"]["timercolorbackdrop"] = true
Serenity.V["templates"]["TukUI"]["frames"]["timers"]["timerbackdropcolor"] = TukBackdropColor
Serenity.V["templates"]["TukUI"]["frames"]["timers"]["timerbackdroptexture"] = "Solid"
Serenity.V["templates"]["TukUI"]["frames"]["timers"]["timertile"] = false
Serenity.V["templates"]["TukUI"]["frames"]["timers"]["timertilesize"] = 1
Serenity.V["templates"]["TukUI"]["frames"]["timers"]["timerbackdropoffsets"] = { -3, 3, 3, -3 }
Serenity.V["templates"]["TukUI"]["frames"]["timers"]["timerbackdropinsets"] = { -1, 1, 1, -1 }
Serenity.V["templates"]["TukUI"]["frames"]["timers"]["timerenableborder"] = true
Serenity.V["templates"]["TukUI"]["frames"]["timers"]["timerbordercolor"] = TukBorderColor
Serenity.V["templates"]["TukUI"]["frames"]["timers"]["timerbordertexture"] = "Solid"
Serenity.V["templates"]["TukUI"]["frames"]["timers"]["timeredgesize"] = 1
Serenity.V["templates"]["TukUI"]["frames"]["timers"]["enabletexcoords"] = true
Serenity.V["templates"]["TukUI"]["frames"]["timers"]["texcoords"] = { 0.08, 0.92, 0.08, 0.92 }

Serenity.V["templates"]["TukUI"]["frames"]["icons"]["enablebackdrop"] = true
Serenity.V["templates"]["TukUI"]["frames"]["icons"]["colorbackdrop"] = true
Serenity.V["templates"]["TukUI"]["frames"]["icons"]["backdropcolor"] = TukBackdropColor
Serenity.V["templates"]["TukUI"]["frames"]["icons"]["backdroptexture"] = "Solid"
Serenity.V["templates"]["TukUI"]["frames"]["icons"]["backdropoffsets"] = { -3, 3, 3, -3 }
Serenity.V["templates"]["TukUI"]["frames"]["icons"]["enableborder"] = true
Serenity.V["templates"]["TukUI"]["frames"]["icons"]["bordercolor"] = TukBorderColor
Serenity.V["templates"]["TukUI"]["frames"]["icons"]["bordertexture"] = "Solid"
Serenity.V["templates"]["TukUI"]["frames"]["icons"]["backdropinsets"] = { -1, 1, 1, -1 }
Serenity.V["templates"]["TukUI"]["frames"]["icons"]["edgesize"] = 1
Serenity.V["templates"]["TukUI"]["frames"]["icons"]["tile"] = false
Serenity.V["templates"]["TukUI"]["frames"]["icons"]["tilesize"] = 1
Serenity.V["templates"]["TukUI"]["frames"]["icons"]["iconenablebackdrop"] = true
Serenity.V["templates"]["TukUI"]["frames"]["icons"]["iconcolorbackdrop"] = true
Serenity.V["templates"]["TukUI"]["frames"]["icons"]["iconbackdropcolor"] = TukBackdropColor
Serenity.V["templates"]["TukUI"]["frames"]["icons"]["iconbackdroptexture"] = "Solid"
Serenity.V["templates"]["TukUI"]["frames"]["icons"]["icontile"] = false
Serenity.V["templates"]["TukUI"]["frames"]["icons"]["icontilesize"] = 1
Serenity.V["templates"]["TukUI"]["frames"]["icons"]["iconbackdropoffsets"] = { -3, 3, 3, -3 }
Serenity.V["templates"]["TukUI"]["frames"]["icons"]["iconbackdropinsets"] = { -1, 1, 1, -1 }
Serenity.V["templates"]["TukUI"]["frames"]["icons"]["iconenableborder"] = true
Serenity.V["templates"]["TukUI"]["frames"]["icons"]["iconbordercolor"] = TukBorderColor
Serenity.V["templates"]["TukUI"]["frames"]["icons"]["iconbordertexture"] = "Solid"
Serenity.V["templates"]["TukUI"]["frames"]["icons"]["iconedgesize"] = 1
Serenity.V["templates"]["TukUI"]["frames"]["icons"]["enabletexcoords"] = true
Serenity.V["templates"]["TukUI"]["frames"]["icons"]["texcoords"] = { 0.08, 0.92, 0.08, 0.92 }

Serenity.V["templates"]["TukUI"]["frames"]["alerts"]["enablebackdrop"] = true
Serenity.V["templates"]["TukUI"]["frames"]["alerts"]["colorbackdrop"] = true
Serenity.V["templates"]["TukUI"]["frames"]["alerts"]["backdropcolor"] = TukBackdropColor
Serenity.V["templates"]["TukUI"]["frames"]["alerts"]["backdroptexture"] = "Solid"
Serenity.V["templates"]["TukUI"]["frames"]["alerts"]["backdropoffsets"] = { -3, 3, 3, -3 }
Serenity.V["templates"]["TukUI"]["frames"]["alerts"]["enableborder"] = true
Serenity.V["templates"]["TukUI"]["frames"]["alerts"]["bordercolor"] = TukBorderColor
Serenity.V["templates"]["TukUI"]["frames"]["alerts"]["bordertexture"] = "Solid"
Serenity.V["templates"]["TukUI"]["frames"]["alerts"]["backdropinsets"] = { -1, 1, 1, -1 }
Serenity.V["templates"]["TukUI"]["frames"]["alerts"]["edgesize"] = 1
Serenity.V["templates"]["TukUI"]["frames"]["alerts"]["tile"] = false
Serenity.V["templates"]["TukUI"]["frames"]["alerts"]["tilesize"] = 1
Serenity.V["templates"]["TukUI"]["frames"]["alerts"]["enabletexcoords"] = true
Serenity.V["templates"]["TukUI"]["frames"]["alerts"]["texcoords"] = { 0.08, 0.92, 0.08, 0.92 }
-- End TukUI Template
