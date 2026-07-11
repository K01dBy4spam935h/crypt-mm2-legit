-- Crypt-MM2-Legit | Noclip + Speedhack + Infinite Jump

local Players    = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInput  = game:GetService("UserInputService")
local lp         = Players.LocalPlayer

-- ─── Noclip ───────────────────────────────────────────────────────────────────

RunService.Stepped:Connect(function()
    if not _G.NoclipEnabled then return end
    local char = lp.Character
    if not char then return end
    for _, part in ipairs(char:GetDescendants()) do
        if part:IsA("BasePart") then
            part.CanCollide = false
        end
    end
end)

-- ─── Speed Hack ───────────────────────────────────────────────────────────────
-- Keeps multiplier subtle (1-3x) to avoid anti-cheat velocity flags

local BASE_SPEED = 16  -- Roblox default walk speed

RunService.Heartbeat:Connect(function()
    local char = lp.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then return end

    if _G.SpeedEnabled then
        local mult = math.clamp(_G.SpeedMultiplier or 1, 1, 3)
        -- Gradual ramp to avoid spike detection
        local target = BASE_SPEED * mult
        hum.WalkSpeed = hum.WalkSpeed + (target - hum.WalkSpeed) * 0.15
    else
        -- Restore default smoothly
        hum.WalkSpeed = hum.WalkSpeed + (BASE_SPEED - hum.WalkSpeed) * 0.15
    end
end)

-- ─── Infinite Jump ────────────────────────────────────────────────────────────

UserInput.JumpRequest:Connect(function()
    if not _G.InfJumpEnabled then return end
    local char = lp.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum then
        hum:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end)
