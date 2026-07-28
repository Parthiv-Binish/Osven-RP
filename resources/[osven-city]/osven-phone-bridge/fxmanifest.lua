fx_version 'cerulean'
game 'gta5'
lua54 'yes'
name 'osven-phone-bridge'
description 'Compatibility bridge: qb-phone events -> NPWD'
author 'Osven City'
version '1.0.0'

shared_script '@ox_lib/init.lua'

server_scripts {
    'bridge/server.lua'
}

client_scripts {
    'bridge/client.lua'
}

dependencies {
    'npwd',
    'ox_lib'
}
