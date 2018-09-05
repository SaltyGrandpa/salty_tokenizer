if IsDuplicityVersion() then
	AddEventHandler('salty_tokenizer:serverReady', function()
		exports['salty_tokenizer']:setupServerResource(GetCurrentResourceName())
	end)
else
	securityToken = nil
	AddEventHandler('salty_tokenizer:clientReady', function()
		securityToken = exports['salty_tokenizer']:setupClientResource(GetCurrentResourceName())
	end)
end
