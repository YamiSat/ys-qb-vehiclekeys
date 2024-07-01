fx_version 'cerulean'
game 'gta5'
author 'YamiSat'
description 'QB-VehicleKeys modified by YamiSat'
version '1.3.0'
ui_page 'NUI/index.html'

files {
    'NUI/index.html',
    'NUI/style.css',
    'NUI/script.js',
    'NUI/images/*',
}

shared_scripts {
    '@qb-core/shared/locale.lua',
    'locales/**.lua',
    'config.lua',
}

client_script {
    'client/main.lua',
    'client/cl_functions.lua',
    'client/dispatch.lua'
}
server_script {
    'server/main.lua',
    'server/sv_functions.lua'
}

lua54 'yes'
