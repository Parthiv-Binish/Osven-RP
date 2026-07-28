fx_version 'cerulean'
game 'gta5'
lua54 'yes'
name 'osven-discord-bot'
description 'FiveM → Discord bot bridge for in-game events'
author 'Osven City'
version '1.0.0'

shared_script '@ox_lib/init.lua'
shared_script 'bridge/sh_config.lua'
server_script 'bridge/sv_main.lua'

dependencies {
    'osven-logging',
    'ox_lib'
}
