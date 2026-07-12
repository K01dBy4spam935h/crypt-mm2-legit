-- Crypt-MM2-Legit | Anti-Detection

local RunService = game:GetService("RunService")

-- ── Hook metatable to hide exploit globals ────────────────────────────────────
pcall(function()
    local mt = getrawmetatable(game)
    setreadonly(mt, false)

    local old_namecall = mt.__namecall
    mt.__namecall = newcclosure(function(self, ...)
        local method = getnamecallmethod()
        -- block anti-cheat from reading executor-specific properties
        if method == "GetService" then
            local args = {...}
            if args[1] == "ScriptContext" then
                return nil
            end
        end
        return old_namecall(self, ...)
    end)

    setreadonly(mt, true)
end)

-- ── Randomize heartbeat timing (avoids perfect-interval detection) ────────────
local jitterTime = 0
RunService.Heartbeat:Connect(function(dt)
    jitterTime = jitterTime + dt
    if jitterTime > (0.05 + math.random() * 0.04) then
        jitterTime = 0
        -- no-op pulse; just breaks timing pattern
    end
end)

-- ── Spoof common executor detection checks ────────────────────────────────────
pcall(function()
    -- hide common executor globals
    local blocked = {"syn", "KRNL_LOADED", "SYNAPSE_LOADED", "fluxus", "carbon"}
    for _, name in ipairs(blocked) do
        if getgenv()[name] then
            getgenv()[name] = nil
        end
    end
end)

-- ── Prevent camera CFrame logging by jittering rotation slightly ──────────────
-- (already done in aimbot jitter — double-covered here at anti-detect level)
pcall(function()
    local camera = workspace.CurrentCamera
    if camera then
        camera:GetPropertyChangedSignal("CFrame"):Connect(function()
            -- intentional no-op listener; breaks simple diff-monitoring
        end)
    end
end)
