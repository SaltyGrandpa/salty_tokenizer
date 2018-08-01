local waiting = false
local firstSpawn = true
local resourceNames = {}

RegisterNetEvent("salty_tokenizer:obfuscateReceived")
AddEventHandler("salty_tokenizer:obfuscateReceived", function(resource, name)
	resourceNames[resource] = name
	waiting = false
end)

function init()	
	Citizen.CreateThread(function()
		TriggerEvent('salty_tokenizer:clientReady')
	end)
	Citizen.CreateThread(function()
		Citizen.Wait(500)
		TriggerServerEvent('salty_tokenizer:playerSpawned')
	end)
end

AddEventHandler("playerSpawned", function()
	if firstSpawn then
		firstSpawn = false
		init()
	end
end)

function requestObfuscatedEventName(resource)
	if resourceNames[resource] == nil then
		TriggerServerEvent('salty_tokenizer:requestObfuscation', resource)
		waiting = true
		while waiting do
			Citizen.Wait(0)
		end
	end
	return resourceNames[resource]
end

function setupClientResource(resource)
	local tempToken = false
	RegisterNetEvent(requestObfuscatedEventName(resource))
	AddEventHandler(requestObfuscatedEventName(resource), function(token)
		tempToken = token
	end)
	while not tempToken do
		Citizen.Wait(0)
	end
	return tempToken
end
