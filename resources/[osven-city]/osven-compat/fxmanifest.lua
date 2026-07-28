fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author 'Osven City'
description 'Osven City — qb-menu/qb-input Compatibility Bridge to ox_lib'
version '2.0.0'

client_scripts {
    'bridge/cl_menu.lua',
    'bridge/cl_input.lua',
}

dependencies {
    'ox_lib',
    'qb-core',
}
