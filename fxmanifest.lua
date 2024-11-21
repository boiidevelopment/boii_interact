--[[
     ____   ____ _____ _____   _   _____  ________      ________ _      ____  _____  __  __ ______ _   _ _______ 
    |  _ \ / __ \_   _|_   _| | | |  __ \|  ____\ \    / /  ____| |    / __ \|  __ \|  \/  |  ____| \ | |__   __|
    | |_) | |  | || |   | |   | | | |  | | |__   \ \  / /| |__  | |   | |  | | |__) | \  / | |__  |  \| |  | |   
    |  _ <| |  | || |   | |   | | | |  | |  __|   \ \/ / |  __| | |   | |  | |  ___/| |\/| |  __| | . ` |  | |   
    | |_) | |__| || |_ _| |_  | | | |__| | |____   \  /  | |____| |___| |__| | |    | |  | | |____| |\  |  | |   
    |____/ \____/_____|_____| | | |_____/|______|   \/   |______|______\____/|_|    |_|  |_|______|_| \_|  |_|   
                              | |                                                                                
                              |_|               INTERACT UI
]]

fx_version 'cerulean'
games { 'gta5', 'rdr3' }

name 'boii_interact'
version '1.0.1'
description 'BOII | Development - Interact UI'
author 'boiidevelopment'
repository 'https://github.com/boiidevelopment/boii_interact'
lua54 'yes'

ui_page 'public/index.html'

files {
    'public/**/**/**',
}

client_scripts {
    'client/main.lua',
}

server_scripts {
    'server/version.lua'
}

escrow_ignore {
    'client/*',
    'server/*'
}
