-- Crypt-MM2-Legit | Teleport Section

local Players = game:GetService("Players")
local lp      = Players.LocalPlayer

local page = _G.Pages["Teleport"].page
local tpS  = _G.UI:MakeSection(page, "Teleport", 1)

_G.TeleportToRole = function(role)
    local char = lp.Character; local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then if _G.Notify then _G.Notify("No character","error") end; return end
    for _, p in ipairs(Players:GetPlayers()) do
        if p == lp then continue end
        if (_G.RoleCache and _G.RoleCache[p]) == role then
            local pC = p.Character; local pR = pC and pC:FindFirstChild("HumanoidRootPart")
            if pR then
                hrp.CFrame = pR.CFrame + pR.CFrame.LookVector * 5 + Vector3.new(0,1,0)
                if _G.Notify then _G.Notify("Teleported to " .. role, "success") end
                return
            end
        end
    end
    if _G.Notify then _G.Notify(role .. " not found", "warn") end
end

_G.TeleportToMap = function()
    local char = lp.Character; local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    local bestPart = nil; local bestY = -math.huge
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") then
            local n = obj.Name:lower()
            if (n:find("floor") or n:find("ground") or n:find("base") or n:find("spawn"))
            and obj.Size.X > 10 and obj.Size.Z > 10
            and obj.Position.Y > -10 and obj.Position.Y < 100 then
                if obj.Position.Y > bestY then bestY = obj.Position.Y; bestPart = obj end
            end
        end
    end
    if bestPart then
        hrp.CFrame = CFrame.new(bestPart.Position + Vector3.new(0, bestY + 5, 0))
        if _G.Notify then _G.Notify("Teleported to map", "success") end
        return
    end
    hrp.CFrame = CFrame.new(0, 10, 0)
    if _G.Notify then _G.Notify("Teleported to origin", "info") end
end

-- Teleport to lobby — finds the lobby spawn area
-- MM2 lobby is typically at a fixed position or under a "Lobby" model
_G.TeleportToLobby = function()
    local char = lp.Character; local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    -- Method 1: find a part named "Lobby" or "LobbySpawn"
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") then
            local n = obj.Name:lower()
            if n:find("lobby") or n:find("spawn") then
                hrp.CFrame = CFrame.new(obj.Position + Vector3.new(0, 5, 0))
                if _G.Notify then _G.Notify("Teleported to lobby", "success") end
                return
            end
        end
        if obj:IsA("Model") then
            local n = obj.Name:lower()
            if n:find("lobby") then
                local cf; pcall(function() cf = obj:GetModelCFrame() end)
                if cf then
                    hrp.CFrame = cf * CFrame.new(0, 5, 0)
                    if _G.Notify then _G.Notify("Teleported to lobby", "success") end
                    return
                end
            end
        end
    end

    -- Method 2: MM2 lobby is often at Y=0 area, central position
    -- Find the waiting area (typically has "Waiting" or "Lobby" GUI visible)
    local localGui = lp:FindFirstChild("PlayerGui")
    if localGui then
        local mainGui = localGui:FindFirstChild("MainGui")
        if mainGui then
            -- If lobby GUI is visible, use spawn position
            local lobby = mainGui:FindFirstChild("Lobby") or mainGui:FindFirstChild("Menu")
            if lobby and lobby.Visible then
                hrp.CFrame = CFrame.new(0, 5, 0)
                if _G.Notify then _G.Notify("Teleported to lobby area", "success") end
                return
            end
        end
    end

    -- Method 3: fallback — origin is usually lobby in MM2
    hrp.CFrame = CFrame.new(0, 10, 0)
    if _G.Notify then _G.Notify("Teleported to origin (lobby fallback)", "info") end
end

_G.UI:Button(tpS, "Teleport to Murderer",   1, function() _G.TeleportToRole("Murderer") end)
_G.UI:Button(tpS, "Teleport to Sheriff",    2, function() _G.TeleportToRole("Sheriff")  end)
_G.UI:Button(tpS, "Teleport to Map Center", 3, function() _G.TeleportToMap()            end)
_G.UI:Button(tpS, "Teleport to Lobby",      4, function() _G.TeleportToLobby()          end)
