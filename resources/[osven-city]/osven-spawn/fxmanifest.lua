fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author 'Osven City'
description 'Osven City Spawn Selector'
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

ui_page 'html/index.html'

files {
    'html/index.html',
    'html/css/main.css',
    'html/js/app.js',
}

dependencies {
    'qb-core',
}
