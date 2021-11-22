fx_version 'adamant'

game 'gta5'

description 'Standalone Status'

version '1.0.0'

server_scripts {
	'@mysql-async/lib/MySQL.lua',
	'config.lua',
	'server/*.lua'
}

client_scripts {
	'config.lua',
	'client/classes/status.lua',
	'client/*.lua',
	'effect.lua',
}