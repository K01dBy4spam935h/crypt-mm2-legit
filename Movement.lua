-- Crypt-MM2-Legit | Local Player

local Players    = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInput  = game:GetService("UserInputService")
local lp         = Players.LocalPlayer
local BASE_SPEED = 16

-- ── Noclip ───────────────────────────────────────────────────────────────────

local noclipConn = nil
local lastNoclip = false

local function setNoclip(on)
    if on then
        if noclipConn then noclipConn:Disconnect() end
        noclipConn = RunService.Stepped:Connect(function()
            local char = lp.Character
            if not char then return end
            for _, p in ipairs(char:GetDescendants()) do
                if p:IsA("BasePart") then p.CanCollide = false end
            end
        end)
    else
        if noclipConn then noclipConn:Disconnect(); noclipConn = nil end
        local char = lp.Character
        if char then
            for _, p in ipairs(char:GetDescendants()) do
                if p:IsA("BasePart") then p.CanCollide = true end
            end
        end
    end
end

RunService.Heartbeat:Connect(function()
    local now = _G.NoclipEnabled or false
    if now ~= lastNoclip then lastNoclip = now; setNoclip(now) end
end)

lp.CharacterAdded:Connect(function()
    task.wait(0.2)
    if _G.NoclipEnabled then setNoclip(true) end
end)

-- ── Speed ────────────────────────────────────────────────────────────────────

RunService.Heartbeat:Connect(function()
    local char = lp.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then return end
    local target = _G.SpeedEnabled
        and (BASE_SPEED * math.clamp(_G.SpeedMultiplier or 1, 1, 3))
        or  BASE_SPEED
    hum.WalkSpeed = hum.WalkSpeed + (target - hum.WalkSpeed) * 0.18
end)

-- ── Infinite Jump ────────────────────────────────────────────────────────────

UserInput.JumpRequest:Connect(function()
    if not _G.InfJumpEnabled then return end
    local char = lp.Character
    local hum  = char and char:FindFirstChildOfClass("Humanoid")
    if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
end)

-- ── Invisibility (client-side) ────────────────────────────────────────────────

local lastInvis = false
RunService.Heartbeat:Connect(function()
    local now  = _G.InvisEnabled or false
    local char = lp.Character
    if not char then return end
    if now == lastInvis then return end
    lastInvis = now
    for _, p in ipairs(char:GetDescendants()) do
        if p:IsA("BasePart") or p:IsA("Decal") then
            p.LocalTransparencyModifier = now and 1 or 0
        end
    end
end)

lp.CharacterAdded:Connect(function(char)
    task.wait(0.2)
    if _G.InvisEnabled then
        for _, p in ipairs(char:GetDescendants()) do
            if p:IsA("BasePart") or p:IsA("Decal") then
                p.LocalTransparencyModifier = 1
            end
        end
    end
end)

-- ── Auto Collect Gun ─────────────────────────────────────────────────────────
-- Method: scan workspace for dropped Gun tool, walk to it naturally
-- using Humanoid:MoveTo() — no teleport, looks like a human player walking

local function findDroppedGun()
    for _, obj in ipairs(workspace:GetDescendants()) do
        -- MM2 drops the gun as a Tool in workspace when sheriff dies
        if obj:IsA("Tool") and (obj.Name == "Gun" or obj.Name:lower():find("gun")) then
            local handle = obj:FindFirstChild("Handle")
            if handle then
                return handle.Position
            end
        end
        -- also check for Model named "Gun" with a PrimaryPart
        if obj:IsA("Model") and (obj.Name == "Gun" or obj.Name:lower():find("gun")) then
            local root = obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")
            if root then return root.Position end
        end
    end
    return nil
end

local autoGunConn = nil
RunService.Heartbeat:Connect(function()
    if not _G.AutoGun then
        if autoGunConn then autoGunConn:Disconnect(); autoGunConn = nil end
        return
    end

    local char = lp.Character
    local hum  = char and char:FindFirstChildOfClass("Humanoid")
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not (hum and root) then return end

    -- already have gun?
    if char:FindFirstChild("Gun") or lp.Backpack:FindFirstChild("Gun") then return end

    local gunPos = findDroppedGun()
    if not gunPos then return end

    -- walk naturally toward it (uses built-in pathfind movement, very natural)
    hum:MoveTo(gunPos)
end)
