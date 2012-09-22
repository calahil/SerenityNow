--[[

	Localization for enUS and enGB.
	
]]

local AceLocale = LibStub:GetLibrary("AceLocale-3.0")
local L2 = AceLocale:NewLocale("SerenityOptions", "enUS", true)
if not L2 then return end

-- Misc
L2["Enable"] = true
L2["NONE"] = true
L2["Sound Notification"] = true
L2["Chat Notification"] = true
L2["Colors"] = true
L2["Font Face"] = true
L2["Font Size"] = true
L2["Font Flags"] = true
L2["OUTLINE"] = true
L2["THICKOUTLINE"] = true
L2["MONOCHROME"] = true
L2["Offsets"] = true
L2["X Offset"] = true
L2["Y Offset"] = true
L2["This sets the 'X offset' value."] = true
L2["This sets the 'Y offset' value."] = true
L2["Only valid numeric offsets are allowed."] = true
L2["Top-Left X"] = true
L2["Top-Left Y"] = true
L2["Bottom-Right X"] = true
L2["Bottom-Right Y"] = true
L2["Horizontal"] = true
L2["Vertical"] = true
L2["Insets"] = true
L2["Left"] = true
L2["Right"] = true
L2["Top"] = true
L2["Bottom"] = true

L2["SERENITY_BUILD"] = "Version "
L2["Enable master audio channel for sounds"] = true
L2["MASTERAUDIO_DESC"] = "Turning this option on will play any sound files through the \"Master Audio\" channel.  This allows you to turn off game sounds but still hear imporatnt alert or warning sounds."
L2["Tenths of seconds display"] = true
L2["MINFORTENTHS_DESC"] = "Pick the number of seconds remaining where timers will start to show tenths of seconds."

-- Options panels
L2["Template"] = true
L2["TEMPLATE_DESC"] = "Templates allow you to change the look of Serenity on a global level.  If you change templates, you will lose any custom style settings for frames.\n\nYou may want to consider creating a new profile before you change to a new global style."
L2["Pick a re-styling template:"] = true
L2["TEMPLATE_DESC2"] = "A template is a set of styling for the different frames, fonts, textures, backdrops, etc. of Serenity.  Selecting a template here will change current styling to anything defined in the template."

L2["Styling"] = true
L2["STYLES_DESC"] = "Styling is the \"look and feel\" settings of the various components.  You can change things like fonts, textures, colors, etc. in this area."

-- Frame Movers
L2["Mover Frames"] = true
L2["MOVERS_DESC"] = "Movers are the frames that show up when you unlock Serenity to move the module's frames around"
L2["Title font"] = true
L2["This is the font used for the title of the movable frames when you unlock Serenity."] = true
L2["Color of a movable frame's title text"] = true
L2["Title font's color"] = true
L2["Frame color"] = true
L2["Color of the movable frame"] = true

-- Cooldowns
L2["Cooldowns"] = true
L2["COOLDOWNS_DESC"] = "Cooldowns are the \"cooldown\" shown for various modules, such as the time remaining on a crowd control timer"
L2["Cooldown font"] = true
L2["This is the font used for cooldown or duration timers."] = true
L2["Days Color"] = true
L2["Color when a cooldown is at least a day"] = true
L2["Hours Color"] = true
L2["Color when a cooldown is at least an hour"] = true
L2["Minutes Color"] = true
L2["Color when a cooldown is at least a minute"] = true
L2["Seconds Color"] = true
L2["Color when a cooldown is only seconds"] = true
L2["Expiring Color"] = true
L2["Color when a cooldown is about to expire"] = true
L2["Font Shadow Color"] = true
L2["Color used for the cooldown's font shadow"] = true
L2["ENABLESHADOW_DESC"] = "Do you want to enable a shadow behind the text?"
L2["Font shadow"] = true
L2["Shadow offset"] = true

-- Energy Bar
L2["Energy Bar"] = true
L2["ENERGYBAR_DESC"] = "The energy bar is your focus, energy, rage, etc. status bar.  This will differ for any class that is supported."
L2["Enable energy bar smoothing"] = true
L2["Enable shot bar smoothing"] = true
L2["ENERGYBARSMOOTHBARDESC_ENABLE"] = "This will make the moving status bar fill in a flowing manner as opposed to being chunky in how it fills the bar."
L2["Size of the bar"] = true
L2["Width"] = true
L2["Height"] = true
L2["Current energy font"] = true
L2["This is the font used for your current energy, focus, rage, etc."] = true
L2["Target's health font"] = true
L2["This is the font used for showing your target's current health percent."] = true
L2["Shot timer font"] = true
L2["This is the font used for the shot timer. (A hunter's auto-shot, for example)"] = true
L2["Energy bar style"] = true
L2["Energy bar texture"] = true
L2["Texture that gets used on the moving status bar."] = true
L2["Texture that gets used for the bar's background."] = true
L2["DESCBACKDROP_ENABLE"] = "Turns on the backdrop, otherwise the layer will not be drawn."
L2["DESCBORDER_ENABLE"] = "Turns on the border, otherwise the layer will not be drawn."
L2["Energy Offset"] = true
L2["DESC_ENERGYBARFONTOFFSET"] = "This offsets the text to the left or right of the default position on the bar."
L2["Health Offset"] = true
L2["Shot Timer Offset"] = true
L2["ENERGYBARDESC_ENABLE"] = "Turn the entire energy bar module on or off."
L2["Show current energy number"] = true
L2["ENERGYBARNUMBERDESC_ENABLE"] = "You can turn on or off the number on the energy bar showing a numeric value for your current energy type. (energy, focus, rage, etc.)"
L2["Show current target's health on bar"] = true
L2["ENERGYBARHEALTHDESC_ENABLE"] = "Show the health percentage of the current target on the bar."
L2["Show numeric timer for auto-shot/attack"] = true
L2["ENERGYBARAUTOSHOTDESC_ENABLE"] = "Shows the cooldown time till your next auto-shot / auto-attack, etc."
L2["Show moving bar for auto-shot/attack"] = true
L2["ENERGYBARAUTOSHOTBARDESC_ENABLE"] = "Adds a moving bar to the bottom of the energy bar to indicate when an auto-shot/attack will occur."
L2["Use class colors for the bar"] = true
L2["DESCENERGYBARCLASSCOLOR_ENABLE"] = "You can choose to either color the moving energy bar to match your class or specify the color.\nNote: Other options can override this color, such as prediction, or setting indicators on the bar."
L2["Bar's normal color"] = true
L2["ENERGYBARCOLORNORM_DESC"] = "This color can be overridden with other settings, such as low or high threshold or indicators being set to change color."
L2["Enable low energy color change"] = true
L2["ENERGYBARLOWWARNDESC_ENABLE"] = "Change the bar's color if there is not enough energy to use your main shot/attack spell."
L2["Bar's low warning color"] = true
L2["Bar's high warning color"] = true
L2["Auto shot/attack bar color"] = true
L2["Enable high energy color change"] = true
L2["ENERGYBARHIGHWARNDESC_ENABLE"] = "Change the bar's color if the energy is above the set amount for being considered high (or near over-capping)."
L2["High warning at %"] = true
L2["ENERGYBARHIGHWARNTHRESHOLD_DESC"] = "Set the percent of energy when the high warning color change should occur."
L2["Enable prediction of incoming energy"] = true
L2["ENERGYBARPREDICTIONDESC_ENABLE"] = "If this option is on, a secondary bar will be shown at the end of the status bar to indicate how much energy is incoming."
L2["ENERGYBARACTIVEALPHA_DESC"] = "Alpha value for when the bar's energy number is draining/filling. (in use)"
L2["ENERGYBARINACTIVEALPHA_DESC"] = "Alpha value for when the bar's energy is not draining/filling. (not in use)"
L2["ENERGYBARENABLEOOCOVERRIDE_DESC"] = "This will override the bar's alpha value if you are not in combat."
L2["ENERGYBAROOCALPHA_DESC"] = "This is the value to set the bar's alpha to when OOC Override is turned on and you are Out Of Combat."
L2["ENERGYBARENABLEMOUNTOVERRIDE_DESC"] = "This will override the bar's alpha value if you are mounted."
L2["ENERGYBARMOUNTALPHA_DESC"] = "This is the value to set the bar's alpha to when Mount Override is turned on and you are mounted."
L2["ENERGYBARENABLEDEADOVERRIDE_DESC"] = "This will override the bar's alpha value if you are dead or a ghost."
L2["ENERGYBARDEADALPHA_DESC"] = "This is the value to set the bar's alpha to when Dead Override is turned on and you are dead or a ghost."
L2["Current energy text color"] = true
L2["Color of the text showing your current energy."] = true
L2["Shot timer text color"] = true
L2["Color of the text showing auto shot/attack timer."] = true
L2["Shot bar's color"] = true
L2["Color of the bar showing auto shot/attack timer."] = true
L2["Indicator 1 (Main Spell)"] = true
L2["Indicator 2"] = true
L2["Indicator 3"] = true
L2["Indicator 4"] = true
L2["Indicator 5"] = true
L2["ENERGYBARTICKDESC_ENABLE"] = "This enables the use of this tick. (a \"tick\" is a mark on the bar indicating how much energy you need to cast a defined spell)"
L2["Spell"] = true
L2["TICKSPELL_DESC"] = "Choose the spell to display an indicator mark on the bar for."
L2["Offset from main spell"] = true
L2["TICKOFFSET_DESC"] = "Turning this on makes this indicator mark place itself to the right of the main spell; turning it off places it from the very left of the bar plus spell cost."
L2["Change bar color"] = true
L2["TICKCOLOR_DESC"] = "This will make the bar turn to the defined color if current energy is more than the cost of this tick but less than the next higher tick or bar max."
L2["Color"] = true
L2["Color to change to."] = true
L2["TICKSPEC_DESC"] = "Select which talent spec this tick should be enabled for."

-- Enrage Alert
L2["Enrage Alert"] = true
L2["ENRAGE_DESC"] = "The Enrage alert is used to notify you when something needs to be removed from your target.  Hunters use Tranqulizing Shot, Rogues use Shiv, etc."
L2["Sizes"] = true
L2["Alert icon size"] = true
L2["ENRAGEDESC_ENABLE"] = "Turn or or off the entire Enrage Alert module."
L2["Removables icon size"] = true
L2["ENRAGEREOMVABLESSIZE_DESC"] = "This is the size of the icons used when you turn on the \"Removables\" frame to show what is on your target that can be removed."
L2["ENRAGEREMOVEDDESC_ENABLE"] = "This enables the sending of a chat message showing what was removed when something is removed from the target."
L2["Enable Alert Sound"] = true
L2["ENRAGESOUNDDESC_ENABLE"] = "This will play a specified sound file when the Enrage Alert is triggered."
L2["Alert Sound"] = true
L2["ENRAGESOUND_DESC"] = "Sound that is played when an enrage alert is triggered."
L2["Solo"] = true
L2["SOLOCHANNEL_DESC"] = "Pick the channel to send the message to when you are solo. (no group or raid, etc.)"
L2["In a Party"] = true
L2["PARTYCHANNEL_DESC"] = "Pick the channel to send the message to when you are in a party. (but not an arena)"
L2["In a Raid"] = true
L2["RAIDCHANNEL_DESC"] = "Pick the channel to send the message to when you are in a raid group. (but not a battleground)"
L2["In an Arena"] = true
L2["ARENACHANNEL_DESC"] = "Pick the channel to send the message to when you are in an arena."
L2["In a PvP Zone"] = true
L2["PVPCHANNEL_DESC"] = "Pick the channel to send the message to when you are in a battleground."
L2["Removable buffs display"] = true
L2["Enable display of removable buffs"] = true
L2["ENRAGEREMOVABLESDESC_ENABLE"] = "Turning this on will create a frame that contains any removable debuffs on your current target.  This is mainly useful for PvP / arenas."
L2["Only show when in a PvP zone or Arena"] = true
L2["ENRAGEREMOVABLESPVP_DESC"] = "Turning this on will only show the fram of removable target buffs if you are in a PvP zone or Arena."
L2["Show tips when hovering removable buffs"] = true
L2["ENRAGEREMOVABLESTIPS_DESC"] = "Display tooltips for hovered-over removable buffs.  This will make the removable buff frames non-click through."
L2["Removable buff's backdrop"] = true
L2["Removable buff's border"] = true

-- Crowd Control
L2["Crowd Control"] = true
L2["CC_DESC"] = "Crowd Control will track your break times on any mobs you have under a crowd control effect. (freezing trap, polymorph, wyvern sting, etc.)"
L2["Icon size"] = true
L2["Icon Backdrop"] = true
L2["Texture that gets used for the background."] = true
L2["Texture that gets used for the border."] = true
L2["Icon's Border"] = true
L2["Time text settings"] = true
L2["CCDESC_ENABLE"] = "Enable the crowd control tracking module."

-- Indicators
L2["Indicators"] = true
L2["INDICATORS_DESC"] = "Indicators are frames or notifications for abilities that need to be handled in special ways; for example, Hunter's Mark, Scare Beast, etc."
L2["INDICATORS_ENABLE"] = "Enable the indicators modules.  You can also enable or disable any sub-modules that you need or do not need."
L2["Hunter's Mark Indicator"] = true
L2["HM_INDICATOR_ENABLE"] = "Enable the indicator frame showing missing or near expiring Hunter's Mark on your target."
L2["Ignore Marked for Death"] = true
L2["HM_MFD_INDICATOR_ENABLE"] = "This will avoid showing any warning when the target has Marked for Death on it with any time remaining."
L2["Hunter's Mark Texture Coords"] = true
L2["Hunter's Mark size"] = true
L2["Hunter's Mark Backdrop"] = true
L2["Hunter's Mark Border"] = true
L2["Aspect size"] = true
L2["Aspect Texture Coords"] = true
L2["Aspect Backdrop"] = true
L2["Aspect Border"] = true
L2["Aspect Indicator"] = true
L2["ASPECT_INDICATOR_ENABLE"] = "Enable the indicator frame showing your current aspect.  This also add's sparkels to the aspect if you don't have one in combat or have pack/cheetah on."
L2["Only show no aspect"] = true
L2["ASPECT_ONLYMISSING_DESC"] = "This options will only display an aspect missing indicator as opposed to your current aspect (and missing)."
L2["Only show in combat"] = true
L2["ASPECT_ONLYCOMBAT_DESC"] = ""
L2["Scare Beast Indicator"] = true
L2["SCAREBEAST_INDICATOR_ENABLE"] = "Enable the indicator frame to show when scare beast is available."
L2["Scare Beast size"] = true
L2["Scare Beast Texture Coords"] = true
L2["Scare Beast Backdrop"] = true
L2["Scare Beast Border"] = true

-- Timers Sets
L2["Timers"] = true
L2["TIMERS_DESC"] = "Timers are used for tracking buffs, debuffs, cooldowns, trinkets or anythng else that can technically be \"timed\".  You can define multiple timer \"sets\" to hold different types of timers. A \"Set\" will create a movable bar object for the timers in the set."
L2["New timer set"] = true
L2["Creates a new timer set."] = true
L2["Remove timer set"] = true
L2["Removes a set of timers by name."] = true
L2["CONFIRM_NEWTIMERSET"] = "Create a new timer set named '%s'?"
L2["CONFIRM_DELETETIMERSET"] = "Delete the whole set of timers named '%s'?\n(This can not be undone!)"
L2["Invalid timer set name!"] = true
L2["You already have a set with that name!"] = true
L2["There is no timer set named '%s'!"] = true
L2["New timer set '%s' created."] = true
L2["Timer set '%s' deleted."] = true
L2["Timer Sets"] = true
L2["Add a new timer for this set"] = true
L2["ADDTIMER_CONFIRM"] = "Create a new timer object for this set of timers?"
L2["TIMERDESC_ENABLE"] = "Turn on or off this timer bar (set of timers).\nWhen off, the whole \"bar\" will not be created."
L2["Active Alpha"] = true
L2["ACTIVEALPHA_DESC"] = "Sets the alpha of this timer bar when something is actually active (there is a timer shown)."
L2["Inactive Alpha"] = true
L2["INACTIVEALPHA_DESC"] = "Sets the alpha of this timer bar when there is noting active (there is no timer to show)."
L2["Enable OOC Override"] = true
L2["ENABLEOOCOVERRIDE_DESC"] = "This overrides this timer bar's alpha to a defined value when Out of Combat (OOC)."
L2["OOC Alpha"] = true
L2["OOCALPHA_DESC"] = "This is the alpha setting for the bar when you enable 'OOC Override'."
L2["Enable Mount Override"] = true
L2["ENABLEMOUNTOVERRIDE_DESC"] = "This overrides this timer bar's alpha to a defined value when you are mounted."
L2["Mount Alpha"] = true
L2["MOUNTALPHA_DESC"] = "This is the alpha setting for the bar when you enable 'Mount Override'."
L2["Enable Dead Override"] = true
L2["ENABLEDEADOVERRIDE_DESC"] = "This overrides this timer bar's alpha to a defined value when you are dead or a ghost."
L2["Dead Alpha"] = true
L2["DEADALPHA_DESC"] = "This is the alpha setting for the bar when you enable 'Dead Override'."
L2["Set's orientation"] = true
L2["TIMERORIENTATION_DESC"] = "Do you want this timer set to be Horizontal or Vertical?"
L2["Reverse movement"] = true
L2["REVERSEDESC_ENABLE"] = "This makes timers move in the opposite direction (i.e. left to right instead of right to left on a horizontal set)"
L2["Delete this set"] = true
L2["DELETETIMERSET_CONFIRM"] = "This will delete the set and any timers it contains.  This can NOT be undone!"
			
L2["SPELLLICON_DESC"] = "If the icon appears as a '?', it just means it cannot be verified due to limitations in WoW."
L2["Enter a Spell Name or ID.."] = true
L2["SPELL_DESC"] = "Enter the EXACT name of the spell, buff, debuff, trinket proc, etc. to track."
L2["CHANGETOSPELL_CONFIRM"] = "You currently have an Item selected to track, do you want to change to a Spell instead?"
L2["TIMERSPELL_INVALID"] = "The spell you have entered is not valid!"
L2["TIMERSPELL_UNVERIFIED"] = "Spell name can not be verified because it's either spelled wrong or not one of your castable spells.  If you know the name is correct and you can not cast the spell, ignore this warning."
L2["..or an Item Name or ID"] = true
L2["ITEM_DESC"] = "Enter the EXACT name of the item to track. (i.e. 'Hearthstone' to track your hearth stone's cooldown)"
L2["CHANGETOITEM_CONFIRM"] = "You currently have a Spell selected to track, do you want to change to an Item instead?"
L2["TIMERITEM_INVALID"] = "The item you have entered is not valid!"
L2["TIMERITEM_UNVERIFIED"] = "Item name can not be verified because it's either spelled wrong or not in your inventory.  If you know the name is correct and you have the item elsewhere, ignore this warning."
L2["Check Target"] = true
L2["CHECKTARGET_DESC"] = "Select which unit or group of units to check for this spell."
L2["Duration or Cooldown"] = true
L2["DURORCD_DESC"] = "Specify if this timer should check for duration remaining or cooldown left."
L2["Owner of spell"] = true
L2["SPELLOWNER_DESC"] = "Specify who the spell must belong to in order to trigger the timer showing."
L2["Talent Spec"] = true
L2["TALENTSPEC_DESC"] = "Select what talent spec this timer should be used for. (i.e. You may not want a 'Beast Mastery' spell to be checked for when you are 'Marksmanship')"
L2["Any Spec"] = true
L2["Positon of timer text"] = true
L2["TIMERTEXTPOS_DESC"] = "Where should the duration/cooldown value be placed on this specific timer."
L2["None"] = true
L2["Flash when expiring"] = true
L2["EXPIREFLASH_ENABLE"] = "Should this object start to flash when it's about to expire?"
L2["Spin when expiring"] = true
L2["EXPIRESPIN_ENABLE"] = "Should this object start spinning when it's about to expire?"
L2["Grow when expiring"] = true
L2["EXPIREGROW_ENABLE"] = "Should this object start to grow when it's about to expire?"
L2["Grow start %"] = true
L2["GROWSTART_DESC"] = "How much of the cooldown or duration has to be left before the timer starts to Grow in size?"
L2["Grow size %"] = true
L2["GROWSIZE_DESC"] = "Size (in %) of original to grow up to?  (100% would be the current size, 200% would be double the current size)"
L2["Alpha Change"] = true
L2["EXPIREALPHA_ENABLE"] = "Should this timer have it's alpha modified as it moves along the bar? (This is the alpha for this timer, subject to current alpha of the timer set)"
L2["Alpha start %"] = true
L2["ALPHASTART_DESC"] = "What alpha value should this timer initially start at?"
L2["Alpha end %"] = true
L2["ALPHAEND_DESC"] = "What alpha value should this timer expire with?"
L2["Delete this timer"] = true
L2["DELETETIMER_CONFIRM"] = "Are you sure you want to delete this timer object?"

L2["Timer Set: %s"] = true
L2["TIMERSETSFRAME_DESC"] = "This is a timer set.  You can customize each set individually."
L2["Timer icon size"] = true

L2["Timer text settings"] = true
L2["Timer font"] = true
L2["Font Color"] = true
L2["Color used for the timer's font if set to static"] = true
L2["Static timer color"] = true
L2["STATICTIMERCOLOR_DESC"] = "This sets the color of the timer number to a static color or else the cooldown colors will be used based on time remaining"
L2["Color used for the text font shadow"] = true
L2["Stacks font"] = true
L2["This is the font used for stacks on the timers."] = true
L2["Stacks Font Color"] = true
L2["Color used for the timer's stacks font."] = true

L2["Texture Coords"] = true
L2["Alert Texture Coords"] = true
L2["Removables Texture Coords"] = true
L2["Enable TexCoords"] = true
L2["DESCTEXCOORDS_ENABLE"] = "This allows the texture (icon picture for example) to be cut from a section of the full texture."

-- Interrupts
L2["Interrupts"] = true
L2["INTERRUPTS_DESC"] = "This module contains any interrupt related items.  You can choose, for example, to announce what and when you interrupt a mob's spell cast."
L2["Announce interrupts to chat"] = true

-- Misdirection
L2["Threat Transfer"] = true
L2["THREATTRANSFER_DESC"] = "This module allows you to manage features available when you have an ability like Misdirection.  Right-click functionality and chat announces are options you can configure."
L2["Enable right-click casting on unit frames"] = true
L2["RIGHTCLICKMD_DESC"] = "This module will add right-click Misdirection to frames.\n\nNOTE: You will have to hold a modifier key (shift/alt/control) when you right-click to bring up the normal options menu - if the frame has one."
L2["Announce Misdirection Cast"] = true
L2["Announce the cast"] = true
L2["Announce the expire"] = true
L2["Whisper target when transferring"] = true
L2["Whisper target if they are mounted"] = true
L2["Frame Selection"] = true
L2["Target frame"] = true
L2["Pet frame"] = true
L2["Focus frame"] = true
L2["Party frames"] = true
L2["Party pet frames"] = true
L2["Raid frames"] = true
L2["Raid pet frames"] = true

-- Border Stuff
L2["Set's Border"] = true
L2["Timer's Border"] = true
L2["Border"] = true
L2["Border texture"] = true
L2["Border color"] = true
L2["Edge Size"] = true
L2["DESCEDGESIZE_ENABLE"] = "Control how large each copy of the edgeFile (border texture) becomes on-screen. (i.e. border thickness and corner size)"
L2["Texture that gets used for an individual timer's background."] = true

-- Backdrop stuff
L2["Set's Backdrop"] = true
L2["Timer's Backdrop"] = true
L2["Backdrop"] = true
L2["Backdrop texture"] = true
L2["Color the backdrop"] = true
L2["DESCBACKDROPCOLOR_ENABLE"] = "Do you want to apply custom coloring to the backdrop texture?"
L2["Backdrop color"] = true
L2["Tile the backdrop"] = true
L2["DESCBACKDROPTILE_ENABLE"] = "Should the backdrop texture be tiled or stretched."
L2["Tile Size"] = true
L2["DESCTILESIZE_ENABLE"] = "Control how large each copy of the background texture becomes on-screen when tiled."

L2["Duration"] = true
L2["Cooldown"] = true
L2["Out of Combat"] = true

-- Options panel (Profiles)
L2["Profiles"] = true

-- Icons
L2["Timer Icons"] = true
L2["Icon Block: %s"] = true
L2["ICONBLOCKSFRAME_DESC"] = "This is an icon block.  You can customize each block individually."
L2["Size of the icons"] = true
L2["Block's Backdrop"] = true
L2["Texture that gets used for the block's background."] = true
L2["Block's Border"] = true
L2["Color used for the stacks font."] = true
L2["Icon's Backdrop"] = true
L2["Icon's Border"] = true
L2["ICONS_DESC"] = "Icon Timers are a stationary version of the moving timers."
L2["New icon block"] = true
L2["Creates a new block of icons."] = true
L2["CONFIRM_NEWICONBLOCK"] = "Create a new icon block named '%s'?"
L2["Invalid icon block name!"] = true
L2["You already have a block with that name!"] = true
L2["New icon block '%s' created."] = true
L2["ICONDESC_ENABLE"] = "Turn on or off this icon block (set of icons).\nWhen off, the whole \"block\" will not be created."
L2["Add a new icon for this block"] = true
L2["ADDICON_CONFIRM"] = "Create a new icon object for this block of icons?"
L2["ACTIVEICONALPHA_DESC"] = "Sets the alpha of this icon block when something is actually active."
L2["INACTIVEICONALPHA_DESC"] = "Sets the alpha of this icon block when there is no icon in the block active."
L2["ENABLEICONOOCOVERRIDE_DESC"] = "This overrides this icon block's alpha to a defined value when Out of Combat (OOC)."
L2["ICONOOCALPHA_DESC"] = "This is the alpha setting for the block when you enable 'OOC Override'."
L2["ENABLEICONMOUNTOVERRIDE_DESC"] = "This overrides this icon block's alpha to a defined value when you are mounted."
L2["ICONMOUNTALPHA_DESC"] = "This is the alpha setting for the block when you enable 'Mount Override'."
L2["ENABLEICONDEADOVERRIDE_DESC"] = "This overrides this icon block's alpha to a defined value when you are dead or a ghost."
L2["ICONDEADALPHA_DESC"] = "This is the alpha setting for the block when you enable 'Dead Override'."
L2["Block's orientation"] = true
L2["BLOCKORIENTATION_DESC"] = "Do you want this icon block to be Horizontal or Vertical?"
L2["Reverse fill"] = true
L2["ICONREVERSEDESC_ENABLE"] = "This makes icons populate the block in the opposite direction (i.e. right to left instead of left to right on a horizontal block)"
L2["Delete this block"] = true
L2["DELETEICONBLOCK_CONFIRM"] = "This will delete the whole block and any icons it contains.  This can NOT be undone!"
L2["Icon block '%s' deleted."] = true
L2["Delete this icon"] = true
L2["DELETEICON_CONFIRM"] = "Are you sure you want to delete this icon object?"
L2["Position"] = true
L2["ICONPOSITION_DESC"] = "Sets the position from the start of the 1st icon being added to the block."

-- Alerts
L2["Alerts"] = true
L2["ALERTS_DESC"] = "Alerts are triggered events that will pop up a frame to show the trigger.  For example, you can set an alert to show you when your target casts a specific spell to know when to interrupt."
L2["New alert"] = true
L2["Creates a alert."] = true
L2["CONFIRM_NEWALERT"] = "Create a new alert named '%s'?"
L2["Invalid alert name!"] = true
L2["You already have an alert with that name!"] = true
L2["New alert '%s' created."] = true
L2["ALERTDESC_ENABLE"] = "Enable this alert."
L2["Delete this alert"] = true
L2["DELETEALERT_CONFIRM"] = "Are you sure you want to delete this alert?"
L2["Alert trigger"] = true
L2["ALERTTRIGGER_DESC"] = "Pick what to check in order to trigger this alert."
L2["Alert: %s"] = true
L2["ALERTFRAME_DESC"] = "This is an alert.  You can customize each alert individually."
L2["Size of the alert"] = true
L2["Add Sparkles"] = true
L2["Show Tooltip"] = true
L2["Stack text"] = true
L2["Alert's Backdrop"] = true
L2["Texture that gets used for the alert's background."] = true
L2["Alert's Border"] = true
L2["This is the font used for stacks on the alert."] = true

-- Stack stuff / Combo Points / Runic Power
L2["Stack Indicators"] = true
L2["ENERGYBARSTACKSDESC_ENABLE"] = "This enables showing marks to indicate current stacks on certain abilities (ex: Hunter - Marksman: Ready, Set, Aim... stacks)."
L2["ENERGYBARSTACKSEMBEDDESC_ENABLE"] = "If this is enabled, the stacks indicator will embed to the top right of the energy bar.\nYou can disable this to allow the stacks indicator to be moved freely."
L2["Reverse stacks"] = true
L2["ENERGYBARSTACKSREVERSEDESC_ENABLE"] = "Turning this option on will make the stacks fill in right to left as opposed to left to right."
L2["Stacks color"] = true
L2["Stack size"] = true
L2["ENERGYBARSTACKSIZE_DESC"] = "Set the size of the stacks (squared) when not embedded on the energy bar."
L2["Embed on bar"] = true
