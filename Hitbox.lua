-- Crypt-MM2-Legit | Hitbox Expander + Silent Aim

local Players    = game:GetService("Players")
local RunService = game:GetService("RunService")
local lp         = Players.LocalPlayer

local originalSizes = {}

local function getRole(player)
    local char = player.Character
    local bp   = player:FindFirstChild("Backpack")
    if char then
        if char:FindFirstChild("Knife") then return "Murderer" end
        if char:FindFirstChild("Gun")   then return "Sheriff"  end
    end
    if bp then
        if bp:FindFirstChild("Knife") then return "Murderer" end
        if bp:FindFirstChild("Gun")   then return "Sheriff"  end
    end
    return "Innocent"
end

RunService.Heartbeat:Connect(function()
    for _, player in ipairs(Players:GetPlayers()) do
        if player == lp then continue end
        local char = player.Character
        if not char then continue end
        local root = char:FindFirstChild("HumanoidRootPart")
        if not root then continue end

        local role = getRole(player)

        -- Silent aim: expand murderer and sheriff hugely (through walls hitbox)
        local silentTarget = _G.SilentAim and (role == "Murderer" or role == "Sheriff")

        if _G.HitboxEnabled or silentTarget then
            if not originalSizes[player] then
                originalSizes[player] = root.Size
            end

            local sz = silentTarget
                and (_G.SilentAimSize or 40)   -- massive for silent aim
                or  (_G.HitboxSize    or 6)     -- normal hitbox expand

            root.Size = Vector3.new(sz, sz, sz)

            -- Hide visual expansion from this client
            root.LocalTransparencyModifier = 1

            -- Allow walking through expanded hitbox (CanCollide off client-side)
            root.CanCollide = false
        else
            -- Restore
            if originalSizes[player] then
                root.Size                      = originalSizes[player]
                originalSizes[player]          = nil
                root.LocalTransparencyModifier = 0
                root.CanCollide                = true
            end
        end
    end
end)

Players.PlayerRemoving:Connect(function(p)
    originalSizes[p] = nil
end)
