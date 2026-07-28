fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author 'Osven City'
description 'Osven City Vehicle Impound & Evidence Locker'
version '2.0.0'

client_scripts {
    'bridge/cl_main.lua',
}

server_scripts {
    'bridge/sv_main.lua',
}

dependencies {
    'qb-core',
    'ox_lib',
    'ox_target',
}
