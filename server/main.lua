player = {}
charslot = {}
function SQLQuery(plugin,type,query,var)
	local wait = promise.new()
    if type == 'fetchAll' and plugin == 'mysql-async' then
		MySQL.query(query, var, function(result)
            wait:resolve(result)
        end)
    end
    if type == 'execute' and plugin == 'mysql-async' then
        MySQL.Async.execute(query, var, function(result)
            wait:resolve(result)
        end)
    end
    if type == 'execute' and plugin == 'ghmattisql' then
        exports['ghmattimysql']:execute(query, var, function(result)
            wait:resolve(result)
        end)
    end
    if type == 'fetchAll' and plugin == 'ghmattisql' then
        exports.ghmattimysql:execute(query, var, function(result)
            wait:resolve(result)
        end)
    end
    if type == 'execute' and plugin == 'oxmysql' then
        exports.oxmysql:query(query, var, function(result)
            wait:resolve(result)
        end)
    end
    if type == 'fetchAll' and plugin == 'oxmysql' then
		exports['oxmysql']:query(query, var, function(result)
			wait:resolve(result)
		end)
    end
	return Citizen.Await(wait)
end
Citizen.CreateThread(function()
	Wait(1000)
	SQLQuery(Config.Mysql,'execute',[[
		CREATE TABLE IF NOT EXISTS `status` (
			`status` LONGTEXT NULL COLLATE 'utf8mb4_general_ci',
			`identifier` VARCHAR(64) NOT NULL DEFAULT '' COLLATE 'utf8mb4_general_ci',
			PRIMARY KEY (`identifier`) USING BTREE
		)
		COLLATE='utf8mb4_general_ci'
		ENGINE=InnoDB
		;
	]], {})
end)
status_set = function(k, v, source)
	player[source].val = v
end

statusget = function(source)
	return player[source].val
end

statusset = function(val,source)
	if player[source] ~= nil then
		player[source].val = val
	end
end

statusadd = function(val,source)
	if player[source].val + val > Config.StatusMax then
		player[source].val = Config.StatusMax
	else
		player[source].val = player[source].val + val
	end
end

statusremove = function(val,source)
	if player[source].val - val < 0 then
		player[source].val = 0
	else
		player[source].val = player[source].val - (val * 70)
	end
end

statusgetPercent = function(source)
	return (player[source].val / Config.StatusMax) * 100
end

statusupdateClient = function(source)
	TriggerEvent('standalone_status:updateClient', source)
end

function getStatus(source)
	local source = tonumber(source)
	if player[source] == nil then
		player[source] = {}
		if Config.multichar and Config.multichar_advanced then
			while charslot[source] == nil do
				Wait(500)
			end
		end
		identifier = GetSteam(source)
		if identifier ~= nil then
			local result = MySQL.scalar.await('SELECT * FROM status WHERE identifier = ?', {identifier})
			if not result then
				SQLQuery(Config.Mysql,'execute',"INSERT INTO status (status, identifier) VALUES (?,?)", {'[]',identifier})
			end
			local data = {}

			if result and result[1] and result[1].status then
				data = json.decode(result[1].status)
				statusset(data, source)
				TriggerClientEvent('esx_status:load', source, data)
			end
		end
	end
end

RegisterServerEvent('esx_status:playerLoaded')
AddEventHandler('esx_status:playerLoaded', function(status)
	local source = source
	print("PLAYERLOADED")
	Wait(2000)
	getStatus(source)
end)

RegisterServerEvent('playerDropped')
AddEventHandler('playerDropped', function()
	local identifier = GetSteam(tonumber(source))
	local status = statusget(tonumber(source))

	SQLQuery(Config.Mysql,'execute',"UPDATE status SET status = @status WHERE identifier = @identifier", {
		['@status']     = json.encode(status),
		['@identifier'] = identifier
	})
end)

RegisterServerEvent('esx_status:getStatus')
AddEventHandler('esx_status:getStatus', function(playerId, statusName, cb)
	local identifier = GetSteam(tonumber(source))
	local status  = statusget(tonumber(source))

	for i=1, #status, 1 do
		if status[i].name == statusName then
			cb(status[i])
			break
		end
	end
end)

RegisterServerEvent('esx_status:update')
AddEventHandler('esx_status:update', function(status)
	local source = tonumber(source)
	statusset(status,tonumber(source))
end)

function SaveData()
	local playerList = {}
	for i=0, GetNumPlayerIndices()-1 do
		local source = GetPlayerFromIndex(i)
		getStatus(tonumber(source))
		local status  = statusget(tonumber(source))
		if GetPlayerPed(source) ~= 0 and status ~= 'null' and status ~= nil and status ~= '[]' then
			SQLQuery(Config.Mysql,'execute',"UPDATE status SET status = @status WHERE identifier = @identifier", {
				['@status']     = json.encode(status),
				['@identifier'] = GetSteam(tonumber(source))
			})
		end
	end
	SetTimeout(Config.SaveDelay, SaveData)
end

RegisterServerEvent(Config.characterchosenevent)
AddEventHandler(Config.characterchosenevent, function(charid, ischar)
    local source = tonumber(source)
    charslot[source] = charid
end)

function GetSteam(source)
	local source = tonumber(source)
	for k, v in ipairs(GetPlayerIdentifiers(source)) do
		if string.match(v, Config.identifier) then
			license = v
			break
		end
	end
	if Config.multichar and Config.multichar_advanced and charslot[source] ~= nil then
		license = string.gsub(license, "steam", ""..Config.charprefix..""..charslot[source].."")
	end
	return license
end

if Config.SaveLoop then
	CreateThread(function()
		Wait(2000)
		SaveData()
	end)
end

function havePermission(i)
	for k,v in pairs(Config.Admins) do
		if v == i then
		return true
		end
	end
	return false
end

RegisterCommand("heal", function(source, args, rawCommand)
	if source ~= 0 then
		if havePermission(GetPlayerIdentifier(source, 0)) then
			if args[1] then
				local playerId = tonumber(args[1])
				if GetPlayerName(playerId) then
					print(('esx_basicneeds: %s healed %s'):format(GetPlayerIdentifier(source, 0), GetPlayerIdentifier(playerId, 0)))
					TriggerClientEvent('esx_status:healPlayer', playerId)
					TriggerClientEvent('chat:addMessage', source, { args = { '^5HEAL', 'You have been healed.' } })
				else
					TriggerClientEvent('chat:addMessage', source, { args = { '^1SYSTEM', 'Player not online.' } })
				end
			else
				print(('esx_status: %s healed self'):format(GetPlayerIdentifier(source, 0)))
				TriggerClientEvent('esx_status:healPlayer', source)
			end
		end
	end
end, false)
