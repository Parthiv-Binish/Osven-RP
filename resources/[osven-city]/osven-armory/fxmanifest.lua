fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author 'Osven City'
description 'Osven City Armory & Uniform System'
version '2.0.0'

shared_scripts {
    'bridge/sh_config.lua',
}

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
