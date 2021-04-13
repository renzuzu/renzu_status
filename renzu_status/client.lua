local Keys = {
	["ESC"] = 322, ["F1"] = 288, ["F2"] = 289, ["F3"] = 170, ["F5"] = 166, ["F6"] = 167, ["F7"] = 168, ["F8"] = 169, ["F9"] = 56, ["F10"] = 57, 
	["~"] = 243, ["1"] = 157, ["2"] = 158, ["3"] = 160, ["4"] = 164, ["5"] = 165, ["6"] = 159, ["7"] = 161, ["8"] = 162, ["9"] = 163, ["-"] = 84, ["="] = 83, ["BACKSPACE"] = 177, 
	["TAB"] = 37, ["Q"] = 44, ["W"] = 32, ["E"] = 38, ["R"] = 45, ["T"] = 245, ["Y"] = 246, ["U"] = 303, ["P"] = 199, ["["] = 39, ["]"] = 40, ["ENTER"] = 18,
	["CAPS"] = 137, ["A"] = 34, ["S"] = 8, ["D"] = 9, ["F"] = 23, ["G"] = 47, ["H"] = 74, ["K"] = 311, ["L"] = 182,
	["LEFTSHIFT"] = 21, ["Z"] = 20, ["X"] = 73, ["C"] = 26, ["V"] = 0, ["B"] = 29, ["N"] = 249, ["M"] = 244, [","] = 82, ["."] = 81,
	["LEFTCTRL"] = 36, ["LEFTALT"] = 19, ["SPACE"] = 22, ["RIGHTCTRL"] = 70, 
	["HOME"] = 213, ["PAGEUP"] = 10, ["PAGEDOWN"] = 11, ["DELETE"] = 178,
	["LEFT"] = 174, ["RIGHT"] = 175, ["TOP"] = 27, ["DOWN"] = 173,
	["NENTER"] = 201, ["N4"] = 108, ["N5"] = 60, ["N6"] = 107, ["N+"] = 96, ["N-"] = 97, ["N7"] = 117, ["N8"] = 61, ["N9"] = 118
}
local current = 0;
local ESX = nil

Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end
	TriggerEvent('es:setMoneyDisplay', 0.0)
	ESX.UI.HUD.SetDisplay(0.0)
end)

Citizen.CreateThread(function()
	if (Config.HideOnHidedRadar) then
		while true do
			Citizen.Wait(0)
			if (IsRadarEnabled()) then
				SendNUIMessage({action = "toggle", show = true})
			else
				SendNUIMessage({action = "toggle", show = false})
			end
		end
	end
end)

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer) 
	local data = xPlayer
	local accounts = data.accounts
	for k, v in pairs(accounts) do
		local account = v
		if account.name == "bank" then
			SendNUIMessage({action = "setValue", key = "bankmoney", value = "$" .. account.money})
		elseif account.name == "black_money" then
			SendNUIMessage({action = "setValue", key = "dirtymoney", value = "$" .. account.money})
		end
	end
	SendNUIMessage({action = "setValue", key = "job", value = data.job.label .. " - " .. data.job.grade_label})
	SendNUIMessage({action = "setValue", key = "money", value = "$" .. data.money})
end)

RegisterNetEvent('esx:setAccountMoney')
AddEventHandler('esx:setAccountMoney', function(account)
	if account.name == "bank" then
		SendNUIMessage({action = "setValue", key = "bankmoney", value = "$" .. account.money})
	elseif account.name == "black_money" then
		SendNUIMessage({action = "setValue", key = "dirtymoney", value = "$" .. account.money})
	end
end)

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
	SendNUIMessage({action = "setValue", key = "job", value = job.label .. " - " .. job.grade_label})
end)

RegisterNetEvent('es:activateMoney')
AddEventHandler('es:activateMoney', function(e)
	SendNUIMessage({action = "setValue", key = "money", value = "$" .. e})
end)

RegisterNetEvent('esx_status:onTick')
AddEventHandler('esx_status:onTick', function(status)
	SendNUIMessage({action = "updateStatus", status = status})
end)

AddEventHandler('onClientMapStart', function()
	if current == 0 then
		NetworkSetTalkerProximity(Config.VoiceDefaultProximity)
	elseif current == 1 then
		NetworkSetTalkerProximity(Config.VoiceShoutProximity)
	elseif current == 2 then
		NetworkSetTalkerProximity(Config.VoiceWhisperProximity)
	end
end)

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(1)
		if IsControlPressed(1, Keys['LEFTSHIFT']) and IsControlJustPressed(1, Keys['H']) then
			current = (current + 1) % 3
			if current == 0 then
				NetworkSetTalkerProximity(Config.VoiceDefaultProximity)
			elseif current == 1 then
				NetworkSetTalkerProximity(Config.VoiceShoutProximity)
			elseif current == 2 then
				NetworkSetTalkerProximity(Config.VoiceWhisperProximity)
			end
		end
		if current == 0 then
			SendNUIMessage({action = "setProximity", value = "normal"})
		elseif current == 1 then
			SendNUIMessage({action = "setProximity", value = "shout"})
		elseif current == 2 then
			SendNUIMessage({action = "setProximity", value = "whisper"})
		end
		if NetworkIsPlayerTalking(PlayerId()) then
			SendNUIMessage({action = "setTalking", value = true})
		elseif not NetworkIsPlayerTalking(PlayerId()) then
			SendNUIMessage({action = "setTalking", value = false})
		end
	end
end)
