fx_version 'adamant'
rdr3_warning 'I acknowledge that this is a prerelease build of RedM, and I am aware my resources *will* become incompatible once RedM ships.'

game 'rdr3'
lua54 'yes'
version '0.0.1'
lua54 'yes'
author 'huzurweriN'

client_scripts {
   'client/main.lua',
}

server_scripts {
   'server/main.lua'
}

shared_scripts {
   'shared/config.lua',
   'locale.lua',
   'languages/*.lua'
}

dependencies { 
    'vorp_core',
    'bcc-utils'
}
