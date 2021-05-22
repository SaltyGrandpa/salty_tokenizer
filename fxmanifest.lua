fx_version 'cerulean'
game 'gta5'

description 'Add security tokens to server events.'

client_scripts {
	'config.lua',
	'client.lua'
}

server_scripts {
	'config.lua',
	'server.lua'
}

exports {
	'setupClientResource'
}

server_exports {
	'setupServerResource',
	'secureServerEvent',
	'getResourceToken'
}

file 'init.lua'
