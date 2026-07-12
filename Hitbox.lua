-- Crypt-MM2-Legit | Hitbox Expander
-- Method: expand only HumanoidRootPart of other players client-side
-- Visual hidden via LocalTransparencyModifier on the expanded part
-- Very small expansion — stays under radar

local Players    = game:GetService("Players")
local RunService = game:GetService("RunService")
local lp         = Players.LocalPlayer

local originalSizes = {}  -- store per-player original sizes

local function restoreHitbox(player)
    local data = originalSizes[player]
    local char = player.Character
    if not (data and char) then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    if root then root.Size = data end
    originalSizes[player] = nil
end

RunService.Heartbeat:Connect(function()
    for _, player in ipairs(Players:GetPlayers()) do
        if player == lp then continue end
        local char = player.Character
        if not char then continue end
        local root = char:FindFirstChild("HumanoidRootPart")
        if not root then continue end

        if _G.HitboxEnabled then
            -- save original only once
            if not originalSizes[player] then
                originalSizes[player] = root.Size
            end
            local s = math.clamp(_G.HitboxSize or 5, 2, 12)
            root.Size = Vector3.new(s, s, s)
            -- hide the visual expansion (other players see nothing)
            root.LocalTransparencyModifier = 1
        else
            restoreHitbox(player)
            -- restore visual
            if root then root.LocalTransparencyModifier = 0 end
        end
    end
end)

Players.PlayerRemoving:Connect(function(p)
    originalSizes[p] = nil
end)
