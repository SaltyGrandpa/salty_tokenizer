# salty_tokenizer
Add security tokens to FiveM server events that are accessible from the client in order to prevent against Lua injections (and similar cheats).

# Features
* A unique security token is generated for each resource on each server restart.
* Tokens are sent through listeners that are obfuscated per client and unique every time the player joins.
* Tokens can only be requested by the client once. This prevents a cheater from attempting to retrieve the token at a later time.
* Players that trigger a server event without a valid security token are kicked from the game.

# Installation
There are no dependencies for this resource. The configuration file is set to generate a 24 character alphanumerical security token. If this is insufficient, the character set and length can be adjusted. In addition, the message a player gets if they are kicked due to an invalid token may be adjusted in the configuration file.

# Usage
In order to use this resource, both the client and server scripts need adjusted.

## Client
Tokens can be received by triggering an export once the tokenizer is ready.
```lua
local securityToken = nil
AddEventHandler('salty_tokenizer:clientReady', function()
	securityToken = exports['salty_tokenizer']:setupClientResource(GetCurrentResourceName())
end)
```

Once the token is received, it can be passed along with a server event to be validated on the server-side.
```lua
TriggerServerEvent('anticheat-testing:testEvent', securityToken)
```

## Server
To prepare a resource server side, an export must be called when the script is ready. Once this export is called, server events can be easily protected against abused server events.
```lua
AddEventHandler('salty_tokenizer:serverReady', function()
	exports['salty_tokenizer']:setupServerResource(GetCurrentResourceName())
end)
```
In order to protect a server event, a simple if statement must be added.
```lua
RegisterNetEvent('anticheat-testing:testEvent')
AddEventHandler('anticheat-testing:testEvent', function(token)
	local _source = source
	if not exports['salty_tokenizer']:secureServerEvent(GetCurrentResourceName(), _source, token) then
		return false
	end
	print("Authenticated")
end)
```
