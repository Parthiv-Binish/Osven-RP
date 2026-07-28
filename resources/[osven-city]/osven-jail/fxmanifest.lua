fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author 'Osven City'
description 'Osven City Jail / Community Service Widget'
version '2.0.0'

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
