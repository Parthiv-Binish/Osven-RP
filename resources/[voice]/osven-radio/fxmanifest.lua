fx_version 'cerulean'
game 'gta5'
lua54 'yes'
name 'osven-radio'
description 'Radio system integrated with pma-voice'
author 'Osven City'
version '1.0.0'

shared_scripts {
    '@ox_lib/init.lua',
    'config.lua'
}

client_scripts {
    'client.lua'
}

server_script 'server.lua'

ui_page 'html/ui.html'

files {
    'html/ui.html',
    'html/js/script.js',
    'html/css/style.css',
    'html/img/radio.png'
}

dependencies {
    'pma-voice',
    'ox_lib'
}
