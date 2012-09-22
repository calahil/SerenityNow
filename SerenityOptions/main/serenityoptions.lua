--[[

	Serenity Options
	
	... "Load on Demand" module for configuring Serenity.
	
]]

--Create Serenity Options LOD addon under Serenity's Global addon table.
SerenityOptions = LibStub("AceAddon-3.0"):NewAddon("SerenityOptions", "AceConsole-3.0", "AceEvent-3.0")

local L2
local fontFlagTable = {}
local DB

local function setFontFlags(db, keyname, state)
	local t = { strsplit(",", db[3]) }	
	if tContains(t, keyname) and (state == false) then
		tremove(t, Serenity.GetMatchTableValSimple(t, keyname, true))
	elseif (not tContains(t, keyname)) and (state == true) then
		t[#t+1] = keyname
	end	
	db[3] = strtrim(strjoin(",", unpack(t)),",")
end

local function getPlayerSpells()
	local spellTable = {}
	local i = 1
	while true do
		local spellName, spellSubName = GetSpellBookItemName(i, BOOKTYPE_SPELL)
		if not spellName then do break end end	   
		local name, rank, icon, cost, isFunnel, powerType, castTime, minRange, maxRange = GetSpellInfo(spellName)
		if cost and (cost > 0) then
			spellTable[name] = name .. " (" .. cost .. ")"
		end
		i = i + 1
	end
	return spellTable
end

local function LockDown(func)
	if not Serenity.V["MoversLocked"] then
		Serenity.V["MoversLocked"] = not Serenity.V["MoversLocked"]
		Serenity.LockAllMovers() 
	end	
	func()
end

function SerenityOptions:PopulateDB()
	DB = Serenity.db.profile
end

function SerenityOptions:OnInitialize()

	-- Populate the local DB upvalue variable
	SerenityOptions:PopulateDB()
	
	-- Flag the options as being loaded
	Serenity.V.OptionsLoaded = true

	-- Create a second Locale instance for SerenityOptions locale.
	L2 = LibStub("AceLocale-3.0"):GetLocale("SerenityOptions", false)

	-- Global tables for use in options
	fontFlagTable["OUTLINE"] = L2["OUTLINE"]
	fontFlagTable["THICKOUTLINE"] = L2["THICKOUTLINE"]
	fontFlagTable["MONOCHROME"] = L2["MONOCHROME"]
	
	-- Remove any Serenity options panels before making new ones.
	Serenity.RemoveInterfaceOptions("SerenityProfiles", nil, "Serenity", Serenity.L["Profiles"])
	Serenity.RemoveInterfaceOptions("SerenityOptions", nil, nil, "Serenity")

	-- The LOD button has a gametooltip, if we don't hide it, it lingers.
	GameTooltip:Hide()
	
	-- Register the options table
	LibStub("AceConfigRegistry-3.0"):RegisterOptionsTable("SerenityOptions", SerenityOptions.SetupOptions)
	
	-- Create a profiles table
	Serenity.profileOptions = LibStub("AceDBOptions-3.0"):GetOptionsTable(Serenity.db)
	LibStub("AceConfig-3.0"):RegisterOptionsTable("SerenityProfiles", Serenity.profileOptions)

	-- Setup the actual options panels
	local AceConfigDialog3 = LibStub("AceConfigDialog-3.0")
	Serenity.optionsFrames = {}
	Serenity.optionsFrames.SerenityOptions = AceConfigDialog3:AddToBlizOptions("SerenityOptions", "Serenity", nil, "main")
	Serenity.optionsFrames.SerenityOptions.template = AceConfigDialog3:AddToBlizOptions("SerenityOptions", L2["Template"], "Serenity", "template")
	Serenity.optionsFrames.SerenityOptions.frames = AceConfigDialog3:AddToBlizOptions("SerenityOptions", L2["Styling"], "Serenity", "frames")
	Serenity.optionsFrames.SerenityOptions.energybar = AceConfigDialog3:AddToBlizOptions("SerenityOptions", L2["Energy Bar"], "Serenity", "energybar")
	Serenity.optionsFrames.SerenityOptions.enrage = AceConfigDialog3:AddToBlizOptions("SerenityOptions", L2["Enrage Alert"], "Serenity", "enrage")
	Serenity.optionsFrames.SerenityOptions.crowdcontrol = AceConfigDialog3:AddToBlizOptions("SerenityOptions", L2["Crowd Control"], "Serenity", "crowdcontrol")
	Serenity.optionsFrames.SerenityOptions.indicators = AceConfigDialog3:AddToBlizOptions("SerenityOptions", L2["Indicators"], "Serenity", "indicators")
	Serenity.optionsFrames.SerenityOptions.timers = AceConfigDialog3:AddToBlizOptions("SerenityOptions", L2["Timers"], "Serenity", "timers")
	Serenity.optionsFrames.SerenityOptions.icons = AceConfigDialog3:AddToBlizOptions("SerenityOptions", L2["Timer Icons"], "Serenity", "icons")
	Serenity.optionsFrames.SerenityOptions.interrupts = AceConfigDialog3:AddToBlizOptions("SerenityOptions", L2["Interrupts"], "Serenity", "interrupts")
	Serenity.optionsFrames.SerenityOptions.threattransfer = AceConfigDialog3:AddToBlizOptions("SerenityOptions", L2["Threat Transfer"], "Serenity", "threattransfer")
	Serenity.optionsFrames.SerenityOptions.alerts = AceConfigDialog3:AddToBlizOptions("SerenityOptions", L2["Alerts"], "Serenity", "alerts")
	Serenity.optionsFrames.SerenityOptions.profiles = AceConfigDialog3:AddToBlizOptions("SerenityProfiles", Serenity.L["Profiles"], "Serenity")	

	SerenityOptions.OnInitialize = nil
	
	-- Make the Blizzard Interface Options screen movable, why it's not by default is baffling.
	_G["InterfaceOptionsFrame"]:SetMovable()
	_G["InterfaceOptionsFrame"]:SetClampedToScreen()
	_G["InterfaceOptionsFrame"]:RegisterForDrag("LeftButton","RightButton")
	_G["InterfaceOptionsFrame"]:SetScript("OnDragStart", function() _G["InterfaceOptionsFrame"]:StartMoving() end)
	_G["InterfaceOptionsFrame"]:SetScript("OnDragStop", function() _G["InterfaceOptionsFrame"]:StopMovingOrSizing() end)
	
	collectgarbage("collect")
end

function SerenityOptions:CreateTimerSets()

	-- Have to be sure someone does not try to create a timer by the same name as a hard-coded key.  Probably will never happen, but people do dumb shit.
	local timersetsitemtableblacklist = { "intro", "movers", "timers", "cooldowns", "energybar" }
	local k,v
	for k,v in pairs(Serenity.V["timerset_defaults"]) do
		timersetsitemtableblacklist[#timersetsitemtableblacklist + 1] = k
	end	
	for k,v in pairs(DB.timers) do
		timersetsitemtableblacklist[#timersetsitemtableblacklist + 1] = k
	end
	
	local timersetstable = {
		intro = {
			order = 1,
			type = "description",
			name = L2["TIMERS_DESC"].."\n",
		},
		newset = {
			order = 2,
			type = 'input',
			name = L2["New timer set"],
			desc = L2["Creates a new timer set."],
			confirm = function(info, value)
					return(((strtrim(value) == "") or tContains(timersetsitemtableblacklist, value) or (DB.timers[value] ~= nil)) and false or format(L2["CONFIRM_NEWTIMERSET"], value)) 
				end,
			get = function(info) return("") end,
			set = function(info, value)
					value = strtrim(value)
					if (value == "") or tContains(timersetsitemtableblacklist, value) then
						print(Serenity.L["SERENITY_PRE"]..format(L2["Invalid timer set name!"], value))
						return
					elseif DB.timers[value] ~= nil then
						print(Serenity.L["SERENITY_PRE"]..format(L2["You already have a set with that name!"], value))							
						return
					end
					local timerset = {}
					-- Timer set defaults
					timerset = Serenity.DeepCopy(Serenity.V["timerset_defaults"])					
					-- Frame styling defaults					
					DB.frames.timers[value] = Serenity.DeepCopy(Serenity.V.templates[DB["basetemplate"] ].frames.timers)
					DB.timers[value] = timerset
					
					table.sort(DB.timers, function(a,b) return(a < b) end)					
					
					local serenityOptionsTable = LibStub("AceConfigRegistry-3.0"):GetOptionsTable("SerenityOptions", "dialog", "SerenityNullLib-1.0")
					-- Re-Inject the new timer set frame
					SerenityOptions:CreateFrameTimerSets(serenityOptionsTable.args.frames.args)
					LibStub("AceConfigRegistry-3.0"):NotifyChange("SerenityOptions")
					
					print(Serenity.L["SERENITY_PRE"]..format(L2["New timer set '%s' created."], value))
					SerenityOptions:UpdateTimerSets()
				end,
		},
		spacer1 = { order = 3, type = "description", name = " ", desc = "", },
	}
			
	local ord, ord2 = 4, 20
	local key, value, k, v 
	for key,value in pairs(DB.timers) do
		if DB.timers[key] ~= nil then -- Technically should never be nil!
			timersetstable[key] = {
				order = ord,
				type = "group",
				name = key,
				childGroups = "tree",
				args = {
					enabled = {
						type = "toggle",
						order = 1,
						name = L2["Enable"],
						desc = L2["TIMERDESC_ENABLE"],
						width = "full",
						get = function(info) return DB.timers[info[#info-1] ][info[#info] ] end,
						set = function(info, value) DB.timers[info[#info-1] ][info[#info] ] = value;LockDown(Serenity.SetupTimersModule) end,
					},
					addnew = {
						order = 2,
						type = "execute",
						name = L2["Add a new timer for this set"],
						image = "Interface\\Icons\\Spell_ChargePositive",
						confirm = function() return(L2["ADDTIMER_CONFIRM"]) end,
						func = function(info)
								DB.timers[info[#info-1] ].timers[#DB.timers[info[#info-1] ].timers + 1] = Serenity.DeepCopy(Serenity.V["newtimer_default"])
								table.sort(DB.timers[info[#info-1] ].timers, function(a,b)
									local aComp = (a[1] ~= nil) and (tonumber(a[1]) and (select(1, GetSpellInfo(a[1]))) or a[1]) or (tonumber(a[2]) and (select(1, GetItemInfo(a[2]))) or a[2])
									local bComp = (b[1] ~= nil) and (tonumber(b[1]) and (select(1, GetSpellInfo(b[1]))) or b[1]) or (tonumber(b[2]) and (select(1, GetItemInfo(b[2]))) or b[2])
									return(aComp < bComp)
								end)
								SerenityOptions:UpdateTimerSets()
								
								LockDown(Serenity.SetupTimersModule)
							end,						
					},
					spacer1 = { order = 3, type = "description", name = "", desc = "", },
					activealpha = {
						type = "range",
						order = 4,
						name = L2["Active Alpha"],
						desc = L2["ACTIVEALPHA_DESC"],
						min = 0, max = 1, step = .1,
						isPercent = true,
						disabled = function(info) return not DB.timers[info[#info-1] ]["enabled"] end,
						get = function(info) return (DB.timers[info[#info-1] ][info[#info] ]) end,
						set = function(info, value) DB.timers[info[#info-1] ][info[#info] ] = (value);LockDown(Serenity.SetupTimersModule) end,
					},
					inactivealpha = {
						type = "range",
						order = 5,
						name = L2["Inactive Alpha"],
						desc = L2["INACTIVEALPHA_DESC"],
						min = 0, max = 1, step = .1,
						isPercent = true,
						disabled = function(info) return not DB.timers[info[#info-1] ]["enabled"] end,
						get = function(info) return (DB.timers[info[#info-1] ][info[#info] ]) end,
						set = function(info, value) DB.timers[info[#info-1] ][info[#info] ] = (value);LockDown(Serenity.SetupTimersModule) end,
					},
					oocoverride = {
						type = "toggle",
						order = 6,
						name = L2["Enable OOC Override"],
						desc = L2["ENABLEOOCOVERRIDE_DESC"],
						disabled = function(info) return not DB.timers[info[#info-1] ]["enabled"] end,
						get = function(info) return DB.timers[info[#info-1] ][info[#info] ] end,
						set = function(info, value) DB.timers[info[#info-1] ][info[#info] ] = value;LockDown(Serenity.SetupTimersModule) end,
					},
					oocoverridealpha = {
						type = "range",
						order = 7,
						name = L2["OOC Alpha"],
						desc = L2["OOCALPHA_DESC"],
						min = 0, max = 1, step = .1,
						isPercent = true,
						disabled = function(info) 
							if not DB.timers[info[#info-1] ]["oocoverride"] then return true end
							if not DB.timers[info[#info-1] ]["enabled"] then return true end
							return false end,
						get = function(info) return (DB.timers[info[#info-1] ][info[#info] ]) end,
						set = function(info, value) DB.timers[info[#info-1] ][info[#info] ] = (value);LockDown(Serenity.SetupTimersModule) end,
					},
					mountoverride = {
						type = "toggle",
						order = 8,
						name = L2["Enable Mount Override"],
						desc = L2["ENABLEMOUNTOVERRIDE_DESC"],
						disabled = function(info) return not DB.timers[info[#info-1] ]["enabled"] end,
						get = function(info) return DB.timers[info[#info-1] ][info[#info] ] end,
						set = function(info, value) DB.timers[info[#info-1] ][info[#info] ] = value;LockDown(Serenity.SetupTimersModule) end,
					},
					mountoverridealpha = {
						type = "range",
						order = 9,
						name = L2["Mount Alpha"],
						desc = L2["MOUNTALPHA_DESC"],
						min = 0, max = 1, step = .1,
						isPercent = true,
						disabled = function(info) 
							if not DB.timers[info[#info-1] ]["mountoverride"] then return true end
							if not DB.timers[info[#info-1] ]["enabled"] then return true end
							return false end,
						get = function(info) return (DB.timers[info[#info-1] ][info[#info] ]) end,
						set = function(info, value) DB.timers[info[#info-1] ][info[#info] ] = (value);LockDown(Serenity.SetupTimersModule) end,
					},
					deadoverride = {
						type = "toggle",
						order = 10,
						name = L2["Enable Dead Override"],
						desc = L2["ENABLEDEADOVERRIDE_DESC"],
						disabled = function(info) return not DB.timers[info[#info-1] ]["enabled"] end,
						get = function(info) return DB.timers[info[#info-1] ][info[#info] ] end,
						set = function(info, value) DB.timers[info[#info-1] ][info[#info] ] = value;LockDown(Serenity.SetupTimersModule) end,
					},
					deadoverridealpha = {
						type = "range",
						order = 11,
						name = L2["Dead Alpha"],
						desc = L2["DEADALPHA_DESC"],
						min = 0, max = 1, step = .1,
						isPercent = true,
						disabled = function(info) 
							if not DB.timers[info[#info-1] ]["deadoverride"] then return true end
							if not DB.timers[info[#info-1] ]["enabled"] then return true end
							return false end,
						get = function(info) return (DB.timers[info[#info-1] ][info[#info] ]) end,
						set = function(info, value) DB.timers[info[#info-1] ][info[#info] ] = (value);LockDown(Serenity.SetupTimersModule) end,
					},
					layout = {
						order = 12,
						type = "select",
						name = L2["Set's orientation"],
						desc = L2["TIMERORIENTATION_DESC"],
						style = "dropdown",
						values = function() 
								local t = {	["horizontal"] = L2["Horizontal"], ["vertical"] = L2["Vertical"], }
								return(t)
							end,
						get = function(info) return(DB.timers[info[#info-1] ][info[#info] ]) end,
						set = function(info, value) DB.timers[info[#info-1] ][info[#info] ] = value;LockDown(Serenity.SetupTimersModule) end,
					},
					reverse = {
						type = "toggle",
						order = 13,
						name = L2["Reverse movement"],
						desc = L2["REVERSEDESC_ENABLE"],
						width = "full",
						get = function(info) return DB.timers[info[#info-1] ][info[#info] ] end,
						set = function(info, value) DB.timers[info[#info-1] ][info[#info] ] = value;LockDown(Serenity.SetupTimersModule) end,
					},
					spacer2 = { order = 48, type = "description", name = " ", desc = "", width = "full"},
					delete = {
						order = 49,
						type = "execute",
						name = L2["Delete this set"],
						image = "Interface\\Icons\\Spell_ChargeNegative",
						confirm = function(info) return(L2["DELETETIMERSET_CONFIRM"]) end,
						func = function(info)
								DB.frames.timers[info[#info-1] ] = nil
								DB.timers[info[#info-1] ] = nil
								
								local serenityOptionsTable = LibStub("AceConfigRegistry-3.0"):GetOptionsTable("SerenityOptions", "dialog", "SerenityNullLib-1.0")
								serenityOptionsTable.args.frames.args[info[#info-1] ] = nil
								-- Re-Inject the timer set frames
								SerenityOptions:CreateFrameTimerSets(serenityOptionsTable.args.frames.args)
								LibStub("AceConfigRegistry-3.0"):NotifyChange("SerenityOptions")
								
								print(Serenity.L["SERENITY_PRE"]..format(L2["Timer set '%s' deleted."], info[#info-1]))
								SerenityOptions:UpdateTimerSets()
								LockDown(Serenity.SetupTimersModule)
							end,							
					},
				},
			}
			ord = ord + 1
			
			-- Inject the timers into the sets.
			local i, timername
			for i=1,#DB.timers[key].timers do
				timername = "timer" .. i
				timersetstable[key].args[timername] = {
					order = ord2,
					type = "group",
					name = function(info)
							local t
							if DB.timers[info[#info-1] ].timers[tonumber(strsub(info[#info],6))][2] == nil then
								t = DB.timers[info[#info-1] ].timers[tonumber(strsub(info[#info],6))][1]
								if tonumber(t) then
									return(select(1, GetSpellInfo(tonumber(t))) or t)
								end
								return(t)
							end
							
							t = DB.timers[info[#info-1] ].timers[tonumber(strsub(info[#info],6))][2]							
							if tonumber(t) then
								return(select(1, GetItemInfo(tonumber(t))) or t)
							end
							return(t)
						end,
					guiInline = false,
					args = {
						spellicon = {
							order = 1,
							type = "execute",
							name = function(info)
									local t
									if DB.timers[info[#info-2] ].timers[tonumber(strsub(info[#info-1],6))][2] == nil then
										t = DB.timers[info[#info-2] ].timers[tonumber(strsub(info[#info-1],6))][1]
										if tonumber(t) then
											return(select(1, GetSpellInfo(tonumber(t))) or t)
										end
										return(t)
									end
									
									t = DB.timers[info[#info-2] ].timers[tonumber(strsub(info[#info-1],6))][2]							
									if tonumber(t) then
										return(select(1, GetItemInfo(tonumber(t))) or t)
									end
									return(t)
								end,
							desc = L2["SPELLLICON_DESC"],
							func = function() return end,
							image = function(info)
									local t
									local q = "Interface\\ICONS\\INV_Misc_QuestionMark"
									if DB.timers[info[#info-2] ].timers[tonumber(strsub(info[#info-1],6))][2] == nil then
										t = DB.timers[info[#info-2] ].timers[tonumber(strsub(info[#info-1],6))][1]
										if tonumber(t) then
											return(select(3, GetSpellInfo(tonumber(t))) or q)
										end
										if GetSpellInfo(t) then
											return(select(3, GetSpellInfo(t)) or q)
										end
										return(q)
									end
									
									t = DB.timers[info[#info-2] ].timers[tonumber(strsub(info[#info-1],6))][2]							
									if tonumber(t) then
										return(select(10, GetItemInfo(tonumber(t))) or q)
									end
									if GetItemInfo(t) then
										return(select(10, GetItemInfo(t)) or q)
									end
									return(q)
								end,
						},
						a = { -- Spell name or ID.
							order = 2,
							type = "input",
							name = L2["Enter a Spell Name or ID.."],
							desc = L2["SPELL_DESC"],
							confirm = function(info)
									if DB.timers[info[#info-2] ].timers[tonumber(strsub(info[#info-1],6))][2] ~= nil then
										return(L2["CHANGETOSPELL_CONFIRM"])
									end							
									return(false)
								end,
							validate = function(info, val)
									if GetSpellInfo(tonumber(val) and tonumber(val) or val) then return(true) end
									if tonumber(val) then -- If it's a Spell ID number we CAN verify it.
										print(Serenity.L["SERENITY_PRE"].."|cffff0000"..L2["TIMERSPELL_INVALID"].."|r")
										return(false) 
									end
									-- If it's not a Spell ID number we can only verify it if the player HAS that spell in his book.
									if not (GetSpellInfo(val)) then -- Try to verify, if it does then we don't need to show the unverified warning.
										print(Serenity.L["SERENITY_PRE"].."|cffff0000"..L2["TIMERSPELL_UNVERIFIED"].."|r")
									end
									return(true)
								end,
							get = function(info) return(DB.timers[info[#info-2] ].timers[tonumber(strsub(info[#info-1],6))][1] ~= nil and 
									tostring(DB.timers[info[#info-2] ].timers[tonumber(strsub(info[#info-1],6))][1]) or "") end,
							set = function(info, val)
									DB.timers[info[#info-2] ].timers[tonumber(strsub(info[#info-1],6))][2] = nil
									DB.timers[info[#info-2] ].timers[tonumber(strsub(info[#info-1],6))][1] = (tonumber(val) and tonumber(val) or val)
									
									table.sort(DB.timers[info[#info-2] ].timers, function(a,b)
										local aComp = (a[1] ~= nil) and (tonumber(a[1]) and (select(1, GetSpellInfo(a[1]))) or a[1]) or (tonumber(a[2]) and (select(1, GetItemInfo(a[2]))) or a[2])
										local bComp = (b[1] ~= nil) and (tonumber(b[1]) and (select(1, GetSpellInfo(b[1]))) or b[1]) or (tonumber(b[2]) and (select(1, GetItemInfo(b[2]))) or b[2])
										return(aComp < bComp)
									end)
									
									LibStub("AceConfigRegistry-3.0"):NotifyChange("SerenityOptions")
									collectgarbage("collect")
									LockDown(Serenity.SetupTimersModule)
								end,
						},
						b = { -- Item name or ID.
							order = 3,
							type = "input",
							name = L2["..or an Item Name or ID"],
							desc = L2["ITEM_DESC"],
							confirm = function(info)
									if DB.timers[info[#info-2] ].timers[tonumber(strsub(info[#info-1],6))][1] ~= nil then
										return(L2["CHANGETOITEM_CONFIRM"])
									end							
									return(false)
								end,
							validate = function(info, val)
									if GetItemInfo(tonumber(val) and tonumber(val) or val) then return(true) end
									if tonumber(val) then -- If it's an Item ID number we CAN verify it.
										print(Serenity.L["SERENITY_PRE"].."|cffff0000"..L2["TIMERITEM_INVALID"].."|r")
										return(false) 
									end
									-- If it's not an Item ID number we can only verify it if the player HAS that item.
									if not (GetItemInfo(val)) then -- Try to verify, if it does then we don't need to show the unverified warning.
										print(Serenity.L["SERENITY_PRE"].."|cffff0000"..L2["TIMERITEM_UNVERIFIED"].."|r")
									end
									return(true)
								end,
							get = function(info) return(DB.timers[info[#info-2] ].timers[tonumber(strsub(info[#info-1],6))][2] ~= nil and
									tostring(DB.timers[info[#info-2] ].timers[tonumber(strsub(info[#info-1],6))][2]) or "") end,
							set = function(info, val)
									DB.timers[info[#info-2] ].timers[tonumber(strsub(info[#info-1],6))][1] = nil
									DB.timers[info[#info-2] ].timers[tonumber(strsub(info[#info-1],6))][2] = (tonumber(val) and tonumber(val) or val)
									
									table.sort(DB.timers[info[#info-2] ].timers, function(a,b)
										local aComp = (a[1] ~= nil) and (tonumber(a[1]) and (select(1, GetSpellInfo(a[1]))) or a[1]) or (tonumber(a[2]) and (select(1, GetItemInfo(a[2]))) or a[2])
										local bComp = (b[1] ~= nil) and (tonumber(b[1]) and (select(1, GetSpellInfo(b[1]))) or b[1]) or (tonumber(b[2]) and (select(1, GetItemInfo(b[2]))) or b[2])
										return(aComp < bComp)
									end)
									
									LibStub("AceConfigRegistry-3.0"):NotifyChange("SerenityOptions")
									collectgarbage("collect")
									LockDown(Serenity.SetupTimersModule)
								end,
						},
						c = { -- Target to check for the spell.
							order = 4,
							type = "select",
							name = L2["Check Target"],
							desc = L2["CHECKTARGET_DESC"],
							hidden = function(info) return((DB.timers[info[#info-2] ].timers[tonumber(strsub(info[#info-1],6))][2] ~= nil) and true or false) end,
							style = "dropdown",
							values = function() return Serenity.V["targets"] end,
							get = function(info) return DB.timers[info[#info-2] ].timers[tonumber(strsub(info[#info-1],6))][3] end,
							set = function(info, value) DB.timers[info[#info-2] ].timers[tonumber(strsub(info[#info-1],6))][3] = value;LockDown(Serenity.SetupTimersModule) end,
						},
						d = { -- Duration or cooldown
							order = 5,
							type = "select",
							name = L2["Duration or Cooldown"],
							desc = L2["DURORCD_DESC"],
							hidden = function(info) return((DB.timers[info[#info-2] ].timers[tonumber(strsub(info[#info-1],6))][2] ~= nil) and true or false) end,
							style = "dropdown",
							values = function() 
									local t = {	["DURATION"] = L2["Duration"], ["COOLDOWN"] = L2["Cooldown"], }
									return(t)
								end,
							get = function(info) return(DB.timers[info[#info-2] ].timers[tonumber(strsub(info[#info-1],6))][4]) end,
							set = function(info, value) DB.timers[info[#info-2] ].timers[tonumber(strsub(info[#info-1],6))][4] = (value);LockDown(Serenity.SetupTimersModule) end,
						},
						e = { -- Owner
							order = 6,
							type = "select",
							name = L2["Owner of spell"],
							desc = L2["SPELLOWNER_DESC"],
							hidden = function(info) return((DB.timers[info[#info-2] ].timers[tonumber(strsub(info[#info-1],6))][2] ~= nil) and true or false) end,
							style = "dropdown",
							values = function() return Serenity.V["timerowners"] end,
							get = function(info) return(DB.timers[info[#info-2] ].timers[tonumber(strsub(info[#info-1],6))][5]) end,
							set = function(info, value) DB.timers[info[#info-2] ].timers[tonumber(strsub(info[#info-1],6))][5] = (value);LockDown(Serenity.SetupTimersModule) end,
						},
						f = { -- Spec
							order = 7,
							type = "select",
							name = L2["Talent Spec"],
							desc = L2["TALENTSPEC_DESC"],
							style = "dropdown",
							values = function()
									local t = {
										["0"] = L2["Any Spec"],
										["1"] = select(2, GetTalentTabInfo(1)),
										["2"] = select(2, GetTalentTabInfo(2)),
										["3"] = select(2, GetTalentTabInfo(3)),
									}
									return(t)
								end,
							get = function(info) return(tostring(DB.timers[info[#info-2] ].timers[tonumber(strsub(info[#info-1],6))][6])) end,
							set = function(info, value) DB.timers[info[#info-2] ].timers[tonumber(strsub(info[#info-1],6))][6] = tonumber(value);LockDown(Serenity.SetupTimersModule) end,
						},
						g = { -- Timer text position
							order = 8,
							type = "select",
							name = L2["Positon of timer text"],
							desc = L2["TIMERTEXTPOS_DESC"],
							style = "dropdown",
							values = function()
									local t = Serenity.DeepCopy(Serenity.V["timerpositions"])
									t["NONE"] = L2["NONE"]
									return(t) 
								end,
							get = function(info) return(DB.timers[info[#info-2] ].timers[tonumber(strsub(info[#info-1],6))][7]) end,
							set = function(info, value) DB.timers[info[#info-2] ].timers[tonumber(strsub(info[#info-1],6))][7] = (value);LockDown(Serenity.SetupTimersModule) end,
						},
						h = { -- Flash
							type = "toggle",
							order = 9,
							name = L2["Flash when expiring"],
							desc = L2["EXPIREFLASH_ENABLE"],
							width = "full",
							get = function(info) return(DB.timers[info[#info-2] ].timers[tonumber(strsub(info[#info-1],6))][8]) end,
							set = function(info, value) DB.timers[info[#info-2] ].timers[tonumber(strsub(info[#info-1],6))][8] = value;LockDown(Serenity.SetupTimersModule) end,
						},
						i = { -- Spin
							type = "toggle",
							order = 10,
							name = L2["Spin when expiring"],
							desc = L2["EXPIRESPIN_ENABLE"],
							width = "full",
							get = function(info) return(DB.timers[info[#info-2] ].timers[tonumber(strsub(info[#info-1],6))][9]) end,
							set = function(info, value) DB.timers[info[#info-2] ].timers[tonumber(strsub(info[#info-1],6))][9] = value;LockDown(Serenity.SetupTimersModule) end,
						},
						j = { -- Grow
							type = "toggle",
							order = 11,
							name = L2["Grow when expiring"],
							desc = L2["EXPIREGROW_ENABLE"],
							width = "full",
							get = function(info) return(DB.timers[info[#info-2] ].timers[tonumber(strsub(info[#info-1],6))][10]) end,
							set = function(info, value) DB.timers[info[#info-2] ].timers[tonumber(strsub(info[#info-1],6))][10] = value;LockDown(Serenity.SetupTimersModule) end,
						},
						k = { -- Grow Start
							type = "range", 
							order = 12,
							name = L2["Grow start %"],
							desc = L2["GROWSTART_DESC"],
							hidden = function(info) return(not DB.timers[info[#info-2] ].timers[tonumber(strsub(info[#info-1],6))][10]) end,
							isPercent = true,
							min = .1, max = 1, step = .1,
							get = function(info) return(DB.timers[info[#info-2] ].timers[tonumber(strsub(info[#info-1],6))][11]) end,
							set = function(info, size) DB.timers[info[#info-2] ].timers[tonumber(strsub(info[#info-1],6))][11] = (size);LockDown(Serenity.SetupTimersModule) end,
						},
						spacer1 = { order = 13, type = "description", name = "", desc = "", width = "full"},
						l = { -- Grow Size
							type = "range", 
							order = 14,
							name = L2["Grow size %"],
							desc = L2["GROWSIZE_DESC"],
							hidden = function(info) return(not DB.timers[info[#info-2] ].timers[tonumber(strsub(info[#info-1],6))][10]) end,
							isPercent = true,
							min = 1.1, max = 3, step = .1,
							get = function(info) return(DB.timers[info[#info-2] ].timers[tonumber(strsub(info[#info-1],6))][12]) end,
							set = function(info, size) DB.timers[info[#info-2] ].timers[tonumber(strsub(info[#info-1],6))][12] = (size);LockDown(Serenity.SetupTimersModule) end,
						},
						m = { -- Alpha Change
							type = "toggle",
							order = 15,
							name = L2["Alpha Change"],
							desc = L2["EXPIREALPHA_ENABLE"],
							width = "full",
							get = function(info) return(DB.timers[info[#info-2] ].timers[tonumber(strsub(info[#info-1],6))][13]) end,
							set = function(info, value) DB.timers[info[#info-2] ].timers[tonumber(strsub(info[#info-1],6))][13] = value;LockDown(Serenity.SetupTimersModule) end,
						},
						n = { -- Alpha Change - Start
							type = "range", 
							order = 16,
							name = L2["Alpha start %"],
							desc = L2["ALPHASTART_DESC"],
							hidden = function(info) return(not DB.timers[info[#info-2] ].timers[tonumber(strsub(info[#info-1],6))][13]) end,
							isPercent = true,
							min = 0, max = 1, step = .1,
							get = function(info) return(DB.timers[info[#info-2] ].timers[tonumber(strsub(info[#info-1],6))][14]) end,
							set = function(info, size) DB.timers[info[#info-2] ].timers[tonumber(strsub(info[#info-1],6))][14] = (size);LockDown(Serenity.SetupTimersModule) end,
						},
						o = { -- Alpha Change - End
							type = "range", 
							order = 17,
							name = L2["Alpha end %"],
							desc = L2["ALPHAEND_DESC"],
							hidden = function(info) return(not DB.timers[info[#info-2] ].timers[tonumber(strsub(info[#info-1],6))][13]) end,
							isPercent = true,
							min = 0, max = 1, step = .1,
							get = function(info) return(DB.timers[info[#info-2] ].timers[tonumber(strsub(info[#info-1],6))][15]) end,
							set = function(info, size) DB.timers[info[#info-2] ].timers[tonumber(strsub(info[#info-1],6))][15] = (size);LockDown(Serenity.SetupTimersModule) end,
						},
						spacer2 = { order = 50, type = "description", name = "\n", desc = "", width = "full"},
						delete = {
							order = 51,
							type = "execute",
							name = L2["Delete this timer"],
							image = "Interface\\Icons\\Spell_ChargeNegative",
							confirm = function(info) return(L2["DELETETIMER_CONFIRM"]) end,
							func = function(info)
									tremove(DB.timers[info[#info-2] ].timers, tonumber(strsub(info[#info-1],6)))
									LibStub("AceConfigRegistry-3.0"):NotifyChange("SerenityOptions")
									LockDown(Serenity.SetupTimersModule)
								end,							
						},
					},					
				}
				ord2 = ord2 + 1
			end

		end
	end	
	
	return timersetstable
end

function SerenityOptions:CreateIconBlocks()

	-- Have to be sure someone does not try to create an icon by the same name as a hard-coded key.  Probably will never happen, but people do dumb shit.
	local iconblocksitemtableblacklist = { "intro", "movers", "icons", "cooldowns", "energybar" }
	local k,v
	for k,v in pairs(Serenity.V["timerset_defaults"]) do
		iconblocksitemtableblacklist[#iconblocksitemtableblacklist + 1] = k
	end	
	for k,v in pairs(DB.icons) do
		iconblocksitemtableblacklist[#iconblocksitemtableblacklist + 1] = k
	end	
	
	local iconblockstable = {
		intro = {
			order = 1,
			type = "description",
			name = L2["ICONS_DESC"].."\n",
		},
		newset = {
			order = 2,
			type = 'input',
			name = L2["New icon block"],
			desc = L2["Creates a new block of icons."],
			confirm = function(info, value)
					return(((strtrim(value) == "") or tContains(iconblocksitemtableblacklist, value) or (DB.icons[value] ~= nil)) and false or format(L2["CONFIRM_NEWICONBLOCK"], value)) 
				end,
			get = function(info) return("") end,
			set = function(info, value)
					value = strtrim(value)
					if (value == "") or tContains(iconblocksitemtableblacklist, value) then
						print(Serenity.L["SERENITY_PRE"]..format(L2["Invalid icon block name!"], value))
						return
					elseif DB.icons[value] ~= nil then
						print(Serenity.L["SERENITY_PRE"]..format(L2["You already have a block with that name!"], value))							
						return
					end
					-- Frame styling defaults					
					DB.frames.icons[value] = Serenity.DeepCopy(Serenity.V.templates[DB["basetemplate"] ].frames.icons)
					DB.icons[value] = Serenity.DeepCopy(Serenity.V["iconblock_defaults"])
					
					table.sort(DB.icons, function(a,b) return(a < b) end)					
					
					local serenityOptionsTable = LibStub("AceConfigRegistry-3.0"):GetOptionsTable("SerenityOptions", "dialog", "SerenityNullLib-1.0")
					-- Re-Inject the new timer set frame
					SerenityOptions:CreateFrameIconBlocks(serenityOptionsTable.args.frames.args)
					LibStub("AceConfigRegistry-3.0"):NotifyChange("SerenityOptions")
					
					print(Serenity.L["SERENITY_PRE"]..format(L2["New icon block '%s' created."], value))
					SerenityOptions:UpdateIconBlocks()
				end,
		},
		spacer1 = { order = 3, type = "description", name = " ", desc = "", },
	}

	local ord, ord2 = 24, 40
	local key, value, k, v 
	for key,value in pairs(DB.icons) do
		if DB.icons[key] ~= nil then -- Technically should never be nil!
			iconblockstable[key] = {
				order = ord,
				type = "group",
				name = key,
				childGroups = "tree",
				args = {
					enabled = {
						type = "toggle",
						order = 1,
						name = L2["Enable"],
						desc = L2["ICONDESC_ENABLE"],
						width = "full",
						get = function(info) return DB.icons[info[#info-1] ][info[#info] ] end,
						set = function(info, value) DB.icons[info[#info-1] ][info[#info] ] = value;LockDown(Serenity.SetupIconsModule) end,
					},
					addnew = {
						order = 2,
						type = "execute",
						name = L2["Add a new icon for this block"],
						image = "Interface\\Icons\\Spell_ChargePositive",
						confirm = function() return(L2["ADDICON_CONFIRM"]) end,
						func = function(info)
								DB.icons[info[#info-1] ].icons[#DB.icons[info[#info-1] ].icons + 1] = Serenity.DeepCopy(Serenity.V["newicon_default"])
								DB.icons[info[#info-1] ].icons[#DB.icons[info[#info-1] ].icons][16] = #DB.icons[info[#info-1] ].icons

								SerenityOptions:UpdateIconBlocks()
								LibStub("AceConfigDialog-3.0"):SelectGroup("SerenityOptions", "icons", info[#info-1], "icon".. #DB.icons[info[#info-1] ].icons)
								LockDown(Serenity.SetupIconsModule)
							end,						
					},
					spacer1 = { order = 3, type = "description", name = " ", desc = "" },
					activealpha = {
						type = "range",
						order = 4,
						name = L2["Active Alpha"],
						desc = L2["ACTIVEICONALPHA_DESC"],
						min = 0, max = 1, step = .1,
						isPercent = true,
						disabled = function(info) return not DB.icons[info[#info-1] ]["enabled"] end,
						get = function(info) return (DB.icons[info[#info-1] ][info[#info] ]) end,
						set = function(info, value) DB.icons[info[#info-1] ][info[#info] ] = (value);LockDown(Serenity.SetupIconsModule) end,
					},
					inactivealpha = {
						type = "range",
						order = 5,
						name = L2["Inactive Alpha"],
						desc = L2["INACTIVEICONALPHA_DESC"],
						min = 0, max = 1, step = .1,
						isPercent = true,
						disabled = function(info) return not DB.icons[info[#info-1] ]["enabled"] end,
						get = function(info) return (DB.icons[info[#info-1] ][info[#info] ]) end,
						set = function(info, value) DB.icons[info[#info-1] ][info[#info] ] = (value);LockDown(Serenity.SetupIconsModule) end,
					},
					oocoverride = {
						type = "toggle",
						order = 6,
						name = L2["Enable OOC Override"],
						desc = L2["ENABLEICONOOCOVERRIDE_DESC"],
						disabled = function(info) return not DB.icons[info[#info-1] ]["enabled"] end,
						get = function(info) return DB.icons[info[#info-1] ][info[#info] ] end,
						set = function(info, value) DB.icons[info[#info-1] ][info[#info] ] = value;LockDown(Serenity.SetupIconsModule) end,
					},
					oocoverridealpha = {
						type = "range",
						order = 7,
						name = L2["OOC Alpha"],
						desc = L2["ICONOOCALPHA_DESC"],
						min = 0, max = 1, step = .1,
						isPercent = true,
						disabled = function(info) 
							if not DB.icons[info[#info-1] ]["oocoverride"] then return true end
							if not DB.icons[info[#info-1] ]["enabled"] then return true end
							return false end,
						get = function(info) return (DB.icons[info[#info-1] ][info[#info] ]) end,
						set = function(info, value) DB.icons[info[#info-1] ][info[#info] ] = (value);LockDown(Serenity.SetupIconsModule) end,
					},
					mountoverride = {
						type = "toggle",
						order = 8,
						name = L2["Enable Mount Override"],
						desc = L2["ENABLEICONMOUNTOVERRIDE_DESC"],
						disabled = function(info) return not DB.icons[info[#info-1] ]["enabled"] end,
						get = function(info) return DB.icons[info[#info-1] ][info[#info] ] end,
						set = function(info, value) DB.icons[info[#info-1] ][info[#info] ] = value;LockDown(Serenity.SetupIconsModule) end,
					},
					mountoverridealpha = {
						type = "range",
						order = 9,
						name = L2["Mount Alpha"],
						desc = L2["ICONMOUNTALPHA_DESC"],
						min = 0, max = 1, step = .1,
						isPercent = true,
						disabled = function(info) 
							if not DB.icons[info[#info-1] ]["mountoverride"] then return true end
							if not DB.icons[info[#info-1] ]["enabled"] then return true end
							return false end,
						get = function(info) return (DB.icons[info[#info-1] ][info[#info] ]) end,
						set = function(info, value) DB.icons[info[#info-1] ][info[#info] ] = (value);LockDown(Serenity.SetupIconsModule) end,
					},
					deadoverride = {
						type = "toggle",
						order = 10,
						name = L2["Enable Dead Override"],
						desc = L2["ENABLEICONDEADOVERRIDE_DESC"],
						disabled = function(info) return not DB.icons[info[#info-1] ]["enabled"] end,
						get = function(info) return DB.icons[info[#info-1] ][info[#info] ] end,
						set = function(info, value) DB.icons[info[#info-1] ][info[#info] ] = value;LockDown(Serenity.SetupIconsModule) end,
					},
					deadoverridealpha = {
						type = "range",
						order = 11,
						name = L2["Dead Alpha"],
						desc = L2["ICONDEADALPHA_DESC"],
						min = 0, max = 1, step = .1,
						isPercent = true,
						disabled = function(info) 
							if not DB.icons[info[#info-1] ]["deadoverride"] then return true end
							if not DB.icons[info[#info-1] ]["enabled"] then return true end
							return false end,
						get = function(info) return (DB.icons[info[#info-1] ][info[#info] ]) end,
						set = function(info, value) DB.icons[info[#info-1] ][info[#info] ] = (value);LockDown(Serenity.SetupIconsModule) end,
					},
					layout = {
						order = 12,
						type = "select",
						name = L2["Block's orientation"],
						desc = L2["BLOCKORIENTATION_DESC"],
						style = "dropdown",
						values = function() 
								local t = {	["horizontal"] = L2["Horizontal"], ["vertical"] = L2["Vertical"], }
								return(t)
							end,
						get = function(info) return(DB.icons[info[#info-1] ][info[#info] ]) end,
						set = function(info, value) DB.icons[info[#info-1] ][info[#info] ] = value;LockDown(Serenity.SetupIconsModule) end,
					},
					reverse = {
						type = "toggle",
						order = 13,
						name = L2["Reverse fill"],
						desc = L2["ICONREVERSEDESC_ENABLE"],
						width = "full",
						get = function(info) return DB.icons[info[#info-1] ][info[#info] ] end,
						set = function(info, value) DB.icons[info[#info-1] ][info[#info] ] = value;LockDown(Serenity.SetupIconsModule) end,
					},
					spacer2 = { order = 48, type = "description", name = " ", desc = "", width = "full"},
					delete = {
						order = 49,
						type = "execute",
						name = L2["Delete this block"],
						image = "Interface\\Icons\\Spell_ChargeNegative",
						confirm = function(info) return(L2["DELETEICONBLOCK_CONFIRM"]) end,
						func = function(info)
								DB.frames.icons[info[#info-1] ] = nil
								DB.icons[info[#info-1] ] = nil
								
								local serenityOptionsTable = LibStub("AceConfigRegistry-3.0"):GetOptionsTable("SerenityOptions", "dialog", "SerenityNullLib-1.0")
								serenityOptionsTable.args.frames.args[info[#info-1] ] = nil
								-- Re-Inject the icon block frames
								SerenityOptions:CreateFrameIconBlocks(serenityOptionsTable.args.frames.args)
								LibStub("AceConfigRegistry-3.0"):NotifyChange("SerenityOptions")
								
								print(Serenity.L["SERENITY_PRE"]..format(L2["Icon block '%s' deleted."], info[#info-1]))
								SerenityOptions:UpdateIconBlocks()
								LockDown(Serenity.SetupIconsModule)
							end,							
					},
				},
			}
			ord = ord + 1

			-- Inject the icons into the blocks.
			local totalIcons = #DB.icons[key].icons
			local i, iconname			
			for i=1,#DB.icons[key].icons do
				iconname = "icon" .. i
				iconblockstable[key].args[iconname] = {
					order = ord2,
					type = "group",
					name = function(info)
							local t
							if DB.icons[info[#info-1] ].icons[tonumber(strsub(info[#info],5))][2] == nil then
								t = DB.icons[info[#info-1] ].icons[tonumber(strsub(info[#info],5))][1]
								if tonumber(t) then
									return(select(1, GetSpellInfo(tonumber(t))) or t)
								end
								return(t)
							end
							
							t = DB.icons[info[#info-1] ].icons[tonumber(strsub(info[#info],5))][2]							
							if tonumber(t) then
								return(select(1, GetItemInfo(tonumber(t))) or t)
							end
							return(t)
						end,
					guiInline = false,
					args = {
						spellicon = {
							order = 1,
							type = "execute",
							name = function(info)
									local t
									if DB.icons[info[#info-2] ].icons[tonumber(strsub(info[#info-1],5))][2] == nil then
										t = DB.icons[info[#info-2] ].icons[tonumber(strsub(info[#info-1],5))][1]
										if tonumber(t) then
											return(select(1, GetSpellInfo(tonumber(t))) or t)
										end
										return(t)
									end
									
									t = DB.icons[info[#info-2] ].icons[tonumber(strsub(info[#info-1],5))][2]							
									if tonumber(t) then
										return(select(1, GetItemInfo(tonumber(t))) or t)
									end
									return(t)
								end,
							desc = L2["SPELLLICON_DESC"],
							func = function() return end,
							image = function(info)
									local t
									local q = "Interface\\ICONS\\INV_Misc_QuestionMark"
									if DB.icons[info[#info-2] ].icons[tonumber(strsub(info[#info-1],5))][2] == nil then
										t = DB.icons[info[#info-2] ].icons[tonumber(strsub(info[#info-1],5))][1]
										if tonumber(t) then
											return(select(3, GetSpellInfo(tonumber(t))) or q)
										end
										if GetSpellInfo(t) then
											return(select(3, GetSpellInfo(t)) or q)
										end
										return(q)
									end
									
									t = DB.icons[info[#info-2] ].icons[tonumber(strsub(info[#info-1],5))][2]							
									if tonumber(t) then
										return(select(10, GetItemInfo(tonumber(t))) or q)
									end
									if GetItemInfo(t) then
										return(select(10, GetItemInfo(t)) or q)
									end
									return(q)
								end,
						},
						a = { -- Spell name or ID.
							order = 2,
							type = "input",
							name = L2["Enter a Spell Name or ID.."],
							desc = L2["SPELL_DESC"],
							confirm = function(info)
									if DB.icons[info[#info-2] ].icons[tonumber(strsub(info[#info-1],5))][2] ~= nil then
										return(L2["CHANGETOSPELL_CONFIRM"])
									end							
									return(false)
								end,
							validate = function(info, val)
									if GetSpellInfo(tonumber(val) and tonumber(val) or val) then return(true) end
									if tonumber(val) then -- If it's a Spell ID number we CAN verify it.
										print(Serenity.L["SERENITY_PRE"].."|cffff0000"..L2["TIMERSPELL_INVALID"].."|r")
										return(false) 
									end
									-- If it's not a Spell ID number we can only verify it if the player HAS that spell in his book.
									if not (GetSpellInfo(val)) then -- Try to verify, if it does then we don't need to show the unverified warning.
										print(Serenity.L["SERENITY_PRE"].."|cffff0000"..L2["TIMERSPELL_UNVERIFIED"].."|r")
									end
									return(true)
								end,
							get = function(info) return(DB.icons[info[#info-2] ].icons[tonumber(strsub(info[#info-1],5))][1] ~= nil and 
									tostring(DB.icons[info[#info-2] ].icons[tonumber(strsub(info[#info-1],5))][1]) or "") end,
							set = function(info, val)
									DB.icons[info[#info-2] ].icons[tonumber(strsub(info[#info-1],5))][2] = nil
									DB.icons[info[#info-2] ].icons[tonumber(strsub(info[#info-1],5))][1] = (tonumber(val) and tonumber(val) or val)
									
									--[[table.sort(DB.icons[info[#info-2] ].icons, function(a,b)
										local aComp = (a[1] ~= nil) and (tonumber(a[1]) and (select(1, GetSpellInfo(a[1]))) or a[1]) or (tonumber(a[2]) and (select(1, GetItemInfo(a[2]))) or a[2])
										local bComp = (b[1] ~= nil) and (tonumber(b[1]) and (select(1, GetSpellInfo(b[1]))) or b[1]) or (tonumber(b[2]) and (select(1, GetItemInfo(b[2]))) or b[2])
										return(aComp < bComp)
									end)]]
									
									LibStub("AceConfigRegistry-3.0"):NotifyChange("SerenityOptions")
									collectgarbage("collect")
									LockDown(Serenity.SetupIconsModule)
								end,
						},
						b = { -- Item name or ID.
							order = 3,
							type = "input",
							name = L2["..or an Item Name or ID"],
							desc = L2["ITEM_DESC"],
							confirm = function(info)
									if DB.icons[info[#info-2] ].icons[tonumber(strsub(info[#info-1],5))][1] ~= nil then
										return(L2["CHANGETOITEM_CONFIRM"])
									end							
									return(false)
								end,
							validate = function(info, val)
									if GetItemInfo(tonumber(val) and tonumber(val) or val) then return(true) end
									if tonumber(val) then -- If it's an Item ID number we CAN verify it.
										print(Serenity.L["SERENITY_PRE"].."|cffff0000"..L2["TIMERITEM_INVALID"].."|r")
										return(false) 
									end
									-- If it's not an Item ID number we can only verify it if the player HAS that item.
									if not (GetItemInfo(val)) then -- Try to verify, if it does then we don't need to show the unverified warning.
										print(Serenity.L["SERENITY_PRE"].."|cffff0000"..L2["TIMERITEM_UNVERIFIED"].."|r")
									end
									return(true)
								end,
							get = function(info) return(DB.icons[info[#info-2] ].icons[tonumber(strsub(info[#info-1],5))][2] ~= nil and
									tostring(DB.icons[info[#info-2] ].icons[tonumber(strsub(info[#info-1],5))][2]) or "") end,
							set = function(info, val)
									DB.icons[info[#info-2] ].icons[tonumber(strsub(info[#info-1],5))][1] = nil
									DB.icons[info[#info-2] ].icons[tonumber(strsub(info[#info-1],5))][2] = (tonumber(val) and tonumber(val) or val)
									
									--[[table.sort(DB.icons[info[#info-2] ].icons, function(a,b)
										local aComp = (a[1] ~= nil) and (tonumber(a[1]) and (select(1, GetSpellInfo(a[1]))) or a[1]) or (tonumber(a[2]) and (select(1, GetItemInfo(a[2]))) or a[2])
										local bComp = (b[1] ~= nil) and (tonumber(b[1]) and (select(1, GetSpellInfo(b[1]))) or b[1]) or (tonumber(b[2]) and (select(1, GetItemInfo(b[2]))) or b[2])
										return(aComp < bComp)
									end)]]
									
									LibStub("AceConfigRegistry-3.0"):NotifyChange("SerenityOptions")
									collectgarbage("collect")
									LockDown(Serenity.SetupIconsModule)
								end,
						},
						pos = { -- Position
							type = "select",
							order = 4,
							name = L2["Position"],
							desc = L2["ICONPOSITION_DESC"],
							values = function()
									local t = {}; local i
									for i=1,totalIcons do t[i] = i end 
									return(t)
								end,
							get = function(info) return(DB.icons[info[#info-2] ].icons[tonumber(strsub(info[#info-1],5))][16]) end,
							set = function(info, newPos)
								local oldPos = DB.icons[info[#info-2] ].icons[tonumber(strsub(info[#info-1],5))][16]
								DB.icons[info[#info-2] ].icons[tonumber(strsub(info[#info-1],5))][16] = (newPos)
								
								-- Now we need to properly re-order these damn things.
								local index
								if newPos > oldPos then
									for index=oldPos,newPos do
										if index ~= tonumber(strsub(info[#info-1],5)) then
											DB.icons[info[#info-2] ].icons[index][16] = DB.icons[info[#info-2] ].icons[index][16] - 1
										end
									end
								else
									for index=newPos,oldPos do
										if index ~= tonumber(strsub(info[#info-1],5)) then
											DB.icons[info[#info-2] ].icons[index][16] = DB.icons[info[#info-2] ].icons[index][16] + 1
										end
									end								
								end
								
								table.sort(DB.icons[info[#info-2] ].icons, function(a,b) return(a[16] < b[16]) end)
								
								SerenityOptions:UpdateIconBlocks(info[#info-2], "icon"..newPos)
								LibStub("AceConfigDialog-3.0"):SelectGroup("SerenityOptions", "icons", info[#info-2], "icon"..newPos)
								LockDown(Serenity.SetupIconsModule) 
							end,
						},
						c = { -- Target to check for the spell.
							order = 9,
							type = "select",
							name = L2["Check Target"],
							desc = L2["CHECKTARGET_DESC"],
							hidden = function(info) return((DB.icons[info[#info-2] ].icons[tonumber(strsub(info[#info-1],5))][2] ~= nil) and true or false) end,
							style = "dropdown",
							values = function() return Serenity.V["targets"] end,
							get = function(info) return DB.icons[info[#info-2] ].icons[tonumber(strsub(info[#info-1],5))][3] end,
							set = function(info, value) DB.icons[info[#info-2] ].icons[tonumber(strsub(info[#info-1],5))][3] = value;LockDown(Serenity.SetupIconsModule) end,
						},
						d = { -- Duration or cooldown
							order = 10,
							type = "select",
							name = L2["Duration or Cooldown"],
							desc = L2["DURORCD_DESC"],
							hidden = function(info) return((DB.icons[info[#info-2] ].icons[tonumber(strsub(info[#info-1],5))][2] ~= nil) and true or false) end,
							style = "dropdown",
							values = function() 
									local t = {	["DURATION"] = L2["Duration"], ["COOLDOWN"] = L2["Cooldown"], }
									return(t)
								end,
							get = function(info) return(DB.icons[info[#info-2] ].icons[tonumber(strsub(info[#info-1],5))][4]) end,
							set = function(info, value) DB.icons[info[#info-2] ].icons[tonumber(strsub(info[#info-1],5))][4] = (value);LockDown(Serenity.SetupIconsModule) end,
						},
						e = { -- Owner
							order = 11,
							type = "select",
							name = L2["Owner of spell"],
							desc = L2["SPELLOWNER_DESC"],
							hidden = function(info) return((DB.icons[info[#info-2] ].icons[tonumber(strsub(info[#info-1],5))][2] ~= nil) and true or false) end,
							style = "dropdown",
							values = function() return Serenity.V["timerowners"] end,
							get = function(info) return(DB.icons[info[#info-2] ].icons[tonumber(strsub(info[#info-1],5))][5]) end,
							set = function(info, value) DB.icons[info[#info-2] ].icons[tonumber(strsub(info[#info-1],5))][5] = (value);LockDown(Serenity.SetupIconsModule) end,
						},
						f = { -- Spec
							order = 12,
							type = "select",
							name = L2["Talent Spec"],
							desc = L2["TALENTSPEC_DESC"],
							style = "dropdown",
							values = function()
									local t = {
										["0"] = L2["Any Spec"],
										["1"] = select(2, GetTalentTabInfo(1)),
										["2"] = select(2, GetTalentTabInfo(2)),
										["3"] = select(2, GetTalentTabInfo(3)),
									}
									return(t)
								end,
							get = function(info) return(tostring(DB.icons[info[#info-2] ].icons[tonumber(strsub(info[#info-1],5))][6])) end,
							set = function(info, value) DB.icons[info[#info-2] ].icons[tonumber(strsub(info[#info-1],5))][6] = tonumber(value);LockDown(Serenity.SetupIconsModule) end,
						},
						g = { -- Timer text position
							order = 13,
							type = "select",
							name = L2["Positon of timer text"],
							desc = L2["TIMERTEXTPOS_DESC"],
							style = "dropdown",
							values = function()
									local t = Serenity.DeepCopy(Serenity.V["timerpositions"])
									t["NONE"] = L2["NONE"]
									return(t) 
								end,
							get = function(info) return(DB.icons[info[#info-2] ].icons[tonumber(strsub(info[#info-1],5))][7]) end,
							set = function(info, value) DB.icons[info[#info-2] ].icons[tonumber(strsub(info[#info-1],5))][7] = (value);LockDown(Serenity.SetupIconsModule) end,
						},
						h = { -- Flash
							type = "toggle",
							order = 14,
							name = L2["Flash when expiring"],
							desc = L2["EXPIREFLASH_ENABLE"],
							width = "full",
							get = function(info) return(DB.icons[info[#info-2] ].icons[tonumber(strsub(info[#info-1],5))][8]) end,
							set = function(info, value) DB.icons[info[#info-2] ].icons[tonumber(strsub(info[#info-1],5))][8] = value;LockDown(Serenity.SetupIconsModule) end,
						},
						m = { -- Alpha Change
							type = "toggle",
							order = 15,
							name = L2["Alpha Change"],
							desc = L2["EXPIREALPHA_ENABLE"],
							width = "full",
							get = function(info) return(DB.icons[info[#info-2] ].icons[tonumber(strsub(info[#info-1],5))][13]) end,
							set = function(info, value) DB.icons[info[#info-2] ].icons[tonumber(strsub(info[#info-1],5))][13] = value;LockDown(Serenity.SetupIconsModule) end,
						},
						n = { -- Alpha Change - Start
							type = "range", 
							order = 16,
							name = L2["Alpha start %"],
							desc = L2["ALPHASTART_DESC"],
							hidden = function(info) return(not DB.icons[info[#info-2] ].icons[tonumber(strsub(info[#info-1],5))][13]) end,
							isPercent = true,
							min = 0, max = 1, step = .1,
							get = function(info) return(DB.icons[info[#info-2] ].icons[tonumber(strsub(info[#info-1],5))][14]) end,
							set = function(info, size) DB.icons[info[#info-2] ].icons[tonumber(strsub(info[#info-1],5))][14] = (size);LockDown(Serenity.SetupIconsModule) end,
						},
						o = { -- Alpha Change - End
							type = "range", 
							order = 17,
							name = L2["Alpha end %"],
							desc = L2["ALPHAEND_DESC"],
							hidden = function(info) return(not DB.icons[info[#info-2] ].icons[tonumber(strsub(info[#info-1],5))][13]) end,
							isPercent = true,
							min = 0, max = 1, step = .1,
							get = function(info) return(DB.icons[info[#info-2] ].icons[tonumber(strsub(info[#info-1],5))][15]) end,
							set = function(info, size) DB.icons[info[#info-2] ].icons[tonumber(strsub(info[#info-1],5))][15] = (size);LockDown(Serenity.SetupIconsModule) end,
						},
						spacer3 = { order = 50, type = "description", name = "\n", desc = "", width = "full"},
						delete = {
							order = 51,
							type = "execute",
							name = L2["Delete this icon"],
							image = "Interface\\Icons\\Spell_ChargeNegative",
							confirm = function(info) return(L2["DELETEICON_CONFIRM"]) end,
							func = function(info)
									tremove(DB.icons[info[#info-2] ].icons, tonumber(strsub(info[#info-1],5)))
									LibStub("AceConfigRegistry-3.0"):NotifyChange("SerenityOptions")
									LockDown(Serenity.SetupIconsModule)
								end,							
						},
					},					
				}
				ord2 = ord2 + 1
			end

		end
	end	
	
	return iconblockstable
end

function SerenityOptions:CreateAlerts()

	-- Have to be sure someone does not try to create an alert by the same name as a hard-coded key.  Probably will never happen, but people do dumb shit.
	local alertstableblacklist = { "intro", "movers", "icons", "cooldowns", "energybar", "alerts" }
	local k,v
	for k,v in pairs(Serenity.V["alert_defaults"]) do
		alertstableblacklist[#alertstableblacklist + 1] = k
	end	
	for k,v in pairs(DB.alerts) do
		alertstableblacklist[#alertstableblacklist + 1] = k
	end	
	
	local alertstable = {
		intro = {
			order = 1,
			type = "description",
			name = L2["ALERTS_DESC"].."\n",
		},
		newalert = {
			order = 2,
			type = 'input',
			name = L2["New alert"],
			desc = L2["Creates a alert."],
			confirm = function(info, value)
					return(((strtrim(value) == "") or tContains(alertstableblacklist, value) or (DB.alerts[value] ~= nil)) and false or format(L2["CONFIRM_NEWALERT"], value)) 
				end,
			get = function(info) return("") end,
			set = function(info, value)
					value = strtrim(value)
					if (value == "") or tContains(alertstableblacklist, value) then
						print(Serenity.L["SERENITY_PRE"]..format(L2["Invalid alert name!"], value))
						return
					elseif DB.alerts[value] ~= nil then
						print(Serenity.L["SERENITY_PRE"]..format(L2["You already have an alert with that name!"], value))							
						return
					end
					local alert = {}
					-- Alert defaults
					alert = Serenity.DeepCopy(Serenity.V["alert_defaults"])					
					-- Frame styling defaults					
					DB.frames.alerts[value] = Serenity.DeepCopy(Serenity.V.templates[DB["basetemplate"] ].frames.alerts)
					DB.alerts[value] = alert
					
					table.sort(DB.alerts, function(a,b) return(a < b) end)					
					
					local serenityOptionsTable = LibStub("AceConfigRegistry-3.0"):GetOptionsTable("SerenityOptions", "dialog", "SerenityNullLib-1.0")
					-- Re-Inject the new alert
					LibStub("AceConfigRegistry-3.0"):NotifyChange("SerenityOptions")
					
					print(Serenity.L["SERENITY_PRE"]..format(L2["New alert '%s' created."], value))
					SerenityOptions:UpdateAlerts()
				end,
		},
--		spacer1 = { order = 3, type = "description", name = " ", desc = "", },
	}
	
	local ord = 24
	local key, value
	for key,value in pairs(DB.alerts) do
		if DB.alerts[key] ~= nil then -- Technically should never be nil!
			alertstable[key] = {
				order = ord,
				type = "group",
				name = key,
				childGroups = "tree",
				args = {
					enabled = {
						type = "toggle",
						order = 1,
						name = L2["Enable"],
						desc = L2["ALERTDESC_ENABLE"],
						width = "full",
						get = function(info) return DB.alerts[info[#info-1] ][info[#info] ] end,
						set = function(info, value) DB.alerts[info[#info-1] ][info[#info] ] = value;LockDown(Serenity.SetupAlertsModule) end,
					},
					tooltips = {
						type = "toggle",
						order = 3,
						name = L2["Show Tooltip"],
						disabled = function(info) return not DB.alerts[info[#info-1] ].enabled end,
						get = function(info) return DB.alerts[info[#info-1] ][info[#info] ] end,
						set = function(info, value) DB.alerts[info[#info-1] ][info[#info] ] = value;LockDown(Serenity.SetupAlertsModule) end,
					},
					sparkles = {
						type = "toggle",
						order = 3,
						name = L2["Add Sparkles"],
						disabled = function(info) return not DB.alerts[info[#info-1] ].enabled end,
						get = function(info) return DB.alerts[info[#info-1] ][info[#info] ] end,
						set = function(info, value) DB.alerts[info[#info-1] ][info[#info] ] = value;LockDown(Serenity.SetupAlertsModule) end,
					},
					enablesound = {
						type = "toggle",
						order = 5,
						name = L2["Enable Alert Sound"],
						disabled = function(info) return not DB.alerts[info[#info-1] ].enabled end,
						get = function(info) return DB.alerts[info[#info-1] ][info[#info] ] end,
						set = function(info, value) DB.alerts[info[#info-1] ][info[#info] ] = value;LockDown(Serenity.SetupAlertsModule) end,
					},
					sound = {
						type = "select",
						dialogControl = 'LSM30_Sound',
						order = 6,
						name = L2["Alert Sound"],
						values = AceGUIWidgetLSMlists.sound,
						disabled = function(info)
								if (not DB.alerts[info[#info-1] ].enabled) or (not DB.alerts[info[#info-1] ].enablesound) then
									return true
								end
								return false
							end,
						get = function(info) return DB.alerts[info[#info-1] ][info[#info] ] end,
						set = function(info, value) DB.alerts[info[#info-1] ][info[#info] ] = value;LockDown(Serenity.SetupAlertsModule) end,								
					},
					alerttype = {
						order = 10,
						type = "select",
						style = "dropdown",
						name = L2["Alert trigger"],
						desc = L2["ALERTTRIGGER_DESC"],
						values = function() return Serenity.V["alerttypes"] end,
						get = function(info) return DB.alerts[info[#info-1] ][info[#info] ] end,
						set = function(info, value) DB.alerts[info[#info-1] ][info[#info] ] = value;LockDown(Serenity.SetupAlertsModule) end,
					},
					spacer1 = { order = 12, type = "description", name = " ", desc = "", width = "full"},
					aura = { -- Spell name or ID.
						order = 14,
						type = "input",
						name = L2["Enter a Spell Name or ID.."],
						desc = L2["SPELL_DESC"],
						width = "full",
						disabled = function(info) return not DB.alerts[info[#info-1] ].enabled end,
						hidden = function(info) 
								if tContains({ "BUFF", "DEBUFF", "CAST" }, DB.alerts[info[#info-1] ].alerttype) then
									return false
								end							
								return true
							end,
						validate = function(info, val)
								if GetSpellInfo(tonumber(val) and tonumber(val) or val) then return(true) end
								if tonumber(val) then -- If it's a Spell ID number we CAN verify it.
									print(Serenity.L["SERENITY_PRE"].."|cffff0000"..L2["TIMERSPELL_INVALID"].."|r")
									return(false) 
								end
								-- If it's not a Spell ID number we can only verify it if the player HAS that spell in his book.
								if not (GetSpellInfo(val)) then -- Try to verify, if it does then we don't need to show the unverified warning.
									print(Serenity.L["SERENITY_PRE"].."|cffff0000"..L2["TIMERSPELL_UNVERIFIED"].."|r")
								end
								return(true)
							end,
						get = function(info) return(tonumber(DB.alerts[info[#info-1] ][info[#info] ]) and tostring(DB.alerts[info[#info-1] ][info[#info] ]) or DB.alerts[info[#info-1] ][info[#info] ]) end,
						set = function(info, val)
								DB.alerts[info[#info-1] ][info[#info] ] = (tonumber(val) and tonumber(val) or val)
								
								table.sort(DB.alerts, function(a,b)
									local aComp = (tonumber(a) and (select(1, GetSpellInfo(a))) or a)
									local bComp = (tonumber(b) and (select(1, GetSpellInfo(b))) or b)
									return(aComp < bComp)
								end)
								
								LibStub("AceConfigRegistry-3.0"):NotifyChange("SerenityOptions")
								collectgarbage("collect")
								LockDown(Serenity.SetupAlertsModule)
							end,
					},
					target = { -- Target to check for the spell.
						order = 16,
						type = "select",
						name = L2["Check Target"],
						desc = L2["CHECKTARGET_DESC"],						
						disabled = function(info) return not DB.alerts[info[#info-1] ].enabled end,
						hidden = function(info) 
								if tContains({ "BUFF", "DEBUFF", "CAST" }, DB.alerts[info[#info-1] ].alerttype) then
									return false
								end							
								return true
							end,
						style = "dropdown",
						values = function() return Serenity.V["targets"] end,
						get = function(info) return DB.alerts[info[#info-1] ][info[#info] ] end,
						set = function(info, value) DB.alerts[info[#info-1] ][info[#info] ] = value;LockDown(Serenity.SetupAlertsModule) end,
					},

					spacer3 = { order = 50, type = "description", name = "\n", desc = "", width = "full"},
					delete = {
						order = 51,
						type = "execute",
						name = L2["Delete this alert"],
						image = "Interface\\Icons\\Spell_ChargeNegative",
						confirm = function(info) return(L2["DELETEALERT_CONFIRM"]) end,
						func = function(info)
								DB.frames.alerts[info[#info-1] ] = nil
								DB.alerts[info[#info-1] ] = nil
								LibStub("AceConfigRegistry-3.0"):NotifyChange("SerenityOptions")
								LockDown(Serenity.SetupAlertsModule)
							end,							
					},
				},
			}
			ord = ord + 1
		end
	end

	return alertstable
end

function SerenityOptions:UpdateTimerSets()
	local serenityOptionsTable = LibStub("AceConfigRegistry-3.0"):GetOptionsTable("SerenityOptions", "dialog", "SerenityNullLib-1.0")		
	serenityOptionsTable.args.timers.args = SerenityOptions:CreateTimerSets()
	LibStub("AceConfigRegistry-3.0"):NotifyChange("SerenityOptions")
	collectgarbage("collect")
end

function SerenityOptions:UpdateIconBlocks(newBlock, newIcon)
	local serenityOptionsTable = LibStub("AceConfigRegistry-3.0"):GetOptionsTable("SerenityOptions", "dialog", "SerenityNullLib-1.0")		
	serenityOptionsTable.args.icons.args = SerenityOptions:CreateIconBlocks()
	-- We need to re-open a specific options frame if we have been given one
	if newBlock and newIcon then
		LibStub("AceConfigDialog-3.0"):SelectGroup("SerenityOptions", "icons", newBlock, newIcon)
	else
		LibStub("AceConfigRegistry-3.0"):NotifyChange("SerenityOptions")
	end
	collectgarbage("collect")
end

function SerenityOptions:UpdateAlerts()
	local serenityOptionsTable = LibStub("AceConfigRegistry-3.0"):GetOptionsTable("SerenityOptions", "dialog", "SerenityNullLib-1.0")		
	serenityOptionsTable.args.alerts.args = SerenityOptions:CreateAlerts()
	LibStub("AceConfigRegistry-3.0"):NotifyChange("SerenityOptions")
	collectgarbage("collect")
end

function SerenityOptions:CreateFrameTimerSets(tbl)
	local ord = 50
	local key, value
	
	-- Clean out any current entries in the options table
	for key,value in pairs(DB.timers) do
		tbl[key] = nil
	end

	for key,value in pairs(DB.timers) do
		tbl[key] = {
			order = ord,
			type = "group",
			name = format(L2["Timer Set: %s"], key),
			guiInline = false,
			args = {
				intro = {
					order = 1,
					type = "description",
					name = L2["TIMERSETSFRAME_DESC"].."\n",
				},
				size = {
					type = "group",
					order = 2,
					name = L2["Size of the bar"],
					guiInline = false,
					args = {
						width = {
							type = "range", 
							order = 1,
							name = L2["Width"],
							min = 20, max = 2000, step = 1,
							get = function(info) return (DB.frames.timers[info[#info-2] ][info[#info] ]) end,
							set = function(info, size) DB.frames.timers[info[#info-2] ][info[#info] ] = (size);LockDown(Serenity.SetupTimersModule) end,
						},
						height = {
							type = "range", 
							order = 2,
							name = L2["Height"],
							min = 10, max = 400, step = 1,
							get = function(info) return (DB.frames.timers[info[#info-2] ][info[#info] ]) end,
							set = function(info, size) DB.frames.timers[info[#info-2] ][info[#info] ] = (size);LockDown(Serenity.SetupTimersModule) end,
						},
						iconsize = {
							type = "range", 
							order = 3,
							name = L2["Timer icon size"],
							min = 10, max = 100, step = 1,
							get = function(info) return (DB.frames.timers[info[#info-2] ][info[#info] ]) end,
							set = function(info, size) DB.frames.timers[info[#info-2] ][info[#info] ] = (size);LockDown(Serenity.SetupTimersModule) end,
						},
					},
				},
				texcoords = {
					type = "group",
					order = 8,
					name = L2["Texture Coords"],
					guiInline = false,
					args = {						
						enabletexcoords = {
							type = "toggle",
							order = 5,
							name = L2["Enable TexCoords"],
							desc = L2["DESCTEXCOORDS_ENABLE"],
							get = function(info) return DB.frames.timers[info[#info-2] ][info[#info] ] end,
							set = function(info, value) DB.frames.timers[info[#info-2] ][info[#info] ] = value;LockDown(Serenity.SetupTimersModule) end,
						},
						texcoords = {
							type = "group",
							order = 6,
							name = L2["Texture Coords"],
							guiInline = true,
							args = {
								left = {
									type = "range",
									order = 1,
									name = L2["Left"],
									min = 0, max = 1, step = .01,
									disabled = function(info) return not DB.frames.timers[info[#info-3] ]["enabletexcoords"] end,
									get = function(info) return (DB.frames.timers[info[#info-3] ][info[#info-1] ][1]) end,
									set = function(info, offset) DB.frames.timers[info[#info-3] ][info[#info-1] ][1] = (offset);LockDown(Serenity.SetupTimersModule) end,
								},
								right = {
									type = "range", 
									order = 2,
									name = L2["Right"],
									min = 0, max = 1, step = .01,
									disabled = function(info) return not DB.frames.timers[info[#info-3] ]["enabletexcoords"] end,
									get = function(info) return (DB.frames.timers[info[#info-3] ][info[#info-1] ][2]) end,
									set = function(info, offset) DB.frames.timers[info[#info-3] ][info[#info-1] ][2] = (offset);LockDown(Serenity.SetupTimersModule) end,
								},
								top = {
									type = "range", 
									order = 3,
									name = L2["Top"],
									min = 0, max = 1, step = .01,
									disabled = function(info) return not DB.frames.timers[info[#info-3] ]["enabletexcoords"] end,
									get = function(info) return (DB.frames.timers[info[#info-3] ][info[#info-1] ][3]) end,
									set = function(info, offset) DB.frames.timers[info[#info-3] ][info[#info-1] ][3] = (offset);LockDown(Serenity.SetupTimersModule) end,
								},
								bottom = {
									type = "range", 
									order = 4,
									name = L2["Bottom"],
									min = 0, max = 1, step = .01,
									disabled = function(info) return not DB.frames.timers[info[#info-3] ]["enabletexcoords"] end,
									get = function(info) return (DB.frames.timers[info[#info-3] ][info[#info-1] ][4]) end,
									set = function(info, offset) DB.frames.timers[info[#info-3] ][info[#info-1] ][4] = (offset);LockDown(Serenity.SetupTimersModule) end,
								},										
							},
						},
					},
				},
				backdrop = {
					type = "group",
					order = 3,
					name = L2["Set's Backdrop"],
					guiInline = false,
					args = {
						enablebackdrop = {
							type = "toggle",
							order = 1,
							name = L2["Enable"],
							desc = L2["DESCBACKDROP_ENABLE"],
							get = function(info) return DB.frames.timers[info[#info-2] ][info[#info] ] end,
							set = function(info, value) DB.frames.timers[info[#info-2] ][info[#info] ] = value;LockDown(Serenity.SetupTimersModule) end,
						},
						backdroptexture = {
							type = "select",
							dialogControl = 'LSM30_Background',
							order = 2,
							name = L2["Backdrop texture"],
							desc = L2["Texture that gets used for the bar's background."],
							values = AceGUIWidgetLSMlists.background,
							disabled = function(info) return not DB.frames.timers[info[#info-2] ]["enablebackdrop"] end,
							get = function(info) return DB.frames.timers[info[#info-2] ][info[#info] ] end,
							set = function(info, value) DB.frames.timers[info[#info-2] ][info[#info] ] = value;LockDown(Serenity.SetupTimersModule) end,
						},
						colorbackdrop = {
							type = "toggle",
							order = 3,
							name = L2["Color the backdrop"],
							desc = L2["DESCBACKDROPCOLOR_ENABLE"],
							disabled = function(info) return not DB.frames.timers[info[#info-2] ]["enablebackdrop"] end,
							get = function(info) return DB.frames.timers[info[#info-2] ][info[#info] ] end,
							set = function(info, value) DB.frames.timers[info[#info-2] ][info[#info] ] = value;LockDown(Serenity.SetupTimersModule) end,
						},
						backdropcolor = {
							type = "color",
							order = 4,
							name = L2["Backdrop color"],
							hasAlpha = true,
							disabled = function(info) return not DB.frames.timers[info[#info-2] ]["enablebackdrop"] end,
							hidden = function(info) return not DB.frames.timers[info[#info-2] ].colorbackdrop end,
							get = function(info) return unpack(DB.frames.timers[info[#info-2] ][info[#info] ]) end,
							set = function(info, r, g, b, a) DB.frames.timers[info[#info-2] ][info[#info] ] = {r, g, b, a};LockDown(Serenity.SetupTimersModule) end,
						},
						tile = {
							type = "toggle",
							order = 5,
							name = L2["Tile the backdrop"],
							desc = L2["DESCBACKDROPTILE_ENABLE"],
							disabled = function(info) return not DB.frames.timers[info[#info-2] ]["enablebackdrop"] end,
							get = function(info) return DB.frames.timers[info[#info-2] ][info[#info] ] end,
							set = function(info, value) DB.frames.timers[info[#info-2] ][info[#info] ] = value;LockDown(Serenity.SetupTimersModule) end,
						},
						tilesize = {
							type = "range",
							order = 6,
							name = L2["Tile Size"],
							desc = L2["DESCTILESIZE_ENABLE"],
							min = -100, softMin = -30, softMax = 30, max = 100, step = 1,
							disabled = function(info) return not DB.frames.timers[info[#info-2] ]["enablebackdrop"] end,
							hidden = function(info) return not DB.frames.timers[info[#info-2] ].tile end,
							get = function(info) return DB.frames.timers[info[#info-2] ][info[#info] ] end,
							set = function(info, value) DB.frames.timers[info[#info-2] ][info[#info] ] = value;LockDown(Serenity.SetupTimersModule) end,
						},
						spacer = { order = 7, type = "description", name = "", desc = "", width = "full"},
						backdropoffsets = {
							type = "group",
							order = 8,
							name = L2["Offsets"],
							guiInline = true,
							args = {
								offsetX1 = {
									type = "range",
									order = 1,
									name = L2["Top-Left X"],
									desc = L2["This sets the 'X offset' value."],
									min = -50, softMin = -10, softMax = 0, max = 50, step = 1,
									disabled = function(info) return not DB.frames.timers[info[#info-3] ]["enablebackdrop"] end,
									get = function(info) return (DB.frames.timers[info[#info-3] ][info[#info-1] ][1]) end,
									set = function(info, offset) DB.frames.timers[info[#info-3] ][info[#info-1] ][1] = (offset);LockDown(Serenity.SetupTimersModule) end,
								},
								offsetY1 = {
									type = "range", 
									order = 2,
									name = L2["Top-Left Y"],
									desc = L2["This sets the 'Y offset' value."],
									min = -50, softMin = 0, softMax = 10, max = 50, step = 1,
									disabled = function(info) return not DB.frames.timers[info[#info-3] ]["enablebackdrop"] end,
									get = function(info) return (DB.frames.timers[info[#info-3] ][info[#info-1] ][2]) end,
									set = function(info, offset) DB.frames.timers[info[#info-3] ][info[#info-1] ][2] = (offset);LockDown(Serenity.SetupTimersModule) end,
								},
								offsetX2 = {
									type = "range", 
									order = 3,
									name = L2["Bottom-Right X"],
									desc = L2["This sets the 'X offset' value."],
									min = -50, softMin = 0, softMax = 10, max = 50, step = 1,
									disabled = function(info) return not DB.frames.timers[info[#info-3] ]["enablebackdrop"] end,
									get = function(info) return (DB.frames.timers[info[#info-3] ][info[#info-1] ][3]) end,
									set = function(info, offset) DB.frames.timers[info[#info-3] ][info[#info-1] ][3] = (offset);LockDown(Serenity.SetupTimersModule) end,
								},
								offsetY2 = {
									type = "range", 
									order = 4,
									name = L2["Bottom-Right Y"],
									desc = L2["This sets the 'Y offset' value."],
									min = -50, softMin = -10, softMax = 0, max = 50, step = 1,
									disabled = function(info) return not DB.frames.timers[info[#info-3] ]["enablebackdrop"] end,
									get = function(info) return (DB.frames.timers[info[#info-3] ][info[#info-1] ][4]) end,
									set = function(info, offset) DB.frames.timers[info[#info-3] ][info[#info-1] ][4] = (offset);LockDown(Serenity.SetupTimersModule) end,
								},										
							},
						},
						spacer = { order = 9, type = "description", name = "", desc = "", width = "full"},
					},
				},
				border = {
					type = "group",
					order = 4,
					name = L2["Set's Border"],
					guiInline = false,
					args = {
						enableborder = {
							type = "toggle",
							order = 1,
							name = L2["Enable"],
							desc = L2["DESCBORDER_ENABLE"],
							get = function(info) return DB.frames.timers[info[#info-2] ][info[#info] ] end,
							set = function(info, value) DB.frames.timers[info[#info-2] ][info[#info] ] = value;LockDown(Serenity.SetupTimersModule) end,
						},
						bordertexture = {
							type = "select",
							dialogControl = 'LSM30_Border',
							order = 2,
							name = L2["Border texture"],
							desc = L2["Texture that gets used for the bar's background."],
							values = AceGUIWidgetLSMlists.border,
							disabled = function(info) return not DB.frames.timers[info[#info-2] ]["enableborder"] end,
							get = function(info) return DB.frames.timers[info[#info-2] ][info[#info] ] end,
							set = function(info, value) DB.frames.timers[info[#info-2] ][info[#info] ] = value;LockDown(Serenity.SetupTimersModule) end,
						},
						bordercolor = {
							type = "color",
							order = 3,
							name = L2["Border color"],
							hasAlpha = true,
							disabled = function(info) return not DB.frames.timers[info[#info-2] ]["enableborder"] end,
							get = function(info) return unpack(DB.frames.timers[info[#info-2] ][info[#info] ]) end,
							set = function(info, r, g, b, a) DB.frames.timers[info[#info-2] ][info[#info] ] = {r, g, b, a};LockDown(Serenity.SetupTimersModule) end,
						},
						edgesize = {
							type = "range",
							order = 4,
							name = L2["Edge Size"],
							desc = L2["DESCEDGESIZE_ENABLE"],
							min = -100, softMin = -16, softMax = 16, max = 100, step = 1,
							disabled = function(info) return not DB.frames.timers[info[#info-2] ]["enableborder"] end,
							get = function(info) return DB.frames.timers[info[#info-2] ][info[#info] ] end,
							set = function(info, value) DB.frames.timers[info[#info-2] ][info[#info] ] = value;LockDown(Serenity.SetupTimersModule) end,
						},
						spacer = { order = 7, type = "description", name = "", desc = "", width = "full"},
						backdropinsets = {
							type = "group",
							order = 10,
							name = L2["Insets"],
							guiInline = true,
							args = {
								left = {
									type = "range",
									order = 1,
									name = L2["Left"],
									min = -50, softMin = -16, softMax = 16, max = 50, step = 1,
									disabled = function(info) return not DB.frames.timers[info[#info-3] ]["enableborder"] end,
									get = function(info) return (DB.frames.timers[info[#info-3] ][info[#info-1] ][1]) end,
									set = function(info, offset) DB.frames.timers[info[#info-3] ][info[#info-1] ][1] = (offset);LockDown(Serenity.SetupTimersModule) end,
								},
								right = {
									type = "range", 
									order = 2,
									name = L2["Right"],
									min = -50, softMin = -16, softMax = 16, max = 50, step = 1,
									disabled = function(info) return not DB.frames.timers[info[#info-3] ]["enableborder"] end,
									get = function(info) return (DB.frames.timers[info[#info-3] ][info[#info-1] ][2]) end,
									set = function(info, offset) DB.frames.timers[info[#info-3] ][info[#info-1] ][2] = (offset);LockDown(Serenity.SetupTimersModule) end,
								},
								top = {
									type = "range", 
									order = 3,
									name = L2["Top"],
									min = -50, softMin = -16, softMax = 16, max = 50, step = 1,
									disabled = function(info) return not DB.frames.timers[info[#info-3] ]["enableborder"] end,
									get = function(info) return (DB.frames.timers[info[#info-3] ][info[#info-1] ][3]) end,
									set = function(info, offset) DB.frames.timers[info[#info-3] ][info[#info-1] ][3] = (offset);LockDown(Serenity.SetupTimersModule) end,
								},
								bottom = {
									type = "range", 
									order = 4,
									name = L2["Bottom"],
									min = -50, softMin = -16, softMax = 16, max = 50, step = 1,
									disabled = function(info) return not DB.frames.timers[info[#info-3] ]["enableborder"] end,
									get = function(info) return (DB.frames.timers[info[#info-3] ][info[#info-1] ][4]) end,
									set = function(info, offset) DB.frames.timers[info[#info-3] ][info[#info-1] ][4] = (offset);LockDown(Serenity.SetupTimersModule) end,
								},										
							},
						},
					},
				},
				fonttext = {
					type = "group",
					order = 5,
					name = L2["Timer text settings"],
					guiInline = false,
					args = {
						timefont = {
							type = "group",
							order = 1,
							name = L2["Timer font"],
							guiInline = true,
							args = {
								font = {
									type = "select", 
									dialogControl = 'LSM30_Font',
									order = 1,
									name = L2["Font Face"],
									desc = L2["This is the font used for cooldown or duration timers."],
									values = AceGUIWidgetLSMlists.font,
									get = function(info) return DB.frames.timers[info[#info-3] ][info[#info-1] ][1] end,
									set = function(info, font) DB.frames.timers[info[#info-3] ][info[#info-1] ][1] = font;LockDown(Serenity.SetupTimersModule) end,
								},
								size = {
									type = "range", 
									order = 2,
									name = L2["Font Size"],
									min = 6, max = 40, step = 1,
									get = function(info) return (DB.frames.timers[info[#info-3] ][info[#info-1] ][2]) end,
									set = function(info, size) DB.frames.timers[info[#info-3] ][info[#info-1] ][2] = (size);LockDown(Serenity.SetupTimersModule) end,
								},
								flags = {
									type = "multiselect", 
									order = 3,
									name = L2["Font Flags"],
									values = fontFlagTable,
									get = function(info, key) return(tContains({strsplit(",", DB.frames.timers[info[#info-3] ][info[#info-1] ][3])}, key) and true or false) end,
									set = function(info, keyname, state) setFontFlags(DB.frames.timers[info[#info-3] ][info[#info-1] ], keyname, state);LockDown(Serenity.SetupTimersModule) end,
								},
							},
						},
						spacer = { order = 2, type = "description", name = "", desc = "", width = "full", get = nil, set = nil, },
						timerfontcolorstatic = {
							type = "toggle",
							order = 3,
							name = L2["Static timer color"],
							desc = L2["STATICTIMERCOLOR_DESC"],
							width = "full",
							get = function(info) return DB.frames.timers[info[#info-2] ][info[#info] ] end,
							set = function(info, value) DB.frames.timers[info[#info-2] ][info[#info] ] = value;LockDown(Serenity.SetupTimersModule) end,
						},
						timerfontcolor = {
							type = "color",
							order = 4,
							name = L2["Font Color"],
							desc = L2["Color used for the timer's font if set to static"],
							hasAlpha = false,
							disabled = function(info) return not DB.frames.timers[info[#info-2] ].timerfontcolorstatic end,
							get = function(info) return unpack(DB.frames.timers[info[#info-2] ][info[#info] ]) end,
							set = function(info, r, g, b, a) DB.frames.timers[info[#info-2] ][info[#info] ] = {r, g, b, a};LockDown(Serenity.SetupTimersModule) end,
						},
						spacer = { order = 5, type = "description", name = "", desc = "", width = "full", get = nil, set = nil, },
						enabletimershadow = {
							type = "toggle",
							order = 6,
							name = L2["Enable"],
							desc = L2["ENABLESHADOW_DESC"],
							width = "full",
							get = function(info) return DB.frames.timers[info[#info-2] ][info[#info] ] end,
							set = function(info, value) DB.frames.timers[info[#info-2] ][info[#info] ] = value;LockDown(Serenity.SetupTimersModule) end,
						},
						spacer = { order = 7, type = "description", name = "", desc = "", width = "full"},
						timershadowcolor = {
							type = "color",
							order = 8,
							name = L2["Font Shadow Color"],
							desc = L2["Color used for the text font shadow"],
							hasAlpha = true,
							disabled = function(info) return not DB.frames.timers[info[#info-2] ].enabletimershadow end,
							get = function(info) return unpack(DB.frames.timers[info[#info-2] ][info[#info] ]) end,
							set = function(info, r, g, b, a) DB.frames.timers[info[#info-2] ][info[#info] ] = {r, g, b, a};LockDown(Serenity.SetupTimersModule) end,
						},
						spacer = { order = 9, type = "description", name = "", desc = "", width = "full"},
						offsetX = {
							type = "input", 
							order = 10,
							name = L2["X Offset"],
							desc = L2["This sets the 'X offset' value."],
							width = "half",
							pattern = "%d",
							usage = L2["Only valid numeric offsets are allowed."],
							disabled = function(info) return not DB.frames.timers[info[#info-2] ].enabletimershadow end,
							get = function(info) return tostring(DB.frames.timers[info[#info-2] ].timershadowoffset[1]) end,
							set = function(info, offset) DB.frames.timers[info[#info-2] ].timershadowoffset[1] = tonumber(offset);LockDown(Serenity.SetupTimersModule) end,
						},
						offsetY = {
							type = "input", 
							order = 11,
							name = L2["Y Offset"],
							desc = L2["This sets the 'Y offset' value."],
							width = "half",
							pattern = "%d",
							usage = L2["Only valid numeric offsets are allowed."],
							disabled = function(info) return not DB.frames.timers[info[#info-2] ].enabletimershadow end,
							get = function(info) return tostring(DB.frames.timers[info[#info-2] ].timershadowoffset[2]) end,
							set = function(info, offset) DB.frames.timers[info[#info-2] ].timershadowoffset[2] = tonumber(offset);LockDown(Serenity.SetupTimersModule) end,
						},
						spacer = { order = 12, type = "description", name = "", desc = "", width = "full"},
						stackfont = {
							type = "group",
							order = 13,
							name = L2["Stacks font"],
							guiInline = true,
							args = {
								font = {
									type = "select", 
									dialogControl = 'LSM30_Font',
									order = 1,
									name = L2["Font Face"],
									desc = L2["This is the font used for stacks on the timers."],
									values = AceGUIWidgetLSMlists.font,
									get = function(info) return DB.frames.timers[info[#info-3] ][info[#info-1] ][1] end,
									set = function(info, font) DB.frames.timers[info[#info-3] ][info[#info-1] ][1] = font;LockDown(Serenity.SetupTimersModule) end,
								},
								size = {
									type = "range", 
									order = 2,
									name = L2["Font Size"],
									min = 6, max = 40, step = 1,
									get = function(info) return (DB.frames.timers[info[#info-3] ][info[#info-1] ][2]) end,
									set = function(info, size) DB.frames.timers[info[#info-3] ][info[#info-1] ][2] = (size);LockDown(Serenity.SetupTimersModule) end,
								},
								flags = {
									type = "multiselect", 
									order = 3,
									name = L2["Font Flags"],
									values = fontFlagTable,
									get = function(info, key) return(tContains({strsplit(",", DB.frames.timers[info[#info-3] ][info[#info-1] ][3])}, key) and true or false) end,
									set = function(info, keyname, state) setFontFlags(DB.frames.timers[info[#info-3] ][info[#info-1] ], keyname, state);LockDown(Serenity.SetupTimersModule) end,
								},
							},
						},
						stackfontcolor = {
							type = "color",
							order = 14,
							name = L2["Stacks Font Color"],
							desc = L2["Color used for the timer's stacks font."],
							hasAlpha = false,
							get = function(info) return unpack(DB.frames.timers[info[#info-2] ][info[#info] ]) end,
							set = function(info, r, g, b, a) DB.frames.timers[info[#info-2] ][info[#info] ] = {r, g, b, a};LockDown(Serenity.SetupTimersModule) end,
						},
					},
				},
				timerbackdrop = {
					type = "group",
					order = 3,
					name = L2["Timer's Backdrop"],
					guiInline = false,
					args = {
						timerenablebackdrop = {
							type = "toggle",
							order = 1,
							name = L2["Enable"],
							desc = L2["DESCBACKDROP_ENABLE"],
							get = function(info) return DB.frames.timers[info[#info-2] ][info[#info] ] end,
							set = function(info, value) DB.frames.timers[info[#info-2] ][info[#info] ] = value;LockDown(Serenity.SetupTimersModule) end,
						},
						timerbackdroptexture = {
							type = "select",
							dialogControl = 'LSM30_Background',
							order = 2,
							name = L2["Backdrop texture"],
							desc = L2["Texture that gets used for the bar's background."],
							values = AceGUIWidgetLSMlists.background,
							disabled = function(info) return not DB.frames.timers[info[#info-2] ]["timerenablebackdrop"] end,
							get = function(info) return DB.frames.timers[info[#info-2] ][info[#info] ] end,
							set = function(info, value) DB.frames.timers[info[#info-2] ][info[#info] ] = value;LockDown(Serenity.SetupTimersModule) end,
						},
						timercolorbackdrop = {
							type = "toggle",
							order = 3,
							name = L2["Color the backdrop"],
							desc = L2["DESCBACKDROPCOLOR_ENABLE"],
							disabled = function(info) return not DB.frames.timers[info[#info-2] ]["timerenablebackdrop"] end,
							get = function(info) return DB.frames.timers[info[#info-2] ][info[#info] ] end,
							set = function(info, value) DB.frames.timers[info[#info-2] ][info[#info] ] = value;LockDown(Serenity.SetupTimersModule) end,
						},
						timerbackdropcolor = {
							type = "color",
							order = 4,
							name = L2["Backdrop color"],
							hasAlpha = true,
							disabled = function(info) return not DB.frames.timers[info[#info-2] ]["timerenablebackdrop"] end,
							hidden = function(info) return not DB.frames.timers[info[#info-2] ].timercolorbackdrop end,
							get = function(info) return unpack(DB.frames.timers[info[#info-2] ][info[#info] ]) end,
							set = function(info, r, g, b, a) DB.frames.timers[info[#info-2] ][info[#info] ] = {r, g, b, a};LockDown(Serenity.SetupTimersModule) end,
						},
						timertile = {
							type = "toggle",
							order = 5,
							name = L2["Tile the backdrop"],
							desc = L2["DESCBACKDROPTILE_ENABLE"],
							disabled = function(info) return not DB.frames.timers[info[#info-2] ]["timerenablebackdrop"] end,
							get = function(info) return DB.frames.timers[info[#info-2] ][info[#info] ] end,
							set = function(info, value) DB.frames.timers[info[#info-2] ][info[#info] ] = value;LockDown(Serenity.SetupTimersModule) end,
						},
						timertilesize = {
							type = "range",
							order = 6,
							name = L2["Tile Size"],
							desc = L2["DESCTILESIZE_ENABLE"],
							min = -100, softMin = -30, softMax = 30, max = 100, step = 1,
							disabled = function(info) return not DB.frames.timers[info[#info-2] ]["timerenablebackdrop"] end,
							hidden = function(info) return not DB.frames.timers[info[#info-2] ].tile end,
							get = function(info) return DB.frames.timers[info[#info-2] ][info[#info] ] end,
							set = function(info, value) DB.frames.timers[info[#info-2] ][info[#info] ] = value;LockDown(Serenity.SetupTimersModule) end,
						},
						spacer1 = { order = 7, type = "description", name = "", desc = "", width = "full"},
						timerbackdropoffsets = {
							type = "group",
							order = 8,
							name = L2["Offsets"],
							guiInline = true,
							args = {
								offsetX1 = {
									type = "range",
									order = 1,
									name = L2["Top-Left X"],
									desc = L2["This sets the 'X offset' value."],
									min = -50, softMin = -10, softMax = 0, max = 50, step = 1,
									disabled = function(info) return not DB.frames.timers[info[#info-3] ]["timerenablebackdrop"] end,
									get = function(info) return (DB.frames.timers[info[#info-3] ][info[#info-1] ][1]) end,
									set = function(info, offset) DB.frames.timers[info[#info-3] ][info[#info-1] ][1] = (offset);LockDown(Serenity.SetupTimersModule) end,
								},
								offsetY1 = {
									type = "range", 
									order = 2,
									name = L2["Top-Left Y"],
									desc = L2["This sets the 'Y offset' value."],
									min = -50, softMin = 0, softMax = 10, max = 50, step = 1,
									disabled = function(info) return not DB.frames.timers[info[#info-3] ]["timerenablebackdrop"] end,
									get = function(info) return (DB.frames.timers[info[#info-3] ][info[#info-1] ][2]) end,
									set = function(info, offset) DB.frames.timers[info[#info-3] ][info[#info-1] ][2] = (offset);LockDown(Serenity.SetupTimersModule) end,
								},
								offsetX2 = {
									type = "range", 
									order = 3,
									name = L2["Bottom-Right X"],
									desc = L2["This sets the 'X offset' value."],
									min = -50, softMin = 0, softMax = 10, max = 50, step = 1,
									disabled = function(info) return not DB.frames.timers[info[#info-3] ]["timerenablebackdrop"] end,
									get = function(info) return (DB.frames.timers[info[#info-3] ][info[#info-1] ][3]) end,
									set = function(info, offset) DB.frames.timers[info[#info-3] ][info[#info-1] ][3] = (offset);LockDown(Serenity.SetupTimersModule) end,
								},
								offsetY2 = {
									type = "range", 
									order = 4,
									name = L2["Bottom-Right Y"],
									desc = L2["This sets the 'Y offset' value."],
									min = -50, softMin = -10, softMax = 0, max = 50, step = 1,
									disabled = function(info) return not DB.frames.timers[info[#info-3] ]["timerenablebackdrop"] end,
									get = function(info) return (DB.frames.timers[info[#info-3] ][info[#info-1] ][4]) end,
									set = function(info, offset) DB.frames.timers[info[#info-3] ][info[#info-1] ][4] = (offset);LockDown(Serenity.SetupTimersModule) end,
								},										
							},
						},
					},
				},
				timerborder = {
					type = "group",
					order = 4,
					name = L2["Timer's Border"],
					guiInline = false,
					args = {
						timerenableborder = {
							type = "toggle",
							order = 1,
							name = L2["Enable"],
							desc = L2["DESCBORDER_ENABLE"],
							get = function(info) return DB.frames.timers[info[#info-2] ][info[#info] ] end,
							set = function(info, value) DB.frames.timers[info[#info-2] ][info[#info] ] = value;LockDown(Serenity.SetupTimersModule) end,
						},
						timerbordertexture = {
							type = "select",
							dialogControl = 'LSM30_Border',
							order = 2,
							name = L2["Border texture"],
							desc = L2["Texture that gets used for an individual timer's background."],
							values = AceGUIWidgetLSMlists.border,
							disabled = function(info) return not DB.frames.timers[info[#info-2] ]["timerenableborder"] end,
							get = function(info) return DB.frames.timers[info[#info-2] ][info[#info] ] end,
							set = function(info, value) DB.frames.timers[info[#info-2] ][info[#info] ] = value;LockDown(Serenity.SetupTimersModule) end,
						},
						timerbordercolor = {
							type = "color",
							order = 3,
							name = L2["Border color"],
							hasAlpha = true,
							disabled = function(info) return not DB.frames.timers[info[#info-2] ]["timerenableborder"] end,
							get = function(info) return unpack(DB.frames.timers[info[#info-2] ][info[#info] ]) end,
							set = function(info, r, g, b, a) DB.frames.timers[info[#info-2] ][info[#info] ] = {r, g, b, a};LockDown(Serenity.SetupTimersModule) end,
						},
						timeredgesize = {
							type = "range",
							order = 4,
							name = L2["Edge Size"],
							desc = L2["DESCEDGESIZE_ENABLE"],
							min = -100, softMin = -16, softMax = 16, max = 100, step = 1,
							disabled = function(info) return not DB.frames.timers[info[#info-2] ]["timerenableborder"] end,
							get = function(info) return DB.frames.timers[info[#info-2] ][info[#info] ] end,
							set = function(info, value) DB.frames.timers[info[#info-2] ][info[#info] ] = value;LockDown(Serenity.SetupTimersModule) end,
						},
						spacer1 = { order = 9, type = "description", name = "", desc = "", width = "full"},
						timerbackdropinsets = {
							type = "group",
							order = 10,
							name = L2["Insets"],
							guiInline = true,
							args = {
								left = {
									type = "range",
									order = 1,
									name = L2["Left"],
									min = -50, softMin = -16, softMax = 16, max = 50, step = 1,
									disabled = function(info) return not DB.frames.timers[info[#info-3] ]["timerenableborder"] end,
									get = function(info) return (DB.frames.timers[info[#info-3] ][info[#info-1] ][1]) end,
									set = function(info, offset) DB.frames.timers[info[#info-3] ][info[#info-1] ][1] = (offset);LockDown(Serenity.SetupTimersModule) end,
								},
								right = {
									type = "range", 
									order = 2,
									name = L2["Right"],
									min = -50, softMin = -16, softMax = 16, max = 50, step = 1,
									disabled = function(info) return not DB.frames.timers[info[#info-3] ]["timerenableborder"] end,
									get = function(info) return (DB.frames.timers[info[#info-3] ][info[#info-1] ][2]) end,
									set = function(info, offset) DB.frames.timers[info[#info-3] ][info[#info-1] ][2] = (offset);LockDown(Serenity.SetupTimersModule) end,
								},
								top = {
									type = "range", 
									order = 3,
									name = L2["Top"],
									min = -50, softMin = -16, softMax = 16, max = 50, step = 1,
									disabled = function(info) return not DB.frames.timers[info[#info-3] ]["timerenableborder"] end,
									get = function(info) return (DB.frames.timers[info[#info-3] ][info[#info-1] ][3]) end,
									set = function(info, offset) DB.frames.timers[info[#info-3] ][info[#info-1] ][3] = (offset);LockDown(Serenity.SetupTimersModule) end,
								},
								bottom = {
									type = "range", 
									order = 4,
									name = L2["Bottom"],
									min = -50, softMin = -16, softMax = 16, max = 50, step = 1,
									disabled = function(info) return not DB.frames.timers[info[#info-3] ]["timerenableborder"] end,
									get = function(info) return (DB.frames.timers[info[#info-3] ][info[#info-1] ][4]) end,
									set = function(info, offset) DB.frames.timers[info[#info-3] ][info[#info-1] ][4] = (offset);LockDown(Serenity.SetupTimersModule) end,
								},										
							},
						},
					},
				},
			},
		}
		ord = ord + 1
	end
end

function SerenityOptions:CreateFrameIconBlocks(tbl)
	local ord = 150
	local key, value
	
	-- Clean out any current entries in the options table
	for key,value in pairs(DB.icons) do
		tbl[key] = nil
	end

	for key,value in pairs(DB.icons) do
		tbl[key] = {
			order = ord,
			type = "group",
			name = format(L2["Icon Block: %s"], key),
			guiInline = false,
			args = {
				intro = {
					order = 1,
					type = "description",
					name = L2["ICONBLOCKSFRAME_DESC"].."\n",
				},
				size = {
					type = "group",
					order = 2,
					name = L2["Size of the icons"],
					guiInline = false,
					args = {
						iconsize = {
							type = "range", 
							order = 3,
							name = L2["Icon size"],
							min = 10, max = 100, step = 1,
							get = function(info) return (DB.frames.icons[info[#info-2] ][info[#info] ]) end,
							set = function(info, size) DB.frames.icons[info[#info-2] ][info[#info] ] = (size);LockDown(Serenity.SetupIconsModule) end,
						},
					},
				},
				texcoords = {
					type = "group",
					order = 8,
					name = L2["Texture Coords"],
					guiInline = false,
					args = {						
						enabletexcoords = {
							type = "toggle",
							order = 5,
							name = L2["Enable TexCoords"],
							desc = L2["DESCTEXCOORDS_ENABLE"],
							get = function(info) return DB.frames.icons[info[#info-2] ][info[#info] ] end,
							set = function(info, value) DB.frames.icons[info[#info-2] ][info[#info] ] = value;LockDown(Serenity.SetupIconsModule) end,
						},
						texcoords = {
							type = "group",
							order = 6,
							name = L2["Texture Coords"],
							guiInline = true,
							args = {
								left = {
									type = "range",
									order = 1,
									name = L2["Left"],
									min = 0, max = 1, step = .01,
									disabled = function(info) return not DB.frames.icons[info[#info-3] ]["enabletexcoords"] end,
									get = function(info) return (DB.frames.icons[info[#info-3] ][info[#info-1] ][1]) end,
									set = function(info, offset) DB.frames.icons[info[#info-3] ][info[#info-1] ][1] = (offset);LockDown(Serenity.SetupIconsModule) end,
								},
								right = {
									type = "range", 
									order = 2,
									name = L2["Right"],
									min = 0, max = 1, step = .01,
									disabled = function(info) return not DB.frames.icons[info[#info-3] ]["enabletexcoords"] end,
									get = function(info) return (DB.frames.icons[info[#info-3] ][info[#info-1] ][2]) end,
									set = function(info, offset) DB.frames.icons[info[#info-3] ][info[#info-1] ][2] = (offset);LockDown(Serenity.SetupIconsModule) end,
								},
								top = {
									type = "range", 
									order = 3,
									name = L2["Top"],
									min = 0, max = 1, step = .01,
									disabled = function(info) return not DB.frames.icons[info[#info-3] ]["enabletexcoords"] end,
									get = function(info) return (DB.frames.icons[info[#info-3] ][info[#info-1] ][3]) end,
									set = function(info, offset) DB.frames.icons[info[#info-3] ][info[#info-1] ][3] = (offset);LockDown(Serenity.SetupIconsModule) end,
								},
								bottom = {
									type = "range", 
									order = 4,
									name = L2["Bottom"],
									min = 0, max = 1, step = .01,
									disabled = function(info) return not DB.frames.icons[info[#info-3] ]["enabletexcoords"] end,
									get = function(info) return (DB.frames.icons[info[#info-3] ][info[#info-1] ][4]) end,
									set = function(info, offset) DB.frames.icons[info[#info-3] ][info[#info-1] ][4] = (offset);LockDown(Serenity.SetupIconsModule) end,
								},										
							},
						},
					},
				},
				backdrop = {
					type = "group",
					order = 3,
					name = L2["Block's Backdrop"],
					guiInline = false,
					args = {
						enablebackdrop = {
							type = "toggle",
							order = 1,
							name = L2["Enable"],
							desc = L2["DESCBACKDROP_ENABLE"],
							get = function(info) return DB.frames.icons[info[#info-2] ][info[#info] ] end,
							set = function(info, value) DB.frames.icons[info[#info-2] ][info[#info] ] = value;LockDown(Serenity.SetupIconsModule) end,
						},
						backdroptexture = {
							type = "select",
							dialogControl = 'LSM30_Background',
							order = 2,
							name = L2["Backdrop texture"],
							desc = L2["Texture that gets used for the block's background."],
							values = AceGUIWidgetLSMlists.background,
							disabled = function(info) return not DB.frames.icons[info[#info-2] ]["enablebackdrop"] end,
							get = function(info) return DB.frames.icons[info[#info-2] ][info[#info] ] end,
							set = function(info, value) DB.frames.icons[info[#info-2] ][info[#info] ] = value;LockDown(Serenity.SetupIconsModule) end,
						},
						colorbackdrop = {
							type = "toggle",
							order = 3,
							name = L2["Color the backdrop"],
							desc = L2["DESCBACKDROPCOLOR_ENABLE"],
							disabled = function(info) return not DB.frames.icons[info[#info-2] ]["enablebackdrop"] end,
							get = function(info) return DB.frames.icons[info[#info-2] ][info[#info] ] end,
							set = function(info, value) DB.frames.icons[info[#info-2] ][info[#info] ] = value;LockDown(Serenity.SetupIconsModule) end,
						},
						backdropcolor = {
							type = "color",
							order = 4,
							name = L2["Backdrop color"],
							hasAlpha = true,
							disabled = function(info) return not DB.frames.icons[info[#info-2] ]["enablebackdrop"] end,
							hidden = function(info) return not DB.frames.icons[info[#info-2] ].colorbackdrop end,
							get = function(info) return unpack(DB.frames.icons[info[#info-2] ][info[#info] ]) end,
							set = function(info, r, g, b, a) DB.frames.icons[info[#info-2] ][info[#info] ] = {r, g, b, a};LockDown(Serenity.SetupIconsModule) end,
						},
						tile = {
							type = "toggle",
							order = 5,
							name = L2["Tile the backdrop"],
							desc = L2["DESCBACKDROPTILE_ENABLE"],
							disabled = function(info) return not DB.frames.icons[info[#info-2] ]["enablebackdrop"] end,
							get = function(info) return DB.frames.icons[info[#info-2] ][info[#info] ] end,
							set = function(info, value) DB.frames.icons[info[#info-2] ][info[#info] ] = value;LockDown(Serenity.SetupIconsModule) end,
						},
						tilesize = {
							type = "range",
							order = 6,
							name = L2["Tile Size"],
							desc = L2["DESCTILESIZE_ENABLE"],
							min = -100, softMin = -30, softMax = 30, max = 100, step = 1,
							disabled = function(info) return not DB.frames.icons[info[#info-2] ]["enablebackdrop"] end,
							hidden = function(info) return not DB.frames.icons[info[#info-2] ].tile end,
							get = function(info) return DB.frames.icons[info[#info-2] ][info[#info] ] end,
							set = function(info, value) DB.frames.icons[info[#info-2] ][info[#info] ] = value;LockDown(Serenity.SetupIconsModule) end,
						},
						spacer = { order = 7, type = "description", name = "", desc = "", width = "full"},
						backdropoffsets = {
							type = "group",
							order = 8,
							name = L2["Offsets"],
							guiInline = true,
							args = {
								offsetX1 = {
									type = "range",
									order = 1,
									name = L2["Top-Left X"],
									desc = L2["This sets the 'X offset' value."],
									min = -50, softMin = -10, softMax = 0, max = 50, step = 1,
									disabled = function(info) return not DB.frames.icons[info[#info-3] ]["enablebackdrop"] end,
									get = function(info) return (DB.frames.icons[info[#info-3] ][info[#info-1] ][1]) end,
									set = function(info, offset) DB.frames.icons[info[#info-3] ][info[#info-1] ][1] = (offset);LockDown(Serenity.SetupIconsModule) end,
								},
								offsetY1 = {
									type = "range", 
									order = 2,
									name = L2["Top-Left Y"],
									desc = L2["This sets the 'Y offset' value."],
									min = -50, softMin = 0, softMax = 10, max = 50, step = 1,
									disabled = function(info) return not DB.frames.icons[info[#info-3] ]["enablebackdrop"] end,
									get = function(info) return (DB.frames.icons[info[#info-3] ][info[#info-1] ][2]) end,
									set = function(info, offset) DB.frames.icons[info[#info-3] ][info[#info-1] ][2] = (offset);LockDown(Serenity.SetupIconsModule) end,
								},
								offsetX2 = {
									type = "range", 
									order = 3,
									name = L2["Bottom-Right X"],
									desc = L2["This sets the 'X offset' value."],
									min = -50, softMin = 0, softMax = 10, max = 50, step = 1,
									disabled = function(info) return not DB.frames.icons[info[#info-3] ]["enablebackdrop"] end,
									get = function(info) return (DB.frames.icons[info[#info-3] ][info[#info-1] ][3]) end,
									set = function(info, offset) DB.frames.icons[info[#info-3] ][info[#info-1] ][3] = (offset);LockDown(Serenity.SetupIconsModule) end,
								},
								offsetY2 = {
									type = "range", 
									order = 4,
									name = L2["Bottom-Right Y"],
									desc = L2["This sets the 'Y offset' value."],
									min = -50, softMin = -10, softMax = 0, max = 50, step = 1,
									disabled = function(info) return not DB.frames.icons[info[#info-3] ]["enablebackdrop"] end,
									get = function(info) return (DB.frames.icons[info[#info-3] ][info[#info-1] ][4]) end,
									set = function(info, offset) DB.frames.icons[info[#info-3] ][info[#info-1] ][4] = (offset);LockDown(Serenity.SetupIconsModule) end,
								},										
							},
						},
						spacer = { order = 9, type = "description", name = "", desc = "", width = "full"},
					},
				},
				border = {
					type = "group",
					order = 4,
					name = L2["Block's Border"],
					guiInline = false,
					args = {
						enableborder = {
							type = "toggle",
							order = 1,
							name = L2["Enable"],
							desc = L2["DESCBORDER_ENABLE"],
							get = function(info) return DB.frames.icons[info[#info-2] ][info[#info] ] end,
							set = function(info, value) DB.frames.icons[info[#info-2] ][info[#info] ] = value;LockDown(Serenity.SetupIconsModule) end,
						},
						bordertexture = {
							type = "select",
							dialogControl = 'LSM30_Border',
							order = 2,
							name = L2["Border texture"],
							values = AceGUIWidgetLSMlists.border,
							disabled = function(info) return not DB.frames.icons[info[#info-2] ]["enableborder"] end,
							get = function(info) return DB.frames.icons[info[#info-2] ][info[#info] ] end,
							set = function(info, value) DB.frames.icons[info[#info-2] ][info[#info] ] = value;LockDown(Serenity.SetupIconsModule) end,
						},
						bordercolor = {
							type = "color",
							order = 3,
							name = L2["Border color"],
							hasAlpha = true,
							disabled = function(info) return not DB.frames.icons[info[#info-2] ]["enableborder"] end,
							get = function(info) return unpack(DB.frames.icons[info[#info-2] ][info[#info] ]) end,
							set = function(info, r, g, b, a) DB.frames.icons[info[#info-2] ][info[#info] ] = {r, g, b, a};LockDown(Serenity.SetupIconsModule) end,
						},
						edgesize = {
							type = "range",
							order = 4,
							name = L2["Edge Size"],
							desc = L2["DESCEDGESIZE_ENABLE"],
							min = -100, softMin = -16, softMax = 16, max = 100, step = 1,
							disabled = function(info) return not DB.frames.icons[info[#info-2] ]["enableborder"] end,
							get = function(info) return DB.frames.icons[info[#info-2] ][info[#info] ] end,
							set = function(info, value) DB.frames.icons[info[#info-2] ][info[#info] ] = value;LockDown(Serenity.SetupIconsModule) end,
						},
						spacer = { order = 7, type = "description", name = "", desc = "", width = "full"},
						backdropinsets = {
							type = "group",
							order = 10,
							name = L2["Insets"],
							guiInline = true,
							args = {
								left = {
									type = "range",
									order = 1,
									name = L2["Left"],
									min = -50, softMin = -16, softMax = 16, max = 50, step = 1,
									disabled = function(info) return not DB.frames.icons[info[#info-3] ]["enableborder"] end,
									get = function(info) return (DB.frames.icons[info[#info-3] ][info[#info-1] ][1]) end,
									set = function(info, offset) DB.frames.icons[info[#info-3] ][info[#info-1] ][1] = (offset);LockDown(Serenity.SetupIconsModule) end,
								},
								right = {
									type = "range", 
									order = 2,
									name = L2["Right"],
									min = -50, softMin = -16, softMax = 16, max = 50, step = 1,
									disabled = function(info) return not DB.frames.icons[info[#info-3] ]["enableborder"] end,
									get = function(info) return (DB.frames.icons[info[#info-3] ][info[#info-1] ][2]) end,
									set = function(info, offset) DB.frames.icons[info[#info-3] ][info[#info-1] ][2] = (offset);LockDown(Serenity.SetupIconsModule) end,
								},
								top = {
									type = "range", 
									order = 3,
									name = L2["Top"],
									min = -50, softMin = -16, softMax = 16, max = 50, step = 1,
									disabled = function(info) return not DB.frames.icons[info[#info-3] ]["enableborder"] end,
									get = function(info) return (DB.frames.icons[info[#info-3] ][info[#info-1] ][3]) end,
									set = function(info, offset) DB.frames.icons[info[#info-3] ][info[#info-1] ][3] = (offset);LockDown(Serenity.SetupIconsModule) end,
								},
								bottom = {
									type = "range", 
									order = 4,
									name = L2["Bottom"],
									min = -50, softMin = -16, softMax = 16, max = 50, step = 1,
									disabled = function(info) return not DB.frames.icons[info[#info-3] ]["enableborder"] end,
									get = function(info) return (DB.frames.icons[info[#info-3] ][info[#info-1] ][4]) end,
									set = function(info, offset) DB.frames.icons[info[#info-3] ][info[#info-1] ][4] = (offset);LockDown(Serenity.SetupIconsModule) end,
								},										
							},
						},
					},
				},
				fonttext = {
					type = "group",
					order = 5,
					name = L2["Timer text settings"],
					guiInline = false,
					args = {
						timefont = {
							type = "group",
							order = 1,
							name = L2["Timer font"],
							guiInline = true,
							args = {
								font = {
									type = "select", 
									dialogControl = 'LSM30_Font',
									order = 1,
									name = L2["Font Face"],
									desc = L2["This is the font used for cooldown or duration timers."],
									values = AceGUIWidgetLSMlists.font,
									get = function(info) return DB.frames.icons[info[#info-3] ][info[#info-1] ][1] end,
									set = function(info, font) DB.frames.icons[info[#info-3] ][info[#info-1] ][1] = font;LockDown(Serenity.SetupIconsModule) end,
								},
								size = {
									type = "range", 
									order = 2,
									name = L2["Font Size"],
									min = 6, max = 40, step = 1,
									get = function(info) return (DB.frames.icons[info[#info-3] ][info[#info-1] ][2]) end,
									set = function(info, size) DB.frames.icons[info[#info-3] ][info[#info-1] ][2] = (size);LockDown(Serenity.SetupIconsModule) end,
								},
								flags = {
									type = "multiselect", 
									order = 3,
									name = L2["Font Flags"],
									values = fontFlagTable,
									get = function(info, key) return(tContains({strsplit(",", DB.frames.icons[info[#info-3] ][info[#info-1] ][3])}, key) and true or false) end,
									set = function(info, keyname, state) setFontFlags(DB.frames.icons[info[#info-3] ][info[#info-1] ], keyname, state);LockDown(Serenity.SetupIconsModule) end,
								},
							},
						},
						spacer = { order = 2, type = "description", name = "", desc = "", width = "full", get = nil, set = nil, },
						timerfontcolorstatic = {
							type = "toggle",
							order = 3,
							name = L2["Static timer color"],
							desc = L2["STATICTIMERCOLOR_DESC"],
							width = "full",
							get = function(info) return DB.frames.icons[info[#info-2] ][info[#info] ] end,
							set = function(info, value) DB.frames.icons[info[#info-2] ][info[#info] ] = value;LockDown(Serenity.SetupIconsModule) end,
						},
						timerfontcolor = {
							type = "color",
							order = 4,
							name = L2["Font Color"],
							desc = L2["Color used for the timer's font if set to static"],
							hasAlpha = false,
							disabled = function(info) return not DB.frames.icons[info[#info-2] ].timerfontcolorstatic end,
							get = function(info) return unpack(DB.frames.icons[info[#info-2] ][info[#info] ]) end,
							set = function(info, r, g, b, a) DB.frames.icons[info[#info-2] ][info[#info] ] = {r, g, b, a};LockDown(Serenity.SetupIconsModule) end,
						},
						spacer = { order = 5, type = "description", name = "", desc = "", width = "full", get = nil, set = nil, },
						enabletimershadow = {
							type = "toggle",
							order = 6,
							name = L2["Enable"],
							desc = L2["ENABLESHADOW_DESC"],
							width = "full",
							get = function(info) return DB.frames.icons[info[#info-2] ][info[#info] ] end,
							set = function(info, value) DB.frames.icons[info[#info-2] ][info[#info] ] = value;LockDown(Serenity.SetupIconsModule) end,
						},
						spacer = { order = 7, type = "description", name = "", desc = "", width = "full"},
						timershadowcolor = {
							type = "color",
							order = 8,
							name = L2["Font Shadow Color"],
							desc = L2["Color used for the text font shadow"],
							hasAlpha = true,
							disabled = function(info) return not DB.frames.icons[info[#info-2] ].enabletimershadow end,
							get = function(info) return unpack(DB.frames.icons[info[#info-2] ][info[#info] ]) end,
							set = function(info, r, g, b, a) DB.frames.icons[info[#info-2] ][info[#info] ] = {r, g, b, a};LockDown(Serenity.SetupIconsModule) end,
						},
						spacer = { order = 9, type = "description", name = "", desc = "", width = "full"},
						offsetX = {
							type = "input", 
							order = 10,
							name = L2["X Offset"],
							desc = L2["This sets the 'X offset' value."],
							width = "half",
							pattern = "%d",
							usage = L2["Only valid numeric offsets are allowed."],
							disabled = function(info) return not DB.frames.icons[info[#info-2] ].enabletimershadow end,
							get = function(info) return tostring(DB.frames.icons[info[#info-2] ].timershadowoffset[1]) end,
							set = function(info, offset) DB.frames.icons[info[#info-2] ].timershadowoffset[1] = tonumber(offset);LockDown(Serenity.SetupIconsModule) end,
						},
						offsetY = {
							type = "input", 
							order = 11,
							name = L2["Y Offset"],
							desc = L2["This sets the 'Y offset' value."],
							width = "half",
							pattern = "%d",
							usage = L2["Only valid numeric offsets are allowed."],
							disabled = function(info) return not DB.frames.icons[info[#info-2] ].enabletimershadow end,
							get = function(info) return tostring(DB.frames.icons[info[#info-2] ].timershadowoffset[2]) end,
							set = function(info, offset) DB.frames.icons[info[#info-2] ].timershadowoffset[2] = tonumber(offset);LockDown(Serenity.SetupIconsModule) end,
						},
						spacer = { order = 12, type = "description", name = "", desc = "", width = "full"},
						stackfont = {
							type = "group",
							order = 13,
							name = L2["Stacks font"],
							guiInline = true,
							args = {
								font = {
									type = "select", 
									dialogControl = 'LSM30_Font',
									order = 1,
									name = L2["Font Face"],
									desc = L2["This is the font used for stacks on the timers."],
									values = AceGUIWidgetLSMlists.font,
									get = function(info) return DB.frames.icons[info[#info-3] ][info[#info-1] ][1] end,
									set = function(info, font) DB.frames.icons[info[#info-3] ][info[#info-1] ][1] = font;LockDown(Serenity.SetupIconsModule) end,
								},
								size = {
									type = "range", 
									order = 2,
									name = L2["Font Size"],
									min = 6, max = 40, step = 1,
									get = function(info) return (DB.frames.icons[info[#info-3] ][info[#info-1] ][2]) end,
									set = function(info, size) DB.frames.icons[info[#info-3] ][info[#info-1] ][2] = (size);LockDown(Serenity.SetupIconsModule) end,
								},
								flags = {
									type = "multiselect", 
									order = 3,
									name = L2["Font Flags"],
									values = fontFlagTable,
									get = function(info, key) return(tContains({strsplit(",", DB.frames.icons[info[#info-3] ][info[#info-1] ][3])}, key) and true or false) end,
									set = function(info, keyname, state) setFontFlags(DB.frames.icons[info[#info-3] ][info[#info-1] ], keyname, state);LockDown(Serenity.SetupIconsModule) end,
								},
							},
						},
						stackfontcolor = {
							type = "color",
							order = 14,
							name = L2["Stacks Font Color"],
							desc = L2["Color used for the stacks font."],
							hasAlpha = false,
							get = function(info) return unpack(DB.frames.icons[info[#info-2] ][info[#info] ]) end,
							set = function(info, r, g, b, a) DB.frames.icons[info[#info-2] ][info[#info] ] = {r, g, b, a};LockDown(Serenity.SetupIconsModule) end,
						},
					},
				},
				iconbackdrop = {
					type = "group",
					order = 3,
					name = L2["Icon's Backdrop"],
					guiInline = false,
					args = {
						iconenablebackdrop = {
							type = "toggle",
							order = 1,
							name = L2["Enable"],
							desc = L2["DESCBACKDROP_ENABLE"],
							get = function(info) return DB.frames.icons[info[#info-2] ][info[#info] ] end,
							set = function(info, value) DB.frames.icons[info[#info-2] ][info[#info] ] = value;LockDown(Serenity.SetupIconsModule) end,
						},
						iconbackdroptexture = {
							type = "select",
							dialogControl = 'LSM30_Background',
							order = 2,
							name = L2["Backdrop texture"],
							desc = L2["Texture that gets used for the bar's background."],
							values = AceGUIWidgetLSMlists.background,
							disabled = function(info) return not DB.frames.icons[info[#info-2] ]["iconenablebackdrop"] end,
							get = function(info) return DB.frames.icons[info[#info-2] ][info[#info] ] end,
							set = function(info, value) DB.frames.icons[info[#info-2] ][info[#info] ] = value;LockDown(Serenity.SetupIconsModule) end,
						},
						iconcolorbackdrop = {
							type = "toggle",
							order = 3,
							name = L2["Color the backdrop"],
							desc = L2["DESCBACKDROPCOLOR_ENABLE"],
							disabled = function(info) return not DB.frames.icons[info[#info-2] ]["iconenablebackdrop"] end,
							get = function(info) return DB.frames.icons[info[#info-2] ][info[#info] ] end,
							set = function(info, value) DB.frames.icons[info[#info-2] ][info[#info] ] = value;LockDown(Serenity.SetupIconsModule) end,
						},
						iconbackdropcolor = {
							type = "color",
							order = 4,
							name = L2["Backdrop color"],
							hasAlpha = true,
							disabled = function(info) return not DB.frames.icons[info[#info-2] ]["iconenablebackdrop"] end,
							hidden = function(info) return not DB.frames.icons[info[#info-2] ].iconcolorbackdrop end,
							get = function(info) return unpack(DB.frames.icons[info[#info-2] ][info[#info] ]) end,
							set = function(info, r, g, b, a) DB.frames.icons[info[#info-2] ][info[#info] ] = {r, g, b, a};LockDown(Serenity.SetupIconsModule) end,
						},
						icontile = {
							type = "toggle",
							order = 5,
							name = L2["Tile the backdrop"],
							desc = L2["DESCBACKDROPTILE_ENABLE"],
							disabled = function(info) return not DB.frames.icons[info[#info-2] ]["iconenablebackdrop"] end,
							get = function(info) return DB.frames.icons[info[#info-2] ][info[#info] ] end,
							set = function(info, value) DB.frames.icons[info[#info-2] ][info[#info] ] = value;LockDown(Serenity.SetupIconsModule) end,
						},
						icontilesize = {
							type = "range",
							order = 6,
							name = L2["Tile Size"],
							desc = L2["DESCTILESIZE_ENABLE"],
							min = -100, softMin = -30, softMax = 30, max = 100, step = 1,
							disabled = function(info) return not DB.frames.icons[info[#info-2] ]["iconenablebackdrop"] end,
							hidden = function(info) return not DB.frames.icons[info[#info-2] ].tile end,
							get = function(info) return DB.frames.icons[info[#info-2] ][info[#info] ] end,
							set = function(info, value) DB.frames.icons[info[#info-2] ][info[#info] ] = value;LockDown(Serenity.SetupIconsModule) end,
						},
						spacer1 = { order = 7, type = "description", name = "", desc = "", width = "full"},
						iconbackdropoffsets = {
							type = "group",
							order = 8,
							name = L2["Offsets"],
							guiInline = true,
							args = {
								offsetX1 = {
									type = "range",
									order = 1,
									name = L2["Top-Left X"],
									desc = L2["This sets the 'X offset' value."],
									min = -50, softMin = -10, softMax = 0, max = 50, step = 1,
									disabled = function(info) return not DB.frames.icons[info[#info-3] ]["iconenablebackdrop"] end,
									get = function(info) return (DB.frames.icons[info[#info-3] ][info[#info-1] ][1]) end,
									set = function(info, offset) DB.frames.icons[info[#info-3] ][info[#info-1] ][1] = (offset);LockDown(Serenity.SetupIconsModule) end,
								},
								offsetY1 = {
									type = "range", 
									order = 2,
									name = L2["Top-Left Y"],
									desc = L2["This sets the 'Y offset' value."],
									min = -50, softMin = 0, softMax = 10, max = 50, step = 1,
									disabled = function(info) return not DB.frames.icons[info[#info-3] ]["iconenablebackdrop"] end,
									get = function(info) return (DB.frames.icons[info[#info-3] ][info[#info-1] ][2]) end,
									set = function(info, offset) DB.frames.icons[info[#info-3] ][info[#info-1] ][2] = (offset);LockDown(Serenity.SetupIconsModule) end,
								},
								offsetX2 = {
									type = "range", 
									order = 3,
									name = L2["Bottom-Right X"],
									desc = L2["This sets the 'X offset' value."],
									min = -50, softMin = 0, softMax = 10, max = 50, step = 1,
									disabled = function(info) return not DB.frames.icons[info[#info-3] ]["iconenablebackdrop"] end,
									get = function(info) return (DB.frames.icons[info[#info-3] ][info[#info-1] ][3]) end,
									set = function(info, offset) DB.frames.icons[info[#info-3] ][info[#info-1] ][3] = (offset);LockDown(Serenity.SetupIconsModule) end,
								},
								offsetY2 = {
									type = "range", 
									order = 4,
									name = L2["Bottom-Right Y"],
									desc = L2["This sets the 'Y offset' value."],
									min = -50, softMin = -10, softMax = 0, max = 50, step = 1,
									disabled = function(info) return not DB.frames.icons[info[#info-3] ]["iconenablebackdrop"] end,
									get = function(info) return (DB.frames.icons[info[#info-3] ][info[#info-1] ][4]) end,
									set = function(info, offset) DB.frames.icons[info[#info-3] ][info[#info-1] ][4] = (offset);LockDown(Serenity.SetupIconsModule) end,
								},										
							},
						},
					},
				},
				iconborder = {
					type = "group",
					order = 4,
					name = L2["Icon's Border"],
					guiInline = false,
					args = {
						iconenableborder = {
							type = "toggle",
							order = 1,
							name = L2["Enable"],
							desc = L2["DESCBORDER_ENABLE"],
							get = function(info) return DB.frames.icons[info[#info-2] ][info[#info] ] end,
							set = function(info, value) DB.frames.icons[info[#info-2] ][info[#info] ] = value;LockDown(Serenity.SetupIconsModule) end,
						},
						iconbordertexture = {
							type = "select",
							dialogControl = 'LSM30_Border',
							order = 2,
							name = L2["Border texture"],
							values = AceGUIWidgetLSMlists.border,
							disabled = function(info) return not DB.frames.icons[info[#info-2] ]["iconenableborder"] end,
							get = function(info) return DB.frames.icons[info[#info-2] ][info[#info] ] end,
							set = function(info, value) DB.frames.icons[info[#info-2] ][info[#info] ] = value;LockDown(Serenity.SetupIconsModule) end,
						},
						iconbordercolor = {
							type = "color",
							order = 3,
							name = L2["Border color"],
							hasAlpha = true,
							disabled = function(info) return not DB.frames.icons[info[#info-2] ]["iconenableborder"] end,
							get = function(info) return unpack(DB.frames.icons[info[#info-2] ][info[#info] ]) end,
							set = function(info, r, g, b, a) DB.frames.icons[info[#info-2] ][info[#info] ] = {r, g, b, a};LockDown(Serenity.SetupIconsModule) end,
						},
						iconedgesize = {
							type = "range",
							order = 4,
							name = L2["Edge Size"],
							desc = L2["DESCEDGESIZE_ENABLE"],
							min = -100, softMin = -16, softMax = 16, max = 100, step = 1,
							disabled = function(info) return not DB.frames.icons[info[#info-2] ]["iconenableborder"] end,
							get = function(info) return DB.frames.icons[info[#info-2] ][info[#info] ] end,
							set = function(info, value) DB.frames.icons[info[#info-2] ][info[#info] ] = value;LockDown(Serenity.SetupIconsModule) end,
						},
						spacer1 = { order = 9, type = "description", name = "", desc = "", width = "full"},
						iconbackdropinsets = {
							type = "group",
							order = 10,
							name = L2["Insets"],
							guiInline = true,
							args = {
								left = {
									type = "range",
									order = 1,
									name = L2["Left"],
									min = -50, softMin = -16, softMax = 16, max = 50, step = 1,
									disabled = function(info) return not DB.frames.icons[info[#info-3] ]["iconenableborder"] end,
									get = function(info) return (DB.frames.icons[info[#info-3] ][info[#info-1] ][1]) end,
									set = function(info, offset) DB.frames.icons[info[#info-3] ][info[#info-1] ][1] = (offset);LockDown(Serenity.SetupIconsModule) end,
								},
								right = {
									type = "range", 
									order = 2,
									name = L2["Right"],
									min = -50, softMin = -16, softMax = 16, max = 50, step = 1,
									disabled = function(info) return not DB.frames.icons[info[#info-3] ]["iconenableborder"] end,
									get = function(info) return (DB.frames.icons[info[#info-3] ][info[#info-1] ][2]) end,
									set = function(info, offset) DB.frames.icons[info[#info-3] ][info[#info-1] ][2] = (offset);LockDown(Serenity.SetupIconsModule) end,
								},
								top = {
									type = "range", 
									order = 3,
									name = L2["Top"],
									min = -50, softMin = -16, softMax = 16, max = 50, step = 1,
									disabled = function(info) return not DB.frames.icons[info[#info-3] ]["iconenableborder"] end,
									get = function(info) return (DB.frames.icons[info[#info-3] ][info[#info-1] ][3]) end,
									set = function(info, offset) DB.frames.icons[info[#info-3] ][info[#info-1] ][3] = (offset);LockDown(Serenity.SetupIconsModule) end,
								},
								bottom = {
									type = "range", 
									order = 4,
									name = L2["Bottom"],
									min = -50, softMin = -16, softMax = 16, max = 50, step = 1,
									disabled = function(info) return not DB.frames.icons[info[#info-3] ]["iconenableborder"] end,
									get = function(info) return (DB.frames.icons[info[#info-3] ][info[#info-1] ][4]) end,
									set = function(info, offset) DB.frames.icons[info[#info-3] ][info[#info-1] ][4] = (offset);LockDown(Serenity.SetupIconsModule) end,
								},										
							},
						},
					},
				},
			},
		}
		ord = ord + 1
	end
end

function SerenityOptions:SetupOptions()

	local SerenityOptionsTable = {
		type = "group",
		name = "Serenity",		
		args = {
			main = {
				order = 1,
				type = "group",
				name = Serenity.L["General Settings"],
				args = {
					build = {
						order = 1,
						type = "description",
						name = L2["SERENITY_BUILD"]..Serenity.V["shortversion"].."\n",
					},
					intro = {
						order = 3,
						type = "description",
						name = Serenity.L["SERENITY_DESC"].."\n",
					},
					spacer1 = { order = 3, type = "description", name = " ", desc = "", width = "full"},
					masteraudio = {
						type = "toggle",
						order = 6,
						name = L2["Enable master audio channel for sounds"],
						desc = L2["MASTERAUDIO_DESC"],
						width = "full",
						get = function(info) return DB[info[#info] ] end,
						set = function(info, value) DB[info[#info] ] = value end,
					},
					spacer2 = { order = 8, type = "description", name = " ", desc = "", width = "full"},
					minfortenths = {
						type = "range", 
						order = 10,
						name = L2["Tenths of seconds display"],
						desc = L2["MINFORTENTHS_DESC"],
						--width = "full",
						min = 1, max = 9, step = 1,
						get = function(info) return (DB[info[#info] ]) end,
						set = function(info, val) DB[info[#info] ] = (val) end,
					},
				},
			},
			template = {
				order = 2,
				type = "group",
				name = L2["Template"],
				childGroups = "tree",
				args = {
					intro = {
						order = 1,
						type = "description",
						name = L2["TEMPLATE_DESC"].."\n",
					},
					templates = {
						order = 2,
						type = "select",
						style = "dropdown",
						name = L2["Pick a re-styling template:"],
						desc = L2["TEMPLATE_DESC2"],
						confirm = true,
						values = function()
								local t = {}
								local k, v
								for k,v in pairs(Serenity.V["templates"]) do t[k] = k end
								return t
							end,
						get = function(info, value) return("") end,
						set = function(info, value)
								--DB.frames = Serenity.DeepCopy(Serenity.V["templates"][value].frames)
								-- Timers are copied from the timer template section to a timer[setname] section in the db.
								Serenity.ApplyTemplate(value)
								Serenity.db.profile.basetemplate = value
								SerenityOptions:PopulateDB()
								LockDown(Serenity.ReconfigureSerenity)
							end,
					},
				},
			},
			frames = {
				order = 2,
				type = "group",
				name = L2["Styling"],
				childGroups = "select",
				args = {
					intro = {
						order = 1,
						type = "description",
						name = L2["STYLES_DESC"].."\n",
					},
					movers = {
						order = 2,
						type = "group",
						name = L2["Mover Frames"],
						guiInline = false,
						args = {
							intro = {
								order = 1,
								type = "description",
								name = L2["MOVERS_DESC"].."\n",
							},							
							titlefont = {
								type = "group",
								order = 2,
								name = L2["Title font"],
								guiInline = false,
								childGroups = "tab",
								args = {
									font = {
										type = "select", 
										dialogControl = 'LSM30_Font',
										order = 1,
										name = L2["Font Face"],
										desc = L2["This is the font used for the title of the movable frames when you unlock Serenity."],
										values = AceGUIWidgetLSMlists.font,
										get = function(info) return DB.frames.movers[ info[#info-1] ][1] end,
										set = function(info, font) DB.frames.movers[ info[#info-1] ][1] = font;Serenity.RedrawLiveMovers() end,
									},
									size = {
										type = "range", 
										order = 2,
										name = L2["Font Size"],
										min = 6, max = 40, step = 1,
										get = function(info) return (DB.frames.movers[ info[#info-1] ][2]) end,
										set = function(info, size) DB.frames.movers[ info[#info-1] ][2] = (size);Serenity.RedrawLiveMovers() end,
									},
									flags = {
										type = "multiselect", 
										order = 3,
										name = L2["Font Flags"],
										values = fontFlagTable,
										get = function(info, key) return(tContains({strsplit(",", DB.frames.movers[ info[#info-1] ][3])}, key) and true or false) end,
										set = function(info, keyname, state) setFontFlags(DB.frames.movers[ info[#info-1] ], keyname, state);Serenity.RedrawLiveMovers() end,
									},
								},
							},
							titlefontcolor = {
								type = "group",
								order = 3,
								name = L2["Title font's color"],
								guiInline = false,
								childGroups = "tab",
								args = {
									color = {
										type = "color",
										order = 1,
										name = L2["Title font's color"],
										desc = L2["Color of a movable frame's title text"],
										hasAlpha = true,
										get = function(info) return unpack(DB.frames.movers[ info[#info-1] ]) end,
										set = function(info, r, g, b, a) DB.frames.movers[ info[#info-1] ] = {r, g, b, a};Serenity.RedrawLiveMovers() end,
									},
								},
							},
							foreground = {
								type = "group",
								order = 4,
								name = L2["Frame color"],
								guiInline = false,
								childGroups = "tab",
								args = {
									color = {
										type = "color",
										order = 1,
										name = L2["Frame color"],
										desc = L2["Color of the movable frame"],
										get = function(info) return unpack(DB.frames.movers[info[#info-1] ]) end,
										set = function(info, r, g, b, a) DB.frames.movers[info[#info-1] ] = {r, g, b, a};Serenity.RedrawLiveMovers() end,
										hasAlpha = true,
									},
								},
							},
						},
					},
					cooldowns = {
						order = 3,
						type = "group",
						name = L2["Cooldowns"],
						guiInline = false,
						args = {
							intro = {
								order = 1,
								type = "description",
								name = L2["COOLDOWNS_DESC"].."\n",
							},							
							font = {
								type = "group",
								order = 2,
								name = L2["Cooldown font"],
								guiInline = false,
								args = {
									font = {
										type = "select", 
										dialogControl = 'LSM30_Font',
										order = 1,
										name = L2["Font Face"],
										desc = L2["This is the font used for cooldown or duration timers."],
										values = AceGUIWidgetLSMlists.font,
										get = function(info) return DB.frames.cooldowns[info[#info-1] ][1] end,
										set = function(info, font) DB.frames.cooldowns[info[#info-1] ][1] = font end,
									},
									size = {
										type = "range", 
										order = 2,
										name = L2["Font Size"],
										min = 6, max = 40, step = 1,
										get = function(info) return (DB.frames.cooldowns[info[#info-1] ][2]) end,
										set = function(info, size) DB.frames.cooldowns[info[#info-1] ][2] = (size) end,
									},
									flags = {
										type = "multiselect", 
										order = 3,
										name = L2["Font Flags"],
										values = fontFlagTable,
										get = function(info, key) return(tContains({strsplit(",", DB.frames.cooldowns[info[#info-1] ][3])}, key) and true or false) end,
										set = function(info, keyname, state) setFontFlags(DB.frames.cooldowns[info[#info-1] ], keyname, state) end,
									},
								},
							},
							colors = {
								type = "group",
								order = 3,
								name = L2["Colors"],
								guiInline = false,
								get = function(info) return unpack(DB.frames.cooldowns[info[#info] ]) end,
								set = function(info, r, g, b, a) DB.frames.cooldowns[info[#info] ] = {r, g, b, a} end,
								args = {
									dayscolor = {
										type = "color",
										order = 1,
										name = L2["Days Color"],
										desc = L2["Color when a cooldown is at least a day"],
										hasAlpha = false,
									},
									hourscolor = {
										type = "color",
										order = 2,
										name = L2["Hours Color"],
										desc = L2["Color when a cooldown is at least an hour"],
										hasAlpha = false,
									},
									minutescolor = {
										type = "color",
										order = 3,
										name = L2["Minutes Color"],
										desc = L2["Color when a cooldown is at least a minute"],
										hasAlpha = false,
									},
									secondscolor = {
										type = "color",
										order = 4,
										name = L2["Seconds Color"],
										desc = L2["Color when a cooldown is only seconds"],
										hasAlpha = false,
									},
									expiringcolor = {
										type = "color",
										order = 5,
										name = L2["Expiring Color"],
										desc = L2["Color when a cooldown is about to expire"],
										hasAlpha = false,
									},
									spacer = { order = 7, type = "description", name = "", desc = "", width = "full", get = nil, set = nil, },
									shadowcolor = {
										type = "color",
										order = 8,
										name = L2["Font Shadow Color"],
										desc = L2["Color used for the cooldown's font shadow"],
										hasAlpha = true,
										disabled = function(info) return not DB.frames.cooldowns.enableshadow end,
									},
								},
							},
							fontshadowoffset = {
								type = "group",
								order = 4,
								name = L2["Font shadow"],
								guiInline = false,
								args = {
									enableshadow = {
										type = "toggle",
										order = 1,
										name = L2["Enable"],
										desc = L2["ENABLESHADOW_DESC"],
										width = "full",
										get = function(info) return DB.frames.cooldowns[info[#info] ] end,
										set = function(info, value) DB.frames.cooldowns[info[#info] ] = value;LockDown(Serenity.SetupTimersModule) end,
									},
									spacer = { order = 2, type = "description", name = "", desc = "", width = "full"},
									offsetX = {
										type = "input", 
										order = 3,
										name = L2["X Offset"],
										desc = L2["This sets the 'X offset' value."],
										width = "half",
										pattern = "%d",
										usage = L2["Only valid numeric offsets are allowed."],
										disabled = function(info) return not DB.frames.cooldowns.enableshadow end,
										get = function(info) return tostring(DB.frames.cooldowns[info[#info-1] ][1]) end,
										set = function(info, offset) DB.frames.cooldowns[info[#info-1] ][1] = tonumber(offset) end,
									},
									offsetY = {
										type = "input", 
										order = 4,
										name = L2["Y Offset"],
										desc = L2["This sets the 'Y offset' value."],
										width = "half",
										pattern = "%d",
										usage = L2["Only valid numeric offsets are allowed."],
										disabled = function(info) return not DB.frames.cooldowns.enableshadow end,
										get = function(info) return tostring(DB.frames.cooldowns[info[#info-1] ][2]) end,
										set = function(info, offset) DB.frames.cooldowns[info[#info-1] ][2] = tonumber(offset) end,
									},
								},
							},
						},
					},
					energybar = {
						order = 4,
						type = "group",
						name = L2["Energy Bar"],
						guiInline = false,
						args = {
							intro = {
								order = 1,
								type = "description",
								name = L2["ENERGYBAR_DESC"].."\n",
							},
							size = {
								type = "group",
								order = 2,
								name = L2["Size of the bar"],
								guiInline = false,
								args = {
									width = {
										type = "range", 
										order = 1,
										name = L2["Width"],
										min = 20, softMax = 600, max = 2000, step = 1,
										get = function(info) return (DB.frames.energybar[info[#info] ]) end,
										set = function(info, size) DB.frames.energybar[info[#info] ] = (size);LockDown(Serenity.SetupEnergyBarModule) end,
									},
									height = {
										type = "range", 
										order = 2,
										name = L2["Height"],
										min = 6, softMax = 200, max = 400, step = 1,
										get = function(info) return (DB.frames.energybar[info[#info] ]) end,
										set = function(info, size) DB.frames.energybar[info[#info] ] = (size);LockDown(Serenity.SetupEnergyBarModule) end,
									},
								},
							},									
							energyfont = {
								type = "group",
								order = 3,
								name = L2["Current energy font"],
								guiInline = false,
								args = {
									font = {
										type = "select", 
										dialogControl = "LSM30_Font",
										order = 1,
										name = L2["Font Face"],
										desc = L2["This is the font used for your current energy, focus, rage, etc."],
										values = AceGUIWidgetLSMlists.font,
										get = function(info) return DB.frames.energybar[info[#info-1] ][1] end,
										set = function(info, font) DB.frames.energybar[info[#info-1] ][1] = font;LockDown(Serenity.SetupEnergyBarModule) end,
									},
									size = {
										type = "range", 
										order = 2,
										name = L2["Font Size"],
										min = 6, max = 40, step = 1,
										get = function(info) return (DB.frames.energybar[info[#info-1] ][2]) end,
										set = function(info, size) DB.frames.energybar[info[#info-1] ][2] = (size);LockDown(Serenity.SetupEnergyBarModule) end,
									},
									flags = {
										type = "multiselect", 
										order = 3,
										name = L2["Font Flags"],
										values = fontFlagTable,
										get = function(info, key) return(tContains({strsplit(",", DB.frames.energybar[info[#info-1] ][3])}, key) and true or false) end,
										set = function(info, keyname, state) setFontFlags(DB.frames.energybar[info[#info-1] ], keyname, state);LockDown(Serenity.SetupEnergyBarModule) end,
									},
								},
							},
							energyfontcolor = {
								type = "group",
								order = 8,
								name = L2["Current energy text color"],
								guiInline = false,
								args = {
									energyfontcolor = {
										type = "color",
										order = 8,
										name = L2["Current energy text color"],
										desc = L2["Color of the text showing your current energy."],
										hasAlpha = true,
										get = function(info) return unpack(DB.frames.energybar[info[#info] ]) end,
										set = function(info, r, g, b, a) DB.frames.energybar[info[#info] ] = {r, g, b, a};LockDown(Serenity.SetupEnergyBarModule) end,
									},
								},
							},
							energyfontoffset = {
								type = "group",
								order = 10,
								name = L2["Energy Offset"],
								desc = L2["DESC_ENERGYBARFONTOFFSET"],
								guiInline = false,
								args = {
									energyfontoffset = {
										type = "range", 
										order = 1,
										name = L2["Energy Offset"],
										desc = L2["DESC_ENERGYBARFONTOFFSET"],
										min = -900, softMin = -100, softMax = 100, max = 900, step = 1,
										get = function(info) return (DB.frames.energybar[info[#info] ]) end,
										set = function(info, size) DB.frames.energybar[info[#info] ] = (size);LockDown(Serenity.SetupEnergyBarModule) end,
									},
								},
							},
							healthfont = {
								type = "group",
								order = 12,
								name = L2["Target's health font"],
								guiInline = false,
								args = {
									font = {
										type = "select", 
										dialogControl = 'LSM30_Font',
										order = 1,
										name = L2["Font Face"],
										desc = L2["This is the font used for showing your target's current health percent."],
										values = AceGUIWidgetLSMlists.font,
										get = function(info) return DB.frames.energybar[info[#info-1] ][1] end,
										set = function(info, font) DB.frames.energybar[info[#info-1] ][1] = font;LockDown(Serenity.SetupEnergyBarModule) end,
									},
									size = {
										type = "range", 
										order = 2,
										name = L2["Font Size"],
										min = 6, max = 40, step = 1,
										get = function(info) return (DB.frames.energybar[info[#info-1] ][2]) end,
										set = function(info, size) DB.frames.energybar[info[#info-1] ][2] = (size);LockDown(Serenity.SetupEnergyBarModule) end,
									},
									flags = {
										type = "multiselect", 
										order = 3,
										name = L2["Font Flags"],
										values = fontFlagTable,
										get = function(info, key) return(tContains({strsplit(",", DB.frames.energybar[info[#info-1] ][3])}, key) and true or false) end,
										set = function(info, keyname, state) setFontFlags(DB.frames.energybar[info[#info-1] ], keyname, state);LockDown(Serenity.SetupEnergyBarModule) end,
									},
								},
							},
							healthfontoffset = {
								type = "group",
								order = 14,
								name = L2["Health Offset"],
								desc = L2["DESC_ENERGYBARFONTOFFSET"],
								guiInline = false,
								args = {
									healthfontoffset = {
										type = "range", 
										order = 1,
										name = L2["Health Offset"],
										desc = L2["DESC_ENERGYBARFONTOFFSET"],
										min = -900, softMin = -100, softMax = 100, max = 900, step = 1,
										get = function(info) return (DB.frames.energybar[info[#info] ]) end,
										set = function(info, size) DB.frames.energybar[info[#info] ] = (size);LockDown(Serenity.SetupEnergyBarModule) end,
									},
								},
							},
							shottimerfont = {
								type = "group",
								order = 16,
								name = L2["Shot timer font"],
								guiInline = false,
								args = {
									font = {
										type = "select", 
										dialogControl = 'LSM30_Font',
										order = 1,
										name = L2["Font Face"],
										desc = L2["This is the font used for the shot timer. (A hunter's auto-shot, for example)"],
										values = AceGUIWidgetLSMlists.font,
										get = function(info) return DB.frames.energybar[info[#info-1] ][1] end,
										set = function(info, font) DB.frames.energybar[info[#info-1] ][1] = font;LockDown(Serenity.SetupEnergyBarModule) end,
									},
									size = {
										type = "range", 
										order = 2,
										name = L2["Font Size"],
										min = 6, max = 40, step = 1,
										get = function(info) return (DB.frames.energybar[info[#info-1] ][2]) end,
										set = function(info, size) DB.frames.energybar[info[#info-1] ][2] = (size);LockDown(Serenity.SetupEnergyBarModule) end,
									},
									flags = {
										type = "multiselect", 
										order = 3,
										name = L2["Font Flags"],
										values = fontFlagTable,
										get = function(info, key) return(tContains({strsplit(",", DB.frames.energybar[info[#info-1] ][3])}, key) and true or false) end,
										set = function(info, keyname, state) setFontFlags(DB.frames.energybar[info[#info-1] ], keyname, state);LockDown(Serenity.SetupEnergyBarModule) end,
									},
								},
							},
							shottimerfontcolor = {
								order = 17,
								type = "group",
								name = L2["Shot timer text color"],
								guiInline = false,
								args = {
									shottimerfontcolor = {
										type = "color",
										order = 17,
										name = L2["Shot timer text color"],
										desc = L2["Color of the text showing auto shot/attack timer."],
										hasAlpha = true,
										get = function(info) return unpack(DB.frames.energybar[info[#info] ]) end,
										set = function(info, r, g, b, a) DB.frames.energybar[info[#info] ] = {r, g, b, a};LockDown(Serenity.SetupEnergyBarModule) end,
									},
								},
							},
							shottimerfontoffset = {
								type = "group",
								order = 18,
								name = L2["Shot Timer Offset"],
								guiInline = false,
								args = {
									shottimerfontoffset = {
										type = "range", 
										order = 1,
										name = L2["Shot Timer Offset"],
										desc = L2["DESC_ENERGYBARFONTOFFSET"],
										min = -900, softMin = -100, softMax = 100, max = 900, step = 1,
										get = function(info) return (DB.frames.energybar[info[#info] ]) end,
										set = function(info, size) DB.frames.energybar[info[#info] ] = (size);LockDown(Serenity.SetupEnergyBarModule) end,
									},
								},
							},
							bartexture = {
								type = "group",
								order = 20,
								name = L2["Energy bar style"],
								guiInline = false,
								args = {
									bartexture = {
										type = "select",
										dialogControl = 'LSM30_Statusbar',
										order = 1,
										name = L2["Energy bar texture"],
										desc = L2["Texture that gets used on the moving status bar."],
										values = AceGUIWidgetLSMlists.statusbar,
										get = function(info) return DB.frames.energybar[info[#info] ] end,
										set = function(info, value) DB.frames.energybar[info[#info] ] = value;LockDown(Serenity.SetupEnergyBarModule) end,
									},
									spacer1 = { order = 4, type = "description", name = "", desc = "", width = "full"},
									classcolored = {
										type = "toggle",
										order = 6,
										name = L2["Use class colors for the bar"],
										desc = L2["DESCENERGYBARCLASSCOLOR_ENABLE"],
										get = function(info) return DB.frames.energybar[info[#info] ] end,
										set = function(info, value) DB.frames.energybar[info[#info] ] = value;LockDown(Serenity.SetupEnergyBarModule) end,
									},
									barcolor = {
										type = "color",
										order = 8,
										name = L2["Bar's normal color"],
										desc = L2["ENERGYBARCOLORNORM_DESC"],
										hasAlpha = true,
										hidden = function(info) return DB.frames.energybar.classcolored end,
										get = function(info) return unpack(DB.frames.energybar[info[#info] ]) end,
										set = function(info, r, g, b, a) DB.frames.energybar[info[#info] ] = {r, g, b, a};LockDown(Serenity.SetupEnergyBarModule) end,
									},
									barcolorlow = {
										type = "color",
										order = 10,
										name = L2["Bar's low warning color"],
										desc = L2["ENERGYBARCOLORNORM_DESC"],
										hasAlpha = true,
										hidden = function(info) return not DB.energybar.lowwarn end,
										get = function(info) return unpack(DB.frames.energybar[info[#info] ]) end,
										set = function(info, r, g, b, a) DB.frames.energybar[info[#info] ] = {r, g, b, a};LockDown(Serenity.SetupEnergyBarModule) end,
									},
									barcolorhigh = {
										type = "color",
										order = 12,
										name = L2["Bar's high warning color"],
										desc = L2["ENERGYBARCOLORNORM_DESC"],
										hasAlpha = true,
										hidden = function(info) return not DB.energybar.highwarn end,
										get = function(info) return unpack(DB.frames.energybar[info[#info] ]) end,
										set = function(info, r, g, b, a) DB.frames.energybar[info[#info] ] = {r, g, b, a};LockDown(Serenity.SetupEnergyBarModule) end,
									},
									shotbarcolor = {
										type = "color",
										order = 16,
										name = L2["Auto shot/attack bar color"],
										hasAlpha = true,
										hidden = function(info) return not DB.energybar.shotbar end,
										get = function(info) return unpack(DB.frames.energybar[info[#info] ]) end,
										set = function(info, r, g, b, a) DB.frames.energybar[info[#info] ] = {r, g, b, a};LockDown(Serenity.SetupEnergyBarModule) end,
									},
								},
							},
							backdrop = {
								type = "group",
								order = 22,
								name = L2["Backdrop"],
								guiInline = false,
								args = {
									enablebackdrop = {
										type = "toggle",
										order = 1,
										name = L2["Enable"],
										desc = L2["DESCBACKDROP_ENABLE"],
										get = function(info) return DB.frames.energybar[info[#info] ] end,
										set = function(info, value) DB.frames.energybar[info[#info] ] = value;LockDown(Serenity.SetupEnergyBarModule) end,
									},
									backdroptexture = {
										type = "select",
										dialogControl = 'LSM30_Background',
										order = 2,
										name = L2["Backdrop texture"],
										desc = L2["Texture that gets used for the bar's background."],
										values = AceGUIWidgetLSMlists.background,
										disabled = function(info) return not DB.frames.energybar["enablebackdrop"] end,
										get = function(info) return DB.frames.energybar[info[#info] ] end,
										set = function(info, value) DB.frames.energybar[info[#info] ] = value;LockDown(Serenity.SetupEnergyBarModule) end,
									},
									colorbackdrop = {
										type = "toggle",
										order = 3,
										name = L2["Color the backdrop"],
										desc = L2["DESCBACKDROPCOLOR_ENABLE"],
										disabled = function(info) return not DB.frames.energybar["enablebackdrop"] end,
										get = function(info) return DB.frames.energybar[info[#info] ] end,
										set = function(info, value) DB.frames.energybar[info[#info] ] = value;LockDown(Serenity.SetupEnergyBarModule) end,
									},
									backdropcolor = {
										type = "color",
										order = 5,
										name = L2["Backdrop color"],
										hasAlpha = true,
										disabled = function(info) return not DB.frames.energybar["enablebackdrop"] end,
										hidden = function(info) return not DB.frames.energybar.colorbackdrop end,
										get = function(info) return unpack(DB.frames.energybar[info[#info] ]) end,
										set = function(info, r, g, b, a) DB.frames.energybar[info[#info] ] = {r, g, b, a};LockDown(Serenity.SetupEnergyBarModule) end,
									},
									tile = {
										type = "toggle",
										order = 7,
										name = L2["Tile the backdrop"],
										desc = L2["DESCBACKDROPTILE_ENABLE"],
										disabled = function(info) return not DB.frames.energybar["enablebackdrop"] end,
										get = function(info) return DB.frames.energybar[info[#info] ] end,
										set = function(info, value) DB.frames.energybar[info[#info] ] = value;LockDown(Serenity.SetupEnergyBarModule) end,
									},
									tilesize = {
										type = "range",
										order = 8,
										name = L2["Tile Size"],
										desc = L2["DESCTILESIZE_ENABLE"],
										min = -100, softMin = -30, softMax = 30, max = 100, step = 1,
										disabled = function(info) return not DB.frames.energybar["enablebackdrop"] end,
										hidden = function(info) return not DB.frames.energybar.tile end,
										get = function(info) return DB.frames.energybar[info[#info] ] end,
										set = function(info, value) DB.frames.energybar[info[#info] ] = value;LockDown(Serenity.SetupEnergyBarModule) end,
									},
									spacer = { order = 11, type = "description", name = "", desc = "", width = "full"},
									backdropoffsets = {
										type = "group",
										order = 14,
										name = L2["Offsets"],
										guiInline = true,
										args = {
											offsetX1 = {
												type = "range",
												order = 1,
												name = L2["Top-Left X"],
												desc = L2["This sets the 'X offset' value."],
												min = -50, softMin = -10, softMax = 0, max = 50, step = 1,
												disabled = function(info) return not DB.frames.energybar["enablebackdrop"] end,
												get = function(info) return (DB.frames.energybar[info[#info-1] ][1]) end,
												set = function(info, offset) DB.frames.energybar[info[#info-1] ][1] = (offset);LockDown(Serenity.SetupEnergyBarModule) end,
											},
											offsetY1 = {
												type = "range", 
												order = 2,
												name = L2["Top-Left Y"],
												desc = L2["This sets the 'Y offset' value."],
												min = -50, softMin = 0, softMax = 10, max = 50, step = 1,
												disabled = function(info) return not DB.frames.energybar["enablebackdrop"] end,
												get = function(info) return (DB.frames.energybar[info[#info-1] ][2]) end,
												set = function(info, offset) DB.frames.energybar[info[#info-1] ][2] = (offset);LockDown(Serenity.SetupEnergyBarModule) end,
											},
											offsetX2 = {
												type = "range", 
												order = 3,
												name = L2["Bottom-Right X"],
												desc = L2["This sets the 'X offset' value."],
												min = -50, softMin = 0, softMax = 10, max = 50, step = 1,
												disabled = function(info) return not DB.frames.energybar["enablebackdrop"] end,
												get = function(info) return (DB.frames.energybar[info[#info-1] ][3]) end,
												set = function(info, offset) DB.frames.energybar[info[#info-1] ][3] = (offset);LockDown(Serenity.SetupEnergyBarModule) end,
											},
											offsetY2 = {
												type = "range", 
												order = 4,
												name = L2["Bottom-Right Y"],
												desc = L2["This sets the 'Y offset' value."],
												min = -50, softMin = -10, softMax = 0, max = 50, step = 1,
												disabled = function(info) return not DB.frames.energybar["enablebackdrop"] end,
												get = function(info) return (DB.frames.energybar[info[#info-1] ][4]) end,
												set = function(info, offset) DB.frames.energybar[info[#info-1] ][4] = (offset);LockDown(Serenity.SetupEnergyBarModule) end,
											},										
										},
									},
									spacer = { order = 16, type = "description", name = "", desc = "", width = "full"},
								},
							},
							border = {
								type = "group",
								order = 24,
								name = L2["Border"],
								guiInline = false,
								args = {
									enableborder = {
										type = "toggle",
										order = 1,
										name = L2["Enable"],
										desc = L2["DESCBORDER_ENABLE"],
										get = function(info) return DB.frames.energybar[info[#info] ] end,
										set = function(info, value) DB.frames.energybar[info[#info] ] = value;LockDown(Serenity.SetupEnergyBarModule) end,
									},
									bordertexture = {
										type = "select",
										dialogControl = 'LSM30_Border',
										order = 2,
										name = L2["Border texture"],
										desc = L2["Texture that gets used for the bar's background."],
										values = AceGUIWidgetLSMlists.border,
										disabled = function(info) return not DB.frames.energybar["enableborder"] end,
										get = function(info) return DB.frames.energybar[info[#info] ] end,
										set = function(info, value) DB.frames.energybar[info[#info] ] = value;LockDown(Serenity.SetupEnergyBarModule) end,
									},
									bordercolor = {
										type = "color",
										order = 3,
										name = L2["Border color"],
										hasAlpha = true,
										disabled = function(info) return not DB.frames.energybar["enableborder"] end,
										get = function(info) return unpack(DB.frames.energybar[info[#info] ]) end,
										set = function(info, r, g, b, a) DB.frames.energybar[info[#info] ] = {r, g, b, a};LockDown(Serenity.SetupEnergyBarModule) end,
									},
									edgesize = {
										type = "range",
										order = 4,
										name = L2["Edge Size"],
										desc = L2["DESCEDGESIZE_ENABLE"],
										min = -100, softMin = -16, softMax = 16, max = 100, step = 1,
										disabled = function(info) return not DB.frames.energybar["enableborder"] end,
										get = function(info) return DB.frames.energybar[info[#info] ] end,
										set = function(info, value) DB.frames.energybar[info[#info] ] = value;LockDown(Serenity.SetupEnergyBarModule) end,
									},
									spacer = { order = 7, type = "description", name = "", desc = "", width = "full"},
									backdropinsets = {
										type = "group",
										order = 10,
										name = L2["Insets"],
										guiInline = true,
										args = {
											left = {
												type = "range",
												order = 1,
												name = L2["Left"],
												min = -50, softMin = -16, softMax = 16, max = 50, step = 1,
												disabled = function(info) return not DB.frames.energybar["enableborder"] end,
												get = function(info) return (DB.frames.energybar[info[#info-1] ][1]) end,
												set = function(info, offset) DB.frames.energybar[info[#info-1] ][1] = (offset);LockDown(Serenity.SetupEnergyBarModule) end,
											},
											right = {
												type = "range", 
												order = 2,
												name = L2["Right"],
												min = -50, softMin = -16, softMax = 16, max = 50, step = 1,
												disabled = function(info) return not DB.frames.energybar["enableborder"] end,
												get = function(info) return (DB.frames.energybar[info[#info-1] ][2]) end,
												set = function(info, offset) DB.frames.energybar[info[#info-1] ][2] = (offset);LockDown(Serenity.SetupEnergyBarModule) end,
											},
											top = {
												type = "range", 
												order = 3,
												name = L2["Top"],
												min = -50, softMin = -16, softMax = 16, max = 50, step = 1,
												disabled = function(info) return not DB.frames.energybar["enableborder"] end,
												get = function(info) return (DB.frames.energybar[info[#info-1] ][3]) end,
												set = function(info, offset) DB.frames.energybar[info[#info-1] ][3] = (offset);LockDown(Serenity.SetupEnergyBarModule) end,
											},
											bottom = {
												type = "range", 
												order = 4,
												name = L2["Bottom"],
												min = -50, softMin = -16, softMax = 16, max = 50, step = 1,
												disabled = function(info) return not DB.frames.energybar["enableborder"] end,
												get = function(info) return (DB.frames.energybar[info[#info-1] ][4]) end,
												set = function(info, offset) DB.frames.energybar[info[#info-1] ][4] = (offset);LockDown(Serenity.SetupEnergyBarModule) end,
											},										
										},
									},
								},
							},
							shotbarcolor = {
								order = 26,
								type = "group",
								name = L2["Shot bar's color"],
								guiInline = false,
								args = {
									shotbarcolor = {
										type = "color",
										order = 17,
										name = L2["Shot bar's color"],
										desc = L2["Color of the bar showing auto shot/attack timer."],
										hasAlpha = true,
										get = function(info) return unpack(DB.frames.energybar[info[#info] ]) end,
										set = function(info, r, g, b, a) DB.frames.energybar[info[#info] ] = {r, g, b, a};LockDown(Serenity.SetupEnergyBarModule) end,
									},
								},
							},
						},
					},
					enrage = {
						order = 5,
						type = "group",
						name = L2["Enrage Alert"],
						guiInline = false,
						args = {
							intro = {
								order = 1,
								type = "description",
								name = L2["ENRAGE_DESC"].."\n",
							},
							sizes = {
								type = "group",
								order = 2,
								name = L2["Sizes"],
								guiInline = false,
								args = {
									iconsize = {
										type = "range", 
										order = 1,
										name = L2["Alert icon size"],
										min = 10, max = 100, step = 1,
										get = function(info) return (DB.frames.enrage[info[#info] ]) end,
										set = function(info, size) DB.frames.enrage[info[#info] ] = (size);LockDown(Serenity.SetupEnrageModule) end,
									},
									iconsizeremovables = {
										type = "range", 
										order = 1,
										name = L2["Removables icon size"],
										desc = L2["ENRAGEREOMVABLESSIZE_DESC"],
										min = 10, max = 100, step = 1,
										get = function(info) return (DB.frames.enrage[info[#info] ]) end,
										set = function(info, size) DB.frames.enrage[info[#info] ] = (size);LockDown(Serenity.SetupEnrageModule) end,
									},
								},
							},
							backdrop = {
								type = "group",
								order = 22,
								name = L2["Backdrop"],
								guiInline = false,
								args = {
									enablebackdrop = {
										type = "toggle",
										order = 1,
										name = L2["Enable"],
										desc = L2["DESCBACKDROP_ENABLE"],
										get = function(info) return DB.frames.enrage[info[#info] ] end,
										set = function(info, value) DB.frames.enrage[info[#info] ] = value;LockDown(Serenity.SetupEnrageModule) end,
									},
									backdroptexture = {
										type = "select",
										dialogControl = 'LSM30_Background',
										order = 2,
										name = L2["Backdrop texture"],
										desc = L2["Texture that gets used for the background."],
										values = AceGUIWidgetLSMlists.background,
										disabled = function(info) return not DB.frames.enrage["enablebackdrop"] end,
										get = function(info) return DB.frames.enrage[info[#info] ] end,
										set = function(info, value) DB.frames.enrage[info[#info] ] = value;LockDown(Serenity.SetupEnrageModule) end,
									},
									colorbackdrop = {
										type = "toggle",
										order = 3,
										name = L2["Color the backdrop"],
										desc = L2["DESCBACKDROPCOLOR_ENABLE"],
										disabled = function(info) return not DB.frames.enrage["enablebackdrop"] end,
										get = function(info) return DB.frames.enrage[info[#info] ] end,
										set = function(info, value) DB.frames.enrage[info[#info] ] = value;LockDown(Serenity.SetupEnrageModule) end,
									},
									backdropcolor = {
										type = "color",
										order = 5,
										name = L2["Backdrop color"],
										hasAlpha = true,
										disabled = function(info) return not DB.frames.enrage["enablebackdrop"] end,
										hidden = function(info) return not DB.frames.enrage.colorbackdrop end,
										get = function(info) return unpack(DB.frames.enrage[info[#info] ]) end,
										set = function(info, r, g, b, a) DB.frames.enrage[info[#info] ] = {r, g, b, a};LockDown(Serenity.SetupEnrageModule) end,
									},
									tile = {
										type = "toggle",
										order = 7,
										name = L2["Tile the backdrop"],
										desc = L2["DESCBACKDROPTILE_ENABLE"],
										disabled = function(info) return not DB.frames.enrage["enablebackdrop"] end,
										get = function(info) return DB.frames.enrage[info[#info] ] end,
										set = function(info, value) DB.frames.enrage[info[#info] ] = value;LockDown(Serenity.SetupEnrageModule) end,
									},
									tilesize = {
										type = "range",
										order = 8,
										name = L2["Tile Size"],
										desc = L2["DESCTILESIZE_ENABLE"],
										min = -100, softMin = -30, softMax = 30, max = 100, step = 1,
										disabled = function(info) return not DB.frames.enrage["enablebackdrop"] end,
										hidden = function(info) return not DB.frames.enrage.tile end,
										get = function(info) return DB.frames.enrage[info[#info] ] end,
										set = function(info, value) DB.frames.enrage[info[#info] ] = value;LockDown(Serenity.SetupEnrageModule) end,
									},
									spacer = { order = 11, type = "description", name = "", desc = "", width = "full"},
									backdropoffsets = {
										type = "group",
										order = 14,
										name = L2["Offsets"],
										guiInline = true,
										args = {
											offsetX1 = {
												type = "range",
												order = 1,
												name = L2["Top-Left X"],
												desc = L2["This sets the 'X offset' value."],
												min = -50, softMin = -10, softMax = 0, max = 50, step = 1,
												disabled = function(info) return not DB.frames.enrage["enablebackdrop"] end,
												get = function(info) return (DB.frames.enrage[info[#info-1] ][1]) end,
												set = function(info, offset) DB.frames.enrage[info[#info-1] ][1] = (offset);LockDown(Serenity.SetupEnrageModule) end,
											},
											offsetY1 = {
												type = "range", 
												order = 2,
												name = L2["Top-Left Y"],
												desc = L2["This sets the 'Y offset' value."],
												min = -50, softMin = 0, softMax = 10, max = 50, step = 1,
												disabled = function(info) return not DB.frames.enrage["enablebackdrop"] end,
												get = function(info) return (DB.frames.enrage[info[#info-1] ][2]) end,
												set = function(info, offset) DB.frames.enrage[info[#info-1] ][2] = (offset);LockDown(Serenity.SetupEnrageModule) end,
											},
											offsetX2 = {
												type = "range", 
												order = 3,
												name = L2["Bottom-Right X"],
												desc = L2["This sets the 'X offset' value."],
												min = -50, softMin = 0, softMax = 10, max = 50, step = 1,
												disabled = function(info) return not DB.frames.enrage["enablebackdrop"] end,
												get = function(info) return (DB.frames.enrage[info[#info-1] ][3]) end,
												set = function(info, offset) DB.frames.enrage[info[#info-1] ][3] = (offset);LockDown(Serenity.SetupEnrageModule) end,
											},
											offsetY2 = {
												type = "range", 
												order = 4,
												name = L2["Bottom-Right Y"],
												desc = L2["This sets the 'Y offset' value."],
												min = -50, softMin = -10, softMax = 0, max = 50, step = 1,
												disabled = function(info) return not DB.frames.enrage["enablebackdrop"] end,
												get = function(info) return (DB.frames.enrage[info[#info-1] ][4]) end,
												set = function(info, offset) DB.frames.enrage[info[#info-1] ][4] = (offset);LockDown(Serenity.SetupEnrageModule) end,
											},										
										},
									},
									spacer = { order = 16, type = "description", name = "", desc = "", width = "full"},
								},
							},
							border = {
								type = "group",
								order = 24,
								name = L2["Border"],
								guiInline = false,
								args = {
									enableborder = {
										type = "toggle",
										order = 1,
										name = L2["Enable"],
										desc = L2["DESCBORDER_ENABLE"],
										get = function(info) return DB.frames.enrage[info[#info] ] end,
										set = function(info, value) DB.frames.enrage[info[#info] ] = value;LockDown(Serenity.SetupEnrageModule) end,
									},
									bordertexture = {
										type = "select",
										dialogControl = 'LSM30_Border',
										order = 2,
										name = L2["Border texture"],
										desc = L2["Texture that gets used for the border."],
										values = AceGUIWidgetLSMlists.border,
										disabled = function(info) return not DB.frames.enrage["enableborder"] end,
										get = function(info) return DB.frames.enrage[info[#info] ] end,
										set = function(info, value) DB.frames.enrage[info[#info] ] = value;LockDown(Serenity.SetupEnrageModule) end,
									},
									bordercolor = {
										type = "color",
										order = 3,
										name = L2["Border color"],
										hasAlpha = true,
										disabled = function(info) return not DB.frames.enrage["enableborder"] end,
										get = function(info) return unpack(DB.frames.enrage[info[#info] ]) end,
										set = function(info, r, g, b, a) DB.frames.enrage[info[#info] ] = {r, g, b, a};LockDown(Serenity.SetupEnrageModule) end,
									},
									edgesize = {
										type = "range",
										order = 4,
										name = L2["Edge Size"],
										desc = L2["DESCEDGESIZE_ENABLE"],
										min = -100, softMin = -16, softMax = 16, max = 100, step = 1,
										disabled = function(info) return not DB.frames.enrage["enableborder"] end,
										get = function(info) return DB.frames.enrage[info[#info] ] end,
										set = function(info, value) DB.frames.enrage[info[#info] ] = value;LockDown(Serenity.SetupEnrageModule) end,
									},
									spacer = { order = 7, type = "description", name = "", desc = "", width = "full"},
									backdropinsets = {
										type = "group",
										order = 10,
										name = L2["Insets"],
										guiInline = true,
										args = {
											left = {
												type = "range",
												order = 1,
												name = L2["Left"],
												min = -50, softMin = -16, softMax = 16, max = 50, step = 1,
												disabled = function(info) return not DB.frames.enrage["enableborder"] end,
												get = function(info) return (DB.frames.enrage[info[#info-1] ][1]) end,
												set = function(info, offset) DB.frames.enrage[info[#info-1] ][1] = (offset);LockDown(Serenity.SetupEnrageModule) end,
											},
											right = {
												type = "range", 
												order = 2,
												name = L2["Right"],
												min = -50, softMin = -16, softMax = 16, max = 50, step = 1,
												disabled = function(info) return not DB.frames.enrage["enableborder"] end,
												get = function(info) return (DB.frames.enrage[info[#info-1] ][2]) end,
												set = function(info, offset) DB.frames.enrage[info[#info-1] ][2] = (offset);LockDown(Serenity.SetupEnrageModule) end,
											},
											top = {
												type = "range", 
												order = 3,
												name = L2["Top"],
												min = -50, softMin = -16, softMax = 16, max = 50, step = 1,
												disabled = function(info) return not DB.frames.enrage["enableborder"] end,
												get = function(info) return (DB.frames.enrage[info[#info-1] ][3]) end,
												set = function(info, offset) DB.frames.enrage[info[#info-1] ][3] = (offset);LockDown(Serenity.SetupEnrageModule) end,
											},
											bottom = {
												type = "range", 
												order = 4,
												name = L2["Bottom"],
												min = -50, softMin = -16, softMax = 16, max = 50, step = 1,
												disabled = function(info) return not DB.frames.enrage["enableborder"] end,
												get = function(info) return (DB.frames.enrage[info[#info-1] ][4]) end,
												set = function(info, offset) DB.frames.enrage[info[#info-1] ][4] = (offset);LockDown(Serenity.SetupEnrageModule) end,
											},										
										},
									},
								},
							},
							texcoords = {
								type = "group",
								order = 8,
								name = L2["Alert Texture Coords"],
								guiInline = false,
								args = {						
									enabletexcoords = {
										type = "toggle",
										order = 5,
										name = L2["Enable TexCoords"],
										desc = L2["DESCTEXCOORDS_ENABLE"],
										get = function(info) return DB.frames.enrage[info[#info] ] end,
										set = function(info, value) DB.frames.enrage[info[#info] ] = value;LockDown(Serenity.SetupEnrageModule) end,
									},
									texcoords = {
										type = "group",
										order = 6,
										name = L2["Texture Coords"],
										guiInline = true,
										args = {
											left = {
												type = "range",
												order = 1,
												name = L2["Left"],
												min = 0, max = 1, step = .01,
												disabled = function(info) return not DB.frames.enrage["enabletexcoords"] end,
												get = function(info) return (DB.frames.enrage[info[#info-1] ][1]) end,
												set = function(info, offset) DB.frames.enrage[info[#info-1] ][1] = (offset);LockDown(Serenity.SetupEnrageModule) end,
											},
											right = {
												type = "range", 
												order = 2,
												name = L2["Right"],
												min = 0, max = 1, step = .01,
												disabled = function(info) return not DB.frames.enrage["enabletexcoords"] end,
												get = function(info) return (DB.frames.enrage[info[#info-1] ][2]) end,
												set = function(info, offset) DB.frames.enrage[info[#info-1] ][2] = (offset);LockDown(Serenity.SetupEnrageModule) end,
											},
											top = {
												type = "range", 
												order = 3,
												name = L2["Top"],
												min = 0, max = 1, step = .01,
												disabled = function(info) return not DB.frames.enrage["enabletexcoords"] end,
												get = function(info) return (DB.frames.enrage[info[#info-1] ][3]) end,
												set = function(info, offset) DB.frames.enrage[info[#info-1] ][3] = (offset);LockDown(Serenity.SetupEnrageModule) end,
											},
											bottom = {
												type = "range", 
												order = 4,
												name = L2["Bottom"],
												min = 0, max = 1, step = .01,
												disabled = function(info) return not DB.frames.enrage["enabletexcoords"] end,
												get = function(info) return (DB.frames.enrage[info[#info-1] ][4]) end,
												set = function(info, offset) DB.frames.enrage[info[#info-1] ][4] = (offset);LockDown(Serenity.SetupEnrageModule) end,
											},										
										},
									},
								},
							},
							removablesbackdrop = {
								type = "group",
								order = 26,
								name = L2["Removable buff's backdrop"],
								guiInline = false,
								args = {
									removablesenablebackdrop = {
										type = "toggle",
										order = 1,
										name = L2["Enable"],
										desc = L2["DESCBACKDROP_ENABLE"],
										get = function(info) return DB.frames.enrage[info[#info] ] end,
										set = function(info, value) DB.frames.enrage[info[#info] ] = value;LockDown(Serenity.SetupEnrageModule) end,
									},
									removablesbackdroptexture = {
										type = "select",
										dialogControl = 'LSM30_Background',
										order = 2,
										name = L2["Backdrop texture"],
										desc = L2["Texture that gets used for the bar's background."],
										values = AceGUIWidgetLSMlists.background,
										disabled = function(info) return not DB.frames.enrage["removablesenablebackdrop"] end,
										get = function(info) return DB.frames.enrage[info[#info] ] end,
										set = function(info, value) DB.frames.enrage[info[#info] ] = value;LockDown(Serenity.SetupEnrageModule) end,
									},
									removablescolorbackdrop = {
										type = "toggle",
										order = 3,
										name = L2["Color the backdrop"],
										desc = L2["DESCBACKDROPCOLOR_ENABLE"],
										disabled = function(info) return not DB.frames.enrage["removablesenablebackdrop"] end,
										get = function(info) return DB.frames.enrage[info[#info] ] end,
										set = function(info, value) DB.frames.enrage[info[#info] ] = value;LockDown(Serenity.SetupEnrageModule) end,
									},
									removablesbackdropcolor = {
										type = "color",
										order = 5,
										name = L2["Backdrop color"],
										hasAlpha = true,
										disabled = function(info) return not DB.frames.enrage["removablesenablebackdrop"] end,
										hidden = function(info) return not DB.frames.enrage.colorbackdrop end,
										get = function(info) return unpack(DB.frames.enrage[info[#info] ]) end,
										set = function(info, r, g, b, a) DB.frames.enrage[info[#info] ] = {r, g, b, a};LockDown(Serenity.SetupEnrageModule) end,
									},
									removablestile = {
										type = "toggle",
										order = 7,
										name = L2["Tile the backdrop"],
										desc = L2["DESCBACKDROPTILE_ENABLE"],
										disabled = function(info) return not DB.frames.enrage["removablesenablebackdrop"] end,
										get = function(info) return DB.frames.enrage[info[#info] ] end,
										set = function(info, value) DB.frames.enrage[info[#info] ] = value;LockDown(Serenity.SetupEnrageModule) end,
									},
									removablestilesize = {
										type = "range",
										order = 8,
										name = L2["Tile Size"],
										desc = L2["DESCTILESIZE_ENABLE"],
										min = -100, softMin = -30, softMax = 30, max = 100, step = 1,
										disabled = function(info) return not DB.frames.enrage["removablesenablebackdrop"] end,
										hidden = function(info) return not DB.frames.enrage.tile end,
										get = function(info) return DB.frames.enrage[info[#info] ] end,
										set = function(info, value) DB.frames.enrage[info[#info] ] = value;LockDown(Serenity.SetupEnrageModule) end,
									},
									spacer1 = { order = 11, type = "description", name = "", desc = "", width = "full"},
									removablesbackdropoffsets = {
										type = "group",
										order = 14,
										name = L2["Offsets"],
										guiInline = true,
										args = {
											offsetX1 = {
												type = "range",
												order = 1,
												name = L2["Top-Left X"],
												desc = L2["This sets the 'X offset' value."],
												min = -50, softMin = -10, softMax = 0, max = 50, step = 1,
												disabled = function(info) return not DB.frames.enrage["removablesenablebackdrop"] end,
												get = function(info) return (DB.frames.enrage[info[#info-1] ][1]) end,
												set = function(info, offset) DB.frames.enrage[info[#info-1] ][1] = (offset);LockDown(Serenity.SetupEnrageModule) end,
											},
											offsetY1 = {
												type = "range", 
												order = 2,
												name = L2["Top-Left Y"],
												desc = L2["This sets the 'Y offset' value."],
												min = -50, softMin = 0, softMax = 10, max = 50, step = 1,
												disabled = function(info) return not DB.frames.enrage["removablesenablebackdrop"] end,
												get = function(info) return (DB.frames.enrage[info[#info-1] ][2]) end,
												set = function(info, offset) DB.frames.enrage[info[#info-1] ][2] = (offset);LockDown(Serenity.SetupEnrageModule) end,
											},
											offsetX2 = {
												type = "range", 
												order = 3,
												name = L2["Bottom-Right X"],
												desc = L2["This sets the 'X offset' value."],
												min = -50, softMin = 0, softMax = 10, max = 50, step = 1,
												disabled = function(info) return not DB.frames.enrage["removablesenablebackdrop"] end,
												get = function(info) return (DB.frames.enrage[info[#info-1] ][3]) end,
												set = function(info, offset) DB.frames.enrage[info[#info-1] ][3] = (offset);LockDown(Serenity.SetupEnrageModule) end,
											},
											offsetY2 = {
												type = "range", 
												order = 4,
												name = L2["Bottom-Right Y"],
												desc = L2["This sets the 'Y offset' value."],
												min = -50, softMin = -10, softMax = 0, max = 50, step = 1,
												disabled = function(info) return not DB.frames.enrage["removablesenablebackdrop"] end,
												get = function(info) return (DB.frames.enrage[info[#info-1] ][4]) end,
												set = function(info, offset) DB.frames.enrage[info[#info-1] ][4] = (offset);LockDown(Serenity.SetupEnrageModule) end,
											},										
										},
									},
									spacer2 = { order = 16, type = "description", name = "", desc = "", width = "full"},
								},
							},
							removablesborder = {
								type = "group",
								order = 28,
								name = L2["Removable buff's border"],
								guiInline = false,
								args = {
									removablesenableborder = {
										type = "toggle",
										order = 1,
										name = L2["Enable"],
										desc = L2["DESCBORDER_ENABLE"],
										get = function(info) return DB.frames.enrage[info[#info] ] end,
										set = function(info, value) DB.frames.enrage[info[#info] ] = value;LockDown(Serenity.SetupEnrageModule) end,
									},
									removablesbordertexture = {
										type = "select",
										dialogControl = 'LSM30_Border',
										order = 2,
										name = L2["Border texture"],
										desc = L2["Texture that gets used for the bar's background."],
										values = AceGUIWidgetLSMlists.border,
										disabled = function(info) return not DB.frames.enrage["removablesenableborder"] end,
										get = function(info) return DB.frames.enrage[info[#info] ] end,
										set = function(info, value) DB.frames.enrage[info[#info] ] = value;LockDown(Serenity.SetupEnrageModule) end,
									},
									removablesbordercolor = {
										type = "color",
										order = 3,
										name = L2["Border color"],
										hasAlpha = true,
										disabled = function(info) return not DB.frames.enrage["removablesenableborder"] end,
										get = function(info) return unpack(DB.frames.enrage[info[#info] ]) end,
										set = function(info, r, g, b, a) DB.frames.enrage[info[#info] ] = {r, g, b, a};LockDown(Serenity.SetupEnrageModule) end,
									},
									removablesedgesize = {
										type = "range",
										order = 4,
										name = L2["Edge Size"],
										desc = L2["DESCEDGESIZE_ENABLE"],
										min = -100, softMin = -16, softMax = 16, max = 100, step = 1,
										disabled = function(info) return not DB.frames.enrage["removablesenableborder"] end,
										get = function(info) return DB.frames.enrage[info[#info] ] end,
										set = function(info, value) DB.frames.enrage[info[#info] ] = value;LockDown(Serenity.SetupEnrageModule) end,
									},
									spacer1 = { order = 7, type = "description", name = "", desc = "", width = "full"},
									removablesbackdropinsets = {
										type = "group",
										order = 10,
										name = L2["Insets"],
										guiInline = true,
										args = {
											left = {
												type = "range",
												order = 1,
												name = L2["Left"],
												min = -50, softMin = -16, softMax = 16, max = 50, step = 1,
												disabled = function(info) return not DB.frames.enrage["removablesenableborder"] end,
												get = function(info) return (DB.frames.enrage[info[#info-1] ][1]) end,
												set = function(info, offset) DB.frames.enrage[info[#info-1] ][1] = (offset);LockDown(Serenity.SetupEnrageModule) end,
											},
											right = {
												type = "range", 
												order = 2,
												name = L2["Right"],
												min = -50, softMin = -16, softMax = 16, max = 50, step = 1,
												disabled = function(info) return not DB.frames.enrage["removablesenableborder"] end,
												get = function(info) return (DB.frames.enrage[info[#info-1] ][2]) end,
												set = function(info, offset) DB.frames.enrage[info[#info-1] ][2] = (offset);LockDown(Serenity.SetupEnrageModule) end,
											},
											top = {
												type = "range", 
												order = 3,
												name = L2["Top"],
												min = -50, softMin = -16, softMax = 16, max = 50, step = 1,
												disabled = function(info) return not DB.frames.enrage["removablesenableborder"] end,
												get = function(info) return (DB.frames.enrage[info[#info-1] ][3]) end,
												set = function(info, offset) DB.frames.enrage[info[#info-1] ][3] = (offset);LockDown(Serenity.SetupEnrageModule) end,
											},
											bottom = {
												type = "range", 
												order = 4,
												name = L2["Bottom"],
												min = -50, softMin = -16, softMax = 16, max = 50, step = 1,
												disabled = function(info) return not DB.frames.enrage["removablesenableborder"] end,
												get = function(info) return (DB.frames.enrage[info[#info-1] ][4]) end,
												set = function(info, offset) DB.frames.enrage[info[#info-1] ][4] = (offset);LockDown(Serenity.SetupEnrageModule) end,
											},										
										},
									},
								},
							},
							removablestexcoords = {
								type = "group",
								order = 30,
								name = L2["Removables Texture Coords"],
								guiInline = false,
								args = {						
									removablesenabletexcoords = {
										type = "toggle",
										order = 5,
										name = L2["Enable TexCoords"],
										desc = L2["DESCTEXCOORDS_ENABLE"],
										get = function(info) return DB.frames.enrage[info[#info] ] end,
										set = function(info, value) DB.frames.enrage[info[#info] ] = value;LockDown(Serenity.SetupEnrageModule) end,
									},
									removablestexcoords = {
										type = "group",
										order = 6,
										name = L2["Texture Coords"],
										guiInline = true,
										args = {
											left = {
												type = "range",
												order = 1,
												name = L2["Left"],
												min = 0, max = 1, step = .01,
												disabled = function(info) return not DB.frames.enrage["removablesenabletexcoords"] end,
												get = function(info) return (DB.frames.enrage[info[#info-1] ][1]) end,
												set = function(info, offset) DB.frames.enrage[info[#info-1] ][1] = (offset);LockDown(Serenity.SetupEnrageModule) end,
											},
											right = {
												type = "range", 
												order = 2,
												name = L2["Right"],
												min = 0, max = 1, step = .01,
												disabled = function(info) return not DB.frames.enrage["removablesenabletexcoords"] end,
												get = function(info) return (DB.frames.enrage[info[#info-1] ][2]) end,
												set = function(info, offset) DB.frames.enrage[info[#info-1] ][2] = (offset);LockDown(Serenity.SetupEnrageModule) end,
											},
											top = {
												type = "range", 
												order = 3,
												name = L2["Top"],
												min = 0, max = 1, step = .01,
												disabled = function(info) return not DB.frames.enrage["removablesenabletexcoords"] end,
												get = function(info) return (DB.frames.enrage[info[#info-1] ][3]) end,
												set = function(info, offset) DB.frames.enrage[info[#info-1] ][3] = (offset);LockDown(Serenity.SetupEnrageModule) end,
											},
											bottom = {
												type = "range", 
												order = 4,
												name = L2["Bottom"],
												min = 0, max = 1, step = .01,
												disabled = function(info) return not DB.frames.enrage["removablesenabletexcoords"] end,
												get = function(info) return (DB.frames.enrage[info[#info-1] ][4]) end,
												set = function(info, offset) DB.frames.enrage[info[#info-1] ][4] = (offset);LockDown(Serenity.SetupEnrageModule) end,
											},										
										},
									},
								},
							},
						},
					},
					crowdcontrol = {
						order = 8,
						type = "group",
						name = L2["Crowd Control"],
						guiInline = false,
						args = {
							intro = {
								order = 1,
								type = "description",
								name = L2["CC_DESC"].."\n",
							},
							size = {
								type = "group",
								order = 2,
								name = L2["Icon size"],
								guiInline = false,
								args = {
									iconsize = {
										type = "range", 
										order = 3,
										name = L2["Icon size"],
										min = 10, max = 100, step = 1,
										get = function(info) return (DB.frames.crowdcontrol[info[#info] ]) end,
										set = function(info, size) DB.frames.crowdcontrol[info[#info] ] = (size);LockDown(Serenity.SetupCrowdControlModule) end,
									},
								},
							},
							texcoords = {
								type = "group",
								order = 8,
								name = L2["Texture Coords"],
								guiInline = false,
								args = {						
									enabletexcoords = {
										type = "toggle",
										order = 5,
										name = L2["Enable TexCoords"],
										desc = L2["DESCTEXCOORDS_ENABLE"],
										get = function(info) return DB.frames.crowdcontrol[info[#info] ] end,
										set = function(info, value) DB.frames.crowdcontrol[info[#info] ] = value;LockDown(Serenity.SetupCrowdControlModule) end,
									},
									texcoords = {
										type = "group",
										order = 6,
										name = L2["Texture Coords"],
										guiInline = true,
										args = {
											left = {
												type = "range",
												order = 1,
												name = L2["Left"],
												min = 0, max = 1, step = .01,
												disabled = function(info) return not DB.frames.crowdcontrol["enabletexcoords"] end,
												get = function(info) return (DB.frames.crowdcontrol[info[#info-1] ][1]) end,
												set = function(info, offset) DB.frames.crowdcontrol[info[#info-1] ][1] = (offset);LockDown(Serenity.SetupCrowdControlModule) end,
											},
											right = {
												type = "range", 
												order = 2,
												name = L2["Right"],
												min = 0, max = 1, step = .01,
												disabled = function(info) return not DB.frames.crowdcontrol["enabletexcoords"] end,
												get = function(info) return (DB.frames.crowdcontrol[info[#info-1] ][2]) end,
												set = function(info, offset) DB.frames.crowdcontrol[info[#info-1] ][2] = (offset);LockDown(Serenity.SetupCrowdControlModule) end,
											},
											top = {
												type = "range", 
												order = 3,
												name = L2["Top"],
												min = 0, max = 1, step = .01,
												disabled = function(info) return not DB.frames.crowdcontrol["enabletexcoords"] end,
												get = function(info) return (DB.frames.crowdcontrol[info[#info-1] ][3]) end,
												set = function(info, offset) DB.frames.crowdcontrol[info[#info-1] ][3] = (offset);LockDown(Serenity.SetupCrowdControlModule) end,
											},
											bottom = {
												type = "range", 
												order = 4,
												name = L2["Bottom"],
												min = 0, max = 1, step = .01,
												disabled = function(info) return not DB.frames.crowdcontrol["enabletexcoords"] end,
												get = function(info) return (DB.frames.crowdcontrol[info[#info-1] ][4]) end,
												set = function(info, offset) DB.frames.crowdcontrol[info[#info-1] ][4] = (offset);LockDown(Serenity.SetupCrowdControlModule) end,
											},										
										},
									},
								},
							},
							backdrop = {
								type = "group",
								order = 3,
								name = L2["Icon Backdrop"],
								guiInline = false,
								args = {
									enablebackdrop = {
										type = "toggle",
										order = 1,
										name = L2["Enable"],
										desc = L2["DESCBACKDROP_ENABLE"],
										get = function(info) return DB.frames.crowdcontrol[info[#info] ] end,
										set = function(info, value) DB.frames.crowdcontrol[info[#info] ] = value;LockDown(Serenity.SetupCrowdControlModule) end,
									},
									backdroptexture = {
										type = "select",
										dialogControl = 'LSM30_Background',
										order = 2,
										name = L2["Backdrop texture"],
										desc = L2["Texture that gets used for the background."],
										values = AceGUIWidgetLSMlists.background,
										disabled = function(info) return not DB.frames.crowdcontrol["enablebackdrop"] end,
										get = function(info) return DB.frames.crowdcontrol[info[#info] ] end,
										set = function(info, value) DB.frames.crowdcontrol[info[#info] ] = value;LockDown(Serenity.SetupCrowdControlModule) end,
									},
									colorbackdrop = {
										type = "toggle",
										order = 3,
										name = L2["Color the backdrop"],
										desc = L2["DESCBACKDROPCOLOR_ENABLE"],
										disabled = function(info) return not DB.frames.crowdcontrol["enablebackdrop"] end,
										get = function(info) return DB.frames.crowdcontrol[info[#info] ] end,
										set = function(info, value) DB.frames.crowdcontrol[info[#info] ] = value;LockDown(Serenity.SetupCrowdControlModule) end,
									},
									backdropcolor = {
										type = "color",
										order = 4,
										name = L2["Backdrop color"],
										hasAlpha = true,
										disabled = function(info) return not DB.frames.crowdcontrol["enablebackdrop"] end,
										hidden = function(info) return not DB.frames.crowdcontrol.colorbackdrop end,
										get = function(info) return unpack(DB.frames.crowdcontrol[info[#info] ]) end,
										set = function(info, r, g, b, a) DB.frames.crowdcontrol[info[#info] ] = {r, g, b, a};LockDown(Serenity.SetupCrowdControlModule) end,
									},
									tile = {
										type = "toggle",
										order = 5,
										name = L2["Tile the backdrop"],
										desc = L2["DESCBACKDROPTILE_ENABLE"],
										disabled = function(info) return not DB.frames.crowdcontrol["enablebackdrop"] end,
										get = function(info) return DB.frames.crowdcontrol[info[#info] ] end,
										set = function(info, value) DB.frames.crowdcontrol[info[#info] ] = value;LockDown(Serenity.SetupCrowdControlModule) end,
									},
									tilesize = {
										type = "range",
										order = 6,
										name = L2["Tile Size"],
										desc = L2["DESCTILESIZE_ENABLE"],
										min = -100, softMin = -30, softMax = 30, max = 100, step = 1,
										disabled = function(info) return not DB.frames.crowdcontrol["enablebackdrop"] end,
										hidden = function(info) return not DB.frames.crowdcontrol.tile end,
										get = function(info) return DB.frames.crowdcontrol[info[#info] ] end,
										set = function(info, value) DB.frames.crowdcontrol[info[#info] ] = value;LockDown(Serenity.SetupCrowdControlModule) end,
									},
									spacer1 = { order = 7, type = "description", name = " ", desc = "", width = "full"},
									backdropoffsets = {
										type = "group",
										order = 8,
										name = L2["Offsets"],
										guiInline = true,
										args = {
											offsetX1 = {
												type = "range",
												order = 1,
												name = L2["Top-Left X"],
												desc = L2["This sets the 'X offset' value."],
												min = -50, softMin = -10, softMax = 0, max = 50, step = 1,
												disabled = function(info) return not DB.frames.crowdcontrol["enablebackdrop"] end,
												get = function(info) return (DB.frames.crowdcontrol[info[#info-1] ][1]) end,
												set = function(info, offset) DB.frames.crowdcontrol[info[#info-1] ][1] = (offset);LockDown(Serenity.SetupCrowdControlModule) end,
											},
											offsetY1 = {
												type = "range", 
												order = 2,
												name = L2["Top-Left Y"],
												desc = L2["This sets the 'Y offset' value."],
												min = -50, softMin = 0, softMax = 10, max = 50, step = 1,
												disabled = function(info) return not DB.frames.crowdcontrol["enablebackdrop"] end,
												get = function(info) return (DB.frames.crowdcontrol[info[#info-1] ][2]) end,
												set = function(info, offset) DB.frames.crowdcontrol[info[#info-1] ][2] = (offset);LockDown(Serenity.SetupCrowdControlModule) end,
											},
											offsetX2 = {
												type = "range", 
												order = 3,
												name = L2["Bottom-Right X"],
												desc = L2["This sets the 'X offset' value."],
												min = -50, softMin = 0, softMax = 10, max = 50, step = 1,
												disabled = function(info) return not DB.frames.crowdcontrol["enablebackdrop"] end,
												get = function(info) return (DB.frames.crowdcontrol[info[#info-1] ][3]) end,
												set = function(info, offset) DB.frames.crowdcontrol[info[#info-1] ][3] = (offset);LockDown(Serenity.SetupCrowdControlModule) end,
											},
											offsetY2 = {
												type = "range", 
												order = 4,
												name = L2["Bottom-Right Y"],
												desc = L2["This sets the 'Y offset' value."],
												min = -50, softMin = -10, softMax = 0, max = 50, step = 1,
												disabled = function(info) return not DB.frames.crowdcontrol["enablebackdrop"] end,
												get = function(info) return (DB.frames.crowdcontrol[info[#info-1] ][4]) end,
												set = function(info, offset) DB.frames.crowdcontrol[info[#info-1] ][4] = (offset);LockDown(Serenity.SetupCrowdControlModule) end,
											},										
										},
									},
									spacer2 = { order = 9, type = "description", name = " ", desc = "", width = "full"},
								},
							},
							border = {
								type = "group",
								order = 4,
								name = L2["Icon's Border"],
								guiInline = false,
								args = {
									enableborder = {
										type = "toggle",
										order = 1,
										name = L2["Enable"],
										desc = L2["DESCBORDER_ENABLE"],
										get = function(info) return DB.frames.crowdcontrol[info[#info] ] end,
										set = function(info, value) DB.frames.crowdcontrol[info[#info] ] = value;LockDown(Serenity.SetupCrowdControlModule) end,
									},
									bordertexture = {
										type = "select",
										dialogControl = 'LSM30_Border',
										order = 2,
										name = L2["Border texture"],
										desc = L2["Texture that gets used for the background."],
										values = AceGUIWidgetLSMlists.border,
										disabled = function(info) return not DB.frames.crowdcontrol["enableborder"] end,
										get = function(info) return DB.frames.crowdcontrol[info[#info] ] end,
										set = function(info, value) DB.frames.crowdcontrol[info[#info] ] = value;LockDown(Serenity.SetupCrowdControlModule) end,
									},
									bordercolor = {
										type = "color",
										order = 3,
										name = L2["Border color"],
										hasAlpha = true,
										disabled = function(info) return not DB.frames.crowdcontrol["enableborder"] end,
										get = function(info) return unpack(DB.frames.crowdcontrol[info[#info] ]) end,
										set = function(info, r, g, b, a) DB.frames.crowdcontrol[info[#info] ] = {r, g, b, a};LockDown(Serenity.SetupCrowdControlModule) end,
									},
									edgesize = {
										type = "range",
										order = 4,
										name = L2["Edge Size"],
										desc = L2["DESCEDGESIZE_ENABLE"],
										min = -100, softMin = -16, softMax = 16, max = 100, step = 1,
										disabled = function(info) return not DB.frames.crowdcontrol["enableborder"] end,
										get = function(info) return DB.frames.crowdcontrol[info[#info] ] end,
										set = function(info, value) DB.frames.crowdcontrol[info[#info] ] = value;LockDown(Serenity.SetupCrowdControlModule) end,
									},
									spacer1 = { order = 7, type = "description", name = " ", desc = "", width = "full"},
									backdropinsets = {
										type = "group",
										order = 10,
										name = L2["Insets"],
										guiInline = true,
										args = {
											left = {
												type = "range",
												order = 1,
												name = L2["Left"],
												min = -50, softMin = -16, softMax = 16, max = 50, step = 1,
												disabled = function(info) return not DB.frames.crowdcontrol["enableborder"] end,
												get = function(info) return (DB.frames.crowdcontrol[info[#info-1] ][1]) end,
												set = function(info, offset) DB.frames.crowdcontrol[info[#info-1] ][1] = (offset);LockDown(Serenity.SetupCrowdControlModule) end,
											},
											right = {
												type = "range", 
												order = 2,
												name = L2["Right"],
												min = -50, softMin = -16, softMax = 16, max = 50, step = 1,
												disabled = function(info) return not DB.frames.crowdcontrol["enableborder"] end,
												get = function(info) return (DB.frames.crowdcontrol[info[#info-1] ][2]) end,
												set = function(info, offset) DB.frames.crowdcontrol[info[#info-1] ][2] = (offset);LockDown(Serenity.SetupCrowdControlModule) end,
											},
											top = {
												type = "range", 
												order = 3,
												name = L2["Top"],
												min = -50, softMin = -16, softMax = 16, max = 50, step = 1,
												disabled = function(info) return not DB.frames.crowdcontrol["enableborder"] end,
												get = function(info) return (DB.frames.crowdcontrol[info[#info-1] ][3]) end,
												set = function(info, offset) DB.frames.crowdcontrol[info[#info-1] ][3] = (offset);LockDown(Serenity.SetupCrowdControlModule) end,
											},
											bottom = {
												type = "range", 
												order = 4,
												name = L2["Bottom"],
												min = -50, softMin = -16, softMax = 16, max = 50, step = 1,
												disabled = function(info) return not DB.frames.crowdcontrol["enableborder"] end,
												get = function(info) return (DB.frames.crowdcontrol[info[#info-1] ][4]) end,
												set = function(info, offset) DB.frames.crowdcontrol[info[#info-1] ][4] = (offset);LockDown(Serenity.SetupCrowdControlModule) end,
											},										
										},
									},
								},
							},
						},
					},
					indicators = {
						order = 10,
						type = "group",
						name = L2["Indicators"],
						guiInline = false,
						args = {
							intro = {
								order = 1,
								type = "description",
								name = L2["INDICATORS_DESC"].."\n",
							},
							huntersmark_size = {
								type = "group",
								order = 2,
								name = L2["Hunter's Mark size"],
								guiInline = false,
								args = {
									huntersmark_iconsize = {
										type = "range", 
										order = 3,
										name = L2["Icon size"],
										min = 10, max = 100, step = 1,
										hidden = function(info) return (Serenity.V["playerclass"] ~= "HUNTER") end,
										get = function(info) return (DB.frames.indicators[info[#info] ]) end,
										set = function(info, size) DB.frames.indicators[info[#info] ] = (size);LockDown(Serenity.SetupIndicatorsModule) end,
									},
								},
							},
							huntersmark_texcoords = {
								type = "group",
								order = 8,
								name = L2["Hunter's Mark Texture Coords"],
								guiInline = false,
								hidden = function(info) return (Serenity.V["playerclass"] ~= "HUNTER") end,
								args = {						
									huntersmark_enabletexcoords = {
										type = "toggle",
										order = 5,
										name = L2["Enable TexCoords"],
										desc = L2["DESCTEXCOORDS_ENABLE"],
										get = function(info) return DB.frames.indicators[info[#info] ] end,
										set = function(info, value) DB.frames.indicators[info[#info] ] = value;LockDown(Serenity.SetupIndicatorsModule) end,
									},
									huntersmark_texcoords = {
										type = "group",
										order = 6,
										name = L2["Texture Coords"],
										guiInline = true,
										args = {
											left = {
												type = "range",
												order = 1,
												name = L2["Left"],
												min = 0, max = 1, step = .01,
												disabled = function(info) return not DB.frames.indicators.huntersmark_enabletexcoords end,
												get = function(info) return (DB.frames.indicators[info[#info-1] ][1]) end,
												set = function(info, offset) DB.frames.indicators[info[#info-1] ][1] = (offset);LockDown(Serenity.SetupIndicatorsModule) end,
											},
											right = {
												type = "range", 
												order = 2,
												name = L2["Right"],
												min = 0, max = 1, step = .01,
												disabled = function(info) return not DB.frames.indicators.huntersmark_enabletexcoords end,
												get = function(info) return (DB.frames.indicators[info[#info-1] ][2]) end,
												set = function(info, offset) DB.frames.indicators[info[#info-1] ][2] = (offset);LockDown(Serenity.SetupIndicatorsModule) end,
											},
											top = {
												type = "range", 
												order = 3,
												name = L2["Top"],
												min = 0, max = 1, step = .01,
												disabled = function(info) return not DB.frames.indicators.huntersmark_enabletexcoords end,
												get = function(info) return (DB.frames.indicators[info[#info-1] ][3]) end,
												set = function(info, offset) DB.frames.indicators[info[#info-1] ][3] = (offset);LockDown(Serenity.SetupIndicatorsModule) end,
											},
											bottom = {
												type = "range", 
												order = 4,
												name = L2["Bottom"],
												min = 0, max = 1, step = .01,
												disabled = function(info) return not DB.frames.indicators.huntersmark_enabletexcoords end,
												get = function(info) return (DB.frames.indicators[info[#info-1] ][4]) end,
												set = function(info, offset) DB.frames.indicators[info[#info-1] ][4] = (offset);LockDown(Serenity.SetupIndicatorsModule) end,
											},										
										},
									},
								},
							},
							huntersmark_backdrop = {
								type = "group",
								order = 10,
								name = L2["Hunter's Mark Backdrop"],
								guiInline = false,
								hidden = function(info) return (Serenity.V["playerclass"] ~= "HUNTER") end,
								args = {
									huntersmark_enablebackdrop = {
										type = "toggle",
										order = 1,
										name = L2["Enable"],
										desc = L2["DESCBACKDROP_ENABLE"],
										get = function(info) return DB.frames.indicators[info[#info] ] end,
										set = function(info, value) DB.frames.indicators[info[#info] ] = value;LockDown(Serenity.SetupIndicatorsModule) end,
									},
									huntersmark_backdroptexture = {
										type = "select",
										dialogControl = 'LSM30_Background',
										order = 2,
										name = L2["Backdrop texture"],
										desc = L2["Texture that gets used for the background."],
										values = AceGUIWidgetLSMlists.background,
										disabled = function(info) return not DB.frames.indicators["huntersmark_enablebackdrop"] end,
										get = function(info) return DB.frames.indicators[info[#info] ] end,
										set = function(info, value) DB.frames.indicators[info[#info] ] = value;LockDown(Serenity.SetupIndicatorsModule) end,
									},
									huntersmark_colorbackdrop = {
										type = "toggle",
										order = 3,
										name = L2["Color the backdrop"],
										desc = L2["DESCBACKDROPCOLOR_ENABLE"],
										disabled = function(info) return not DB.frames.indicators["huntersmark_enablebackdrop"] end,
										get = function(info) return DB.frames.indicators[info[#info] ] end,
										set = function(info, value) DB.frames.indicators[info[#info] ] = value;LockDown(Serenity.SetupIndicatorsModule) end,
									},
									huntersmark_backdropcolor = {
										type = "color",
										order = 4,
										name = L2["Backdrop color"],
										hasAlpha = true,
										disabled = function(info) return not DB.frames.indicators["huntersmark_enablebackdrop"] end,
										hidden = function(info) return not DB.frames.indicators.huntersmark_colorbackdrop end,
										get = function(info) return unpack(DB.frames.indicators[info[#info] ]) end,
										set = function(info, r, g, b, a) DB.frames.indicators[info[#info] ] = {r, g, b, a};LockDown(Serenity.SetupIndicatorsModule) end,
									},
									huntersmark_tile = {
										type = "toggle",
										order = 5,
										name = L2["Tile the backdrop"],
										desc = L2["DESCBACKDROPTILE_ENABLE"],
										disabled = function(info) return not DB.frames.indicators["huntersmark_enablebackdrop"] end,
										get = function(info) return DB.frames.indicators[info[#info] ] end,
										set = function(info, value) DB.frames.indicators[info[#info] ] = value;LockDown(Serenity.SetupIndicatorsModule) end,
									},
									huntersmark_tilesize = {
										type = "range",
										order = 6,
										name = L2["Tile Size"],
										desc = L2["DESCTILESIZE_ENABLE"],
										min = -100, softMin = -30, softMax = 30, max = 100, step = 1,
										disabled = function(info) return not DB.frames.indicators["huntersmark_enablebackdrop"] end,
										hidden = function(info) return not DB.frames.indicators.huntersmark_tile end,
										get = function(info) return DB.frames.indicators[info[#info] ] end,
										set = function(info, value) DB.frames.indicators[info[#info] ] = value;LockDown(Serenity.SetupIndicatorsModule) end,
									},
									spacer1 = { order = 7, type = "description", name = " ", desc = "", width = "full"},
									huntersmark_backdropoffsets = {
										type = "group",
										order = 8,
										name = L2["Offsets"],
										guiInline = true,
										args = {
											offsetX1 = {
												type = "range",
												order = 1,
												name = L2["Top-Left X"],
												desc = L2["This sets the 'X offset' value."],
												min = -50, softMin = -10, softMax = 0, max = 50, step = 1,
												disabled = function(info) return not DB.frames.indicators["huntersmark_enablebackdrop"] end,
												get = function(info) return (DB.frames.indicators[info[#info-1] ][1]) end,
												set = function(info, offset) DB.frames.indicators[info[#info-1] ][1] = (offset);LockDown(Serenity.SetupIndicatorsModule) end,
											},
											offsetY1 = {
												type = "range", 
												order = 2,
												name = L2["Top-Left Y"],
												desc = L2["This sets the 'Y offset' value."],
												min = -50, softMin = 0, softMax = 10, max = 50, step = 1,
												disabled = function(info) return not DB.frames.indicators["huntersmark_enablebackdrop"] end,
												get = function(info) return (DB.frames.indicators[info[#info-1] ][2]) end,
												set = function(info, offset) DB.frames.indicators[info[#info-1] ][2] = (offset);LockDown(Serenity.SetupIndicatorsModule) end,
											},
											offsetX2 = {
												type = "range", 
												order = 3,
												name = L2["Bottom-Right X"],
												desc = L2["This sets the 'X offset' value."],
												min = -50, softMin = 0, softMax = 10, max = 50, step = 1,
												disabled = function(info) return not DB.frames.indicators["huntersmark_enablebackdrop"] end,
												get = function(info) return (DB.frames.indicators[info[#info-1] ][3]) end,
												set = function(info, offset) DB.frames.indicators[info[#info-1] ][3] = (offset);LockDown(Serenity.SetupIndicatorsModule) end,
											},
											offsetY2 = {
												type = "range", 
												order = 4,
												name = L2["Bottom-Right Y"],
												desc = L2["This sets the 'Y offset' value."],
												min = -50, softMin = -10, softMax = 0, max = 50, step = 1,
												disabled = function(info) return not DB.frames.indicators["huntersmark_enablebackdrop"] end,
												get = function(info) return (DB.frames.indicators[info[#info-1] ][4]) end,
												set = function(info, offset) DB.frames.indicators[info[#info-1] ][4] = (offset);LockDown(Serenity.SetupIndicatorsModule) end,
											},										
										},
									},
								},
							},
							huntersmark_border = {
								type = "group",
								order = 12,
								name = L2["Hunter's Mark Border"],
								guiInline = false,
								hidden = function(info) return (Serenity.V["playerclass"] ~= "HUNTER") end,
								args = {
									huntersmark_enableborder = {
										type = "toggle",
										order = 1,
										name = L2["Enable"],
										desc = L2["DESCBORDER_ENABLE"],
										get = function(info) return DB.frames.indicators[info[#info] ] end,
										set = function(info, value) DB.frames.indicators[info[#info] ] = value;LockDown(Serenity.SetupIndicatorsModule) end,
									},
									huntersmark_bordertexture = {
										type = "select",
										dialogControl = 'LSM30_Border',
										order = 2,
										name = L2["Border texture"],
										desc = L2["Texture that gets used for the background."],
										values = AceGUIWidgetLSMlists.border,
										disabled = function(info) return not DB.frames.indicators["huntersmark_enableborder"] end,
										get = function(info) return DB.frames.indicators[info[#info] ] end,
										set = function(info, value) DB.frames.indicators[info[#info] ] = value;LockDown(Serenity.SetupIndicatorsModule) end,
									},
									huntersmark_bordercolor = {
										type = "color",
										order = 3,
										name = L2["Border color"],
										hasAlpha = true,
										disabled = function(info) return not DB.frames.indicators["huntersmark_enableborder"] end,
										get = function(info) return unpack(DB.frames.indicators[info[#info] ]) end,
										set = function(info, r, g, b, a) DB.frames.indicators[info[#info] ] = {r, g, b, a};LockDown(Serenity.SetupIndicatorsModule) end,
									},
									huntersmark_edgesize = {
										type = "range",
										order = 4,
										name = L2["Edge Size"],
										desc = L2["DESCEDGESIZE_ENABLE"],
										min = -100, softMin = -16, softMax = 16, max = 100, step = 1,
										disabled = function(info) return not DB.frames.indicators["huntersmark_enableborder"] end,
										get = function(info) return DB.frames.indicators[info[#info] ] end,
										set = function(info, value) DB.frames.indicators[info[#info] ] = value;LockDown(Serenity.SetupIndicatorsModule) end,
									},
									spacer1 = { order = 7, type = "description", name = " ", desc = "", width = "full"},
									huntersmark_backdropinsets = {
										type = "group",
										order = 10,
										name = L2["Insets"],
										guiInline = true,
										args = {
											left = {
												type = "range",
												order = 1,
												name = L2["Left"],
												min = -50, softMin = -16, softMax = 16, max = 50, step = 1,
												disabled = function(info) return not DB.frames.indicators["huntersmark_enableborder"] end,
												get = function(info) return (DB.frames.indicators[info[#info-1] ][1]) end,
												set = function(info, offset) DB.frames.indicators[info[#info-1] ][1] = (offset);LockDown(Serenity.SetupIndicatorsModule) end,
											},
											right = {
												type = "range", 
												order = 2,
												name = L2["Right"],
												min = -50, softMin = -16, softMax = 16, max = 50, step = 1,
												disabled = function(info) return not DB.frames.indicators["huntersmark_enableborder"] end,
												get = function(info) return (DB.frames.indicators[info[#info-1] ][2]) end,
												set = function(info, offset) DB.frames.indicators[info[#info-1] ][2] = (offset);LockDown(Serenity.SetupIndicatorsModule) end,
											},
											top = {
												type = "range", 
												order = 3,
												name = L2["Top"],
												min = -50, softMin = -16, softMax = 16, max = 50, step = 1,
												disabled = function(info) return not DB.frames.indicators["huntersmark_enableborder"] end,
												get = function(info) return (DB.frames.indicators[info[#info-1] ][3]) end,
												set = function(info, offset) DB.frames.indicators[info[#info-1] ][3] = (offset);LockDown(Serenity.SetupIndicatorsModule) end,
											},
											bottom = {
												type = "range", 
												order = 4,
												name = L2["Bottom"],
												min = -50, softMin = -16, softMax = 16, max = 50, step = 1,
												disabled = function(info) return not DB.frames.indicators["huntersmark_enableborder"] end,
												get = function(info) return (DB.frames.indicators[info[#info-1] ][4]) end,
												set = function(info, offset) DB.frames.indicators[info[#info-1] ][4] = (offset);LockDown(Serenity.SetupIndicatorsModule) end,
											},										
										},
									},
								},
							},
							aspect_size = {
								type = "group",
								order = 14,
								name = L2["Aspect size"],
								guiInline = false,
								args = {
									aspect_iconsize = {
										type = "range", 
										order = 3,
										name = L2["Icon size"],
										min = 10, max = 100, step = 1,
										hidden = function(info) return (Serenity.V["playerclass"] ~= "HUNTER") end,
										get = function(info) return (DB.frames.indicators[info[#info] ]) end,
										set = function(info, size) DB.frames.indicators[info[#info] ] = (size);LockDown(Serenity.SetupIndicatorsModule) end,
									},
								},
							},
							aspect_texcoords = {
								type = "group",
								order = 16,
								name = L2["Aspect Texture Coords"],
								guiInline = false,
								hidden = function(info) return (Serenity.V["playerclass"] ~= "HUNTER") end,
								args = {						
									aspect_enabletexcoords = {
										type = "toggle",
										order = 5,
										name = L2["Enable TexCoords"],
										desc = L2["DESCTEXCOORDS_ENABLE"],
										get = function(info) return DB.frames.indicators[info[#info] ] end,
										set = function(info, value) DB.frames.indicators[info[#info] ] = value;LockDown(Serenity.SetupIndicatorsModule) end,
									},
									aspect_texcoords = {
										type = "group",
										order = 6,
										name = L2["Texture Coords"],
										guiInline = true,
										args = {
											left = {
												type = "range",
												order = 1,
												name = L2["Left"],
												min = 0, max = 1, step = .01,
												disabled = function(info) return not DB.frames.indicators.aspect_enabletexcoords end,
												get = function(info) return (DB.frames.indicators[info[#info-1] ][1]) end,
												set = function(info, offset) DB.frames.indicators[info[#info-1] ][1] = (offset);LockDown(Serenity.SetupIndicatorsModule) end,
											},
											right = {
												type = "range", 
												order = 2,
												name = L2["Right"],
												min = 0, max = 1, step = .01,
												disabled = function(info) return not DB.frames.indicators.aspect_enabletexcoords end,
												get = function(info) return (DB.frames.indicators[info[#info-1] ][2]) end,
												set = function(info, offset) DB.frames.indicators[info[#info-1] ][2] = (offset);LockDown(Serenity.SetupIndicatorsModule) end,
											},
											top = {
												type = "range", 
												order = 3,
												name = L2["Top"],
												min = 0, max = 1, step = .01,
												disabled = function(info) return not DB.frames.indicators.aspect_enabletexcoords end,
												get = function(info) return (DB.frames.indicators[info[#info-1] ][3]) end,
												set = function(info, offset) DB.frames.indicators[info[#info-1] ][3] = (offset);LockDown(Serenity.SetupIndicatorsModule) end,
											},
											bottom = {
												type = "range", 
												order = 4,
												name = L2["Bottom"],
												min = 0, max = 1, step = .01,
												disabled = function(info) return not DB.frames.indicators.aspect_enabletexcoords end,
												get = function(info) return (DB.frames.indicators[info[#info-1] ][4]) end,
												set = function(info, offset) DB.frames.indicators[info[#info-1] ][4] = (offset);LockDown(Serenity.SetupIndicatorsModule) end,
											},										
										},
									},
								},
							},
							aspect_backdrop = {
								type = "group",
								order = 18,
								name = L2["Aspect Backdrop"],
								guiInline = false,
								hidden = function(info) return (Serenity.V["playerclass"] ~= "HUNTER") end,
								args = {
									aspect_enablebackdrop = {
										type = "toggle",
										order = 1,
										name = L2["Enable"],
										desc = L2["DESCBACKDROP_ENABLE"],
										get = function(info) return DB.frames.indicators[info[#info] ] end,
										set = function(info, value) DB.frames.indicators[info[#info] ] = value;LockDown(Serenity.SetupIndicatorsModule) end,
									},
									aspect_backdroptexture = {
										type = "select",
										dialogControl = 'LSM30_Background',
										order = 2,
										name = L2["Backdrop texture"],
										desc = L2["Texture that gets used for the background."],
										values = AceGUIWidgetLSMlists.background,
										disabled = function(info) return not DB.frames.indicators["aspect_enablebackdrop"] end,
										get = function(info) return DB.frames.indicators[info[#info] ] end,
										set = function(info, value) DB.frames.indicators[info[#info] ] = value;LockDown(Serenity.SetupIndicatorsModule) end,
									},
									aspect_colorbackdrop = {
										type = "toggle",
										order = 3,
										name = L2["Color the backdrop"],
										desc = L2["DESCBACKDROPCOLOR_ENABLE"],
										disabled = function(info) return not DB.frames.indicators["aspect_enablebackdrop"] end,
										get = function(info) return DB.frames.indicators[info[#info] ] end,
										set = function(info, value) DB.frames.indicators[info[#info] ] = value;LockDown(Serenity.SetupIndicatorsModule) end,
									},
									aspect_backdropcolor = {
										type = "color",
										order = 4,
										name = L2["Backdrop color"],
										hasAlpha = true,
										disabled = function(info) return not DB.frames.indicators["aspect_enablebackdrop"] end,
										hidden = function(info) return not DB.frames.indicators.aspect_colorbackdrop end,
										get = function(info) return unpack(DB.frames.indicators[info[#info] ]) end,
										set = function(info, r, g, b, a) DB.frames.indicators[info[#info] ] = {r, g, b, a};LockDown(Serenity.SetupIndicatorsModule) end,
									},
									aspect_tile = {
										type = "toggle",
										order = 5,
										name = L2["Tile the backdrop"],
										desc = L2["DESCBACKDROPTILE_ENABLE"],
										disabled = function(info) return not DB.frames.indicators["aspect_enablebackdrop"] end,
										get = function(info) return DB.frames.indicators[info[#info] ] end,
										set = function(info, value) DB.frames.indicators[info[#info] ] = value;LockDown(Serenity.SetupIndicatorsModule) end,
									},
									aspect_tilesize = {
										type = "range",
										order = 6,
										name = L2["Tile Size"],
										desc = L2["DESCTILESIZE_ENABLE"],
										min = -100, softMin = -30, softMax = 30, max = 100, step = 1,
										disabled = function(info) return not DB.frames.indicators["aspect_enablebackdrop"] end,
										hidden = function(info) return not DB.frames.indicators.aspect_tile end,
										get = function(info) return DB.frames.indicators[info[#info] ] end,
										set = function(info, value) DB.frames.indicators[info[#info] ] = value;LockDown(Serenity.SetupIndicatorsModule) end,
									},
									spacer1 = { order = 7, type = "description", name = " ", desc = "", width = "full"},
									aspect_backdropoffsets = {
										type = "group",
										order = 8,
										name = L2["Offsets"],
										guiInline = true,
										args = {
											offsetX1 = {
												type = "range",
												order = 1,
												name = L2["Top-Left X"],
												desc = L2["This sets the 'X offset' value."],
												min = -50, softMin = -10, softMax = 0, max = 50, step = 1,
												disabled = function(info) return not DB.frames.indicators["aspect_enablebackdrop"] end,
												get = function(info) return (DB.frames.indicators[info[#info-1] ][1]) end,
												set = function(info, offset) DB.frames.indicators[info[#info-1] ][1] = (offset);LockDown(Serenity.SetupIndicatorsModule) end,
											},
											offsetY1 = {
												type = "range", 
												order = 2,
												name = L2["Top-Left Y"],
												desc = L2["This sets the 'Y offset' value."],
												min = -50, softMin = 0, softMax = 10, max = 50, step = 1,
												disabled = function(info) return not DB.frames.indicators["aspect_enablebackdrop"] end,
												get = function(info) return (DB.frames.indicators[info[#info-1] ][2]) end,
												set = function(info, offset) DB.frames.indicators[info[#info-1] ][2] = (offset);LockDown(Serenity.SetupIndicatorsModule) end,
											},
											offsetX2 = {
												type = "range", 
												order = 3,
												name = L2["Bottom-Right X"],
												desc = L2["This sets the 'X offset' value."],
												min = -50, softMin = 0, softMax = 10, max = 50, step = 1,
												disabled = function(info) return not DB.frames.indicators["aspect_enablebackdrop"] end,
												get = function(info) return (DB.frames.indicators[info[#info-1] ][3]) end,
												set = function(info, offset) DB.frames.indicators[info[#info-1] ][3] = (offset);LockDown(Serenity.SetupIndicatorsModule) end,
											},
											offsetY2 = {
												type = "range", 
												order = 4,
												name = L2["Bottom-Right Y"],
												desc = L2["This sets the 'Y offset' value."],
												min = -50, softMin = -10, softMax = 0, max = 50, step = 1,
												disabled = function(info) return not DB.frames.indicators["aspect_enablebackdrop"] end,
												get = function(info) return (DB.frames.indicators[info[#info-1] ][4]) end,
												set = function(info, offset) DB.frames.indicators[info[#info-1] ][4] = (offset);LockDown(Serenity.SetupIndicatorsModule) end,
											},										
										},
									},
								},
							},
							aspect_border = {
								type = "group",
								order = 20,
								name = L2["Aspect Border"],
								guiInline = false,
								hidden = function(info) return (Serenity.V["playerclass"] ~= "HUNTER") end,
								args = {
									aspect_enableborder = {
										type = "toggle",
										order = 1,
										name = L2["Enable"],
										desc = L2["DESCBORDER_ENABLE"],
										get = function(info) return DB.frames.indicators[info[#info] ] end,
										set = function(info, value) DB.frames.indicators[info[#info] ] = value;LockDown(Serenity.SetupIndicatorsModule) end,
									},
									aspect_bordertexture = {
										type = "select",
										dialogControl = 'LSM30_Border',
										order = 2,
										name = L2["Border texture"],
										desc = L2["Texture that gets used for the background."],
										values = AceGUIWidgetLSMlists.border,
										disabled = function(info) return not DB.frames.indicators["aspect_enableborder"] end,
										get = function(info) return DB.frames.indicators[info[#info] ] end,
										set = function(info, value) DB.frames.indicators[info[#info] ] = value;LockDown(Serenity.SetupIndicatorsModule) end,
									},
									aspect_bordercolor = {
										type = "color",
										order = 3,
										name = L2["Border color"],
										hasAlpha = true,
										disabled = function(info) return not DB.frames.indicators["aspect_enableborder"] end,
										get = function(info) return unpack(DB.frames.indicators[info[#info] ]) end,
										set = function(info, r, g, b, a) DB.frames.indicators[info[#info] ] = {r, g, b, a};LockDown(Serenity.SetupIndicatorsModule) end,
									},
									aspect_edgesize = {
										type = "range",
										order = 4,
										name = L2["Edge Size"],
										desc = L2["DESCEDGESIZE_ENABLE"],
										min = -100, softMin = -16, softMax = 16, max = 100, step = 1,
										disabled = function(info) return not DB.frames.indicators["aspect_enableborder"] end,
										get = function(info) return DB.frames.indicators[info[#info] ] end,
										set = function(info, value) DB.frames.indicators[info[#info] ] = value;LockDown(Serenity.SetupIndicatorsModule) end,
									},
									spacer1 = { order = 7, type = "description", name = " ", desc = "", width = "full"},
									aspect_backdropinsets = {
										type = "group",
										order = 10,
										name = L2["Insets"],
										guiInline = true,
										args = {
											left = {
												type = "range",
												order = 1,
												name = L2["Left"],
												min = -50, softMin = -16, softMax = 16, max = 50, step = 1,
												disabled = function(info) return not DB.frames.indicators["aspect_enableborder"] end,
												get = function(info) return (DB.frames.indicators[info[#info-1] ][1]) end,
												set = function(info, offset) DB.frames.indicators[info[#info-1] ][1] = (offset);LockDown(Serenity.SetupIndicatorsModule) end,
											},
											right = {
												type = "range", 
												order = 2,
												name = L2["Right"],
												min = -50, softMin = -16, softMax = 16, max = 50, step = 1,
												disabled = function(info) return not DB.frames.indicators["aspect_enableborder"] end,
												get = function(info) return (DB.frames.indicators[info[#info-1] ][2]) end,
												set = function(info, offset) DB.frames.indicators[info[#info-1] ][2] = (offset);LockDown(Serenity.SetupIndicatorsModule) end,
											},
											top = {
												type = "range", 
												order = 3,
												name = L2["Top"],
												min = -50, softMin = -16, softMax = 16, max = 50, step = 1,
												disabled = function(info) return not DB.frames.indicators["aspect_enableborder"] end,
												get = function(info) return (DB.frames.indicators[info[#info-1] ][3]) end,
												set = function(info, offset) DB.frames.indicators[info[#info-1] ][3] = (offset);LockDown(Serenity.SetupIndicatorsModule) end,
											},
											bottom = {
												type = "range", 
												order = 4,
												name = L2["Bottom"],
												min = -50, softMin = -16, softMax = 16, max = 50, step = 1,
												disabled = function(info) return not DB.frames.indicators["aspect_enableborder"] end,
												get = function(info) return (DB.frames.indicators[info[#info-1] ][4]) end,
												set = function(info, offset) DB.frames.indicators[info[#info-1] ][4] = (offset);LockDown(Serenity.SetupIndicatorsModule) end,
											},										
										},
									},
								},
							},
							scarebeast_size = {
								type = "group",
								order = 22,
								name = L2["Scare Beast size"],
								guiInline = false,
								args = {
									scarebeast_iconsize = {
										type = "range", 
										order = 3,
										name = L2["Icon size"],
										min = 10, max = 100, step = 1,
										hidden = function(info) return (Serenity.V["playerclass"] ~= "HUNTER") end,
										get = function(info) return (DB.frames.indicators[info[#info] ]) end,
										set = function(info, size) DB.frames.indicators[info[#info] ] = (size);LockDown(Serenity.SetupIndicatorsModule) end,
									},
								},
							},
							scarebeast_texcoords = {
								type = "group",
								order = 24,
								name = L2["Scare Beast Texture Coords"],
								guiInline = false,
								hidden = function(info) return (Serenity.V["playerclass"] ~= "HUNTER") end,
								args = {						
									scarebeast_enabletexcoords = {
										type = "toggle",
										order = 5,
										name = L2["Enable TexCoords"],
										desc = L2["DESCTEXCOORDS_ENABLE"],
										get = function(info) return DB.frames.indicators[info[#info] ] end,
										set = function(info, value) DB.frames.indicators[info[#info] ] = value;LockDown(Serenity.SetupIndicatorsModule) end,
									},
									scarebeast_texcoords = {
										type = "group",
										order = 6,
										name = L2["Texture Coords"],
										guiInline = true,
										args = {
											left = {
												type = "range",
												order = 1,
												name = L2["Left"],
												min = 0, max = 1, step = .01,
												disabled = function(info) return not DB.frames.indicators.scarebeast_enabletexcoords end,
												get = function(info) return (DB.frames.indicators[info[#info-1] ][1]) end,
												set = function(info, offset) DB.frames.indicators[info[#info-1] ][1] = (offset);LockDown(Serenity.SetupIndicatorsModule) end,
											},
											right = {
												type = "range", 
												order = 2,
												name = L2["Right"],
												min = 0, max = 1, step = .01,
												disabled = function(info) return not DB.frames.indicators.scarebeast_enabletexcoords end,
												get = function(info) return (DB.frames.indicators[info[#info-1] ][2]) end,
												set = function(info, offset) DB.frames.indicators[info[#info-1] ][2] = (offset);LockDown(Serenity.SetupIndicatorsModule) end,
											},
											top = {
												type = "range", 
												order = 3,
												name = L2["Top"],
												min = 0, max = 1, step = .01,
												disabled = function(info) return not DB.frames.indicators.scarebeast_enabletexcoords end,
												get = function(info) return (DB.frames.indicators[info[#info-1] ][3]) end,
												set = function(info, offset) DB.frames.indicators[info[#info-1] ][3] = (offset);LockDown(Serenity.SetupIndicatorsModule) end,
											},
											bottom = {
												type = "range", 
												order = 4,
												name = L2["Bottom"],
												min = 0, max = 1, step = .01,
												disabled = function(info) return not DB.frames.indicators.scarebeast_enabletexcoords end,
												get = function(info) return (DB.frames.indicators[info[#info-1] ][4]) end,
												set = function(info, offset) DB.frames.indicators[info[#info-1] ][4] = (offset);LockDown(Serenity.SetupIndicatorsModule) end,
											},										
										},
									},
								},
							},
							scarebeast_backdrop = {
								type = "group",
								order = 26,
								name = L2["Scare Beast Backdrop"],
								guiInline = false,
								hidden = function(info) return (Serenity.V["playerclass"] ~= "HUNTER") end,
								args = {
									scarebeast_enablebackdrop = {
										type = "toggle",
										order = 1,
										name = L2["Enable"],
										desc = L2["DESCBACKDROP_ENABLE"],
										get = function(info) return DB.frames.indicators[info[#info] ] end,
										set = function(info, value) DB.frames.indicators[info[#info] ] = value;LockDown(Serenity.SetupIndicatorsModule) end,
									},
									scarebeast_backdroptexture = {
										type = "select",
										dialogControl = 'LSM30_Background',
										order = 2,
										name = L2["Backdrop texture"],
										desc = L2["Texture that gets used for the background."],
										values = AceGUIWidgetLSMlists.background,
										disabled = function(info) return not DB.frames.indicators["scarebeast_enablebackdrop"] end,
										get = function(info) return DB.frames.indicators[info[#info] ] end,
										set = function(info, value) DB.frames.indicators[info[#info] ] = value;LockDown(Serenity.SetupIndicatorsModule) end,
									},
									scarebeast_colorbackdrop = {
										type = "toggle",
										order = 3,
										name = L2["Color the backdrop"],
										desc = L2["DESCBACKDROPCOLOR_ENABLE"],
										disabled = function(info) return not DB.frames.indicators["scarebeast_enablebackdrop"] end,
										get = function(info) return DB.frames.indicators[info[#info] ] end,
										set = function(info, value) DB.frames.indicators[info[#info] ] = value;LockDown(Serenity.SetupIndicatorsModule) end,
									},
									scarebeast_backdropcolor = {
										type = "color",
										order = 4,
										name = L2["Backdrop color"],
										hasAlpha = true,
										disabled = function(info) return not DB.frames.indicators["scarebeast_enablebackdrop"] end,
										hidden = function(info) return not DB.frames.indicators.scarebeast_colorbackdrop end,
										get = function(info) return unpack(DB.frames.indicators[info[#info] ]) end,
										set = function(info, r, g, b, a) DB.frames.indicators[info[#info] ] = {r, g, b, a};LockDown(Serenity.SetupIndicatorsModule) end,
									},
									scarebeast_tile = {
										type = "toggle",
										order = 5,
										name = L2["Tile the backdrop"],
										desc = L2["DESCBACKDROPTILE_ENABLE"],
										disabled = function(info) return not DB.frames.indicators["scarebeast_enablebackdrop"] end,
										get = function(info) return DB.frames.indicators[info[#info] ] end,
										set = function(info, value) DB.frames.indicators[info[#info] ] = value;LockDown(Serenity.SetupIndicatorsModule) end,
									},
									scarebeast_tilesize = {
										type = "range",
										order = 6,
										name = L2["Tile Size"],
										desc = L2["DESCTILESIZE_ENABLE"],
										min = -100, softMin = -30, softMax = 30, max = 100, step = 1,
										disabled = function(info) return not DB.frames.indicators["scarebeast_enablebackdrop"] end,
										hidden = function(info) return not DB.frames.indicators.scarebeast_tile end,
										get = function(info) return DB.frames.indicators[info[#info] ] end,
										set = function(info, value) DB.frames.indicators[info[#info] ] = value;LockDown(Serenity.SetupIndicatorsModule) end,
									},
									spacer1 = { order = 7, type = "description", name = " ", desc = "", width = "full"},
									scarebeast_backdropoffsets = {
										type = "group",
										order = 8,
										name = L2["Offsets"],
										guiInline = true,
										args = {
											offsetX1 = {
												type = "range",
												order = 1,
												name = L2["Top-Left X"],
												desc = L2["This sets the 'X offset' value."],
												min = -50, softMin = -10, softMax = 0, max = 50, step = 1,
												disabled = function(info) return not DB.frames.indicators["scarebeast_enablebackdrop"] end,
												get = function(info) return (DB.frames.indicators[info[#info-1] ][1]) end,
												set = function(info, offset) DB.frames.indicators[info[#info-1] ][1] = (offset);LockDown(Serenity.SetupIndicatorsModule) end,
											},
											offsetY1 = {
												type = "range", 
												order = 2,
												name = L2["Top-Left Y"],
												desc = L2["This sets the 'Y offset' value."],
												min = -50, softMin = 0, softMax = 10, max = 50, step = 1,
												disabled = function(info) return not DB.frames.indicators["scarebeast_enablebackdrop"] end,
												get = function(info) return (DB.frames.indicators[info[#info-1] ][2]) end,
												set = function(info, offset) DB.frames.indicators[info[#info-1] ][2] = (offset);LockDown(Serenity.SetupIndicatorsModule) end,
											},
											offsetX2 = {
												type = "range", 
												order = 3,
												name = L2["Bottom-Right X"],
												desc = L2["This sets the 'X offset' value."],
												min = -50, softMin = 0, softMax = 10, max = 50, step = 1,
												disabled = function(info) return not DB.frames.indicators["scarebeast_enablebackdrop"] end,
												get = function(info) return (DB.frames.indicators[info[#info-1] ][3]) end,
												set = function(info, offset) DB.frames.indicators[info[#info-1] ][3] = (offset);LockDown(Serenity.SetupIndicatorsModule) end,
											},
											offsetY2 = {
												type = "range", 
												order = 4,
												name = L2["Bottom-Right Y"],
												desc = L2["This sets the 'Y offset' value."],
												min = -50, softMin = -10, softMax = 0, max = 50, step = 1,
												disabled = function(info) return not DB.frames.indicators["scarebeast_enablebackdrop"] end,
												get = function(info) return (DB.frames.indicators[info[#info-1] ][4]) end,
												set = function(info, offset) DB.frames.indicators[info[#info-1] ][4] = (offset);LockDown(Serenity.SetupIndicatorsModule) end,
											},										
										},
									},
								},
							},
							scarebeast_border = {
								type = "group",
								order = 28,
								name = L2["Scare Beast Border"],
								guiInline = false,
								hidden = function(info) return (Serenity.V["playerclass"] ~= "HUNTER") end,
								args = {
									scarebeast_enableborder = {
										type = "toggle",
										order = 1,
										name = L2["Enable"],
										desc = L2["DESCBORDER_ENABLE"],
										get = function(info) return DB.frames.indicators[info[#info] ] end,
										set = function(info, value) DB.frames.indicators[info[#info] ] = value;LockDown(Serenity.SetupIndicatorsModule) end,
									},
									scarebeast_bordertexture = {
										type = "select",
										dialogControl = 'LSM30_Border',
										order = 2,
										name = L2["Border texture"],
										desc = L2["Texture that gets used for the background."],
										values = AceGUIWidgetLSMlists.border,
										disabled = function(info) return not DB.frames.indicators["scarebeast_enableborder"] end,
										get = function(info) return DB.frames.indicators[info[#info] ] end,
										set = function(info, value) DB.frames.indicators[info[#info] ] = value;LockDown(Serenity.SetupIndicatorsModule) end,
									},
									scarebeast_bordercolor = {
										type = "color",
										order = 3,
										name = L2["Border color"],
										hasAlpha = true,
										disabled = function(info) return not DB.frames.indicators["scarebeast_enableborder"] end,
										get = function(info) return unpack(DB.frames.indicators[info[#info] ]) end,
										set = function(info, r, g, b, a) DB.frames.indicators[info[#info] ] = {r, g, b, a};LockDown(Serenity.SetupIndicatorsModule) end,
									},
									scarebeast_edgesize = {
										type = "range",
										order = 4,
										name = L2["Edge Size"],
										desc = L2["DESCEDGESIZE_ENABLE"],
										min = -100, softMin = -16, softMax = 16, max = 100, step = 1,
										disabled = function(info) return not DB.frames.indicators["scarebeast_enableborder"] end,
										get = function(info) return DB.frames.indicators[info[#info] ] end,
										set = function(info, value) DB.frames.indicators[info[#info] ] = value;LockDown(Serenity.SetupIndicatorsModule) end,
									},
									spacer1 = { order = 7, type = "description", name = " ", desc = "", width = "full"},
									scarebeast_backdropinsets = {
										type = "group",
										order = 10,
										name = L2["Insets"],
										guiInline = true,
										args = {
											left = {
												type = "range",
												order = 1,
												name = L2["Left"],
												min = -50, softMin = -16, softMax = 16, max = 50, step = 1,
												disabled = function(info) return not DB.frames.indicators["scarebeast_enableborder"] end,
												get = function(info) return (DB.frames.indicators[info[#info-1] ][1]) end,
												set = function(info, offset) DB.frames.indicators[info[#info-1] ][1] = (offset);LockDown(Serenity.SetupIndicatorsModule) end,
											},
											right = {
												type = "range", 
												order = 2,
												name = L2["Right"],
												min = -50, softMin = -16, softMax = 16, max = 50, step = 1,
												disabled = function(info) return not DB.frames.indicators["scarebeast_enableborder"] end,
												get = function(info) return (DB.frames.indicators[info[#info-1] ][2]) end,
												set = function(info, offset) DB.frames.indicators[info[#info-1] ][2] = (offset);LockDown(Serenity.SetupIndicatorsModule) end,
											},
											top = {
												type = "range", 
												order = 3,
												name = L2["Top"],
												min = -50, softMin = -16, softMax = 16, max = 50, step = 1,
												disabled = function(info) return not DB.frames.indicators["scarebeast_enableborder"] end,
												get = function(info) return (DB.frames.indicators[info[#info-1] ][3]) end,
												set = function(info, offset) DB.frames.indicators[info[#info-1] ][3] = (offset);LockDown(Serenity.SetupIndicatorsModule) end,
											},
											bottom = {
												type = "range", 
												order = 4,
												name = L2["Bottom"],
												min = -50, softMin = -16, softMax = 16, max = 50, step = 1,
												disabled = function(info) return not DB.frames.indicators["scarebeast_enableborder"] end,
												get = function(info) return (DB.frames.indicators[info[#info-1] ][4]) end,
												set = function(info, offset) DB.frames.indicators[info[#info-1] ][4] = (offset);LockDown(Serenity.SetupIndicatorsModule) end,
											},										
										},
									},
								},
							},
						},
					},
					-- timers (injected) ORDER = 50+
					-- icons (injected) ORDER = 150+
					alerticons = { -- Alert icons
						order = 250,
						type = "group",
						name = L2["Alerts"],
						guiInline = false,
						args = {
							intro = {
								order = 1,
								type = "description",
								name = L2["ALERTFRAME_DESC"].."\n",
							},
							size = {
								type = "group",
								order = 2,
								name = L2["Size of the alert"],
								guiInline = false,
								args = {
									iconsize = {
										type = "range", 
										order = 3,
										name = L2["Icon size"],
										min = 10, max = 100, step = 1,
										get = function(info) return (DB.frames.alerts.icons[info[#info] ]) end,
										set = function(info, size) DB.frames.alerts.icons[info[#info] ] = (size);LockDown(Serenity.SetupAlertsModule) end,
									},
								},
							},
							texcoords = {
								type = "group",
								order = 8,
								name = L2["Texture Coords"],
								guiInline = false,
								args = {						
									enabletexcoords = {
										type = "toggle",
										order = 5,
										name = L2["Enable TexCoords"],
										desc = L2["DESCTEXCOORDS_ENABLE"],
										get = function(info) return DB.frames.alerts.icons[info[#info] ] end,
										set = function(info, value) DB.frames.alerts.icons[info[#info] ] = value;LockDown(Serenity.SetupAlertsModule) end,
									},
									texcoords = {
										type = "group",
										order = 6,
										name = L2["Texture Coords"],
										guiInline = true,
										args = {
											left = {
												type = "range",
												order = 1,
												name = L2["Left"],
												min = 0, max = 1, step = .01,
												disabled = function(info) return not DB.frames.alerts.icons["enabletexcoords"] end,
												get = function(info) return (DB.frames.alerts.icons[info[#info-1] ][1]) end,
												set = function(info, offset) DB.frames.alerts.icons[info[#info-1] ][1] = (offset);LockDown(Serenity.SetupAlertsModule) end,
											},
											right = {
												type = "range", 
												order = 2,
												name = L2["Right"],
												min = 0, max = 1, step = .01,
												disabled = function(info) return not DB.frames.alerts.icons["enabletexcoords"] end,
												get = function(info) return (DB.frames.alerts.icons[info[#info-1] ][2]) end,
												set = function(info, offset) DB.frames.alerts.icons[info[#info-1] ][2] = (offset);LockDown(Serenity.SetupAlertsModule) end,
											},
											top = {
												type = "range", 
												order = 3,
												name = L2["Top"],
												min = 0, max = 1, step = .01,
												disabled = function(info) return not DB.frames.alerts.icons["enabletexcoords"] end,
												get = function(info) return (DB.frames.alerts.icons[info[#info-1] ][3]) end,
												set = function(info, offset) DB.frames.alerts.icons[info[#info-1] ][3] = (offset);LockDown(Serenity.SetupAlertsModule) end,
											},
											bottom = {
												type = "range", 
												order = 4,
												name = L2["Bottom"],
												min = 0, max = 1, step = .01,
												disabled = function(info) return not DB.frames.alerts.icons["enabletexcoords"] end,
												get = function(info) return (DB.frames.alerts.icons[info[#info-1] ][4]) end,
												set = function(info, offset) DB.frames.alerts.icons[info[#info-1] ][4] = (offset);LockDown(Serenity.SetupAlertsModule) end,
											},										
										},
									},
								},
							},
							backdrop = {
								type = "group",
								order = 3,
								name = L2["Alert's Backdrop"],
								guiInline = false,
								args = {
									enablebackdrop = {
										type = "toggle",
										order = 1,
										name = L2["Enable"],
										desc = L2["DESCBACKDROP_ENABLE"],
										get = function(info) return DB.frames.alerts.icons[info[#info] ] end,
										set = function(info, value) DB.frames.alerts.icons[info[#info] ] = value;LockDown(Serenity.SetupAlertsModule) end,
									},
									backdroptexture = {
										type = "select",
										dialogControl = 'LSM30_Background',
										order = 2,
										name = L2["Backdrop texture"],
										desc = L2["Texture that gets used for the alert's background."],
										values = AceGUIWidgetLSMlists.background,
										disabled = function(info) return not DB.frames.alerts.icons["enablebackdrop"] end,
										get = function(info) return DB.frames.alerts.icons[info[#info] ] end,
										set = function(info, value) DB.frames.alerts.icons[info[#info] ] = value;LockDown(Serenity.SetupAlertsModule) end,
									},
									colorbackdrop = {
										type = "toggle",
										order = 3,
										name = L2["Color the backdrop"],
										desc = L2["DESCBACKDROPCOLOR_ENABLE"],
										disabled = function(info) return not DB.frames.alerts.icons["enablebackdrop"] end,
										get = function(info) return DB.frames.alerts.icons[info[#info] ] end,
										set = function(info, value) DB.frames.alerts.icons[info[#info] ] = value;LockDown(Serenity.SetupAlertsModule) end,
									},
									backdropcolor = {
										type = "color",
										order = 4,
										name = L2["Backdrop color"],
										hasAlpha = true,
										disabled = function(info) return not DB.frames.alerts.icons["enablebackdrop"] end,
										hidden = function(info) return not DB.frames.alerts.icons.colorbackdrop end,
										get = function(info) return unpack(DB.frames.alerts.icons[info[#info] ]) end,
										set = function(info, r, g, b, a) DB.frames.alerts.icons[info[#info] ] = {r, g, b, a};LockDown(Serenity.SetupAlertsModule) end,
									},
									tile = {
										type = "toggle",
										order = 5,
										name = L2["Tile the backdrop"],
										desc = L2["DESCBACKDROPTILE_ENABLE"],
										disabled = function(info) return not DB.frames.alerts.icons["enablebackdrop"] end,
										get = function(info) return DB.frames.alerts.icons[info[#info] ] end,
										set = function(info, value) DB.frames.alerts.icons[info[#info] ] = value;LockDown(Serenity.SetupAlertsModule) end,
									},
									tilesize = {
										type = "range",
										order = 6,
										name = L2["Tile Size"],
										desc = L2["DESCTILESIZE_ENABLE"],
										min = -100, softMin = -30, softMax = 30, max = 100, step = 1,
										disabled = function(info) return not DB.frames.alerts.icons["enablebackdrop"] end,
										hidden = function(info) return not DB.frames.alerts.icons.tile end,
										get = function(info) return DB.frames.alerts.icons[info[#info] ] end,
										set = function(info, value) DB.frames.alerts.icons[info[#info] ] = value;LockDown(Serenity.SetupAlertsModule) end,
									},
									spacer = { order = 7, type = "description", name = " ", desc = "", width = "full"},
									backdropoffsets = {
										type = "group",
										order = 8,
										name = L2["Offsets"],
										guiInline = true,
										args = {
											offsetX1 = {
												type = "range",
												order = 1,
												name = L2["Top-Left X"],
												desc = L2["This sets the 'X offset' value."],
												min = -50, softMin = -10, softMax = 0, max = 50, step = 1,
												disabled = function(info) return not DB.frames.alerts.icons["enablebackdrop"] end,
												get = function(info) return (DB.frames.alerts.icons[info[#info-1] ][1]) end,
												set = function(info, offset) DB.frames.alerts.icons[info[#info-1] ][1] = (offset);LockDown(Serenity.SetupAlertsModule) end,
											},
											offsetY1 = {
												type = "range", 
												order = 2,
												name = L2["Top-Left Y"],
												desc = L2["This sets the 'Y offset' value."],
												min = -50, softMin = 0, softMax = 10, max = 50, step = 1,
												disabled = function(info) return not DB.frames.alerts.icons["enablebackdrop"] end,
												get = function(info) return (DB.frames.alerts.icons[info[#info-1] ][2]) end,
												set = function(info, offset) DB.frames.alerts.icons[info[#info-1] ][2] = (offset);LockDown(Serenity.SetupAlertsModule) end,
											},
											offsetX2 = {
												type = "range", 
												order = 3,
												name = L2["Bottom-Right X"],
												desc = L2["This sets the 'X offset' value."],
												min = -50, softMin = 0, softMax = 10, max = 50, step = 1,
												disabled = function(info) return not DB.frames.alerts.icons["enablebackdrop"] end,
												get = function(info) return (DB.frames.alerts.icons[info[#info-1] ][3]) end,
												set = function(info, offset) DB.frames.alerts.icons[info[#info-1] ][3] = (offset);LockDown(Serenity.SetupAlertsModule) end,
											},
											offsetY2 = {
												type = "range", 
												order = 4,
												name = L2["Bottom-Right Y"],
												desc = L2["This sets the 'Y offset' value."],
												min = -50, softMin = -10, softMax = 0, max = 50, step = 1,
												disabled = function(info) return not DB.frames.alerts.icons["enablebackdrop"] end,
												get = function(info) return (DB.frames.alerts.icons[info[#info-1] ][4]) end,
												set = function(info, offset) DB.frames.alerts.icons[info[#info-1] ][4] = (offset);LockDown(Serenity.SetupAlertsModule) end,
											},										
										},
									},
									spacer = { order = 9, type = "description", name = " ", desc = "", width = "full"},
								},
							},
							border = {
								type = "group",
								order = 4,
								name = L2["Alert's Border"],
								guiInline = false,
								args = {
									enableborder = {
										type = "toggle",
										order = 1,
										name = L2["Enable"],
										desc = L2["DESCBORDER_ENABLE"],
										get = function(info) return DB.frames.alerts.icons[info[#info] ] end,
										set = function(info, value) DB.frames.alerts.icons[info[#info] ] = value;LockDown(Serenity.SetupAlertsModule) end,
									},
									bordertexture = {
										type = "select",
										dialogControl = 'LSM30_Border',
										order = 2,
										name = L2["Border texture"],
										values = AceGUIWidgetLSMlists.border,
										disabled = function(info) return not DB.frames.alerts.icons["enableborder"] end,
										get = function(info) return DB.frames.alerts.icons[info[#info] ] end,
										set = function(info, value) DB.frames.alerts.icons[info[#info] ] = value;LockDown(Serenity.SetupAlertsModule) end,
									},
									bordercolor = {
										type = "color",
										order = 3,
										name = L2["Border color"],
										hasAlpha = true,
										disabled = function(info) return not DB.frames.alerts.icons["enableborder"] end,
										get = function(info) return unpack(DB.frames.alerts.icons[info[#info] ]) end,
										set = function(info, r, g, b, a) DB.frames.alerts.icons[info[#info] ] = {r, g, b, a};LockDown(Serenity.SetupAlertsModule) end,
									},
									edgesize = {
										type = "range",
										order = 4,
										name = L2["Edge Size"],
										desc = L2["DESCEDGESIZE_ENABLE"],
										min = -100, softMin = -16, softMax = 16, max = 100, step = 1,
										disabled = function(info) return not DB.frames.alerts.icons["enableborder"] end,
										get = function(info) return DB.frames.alerts.icons[info[#info] ] end,
										set = function(info, value) DB.frames.alerts.icons[info[#info] ] = value;LockDown(Serenity.SetupAlertsModule) end,
									},
									spacer = { order = 7, type = "description", name = " ", desc = "", width = "full"},
									backdropinsets = {
										type = "group",
										order = 10,
										name = L2["Insets"],
										guiInline = true,
										args = {
											left = {
												type = "range",
												order = 1,
												name = L2["Left"],
												min = -50, softMin = -16, softMax = 16, max = 50, step = 1,
												disabled = function(info) return not DB.frames.alerts.icons["enableborder"] end,
												get = function(info) return (DB.frames.alerts.icons[info[#info-1] ][1]) end,
												set = function(info, offset) DB.frames.alerts.icons[info[#info-1] ][1] = (offset);LockDown(Serenity.SetupAlertsModule) end,
											},
											right = {
												type = "range", 
												order = 2,
												name = L2["Right"],
												min = -50, softMin = -16, softMax = 16, max = 50, step = 1,
												disabled = function(info) return not DB.frames.alerts.icons["enableborder"] end,
												get = function(info) return (DB.frames.alerts.icons[info[#info-1] ][2]) end,
												set = function(info, offset) DB.frames.alerts.icons[info[#info-1] ][2] = (offset);LockDown(Serenity.SetupAlertsModule) end,
											},
											top = {
												type = "range", 
												order = 3,
												name = L2["Top"],
												min = -50, softMin = -16, softMax = 16, max = 50, step = 1,
												disabled = function(info) return not DB.frames.alerts.icons["enableborder"] end,
												get = function(info) return (DB.frames.alerts.icons[info[#info-1] ][3]) end,
												set = function(info, offset) DB.frames.alerts.icons[info[#info-1] ][3] = (offset);LockDown(Serenity.SetupAlertsModule) end,
											},
											bottom = {
												type = "range", 
												order = 4,
												name = L2["Bottom"],
												min = -50, softMin = -16, softMax = 16, max = 50, step = 1,
												disabled = function(info) return not DB.frames.alerts.icons["enableborder"] end,
												get = function(info) return (DB.frames.alerts.icons[info[#info-1] ][4]) end,
												set = function(info, offset) DB.frames.alerts.icons[info[#info-1] ][4] = (offset);LockDown(Serenity.SetupAlertsModule) end,
											},										
										},
									},
								},
							},
							fonttext = {
								type = "group",
								order = 5,
								name = L2["Stack text"],
								guiInline = false,
								args = {
									stackfont = {
										type = "group",
										order = 13,
										name = L2["Stacks font"],
										guiInline = true,
										args = {
											font = {
												type = "select", 
												dialogControl = 'LSM30_Font',
												order = 1,
												name = L2["Font Face"],
												desc = L2["This is the font used for stacks on the alert."],
												values = AceGUIWidgetLSMlists.font,
												get = function(info) return DB.frames.alerts.icons[info[#info-1] ][1] end,
												set = function(info, font) DB.frames.alerts.icons[info[#info-1] ][1] = font;LockDown(Serenity.SetupAlertsModule) end,
											},
											size = {
												type = "range", 
												order = 2,
												name = L2["Font Size"],
												min = 6, max = 40, step = 1,
												get = function(info) return (DB.frames.alerts.icons[info[#info-1] ][2]) end,
												set = function(info, size) DB.frames.alerts.icons[info[#info-1] ][2] = (size);LockDown(Serenity.SetupAlertsModule) end,
											},
											flags = {
												type = "multiselect", 
												order = 3,
												name = L2["Font Flags"],
												values = fontFlagTable,
												get = function(info, key) return(tContains({strsplit(",", DB.frames.alerts.icons[info[#info-1] ][3])}, key) and true or false) end,
												set = function(info, keyname, state) setFontFlags(DB.frames.alerts.icons[info[#info-1] ], keyname, state);LockDown(Serenity.SetupAlertsModule) end,
											},
										},
									},
									stackfontcolor = {
										type = "color",
										order = 14,
										name = L2["Stacks Font Color"],
										desc = L2["Color used for the stacks font."],
										hasAlpha = false,
										get = function(info) return unpack(DB.frames.alerts.icons[info[#info] ]) end,
										set = function(info, r, g, b, a) DB.frames.alerts.icons[info[#info] ] = {r, g, b, a};LockDown(Serenity.SetupAlertsModule) end,
									},
								},
							},
						},
					},
				},
			},
			energybar = {
				order = 6,
				type = "group",
				name = L2["Energy Bar"],
				guiInline = true,
				childGroups = "tree",
				args = {
					intro = {
						order = 1,
						type = "description",
						name = L2["ENERGYBAR_DESC"].."\n",
					},
					enabled = {
						type = "toggle",
						order = 4,
						name = L2["Enable"],
						desc = L2["ENERGYBARDESC_ENABLE"],
						width = "full",
						get = function(info) return DB.energybar[info[#info] ] end,
						set = function(info, value) DB.energybar[info[#info] ] = value;LockDown(Serenity.SetupEnergyBarModule) end,
					},
					genstuff = {
						order = 8,
						type = "group",
						name = " ",
						guiInline = true,
						args = {
							smoothbar = {
								type = "toggle",
								order = 6,
								name = L2["Enable energy bar smoothing"],
								desc = L2["ENERGYBARSMOOTHBARDESC_ENABLE"],
								width = "full",
								disabled = function(info) return not DB.energybar["enabled"] end,
								get = function(info) return DB.energybar[info[#info] ] end,
								set = function(info, value) DB.energybar[info[#info] ] = value;LockDown(Serenity.SetupEnergyBarModule) end,
							},
							energynumber = {
								type = "toggle",
								order = 8,
								name = L2["Show current energy number"],
								desc = L2["ENERGYBARNUMBERDESC_ENABLE"],
								--width = "full",
								disabled = function(info) return not DB.energybar["enabled"] end,
								get = function(info) return DB.energybar[info[#info] ] end,
								set = function(info, value) DB.energybar[info[#info] ] = value;LockDown(Serenity.SetupEnergyBarModule) end,
							},
							targethealth = {
								type = "toggle",
								order = 10,
								name = L2["Show current target's health on bar"],
								desc = L2["ENERGYBARHEALTHDESC_ENABLE"],
								--width = "full",
								disabled = function(info) return not DB.energybar["enabled"] end,
								get = function(info) return DB.energybar[info[#info] ] end,
								set = function(info, value) DB.energybar[info[#info] ] = value;LockDown(Serenity.SetupEnergyBarModule) end,
							},
							shottimer = {
								type = "toggle",
								order = 11,
								name = L2["Show numeric timer for auto-shot/attack"],
								desc = L2["ENERGYBARAUTOSHOTDESC_ENABLE"],
								--width = "full",
								disabled = function(info) return not DB.energybar["enabled"] end,
								get = function(info) return DB.energybar[info[#info] ] end,
								set = function(info, value) DB.energybar[info[#info] ] = value;LockDown(Serenity.SetupEnergyBarModule) end,
							},
							shotbar = {
								type = "toggle",
								order = 12,
								name = L2["Show moving bar for auto-shot/attack"],
								desc = L2["ENERGYBARAUTOSHOTBARDESC_ENABLE"],
								--width = "full",
								disabled = function(info) return not DB.energybar["enabled"] end,
								get = function(info) return DB.energybar[info[#info] ] end,
								set = function(info, value) DB.energybar[info[#info] ] = value;LockDown(Serenity.SetupEnergyBarModule) end,
							},
							smoothbarshotbar = {
								type = "toggle",
								order = 14,
								name = L2["Enable shot bar smoothing"],
								desc = L2["ENERGYBARSMOOTHBARDESC_ENABLE"],
								width = "full",
								hidden = function(info) return not DB.energybar["shotbar"] end,
								disabled = function(info) return not DB.energybar["enabled"] end,
								get = function(info) return DB.energybar[info[#info] ] end,
								set = function(info, value) DB.energybar[info[#info] ] = value;LockDown(Serenity.SetupEnergyBarModule) end,
							},
							enableprediction = {
								type = "toggle",
								order = 16,
								name = L2["Enable prediction of incoming energy"],
								desc = L2["ENERGYBARPREDICTIONDESC_ENABLE"],
								width = "full",
								disabled = function(info) return not DB.energybar["enabled"] end,
								get = function(info) return DB.energybar[info[#info] ] end,
								set = function(info, value) DB.energybar[info[#info] ] = value;LockDown(Serenity.SetupEnergyBarModule) end,
							},
						},
					},
					warningstuff = {
						order = 16,
						type = "group",
						name = " ",
						guiInline = true,
						args = {
							lowwarn = {
								type = "toggle",
								order = 6,
								name = L2["Enable low energy color change"],
								desc = L2["ENERGYBARLOWWARNDESC_ENABLE"],
								width = "full",
								disabled = function(info) return not DB.energybar["enabled"] end,
								get = function(info) return DB.energybar[info[#info] ] end,
								set = function(info, value) DB.energybar[info[#info] ] = value;LockDown(Serenity.SetupEnergyBarModule) end,
							},
							highwarn = {
								type = "toggle",
								order = 8,
								name = L2["Enable high energy color change"],
								desc = L2["ENERGYBARHIGHWARNDESC_ENABLE"],
								--width = "full",
								disabled = function(info) return not DB.energybar["enabled"] end,
								get = function(info) return DB.energybar[info[#info] ] end,
								set = function(info, value) DB.energybar[info[#info] ] = value;LockDown(Serenity.SetupEnergyBarModule) end,
							},
							highwarnthreshold = {
								type = "range", 
								order = 10,
								name = L2["High warning at %"],
								desc = L2["ENERGYBARHIGHWARNTHRESHOLD_DESC"],
								disabled = function(info) return not DB.energybar["enabled"] end,
								hidden = function(info) return(not DB.energybar.highwarn) end,
								isPercent = true,
								min = .1, max = 1, step = .05,
								get = function(info) return(DB.energybar[info[#info] ]) end,
								set = function(info, size) DB.energybar[info[#info] ] = (size);LockDown(Serenity.SetupEnergyBarModule) end,
							},
						},
					},
					alphastuff = {
						order = 18,
						type = "group",
						name = " ",
						guiInline = true,
						args = {
							activealpha = {
								type = "range",
								order = 24,
								name = L2["Active Alpha"],
								desc = L2["ENERGYBARACTIVEALPHA_DESC"],
								min = 0, max = 1, step = .1,
								isPercent = true,
								disabled = function(info) return not DB.energybar["enabled"] end,
								get = function(info) return (DB.energybar[info[#info] ]) end,
								set = function(info, value) DB.energybar[info[#info] ] = (value);LockDown(Serenity.SetupEnergyBarModule) end,
							},
							inactivealpha = {
								type = "range",
								order = 26,
								name = L2["Inactive Alpha"],
								desc = L2["ENERGYBARINACTIVEALPHA_DESC"],
								min = 0, max = 1, step = .1,
								isPercent = true,
								disabled = function(info) return not DB.energybar["enabled"] end,
								get = function(info) return (DB.energybar[info[#info] ]) end,
								set = function(info, value) DB.energybar[info[#info] ] = (value);LockDown(Serenity.SetupEnergyBarModule) end,
							},
							oocoverride = {
								type = "toggle",
								order = 28,
								name = L2["Enable OOC Override"],
								desc = L2["ENERGYBARENABLEOOCOVERRIDE_DESC"],
								disabled = function(info) return not DB.energybar["enabled"] end,
								get = function(info) return DB.energybar[info[#info] ] end,
								set = function(info, value) DB.energybar[info[#info] ] = value;LockDown(Serenity.SetupEnergyBarModule) end,
							},
							oocoverridealpha = {
								type = "range",
								order = 30,
								name = L2["OOC Alpha"],
								desc = L2["ENERGYBAROOCALPHA_DESC"],
								min = 0, max = 1, step = .1,
								isPercent = true,
								disabled = function(info) 
									if not DB.energybar["oocoverride"] then return true end
									if not DB.energybar["enabled"] then return true end
									return false end,
								get = function(info) return (DB.energybar[info[#info] ]) end,
								set = function(info, value) DB.energybar[info[#info] ] = (value);LockDown(Serenity.SetupEnergyBarModule) end,
							},
							mountoverride = {
								type = "toggle",
								order = 32,
								name = L2["Enable Mount Override"],
								desc = L2["ENERGYBARENABLEMOUNTOVERRIDE_DESC"],
								disabled = function(info) return not DB.energybar["enabled"] end,
								get = function(info) return DB.energybar[info[#info] ] end,
								set = function(info, value) DB.energybar[info[#info] ] = value;LockDown(Serenity.SetupEnergyBarModule) end,
							},
							mountoverridealpha = {
								type = "range",
								order = 34,
								name = L2["Mount Alpha"],
								desc = L2["ENERGYBARMOUNTALPHA_DESC"],
								min = 0, max = 1, step = .1,
								isPercent = true,
								disabled = function(info) 
									if not DB.energybar["mountoverride"] then return true end
									if not DB.energybar["enabled"] then return true end
									return false end,
								get = function(info) return (DB.energybar[info[#info] ]) end,
								set = function(info, value) DB.energybar[info[#info] ] = (value);LockDown(Serenity.SetupEnergyBarModule) end,
							},
							deadoverride = {
								type = "toggle",
								order = 36,
								name = L2["Enable Dead Override"],
								desc = L2["ENERGYBARENABLEDEADOVERRIDE_DESC"],
								disabled = function(info) return not DB.energybar["enabled"] end,
								get = function(info) return DB.energybar[info[#info] ] end,
								set = function(info, value) DB.energybar[info[#info] ] = value;LockDown(Serenity.SetupEnergyBarModule) end,
							},
							deadoverridealpha = {
								type = "range",
								order = 38,
								name = L2["Dead Alpha"],
								desc = L2["ENERGYBARDEADALPHA_DESC"],
								min = 0, max = 1, step = .1,
								isPercent = true,
								disabled = function(info) 
									if not DB.energybar["deadoverride"] then return true end
									if not DB.energybar["enabled"] then return true end
									return false end,
								get = function(info) return (DB.energybar[info[#info] ]) end,
								set = function(info, value) DB.energybar[info[#info] ] = (value);LockDown(Serenity.SetupEnergyBarModule) end,
							},
						},
					},
					stackstuff = {
						order = 20,
						type = "group",
						name = L2["Stack Indicators"],
						guiInline = true,
						args = {
							enablestacks = {
								type = "toggle",
								order = 4,
								name = L2["Enable"],
								desc = L2["ENERGYBARSTACKSDESC_ENABLE"],
								width = "full",
								get = function(info) return DB.energybar.enablestacks end,
								set = function(info, value) DB.energybar.enablestacks = value;LockDown(Serenity.SetupEnergyBarModule) end,
							},
							embedstacks = {
								type = "toggle",
								order = 8,
								name = L2["Embed on bar"],
								desc = L2["ENERGYBARSTACKSEMBEDDESC_ENABLE"],
								get = function(info) return DB.energybar[info[#info] ] end,
								set = function(info, value) DB.energybar[info[#info] ] = value;LockDown(Serenity.SetupEnergyBarModule) end,
							},
							stackssize = {
								type = "range",
								order = 12,
								name = L2["Stack size"],
								desc = L2["ENERGYBARSTACKSIZE_DESC"],
								min = 10, softMax = 100, max = 600, step = 1,
								disabled = function(info) return DB.energybar["embedstacks"] end,
								get = function(info) return (DB.energybar[info[#info] ]) end,
								set = function(info, value) DB.energybar[info[#info] ] = (value);LockDown(Serenity.SetupEnergyBarModule) end,
							},
							stacksreverse = {
								type = "toggle",
								order = 18,
								name = L2["Reverse stacks"],
								desc = L2["ENERGYBARSTACKSREVERSEDESC_ENABLE"],
								get = function(info) return DB.energybar[info[#info] ] end,
								set = function(info, value) DB.energybar[info[#info] ] = value;LockDown(Serenity.SetupEnergyBarModule) end,
							},
							stackscolor = {
								type = "color",
								order = 28,
								name = L2["Stacks color"],
								hasAlpha = false,
								get = function(info) return unpack(DB.energybar[info[#info] ]) end,
								set = function(info, r, g, b, a) DB.energybar[info[#info] ] = {r, g, b, a};LockDown(Serenity.SetupEnergyBarModule) end,
							},
						},
					},
					tickstuff1 = {
						order = 24,
						type = "group",
						name = L2["Indicator 1 (Main Spell)"],
						guiInline = true,
						args = {
							enabled = {
								type = "toggle",
								order = 4,
								name = L2["Enable"],
								desc = L2["ENERGYBARTICKDESC_ENABLE"],
								width = "full",
								get = function(info) return DB.energybar.ticks[1][1] end,
								set = function(info, value) DB.energybar.ticks[1][1] = value;LockDown(Serenity.SetupEnergyBarModule) end,
							},							
							colorbar = {
								type = "toggle",
								order = 14,
								name = L2["Change bar color"],
								desc = L2["TICKCOLOR_DESC"],
								hidden = function(info) return not DB.energybar.ticks[1][1] end,
								get = function(info) return DB.energybar.ticks[1][4] end,
								set = function(info, value) DB.energybar.ticks[1][4] = value;LockDown(Serenity.SetupEnergyBarModule) end,
							},
							color = {
								type = "color",
								order = 18,
								name = L2["Color"],
								desc = L2["Color to change to."],
								disabled = function(info) return not DB.energybar.ticks[1][4] end,
								hidden = function(info) return not DB.energybar.ticks[1][1] end,
								hasAlpha = true,
								get = function(info) return unpack(DB.energybar.ticks[1][5]) end,
								set = function(info, r, g, b, a) DB.energybar.ticks[1][5] = {r, g, b, a};LockDown(Serenity.SetupEnergyBarModule) end,
							},
						},
					},
					tickstuff2 = {
						order = 26,
						type = "group",
						name = L2["Indicator 2"],
						hidden = function(info) return not DB.energybar.ticks[1][1] end,
						guiInline = true,
						args = {
							enabled = {
								type = "toggle",
								order = 4,
								name = L2["Enable"],
								desc = L2["ENERGYBARTICKDESC_ENABLE"],
								width = "full",
								get = function(info) return DB.energybar.ticks[2][1] end,
								set = function(info, value) DB.energybar.ticks[2][1] = value;LockDown(Serenity.SetupEnergyBarModule) end,
							},
							spell = {
								order = 7,
								type = "select",
								name = L2["Spell"],
								desc = L2["TICKSPELL_DESC"],
								hidden = function(info) return not DB.energybar.ticks[2][1] end,
								style = "dropdown",
								values = function() return getPlayerSpells() end,
								get = function(info) return DB.energybar.ticks[2][2] end,
								set = function(info, value) DB.energybar.ticks[2][2] = value;LockDown(Serenity.SetupEnergyBarModule) end,
							},
							spec = {
								order = 8,
								type = "select",
								name = L2["Talent Spec"],
								desc = L2["TICKSPEC_DESC"],
								hidden = function(info) return not DB.energybar.ticks[2][1] end,
								style = "dropdown",
								values = function()
										local t = {
											["0"] = L2["Any Spec"],
											["1"] = select(2, GetTalentTabInfo(1)),
											["2"] = select(2, GetTalentTabInfo(2)),
											["3"] = select(2, GetTalentTabInfo(3)),
										}
										return(t)
									end,
								get = function(info) return(tostring(DB.energybar.ticks[2][6])) end,
								set = function(info, value) DB.energybar.ticks[2][6] = tonumber(value);LockDown(Serenity.SetupEnergyBarModule) end,
							},
							offset = {
								type = "toggle",
								order = 10,
								name = L2["Offset from main spell"],
								desc = L2["TICKOFFSET_DESC"],
								hidden = function(info) return not DB.energybar.ticks[2][1] end,
								get = function(info) return DB.energybar.ticks[2][3] end,
								set = function(info, value) DB.energybar.ticks[2][3] = value;LockDown(Serenity.SetupEnergyBarModule) end,
							},
							colorbar = {
								type = "toggle",
								order = 14,
								name = L2["Change bar color"],
								desc = L2["TICKCOLOR_DESC"],
								hidden = function(info) return not DB.energybar.ticks[2][1] end,
								get = function(info) return DB.energybar.ticks[2][4] end,
								set = function(info, value) DB.energybar.ticks[2][4] = value;LockDown(Serenity.SetupEnergyBarModule) end,
							},
							color = {
								type = "color",
								order = 18,
								name = L2["Color"],
								desc = L2["Color to change to."],
								disabled = function(info) return not DB.energybar.ticks[2][4] end,
								hidden = function(info) return not DB.energybar.ticks[2][1] end,
								hasAlpha = true,
								get = function(info) return unpack(DB.energybar.ticks[2][5]) end,
								set = function(info, r, g, b, a) DB.energybar.ticks[2][5] = {r, g, b, a};LockDown(Serenity.SetupEnergyBarModule) end,
							},
						},
					},
					tickstuff3 = {
						order = 29,
						type = "group",
						name = L2["Indicator 3"],
						hidden = function(info) return not DB.energybar.ticks[1][1] end,
						guiInline = true,
						args = {
							enabled = {
								type = "toggle",
								order = 4,
								name = L2["Enable"],
								desc = L2["ENERGYBARTICKDESC_ENABLE"],
								width = "full",
								get = function(info) return DB.energybar.ticks[3][1] end,
								set = function(info, value) DB.energybar.ticks[3][1] = value;LockDown(Serenity.SetupEnergyBarModule) end,
							},
							spell = {
								order = 7,
								type = "select",
								name = L2["Spell"],
								desc = L2["TICKSPELL_DESC"],
								hidden = function(info) return not DB.energybar.ticks[3][1] end,
								style = "dropdown",
								values = function() return getPlayerSpells() end,
								get = function(info) return DB.energybar.ticks[3][2] end,
								set = function(info, value) DB.energybar.ticks[3][2] = value;LockDown(Serenity.SetupEnergyBarModule) end,
							},
							spec = {
								order = 8,
								type = "select",
								name = L2["Talent Spec"],
								desc = L2["TICKSPEC_DESC"],
								hidden = function(info) return not DB.energybar.ticks[3][1] end,
								style = "dropdown",
								values = function()
										local t = {
											["0"] = L2["Any Spec"],
											["1"] = select(2, GetTalentTabInfo(1)),
											["2"] = select(2, GetTalentTabInfo(2)),
											["3"] = select(2, GetTalentTabInfo(3)),
										}
										return(t)
									end,
								get = function(info) return(tostring(DB.energybar.ticks[3][6])) end,
								set = function(info, value) DB.energybar.ticks[3][6] = tonumber(value);LockDown(Serenity.SetupEnergyBarModule) end,
							},
							offset = {
								type = "toggle",
								order = 10,
								name = L2["Offset from main spell"],
								desc = L2["TICKOFFSET_DESC"],
								hidden = function(info) return not DB.energybar.ticks[3][1] end,
								get = function(info) return DB.energybar.ticks[3][3] end,
								set = function(info, value) DB.energybar.ticks[3][3] = value;LockDown(Serenity.SetupEnergyBarModule) end,
							},
							colorbar = {
								type = "toggle",
								order = 14,
								name = L2["Change bar color"],
								desc = L2["TICKCOLOR_DESC"],
								hidden = function(info) return not DB.energybar.ticks[3][1] end,
								get = function(info) return DB.energybar.ticks[3][4] end,
								set = function(info, value) DB.energybar.ticks[3][4] = value;LockDown(Serenity.SetupEnergyBarModule) end,
							},
							color = {
								type = "color",
								order = 18,
								name = L2["Color"],
								desc = L2["Color to change to."],
								disabled = function(info) return not DB.energybar.ticks[3][4] end,
								hidden = function(info) return not DB.energybar.ticks[3][1] end,
								hasAlpha = true,
								get = function(info) return unpack(DB.energybar.ticks[3][5]) end,
								set = function(info, r, g, b, a) DB.energybar.ticks[3][5] = {r, g, b, a};LockDown(Serenity.SetupEnergyBarModule) end,
							},
						},
					},
					tickstuff4 = {
						order = 32,
						type = "group",
						name = L2["Indicator 4"],
						hidden = function(info) return not DB.energybar.ticks[1][1] end,
						guiInline = true,
						args = {
							enabled = {
								type = "toggle",
								order = 4,
								name = L2["Enable"],
								desc = L2["ENERGYBARTICKDESC_ENABLE"],
								width = "full",
								get = function(info) return DB.energybar.ticks[4][1] end,
								set = function(info, value) DB.energybar.ticks[4][1] = value;LockDown(Serenity.SetupEnergyBarModule) end,
							},
							spell = {
								order = 7,
								type = "select",
								name = L2["Spell"],
								desc = L2["TICKSPELL_DESC"],
								hidden = function(info) return not DB.energybar.ticks[4][1] end,
								style = "dropdown",
								values = function() return getPlayerSpells() end,
								get = function(info) return DB.energybar.ticks[4][2] end,
								set = function(info, value) DB.energybar.ticks[4][2] = value;LockDown(Serenity.SetupEnergyBarModule) end,
							},
							spec = {
								order = 8,
								type = "select",
								name = L2["Talent Spec"],
								desc = L2["TICKSPEC_DESC"],
								hidden = function(info) return not DB.energybar.ticks[4][1] end,
								style = "dropdown",
								values = function()
										local t = {
											["0"] = L2["Any Spec"],
											["1"] = select(2, GetTalentTabInfo(1)),
											["2"] = select(2, GetTalentTabInfo(2)),
											["3"] = select(2, GetTalentTabInfo(3)),
										}
										return(t)
									end,
								get = function(info) return(tostring(DB.energybar.ticks[4][6])) end,
								set = function(info, value) DB.energybar.ticks[4][6] = tonumber(value);LockDown(Serenity.SetupEnergyBarModule) end,
							},
							offset = {
								type = "toggle",
								order = 10,
								name = L2["Offset from main spell"],
								desc = L2["TICKOFFSET_DESC"],
								hidden = function(info) return not DB.energybar.ticks[4][1] end,
								get = function(info) return DB.energybar.ticks[4][3] end,
								set = function(info, value) DB.energybar.ticks[4][3] = value;LockDown(Serenity.SetupEnergyBarModule) end,
							},
							colorbar = {
								type = "toggle",
								order = 14,
								name = L2["Change bar color"],
								desc = L2["TICKCOLOR_DESC"],
								hidden = function(info) return not DB.energybar.ticks[4][1] end,
								get = function(info) return DB.energybar.ticks[4][4] end,
								set = function(info, value) DB.energybar.ticks[4][4] = value;LockDown(Serenity.SetupEnergyBarModule) end,
							},
							color = {
								type = "color",
								order = 18,
								name = L2["Color"],
								desc = L2["Color to change to."],
								disabled = function(info) return not DB.energybar.ticks[4][4] end,
								hidden = function(info) return not DB.energybar.ticks[4][1] end,
								hasAlpha = true,
								get = function(info) return unpack(DB.energybar.ticks[4][5]) end,
								set = function(info, r, g, b, a) DB.energybar.ticks[4][5] = {r, g, b, a};LockDown(Serenity.SetupEnergyBarModule) end,
							},
						},
					},
					tickstuff5 = {
						order = 35,
						type = "group",
						name = L2["Indicator 5"],
						hidden = function(info) return not DB.energybar.ticks[1][1] end,
						guiInline = true,
						args = {
							enabled = {
								type = "toggle",
								order = 4,
								name = L2["Enable"],
								desc = L2["ENERGYBARTICKDESC_ENABLE"],
								width = "full",
								get = function(info) return DB.energybar.ticks[5][1] end,
								set = function(info, value) DB.energybar.ticks[5][1] = value;LockDown(Serenity.SetupEnergyBarModule) end,
							},
							spell = {
								order = 7,
								type = "select",
								name = L2["Spell"],
								desc = L2["TICKSPELL_DESC"],
								hidden = function(info) return not DB.energybar.ticks[5][1] end,
								style = "dropdown",
								values = function() return getPlayerSpells() end,
								get = function(info) return DB.energybar.ticks[5][2] end,
								set = function(info, value) DB.energybar.ticks[5][2] = value;LockDown(Serenity.SetupEnergyBarModule) end,
							},
							spec = {
								order = 8,
								type = "select",
								name = L2["Talent Spec"],
								desc = L2["TICKSPEC_DESC"],
								hidden = function(info) return not DB.energybar.ticks[5][1] end,
								style = "dropdown",
								values = function()
										local t = {
											["0"] = L2["Any Spec"],
											["1"] = select(2, GetTalentTabInfo(1)),
											["2"] = select(2, GetTalentTabInfo(2)),
											["3"] = select(2, GetTalentTabInfo(3)),
										}
										return(t)
									end,
								get = function(info) return(tostring(DB.energybar.ticks[5][6])) end,
								set = function(info, value) DB.energybar.ticks[5][6] = tonumber(value);LockDown(Serenity.SetupEnergyBarModule) end,
							},
							offset = {
								type = "toggle",
								order = 10,
								name = L2["Offset from main spell"],
								desc = L2["TICKOFFSET_DESC"],
								hidden = function(info) return not DB.energybar.ticks[5][1] end,
								get = function(info) return DB.energybar.ticks[5][3] end,
								set = function(info, value) DB.energybar.ticks[5][3] = value;LockDown(Serenity.SetupEnergyBarModule) end,
							},
							colorbar = {
								type = "toggle",
								order = 14,
								name = L2["Change bar color"],
								desc = L2["TICKCOLOR_DESC"],
								hidden = function(info) return not DB.energybar.ticks[5][1] end,
								get = function(info) return DB.energybar.ticks[5][4] end,
								set = function(info, value) DB.energybar.ticks[5][4] = value;LockDown(Serenity.SetupEnergyBarModule) end,
							},
							color = {
								type = "color",
								order = 18,
								name = L2["Color"],
								desc = L2["Color to change to."],
								disabled = function(info) return not DB.energybar.ticks[5][4] end,
								hidden = function(info) return not DB.energybar.ticks[5][1] end,
								hasAlpha = true,
								get = function(info) return unpack(DB.energybar.ticks[5][5]) end,
								set = function(info, r, g, b, a) DB.energybar.ticks[5][5] = {r, g, b, a};LockDown(Serenity.SetupEnergyBarModule) end,
							},
						},
					},
				},
			},
			enrage = {
				order = 6,
				type = "group",
				name = L2["Enrage Alert"],
				guiInline = true,
				childGroups = "tree",
				args = {
					intro = {
						order = 1,
						type = "description",
						name = L2["ENRAGE_DESC"].."\n",
					},
					enabled = {
						type = "toggle",
						order = 4,
						name = L2["Enable"],
						desc = L2["ENRAGEDESC_ENABLE"],
						width = "full",
						get = function(info) return DB.enrage[info[#info] ] end,
						set = function(info, value) DB.enrage[info[#info] ] = value;LockDown(Serenity.SetupEnrageModule) end,
					},
					soundstuff = {
						order = 6,
						type = "group",
						name = L2["Sound Notification"],
						guiInline = true,
						args = {
							enablesound = {
								type = "toggle",
								order = 2,
								name = L2["Enable Alert Sound"],
								desc = L2["ENRAGESOUNDDESC_ENABLE"],
								--width = "full",
								disabled = function(info) return not DB.enrage.enabled end,
								get = function(info) return DB.enrage[info[#info] ] end,
								set = function(info, value) DB.enrage[info[#info] ] = value;LockDown(Serenity.SetupEnrageModule) end,
							},
							sound = {
								type = "select",
								dialogControl = 'LSM30_Sound',
								order = 6,
								name = L2["Alert Sound"],
								desc = L2["ENRAGESOUND_DESC"],
								values = AceGUIWidgetLSMlists.sound,
								disabled = function(info) return not DB.enrage.enabled end,
								hidden = function(info) return not DB.enrage.enablesound end,
								get = function(info) return DB.enrage[ info[#info] ] end,
								set = function(info, value) DB.enrage[ info[#info] ] = value;LockDown(Serenity.SetupEnrageModule) end,								
							},
						},
					},
					chatstuff = {
						order = 8,
						type = "group",
						name = L2["Chat Notification"],
						guiInline = true,
						args = {
							removednotify = {
								type = "toggle",
								order = 2,
								name = L2["Enable"],
								desc = L2["ENRAGEREMOVEDDESC_ENABLE"],
								width = "full",
								disabled = function(info) return not DB.enrage.enabled end,
								get = function(info) return DB.enrage[info[#info] ] end,
								set = function(info, value) DB.enrage[info[#info] ] = value;LockDown(Serenity.SetupEnrageModule) end,
							},
							spacer1 = { order = 4, type = "description", name = "", desc = "", width = "full"},
							solochan = {
								order = 6,
								type = "select",
								name = L2["Solo"],
								desc = L2["SOLOCHANNEL_DESC"],
								hidden = function(info) return not DB.enrage.removednotify end,
								disabled = function(info) return not DB.enrage.enabled end,
								style = "dropdown",
								values = function() return(Serenity.V["chatchannels"]) end,
								get = function(info) return(DB.enrage[info[#info] ]) end,
								set = function(info, value) DB.enrage[info[#info] ] = (value);LockDown(Serenity.SetupEnrageModule) end,
							},
							spacer2 = { order = 7, type = "description", name = "", desc = ""},
							partychan = {
								order = 8,
								type = "select",
								name = L2["In a Party"],
								desc = L2["PARTYCHANNEL_DESC"],
								hidden = function(info) return not DB.enrage.removednotify end,
								disabled = function(info) return not DB.enrage.enabled end,
								style = "dropdown",
								values = function() return(Serenity.V["chatchannels"]) end,
								get = function(info) return(DB.enrage[info[#info] ]) end,
								set = function(info, value) DB.enrage[info[#info] ] = (value);LockDown(Serenity.SetupEnrageModule) end,
							},
							raidchan = {
								order = 10,
								type = "select",
								name = L2["In a Raid"],
								desc = L2["RAIDCHANNEL_DESC"],
								hidden = function(info) return not DB.enrage.removednotify end,
								disabled = function(info) return not DB.enrage.enabled end,
								style = "dropdown",
								values = function() return(Serenity.V["chatchannels"]) end,
								get = function(info) return(DB.enrage[info[#info] ]) end,
								set = function(info, value) DB.enrage[info[#info] ] = (value);LockDown(Serenity.SetupEnrageModule) end,
							},
							arenachan = {
								order = 12,
								type = "select",
								name = L2["In an Arena"],
								desc = L2["ARENACHANNEL_DESC"],
								hidden = function(info) return not DB.enrage.removednotify end,
								disabled = function(info) return not DB.enrage.enabled end,
								style = "dropdown",
								values = function() return(Serenity.V["chatchannels"]) end,
								get = function(info) return(DB.enrage[info[#info] ]) end,
								set = function(info, value) DB.enrage[info[#info] ] = (value);LockDown(Serenity.SetupEnrageModule) end,
							},
							pvpchan = {
								order = 14,
								type = "select",
								name = L2["In a PvP Zone"],
								desc = L2["PVPCHANNEL_DESC"],
								hidden = function(info) return not DB.enrage.removednotify end,
								disabled = function(info) return not DB.enrage.enabled end,
								style = "dropdown",
								values = function() return(Serenity.V["chatchannels"]) end,
								get = function(info) return(DB.enrage[info[#info] ]) end,
								set = function(info, value) DB.enrage[info[#info] ] = (value);LockDown(Serenity.SetupEnrageModule) end,
							},
						},
					},
					spacer1 = { order = 12, type = "description", name = " ", desc = "", width = "full"},
					removablesstuff = {
						order = 16,
						type = "group",
						name = L2["Removable buffs display"],
						guiInline = true,
						args = {
							enableremovables = {
								type = "toggle",
								order = 2,
								name = L2["Enable display of removable buffs"],
								desc = L2["ENRAGEREMOVABLESDESC_ENABLE"],
								width = "full",
								disabled = function(info) return not DB.enrage.enabled end,
								get = function(info) return DB.enrage[info[#info] ] end,
								set = function(info, value) DB.enrage[info[#info] ] = value;LockDown(Serenity.SetupEnrageModule) end,
							},
							removablespvponly = {
								type = "toggle",
								order = 6,
								name = L2["Only show when in a PvP zone or Arena"],
								desc = L2["ENRAGEREMOVABLESPVP_DESC"],
								width = "full",
								disabled = function(info) return not DB.enrage.enableremovables end,
								get = function(info) return DB.enrage[info[#info] ] end,
								set = function(info, value) DB.enrage[info[#info] ] = value;LockDown(Serenity.SetupEnrageModule) end,
							},
							removablestips = {
								type = "toggle",
								order = 10,
								name = L2["Show tips when hovering removable buffs"],
								desc = L2["ENRAGEREMOVABLESTIPS_DESC"],
								width = "full",
								disabled = function(info) return not DB.enrage.enableremovables end,
								get = function(info) return DB.enrage[info[#info] ] end,
								set = function(info, value) DB.enrage[info[#info] ] = value;LockDown(Serenity.SetupEnrageModule) end,
							},
						},
					},
				},	
			},
			crowdcontrol = {
				order = 7,
				type = "group",
				name = L2["Crowd Control"],
				guiInline = true,
				childGroups = "tree",
				args = {
					intro = {
						order = 1,
						type = "description",
						name = L2["CC_DESC"].."\n",
					},
					enabled = {
						type = "toggle",
						order = 4,
						name = L2["Enable"],
						desc = L2["CCDESC_ENABLE"],
						width = "full",
						get = function(info) return DB.crowdcontrol[info[#info] ] end,
						set = function(info, value) DB.crowdcontrol[info[#info] ] = value;LockDown(Serenity.SetupCrowdControlModule) end,
					},
				},
			},
			indicators = {
				order = 8,
				type = "group",
				name = L2["Indicators"],
				guiInline = true,
				childGroups = "tree",
				args = {
					intro = {
						order = 1,
						type = "description",
						name = L2["INDICATORS_DESC"].."\n",
					},
					enabled = {
						type = "toggle",
						order = 4,
						name = L2["Enable"],
						desc = L2["INDICATORS_ENABLE"],
						width = "full",
						get = function(info) return DB.indicators[info[#info] ] end,
						set = function(info, value) DB.indicators[info[#info] ] = value;LockDown(Serenity.SetupIndicatorsModule) end,
					},
					spacer1 = { order = 6, type = "description", name = " ", desc = "", width = "full"},
					hm = {
						order = 10,
						type = "group",
						name = L2["Hunter's Mark Indicator"],
						guiInline = true,
						hidden = function(info) return (Serenity.V["playerclass"] ~= "HUNTER") end,
						args = {
							huntersmark_enable = {
								type = "toggle",
								order = 2,
								name = L2["Enable"],
								desc = L2["HM_INDICATOR_ENABLE"],
								width = "full",
								disabled = function(info) return (not DB.indicators.enabled) end,
								get = function(info) return DB.indicators[info[#info] ] end,
								set = function(info, value) DB.indicators[info[#info] ] = value;LockDown(Serenity.SetupIndicatorsModule) end,
							},
							huntersmark_mfd = {
								type = "toggle",
								order = 2,
								name = L2["Ignore Marked for Death"],
								desc = L2["HM_MFD_INDICATOR_ENABLE"],
								--width = "full",
								disabled = function(info) if (not DB.indicators.enabled) or (not DB.indicators.huntersmark_enable) then	return true	else return false end end,
								get = function(info) return DB.indicators[info[#info] ] end,
								set = function(info, value) DB.indicators[info[#info] ] = value;LockDown(Serenity.SetupIndicatorsModule) end,
							},
						},
					},
					spacer2 = { order = 12, type = "description", name = " ", desc = "", width = "full"},
					aspect = {
						order = 14,
						type = "group",
						name = L2["Aspect Indicator"],
						guiInline = true,
						hidden = function(info) return (Serenity.V["playerclass"] ~= "HUNTER") end,
						args = {
							aspect_enable = {
								type = "toggle",
								order = 2,
								name = L2["Enable"],
								desc = L2["ASPECT_INDICATOR_ENABLE"],
								width = "full",
								disabled = function(info) return (not DB.indicators.enabled) end,
								get = function(info) return DB.indicators[info[#info] ] end,
								set = function(info, value) DB.indicators[info[#info] ] = value;LockDown(Serenity.SetupIndicatorsModule) end,
							},
							aspect_onlymissing = {
								type = "toggle",
								order = 2,
								name = L2["Only show no aspect"],
								desc = L2["ASPECT_ONLYMISSING_DESC"],
								width = "full",
								disabled = function(info) if ((DB.indicators.enabled) and (DB.indicators.aspect_enable)) then return(false) else return(true) end end,
								get = function(info) return DB.indicators[info[#info] ] end,
								set = function(info, value) DB.indicators[info[#info] ] = value;LockDown(Serenity.SetupIndicatorsModule) end,
							},
							aspect_onlycombat = {
								type = "toggle",
								order = 2,
								name = L2["Only show in combat"],
								desc = L2["ASPECT_ONLYCOMBAT_DESC"],
								width = "full",
								disabled = function(info) if ((DB.indicators.enabled) and (DB.indicators.aspect_enable)) then return(false) else return(true) end end,
								get = function(info) return DB.indicators[info[#info] ] end,
								set = function(info, value) DB.indicators[info[#info] ] = value;LockDown(Serenity.SetupIndicatorsModule) end,
							},
						},
					},
					spacer3 = { order = 16, type = "description", name = " ", desc = "", width = "full"},
					scarebeast = {
						order = 18,
						type = "group",
						name = L2["Scare Beast Indicator"],
						guiInline = true,
						hidden = function(info) return (Serenity.V["playerclass"] ~= "HUNTER") end,
						args = {
							scarebeast_enable = {
								type = "toggle",
								order = 2,
								name = L2["Enable"],
								desc = L2["SCAREBEAST_INDICATOR_ENABLE"],
								width = "full",
								disabled = function(info) return (not DB.indicators.enabled) end,
								get = function(info) return DB.indicators[info[#info] ] end,
								set = function(info, value) DB.indicators[info[#info] ] = value;LockDown(Serenity.SetupIndicatorsModule) end,
							},
						},
					},
				},
			},
			timers = {
				order = 9,
				type = "group",
				name = L2["Timers"],
				guiInline = true,
				childGroups = "tree",
				args = SerenityOptions:CreateTimerSets(),
			},
			icons = {
				order = 10,
				type = "group",
				name = L2["Timer Icons"],
				guiInline = true,
				childGroups = "tree",
				args = SerenityOptions:CreateIconBlocks(),
			},
			interrupts = {
				order = 12,
				type = "group",
				name = L2["Interrupts"],
				guiInline = true,
				args = {
					intro = {
						order = 1,
						type = "description",
						name = L2["INTERRUPTS_DESC"].."\n",
					},
					enable = {
						type = "toggle",
						order = 4,
						name = L2["Enable"],
						width = "full",
						get = function(info) return DB.interrupts[info[#info] ] end,
						set = function(info, value) DB.interrupts[info[#info] ] = value;LockDown(Serenity.SetupInterruptsModule) end,
					},
					spacer1 = { order = 6, type = "description", name = " ", desc = "", width = "full"},
					announcechatstuff = {
						order = 14,
						type = "group",
						name = L2["Chat Notification"],
						disabled = function(info) return (not DB.interrupts.enable) end,
						guiInline = true,
						args = {
							enableannounce = {
								type = "toggle",
								order = 1,
								name = L2["Announce interrupts to chat"],
								width = "full",
								get = function(info) return DB.interrupts[info[#info] ] end,
								set = function(info, value) DB.interrupts[info[#info] ] = value end,
							},
							spacer1 = { order = 8, type = "description", name = "", desc = "", width = "full"},
							solochan = {
								order = 10,
								type = "select",
								name = L2["Solo"],
								desc = L2["SOLOCHANNEL_DESC"],
								hidden = function(info) return (not DB.interrupts.enableannounce) end,
								style = "dropdown",
								values = function() return(Serenity.V["chatchannels"]) end,
								get = function(info) return(DB.interrupts[info[#info] ]) end,
								set = function(info, value) DB.interrupts[info[#info] ] = (value) end,
							},
							spacer2 = { order = 12, type = "description", name = "", desc = ""},
							partychan = {
								order = 14,
								type = "select",
								name = L2["In a Party"],
								desc = L2["PARTYCHANNEL_DESC"],
								hidden = function(info) return (not DB.interrupts.enableannounce) end,
								style = "dropdown",
								values = function() return(Serenity.V["chatchannels"]) end,
								get = function(info) return(DB.interrupts[info[#info] ]) end,
								set = function(info, value) DB.interrupts[info[#info] ] = (value) end,
							},
							raidchan = {
								order = 16,
								type = "select",
								name = L2["In a Raid"],
								desc = L2["RAIDCHANNEL_DESC"],
								hidden = function(info) return (not DB.interrupts.enableannounce) end,
								style = "dropdown",
								values = function() return(Serenity.V["chatchannels"]) end,
								get = function(info) return(DB.interrupts[info[#info] ]) end,
								set = function(info, value) DB.interrupts[info[#info] ] = (value) end,
							},
							arenachan = {
								order = 18,
								type = "select",
								name = L2["In an Arena"],
								desc = L2["ARENACHANNEL_DESC"],
								hidden = function(info) return (not DB.interrupts.enableannounce) end,
								style = "dropdown",
								values = function() return(Serenity.V["chatchannels"]) end,
								get = function(info) return(DB.interrupts[info[#info] ]) end,
								set = function(info, value) DB.interrupts[info[#info] ] = (value) end,
							},
							pvpchan = {
								order = 20,
								type = "select",
								name = L2["In a PvP Zone"],
								desc = L2["PVPCHANNEL_DESC"],
								hidden = function(info) return (not DB.interrupts.enableannounce) end,
								style = "dropdown",
								values = function() return(Serenity.V["chatchannels"]) end,
								get = function(info) return(DB.interrupts[info[#info] ]) end,
								set = function(info, value) DB.interrupts[info[#info] ] = (value) end,
							},
						},
					},					
				},
			},
			threattransfer = {
				order = 12,
				type = "group",
				name = L2["Threat Transfer"],
				guiInline = true,
				args = {
					intro = {
						order = 1,
						type = "description",
						name = L2["THREATTRANSFER_DESC"].."\n",
					},
					enable = {
						type = "toggle",
						order = 4,
						name = L2["Enable right-click casting on unit frames"],
						desc = L2["RIGHTCLICKMD_DESC"],
						width = "full",
						get = function(info) return DB.misdirection[info[#info] ] end,
						set = function(info, value) DB.misdirection[info[#info] ] = value;LockDown(Serenity.SetupMisdirectionModule) end,
					},
					spacer1 = { order = 6, type = "description", name = " ", desc = "", width = "full"},
					announcechatstuff = {
						order = 14,
						type = "group",
						name = L2["Chat Notification"],
						guiInline = true,
						args = {
							enablemdcastannounce = {
								type = "toggle",
								order = 1,
								name = L2["Announce the cast"],
								width = "full",
								get = function(info) return DB.misdirection[info[#info] ] end,
								set = function(info, value) DB.misdirection[info[#info] ] = value end,
							},
							enablemdoverannounce = {
								type = "toggle",
								order = 4,
								name = L2["Announce the expire"],
								width = "full",
								get = function(info) return DB.misdirection[info[#info] ] end,
								set = function(info, value) DB.misdirection[info[#info] ] = value end,
							},
							enablemdtransferannounce = {
								type = "toggle",
								order = 4,
								name = L2["Whisper target when transferring"],
								width = "full",
								get = function(info) return DB.misdirection[info[#info] ] end,
								set = function(info, value) DB.misdirection[info[#info] ] = value end,
							},
							enablemdmountwarn =  {
								type = "toggle",
								order = 6,
								name = L2["Whisper target if they are mounted"],
								width = "full",
								get = function(info) return DB.misdirection[info[#info] ] end,
								set = function(info, value) DB.misdirection[info[#info] ] = value end,
							},
							spacer1 = { order = 8, type = "description", name = "", desc = "", width = "full"},
							solochan = {
								order = 10,
								type = "select",
								name = L2["Solo"],
								desc = L2["SOLOCHANNEL_DESC"],
								hidden = function(info) return ((not DB.misdirection.enablemdcastannounce) and (not DB.misdirection.enablemdoverannounce)) end,
								style = "dropdown",
								values = function() return(Serenity.V["chatchannels"]) end,
								get = function(info) return(DB.misdirection[info[#info] ]) end,
								set = function(info, value) DB.misdirection[info[#info] ] = (value) end,
							},
							spacer2 = { order = 12, type = "description", name = "", desc = ""},
							partychan = {
								order = 14,
								type = "select",
								name = L2["In a Party"],
								desc = L2["PARTYCHANNEL_DESC"],
								hidden = function(info) return ((not DB.misdirection.enablemdcastannounce) and (not DB.misdirection.enablemdoverannounce)) end,
								style = "dropdown",
								values = function() return(Serenity.V["chatchannels"]) end,
								get = function(info) return(DB.misdirection[info[#info] ]) end,
								set = function(info, value) DB.misdirection[info[#info] ] = (value) end,
							},
							raidchan = {
								order = 16,
								type = "select",
								name = L2["In a Raid"],
								desc = L2["RAIDCHANNEL_DESC"],
								hidden = function(info) return ((not DB.misdirection.enablemdcastannounce) and (not DB.misdirection.enablemdoverannounce)) end,
								style = "dropdown",
								values = function() return(Serenity.V["chatchannels"]) end,
								get = function(info) return(DB.misdirection[info[#info] ]) end,
								set = function(info, value) DB.misdirection[info[#info] ] = (value) end,
							},
							arenachan = {
								order = 18,
								type = "select",
								name = L2["In an Arena"],
								desc = L2["ARENACHANNEL_DESC"],
								hidden = function(info) return ((not DB.misdirection.enablemdcastannounce) and (not DB.misdirection.enablemdoverannounce)) end,
								style = "dropdown",
								values = function() return(Serenity.V["chatchannels"]) end,
								get = function(info) return(DB.misdirection[info[#info] ]) end,
								set = function(info, value) DB.misdirection[info[#info] ] = (value) end,
							},
							pvpchan = {
								order = 20,
								type = "select",
								name = L2["In a PvP Zone"],
								desc = L2["PVPCHANNEL_DESC"],
								hidden = function(info) return ((not DB.misdirection.enablemdcastannounce) and (not DB.misdirection.enablemdoverannounce)) end,
								style = "dropdown",
								values = function() return(Serenity.V["chatchannels"]) end,
								get = function(info) return(DB.misdirection[info[#info] ]) end,
								set = function(info, value) DB.misdirection[info[#info] ] = (value) end,
							},
						},
					},
					framestuff = {
						order = 18,
						type = "group",
						name = L2["Frame Selection"],
						guiInline = true,
						args = {
							targetframe =  {
								type = "toggle",
								order = 4,
								name = L2["Target frame"],
								disabled = function(info) return(not DB.misdirection.enable) end,								
								get = function(info) return DB.misdirection[info[#info] ] end,
								set = function(info, value) DB.misdirection[info[#info] ] = value;LockDown(Serenity.SetupMisdirectionModule) end,
							},
							petframe =  {
								type = "toggle",
								order = 6,
								name = L2["Pet frame"],
								disabled = function(info) return(not DB.misdirection.enable) end,								
								get = function(info) return DB.misdirection[info[#info] ] end,
								set = function(info, value) DB.misdirection[info[#info] ] = value;LockDown(Serenity.SetupMisdirectionModule) end,
							},
							focusframe =  {
								type = "toggle",
								order = 8,
								name = L2["Focus frame"],
								disabled = function(info) return(not DB.misdirection.enable) end,								
								get = function(info) return DB.misdirection[info[#info] ] end,
								set = function(info, value) DB.misdirection[info[#info] ] = value;LockDown(Serenity.SetupMisdirectionModule) end,
							},
							partyframes =  {
								type = "toggle",
								order = 10,
								name = L2["Party frames"],
								disabled = function(info) return(not DB.misdirection.enable) end,								
								get = function(info) return DB.misdirection[info[#info] ] end,
								set = function(info, value) DB.misdirection[info[#info] ] = value;LockDown(Serenity.SetupMisdirectionModule) end,
							},
							partypetframe =  {
								type = "toggle",
								order = 12,
								name = L2["Party pet frames"],
								disabled = function(info) return(not DB.misdirection.enable) end,								
								get = function(info) return DB.misdirection[info[#info] ] end,
								set = function(info, value) DB.misdirection[info[#info] ] = value;LockDown(Serenity.SetupMisdirectionModule) end,
							},
							raidframes =  {
								type = "toggle",
								order = 14,
								name = L2["Raid frames"],
								disabled = function(info) return(not DB.misdirection.enable) end,								
								get = function(info) return DB.misdirection[info[#info] ] end,
								set = function(info, value) DB.misdirection[info[#info] ] = value;LockDown(Serenity.SetupMisdirectionModule) end,
							},
							raidpetframes =  {
								type = "toggle",
								order = 16,
								name = L2["Raid pet frames"],
								disabled = function(info) return(not DB.misdirection.enable) end,								
								get = function(info) return DB.misdirection[info[#info] ] end,
								set = function(info, value) DB.misdirection[info[#info] ] = value;LockDown(Serenity.SetupMisdirectionModule) end,
							},
						},
					},
				},
			},
			alerts = {
				order = 10,
				type = "group",
				name = L2["Alerts"],
				childGroups = "select",
				args = SerenityOptions:CreateAlerts(),
			},
		},
	}
	
	-- Inject the timer set / icon block frames
	SerenityOptions:CreateFrameTimerSets(SerenityOptionsTable.args.frames.args)
	SerenityOptions:CreateFrameIconBlocks(SerenityOptionsTable.args.frames.args)
	LibStub("AceConfigRegistry-3.0"):NotifyChange("SerenityOptions")
	collectgarbage("collect")
	
	return SerenityOptionsTable
end
