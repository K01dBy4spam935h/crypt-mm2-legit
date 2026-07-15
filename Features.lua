-- Crypt-MM2-Legit | Features — hitbox all directions, knife aura, auto stab

local Players    = game:GetService("Players")
local RunService = game:GetService("RunService")
local lp         = Players.LocalPlayer

-- ── Hitbox Expander — expands EVERY part (not just HumanoidRootPart) ──────────
-- Expanding only HumanoidRootPart gives up/down bias.
-- Expanding all parts gives full spherical coverage in all directions.

local origSizes = {}  -- [player][part] = originalSize

RunService.Heartbeat:Connect(function()
    for _, player in ipairs(Players:GetPlayers()) do
        if player == lp then continue end
        local char = player.Character; if not char then continue end

        if _G.HitboxEnabled then
            if not origSizes[player] then origSizes[player] = {} end
            local sz = _G.HitboxSize or 6

            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") then
                    -- Save original size
                    if not origSizes[player][part] then
                        origSizes[player][part] = part.Size
                    end
                    -- Expand uniformly in all 3 axes
                    part.Size        = Vector3.new(sz, sz, sz)
                    part.CanCollide  = false   -- walk through
                    part.LocalTransparencyModifier = 1   -- hide visual
                end
            end
        else
            -- Restore all parts
            if origSizes[player] then
                for part, origSize in pairs(origSizes[player]) do
                    pcall(function()
                        part.Size       = origSize
                        part.CanCollide = true
                        part.LocalTransparencyModifier = 0
                    end)
                end
                origSizes[player] = nil
            end
        end
    end
end)

Players.PlayerRemoving:Connect(function(p) origSizes[p] = nil end)

-- ── Knife Aura ────────────────────────────────────────────────────────────────

local auraCD = 0

RunService.Heartbeat:Connect(function(dt)
    if not _G.KnifeAura then return end
    auraCD = auraCD - dt
    if auraCD > 0 then return end
    auraCD = 0.08 + math.random() * 0.04

    local char   = lp.Character; if not char then return end
    local hrp    = char:FindFirstChild("HumanoidRootPart"); if not hrp then return end
    local knife  = char:FindFirstChild("Knife"); if not knife then return end
    local handle = knife:FindFirstChild("Handle"); if not handle then return end
    local range  = _G.KnifeAuraRange or 15

    for _, player in ipairs(Players:GetPlayers()) do
        if player == lp then continue end
        local pChar = player.Character; if not pChar then continue end
        local pHum  = pChar:FindFirstChildOfClass("Humanoid"); if not pHum or pHum.Health <= 0 then continue end
        local pRoot = pChar:FindFirstChild("HumanoidRootPart"); if not pRoot then continue end

        if (hrp.Position - pRoot.Position).Magnitude <= range then
            -- Fire on all body parts for all-around coverage
            for _, part in ipairs(pChar:GetDescendants()) do
                if part:IsA("BasePart") then
                    pcall(function()
                        firetouchinterest(handle, part, 0)
                        firetouchinterest(handle, part, 1)
                    end)
                end
            end
        end
    end
end)

-- ── Auto Stab ─────────────────────────────────────────────────────────────────

local stabCD = 0

RunService.Heartbeat:Connect(function(dt)
    if not _G.AutoStab then return end
    stabCD = stabCD - dt
    if stabCD > 0 then return end

    local char   = lp.Character; if not char then return end
    local hrp    = char:FindFirstChild("HumanoidRootPart"); if not hrp then return end
    local knife  = char:FindFirstChild("Knife"); if not knife then return end
    local handle = knife:FindFirstChild("Handle"); if not handle then return end
    local range  = _G.KnifeAuraRange or 15

    local closest, closestDist = nil, range

    for _, player in ipairs(Players:GetPlayers()) do
        if player == lp then continue end
        local pChar = player.Character; if not pChar then continue end
        local pHum  = pChar:FindFirstChildOfClass("Humanoid"); if not pHum or pHum.Health <= 0 then continue end
        local pRoot = pChar:FindFirstChild("HumanoidRootPart"); if not pRoot then continue end
        local dist  = (hrp.Position - pRoot.Position).Magnitude
        if dist < closestDist then closestDist = dist; closest = pChar end
    end

    if closest then
        for _, part in ipairs(closest:GetDescendants()) do
            if part:IsA("BasePart") then
                pcall(function()
                    firetouchinterest(handle, part, 0)
                    firetouchinterest(handle, part, 1)
                end)
            end
        end
        stabCD = 0.35 + math.random() * 0.15
    end
end)
