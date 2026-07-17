-- Crypt-MM2-Legit | Anti-Detection

local RunService = game:GetService("RunService")
local Players    = game:GetService("Players")
local lp         = Players.LocalPlayer

-- ── 1. Executor auto-detect + identity spoof ──────────────────────────────────

local detectedExecutor = "Unknown"

local function detectAndSpoof()
    -- Try native executor name API (no list, pure API)
    if identifyexecutor then
        local ok, r = pcall(identifyexecutor)
        if ok and r then detectedExecutor = tostring(r) end
    elseif getexecutorname then
        local ok, r = pcall(getexecutorname)
        if ok and r then detectedExecutor = tostring(r) end
    end

    -- Capability fingerprint for unknown executors
    if detectedExecutor == "Unknown" then
        local s = 0
        local checks = {hookfunction,newcclosure,writefile,readfile,getrawmetatable,
            hookmetamethod,firetouchinterest,Drawing,setfpscap,getconnections,
            clonefunction,decompile,setidentity,setthreadidentity,getgenv}
        for _,v in ipairs(checks) do if v ~= nil then s=s+1 end end
        if s>=13 then detectedExecutor="Premium"
        elseif s>=9  then detectedExecutor="Standard"
        elseif s>=5  then detectedExecutor="Basic"
        else detectedExecutor="Minimal" end
    end

    _G.DetectedExecutor = detectedExecutor

    -- Identity spoof: try all methods, use whichever works
    -- Identity 2 = LocalScript level, indistinguishable from game scripts
    local spoofMethods = {
        function() if setthreadidentity    then setthreadidentity(2)        end end,
        function() if setidentity          then setidentity(2)              end end,
        function() if set_thread_identity  then set_thread_identity(2)      end end,
        function() if syn and syn.set_thread_identity then syn.set_thread_identity(2) end end,
    }
    for _, fn in ipairs(spoofMethods) do pcall(fn) end
end

detectAndSpoof()

-- Re-apply spoof every 2s (executor resets between threads)
local idTimer = 0
RunService.Heartbeat:Connect(function(dt)
    idTimer = idTimer + dt
    if idTimer >= 2 then
        idTimer = 0
        pcall(function()
            if setthreadidentity then setthreadidentity(2) end
            if setidentity       then setidentity(2)       end
        end)
    end
end)

-- ── 2. Wipe risky executor globals ───────────────────────────────────────────

pcall(function()
    local risky = {
        "SYNAPSE_LOADED","syn","KRNL_LOADED","KRNL_INITIALIZED","fluxus",
        "carbon","Celery","is_sirhurt_closure","ElectroHub","PROTOSMASHER_LOADED",
        "AWP_LOADED","ISLAND_LOADED","secure_call","getsynasset"
    }
    local env = (getgenv and getgenv()) or _G
    for _, name in ipairs(risky) do
        pcall(function() env[name] = nil end)
    end
end)

-- ── 3. Humanize timing ────────────────────────────────────────────────────────

local jitter = 0
RunService.Heartbeat:Connect(function(dt)
    jitter = jitter + dt
    if jitter > (0.04 + math.random() * 0.07) then
        jitter = 0
        local _ = math.random()
    end
end)

-- ── 4. GUI watchdog ───────────────────────────────────────────────────────────

task.spawn(function()
    while task.wait(5) do
        pcall(function()
            local pg  = lp:FindFirstChild("PlayerGui")
            local gui = pg and pg:FindFirstChild("CryptMM2")
            if gui and not gui.Enabled then gui.Enabled = true end
        end)
    end
end)

-- ── 5. Disconnect watchdog ────────────────────────────────────────────────────

lp.OnTeleport:Connect(function(s)
    if s == Enum.TeleportState.Started then
        warn("[Crypt] Teleport detected")
        if _G.Notify then _G.Notify("Teleport triggered","warn") end
    end
end)

print("[Crypt] AntiDetect — executor: " .. detectedExecutor)
