# Renzu Status
THIS IS CREATED BASED ON ESX STATUS
COPYRIGHT TO ESX STATUS CREATOR

Standalone Status Created for Renzu Hud Status Function
This version doesnt have a UI

# esx_status
Standalone Framework FIVEM Status
[INSTALLATION]

1) CD in your resources/[esx] folder
2) Clone the repository
```
git clone https://github.com/renzuzu/renzu_status/ renzu_status
```
3) Import esx_status.sql in your database
4) Add this in your server.cfg :

```
start standalone_status
```

[HOWTO]
Register Status :
```lua

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


```
