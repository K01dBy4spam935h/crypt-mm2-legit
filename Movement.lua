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
        task.defer(function()
            local char = lp.Character
            if not char then return end
            for _, p in ipairs(char:GetDescendants()) do
                if p:IsA("BasePart") then p.CanCollide = true end
            end
        end)
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
    local tgt = _G.SpeedEnabled and (BASE_SPEED * math.clamp(_G.SpeedMultiplier or 1, 1, 3)) or BASE_SPEED
    hum.WalkSpeed = hum.WalkSpeed + (tgt - hum.WalkSpeed) * 0.18
end)

-- ── Infinite Jump ─────────────────────────────────────────────────────────────

UserInput.JumpRequest:Connect(function()
    if not _G.InfJumpEnabled then return end
    local char = lp.Character
    local hum  = char and char:FindFirstChildOfClass("Humanoid")
    if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
end)

-- ── Invisibility (server-visible via character ownership) ─────────────────────
-- Your character is owned by your client — Transparency changes replicate to server
-- Others will see you as fully invisible
-- You see an outline of yourself via a local Highlight

local invisHighlight = nil
local lastInvis = false

local function applyInvis(on)
    local char = lp.Character
    if not char then return end

    for _, p in ipairs(char:GetDescendants()) do
        if p:IsA("BasePart") and p.Name ~= "HumanoidRootPart" then
            p.Transparency = on and 1 or 0   -- replicates to server
        end
        if p:IsA("Decal") or p:IsA("SpecialMesh") then
            pcall(function() p.Transparency = on and 1 or 0 end)
        end
    end
    for _, acc in ipairs(char:GetChildren()) do
        if acc:IsA("Accessory") then
            local h = acc:FindFirstChild("Handle")
            if h then h.Transparency = on and 1 or 0 end
        end
    end

    -- Local outline so you can still see yourself
    if on then
        if not invisHighlight or not invisHighlight.Parent then
            invisHighlight = Instance.new("Highlight")
            invisHighlight.DepthMode          = Enum.HighlightDepthMode.AlwaysOnTop
            invisHighlight.FillTransparency   = 1      -- no fill
            invisHighlight.OutlineTransparency = 0.3   -- visible outline only
            invisHighlight.OutlineColor       = Color3.fromRGB(255, 255, 255)
            invisHighlight.Adornee            = char
            invisHighlight.Parent             = char
        end
    else
        if invisHighlight then
            invisHighlight:Destroy()
            invisHighlight = nil
        end
    end
end

RunService.Heartbeat:Connect(function()
    local now = _G.InvisEnabled or false
    if now ~= lastInvis then
        lastInvis = now
        applyInvis(now)
        if _G.Notify then
            _G.Notify(now and "Invisibility ON (server)" or "Invisibility OFF", now and "success" or "info")
        end
    end
end)

lp.CharacterAdded:Connect(function()
    task.wait(0.3)
    if _G.InvisEnabled then applyInvis(true) end
end)

-- ── Auto Collect Gun — firetouchinterest (instant, no movement, no lag) ───────
-- firetouchinterest() fires a .Touched event between two parts without moving
-- MM2 gun pickup is triggered by touch — this works perfectly

local autoGunCooldown = 0

RunService.Heartbeat:Connect(function(dt)
    if not _G.AutoGun then return end

    autoGunCooldown = autoGunCooldown - dt
    if autoGunCooldown > 0 then return end  -- throttle: only run every 0.5s
    autoGunCooldown = 0.5

    local char = lp.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    -- already have gun?
    if char:FindFirstChild("Gun") then return end
    if lp.Backpack:FindFirstChild("Gun") then return end

    -- find dropped gun handle in workspace
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("Tool") and obj.Name:lower():find("gun") and obj.Parent ~= char and obj.Parent ~= lp.Backpack then
            local handle = obj:FindFirstChild("Handle")
            if handle then
                -- fire touch without moving — zero lag
                pcall(function()
                    firetouchinterest(hrp, handle, 0)
                    firetouchinterest(hrp, handle, 1)
                end)
                if _G.Notify then _G.Notify("Gun collected!", "success") end
                return
            end
        end
        -- also handle Part named "GunDrop" or similar MM2 patterns
        if obj:IsA("BasePart") and (obj.Name:lower():find("gun") or obj.Name:lower():find("drop")) then
            pcall(function()
                firetouchinterest(hrp, obj, 0)
                firetouchinterest(hrp, obj, 1)
            end)
        end
    end
end)

-- ── Anti-AFK ─────────────────────────────────────────────────────────────────

local afkConn = nil
RunService.Heartbeat:Connect(function()
    if _G.AntiAFK then
        if not afkConn then
            afkConn = task.spawn(function()
                while _G.AntiAFK do
                    local v = lp.Character and lp.Character:FindFirstChildOfClass("Humanoid")
                    if v then v.Jump = true end
                    task.wait(55)
                end
            end)
        end
    else
        afkConn = nil
    end
end)

-- ── Coin Farm ────────────────────────────────────────────────────────────────

local coinCooldown = 0
RunService.Heartbeat:Connect(function(dt)
    if not _G.CoinFarm then return end
    coinCooldown = coinCooldown - dt
    if coinCooldown > 0 then return end
    coinCooldown = 0.3

    local char = lp.Character
    local hrp  = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj.Name == "Coin" or obj.Name:lower():find("coin") then
            if obj:IsA("BasePart") then
                pcall(function()
                    firetouchinterest(hrp, obj, 0)
                    firetouchinterest(hrp, obj, 1)
                end)
            end
        end
    end
end)
