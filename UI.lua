-- Crypt-MM2-Legit | UI
-- Replace BG_IMAGE_ID below with your Roblox decal asset ID
-- Upload your image at roblox.com/develop > Decals, copy the ID

local BG_IMAGE_ID = "rbxassetid://YOUR_IMAGE_ID_HERE" -- <-- paste yours here

local Players       = game:GetService("Players")
local TweenService  = game:GetService("TweenService")
local UserInput     = game:GetService("UserInputService")
local lp            = Players.LocalPlayer

-- Screen GUI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "CryptMM2"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = gethui and gethui() or lp.PlayerGui

-- Main Window
local main = Instance.new("Frame")
main.Name = "Main"
main.Size = UDim2.new(0, 520, 0, 400)
main.Position = UDim2.new(0.5, -260, 0.5, -200)
main.BackgroundColor3 = Color3.fromRGB(12, 12, 18)
main.BorderSizePixel = 0
main.Active = true
main.Draggable = true
main.ClipsDescendants = true
main.Parent = screenGui

-- Corner rounding
local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 12)
mainCorner.Parent = main

-- Background image
local bgImage = Instance.new("ImageLabel")
bgImage.Image = BG_IMAGE_ID
bgImage.Size = UDim2.new(1, 0, 1, 0)
bgImage.Position = UDim2.new(0, 0, 0, 0)
bgImage.BackgroundTransparency = 1
bgImage.ImageTransparency = 0.55   -- keeps UI readable over bg
bgImage.ScaleType = Enum.ScaleType.Crop
bgImage.ZIndex = 1
bgImage.Parent = main

-- Dark overlay for readability
local overlay = Instance.new("Frame")
overlay.Size = UDim2.new(1, 0, 1, 0)
overlay.BackgroundColor3 = Color3.fromRGB(8, 8, 14)
overlay.BackgroundTransparency = 0.35
overlay.BorderSizePixel = 0
overlay.ZIndex = 2
overlay.Parent = main

-- Title bar
local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 38)
titleBar.BackgroundColor3 = Color3.fromRGB(18, 18, 28)
titleBar.BackgroundTransparency = 0.1
titleBar.BorderSizePixel = 0
titleBar.ZIndex = 3
titleBar.Parent = main

local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 12)
titleCorner.Parent = titleBar

-- Title text
local titleLabel = Instance.new("TextLabel")
titleLabel.Text = "⚰  Crypt-MM2-Legit"
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextSize = 15
titleLabel.TextColor3 = Color3.fromRGB(200, 170, 255)
titleLabel.BackgroundTransparency = 1
titleLabel.Size = UDim2.new(1, -10, 1, 0)
titleLabel.Position = UDim2.new(0, 12, 0, 0)
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.ZIndex = 4
titleLabel.Parent = titleBar

-- Accent line under title
local accent = Instance.new("Frame")
accent.Size = UDim2.new(1, 0, 0, 2)
accent.Position = UDim2.new(0, 0, 0, 38)
accent.BackgroundColor3 = Color3.fromRGB(140, 80, 255)
accent.BorderSizePixel = 0
accent.ZIndex = 3
accent.Parent = main

-- Tab bar
local tabBar = Instance.new("Frame")
tabBar.Size = UDim2.new(0, 130, 1, -42)
tabBar.Position = UDim2.new(0, 0, 0, 42)
tabBar.BackgroundColor3 = Color3.fromRGB(14, 14, 22)
tabBar.BackgroundTransparency = 0.2
tabBar.BorderSizePixel = 0
tabBar.ZIndex = 3
tabBar.Parent = main

local tabLayout = Instance.new("UIListLayout")
tabLayout.Padding = UDim.new(0, 4)
tabLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
tabLayout.Parent = tabBar

local tabPadding = Instance.new("UIPadding")
tabPadding.PaddingTop = UDim.new(0, 8)
tabPadding.Parent = tabBar

-- Content area
local content = Instance.new("Frame")
content.Size = UDim2.new(1, -138, 1, -48)
content.Position = UDim2.new(0, 134, 0, 46)
content.BackgroundTransparency = 1
content.ZIndex = 3
content.Parent = main

-- ─── Helpers ─────────────────────────────────────────────────────────────────

local activeTab = nil
local tabPages = {}

local function makeTab(name, icon)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 114, 0, 32)
    btn.BackgroundColor3 = Color3.fromRGB(22, 22, 34)
    btn.BackgroundTransparency = 0.3
    btn.BorderSizePixel = 0
    btn.Font = Enum.Font.GothamSemibold
    btn.TextSize = 13
    btn.TextColor3 = Color3.fromRGB(160, 140, 200)
    btn.Text = icon .. "  " .. name
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.ZIndex = 4
    btn.Parent = tabBar

    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 7)
    btnCorner.Parent = btn

    local btnPad = Instance.new("UIPadding")
    btnPad.PaddingLeft = UDim.new(0, 10)
    btnPad.Parent = btn

    -- Page
    local page = Instance.new("ScrollingFrame")
    page.Size = UDim2.new(1, 0, 1, 0)
    page.BackgroundTransparency = 1
    page.BorderSizePixel = 0
    page.ScrollBarThickness = 3
    page.ScrollBarImageColor3 = Color3.fromRGB(140, 80, 255)
    page.CanvasSize = UDim2.new(0, 0, 0, 0)
    page.AutomaticCanvasSize = Enum.AutomaticSize.Y
    page.ZIndex = 4
    page.Visible = false
    page.Parent = content

    local pageLayout = Instance.new("UIListLayout")
    pageLayout.Padding = UDim.new(0, 6)
    pageLayout.Parent = page

    local pagePad = Instance.new("UIPadding")
    pagePad.PaddingTop = UDim.new(0, 8)
    pagePad.PaddingLeft = UDim.new(0, 8)
    pagePad.PaddingRight = UDim.new(0, 8)
    pagePad.Parent = page

    tabPages[name] = page

    btn.MouseButton1Click:Connect(function()
        for n, p in pairs(tabPages) do
            p.Visible = false
        end
        page.Visible = true
        if activeTab then
            activeTab.BackgroundColor3 = Color3.fromRGB(22, 22, 34)
            activeTab.TextColor3 = Color3.fromRGB(160, 140, 200)
        end
        btn.BackgroundColor3 = Color3.fromRGB(100, 50, 200)
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        activeTab = btn
    end)

    return page, btn
end

-- Toggle widget
local function makeToggle(parent, labelText, default, callback)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, 0, 0, 30)
    row.BackgroundColor3 = Color3.fromRGB(20, 20, 32)
    row.BackgroundTransparency = 0.3
    row.BorderSizePixel = 0
    row.Parent = parent

    local rowCorner = Instance.new("UICorner")
    rowCorner.CornerRadius = UDim.new(0, 6)
    rowCorner.Parent = row

    local lbl = Instance.new("TextLabel")
    lbl.Text = labelText
    lbl.Font = Enum.Font.Gotham
    lbl.TextSize = 12
    lbl.TextColor3 = Color3.fromRGB(210, 200, 230)
    lbl.BackgroundTransparency = 1
    lbl.Size = UDim2.new(1, -50, 1, 0)
    lbl.Position = UDim2.new(0, 10, 0, 0)
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = row

    local togBg = Instance.new("Frame")
    togBg.Size = UDim2.new(0, 36, 0, 18)
    togBg.Position = UDim2.new(1, -44, 0.5, -9)
    togBg.BackgroundColor3 = default and Color3.fromRGB(100, 50, 200) or Color3.fromRGB(50, 50, 70)
    togBg.BorderSizePixel = 0
    togBg.Parent = row

    local togCorner = Instance.new("UICorner")
    togCorner.CornerRadius = UDim.new(1, 0)
    togCorner.Parent = togBg

    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0, 14, 0, 14)
    knob.Position = default and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)
    knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    knob.BorderSizePixel = 0
    knob.Parent = togBg

    local knobCorner = Instance.new("UICorner")
    knobCorner.CornerRadius = UDim.new(1, 0)
    knobCorner.Parent = knob

    local state = default
    local tweenInfo = TweenInfo.new(0.15, Enum.EasingStyle.Quad)

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 1, 0)
    btn.BackgroundTransparency = 1
    btn.Text = ""
    btn.Parent = row

    btn.MouseButton1Click:Connect(function()
        state = not state
        TweenService:Create(togBg, tweenInfo, {
            BackgroundColor3 = state and Color3.fromRGB(100, 50, 200) or Color3.fromRGB(50, 50, 70)
        }):Play()
        TweenService:Create(knob, tweenInfo, {
            Position = state and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)
        }):Play()
        callback(state)
    end)

    return function() return state end
end

-- Slider widget
local function makeSlider(parent, labelText, min, max, default, callback)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, 0, 0, 44)
    row.BackgroundColor3 = Color3.fromRGB(20, 20, 32)
    row.BackgroundTransparency = 0.3
    row.BorderSizePixel = 0
    row.Parent = parent

    local rowCorner = Instance.new("UICorner")
    rowCorner.CornerRadius = UDim.new(0, 6)
    rowCorner.Parent = row

    local lbl = Instance.new("TextLabel")
    lbl.Font = Enum.Font.Gotham
    lbl.TextSize = 12
    lbl.TextColor3 = Color3.fromRGB(210, 200, 230)
    lbl.BackgroundTransparency = 1
    lbl.Size = UDim2.new(1, -10, 0, 18)
    lbl.Position = UDim2.new(0, 10, 0, 4)
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = row

    local track = Instance.new("Frame")
    track.Size = UDim2.new(1, -20, 0, 4)
    track.Position = UDim2.new(0, 10, 1, -14)
    track.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
    track.BorderSizePixel = 0
    track.Parent = row

    local trackCorner = Instance.new("UICorner")
    trackCorner.CornerRadius = UDim.new(1, 0)
    trackCorner.Parent = track

    local fill = Instance.new("Frame")
    fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(140, 80, 255)
    fill.BorderSizePixel = 0
    fill.Parent = track

    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(1, 0)
    fillCorner.Parent = fill

    local value = default
    lbl.Text = labelText .. ":  " .. value

    local dragging = false

    local sliderBtn = Instance.new("TextButton")
    sliderBtn.Size = UDim2.new(1, 0, 1, 0)
    sliderBtn.BackgroundTransparency = 1
    sliderBtn.Text = ""
    sliderBtn.Parent = row

    local function updateSlider(input)
        local trackPos = track.AbsolutePosition.X
        local trackSize = track.AbsoluteSize.X
        local rel = math.clamp((input.Position.X - trackPos) / trackSize, 0, 1)
        value = math.floor(min + rel * (max - min))
        fill.Size = UDim2.new(rel, 0, 1, 0)
        lbl.Text = labelText .. ":  " .. value
        callback(value)
    end

    sliderBtn.MouseButton1Down:Connect(function()
        dragging = true
    end)

    UserInput.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            updateSlider(input)
        end
    end)

    UserInput.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)

    return function() return value end
end

-- Section label
local function makeSection(parent, text)
    local lbl = Instance.new("TextLabel")
    lbl.Text = "— " .. text
    lbl.Font = Enum.Font.GothamBold
    lbl.TextSize = 11
    lbl.TextColor3 = Color3.fromRGB(140, 80, 255)
    lbl.BackgroundTransparency = 1
    lbl.Size = UDim2.new(1, 0, 0, 20)
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = parent
end

-- ─── Build Tabs ───────────────────────────────────────────────────────────────

local aimbotPage,  aimbotBtn  = makeTab("Aimbot",    "🎯")
local espPage,     espBtn     = makeTab("ESP",        "👁")
local movePage,    moveBtn    = makeTab("Movement",   "⚡")
local visualPage,  visualBtn  = makeTab("Visuals",    "🔵")

-- Activate first tab
aimbotBtn:GetPropertyChangedSignal("Parent"):Wait()
task.defer(function() aimbotBtn.MouseButton1Click:Fire() end)

-- ─── Aimbot Tab ───────────────────────────────────────────────────────────────

makeSection(aimbotPage, "Aimbot")

local getAimbot = makeToggle(aimbotPage, "Enable Aimbot", false, function(v)
    _G.AimbotEnabled = v
end)

local getRightClick = makeToggle(aimbotPage, "Require Right Click Hold", true, function(v)
    _G.AimbotRightClick = v
end)

makeSection(aimbotPage, "Target Filter")

local getAimMurderer = makeToggle(aimbotPage, "Aim at Murderer", true, function(v)
    _G.AimMurderer = v
end)

local getAimSheriff = makeToggle(aimbotPage, "Aim at Sheriff", false, function(v)
    _G.AimSheriff = v
end)

makeSection(aimbotPage, "Settings")

local getSmoothing = makeSlider(aimbotPage, "Smoothing", 1, 30, 12, function(v)
    _G.AimbotSmoothing = v
end)

local getFOV = makeSlider(aimbotPage, "FOV Radius", 50, 500, 180, function(v)
    _G.AimbotFOV = v
end)

local getShowFOV = makeToggle(aimbotPage, "Show FOV Circle", true, function(v)
    _G.ShowFOV = v
end)

-- Set defaults
_G.AimbotEnabled   = false
_G.AimbotRightClick = true
_G.AimMurderer     = true
_G.AimSheriff      = false
_G.AimbotSmoothing = 12
_G.AimbotFOV       = 180
_G.ShowFOV         = true

-- ─── ESP Tab ──────────────────────────────────────────────────────────────────

makeSection(espPage, "ESP Toggles")

makeToggle(espPage, "Box ESP",      false, function(v) _G.BoxESP      = v end)
makeToggle(espPage, "Chams ESP",    false, function(v) _G.ChamsESP    = v end)
makeToggle(espPage, "Name ESP",     true,  function(v) _G.NameESP     = v end)
makeToggle(espPage, "Distance ESP", true,  function(v) _G.DistanceESP = v end)

makeSection(espPage, "Team Colors")

local espInfo = Instance.new("TextLabel")
espInfo.Text = "🔴 Murderer   🟢 Sheriff   ⚪ Innocent"
espInfo.Font = Enum.Font.Gotham
espInfo.TextSize = 11
espInfo.TextColor3 = Color3.fromRGB(180, 170, 200)
espInfo.BackgroundTransparency = 1
espInfo.Size = UDim2.new(1, 0, 0, 24)
espInfo.TextXAlignment = Enum.TextXAlignment.Left
espInfo.Parent = espPage

_G.BoxESP      = false
_G.ChamsESP    = false
_G.NameESP     = true
_G.DistanceESP = true

-- ─── Movement Tab ─────────────────────────────────────────────────────────────

makeSection(movePage, "Movement")

makeToggle(movePage, "Noclip",         false, function(v) _G.NoclipEnabled    = v end)
makeToggle(movePage, "Speedhack",      false, function(v) _G.SpeedEnabled     = v end)
makeToggle(movePage, "Infinite Jump",  false, function(v) _G.InfJumpEnabled   = v end)

makeSection(movePage, "Speed Settings")
makeSlider(movePage, "Speed Multiplier", 1, 3, 1, function(v)
    _G.SpeedMultiplier = v
end)

_G.NoclipEnabled   = false
_G.SpeedEnabled    = false
_G.InfJumpEnabled  = false
_G.SpeedMultiplier = 1

-- ─── Visuals Tab ──────────────────────────────────────────────────────────────

makeSection(visualPage, "Crosshair")

makeToggle(visualPage, "Custom Crosshair", true, function(v) _G.CrosshairEnabled = v end)

makeSection(visualPage, "Crosshair Style")
makeSlider(visualPage, "Size",      4, 30, 14, function(v) _G.CrosshairSize  = v end)
makeSlider(visualPage, "Gap",       0, 12, 4,  function(v) _G.CrosshairGap   = v end)
makeSlider(visualPage, "Thickness", 1, 4,  1,  function(v) _G.CrosshairThick = v end)

_G.CrosshairEnabled = true
_G.CrosshairSize    = 14
_G.CrosshairGap     = 4
_G.CrosshairThick   = 1

-- ─── Keybind hint ─────────────────────────────────────────────────────────────

local hint = Instance.new("TextLabel")
hint.Text = "INSERT  — toggle UI"
hint.Font = Enum.Font.Gotham
hint.TextSize = 10
hint.TextColor3 = Color3.fromRGB(100, 90, 130)
hint.BackgroundTransparency = 1
hint.Size = UDim2.new(1, 0, 0, 16)
hint.Position = UDim2.new(0, 0, 1, -18)
hint.TextXAlignment = Enum.TextXAlignment.Center
hint.ZIndex = 5
hint.Parent = main

-- Toggle visibility with INSERT
UserInput.InputBegan:Connect(function(input, gp)
    if not gp and input.KeyCode == Enum.KeyCode.Insert then
        main.Visible = not main.Visible
    end
end)
