-- Crypt-MM2-Legit | Instant Scan with Optimized Drawing Square Engine

local Players    = game:GetService("Players")
local RunService = game:GetService("RunService")
local RS         = game:GetService("ReplicatedStorage")
local camera     = workspace.CurrentCamera
local lp         = Players.LocalPlayer

_G.RoleCache   = _G.RoleCache or {}
_G.MyRole      = nil
_G.RoundActive = false

local pool = {}

local function clearRoleFromOthers(role)
    for p, r in pairs(_G.RoleCache) do
        if r == role then
            _G.RoleCache[p] = "Innocent"
        end
    end
end

local function setRole(player, role, source)
    if not player or not role then return end
    local cur = _G.RoleCache[player]

    if source == "Tool" then
        if role == "Murderer" or role == "Sheriff" then
            clearRoleFromOthers(role)
        end
        _G.RoleCache[player] = role
        if player == lp then _G.MyRole = role end
        return
    end

    if (cur == "Murderer" or cur == "Sheriff") and role == "Innocent" then return end
    
    _G.RoleCache[player] = role
    if player == lp then _G.MyRole = role end
end

-- ── Layer 1: Instant Native Data Scanner ─────────────────────────────
local function scanGetPlayerData()
    local fn = RS:FindFirstChild("GetPlayerData", true)
    if not (fn and fn:IsA("RemoteFunction")) then return false end
    local ok, result = pcall(function() return fn:InvokeServer() end)
    if not ok or type(result) ~= "table" then return false end
    
    for playerKey, data in pairs(result) do
        local target = type(playerKey) == "string" and Players:FindFirstChild(playerKey) or playerKey
        if target and type(data) == "table" then
            local role = data.Role or data.role or data.Team or data.team
            if role then
                local r = tostring(role):lower()
                if r:find("murder") then 
                    setRole(target, "Murderer", "Scanner")
                    _G.RoundActive = true
                elseif r:find("sheriff") then 
                    setRole(target, "Sheriff", "Scanner")
                    _G.RoundActive = true
                elseif r == "innocent" then 
                    setRole(target, "Innocent", "Scanner") 
                end
            end
        end
    end
    return true
end

task.spawn(function()
    while task.wait(1) do pcall(scanGetPlayerData) end
end)

-- ── Layer 2: Tool Detection Backup ───────────────────────────────────
local function checkCharacterTool(char)
    if not (char and char:IsA("Model")) then return end
    local p = Players:GetPlayerFromCharacter(char)
    if not p then return end
    
    if char:FindFirstChild("Knife") or char:FindFirstChild("RealKnife") then
        setRole(p, "Murderer", "Tool")
        _G.RoundActive = true
    elseif char:FindFirstChild("Gun") or char:FindFirstChild("DefaultGun") then
        setRole(p, "Sheriff", "Tool")
        _G.RoundActive = true
    end
end

workspace.DescendantAdded:Connect(function(desc)
    if desc:IsA("Tool") then
        task.defer(function() checkCharacterTool(desc.Parent) end)
    end
end)

-- ── Visual Drawing Helpers ───────────────────────────────────────────
local function roleColor(role)
    if role == "Murderer" then return Color3.fromRGB(255, 55, 55) end
    if role == "Sheriff"  then return Color3.fromRGB(55, 210, 255) end
    return Color3.fromRGB(255, 255, 255)
end

local function removeESP(p)
    local obj = pool[p]
    if not obj then return end
    
    if obj.box then pcall(function() obj.box:Remove() end) end
    if obj.name then pcall(function() obj.name:Remove() end) end
    if obj.dist then pcall(function() obj.dist:Remove() end) end
    if obj.tracer then pcall(function() obj.tracer:Remove() end) end
    pool[p] = nil
end

local function makeESP(p)
    if p == lp or pool[p] then return end
    local obj = {}
    
    -- FIXED: Swapped out broken multiline arrays for a unified Drawing Square [1]
    obj.box = Drawing.new("Square")
    obj.box.Thickness = 1.5
    obj.box.Filled = false
    obj.box.Visible = false
    obj.box.Transparency = 1
    
    obj.name = Drawing.new("Text")
    obj.name.Size = 14
    obj.name.Font = 2
    obj.name.Center = true
    obj.name.Outline = true
    obj.name.Visible = false
    
    obj.dist = Drawing.new("Text")
    obj.dist.Size = 12
    obj.dist.Font = 2
    obj.dist.Center = true
    obj.dist.Outline = true
    obj.dist.Visible = false
    
    obj.tracer = Drawing.new("Line")
    obj.tracer.Thickness = 1
    obj.tracer.Visible = false
    obj.tracer.Transparency = 0.5
    
    pool[p] = obj
end

-- ── Core Update Rendering Loop ───────────────────────────────────────
RunService.RenderStepped:Connect(function()
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= lp then
            local char = p.Character
            local root = char and char:FindFirstChild("HumanoidRootPart")
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            
            if char then checkCharacterTool(char) end
            
            if root and hum and hum.Health > 0 then
                if not pool[p] then makeESP(p) end
                local obj = pool[p]
                
                local rpos, onScreen = camera:WorldToViewportPoint(root.Position)
                if onScreen then
                    local scale = 1 / (rpos.Z * table.tan(table.rad(camera.FieldOfView * 0.5))) * 1000
                    local w, h = 3 * scale, 4.5 * scale
                    local x, y = rpos.X - w / 2, rpos.Y - h / 2
                    
                    local currentRole = _G.RoleCache[p] or "Innocent"
                    local color = roleColor(currentRole)
                    
                    -- CRASH-PROOFED: Flat configuration assignment on single primitive
                    obj.box.Position = Vector2.new(x, y)
                    obj.box.Size = Vector2.new(w, h)
                    obj.box.Color = color
                    obj.box.Visible = true
                    
                    obj.name.Text = string.format("[%s] %s", currentRole, p.Name)
                    obj.name.Position = Vector2.new(rpos.X, y - 20)
                    obj.name.Color = color
                    obj.name.Visible = true
                    
                    local distance = math.floor((camera.CFrame.Position - root.Position).Magnitude)
                    obj.dist.Text = tostring(distance) .. " studs"
                    obj.dist.Position = Vector2.new(rpos.X, y + h + 5)
                    obj.dist.Color = Color3.fromRGB(235, 235, 235)
                    obj.dist.Visible = true
                    
                    obj.tracer.From = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y)
                    obj.tracer.To = Vector2.new(rpos.X, rpos.Y)
                    obj.tracer.Color = color
                    obj.tracer.Visible = true
                else
                    if pool[p] then
                        pool[p].box.Visible = false
                        pool[p].name.Visible = false
                        pool[p].dist.Visible = false
                        pool[p].tracer.Visible = false
                    end
                end
            else
                if pool[p] then removeESP(p) end
            end
        end
    end
end)

-- ── Event Lifecycle Cleaning ─────────────────────────────────────────
local function resetAll()
    _G.MyRole = nil
    _G.RoundActive = false
    for _, p in ipairs(Players:GetPlayers()) do
        _G.RoleCache[p] = "Innocent"
    end
end

lp.CharacterAdded:Connect(function()
    task.wait(1)
    resetAll()
end)

Players.PlayerAdded:Connect(function(p) _G.RoleCache[p] = "Innocent" end)
Players.PlayerRemoving:Connect(function(p) _G.RoleCache[p] = nil; removeESP(p) end)
resetAll()
