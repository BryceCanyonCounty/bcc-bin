fx_version 'cerulean'
rdr3_warning 'I acknowledge that this is a prerelease build of RedM, and I am aware my resources *will* become incompatible once RedM ships.'

game 'rdr3'
lua54 'yes'
author 'huzurweriN'

shared_scripts {
   'configs/*.lua',
   'locale.lua',
   'languages/*.lua'
}

client_scripts {
   'client/main.lua',
}

server_scripts {
   'server/main.lua'
}

dependencies {
   'vorp_core',
   'bcc-utils',
   'feather-progressbar'
}

version '0.1.0'