-- Crypt-MM2-Legit | Silent Aim + Auto Throw
-- Uses hookmetamethod on ShootGun/ThrowKnife remotes — murderer targets only

local Players    = game:GetService("Players")
local RunService = game:GetService("RunService")
local lp         = Players.LocalPlayer
local Mouse      = lp:GetMouse()

-- ── UI ────────────────────────────────────────────────────────────────────────

local page = _G.Pages["Sheriff"].page
local saS  = _G.UI:MakeSection(page, "Silent Aim", 1)

_G.UI:Toggle(saS, "Enable Silent Aim",  false, function(v) _G.SilentAim     = v end, 1)
_G.UI:Toggle(saS, "Auto Throw (Knife)", false, function(v) _G.AutoThrow     = v end, 2)
_G.UI:Label(saS,  "Targets Murderer only — server-side redirect", 3)
_G.UI:Label(saS,  "Auto Throw fires knife at murderer automatically", 4)

_G.SilentAim  = false
_G.AutoThrow  = false

-- ── Target finder — murderer only ─────────────────────────────────────────────
-- Uses mouse proximity (same logic as reference) but filters by role

local TargetPart = nil

local function GetMurdererTarget()
    local closestPlayer = nil
    local shortestDist  = math.huge

    for _, player in ipairs(Players:GetPlayers()) do
        if player == lp then continue end
        if not player.Character then continue end
        local root = player.Character:FindFirstChild("HumanoidRootPart"); if not root then continue end
        local hum  = player.Character:FindFirstChildOfClass("Humanoid"); if not hum or hum.Health <= 0 then continue end

        -- Murderer only filter
        local role = _G.RoleCache and _G.RoleCache[player]
        if role ~= "Murderer" then continue end

        local screenPos, onScreen = workspace.CurrentCamera:WorldToViewportPoint(root.Position)
        if not onScreen then continue end

        local mousePos = Vector2.new(Mouse.X, Mouse.Y)
        local targetPos = Vector2.new(screenPos.X, screenPos.Y)
        local dist = (mousePos - targetPos).Magnitude

        if dist < shortestDist then
            -- Line of sight check (same as reference)
            local rayParam = RaycastParams.new()
            rayParam.FilterDescendantsInstances = {lp.Character, player.Character}
            rayParam.FilterType = Enum.RaycastFilterType.Exclude

            local origin    = workspace.CurrentCamera.CFrame.Position
            local direction = root.Position - origin
            local result    = workspace:Raycast(origin, direction, rayParam)

            if not result then
                closestPlayer  = root
                shortestDist   = dist
            end
        end
    end
    return closestPlayer
end

-- Track target every frame — same as reference
RunService.RenderStepped:Connect(function()
    if _G.SilentAim or _G.AutoThrow then
        TargetPart = GetMurdererTarget()
    else
        TargetPart = nil
    end
end)

-- ── hookmetamethod — intercepts ShootGun and ThrowKnife remotes ───────────────
-- Exact same method as reference, extended with AutoThrow support
-- Only fires if SilentAim or AutoThrow is enabled

local OldNamecall
pcall(function()
    OldNamecall = hookmetamethod(game, "__namecall", function(Self, ...)
        local Method = getnamecallmethod()
        local Args   = {...}

        if not checkcaller() and (Method == "FireServer" or Method == "fireServer") then
            -- Silent aim: redirect ShootGun (sheriff) to murderer
            if Self.Name == "ShootGun" and _G.SilentAim then
                if TargetPart then
                    Args[1] = TargetPart.Position
                end
            end

            -- Auto throw: redirect ThrowKnife (murderer) to murderer target
            -- (murderer targets nearest innocent in auto throw mode)
            if Self.Name == "ThrowKnife" and _G.AutoThrow then
                if TargetPart then
                    Args[1] = TargetPart.Position
                end
            end
        end

        return OldNamecall(Self, table.unpack(Args))
    end)
end)

-- ── Auto Throw loop — fires knife remote automatically ────────────────────────

local autoThrowCD = 0
RunService.Heartbeat:Connect(function(dt)
    if not _G.AutoThrow then return end
    autoThrowCD = autoThrowCD - dt
    if autoThrowCD > 0 then return end
    if not TargetPart then return end

    local char = lp.Character; if not char then return end
    local knife = char:FindFirstChild("Knife"); if not knife then return end

    -- Activate knife throw — the hookmetamethod above will redirect the position
    pcall(function() knife:Activate() end)
    autoThrowCD = 0.6 + math.random() * 0.2  -- humanized cooldown
end)
