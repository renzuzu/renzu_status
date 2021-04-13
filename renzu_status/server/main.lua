player = {}

status_set = function(k, v, source)
	player[source].val = v
end

statusget = function(source)
	return player[source].val
end

statusset = function(val,source)
	player[source].val = val
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

RegisterServerEvent('esx_status:playerLoaded')
AddEventHandler('esx_status:playerLoaded', function(status)
	local source = source
	if player[source] == nil then
	player[source] = {}
	end
	for k, v in ipairs(GetPlayerIdentifiers(source)) do
		if string.match(v, Config.identifier) then
			license = v
			break
		end
	end
	local identifier = string.gsub(license, "steam", "Char1")
	--local identifier = license
	print(identifier)
	MySQL.Async.fetchAll('SELECT status FROM users WHERE identifier = @identifier', {
		['@identifier'] = identifier
	}, function(result)
		local data = {}

		if result[1].status then
			data = json.decode(result[1].status)
		end
		statusset(data, source)
		TriggerClientEvent('esx_status:load', source, data)
	end)
end)

RegisterServerEvent('playerDropped')
AddEventHandler('playerDropped', function()
	for k, v in ipairs(GetPlayerIdentifiers(source)) do
		if string.match(v, Config.identifier) then
			license = v
			break
		end
	end
	local identifier = license
	local status = statusget(source)

	MySQL.Async.execute('UPDATE users SET status = @status WHERE identifier = @identifier', {
		['@status']     = json.encode(status),
		['@identifier'] = identifier
	})
end)

RegisterServerEvent('esx_status:getStatus')
AddEventHandler('esx_status:getStatus', function(playerId, statusName, cb)
	for k, v in ipairs(GetPlayerIdentifiers(source)) do
		if string.match(v, Config.identifier) then
			license = v
			break
		end
	end
	local identifier = license
	local status  = statusget(source)

	for i=1, #status, 1 do
		if status[i].name == statusName then
			cb(status[i])
			break
		end
	end
end)

RegisterServerEvent('esx_status:update')
AddEventHandler('esx_status:update', function(status)
	statusset(status,source)
end)

function Getplayer(source)
	for k, v in ipairs(GetPlayerIdentifiers(source)) do
		if string.match(v, Config.identifier) then
			license = v
			return {source = source, identifier = license}
		end
	end
end

function getidentifier(source)
	for k, v in ipairs(GetPlayerIdentifiers(source)) do
		if string.match(v, Config.identifier) then
			license = v
			return license
		end
	end
end

function SaveData()
	local playerList = {}
	for i=0, GetNumPlayerIndices()-1 do
		local source = GetPlayerFromIndex(i)
		local status  = statusget(source)
		MySQL.Async.execute('UPDATE users SET status = @status WHERE identifier = @identifier', {
			['@status']     = json.encode(status),
			['@identifier'] = getidentifier(source)
		})
	end
	SetTimeout(10 * 60 * 1000, SaveData)
end

--SaveData()
