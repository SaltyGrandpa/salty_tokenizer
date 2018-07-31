Config = {}

--[[
	Define the length of the generated token
--]]
Config.TokenLength = 10

--[[
	Define the character set to be used in generation
	%a%d = all capital and lowercase letters and digits
	Syntax:
		.	all characters
		%a	letters
		%c	control characters
		%d	digits
		%l	lower case letters
		%p	punctuation characters
		%s	space characters
		%u	upper case letters
		%w	alphanumeric characters
		%x	hexadecimal digits
		%z	the character with representation 0
--]]
Config.TokenCharset = "%a%d"

--[[
	Define the message given to users with an invalid token
--]]
Config.KickMessage = "Invalid security token detected."