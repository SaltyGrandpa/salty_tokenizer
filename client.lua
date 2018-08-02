local firstSpawn = true
local resourceNames = {}
--[[ Structure:
	['resourceName'] = { id = int, name = string },
	['resourceName'] = { id = int, name = string },
]]

RegisterNetEvent("salty_tokenizer:obfuscateReceived")
AddEventHandler("salty_tokenizer:obfuscateReceived", function(id, name)
	for resource,property in pairs(resourceNames) do
		if property.id == id then
			property.name = name
			break
		end
	end
end)

function init()	
	if Config.VerboseClient then
		print("> > > S A L T Y _ T O K E N I Z E R  < < <")
	end
	math.randomseed(GetClockHours() + GetClockMinutes())
	Citizen.CreateThread(function()
		TriggerEvent('salty_tokenizer:clientReady')
	end)
	Citizen.CreateThread(function()
		Citizen.Wait(Config.ClientDelay)
		TriggerServerEvent('salty_tokenizer:playerSpawned')
	end)
end

AddEventHandler("playerSpawned", function()
	if firstSpawn then
		firstSpawn = false
		init()
	end
end)

function validId(id)
	if #resourceNames > 0 then
		for resource,property in pairs(resourceNames) do
			if property.id == id then
				return false
			end
		end
	end
	return true
end

function generateId()
	local id = math.random(1,100000)
	while not validId(id) do
		id = math.random(1,100000)
		if Config.VerboseClient then
			print("ID Collision, Generating New ID")
		end
	end
	return id
end

function requestObfuscatedEventName(resource)
	if resourceNames[resource] == nil then
		resourceNames[resource] = { id = generateId(), name = false }
		TriggerServerEvent('salty_tokenizer:requestObfuscation', resource, resourceNames[resource].id)
		while not resourceNames[resource].name do
			Citizen.Wait(0)
		end
	end
	return resourceNames[resource].name
end

function setupClientResource(resource)
	local token = false
	if Config.VerboseClient then
		print("Deploying Obfuscated Event: " .. tostring(resource) .. " = " .. tostring(requestObfuscatedEventName(resource)))
	end
	RegisterNetEvent(requestObfuscatedEventName(resource))
	AddEventHandler(requestObfuscatedEventName(resource), function(tokenReceived)
		token = tokenReceived
		if Config.VerboseClient then
			print("Obfuscated Event Token Received: " .. tostring(resource) .. " (" .. tostring(requestObfuscatedEventName(resource)) .. "), Token: " .. tostring(token))
		end
	end)
	while not token do
		Citizen.Wait(0)
	end
	return token
end
