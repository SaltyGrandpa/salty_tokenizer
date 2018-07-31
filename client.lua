local firstSpawn = true

AddEventHandler("playerSpawned", function()
	if firstSpawn then
		firstSpawn = false
		TriggerServerEvent('salty_tokenizer:requestToken')
	end
end)