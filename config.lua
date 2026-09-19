--[[
    ██╗     ██╗  ██╗██████╗       ██████╗  █████╗ ██████╗ ██╗ █████╗ ██╗
    ██║     ╚██╗██╔╝██╔══██╗      ██╔══██╗██╔══██╗██╔══██╗██║██╔══██╗██║
    ██║      ╚███╔╝ ██████╔╝█████╗██████╔╝███████║██║  ██║██║███████║██║
    ██║      ██╔██╗ ██╔══██╗╚════╝██╔══██╗██╔══██║██║  ██║██║██╔══██║██║
    ███████╗██╔╝ ██╗██║  ██║      ██║  ██║██║  ██║██████╔╝██║██║  ██║███████╗
    ╚══════╝╚═╝  ╚═╝╚═╝  ╚═╝      ╚═╝  ╚═╝╚═╝  ╚═╝╚═════╝ ╚═╝╚═╝  ╚═╝╚══════╝

    LXR Core - Radial

    The wheel is data. An entry is:
      { id, label = 'locale key' | text, icon = 'name' (html/app.js ICONS),
        show = { 'onfoot' | 'mounted' | 'wagon' } (nil = everywhere),
        one of: sub = { entries } | event = 'client event' | serverEvent = 'server event'
              | command = 'chat command' | export = { resource, fn, args } | dynamic = 'clothing' | 'horse'
        args = anything handed to the event }
    Other resources add their own with exports['lxr-radial']:Add(entry) / Remove(id).

    Brand:       LXRCore — Lux Empire eXperience RedM Core
    Product:     wolves.land / The Land of Wolves
    Developer:   iBoss21 / LXRCore
    Website:     https://www.lxrcore.com
    Discord:     https://discord.gg/GAhk8cgXe9
    GitHub:      https://github.com/LXRCore

    Version: 1.0.0
    Performance Target: 0.00 ms idle

    © 2026 iBoss21 / LXRCore | lxrcore.com | All Rights Reserved
]]

Config = Config or {}

-- ████████████████████████████████████████████████████████████████████████████████
-- ████████████████████████ LANGUAGE ██████████████████████████████████████████████
-- ████████████████████████████████████████████████████████████████████████████████
Config.Lang = 'en'

-- ████████████████████████████████████████████████████████████████████████████████
-- ████████████████████████ THE KEY ███████████████████████████████████████████████
-- ████████████████████████████████████████████████████████████████████████████████
Config.Key = {
    mapping   = 'F1',            -- RegisterKeyMapping default; players rebind it in the game's settings
    hold      = true,            -- true: the wheel is up while the key is held; false: press to open, press / Esc to close
    whileDead = false,
    whileCuffed = false,
}

-- ████████████████████████████████████████████████████████████████████████████████
-- ████████████████████████ THE WHEEL █████████████████████████████████████████████
-- ████████████████████████████████████████████████████████████████████████████████
Config.Wheel = {
    { id = 'clothing', label = 'ring.clothing', icon = 'shirt',  dynamic = 'clothing' },
    { id = 'horse',    label = 'ring.horse',    icon = 'horse',  show = { 'onfoot' }, sub = {
        { id = 'horse_call',  label = 'ring.horse_call',  icon = 'whistle', export = { 'lxr-horses', 'CallHorse' } },
        { id = 'horse_store', label = 'ring.horse_store', icon = 'stable',  command = 'horse store' },
    } },
    { id = 'satchel',  label = 'ring.satchel',  icon = 'satchel', command = 'inventory' },
    { id = 'duty',     label = 'ring.duty',     icon = 'badge',   event = 'lxr-radial:client:duty' },
    { id = 'papers',   label = 'ring.papers',   icon = 'paper',   serverEvent = 'lxr-radial:server:useItem', args = 'id_card' },
    { id = 'hud',      label = 'ring.hud',      icon = 'frame',   command = 'hud' },
}

-- the clothing ring: one entry per worn category (take off / put on), then these
Config.Clothing = {
    order     = { 'hats', 'masks', 'eyewear', 'coats', 'shirts_full', 'vests', 'pants', 'boots', 'gloves', 'neckwear', 'gunbelts', 'satchels' },
    undressAll = true,           -- "Undress" (everything off) and "Dress" (everything back on)
}

-- ████████████████████████████████████████████████████████████████████████████████
-- ████████████████████████ SECURITY ██████████████████████████████████████████████
-- ████████████████████████████████████████████████████████████████████████████████
Config.Security = { rateLimit = { burst = 8, windowMs = 4000 } }
