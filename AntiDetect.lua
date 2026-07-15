-- Crypt-MM2-Legit | Anti-Detection (safe, no metatable hooks)

local RunService = game:GetService("RunService")
local Players    = game:GetService("Players")
local lp         = Players.LocalPlayer

-- ── 1. Clear executor fingerprint globals ─────────────────────────────────────

pcall(function()
    local targets = {
        "SYNAPSE_LOADED","syn","KRNL_LOADED","KRNL_INITIALIZED",
        "fluxus","carbon","Celery","is_sirhurt_closure","ElectroHub",
        "PROTOSMASHER_LOADED","AWP_LOADED","ISLAND_LOADED, Volt, VoltExecutor,
        "Volt_Executor, Delta, DeltaExecutor, Delta_Executor, CodeX, Seliware,
        "Velocity, Solara, Bunni, Pottasium, Volcano, Potassium, RealExecutor,
        "Real_executor, ByteBreaker, Wave, Opiumware, Yub-X, Arceus-X, SynapseZ,
        "Synapse-Z, Cellware, Xeno, Vega-X, VegaX, Zenit, Evon, Romix, Cryptic
    }
    for _,name in ipairs(targets) do
        pcall(function() getgenv()[name]=nil end)
    end
end)

-- ── 2. Identity spoof — multi-method ─────────────────────────────────────────
-- Try all known identity-setting functions across different executors

pcall(function()
    -- Synapse X / KRNL style
    if setidentity   then setidentity(2)    end
    if set_identity  then set_identity(2)   end
    -- Some executors use setthreadidentity
    if setthreadidentity then setthreadidentity(2) end
    -- Direct thread context (Synapse)
    if syn and syn.set_thread_identity then
        syn.set_thread_identity(2)
    end
end)

-- Re-apply identity after each heartbeat since some executors reset it
-- Identity 2 = LocalScript level (looks like a normal game script)
local identityTimer = 0
RunService.Heartbeat:Connect(function(dt)
    identityTimer = identityTimer + dt
    if identityTimer > 1 then
        identityTimer = 0
        pcall(function()
            if setidentity then setidentity(2) end
            if setthreadidentity then setthreadidentity(2) end
        end)
    end
end)

-- ── 3. Humanize timing pattern ────────────────────────────────────────────────

local jitter = 0
RunService.Heartbeat:Connect(function(dt)
    jitter = jitter + dt
    if jitter > (0.04 + math.random() * 0.07) then
        jitter = 0
        local _ = math.random()
    end
end)

-- ── 4. Keep GUI alive ─────────────────────────────────────────────────────────

task.spawn(function()
    while task.wait(5) do
        pcall(function()
            local pg  = lp:FindFirstChild("PlayerGui"); if not pg then return end
            local gui = pg:FindFirstChild("CryptMM2")
            if gui and not gui.Enabled then gui.Enabled=true end
        end)
    end
end)

-- ── 5. Disconnect watchdog ────────────────────────────────────────────────────

lp.OnTeleport:Connect(function(state)
    if state==Enum.TeleportState.Started then
        warn("[Crypt] Teleport detected")
        if _G.Notify then _G.Notify("Warning: Teleport triggered","warn") end
    end
end)

lp.AncestryChanged:Connect(function(_,parent)
    if not parent then warn("[Crypt] Disconnected") end
end)

print("[Crypt] AntiDetect loaded")
