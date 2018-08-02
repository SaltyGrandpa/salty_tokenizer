local didPlayerLoad = {}
local resourceNames = {}
local resourceTokens = {}

for Loop = 1, 64 do
	didPlayerLoad[Loop] = false
	resourceNames[Loop] = {}
end

local Chars = {}
for Loop = 0, 255 do
	Chars[Loop+1] = string.char(Loop)
end
local String = table.concat(Chars)

local Built = {['.'] = Chars}

local AddLookup = function(CharSet)
	local Substitute = string.gsub(String, '[^'..CharSet..']', '')
	local Lookup = {}
	for Loop = 1, string.len(Substitute) do
		Lookup[Loop] = string.sub(Substitute, Loop, Loop)
	end
	Built[CharSet] = Lookup

	return Lookup
end

function string.random(Length, CharSet)
	local CharSet = CharSet or '.'
	if CharSet == '' then
		return ''
	else
		local Result = {}
		local Lookup = Built[CharSet] or AddLookup(CharSet)
		local Range = #Lookup

		for Loop = 1,Length do
			Result[Loop] = Lookup[math.random(1, Range)]
		end

		return table.concat(Result)
	end
end

function isTokenUnique(token)
	for i=1, #resourceNames, 1 do
		for id,resource in pairs(resourceNames[i]) do
            if resource == token then
				if Config.VerboseServer then
					print("Token collision, generating new token.")
				end
				return false
			end
        end
	end
	for resource,storedToken in pairs(resourceTokens) do
		if storedToken == token then
			if Config.VerboseServer then
				print("Token collision, generating new token.")
			end
			return false
		end
	end
	return true
end

function generateToken()
	local token = string.random(Config.TokenLength, Config.TokenCharset)
	while not isTokenUnique(token) do
		token = string.random(Config.TokenLength, Config.TokenCharset)
	end
	return string.random(Config.TokenLength, Config.TokenCharset)
end

RegisterNetEvent('salty_tokenizer:playerSpawned')
AddEventHandler('salty_tokenizer:playerSpawned', function()
	local _source = source
	if not didPlayerLoad[_source] then
		didPlayerLoad[_source] = true
		if Config.VerboseServer then
			print("Player ID " .. tostring(_source) .. " loaded.")
		end
		TriggerEvent('salty_tokenizer:playerLoaded', _source)
	else
		print(tostring(_source) .. " requested another security token, hacker??")
	end
end)

function setupServerResource(resource)
	resourceTokens[resource] = generateToken()
	if Config.VerboseServer then
		print("Generated token for resource " .. tostring(resource) .. ": " .. tostring(resourceTokens[resource]))
	end
	AddEventHandler('salty_tokenizer:playerLoaded', function(player)
		local _source = player
		if Config.VerboseServer then
			print("Sending token for " .. tostring(resource) .. " (Event: " .. tostring(getObfuscatedEvent(_source, resource)) .. " Token: " .. tostring(resourceTokens[resource]) .. ") to Player ID " .. tostring(_source) .. ".")
		end
		TriggerClientEvent(getObfuscatedEvent(_source, resource), _source, resourceTokens[resource])
	end)
end

function secureServerEvent(resource, player, token)
	local _source = player
	if Config.VerboseServer then
		print("Validating token for " .. tostring(resource) .. " for Player ID " .. tostring(_source) .. ". Provided: " .. tostring(token) .. " Stored: " .. tostring(resourceTokens[resource]))
	end
	if token ~= resourceTokens[resource] then
		DropPlayer(_source, Config.KickMessage)
		return false
	end
	return true
end

function getObfuscatedEvent(source, resourceName)
	if resourceNames[source][resourceName] == nil then
		resourceNames[source][resourceName] = generateToken()
		if Config.VerboseServer then
			print("Obfuscated Event for Player ID " .. tostring(source) .. ": Original - " .. tostring(resourceName) .. " Obfuscated - "  .. tostring(resourceNames[source][resourceName]))
		end
	end
	return(resourceNames[source][resourceName])
end

RegisterNetEvent('salty_tokenizer:requestObfuscation')
AddEventHandler('salty_tokenizer:requestObfuscation', function(resourceName, id)
	local _source = source
	TriggerClientEvent('salty_tokenizer:obfuscateReceived', _source, id, getObfuscatedEvent(_source, resourceName))
end)

function init()
	if Config.VerboseServer then
		print("> > > S A L T Y _ T O K E N I Z E R  < < <")
	end
	math.randomseed(os.time())
	TriggerEvent('salty_tokenizer:serverReady')
end

AddEventHandler('onServerResourceStart', function (resource)
    if resource == GetCurrentResourceName() then
        init()
    end
end)

AddEventHandler("playerDropped", function(player, reason)
	local _source = source
	if Config.VerboseServer then
		print("Player ID " .. tostring(_source) .. " dropped, purged obfuscated events.")
	end
    didPlayerLoad[_source] = false
	resourceNames[_source] = {}
end)
