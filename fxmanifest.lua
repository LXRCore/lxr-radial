--[[
    ██╗     ██╗  ██╗██████╗       ██████╗  █████╗ ██████╗ ██╗ █████╗ ██╗
    ██║     ╚██╗██╔╝██╔══██╗      ██╔══██╗██╔══██╗██╔══██╗██║██╔══██╗██║
    ██║      ╚███╔╝ ██████╔╝█████╗██████╔╝███████║██║  ██║██║███████║██║
    ██║      ██╔██╗ ██╔══██╗╚════╝██╔══██╗██╔══██║██║  ██║██║██╔══██║██║
    ███████╗██╔╝ ██╗██║  ██║      ██║  ██║██║  ██║██████╔╝██║██║  ██║███████╗
    ╚══════╝╚═╝  ╚═╝╚═╝  ╚═╝      ╚═╝  ╚═╝╚═╝  ╚═╝╚═════╝ ╚═╝╚═╝  ╚═╝╚══════╝

    🐺 LXR Core - Radial

    The action wheel: hold F1, a ring of what the character can do right now —
    clothing (take off / put on what is worn), the horse, duty, the satchel,
    the HUD. Nested rings, per-context (on foot, in the saddle, on a wagon),
    entries from config and from any resource through one export.

    Brand:       LXRCore — Lux Empire eXperience RedM Core
    Product:     wolves.land / The Land of Wolves
    Developer:   iBoss21 / LXRCore
    Website:     https://www.lxrcore.com
    Discord:     https://discord.gg/GAhk8cgXe9
    GitHub:      https://github.com/LXRCore

    Version: 1.0.0
    Performance Target: 0.00 ms idle (nothing runs until the key is held)

    © 2026 iBoss21 / LXRCore | lxrcore.com | All Rights Reserved
]]

fx_version '3.0.0'
game 'rdr3'
rdr3_warning 'I acknowledge that this is a prerelease build of RedM, and I am aware my resources *will* become incompatible once RedM ships.'
lua54 'yes'

name 'lxr-radial'
author 'iBoss21 / LXRCore'
description 'LXRCore v3 action wheel on the LXR UI Kit — clothing, horse, duty, satchel; nested rings; entries from any resource'
version '1.0.1'
repository 'https://github.com/LXRCore/lxr-radial'

shared_scripts {
    'shared/locale.lua',
    'locales/*.lua',
    'config.lua',
}

client_script 'client/main.lua'
server_script 'server/main.lua'

ui_page 'html/index.html'

files {
    'html/index.html',
    'html/lxr-ui.css',
    'html/style.css',
    'html/app.js',
    'html/img/*.png',
    'html/fonts/*.woff2',
}

dependency 'lxr-core'
