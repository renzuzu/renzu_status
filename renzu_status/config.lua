Config = {}

Config.StatusMax      = 1000000
Config.TickTime       = 4000
Config.UpdateInterval = 4500
Config.SaveDelay = 5000
Config.OnTick_Value_only = true -- more optimized if you want to get value only
Config.SaveLoop = true -- save every SaveDelay
Config.Multiplier = 5.0 -- multiplier value of remove value for status
-- change to license: , if you are using licensed in identifier
Config.identifier = 'steam:' 
Config.multichar = false -- KASHACTERS, cd_multicharacter, etc...
--IMPORTANT PART IF USING Multicharacter
-- if multichar_advanced is false == using steam: format or the config.identifier
Config.multichar_advanced = true -- Using Permanent Char1,Char2 up to Char5 identifier from database. ( This means the identifier reads by ESX or other framework will have Char1:BLAHBLAHBLAH instead of steam:BLAHBLAHBLAH ( from xPlayer.identifier for example))
Config.characterchosenevent = 'kashactersS:CharacterChosen' -- this event contains charid (IMPORTANT and will read only if using advanced)
Config.charprefix = 'Char' -- dont change unless you know what you are doing
Config.register_status = {
'hunger',
'thirst',
'sanity',
'energy'
}
Config.UseEffects = true -- use effects from effect.lua

Config.status_start_value = { -- starting points for status
['hunger'] = 1000000,
['thirst'] = 1000000,
['sanity'] = 0, -- need to be a zero value
['energy'] = 1000000,
}

Config.Admins = {
    'steam:11000013ec77a2e',
}