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

function generateToken()
	return string.random(Config.TokenLength, Config.TokenCharset)
end

RegisterNetEvent('salty_tokenizer:playerSpawned')
AddEventHandler('salty_tokenizer:playerSpawned', function()
	local _source = source
	if not didPlayerLoad[_source] then
		didPlayerLoad[_source] = true
		TriggerEvent('salty_tokenizer:playerLoaded', _source)
	else
		print(tostring(_source) .. " requested another security token, hacker??")
	end
end)

function setupServerResource(resource)
	resourceTokens[resource] = generateToken()
	AddEventHandler('salty_tokenizer:playerLoaded', function(player)
		local _source = player
		TriggerClientEvent(getObfuscatedEvent(_source, resource), _source, resourceTokens[resource])
	end)
end

function secureServerEvent(resource, player, token)
	local _source = player
	if token ~= resourceTokens[resource] then
		DropPlayer(_source, Config.KickMessage)
		return false
	end
	return true
end

function getObfuscatedEvent(source, resourceName)
	if resourceNames[source][resourceName] == nil then
		resourceNames[source][resourceName] = generateToken()
	end
	return(resourceNames[source][resourceName])
end

RegisterNetEvent('salty_tokenizer:requestObfuscation')
AddEventHandler('salty_tokenizer:requestObfuscation', function(resourceName)
	local _source = source
	TriggerClientEvent('salty_tokenizer:obfuscateReceived', _source, resourceName, getObfuscatedEvent(_source, resourceName))
end)

function init()
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
    didPlayerLoad[_source] = false
	resourceNames[_source] = {}
end)
