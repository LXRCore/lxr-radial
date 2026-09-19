--[[ ═══════════════════════════════════════════════════════════════════════════
     LXR-RADIAL — Client: the key, the rings, what each entry does
     ═══════════════════════════════════════════════════════════════════════════
     Nothing runs until the key is held. Then the wheel for the current
     context is built (config entries + entries other resources added + the
     dynamic rings), sent to the page, and the pick comes back as an id.
     ═══════════════════════════════════════════════════════════════════════════
     © 2026 iBoss21 / LXRCore — All Rights Reserved
     ═══════════════════════════════════════════════════════════════════════════ ]]

local LXRCore = exports['lxr-core']:GetCoreObject()
local LXR = exports['lxr-core']:GetLXR()
local open = false
local added = {}        -- id → entry (from other resources)
local owner = {}        -- id → resource
local flat = {}         -- id → entry, of the wheel currently shown

local function me() return LXRCore.PlayerData or {} end
local function context()
    local ped = PlayerPedId()
    if IsPedOnMount(ped) then return 'mounted' end
    if IsPedInAnyVehicle(ped, false) then return 'wagon' end
    return 'onfoot'
end
local function shown(e, ctx)
    if not e.show then return true end
    for _, c in ipairs(e.show) do if c == ctx then return true end end
    return false
end
local function label(e) return e.label and (Lang:t(e.label) ~= e.label and Lang:t(e.label) or e.label) or e.id end

-- ═══════════════════════════════════════════════════════════════════════════════
-- 🧵 DYNAMIC RINGS
-- ═══════════════════════════════════════════════════════════════════════════════
local dynamic = {}

-- clothing: one entry per worn category, take off / put on, plus undress / dress
dynamic.clothing = function()
    if GetResourceState('lxr-clothing') ~= 'started' then return {} end
    local ok, wearing = pcall(function() return exports['lxr-clothing']:Wearing() end)
    if not ok or type(wearing) ~= 'table' then return {} end
    local out = {}
    for _, cat in ipairs(Config.Clothing.order) do
        local w = wearing[cat]
        if w and w.worn then
            out[#out + 1] = { id = 'wear:' .. cat, label = Lang:t('wear.' .. cat), icon = cat, state = w.hidden and 'off' or 'on',
                run = function() exports['lxr-clothing']:ToggleCategory(cat, not w.hidden) end }
        end
    end
    if Config.Clothing.undressAll and #out > 0 then
        out[#out + 1] = { id = 'wear:all_off', label = Lang:t('ring.undress'), icon = 'undress', run = function() for _, cat in ipairs(Config.Clothing.order) do local w = wearing[cat] if w and w.worn and not w.hidden then exports['lxr-clothing']:ToggleCategory(cat, true) end end end }
        out[#out + 1] = { id = 'wear:all_on',  label = Lang:t('ring.dress'),   icon = 'dress',   run = function() for _, cat in ipairs(Config.Clothing.order) do local w = wearing[cat] if w and w.worn and w.hidden then exports['lxr-clothing']:ToggleCategory(cat, false) end end end }
    end
    return out
end

-- ═══════════════════════════════════════════════════════════════════════════════
-- 🛞 BUILD + SHOW
-- ═══════════════════════════════════════════════════════════════════════════════
local function build(list, ctx, path)
    local out = {}
    for _, e in ipairs(list) do
        if shown(e, ctx) then
            local id = e.id
            local row = { id = id, label = label(e), icon = e.icon, state = e.state }
            if e.dynamic and dynamic[e.dynamic] then
                local sub = dynamic[e.dynamic]()
                if #sub > 0 then row.sub = build(sub, ctx, id) end
            elseif e.sub then
                row.sub = build(e.sub, ctx, id)
            end
            if row.sub and #row.sub == 0 then row.sub = nil row.empty = true end
            flat[id] = e
            out[#out + 1] = row
        end
    end
    return out
end

local function wheel()
    local ctx = context()
    local list = {}
    for _, e in ipairs(Config.Wheel) do list[#list + 1] = e end
    local extra = {}
    for _, e in pairs(added) do extra[#extra + 1] = e end
    table.sort(extra, function(a, b) return (a.order or 50) < (b.order or 50) end)
    for _, e in ipairs(extra) do list[#list + 1] = e end
    flat = {}
    return build(list, ctx)
end

local function close()
    if not open then return end
    open = false
    SetNuiFocus(false, false)
    SetNuiFocusKeepInput(false)
    SendNUIMessage({ action = 'close' })
end

local function show()
    if open or not LocalPlayer.state.isLoggedIn or IsNuiFocused() or IsPauseMenuActive() then return end
    local md = me().metadata or {}
    if (md.isdead and not Config.Key.whileDead) or (md.ishandcuffed and not Config.Key.whileCuffed) then return end
    local rings = wheel()
    if #rings == 0 then return end
    open = true
    SetNuiFocus(true, true)
    SetNuiFocusKeepInput(Config.Key.hold)   -- hold mode: the key's release must still reach the game
    SendNUIMessage({ action = 'open', wheel = rings, locale = Lang.bundle(), lang = Config.Lang, brand = LXRCore.Brand, hold = Config.Key.hold })
    CreateThread(function()
        while open do
            DisableControlAction(0, 0x07CE1E61, true) DisableControlAction(0, 0xF84FA74F, true)   -- no shooting through the wheel
            Wait(0)
        end
    end)
end

-- ═══════════════════════════════════════════════════════════════════════════════
-- ▶️ RUN
-- ═══════════════════════════════════════════════════════════════════════════════
local function run(e)
    if type(e.run) == 'function' then e.run() return end
    if e.event then TriggerEvent(e.event, e.args) return end
    if e.serverEvent then TriggerServerEvent(e.serverEvent, e.args) return end
    if e.command then ExecuteCommand(e.command) return end
    if e.export and GetResourceState(e.export[1]) == 'started' then
        local ex = exports[e.export[1]]
        pcall(function() ex[e.export[2]](ex, table.unpack(e.export.args or e.export[3] or {})) end)
    end
end

RegisterNUICallback('pick', function(d, cb)
    cb('ok')
    local e = d and flat[d.id]
    close()
    if e then run(e) end
end)
RegisterNUICallback('close', function(_, cb) cb('ok') close() end)
RegisterNUICallback('sound', function(d, cb) PlaySoundFrontend(d and d.name or 'NAV_UP', 'HUD_SHOP_SOUNDSET', true, 0) cb('ok') end)

-- ═══════════════════════════════════════════════════════════════════════════════
-- ⌨️ KEY
-- ═══════════════════════════════════════════════════════════════════════════════
RegisterCommand('+lxr_radial', function()
    if Config.Key.hold then show() else if open then close() else show() end end
end, false)
RegisterCommand('-lxr_radial', function() if Config.Key.hold then close() end end, false)
RegisterKeyMapping('+lxr_radial', 'Action wheel', 'keyboard', Config.Key.mapping)

-- duty toggle lives here so the wheel needs no job resource
AddEventHandler('lxr-radial:client:duty', function() LXR.Player.ToggleDuty() end)

-- ═══════════════════════════════════════════════════════════════════════════════
-- 📤 EXPORTS — other resources add their own entries
-- ═══════════════════════════════════════════════════════════════════════════════
---Add (or replace) a top-level entry: { id, label, icon, show, order, sub | event | serverEvent | command | export }
exports('Add', function(entry)
    if type(entry) ~= 'table' or type(entry.id) ~= 'string' then return false end
    added[entry.id] = entry
    owner[entry.id] = GetInvokingResource() or GetCurrentResourceName()
    return true
end)
exports('Remove', function(id) added[id] = nil owner[id] = nil end)
exports('Open', show)
exports('Close', close)
exports('IsOpen', function() return open end)

AddEventHandler('onResourceStop', function(res)
    if res == GetCurrentResourceName() then close() return end
    for id, r in pairs(owner) do if r == res then added[id] = nil owner[id] = nil end end
end)
RegisterNetEvent('lxr:client:unloaded', close)
