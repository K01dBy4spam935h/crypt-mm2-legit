-- Crypt-MM2-Legit | Movement

local Players     = game:GetService("Players")
local RunService  = game:GetService("RunService")
local UserInput   = game:GetService("UserInputService")
local VirtualUser = game:GetService("VirtualUser")
local lp          = Players.LocalPlayer
local BASE_SPEED  = 16

-- ── Noclip ────────────────────────────────────────────────────────────────────

local noclipConn = nil; local lastNoclip = false

local function setNoclip(on)
    if on then
        if noclipConn then noclipConn:Disconnect() end
        noclipConn = RunService.Stepped:Connect(function()
            local char = lp.Character; if not char then return end
            for _, p in ipairs(char:GetDescendants()) do
                if p:IsA("BasePart") then p.CanCollide = false end
            end
        end)
    else
        if noclipConn then noclipConn:Disconnect(); noclipConn = nil end
        task.defer(function()
            local char = lp.Character; if not char then return end
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
    task.wait(0.2); if _G.NoclipEnabled then setNoclip(true) end
end)

-- ── Speed ─────────────────────────────────────────────────────────────────────

RunService.Heartbeat:Connect(function()
    local char = lp.Character; if not char then return end
    local hum  = char:FindFirstChildOfClass("Humanoid"); if not hum then return end
    local mult = math.clamp(_G.SpeedMultiplier or 1, 1, 100)
    local tgt  = _G.SpeedEnabled and (BASE_SPEED * mult) or BASE_SPEED
    hum.WalkSpeed = hum.WalkSpeed + (tgt - hum.WalkSpeed) * 0.18
end)

-- ── Infinite Jump ─────────────────────────────────────────────────────────────

UserInput.JumpRequest:Connect(function()
    if not _G.InfJumpEnabled then return end
    local char = lp.Character
    local hum  = char and char:FindFirstChildOfClass("Humanoid")
    if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
end)

-- ── Fly ───────────────────────────────────────────────────────────────────────

local flyConn = nil; local lastFly = false

local function applyFly(on)
    local char = lp.Character; if not char then return end
    local hrp  = char:FindFirstChild("HumanoidRootPart"); if not hrp then return end
    local hum  = char:FindFirstChildOfClass("Humanoid"); if not hum then return end
    local oldBV = hrp:FindFirstChild("CryptBV"); if oldBV then oldBV:Destroy() end
    local oldBG = hrp:FindFirstChild("CryptBG"); if oldBG then oldBG:Destroy() end
    if flyConn then flyConn:Disconnect(); flyConn = nil end
    if not on then hum.PlatformStand = false; return end
    hum.PlatformStand = true
    local bv = Instance.new("BodyVelocity"); bv.Name = "CryptBV"; bv.MaxForce = Vector3.new(1e5,1e5,1e5); bv.Velocity = Vector3.zero; bv.Parent = hrp
    local bg = Instance.new("BodyGyro");    bg.Name = "CryptBG"; bg.MaxTorque = Vector3.new(1e5,1e5,1e5); bg.CFrame = hrp.CFrame; bg.Parent = hrp
    flyConn = RunService.RenderStepped:Connect(function()
        if not _G.FlyEnabled then return end
        local cam   = workspace.CurrentCamera
        local speed = _G.FlySpeed or 60
        local dir   = Vector3.zero
        if UserInput:IsKeyDown(Enum.KeyCode.W) then dir = dir + cam.CFrame.LookVector  end
        if UserInput:IsKeyDown(Enum.KeyCode.S) then dir = dir - cam.CFrame.LookVector  end
        if UserInput:IsKeyDown(Enum.KeyCode.A) then dir = dir - cam.CFrame.RightVector end
        if UserInput:IsKeyDown(Enum.KeyCode.D) then dir = dir + cam.CFrame.RightVector end
        if UserInput:IsKeyDown(Enum.KeyCode.Space)       then dir = dir + Vector3.new(0,1,0) end
        if UserInput:IsKeyDown(Enum.KeyCode.LeftControl) then dir = dir - Vector3.new(0,1,0) end
        bv.Velocity = dir.Magnitude > 0 and dir.Unit * speed or Vector3.zero
        bg.CFrame   = cam.CFrame
    end)
end

RunService.Heartbeat:Connect(function()
    local now = _G.FlyEnabled or false
    if now ~= lastFly then lastFly = now; applyFly(now) end
end)
lp.CharacterAdded:Connect(function() task.wait(0.3); lastFly = false; if _G.FlyEnabled then applyFly(true) end end)
_G.SetFly = applyFly

-- ── Invisibility — continuous reapplication every frame ───────────────────────
-- Applying Transparency=1 every Heartbeat ensures MM2 can't reset it faster than we set it

local invisHL   = nil
local lastInvis = false
local invisActive = false

local function buildInvisHL(char)
    if invisHL and invisHL.Parent then return end
    invisHL = Instance.new("Highlight")
    invisHL.DepthMode           = Enum.HighlightDepthMode.AlwaysOnTop
    invisHL.FillTransparency    = 1
    invisHL.OutlineTransparency = 0.1
    invisHL.OutlineColor        = Color3.fromRGB(255, 255, 255)
    invisHL.Adornee             = char
    invisHL.Parent              = char
end

RunService.Heartbeat:Connect(function()
    local now  = _G.InvisEnabled or false
    local char = lp.Character
    if not char then return end

    if now then
        invisActive = true
        -- Continuous re-application: wins race against any server reset
        for _, p in ipairs(char:GetDescendants()) do
            if p:IsA("BasePart") and p.Name ~= "HumanoidRootPart" then
                p.Transparency = 1
                p.LocalTransparencyModifier = 0  -- you still see yourself
            end
            if p:IsA("Decal") then
                pcall(function() p.Transparency = 1 end)
            end
        end
        buildInvisHL(char)
        if not lastInvis then
            lastInvis = true
            -- Destroy accessories once (they replicate)
            for _, acc in ipairs(char:GetChildren()) do
                if acc:IsA("Accessory") then acc:Destroy() end
            end
            if _G.Notify then _G.Notify("Invisibility ON", "success") end
        end
    else
        if invisActive then
            invisActive = false
            lastInvis   = false
            if invisHL then invisHL:Destroy(); invisHL = nil end
            if _G.Notify then _G.Notify("Rejoin to restore appearance fully", "warn") end
        end
    end
end)

lp.CharacterAdded:Connect(function()
    task.wait(0.3); invisActive = false; lastInvis = false
    if invisHL then invisHL:Destroy(); invisHL = nil end
end)

-- ── Gun Drop — continuous instant grab (uses provided working logic) ──────────

local function findGunDrop()
    -- Direct workspace child first (fastest path)
    local gun = workspace:FindFirstChild("GunDrop")
    if gun then return gun end
    -- Search inside map containers (MM2 sometimes nests under Normal/Map)
    for _, obj in ipairs(workspace:GetChildren()) do
        if obj.Name == "Normal" or obj:FindFirstChild("CoinContainer") or obj.Name:match("Map") then
            local hidden = obj:FindFirstChild("GunDrop", true)
            if hidden then return hidden end
        end
    end
    return nil
end

local function getGunPart(gunDrop)
    if not gunDrop then return nil end
    if gunDrop:IsA("BasePart") then return gunDrop end
    if gunDrop:FindFirstChild("Handle") then return gunDrop.Handle end
    for _, child in ipairs(gunDrop:GetChildren()) do
        if child:IsA("BasePart") then return child end
    end
    return nil
end

-- Run as continuous loop — checks every 0.1s, instant when GunDrop appears
task.spawn(function()
    while true do
        task.wait(0.1)
        if not _G.AutoGun then continue end

        local char = lp.Character; if not char then continue end
        local root = char:FindFirstChild("HumanoidRootPart"); if not root then continue end
        local bp   = lp:FindFirstChild("Backpack")

        -- Skip if we already have gun
        if char:FindFirstChild("Gun") or (bp and bp:FindFirstChild("Gun")) then continue end

        local gunInstance = findGunDrop()
        local targetPart  = getGunPart(gunInstance)

        if targetPart and firetouchinterest then
            -- Primary method: firetouchinterest
            pcall(function()
                firetouchinterest(root, targetPart, 0)
                task.wait(0.02)
                firetouchinterest(root, targetPart, 1)
            end)
            -- Backup: CFrame the drop to player
            pcall(function()
                if gunInstance:IsA("Model") and gunInstance.PrimaryPart then
                    gunInstance:SetPrimaryPartCFrame(root.CFrame)
                elseif gunInstance:IsA("BasePart") then
                    gunInstance.CFrame = root.CFrame
                end
            end)
            -- Verify collected after brief wait
            task.wait(0.3)
            local c = lp.Character; local b = lp:FindFirstChild("Backpack")
            if (c and c:FindFirstChild("Gun")) or (b and b:FindFirstChild("Gun")) then
                if _G.Notify then _G.Notify("Gun collected!", "success") end
            end
        end
    end
end)

-- ── Anti-AFK ─────────────────────────────────────────────────────────────────

local afkTimer = 0
RunService.Heartbeat:Connect(function(dt)
    if not _G.AntiAFK then return end
    afkTimer = afkTimer + dt
    if afkTimer < 20 then return end
    afkTimer = 0
    pcall(function()
        VirtualUser:MouseMoveRel(Vector2.new(1, 0))
        task.wait(0.05)
        VirtualUser:MouseMoveRel(Vector2.new(-1, 0))
    end)
end)

-- ── Coin Farm — from provided working logic ───────────────────────────────────

local GatheredInstances = {}

local function findNextValidCoin()
    local char = lp.Character
    if not char then return nil end

    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") and not GatheredInstances[obj] then
            local nameLower = obj.Name:lower()

            if nameLower:find("coin") or nameLower:find("gold") or nameLower:find("token") then
                -- Not part of player character and not underground
                if not obj:IsDescendantOf(char) and obj.Position.Y > -45 then
                    -- Has touch interest or is a real pickup
                    if obj:FindFirstChild("TouchInterest")
                    or obj.Parent:FindFirstChild("TouchInterest")
                    or not nameLower:find("visual") then
                        return obj
                    end
                end
            end
        end
    end
    return nil
end

local function getMurdererPosition()
    for _, player in ipairs(Players:GetPlayers()) do
        if player == lp then continue end
        local role = _G.RoleCache and _G.RoleCache[player]
        if role == "Murderer" then
            local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
            if root then return root.Position end
        end
    end
    return nil
end

-- Coin farm loop — runs every 0.15s, efficient, uses memory-hash dedup
task.spawn(function()
    while true do
        task.wait(0.15)
        if not _G.CoinFarm then
            -- Clear gathered list when turned off so it resets for next round
            if next(GatheredInstances) then GatheredInstances = {} end
            continue
        end

        -- Auto-enable noclip for smooth farm
        if not _G.NoclipEnabled then _G.NoclipEnabled = true end

        local char = lp.Character; if not char then continue end
        local hrp  = char:FindFirstChild("HumanoidRootPart"); if not hrp then continue end

        -- Anti-murderer safety
        local murdPos   = _G.CoinAntiMurd and getMurdererPosition() or nil
        local safeRange = _G.CoinSafetyRadius or 15

        local coin = findNextValidCoin()
        if coin and coin.Parent then
            -- Anti-murderer: skip if coin is too close to murderer
            if murdPos and (coin.Position - murdPos).Magnitude < safeRange then
                GatheredInstances[coin] = true  -- mark as skipped for now
                continue
            end

            pcall(function()
                firetouchinterest(hrp, coin, 0)
                task.wait(0.02)
                firetouchinterest(hrp, coin, 1)
            end)

            -- Mark as gathered so we don't hit it again
            GatheredInstances[coin] = true
        else
            -- All coins cleared or round ended — reset for next batch
            if not coin then
                task.wait(2)
                GatheredInstances = {}
            end
        end
    end
end)

-- ── Teleport helpers ──────────────────────────────────────────────────────────

_G.TeleportToRole = function(role)
    local char = lp.Character
    local hrp  = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then
        if _G.Notify then _G.Notify("No character", "error") end; return
    end
    for _, player in ipairs(Players:GetPlayers()) do
        if player == lp then continue end
        if (_G.RoleCache and _G.RoleCache[player]) == role then
            local pChar = player.Character
            local pRoot = pChar and pChar:FindFirstChild("HumanoidRootPart")
            if pRoot then
                hrp.CFrame = pRoot.CFrame + pRoot.CFrame.LookVector * 4
                if _G.Notify then _G.Notify("Teleported to " .. role, "success") end
                return
            end
        end
    end
    if _G.Notify then _G.Notify(role .. " not detected yet", "warn") end
end

_G.TeleportToMap = function()
    local char = lp.Character
    local hrp  = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    for _, obj in ipairs(workspace:GetChildren()) do
        if obj.Name == "Normal" or obj:FindFirstChild("CoinContainer") or obj.Name:lower():find("map") then
            local cf
            if obj:IsA("Model") then
                pcall(function() cf = obj:GetModelCFrame() end)
            elseif obj:IsA("BasePart") then
                cf = obj.CFrame
            end
            if cf then
                hrp.CFrame = cf * CFrame.new(0, 10, 0)
                if _G.Notify then _G.Notify("Teleported to map center", "success") end
                return
            end
        end
    end
    hrp.CFrame = CFrame.new(0, 20, 0)
    if _G.Notify then _G.Notify("Teleported to origin", "info") end
end
