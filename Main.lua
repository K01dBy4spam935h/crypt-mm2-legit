-- Crypt-MM2-Legit | Secure Loader + Advanced Module Checker

if _G.__CRYPT_RUNNING then
    warn("[Crypt] Already running — blocked")
    return
end
_G.__CRYPT_RUNNING = true

task.wait(0.05 + math.random() * 0.08)

local BASE = "https://raw.githubusercontent.com/K01dBy4spam935h/crypt-mm2-legit/main/"

-- ── Module tracker ────────────────────────────────────────────────────────────

_G.ModuleStatus = {}   -- [name] = {loaded=bool, error=string|nil, crashed=bool}

local function _load(path)
    local name = path:match("([^/]+)%.lua$") or path
    _G.ModuleStatus[name] = {loaded=false, error=nil, crashed=false}

    local ok, err = pcall(function()
        local src = game:HttpGet(BASE .. path)
        assert(type(src)=="string" and #src>10, "empty or invalid response")
        local fn, compErr = loadstring(src)
        assert(fn, "compile error: " .. tostring(compErr))
        fn()
    end)

    if ok then
        _G.ModuleStatus[name] = {loaded=true, error=nil, crashed=false}
        print("[Crypt] ✓ " .. name)
        return true
    else
        local errStr = tostring(err)
        -- Detect silent crash vs hard error
        local crashed = errStr:find("attempt to") or errStr:find("stack overflow") or errStr:find("nil value")
        _G.ModuleStatus[name] = {loaded=false, error=errStr, crashed=crashed or false}
        warn("[Crypt] ✕ " .. name .. " — " .. errStr)
        return false
    end
end

-- Post-load verification: checks if the module's expected globals/functions exist
local expectedGlobals = {
    Config       = {"_G.Config"},
    AntiDetect   = {"_G.DetectedExecutor"},
    UI           = {"_G.UI","_G.Pages","_G.Notify"},
    ESP          = {"_G.RoleCache","_G.RoundActive"},
    Aimbot       = {"_G.AimbotEnabled","_G.AimbotFOV"},
    SilentAim    = {"_G.SilentAim"},
    KnifeTools   = {"_G.KnifeAura","_G.AutoThrow"},
    Hitbox       = {"_G.HitboxEnabled"},
    CoinFarm     = {"_G.CoinFarm"},
    AutoGun      = {"_G.AutoGun"},
    MovementSection = {"_G.NoclipEnabled","_G.FlyEnabled"},
    ExecutorInfo = {},
}

local function verifyModule(name)
    local checks = expectedGlobals[name]
    if not checks or #checks == 0 then return true end
    for _, globalPath in ipairs(checks) do
        -- parse _G.Something
        local key = globalPath:match("_G%.(.+)")
        if key and _G[key] == nil then
            local status = _G.ModuleStatus[name]
            if status then
                status.crashed = true
                status.error = (status.error or "") .. " | silent fail: _G." .. key .. " is nil"
            end
            return false
        end
    end
    return true
end

-- ── Load order ────────────────────────────────────────────────────────────────

_load("Config.lua")
_load("AntiDetect.lua")
task.wait(0.02 + math.random()*0.03)
_load("UI.lua")
task.wait(0.01)

local tabs = {
    "tabs/Main_Tab.lua","tabs/Sheriff_Tab.lua","tabs/Murderer_Tab.lua",
    "tabs/Visuals_Tab.lua","tabs/LocalPlayer_Tab.lua","tabs/Farm_Tab.lua",
    "tabs/Teleport_Tab.lua","tabs/Settings_Tab.lua",
}
for _, t in ipairs(tabs) do _load(t); task.wait(0.005+math.random()*0.005) end

local sections = {
    "sections/ExecutorInfo.lua","sections/RoundTimer.lua",
    "sections/Aimbot.lua","sections/Triggerbot.lua",
    "sections/SilentAim.lua","sections/KnifeTools.lua",
    "sections/Hitbox.lua","sections/Crosshair.lua",
    "sections/GunDrop.lua","sections/MovementSection.lua",
    "sections/Visibility.lua","sections/AutoGun.lua",
    "sections/CoinFarm.lua","sections/TeleportSection.lua",
    "sections/KeybindSection.lua","sections/BackgroundSettings.lua",
}
for _, s in ipairs(sections) do _load(s); task.wait(0.005+math.random()*0.005) end

_load("ESP.lua")

-- ── Post-load verification ────────────────────────────────────────────────────

task.wait(0.5)
local failed   = {}
local silentFailed = {}
local crashed  = {}

for name, status in pairs(_G.ModuleStatus) do
    verifyModule(name)  -- re-check after all modules loaded
    status = _G.ModuleStatus[name]
    if not status.loaded then
        if status.crashed then
            table.insert(crashed, name)
        else
            table.insert(failed, name)
        end
    elseif status.crashed then
        table.insert(silentFailed, name)
    end
end

-- ── Report ────────────────────────────────────────────────────────────────────

task.wait(1.5)  -- wait for UI and Notify to be ready

local totalModules = 0
for _ in pairs(_G.ModuleStatus) do totalModules = totalModules + 1 end
local loadedCount  = totalModules - #failed - #crashed

if #failed == 0 and #crashed == 0 and #silentFailed == 0 then
    if _G.Notify then
        _G.Notify("Crypt MM2 loaded — " .. loadedCount .. "/" .. totalModules .. " modules OK", "success")
    end
    print("[Crypt] All " .. totalModules .. " modules loaded successfully")
else
    if #crashed > 0 then
        local msg = "Crashed: " .. table.concat(crashed, ", ")
        if _G.Notify then _G.Notify(msg, "error") end
        warn("[Crypt] " .. msg)
    end
    if #failed > 0 then
        local msg = "Failed to load: " .. table.concat(failed, ", ")
        if _G.Notify then _G.Notify(msg, "error") end
        warn("[Crypt] " .. msg)
    end
    if #silentFailed > 0 then
        local msg = "Silent fail (loaded but missing globals): " .. table.concat(silentFailed, ", ")
        if _G.Notify then _G.Notify(msg, "warn") end
        warn("[Crypt] " .. msg)
    end
    if _G.Notify then
        _G.Notify(loadedCount .. "/" .. totalModules .. " modules loaded", "info")
    end
end

-- ── Module status accessible from settings tab ────────────────────────────────
-- sections/ExecutorInfo.lua can read _G.ModuleStatus to display per-module health
