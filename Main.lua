-- Crypt-MM2-Legit | Secure Loader
-- Checks for re-injection, runs anti-detect first, then loads everything

if _G.__CRYPT_RUNNING then
    warn("[Crypt] Already running — re-injection blocked")
    return
end
_G.__CRYPT_RUNNING = true

local _r  = game:GetService("HttpService")
local _p  = game:GetService("Players")
local _rs = game:GetService("RunService")

-- Randomize initial timing to break injection fingerprinting
local _jit = 0.05 + math.random() * 0.08
task.wait(_jit)

local BASE = "https://raw.githubusercontent.com/K01dBy4spam935h/crypt-mm2-legit/main/"

-- Silent load wrapper — no output on success
local function _load(path)
    local ok, err = pcall(function()
        local src = game:HttpGet(BASE .. path)
        assert(type(src)=="string" and #src>0, "empty response")
        local fn, compErr = loadstring(src)
        assert(fn, compErr)
        fn()
    end)
    if not ok then
        warn("[Crypt] " .. path .. " — " .. tostring(err))
        return false
    end
    return true
end

-- ── Load order ────────────────────────────────────────────────────────────────

-- 1. Config first (everything else reads it)
_load("Config.lua")

-- 2. Anti-detect BEFORE anything else runs (identity spoof, global wipe)
_load("AntiDetect.lua")
task.wait(0.02 + math.random() * 0.03)  -- micro-delay after spoof

-- 3. UI framework (window + widget API)
_load("UI.lua")
task.wait(0.01)

-- 4. Tabs (creates page objects in _G.Pages)
local tabs = {
    "tabs/Main_Tab.lua",
    "tabs/Sheriff_Tab.lua",
    "tabs/Murderer_Tab.lua",
    "tabs/Visuals_Tab.lua",
    "tabs/LocalPlayer_Tab.lua",
    "tabs/Farm_Tab.lua",
    "tabs/Teleport_Tab.lua",
    "tabs/Settings_Tab.lua",
}
for _, t in ipairs(tabs) do
    _load(t)
    task.wait(0.005 + math.random() * 0.005)
end

-- 5. Sections (UI + logic, attach to tab pages)
local sections = {
    "sections/ExecutorInfo.lua",
    "sections/RoundTimer.lua",
    "sections/Aimbot.lua",
    "sections/Triggerbot.lua",
    "sections/SilentAim.lua",
    "sections/KnifeTools.lua",
    "sections/Hitbox.lua",
    "sections/Crosshair.lua",
    "sections/GunDrop.lua",
    "sections/MovementSection.lua",
    "sections/Visibility.lua",
    "sections/AutoGun.lua",
    "sections/CoinFarm.lua",
    "sections/TeleportSection.lua",
    "sections/KeybindSection.lua",
    "sections/BackgroundSettings.lua",
}
for _, s in ipairs(sections) do
    _load(s)
    task.wait(0.005 + math.random() * 0.005)
end

-- 6. ESP last (depends on _G.RoleCache being initialized)
_load("ESP.lua")

-- 7. Notify success
task.wait(1.5)
if _G.Notify then
    _G.Notify("Crypt MM2 loaded", "success")
end
print("[Crypt] All modules loaded")
