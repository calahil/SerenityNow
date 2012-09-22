--[[

	Serenity Configuration
	
	This handles registering a configuration function for the main addon and any modules.
	
	These functions are called when the addon needs to reconfigure itself,
	such as when the User Interface Scale changes.
]]

if not Serenity then return end

--[[
	This is the reconfiguration function that gets called when Serenity needs
	to be globally reconfigured.
]]
function Serenity.ReconfigureSerenity()
	if not globalConfigs then globalConfigs = {};return end
	local key,val
	for key,val in pairs(globalConfigs) do
		val()
	end
end

--[[
	Registers a function that will be called when the addon needs to be
	globally reconfigured because settings may have changed.
]]
function Serenity.RegisterConfigFunction(name, func)
	if not globalConfigs then globalConfigs = {} end
	globalConfigs[name] = func
end

--[[
	Removes a registered configuration function from the chain.
]]
function Serenity.UnregisterConfigFunction(name)
	if not globalConfigs then globalConfigs = {};return end
	if not tContains(globalConfigs, name) then return end
	tremove(globalCOnfigs, name)
end
