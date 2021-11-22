ESX = nil
TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
if ESX then
	ESX.RegisterUsableItem('bread', function(source)
		local xPlayer = ESX.GetPlayerFromId(source)
		xPlayer.removeInventoryItem('bread', 1)

		TriggerClientEvent('esx_status:add', source, 'hunger', 200000)
		TriggerClientEvent('esx_basicneeds:onEat', source)
		xPlayer.showNotification('You eat a bread')
	end)

	ESX.RegisterUsableItem('water', function(source)
		local xPlayer = ESX.GetPlayerFromId(source)
		xPlayer.removeInventoryItem('water', 1)

		TriggerClientEvent('esx_status:add', source, 'thirst', 200000)
		TriggerClientEvent('esx_basicneeds:onDrink', source)
		xPlayer.showNotification('you drink a water')
	end)
end