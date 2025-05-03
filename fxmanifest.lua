fx_version 'cerulean'
game 'gta5'

name 'Advanced Garage System'
author 'Your Server'
version '1.0.0'
description 'Fortschrittliches Garagensystem für ESX'

shared_scripts {
    '@es_extended/imports.lua',
    '@[standalone]/[framework_bridge]/shared/main.lua',
    'config/config.lua',
    'locales/*.lua'
}

client_scripts {
    'client/main.lua',
    'client/functions.lua',
    'client/events.lua',
    'client/commands.lua',
    'client/nui.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/main.lua',
    'server/functions.lua',
    'server/events.lua',
    'server/commands.lua'
}

ui_page 'html/index.html'

files {
    'html/index.html',
    'html/css/*.css',
    'html/js/*.js',
    'html/fonts/*.ttf',
    'html/img/*.png',
    'html/img/*.jpg'
}

dependencies {
    'es_extended',
    'oxmysql',
    '[standalone]/[framework_bridge]'
}