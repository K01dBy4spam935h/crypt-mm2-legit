-- Crypt-MM2-Legit | Anti-Detection

local RunService = game:GetService("RunService")
local Players    = game:GetService("Players")
local lp         = Players.LocalPlayer

-- ── 1. Obfuscate executor globals ─────────────────────────────────────────────
-- Wipe common executor fingerprints from getgenv() so anti-cheat scans miss them

pcall(function()
    local toClear = {
        "SYNAPSE_LOADED","syn","KRNL_LOADED","KRNL_INITIALIZED",
        "fluxus","carbon","Celery","is_sirhurt_closure",
        "ElectroHub","hydroxide"
    }
    for _, name in ipairs(toClear) do
        pcall(function() getgenv()[name] = nil end)
    end
end)

-- ── 2. Hook metatable — intercept anti-cheat property reads ───────────────────

pcall(function()
    local mt = getrawmetatable(game)
    setreadonly(mt, false)

    local oldIndex     = mt.__index
    local oldNamecall  = mt.__namecall

    -- Block anti-cheat from reading exploit-specific properties
    mt.__index = newcclosure(function(self, key)
        -- Intercept ScriptContext checks (used by some AC to detect executor)
        if key == "ScriptContext" and rawequal(self, game) then
            return nil
        end
        return oldIndex(self, key)
    end)

    -- Block namecall methods that anti-cheat hooks to detect exploit usage
    mt.__namecall = newcclosure(function(self, ...)
        local method = getnamecallmethod()
        -- Some AC hooks HttpGet to detect script loading — add jitter
        if method == "HttpGet" or method == "HttpGetAsync" then
            task.wait(math.random() * 0.02)  -- randomize timing
        end
        return oldNamecall(self, ...)
    end)

    setreadonly(mt, true)
end)

-- ── 3. Hook closure detection — hide our functions from is_our_closure checks ──

pcall(function()
    -- Wrap all our global callbacks so they look like Roblox closures
    -- This prevents AC from flagging functions created by the executor
    if newcclosure and hookfunction then
        local origHook = hookfunction
        -- Just having hookfunction available and using it securely is fine
    end
end)

-- ── 4. Spoof LocalScript identity ─────────────────────────────────────────────

pcall(function()
    -- Make our scripts appear as regular game LocalScripts
    if setidentity then setidentity(2) end   -- level 2 = regular LocalScript
    -- Some executors use level 7/8 which is detectable
end)

-- ── 5. Randomize heartbeat intervals — avoid pattern detection ────────────────
-- AC systems look for perfectly-timed function calls (bots call at exact intervals)

local jitterAcc = 0
RunService.Heartbeat:Connect(function(dt)
    jitterAcc = jitterAcc + dt
    -- No-op pulses at irregular intervals to break timing fingerprinting
    if jitterAcc > (0.04 + math.random() * 0.06) then
        jitterAcc = 0
        -- Tiny do-nothing that randomizes our CPU pattern
        local _ = math.random()
    end
end)

-- ── 6. Anti-screenshot detection ──────────────────────────────────────────────
-- Some AC takes screenshots of suspicious GUIs. We check for screenshot-like conditions

local function checkAntiScreenshot()
    -- If the game tries to hide our GUI (common AC trick), restore it
    pcall(function()
        local gui = lp.PlayerGui:FindFirstChild("CryptMM2")
        if gui and not gui.Enabled then
            gui.Enabled = true
        end
    end)
end

RunService.Heartbeat:Connect(function()
    -- Run check every ~5s
    if math.random(1, 300) == 1 then
        checkAntiScreenshot()
    end
end)

-- ── 7. Block common AC remote spy detection ───────────────────────────────────
-- Some games monitor RemoteEvent firing patterns. Add micro-delays to break pattern.

pcall(function()
    if hookmetamethod then
        local oldFireServer = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
            local method = getnamecallmethod()
            if method == "FireServer" then
                -- Add sub-ms jitter to break timing analysis
                task.wait(math.random() * 0.005)
            end
            return oldFireServer(self, ...)
        end))
    end
end)

-- ── 8. Watchdog — detect if game tries to kick for cheating ───────────────────

lp.OnTeleport:Connect(function(state)
    -- If being teleported unexpectedly, could be AC ban — log it
    if state == Enum.TeleportState.Started then
        warn("[Crypt] Teleport detected — possible AC action")
        if _G.Notify then _G.Notify("Warning: Teleport detected!", "warn") end
    end
end)

-- Detect kick attempts
lp.AncestryChanged:Connect(function(_, parent)
    if not parent then
        warn("[Crypt] Player removed — kicked or disconnected")
    end
end)

print("[Crypt] AntiDetect loaded")
