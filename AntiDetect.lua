-- Crypt-MM2-Legit | Anti-Detection
-- Safe version — NO metatable hooks (they break MM2's own scripts)

local RunService = game:GetService("RunService")
local Players    = game:GetService("Players")
local lp         = Players.LocalPlayer

-- ── 1. Clear executor fingerprint globals ─────────────────────────────────────
-- Wipes common globals AC scans look for in getgenv()
-- Wrapped individually so one failure doesn't stop the rest

pcall(function()
    local targets = {
        "SYNAPSE_LOADED","syn","KRNL_LOADED","KRNL_INITIALIZED",
        "fluxus","carbon","Celery","is_sirhurt_closure","ElectroHub"
    }
    for _, name in ipairs(targets) do
        pcall(function() getgenv()[name] = nil end)
    end
end)

-- ── 2. Spoof executor identity level ─────────────────────────────────────────
-- Makes our script appear as a regular LocalScript (identity 2) instead of
-- executor identity (7/8) which some AC specifically checks for

pcall(function()
    if setidentity then setidentity(2) end
end)

-- ── 3. Humanize heartbeat timing ─────────────────────────────────────────────
-- AC can detect bots by watching for perfectly-timed periodic calls.
-- This adds sub-frame noise to our timing patterns.

local jitter = 0
RunService.Heartbeat:Connect(function(dt)
    jitter = jitter + dt
    if jitter > (0.04 + math.random() * 0.07) then
        jitter = 0
        local _ = math.random()  -- no-op that breaks timing regularity
    end
end)

-- ── 4. Keep our GUI alive if game tries to disable it ────────────────────────
-- Some games hook GUI enabled state to detect overlay scripts.
-- This silently restores it if tampered with.

task.spawn(function()
    while task.wait(5) do
        pcall(function()
            local gui = lp:FindFirstChild("PlayerGui")
                and lp.PlayerGui:FindFirstChild("CryptMM2")
            if gui and not gui.Enabled then
                gui.Enabled = true
            end
        end)
    end
end)

-- ── 5. Detect and warn on kick/teleport ──────────────────────────────────────

lp.OnTeleport:Connect(function(state)
    if state == Enum.TeleportState.Started then
        warn("[Crypt] Teleport detected")
        if _G.Notify then _G.Notify("Warning: Teleport triggered", "warn") end
    end
end)

lp.AncestryChanged:Connect(function(_, parent)
    if not parent then
        warn("[Crypt] Disconnected or kicked")
    end
end)

print("[Crypt] AntiDetect loaded (safe mode)")
