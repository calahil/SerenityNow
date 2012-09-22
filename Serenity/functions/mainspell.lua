--[[

	Returns the cost of the player's main spell, dependant on current spec.
	
]]

if not Serenity then return end

local classSpells = {
	["HUNTER"] = { 34026, 53209, 53301 }, -- Kill Command, Aimed Shot, Explosive Shot
}

local lastCost = 0
local currentCost = 0

function Serenity.GetMainSpellCost()

	if Serenity.V.playerclass == "HUNTER" then
		currentCost = select(4, GetSpellInfo(classSpells[Serenity.V.playerclass][GetSpecialization() or 1]))
		if currentCost ~= 0 then
			lastCost = currentCost
		end
		return lastCost
	else
		print(Serenity.L["SERENITY_PRE"]..Serenity.RGBToHex(1,0,0).."Invalid class for GetMainSpellCost!|r")
		return nil
	end
end
