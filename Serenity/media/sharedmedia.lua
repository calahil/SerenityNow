--[[

	LibSharedMedia interface
	
]]

if not Serenity then return end

Serenity.V["defaultFonts"] = {
	{ text = "Arial Narrow", 		value = "Fonts\\ARIALN.TTF", font = "Fonts\\ARIALN.TTF" },
	{ text = "Big Noodle", 			value = "Interface\\AddOns\\Serenity\\media\\fonts\\BigNoodle.ttf", font = "Interface\\AddOns\\Serenity\\media\\fonts\\BigNoodle.ttf" },
	{ text = "Friz Quadrata TT", 	value = "Fonts\\FRIZQT__.TTF", font = "Fonts\\FRIZQT__.TTF" },
	{ text = "Morpheus", 			value = "Fonts\\MORPHEUS.ttf", font = "Fonts\\MORPHEUS.ttf" },
	{ text = "Skurri", 				value = "Fonts\\skurri.ttf", font = "Fonts\\skurri.ttf" },
}

Serenity.V["defaultTextures"] = {
	{ text = "Blank", 				value = "Interface\\AddOns\\Serenity\\media\\textures\\blank.tga", texture = "Interface\\AddOns\\Serenity\\media\\textures\\blank.tga" },
	{ text = "Blizzard",			value = "Interface\\TargetingFrame\\UI-StatusBar", texture = "Interface\\TargetingFrame\\UI-StatusBar" },
	{ text = "Solid", 				value = "Interface\\AddOns\\Serenity\\media\\textures\\solid.tga", texture = "Interface\\AddOns\\Serenity\\media\\textures\\solid.tga"},
}

Serenity.V["defaultBorders"] = {
	{ text = "Solid", 				value = "Interface\\AddOns\\Serenity\\media\\textures\\solid.tga", border = "Interface\\AddOns\\Serenity\\media\\textures\\solidborder.tga"},
}

Serenity.V["defaultSounds"] = {
	{ text = "Raid Warning",	value = "Sound\\interface\\RaidWarning.wav", sound = "Sound\\interface\\RaidWarning.wav" },
	{ text = "Alliance Bell", 	value = "Sound\\Doodad\\BellTollAlliance.wav", sound = "Sound\\Doodad\\BellTollAlliance.wav" },
	{ text = "Cannon Blast", 	value = "Sound\\Doodad\\Cannon01_BlastA.wav", sound = "Sound\\Doodad\\Cannon01_BlastA.wav" },
	{ text = "Dynamite", 		value = "Sound\\Spells\\DynamiteExplode.wav", sound = "Sound\\Spells\\DynamiteExplode.wav" },
	{ text = "Gong", 			value = "Sound\\Doodad\\G_GongTroll01.wav", sound = "Sound\\Doodad\\G_GongTroll01.wav" },
	{ text = "Horde Bell", 		value = "Sound\\Doodad\\BellTollHorde.wav",	sound = "Sound\\Doodad\\BellTollHorde.wav" },
	{ text = "Serpent", 		value = "Sound\\Creature\\TotemAll\\SerpentTotemAttackA.wav", sound = "Sound\\Creature\\TotemAll\\SerpentTotemAttackA.wav" },
	{ text = "Tribal Bell", 	value = "Sound\\Doodad\\BellTollTribal.wav", sound = "Sound\\Doodad\\BellTollTribal.wav" },	
	{ text = "Classic", 		value = "Sound\\Doodad\\BellTollNightElf.wav", sound = "Sound\\Doodad\\BellTollNightElf.wav" },
	{ text = "Ding", 			value = "Sound\\interface\\AlarmClockWarning3.wav", sound = "Sound\\interface\\AlarmClockWarning3.wav" },
}

function Serenity.GetLibSharedMedia3()

	if LibStub and LibStub("LibSharedMedia-3.0", true) then
		return(LibStub("LibSharedMedia-3.0", true))
	end
	return(false)
end

function Serenity.updateSharedMedia(mediatype)
	-- Nothing to do.
end

-- Register our media to the global SharedMedia library
if Serenity.GetLibSharedMedia3() then

	for i=1,#Serenity.V["defaultFonts"] do
		Serenity.GetLibSharedMedia3():Register("font", Serenity.V["defaultFonts"][i].text, Serenity.V["defaultFonts"][i].font)
	end
	
	for i=1,#Serenity.V["defaultTextures"] do
		Serenity.GetLibSharedMedia3():Register("statusbar", Serenity.V["defaultTextures"][i].text, Serenity.V["defaultTextures"][i].texture)
	end
	
	for i=1,#Serenity.V["defaultBorders"] do
		Serenity.GetLibSharedMedia3():Register("border", Serenity.V["defaultBorders"][i].text, Serenity.V["defaultBorders"][i].border)
	end
	
	for i=1,#Serenity.V["defaultSounds"] do
		Serenity.GetLibSharedMedia3():Register("sound", Serenity.V["defaultSounds"][i].text, Serenity.V["defaultSounds"][i].sound)
	end
	Serenity.GetLibSharedMedia3().RegisterCallback(Serenity, "LibSharedMedia_Registered", "updateSharedMedia")
end
