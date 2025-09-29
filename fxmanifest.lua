fx_version 'cerulean'
game 'gta5'
author 'LFScripts, xLaugh, Firgyy'
version '0.0.1'

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