local tokenRequested = {}
for Loop = 1, 64 do
	tokenRequested[Loop] = false
end
local securityToken = false

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
	math.randomseed(os.time())
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
	securityToken = string.random(Config.TokenLength, Config.TokenCharset)
	TriggerEvent('salty_tokenizer:receiveTokenServer', securityToken)
end

RegisterNetEvent('salty_tokenizer:requestToken')
AddEventHandler('salty_tokenizer:requestToken', function()
	local _source = source
	if not tokenRequested[_source] then
		tokenRequested[_source] = true
		TriggerClientEvent('salty_tokenizer:receiveTokenClient', _source, securityToken)
	end
end)

AddEventHandler('salty_tokenizer:invalidToken', function(invalidSrc)
	DropPlayer(invalidSrc, Config.KickMessage)
end)

AddEventHandler("playerDropped", function(player, reason)
    tokenRequested[source] = false
end)

AddEventHandler('playerConnecting', function(name, setCallback, deferrals)
	if not securityToken then
		generateToken()
	end
end)