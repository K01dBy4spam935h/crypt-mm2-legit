-- Crypt-MM2-Legit | Movement — noclip fix

local Players    = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInput  = game:GetService("UserInputService")
local lp         = Players.LocalPlayer

local BASE_SPEED = 16
local noclipConn = nil

-- ─── Noclip ──────────────────────────────────────────────────────────────────
-- Store original CanCollide state and restore it properly on disable

local function setNoclip(state)
    if state then
        -- start loop
        if noclipConn then noclipConn:Disconnect() end
        noclipConn = RunService.Stepped:Connect(function()
            local char = lp.Character
            if not char then return end
            for _, p in ipairs(char:GetDescendants()) do
                if p:IsA("BasePart") and p.CanCollide then
                    p.CanCollide = false
                end
            end
        end)
    else
        -- stop loop and restore collision
        if noclipConn then
            noclipConn:Disconnect()
            noclipConn = nil
        end
        -- force re-enable collision on all parts
        local char = lp.Character
        if char then
            for _, p in ipairs(char:GetDescendants()) do
                if p:IsA("BasePart") then
                    p.CanCollide = true
                end
            end
        end
    end
end

-- watch for toggle changes
local lastNoclip = false
RunService.Heartbeat:Connect(function()
    local now = _G.NoclipEnabled or false
    if now ~= lastNoclip then
        lastNoclip = now
        setNoclip(now)
    end
end)

-- re-apply on character respawn
lp.CharacterAdded:Connect(function()
    task.wait(0.1)
    if _G.NoclipEnabled then setNoclip(true) end
end)

-- ─── Speed Hack ──────────────────────────────────────────────────────────────

RunService.Heartbeat:Connect(function()
    local char = lp.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then return end

    if _G.SpeedEnabled then
        local mult   = math.clamp(_G.SpeedMultiplier or 1, 1, 3)
        local target = BASE_SPEED * mult
        -- smooth ramp to avoid spike
        hum.WalkSpeed = hum.WalkSpeed + (target - hum.WalkSpeed) * 0.2
    else
        -- smooth restore to default
        if math.abs(hum.WalkSpeed - BASE_SPEED) > 0.05 then
            hum.WalkSpeed = hum.WalkSpeed + (BASE_SPEED - hum.WalkSpeed) * 0.2
        else
            hum.WalkSpeed = BASE_SPEED
        end
    end
end)

-- ─── Infinite Jump ───────────────────────────────────────────────────────────

UserInput.JumpRequest:Connect(function()
    if not _G.InfJumpEnabled then return end
    local char = lp.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum then
        hum:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end)
