Config = {}

Config.StatusMax      = 1000000
Config.TickTime       = 100000
Config.UpdateInterval = 150000

-- change to license: , if you are using licensed in identifier
Config.identifier = 'steam:' 

Config.register_status = {
'hunger',
'thirst',
'sanity',
'energy'
}

Config.status_start_value = { -- starting points for status
['hunger'] = 1000000,
['thirst'] = 1000000,
['sanity'] = 0, -- need to be a zero value
['energy'] = 1000000,
}