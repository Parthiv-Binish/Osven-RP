fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author 'Osven City'
description 'Osven City — qb-menu/qb-target/qb-input Compatibility Bridge to ox_lib'
version '2.0.0'

provide 'qb-menu'
provide 'qb-target'

client_scripts {
    'bridge/cl_menu.lua',
    'bridge/cl_input.lua',
    'bridge/cl_target.lua',
}

dependencies {
    'ox_lib',
    'ox_target',
    'qb-core',
}
