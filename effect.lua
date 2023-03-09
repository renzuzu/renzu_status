Citizen.CreateThread(function()
	Wait(3000)
	for k,v in pairs(Config.register_status) do
		TriggerEvent('esx_status:registerStatus', v, Config.status_start_value[v], '#CFAD0F', function(status)
			return true
			end, function(status)
			status.remove(100)
		end)
	end
	
	if Config.UseEffects then
		local crazy = false
		Citizen.CreateThread(function()
			Citizen.Wait(1000)
			local qbcore = GetResourceState('qb-core') == 'started'
			while true do
				--collectgarbage()
				local playerPed  = PlayerPedId()
				local prevHealth = GetEntityHealth(playerPed)
				local health     = prevHealth
				local fetch = false
				stress = 0
				thirst = 0
				hunger = 0
				energy = -1
				local status = GetStatus(Config.register_status)
				for k,v in pairs(status) do
					Wait(100)
					if k == 'thirst' then
						thirst = v / 10000
					end
					if k == 'stress' then
						stress = v / 10000
					end
					if k == 'energy' then
						energy = v / 10000
					end
					if k == 'hunger' then
						hunger = v / 10000
					end
				end
				if hunger <= 0 then
					if prevHealth <= 150 then
						health = health - 60
					else
						health = health - 60
					end
				end

				if thirst <= 0 then
					if prevHealth <= 150 then
						health = health - 60
					else
						health = health - 60
					end
				end
				
				if hunger < 5 then
					TriggerEvent('esx_status:add', 'stress', 150000)
				end
				
				if enery ~= -1 and energy < 5 and not antok then
					antok = true
					TriggerEvent('esx_basicneeds:antok')
				end
				TriggerEvent('esx_status:remove', 'energy', 3)

				
				if not qbcore and stress >= 98 and not crazy then
					TriggerEvent('esx_basicneeds:sanityeffect')
					--TriggerServerEvent("Server:SoundToClient", NetworkGetNetworkIdFromEntity(GetPlayerPed(-1)),"crazy", 1.00)
					crazy = true
					SetPedIsDrunk(playerPed, true)
				elseif not qbcore and stress < 20 then
					crazy = false
					SetPedIsDrunk(playerPed, false)
				end

				if not qbcore and health ~= prevHealth then
					SetEntityHealth(playerPed, health)
				end
				Citizen.Wait(10000)
			end
		end)



		function LoadAnim(animDict)
			RequestAnimDict(animDict)
			while not HasAnimDictLoaded(animDict) do
				Citizen.Wait(10)
			end
		end

		function Makeloading(msg,ms)
			BusyspinnerOff()
			Wait(10)
			AddTextEntry("CUSTOMLOADSTR", msg)
			BeginTextCommandBusyspinnerOn("CUSTOMLOADSTR")
			EndTextCommandBusyspinnerOn(4)
			Citizen.CreateThread(function()
				Citizen.Wait(ms)
				BusyspinnerOff()
			end)
		end

		RegisterNetEvent('esx_basicneeds:sanityeffect')
		AddEventHandler('esx_basicneeds:sanityeffect', function(cb)
			Citizen.CreateThread(function()
				StartScreenEffect('PeyoteEndOut', 0, true)
				StartScreenEffect('Dont_tazeme_bro', 0, true)
				StartScreenEffect('MP_race_crash', 0, true)
				TaskWanderStandard(GetPlayerPed(-1), 10.0,10)
				local count = 0
				while not IsEntityDead(GetPlayerPed(-1)) and crazy and count < 5000 do
					DisableAllControlActions(0)
					count = count + 1
					--print(count)
					Citizen.Wait(1)
				end
				print("test")
				TriggerEvent('esx_status:remove', 'sanity', 400000)
				ClearPedTasksImmediately(GetPlayerPed(-1))
				StopScreenEffect('PeyoteEndOut')
				StopScreenEffect('Dont_tazeme_bro')
				StopScreenEffect('MP_race_crash')
				crazy = false
			end)
		end)

		RegisterNetEvent('esx_basicneeds:antok')
		AddEventHandler('esx_basicneeds:antok', function(cb)
			Citizen.CreateThread(function()
				DoScreenFadeOut(100)
				StartScreenEffect('DeathFailOut', 0, true)
				SetTimecycleModifier("hud_def_blur")
				SetCurrentPedWeapon(playerPed, GetHashKey('WEAPON_UNARMED'), true)
				Citizen.Wait(1000)
				ShakeGameplayCam("SMALL_EXPLOSION_SHAKE", 1.0)
				DoScreenFadeIn(1000)
				Citizen.Wait(1000)
				DoScreenFadeOut(100)
				Citizen.Wait(750)
				ShakeGameplayCam("SMALL_EXPLOSION_SHAKE", 1.0)
				DoScreenFadeIn(750)
				Citizen.Wait(750)
				DoScreenFadeOut(100)
				Citizen.Wait(500)
				ShakeGameplayCam("SMALL_EXPLOSION_SHAKE", 1.0)
				DoScreenFadeIn(500)
				Citizen.Wait(500)
				DoScreenFadeOut(100)
				Citizen.Wait(250)
				StopScreenEffect('DeathFailOut')
				DoScreenFadeIn(250)
				--injuredTime = math.min(20, math.floor(damage / 20 + 0.5))
				Citizen.InvokeNative(0xE036A705F989E049)
				local lib, anim = 'misscarsteal4@actor', 'stumble' -- TODO better animations
				local playerPed = PlayerPedId()
				LoadAnim(lib)
				TaskPlayAnim(playerPed, lib, anim, 8.0, -8.0, 4000, 0, 0, false, false, false)
				Makeloading('You are out of energy and sleepy',4000)
				--exports['progressBars']:startUI(4000, 'You are out of energy and sleepy')
				Citizen.Wait(500)
					while IsEntityPlayingAnim(playerPed, lib, anim, 3) do
					Citizen.Wait(0)
					DisableAllControlActions(0)
				end
				Makeloading('You have passed out',1000)
				local lib2, anim2 = 'missarmenian2', 'corpse_search_exit_ped' -- TODO better animations
				LoadAnim(lib2)
				TaskPlayAnim(playerPed, lib2, anim2, 8.0, -8.0, 11000, 0, 0, false, false, false)
				--exports['progressBars']:startUI(9000, 'Taking a Nap')
				Makeloading('Taking a Nap',9000)
				Citizen.Wait(500)
				while IsEntityPlayingAnim(playerPed, lib2, anim2, 3) do
					DoScreenFadeOut(10000)
					Citizen.Wait(0)
					DisableAllControlActions(0)
				end
				StopScreenEffect('DeathFailOut')
				DoScreenFadeIn(250)
				ClearTimecycleModifier()
				StopGameplayCamShaking(true)
				ResetPedMovementClipset(playerPed, 0.0)
				isBlackedOut = false
				TriggerEvent('esx_status:add', 'energy', 700000)
				antok = false
			end)
		end)
	end
end)