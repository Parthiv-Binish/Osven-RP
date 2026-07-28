fx_version 'cerulean'
game 'gta5'
lua54 'yes'
name 'osven-inventory-bridge'
description 'Compatibility bridge: qb-inventory exports -> ox_inventory'
author 'Osven City'
version '1.0.0'

shared_script '@ox_lib/init.lua'

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'bridge/server.lua'
}

client_script 'bridge/client.lua'

dependencies {
    'ox_inventory',
    'ox_lib'
}
