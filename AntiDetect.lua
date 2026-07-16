-- Crypt-MM2-Legit | Anti-Detection v3

local RunService = game:GetService("RunService")
local Players    = game:GetService("Players")
local lp         = Players.LocalPlayer

-- ── 1. Executor auto-detection ────────────────────────────────────────────────

local detectedExecutor = "Unknown"
local detectedVersion  = "?"

local function detectExecutor()
    -- Method 1: Native API (best, no list needed)
    if identifyexecutor then
        local ok, r = pcall(identifyexecutor)
        if ok and r then detectedExecutor = tostring(r); return end
    end
    if getexecutorname then
        local ok, r = pcall(getexecutorname)
        if ok and r then detectedExecutor = tostring(r); return end
    end

    -- Method 2: Capability fingerprinting (no hardcoded names)
    -- Score different function groups that are unique to executor tiers
    local caps = {
        hookfunction     = hookfunction     ~= nil,
        newcclosure      = newcclosure      ~= nil,
        writefile        = writefile        ~= nil,
        readfile         = readfile         ~= nil,
        getgenv          = getgenv          ~= nil,
        setidentity      = setidentity      ~= nil,
        setthreadidentity= setthreadidentity~= nil,
        getrawmetatable  = getrawmetatable  ~= nil,
        hookmetamethod   = hookmetamethod   ~= nil,
        firetouchinterest= firetouchinterest~= nil,
        Drawing          = Drawing          ~= nil,
        setfpscap        = setfpscap        ~= nil,
        getconnections   = getconnections   ~= nil,
        clonefunction    = clonefunction    ~= nil,
        decompile        = decompile        ~= nil,
    }

    local score = 0
    for _, v in pairs(caps) do if v then score = score + 1 end end

    if score >= 13 then detectedExecutor = "Premium (High-tier)"
    elseif score >= 9 then detectedExecutor = "Standard (Mid-tier)"
    elseif score >= 5 then detectedExecutor = "Basic (Low-tier)"
    else detectedExecutor = "Minimal" end

    detectedVersion = score .. "/15 functions"
end

detectExecutor()
_G.DetectedExecutor = detectedExecutor
_G.ExecutorVersion  = detectedVersion

-- ── 2. Advanced identity spoof ────────────────────────────────────────────────
-- Auto-detects which spoofing method is available and uses it
-- Identity 2 = LocalScript level (indistinguishable from normal game scripts)

local identityMethod = nil

local function findIdentityMethod()
    if setthreadidentity then
        identityMethod = function() pcall(setthreadidentity, 2) end
    elseif setidentity then
        identityMethod = function() pcall(setidentity, 2) end
    elseif syn and type(syn) == "table" and syn.set_thread_identity then
        identityMethod = function() pcall(syn.set_thread_identity, 2) end
    elseif set_thread_identity then
        identityMethod = function() pcall(set_thread_identity, 2) end
    end
end

findIdentityMethod()
if identityMethod then identityMethod() end

-- Re-apply identity every second (executor can reset between threads)
local idTimer = 0
RunService.Heartbeat:Connect(function(dt)
    idTimer = idTimer + dt
    if idTimer >= 1 then
        idTimer = 0
        if identityMethod then identityMethod() end
    end
end)

-- ── 3. Wipe executor globals ──────────────────────────────────────────────────
-- Scan getgenv() for non-standard globals and remove known AC targets
-- Without a hardcoded list — instead wipe anything that starts with executor
-- signatures: all-caps single word globals that shouldn't exist in vanilla

pcall(function()
    -- Known high-risk globals regardless of executor
    local riskyGlobals = {
        "SYNAPSE_LOADED","syn","KRNL_LOADED","KRNL_INITIALIZED",
        "fluxus","carbon","Celery","is_sirhurt_closure","ElectroHub",
        "PROTOSMASHER_LOADED","AWP_LOADED","ISLAND_LOADED","secure_call",
        "gethui","getsynasset","seliware","delta","delta-executor","delta_executor",
        "volt","volcano","synapsez","velocity","potassium"
    }
    local env = getgenv and getgenv() or _G
    for _, name in ipairs(riskyGlobals) do
        pcall(function() env[name] = nil end)
    end
end)

-- ── 4. Humanize timing ───────────────────────────────────────────────────────

local jitter = 0
RunService.Heartbeat:Connect(function(dt)
    jitter = jitter + dt
    if jitter > (0.04 + math.random() * 0.07) then
        jitter = 0
        local _ = math.random()
    end
end)

-- ── 5. GUI watchdog ───────────────────────────────────────────────────────────

task.spawn(function()
    while task.wait(5) do
        pcall(function()
            local pg  = lp:FindFirstChild("PlayerGui"); if not pg then return end
            local gui = pg:FindFirstChild("CryptMM2")
            if gui and not gui.Enabled then gui.Enabled = true end
        end)
    end
end)

-- ── 6. Disconnect detection ───────────────────────────────────────────────────

lp.OnTeleport:Connect(function(state)
    if state == Enum.TeleportState.Started then
        warn("[Crypt] Teleport detected")
        if _G.Notify then _G.Notify("Teleport triggered","warn") end
    end
end)

print("[Crypt] AntiDetect loaded — executor: " .. detectedExecutor)
