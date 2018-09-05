resource_manifest_version '44febabe-d386-4d18-afbe-5e627f4af937'

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
