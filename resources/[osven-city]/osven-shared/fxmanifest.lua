fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author 'Osven City'
description 'Osven City Shared Design Tokens & Utilities'
version '2.0.0'

client_scripts {
    'bridge/cl_main.lua',
}

server_scripts {
    'bridge/sv_main.lua',
}

files {
    'html/css/tokens.css',
}

-- This resource provides shared CSS custom properties
-- and utility functions to all other osven-* resources.
-- It must start before any other Osven City NUI resource.
