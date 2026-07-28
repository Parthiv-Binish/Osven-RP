fx_version 'cerulean'
game 'gta5'
lua54 'yes'
name 'osven-whitelist'
description 'Discord role-based whitelist system'
author 'Osven City'
version '1.0.0'

shared_script 'bridge/sh_config.lua'
server_script 'bridge/sv_main.lua'

dependencies {
    'osven-logging'
}
