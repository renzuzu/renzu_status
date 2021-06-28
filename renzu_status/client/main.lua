local Status, isPaused = {}, false
local Statusregistered = false
RegisterNetEvent('playerSpawned')
AddEventHandler('playerSpawned', function(spawn)
	Citizen.Wait(500)
	TriggerServerEvent("esx_status:playerLoaded")	
end)

function GetStatusData(minimal)
	local status = {}

	for i=1, #Status, 1 do
		if minimal then
			table.insert(status, {
				name    = Status[i].name,
				val     = Status[i].val,
				percent = (Status[i].val / Config.StatusMax) * 100
			})
		else
			table.insert(status, {
				name    = Status[i].name,
				val     = Status[i].val,
				color   = Status[i].color,
				visible = Status[i].visible(Status[i]),
				max     = Status[i].max,
				percent = (Status[i].val / Config.StatusMax) * 100
			})
		end
	end

	return status
end

RegisterNetEvent('esx_status:registerStatus')
AddEventHandler('esx_status:registerStatus', function(name, default, color, visible, tickCallback)
	Statusregistered = false
	local status = CreateStatus(name, default, color, visible, tickCallback)
	table.insert(Status, status)
	Statusregistered = true
end)

RegisterNetEvent('esx_status:unregisterStatus')
AddEventHandler('esx_status:unregisterStatus', function(name)
	for k,v in ipairs(Status) do
		if v.name == name then
			table.remove(Status, k)
			break
		end
	end
end)

RegisterNetEvent('esx_status:load')
AddEventHandler('esx_status:load', function(status)
	while not Statusregistered do
		Wait(2000)
	end
	for i=1, #Status, 1 do
		for j=1, #status, 1 do
			if Status[i].name == status[j].name then
				Status[i].set(status[j].val)
			end
		end
	end
	CreateThread(function()
		while true do
			for i=1, #Status, 1 do
				Status[i].onTick()
				Wait(Config.TickTime)
			end
			Wait(Config.TickTime)
		end
	end)
end)

CreateThread(function()
	while not Statusregistered do
		Wait(2000)
	end
	while true do
		if Config.OnTick_Value_only then
			TriggerEvent('esx_status:onTick', GetStatus(Config.register_status))
		else
			TriggerEvent('esx_status:onTick', GetStatusData(true))
		end
		Wait(Config.TickTime)
	end
end)

RegisterNetEvent('esx_status:set')
AddEventHandler('esx_status:set', function(name, val)
	for i=1, #Status, 1 do
		if Status[i].name == name then
			Status[i].set(val)
			break
		end
	end
	TriggerServerEvent('esx_status:update', GetStatusData(true))
end)

RegisterNetEvent('esx_status:add')
AddEventHandler('esx_status:add', function(name, val)
	for i=1, #Status, 1 do
		if Status[i].name == name then
			Status[i].add(val)
			if Status[i].name == 'thirst' then
			TriggerEvent('renzu_shower:addpee', val / 3)
			end
			if Status[i].name == 'hunger' then
			TriggerEvent('renzu_shower:addpoo', val / 5)
			end
			break
		end
	end
	TriggerServerEvent('esx_status:update', GetStatusData(true))
end)

RegisterNetEvent('esx_status:remove')
AddEventHandler('esx_status:remove', function(name, val)
	for i=1, #Status, 1 do
		if Status[i].name == name then
			Status[i].remove(val)
			break
		end
	end
	TriggerServerEvent('esx_status:update', GetStatusData(true))
end)

AddEventHandler('esx_status:getStatus', function(name, cb)
	for i=1, #Status, 1 do
		if Status[i].name == name then
			cb(Status[i])
			return
		end
	end
end)

RegisterNetEvent('esx_status:getStatusm')
AddEventHandler('esx_status:getStatusm', function(table, cb)
	local multi = {}
	for i=1, #Status, 1 do
		for k,v in pairs(table) do
			if v == Status[i].name then
				multi[v] = Status[i]
			end
		end
	end
	cb(multi)
end)

function GetStatus(table)
	local multi = {}
	for i=1, #Status, 1 do
		for k,v in pairs(table) do
			if v == Status[i].name then
				multi[v] = Status[i].val
			end
		end
	end
	return multi
end

Citizen.CreateThread(function()
	Citizen.Wait(1000)
	exports('GetStatus', function(x)
		return GetStatus(x)
	end)
end)

-- Update server
Citizen.CreateThread(function()
	while not Statusregistered do
		Wait(2000)
	end
	while true do
		Citizen.Wait(Config.UpdateInterval)
		TriggerServerEvent('esx_status:update', GetStatusData(true))
	end
end)

RegisterNetEvent('esx_status:healPlayer')
AddEventHandler('esx_status:healPlayer', function()
	-- restore status 
	for k,v in pairs(Config.status_start_value) do
		TriggerEvent('esx_status:set', k, v)
	end
	-- restore hp
	local playerPed = PlayerPedId()
	SetEntityHealth(playerPed, GetEntityMaxHealth(playerPed))
end)