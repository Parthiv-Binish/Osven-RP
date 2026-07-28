fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author 'Osven City'
description 'Osven City Premium HUD'
version '2.0.0'

shared_scripts {
    '@osven-shared/bridge/cl_main.lua',
    'bridge/sh_config.lua',
}

client_scripts {
    'bridge/cl_main.lua',
    'bridge/cl_notify.lua',
}

server_scripts {
    'bridge/sv_main.lua',
}

ui_page 'html/index.html'

files {
    'html/index.html',
    'html/css/main.css',
    'html/css/tokens.css',
    'html/js/app.js',
}

dependencies {
    'ox_lib',
    'qb-core',
}
