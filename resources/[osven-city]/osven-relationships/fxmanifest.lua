fx_version 'cerulean'
game 'gta5'
lua54 'yes'
name 'osven-relationships'
description 'Marriage and relationship system'
author 'Osven City'
version '1.0.0'

shared_script '@ox_lib/init.lua'

shared_scripts {
    'bridge/sh_config.lua'
}

client_scripts {
    'bridge/cl_main.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'bridge/sv_main.lua'
}

ui_page 'html/index.html'

files {
    'html/index.html',
    'html/css/style.css',
    'html/js/app.js',
}

dependencies {
    'ox_lib',
    'oxmysql',
    'osven-inventory-bridge',
}
