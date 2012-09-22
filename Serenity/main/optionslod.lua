--[[

	Options Load on Demand
	
	Sets up a main options panel with a "Load on Demand" button to load in the options.
	This allows memory to stay low when options are not being used.
	
]]

if not Serenity then return end

function Serenity.LoadOptionsAddon()

	PlaySound("igMainMenuOptionCheckBoxOn")
	
	if Serenity.SerenityOptionsIsLoaded then return end

	local loaded, reason = LoadAddOn("SerenityOptions")

	if not loaded then
		print(Serenity.L["SERENITY_PRE"]..Serenity.L["OPT_LOD_ERR"].."\""..reason.."\"")
	else
		print(Serenity.L["SERENITY_PRE"]..Serenity.L["OPT_LOD_OK"])

		Serenity.SerenityOptionsIsLoaded = true
	end
end

--[[
	Sets up a single, main page for Serenity Options.
	This consists of nothing more than a button to call the function to load in
	the SerenityOptions addons which is Load on Demand.
	Also creates a profile page for easy access to profile changing.
]]
function Serenity.SetupOptionsLOD()

	local lodOptionsTable = {
		type = "group",
		name = "Serenity",		
		args = {
			main = {
				order = 1,
				type = "group",
				name = Serenity.L["General Settings"],
				desc = Serenity.L["General Settings"],
				args = {
					intro = {
						order = 1,
						type = "description",
						name = Serenity.L["SERENITY_DESC"].."\n\n\n\n",
					},
					LoD = {
						order = 2,
						type = "group",						
						name = Serenity.L["Load on Demand Options"],
						guiInline = true,
						args = {
							lod = {
								order = 2,
								type = "execute",
								name = Serenity.L["OPT_LOD_BUTTON_TEXT"],
								func = function(info) PlaySound("igMainMenuOptionCheckBoxOn"); Serenity.LoadOptionsAddon(); end,
							},
							loddesc = {
								order = 3,
								type = "description",
								fontSize = "large",
								name = "\n\n"..Serenity.L["OPT_LOD_BUTTON_DESC"],
							},
						},
					},
				},
			},			
		},
	}
	
	-- Register the options table
	LibStub("AceConfigRegistry-3.0"):RegisterOptionsTable("SerenityOptions", lodOptionsTable)
	
	-- Create a profiles table
	Serenity.profileOptions = LibStub("AceDBOptions-3.0"):GetOptionsTable(Serenity.db)
	LibStub("AceConfig-3.0"):RegisterOptionsTable("SerenityProfiles", Serenity.profileOptions)
	
	-- Setup the actual options panels
	local AceConfigDialog3 = LibStub("AceConfigDialog-3.0")
	Serenity.optionsFrames = {}
	Serenity.optionsFrames.SerenityOptions = AceConfigDialog3:AddToBlizOptions("SerenityOptions", "Serenity", nil, "main")
	Serenity.optionsFrames.Profiles = AceConfigDialog3:AddToBlizOptions("SerenityProfiles", Serenity.L["Profiles"], "Serenity")	

	--[[
		After this function is initially called, it should never be called again.
		
		This will have to be removed later when the options LoD is made to Unload on Demand.
	]]	
	Serenity.SetupOptionsLOD = nil
	collectgarbage("collect") -- Frees up "garbage" memory.
end
