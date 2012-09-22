--[[

	Serenity

	by JS - US-Blackhand
	
]]

if not Serenity then return end

function Serenity:SlashProcessor_Serenity(input)

	local v1, v2 = input:match("^(%S*)%s*(.-)$")
	v1 = v1:lower()

	if v1 == "" then	
		if not debug then
			print(format(Serenity.L["SLASHDESC1"], Serenity.V["shortversion"]))
			print("/ser config - " .. Serenity.L["SLASHDESC2"])
			print("/ser lock - " .. Serenity.L["SLASHDESC3"])
			print("/ser reset - " .. Serenity.L["SLASHDESC4"])
		else
			print(Serenity.L["SERENITY_PRE"].."Debug Info:")
		end		
	elseif v1 == "options" or v1 == "config" or v1 == "opt" or v1 == "o" then
		Serenity.LoadOptionsAddon()
		if Serenity.SerenityOptionsIsLoaded == true then
			InterfaceOptionsFrame_OpenToCategory(Serenity.optionsFrames.SerenityOptions)
		end
	elseif v1 == "reset" then
		if not InCombatLockdown() then
			print(Serenity.L["SERENITY_PRE"]..Serenity.L["MOVERSSETTODEFAULT"])
			Serenity.SetDefaultMoversPositions()
		else
			print(Serenity.L["SERENITY_PRE"]..Serenity.L["INCOMBATLOCKDOWN"])
		end
	elseif v1 == "lock" or v1 == "unlock" or v1 == "drag" or v1 == "move" or v1 == "l" then
		--[[if InCombatLockdown() then
			print(Serenity.L["SERENITY_PRE"]..Serenity.L["INCOMBATLOCKDOWN"])
			return
		end]]
		Serenity.ToggleMoversLock()		
	elseif v1 == "id" or v1 == "frameid" then	
		if GetMouseFocus():GetName() then
			print(format(Serenity.L["SERENITY_PRE"]..Serenity.L["SLASHFRAMEID"], GetMouseFocus():GetName() or "nil"))
		end		
	else
		print(Serenity.L["SERENITY_PRE"]..Serenity.L["INVALIDSLASH"])
	end
end

--[[
	Event functions
]]
function Serenity:VARIABLES_LOADED()
	--[[
		Register module configuration functions.
		
		Every module is responsible for destruction before construction
		and de-registering / registering it's own Frame Mover.
	]]	
	Serenity.RegisterConfigFunction("MOD_ENERGYBAR", Serenity.SetupEnergyBarModule) -- Energy bar Module	
	Serenity.RegisterConfigFunction("MOD_TIMERS", Serenity.SetupTimersModule) -- Timers Module
	Serenity.RegisterConfigFunction("MOD_ENRAGE", Serenity.SetupEnrageModule) -- Enrage Module	
	Serenity.RegisterConfigFunction("MOD_CROWDCONTROL", Serenity.SetupCrowdControlModule) -- Crowd Control Module	
	Serenity.RegisterConfigFunction("MOD_INDICATORS",Serenity.SetupIndicatorsModule) -- Indicators Module
	Serenity.RegisterConfigFunction("MOD_INTERRUPTS",Serenity.SetupInterruptsModule) -- Misdirection Module
	Serenity.RegisterConfigFunction("MOD_MISDIRECTION",Serenity.SetupMisdirectionModule) -- Misdirection Module
	Serenity.RegisterConfigFunction("MOD_ICONS", Serenity.SetupIconsModule) -- Icons Module
	Serenity.RegisterConfigFunction("MOD_ALERTS", Serenity.SetupAlertsModule) -- Alerts Module
	Serenity.RegisterConfigFunction("MOD_STACKBARS", Serenity.SetupStackBarsModule) -- Stack Bars Module
	
	--[[
		Globally configure all modules.
	]]
	Serenity.ReconfigureSerenity()
	
	-- Clean up
	Serenity:RegisterEvent("PLAYER_ENTERING_WORLD")
	Serenity:UnregisterEvent("VARIABLES_LOADED")
	Serenity.VARIABLES_LOADED = nil
	collectgarbage("collect")
end

function Serenity:PLAYER_REGEN_ENABLED()
	if Serenity.db.profile.misdirection.enable then
		if Serenity.V.flagDelayedMDUpdate then
			Serenity.SetupMisdirectionModule()
			Serenity:UnregisterEvent("PLAYER_REGEN_ENABLED")
		end
	end
end

function Serenity:UI_SCALE_CHANGED()
	Serenity.ReconfigureSerenity()
end

function Serenity:ACTIVE_TALENT_GROUP_CHANGED()
	Serenity.ReconfigureSerenity()
end

function Serenity:PLAYER_ENTERING_WORLD()
	Serenity.ReconfigureSerenity()
end

function Serenity:PLAYER_LEVEL_UP()
	Serenity.ReconfigureSerenity()
end

function Serenity:PostChangeProfile()
	if SerenityOptions and Serenity.V.OptionsLoaded then 
		SerenityOptions:PopulateDB()
	end
	Serenity.ReconfigureSerenity()
end

function Serenity:OnInitialize()
	-- Code that you want to run when the addon is first loaded goes here.
  
	--[[
		Display the welcome greeting on startup
	]]
	print(format(Serenity.L["GREETING1"], Serenity.V["shortversion"]))
	
	--[[
		Register Slash commands for Serenity.
	]]
	Serenity:RegisterChatCommand("serenity", "SlashProcessor_Serenity")
	Serenity:RegisterChatCommand("ser", "SlashProcessor_Serenity")

	--[[
		Serenity tries to wait for all variables to be loaded before configuring itself.
	]]
	Serenity:RegisterEvent("VARIABLES_LOADED")
	
	--[[
		Setup Saved Variables
	]]
	Serenity.db = LibStub("AceDB-3.0"):New("SerenityDB", Serenity.V["defaults"], true)
	
	--[[
		After the defaults have been fed into AceDB, now we can create defaults for
		things like the timers.  These entries can be totally deleted from the options,
		so they can not be saved as AceDB does when you feed it a default options table
		because it will create 'nil' table entries.
	]]
	Serenity.newInstallSetup()
	
	--[[
		Register a reconfigure call for when the user changes profiles.
	]]
	Serenity.db.RegisterCallback(Serenity, "OnProfileChanged", "PostChangeProfile")
	Serenity.db.RegisterCallback(Serenity, "OnProfileCopied", "PostChangeProfile")
	Serenity.db.RegisterCallback(Serenity, "OnProfileReset", "PostChangeProfile")
	
	--[[
		Setup the initial options panels.  This consists of a LoD button and profiles tab.
	]]
	Serenity.SetupOptionsLOD()
	
	--[[
		Register an event to notify Serenity when the addon needs to be reconfigured based on events.
	]]
	Serenity:RegisterEvent("UI_SCALE_CHANGED")
	Serenity:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED")
	Serenity:RegisterEvent("PLAYER_LEVEL_UP")
	
	--[[
		Free up memory from OnInitialize function, as it will never be run again.
	]]
	Serenity.OnInitialize = nil
	collectgarbage("collect") -- Frees up "garbage" memory.
end

function Serenity:OnEnable()
    -- Called when the addon is enabled	
end

function Serenity:OnDisable()
    -- Called when the addon is disabled
end
