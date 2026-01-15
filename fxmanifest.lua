fx_version 'cerulean'
game 'gta5'
author 'LFScripts, xLaugh, Firgyy'
version '1.0.1'

escrow_ignore {
    'config.lua',
    'lang.lua',
    'client.lua',
    'server.lua'
}

shared_scripts {
    'config.lua',
    'lang.lua'
}

client_scripts {
    'client.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server.lua'
}