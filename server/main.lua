--[[ ═══════════════════════════════════════════════════════════════════════════
     LXR-RADIAL — Server: the one thing a wheel entry may ask the server for
     ═══════════════════════════════════════════════════════════════════════════
     `lxr-radial:server:useItem(name)` uses an item the character holds through
     the core's usable registry — the same path as the satchel, rate limited.
     ═══════════════════════════════════════════════════════════════════════════
     © 2026 iBoss21 / LXRCore — All Rights Reserved
     ═══════════════════════════════════════════════════════════════════════════ ]]

local LXRCore = exports['lxr-core']:GetCoreObject()
local buckets = {}

RegisterNetEvent('lxr-radial:server:useItem', function(name)
    local src = source
    local rl = Config.Security.rateLimit
    if type(name) ~= 'string' or not LXRCore.RateLimit(buckets, src, rl.burst, rl.windowMs) then return end
    local item = LXRCore.Inventory.GetItem(src, name)
    if not item then return LXRCore.Notify(src, Lang:t('error.no_item', { item = (LXRShared.Items[name] or {}).label or name }), 'error') end
    if not LXRCore.Items.CanUse(name) then return LXRCore.Notify(src, Lang:t('error.not_usable'), 'error') end
    LXRCore.Items.Use(src, item)
end)

AddEventHandler('playerDropped', function() buckets[source] = nil end)
