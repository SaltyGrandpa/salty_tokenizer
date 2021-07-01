Config = {}

--[[
	Enable verbose output on the console
	VerboseClient should be disable in production since it exposed tokens
]]
Config.VerboseClient = false
Config.VerboseServer = false

--[[
	Adjust the delay between when the client deploys the listeners and
	when the server sends the information.
	250 seems like a sweet spot here, but it can be reduced or increased if desired.
]]

Config.ClientDelay = 250

--[[
	Define the message given to users with an invalid token
--]]
Config.KickMessage = "Invalid security token detected."

--[[
	Define a custom function to trigger when a player is kicked
	If Config.CustomAction is false, the player will be dropped
]]
Config.CustomAction = false
Config.CustomActionFunction = function(source)
	print("Custom action executing for: " .. source)
	DropPlayer(source, Config.KickMessage)
end
