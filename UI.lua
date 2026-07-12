-- Crypt-MM2-Legit | UI (fixed)

local Players      = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInput    = game:GetService("UserInputService")
local lp           = Players.LocalPlayer

local cfg          = _G.Config or {}
local BG_IMAGE     = cfg.BackgroundDecal   or "rbxassetid://0"
local ICON_IMAGE   = cfg.MinimizeIconDecal or "rbxassetid://0"
local TOGGLE_KEY   = cfg.ToggleKey         or Enum.KeyCode.Insert
local WIN_SIZE     = cfg.WindowSize        or UDim2.new(0, 520, 0, 400)
local ICON_SIZE    = cfg.IconSize          or UDim2.new(0, 54, 0, 54)
local START_POS    = cfg.StartPosition     or UDim2.new(0.5, -260, 0.5, -200)

-- ─── Screen GUI ───────────────────────────────────────────────────────────────

local gui = Instance.new("ScreenGui")
gui.Name           = "CryptMM2"
gui.ResetOnSpawn   = false
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.IgnoreGuiInset = true
gui.Parent         = (gethui and gethui()) or lp.PlayerGui

-- ─── Main Window ─────────────────────────────────────────────────────────────

local main = Instance.new("Frame")
main.Name                  = "Main"
main.Size                  = WIN_SIZE
main.Position              = START_POS
main.BackgroundColor3      = Color3.fromRGB(0, 0, 0)
main.BackgroundTransparency = 0
main.BorderSizePixel       = 0
main.Active                = true
main.Draggable             = true
main.ClipsDescendants      = true
main.Parent                = gui

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 14)
mainCorner.Parent = main

-- Background image — fully visible, crops to fill window
-- replace the bgImg ImageLabel creation with this:
local bgImg = Instance.new("ImageLabel")
bgImg.Image              = BG_IMAGE
bgImg.Size               = UDim2.new(1, 0, 1, 0)
bgImg.Position           = UDim2.new(0, 0, 0, 0)
bgImg.BackgroundTransparency = 1
bgImg.ImageTransparency  = 0
bgImg.ScaleType          = Enum.ScaleType.Stretch  -- stretch fits any image perfectly, no cropping
bgImg.ZIndex             = 1
bgImg.Parent             = main

-- Subtle dark wash so text stays readable (30% opacity)
local wash = Instance.new("Frame")
wash.Size                   = UDim2.new(1, 0, 1, 0)
wash.BackgroundColor3       = Color3.fromRGB(0, 0, 0)
wash.BackgroundTransparency = 0.6   -- lower = darker wash; raise to show more image
wash.BorderSizePixel        = 0
wash.ZIndex                 = 2
wash.Parent                 = main

local washCorner = Instance.new("UICorner")
washCorner.CornerRadius = UDim.new(0, 14)
washCorner.Parent = wash

-- ─── Title Bar ───────────────────────────────────────────────────────────────

local titleBar = Instance.new("Frame")
titleBar.Size                   = UDim2.new(1, 0, 0, 40)
titleBar.BackgroundColor3       = Color3.fromRGB(0, 0, 0)
titleBar.BackgroundTransparency = 0.35
titleBar.BorderSizePixel        = 0
titleBar.ZIndex                 = 5
titleBar.Parent                 = main

local tbCorner = Instance.new("UICorner")
tbCorner.CornerRadius = UDim.new(0, 14)
tbCorner.Parent = titleBar

-- Square off bottom of title bar so it meets body cleanly
local tbSquare = Instance.new("Frame")
tbSquare.Size                   = UDim2.new(1, 0, 0, 14)
tbSquare.Position               = UDim2.new(0, 0, 1, -14)
tbSquare.BackgroundColor3       = Color3.fromRGB(0, 0, 0)
tbSquare.BackgroundTransparency = 0.35
tbSquare.BorderSizePixel        = 0
tbSquare.ZIndex                 = 5
tbSquare.Parent                 = titleBar

local titleLbl = Instance.new("TextLabel")
titleLbl.Text               = "⚰  Crypt MM2"
titleLbl.Font               = Enum.Font.GothamBold
titleLbl.TextSize           = 14
titleLbl.TextColor3         = Color3.fromRGB(255, 255, 255)
titleLbl.BackgroundTransparency = 1
titleLbl.Size               = UDim2.new(1, -80, 1, 0)
titleLbl.Position           = UDim2.new(0, 14, 0, 0)
titleLbl.TextXAlignment     = Enum.TextXAlignment.Left
titleLbl.ZIndex             = 6
titleLbl.Parent             = titleBar

-- White accent line under title bar
local accent = Instance.new("Frame")
accent.Size                   = UDim2.new(1, 0, 0, 1)
accent.Position               = UDim2.new(0, 0, 0, 40)
accent.BackgroundColor3       = Color3.fromRGB(255, 255, 255)
accent.BackgroundTransparency = 0.75
accent.BorderSizePixel        = 0
accent.ZIndex                 = 4
accent.Parent                 = main

-- ─── Minimize Button ─────────────────────────────────────────────────────────

local minBtn = Instance.new("TextButton")
minBtn.Size                   = UDim2.new(0, 28, 0, 22)
minBtn.Position               = UDim2.new(1, -62, 0.5, -11)
minBtn.BackgroundColor3       = Color3.fromRGB(60, 60, 60)
minBtn.BackgroundTransparency = 0.3
minBtn.BorderSizePixel        = 0
minBtn.Text                   = "—"
minBtn.Font                   = Enum.Font.GothamBold
minBtn.TextSize               = 13
minBtn.TextColor3             = Color3.fromRGB(255, 255, 255)
minBtn.AutoButtonColor        = false
minBtn.ZIndex                 = 8
minBtn.Parent                 = titleBar

local minCorner = Instance.new("UICorner")
minCorner.CornerRadius = UDim.new(0, 5)
minCorner.Parent = minBtn

-- ─── Close Button ────────────────────────────────────────────────────────────

local closeBtn = Instance.new("TextButton")
closeBtn.Size                   = UDim2.new(0, 28, 0, 22)
closeBtn.Position               = UDim2.new(1, -30, 0.5, -11)
closeBtn.BackgroundColor3       = Color3.fromRGB(180, 40, 40)
closeBtn.BackgroundTransparency = 0.1
closeBtn.BorderSizePixel        = 0
closeBtn.Text                   = "✕"
closeBtn.Font                   = Enum.Font.GothamBold
closeBtn.TextSize               = 12
closeBtn.TextColor3             = Color3.fromRGB(255, 255, 255)
closeBtn.AutoButtonColor        = false
closeBtn.ZIndex                 = 8
closeBtn.Parent                 = titleBar

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0, 5)
closeCorner.Parent = closeBtn

-- hover effect for close
closeBtn.MouseEnter:Connect(function()
    TweenService:Create(closeBtn, TweenInfo.new(0.1), {
        BackgroundColor3 = Color3.fromRGB(220, 60, 60)
    }):Play()
end)
closeBtn.MouseLeave:Connect(function()
    TweenService:Create(closeBtn, TweenInfo.new(0.1), {
        BackgroundColor3 = Color3.fromRGB(180, 40, 40)
    }):Play()
end)

-- ─── Minimized Icon ──────────────────────────────────────────────────────────

local iconFrame = Instance.new("Frame")
iconFrame.Size                  = ICON_SIZE
iconFrame.Position              = START_POS
iconFrame.BackgroundColor3      = Color3.fromRGB(10, 10, 10)
iconFrame.BackgroundTransparency = 0.1
iconFrame.BorderSizePixel       = 0
iconFrame.Active                = true
iconFrame.Draggable             = true
iconFrame.Visible               = false
iconFrame.ZIndex                = 10
iconFrame.Parent                = gui

local iconCorner = Instance.new("UICorner")
iconCorner.CornerRadius = UDim.new(0, 12)
iconCorner.Parent = iconFrame

local iconImg = Instance.new("ImageLabel")
iconImg.Image                = ICON_IMAGE
iconImg.Size                 = UDim2.new(1, -8, 1, -8)
iconImg.Position             = UDim2.new(0, 4, 0, 4)
iconImg.BackgroundTransparency = 1
iconImg.ScaleType            = Enum.ScaleType.Fit
iconImg.ZIndex               = 11
iconImg.Parent               = iconFrame

local iconBtn = Instance.new("TextButton")
iconBtn.Size                 = UDim2.new(1, 0, 1, 0)
iconBtn.BackgroundTransparency = 1
iconBtn.Text                 = ""
iconBtn.ZIndex               = 12
iconBtn.Parent               = iconFrame

-- ─── Minimize / Close Logic ──────────────────────────────────────────────────

local minimized = false

local function minimize()
    minimized         = true
    iconFrame.Position = main.Position
    main.Visible      = false
    iconFrame.Visible  = true
end

local function restore()
    minimized         = false
    main.Position     = iconFrame.Position
    iconFrame.Visible  = false
    main.Visible      = true
end

minBtn.MouseButton1Click:Connect(minimize)
iconBtn.MouseButton1Click:Connect(restore)
closeBtn.MouseButton1Click:Connect(function()
    gui:Destroy()
end)

UserInput.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == TOGGLE_KEY then
        if minimized then restore() else minimize() end
    end
end)

-- ─── Sidebar ─────────────────────────────────────────────────────────────────

local sidebar = Instance.new("Frame")
sidebar.Size                   = UDim2.new(0, 120, 1, -42)
sidebar.Position               = UDim2.new(0, 0, 0, 41)
sidebar.BackgroundColor3       = Color3.fromRGB(0, 0, 0)
sidebar.BackgroundTransparency = 0.55
sidebar.BorderSizePixel        = 0
sidebar.ZIndex                 = 4
sidebar.Parent                 = main

local sideLayout = Instance.new("UIListLayout")
sideLayout.Padding             = UDim.new(0, 4)
sideLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
sideLayout.Parent              = sidebar

local sidePad = Instance.new("UIPadding")
sidePad.PaddingTop   = UDim.new(0, 8)
sidePad.PaddingLeft  = UDim.new(0, 6)
sidePad.PaddingRight = UDim.new(0, 6)
sidePad.Parent       = sidebar

local divider = Instance.new("Frame")
divider.Size                   = UDim2.new(0, 1, 1, -42)
divider.Position               = UDim2.new(0, 120, 0, 41)
divider.BackgroundColor3       = Color3.fromRGB(255, 255, 255)
divider.BackgroundTransparency = 0.82
divider.BorderSizePixel        = 0
divider.ZIndex                 = 4
divider.Parent                 = main

-- ─── Content Area ────────────────────────────────────────────────────────────

local contentArea = Instance.new("Frame")
contentArea.Size                   = UDim2.new(1, -128, 1, -50)
contentArea.Position               = UDim2.new(0, 124, 0, 46)
contentArea.BackgroundTransparency = 1
contentArea.BorderSizePixel        = 0
contentArea.ClipsDescendants       = true
contentArea.ZIndex                 = 4
contentArea.Parent                 = main

-- ─── Widget Builders ─────────────────────────────────────────────────────────

local function makeSection(parent, text)
    local f = Instance.new("Frame")
    f.Size                   = UDim2.new(1, 0, 0, 24)
    f.BackgroundTransparency = 1
    f.BorderSizePixel        = 0
    f.Parent                 = parent

    local lbl = Instance.new("TextLabel")
    lbl.Text               = text:upper()
    lbl.Font               = Enum.Font.GothamBold
    lbl.TextSize           = 10
    lbl.TextColor3         = Color3.fromRGB(255, 255, 255)
    lbl.BackgroundTransparency = 1
    lbl.Size               = UDim2.new(1, 0, 1, 0)
    lbl.TextXAlignment     = Enum.TextXAlignment.Left
    lbl.ZIndex             = 6
    lbl.Parent             = f
    -- NOTE: LetterSpacing removed — not a valid Roblox property

    local line = Instance.new("Frame")
    line.Size                   = UDim2.new(1, 0, 0, 1)
    line.Position               = UDim2.new(0, 0, 1, -1)
    line.BackgroundColor3       = Color3.fromRGB(255, 255, 255)
    line.BackgroundTransparency = 0.82
    line.BorderSizePixel        = 0
    line.ZIndex                 = 6
    line.Parent                 = f
end

local function makeToggle(parent, label, default, callback)
    -- guard: default must be boolean
    default = (default == true)

    local row = Instance.new("Frame")
    row.Size                   = UDim2.new(1, 0, 0, 34)
    row.BackgroundColor3       = Color3.fromRGB(255, 255, 255)
    row.BackgroundTransparency = 0.91
    row.BorderSizePixel        = 0
    row.ZIndex                 = 6
    row.Parent                 = parent

    local rowCorner = Instance.new("UICorner")
    rowCorner.CornerRadius = UDim.new(0, 7)
    rowCorner.Parent = row

    local lbl = Instance.new("TextLabel")
    lbl.Text               = label
    lbl.Font               = Enum.Font.Gotham
    lbl.TextSize           = 12
    lbl.TextColor3         = Color3.fromRGB(230, 230, 230)
    lbl.BackgroundTransparency = 1
    lbl.Size               = UDim2.new(1, -56, 1, 0)
    lbl.Position           = UDim2.new(0, 10, 0, 0)
    lbl.TextXAlignment     = Enum.TextXAlignment.Left
    lbl.ZIndex             = 7
    lbl.Parent             = row

    local track = Instance.new("Frame")
    track.Size             = UDim2.new(0, 36, 0, 18)
    track.Position         = UDim2.new(1, -44, 0.5, -9)
    track.BackgroundColor3 = default
        and Color3.fromRGB(255, 255, 255)
        or  Color3.fromRGB(55, 55, 55)
    track.BorderSizePixel  = 0
    track.ZIndex           = 7
    track.Parent           = row

    local trackCorner = Instance.new("UICorner")
    trackCorner.CornerRadius = UDim.new(1, 0)
    trackCorner.Parent = track

    local knob = Instance.new("Frame")
    knob.Size             = UDim2.new(0, 14, 0, 14)
    knob.Position         = default
        and UDim2.new(1, -16, 0.5, -7)
        or  UDim2.new(0,  2, 0.5, -7)
    knob.BackgroundColor3 = default
        and Color3.fromRGB(0, 0, 0)
        or  Color3.fromRGB(150, 150, 150)
    knob.BorderSizePixel  = 0
    knob.ZIndex           = 8
    knob.Parent           = track

    local knobCorner = Instance.new("UICorner")
    knobCorner.CornerRadius = UDim.new(1, 0)
    knobCorner.Parent = knob

    local state = default
    local ti    = TweenInfo.new(0.15, Enum.EasingStyle.Quad)

    local hitbox = Instance.new("TextButton")
    hitbox.Size                 = UDim2.new(1, 0, 1, 0)
    hitbox.BackgroundTransparency = 1
    hitbox.Text                 = ""
    hitbox.ZIndex               = 9
    hitbox.Parent               = row

    hitbox.MouseButton1Click:Connect(function()
        state = not state
        TweenService:Create(track, ti, {
            BackgroundColor3 = state
                and Color3.fromRGB(255, 255, 255)
                or  Color3.fromRGB(55, 55, 55)
        }):Play()
        TweenService:Create(knob, ti, {
            Position = state
                and UDim2.new(1, -16, 0.5, -7)
                or  UDim2.new(0,  2, 0.5, -7),
            BackgroundColor3 = state
                and Color3.fromRGB(0, 0, 0)
                or  Color3.fromRGB(150, 150, 150)
        }):Play()
        if callback then callback(state) end
    end)

    return function() return state end
end

local function makeSlider(parent, label, min, max, default, callback)
    local row = Instance.new("Frame")
    row.Size                   = UDim2.new(1, 0, 0, 50)
    row.BackgroundColor3       = Color3.fromRGB(255, 255, 255)
    row.BackgroundTransparency = 0.91
    row.BorderSizePixel        = 0
    row.ZIndex                 = 6
    row.Parent                 = parent

    local rowCorner = Instance.new("UICorner")
    rowCorner.CornerRadius = UDim.new(0, 7)
    rowCorner.Parent = row

    local lbl = Instance.new("TextLabel")
    lbl.Font               = Enum.Font.Gotham
    lbl.TextSize           = 12
    lbl.TextColor3         = Color3.fromRGB(230, 230, 230)
    lbl.BackgroundTransparency = 1
    lbl.Size               = UDim2.new(1, -10, 0, 22)
    lbl.Position           = UDim2.new(0, 10, 0, 6)
    lbl.TextXAlignment     = Enum.TextXAlignment.Left
    lbl.ZIndex             = 7
    lbl.Parent             = row

    local trackBg = Instance.new("Frame")
    trackBg.Size             = UDim2.new(1, -20, 0, 4)
    trackBg.Position         = UDim2.new(0, 10, 1, -14)
    trackBg.BackgroundColor3 = Color3.fromRGB(55, 55, 55)
    trackBg.BorderSizePixel  = 0
    trackBg.ZIndex           = 7
    trackBg.Parent           = row

    local tbCornerInner = Instance.new("UICorner")
    tbCornerInner.CornerRadius = UDim.new(1, 0)
    tbCornerInner.Parent = trackBg

    local fill = Instance.new("Frame")
    fill.Size             = UDim2.new((default - min) / (max - min), 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    fill.BorderSizePixel  = 0
    fill.ZIndex           = 8
    fill.Parent           = trackBg

    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(1, 0)
    fillCorner.Parent = fill

    local value = default
    lbl.Text = label .. ":  " .. value

    local dragging = false

    local hitbox = Instance.new("TextButton")
    hitbox.Size                 = UDim2.new(1, 0, 1, 0)
    hitbox.BackgroundTransparency = 1
    hitbox.Text                 = ""
    hitbox.ZIndex               = 9
    hitbox.Parent               = row

    local function updateSlider(input)
        local rel = math.clamp(
            (input.Position.X - trackBg.AbsolutePosition.X) / trackBg.AbsoluteSize.X,
            0, 1
        )
        value    = math.floor(min + rel * (max - min))
        fill.Size = UDim2.new(rel, 0, 1, 0)
        lbl.Text  = label .. ":  " .. value
        if callback then callback(value) end
    end

    hitbox.MouseButton1Down:Connect(function() dragging = true end)
    UserInput.InputChanged:Connect(function(i)
        if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then
            updateSlider(i)
        end
    end)
    UserInput.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)

    return function() return value end
end

-- ─── Tab System ──────────────────────────────────────────────────────────────

local tabPages   = {}
local tabButtons = {}

local function makeTab(name, icon)
    local btn = Instance.new("TextButton")
    btn.Size                   = UDim2.new(1, 0, 0, 34)
    btn.BackgroundColor3       = Color3.fromRGB(255, 255, 255)
    btn.BackgroundTransparency = 0.9
    btn.BorderSizePixel        = 0
    btn.Font                   = Enum.Font.GothamSemibold
    btn.TextSize               = 12
    btn.TextColor3             = Color3.fromRGB(160, 160, 160)
    btn.Text                   = icon .. "  " .. name
    btn.TextXAlignment         = Enum.TextXAlignment.Left
    btn.AutoButtonColor        = false
    btn.ZIndex                 = 6
    btn.Parent                 = sidebar

    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 7)
    btnCorner.Parent = btn

    local btnPad = Instance.new("UIPadding")
    btnPad.PaddingLeft = UDim.new(0, 10)
    btnPad.Parent = btn

    local page = Instance.new("ScrollingFrame")
    page.Size                   = UDim2.new(1, 0, 1, 0)
    page.BackgroundTransparency = 1
    page.BorderSizePixel        = 0
    page.ScrollBarThickness     = 2
    page.ScrollBarImageColor3   = Color3.fromRGB(255, 255, 255)
    page.CanvasSize             = UDim2.new(0, 0, 0, 0)
    page.AutomaticCanvasSize    = Enum.AutomaticSize.Y
    page.ZIndex                 = 5
    page.Visible                = false
    page.Parent                 = contentArea

    local layout = Instance.new("UIListLayout")
    layout.Padding   = UDim.new(0, 6)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Parent    = page

    local pad = Instance.new("UIPadding")
    pad.PaddingTop    = UDim.new(0, 8)
    pad.PaddingBottom = UDim.new(0, 8)
    pad.PaddingLeft   = UDim.new(0, 8)
    pad.PaddingRight  = UDim.new(0, 10)
    pad.Parent        = page

    tabPages[name]   = page
    tabButtons[name] = btn

    btn.MouseButton1Click:Connect(function()
        for _, p in pairs(tabPages)   do p.Visible = false end
        for _, b in pairs(tabButtons) do
            b.BackgroundTransparency = 0.9
            b.TextColor3             = Color3.fromRGB(160, 160, 160)
        end
        page.Visible              = true
        btn.BackgroundTransparency = 0.6
        btn.TextColor3            = Color3.fromRGB(255, 255, 255)
    end)

    return page, btn
end

-- ─── Build Tabs ───────────────────────────────────────────────────────────────

local aimbotPage, aimbotBtn = makeTab("Aimbot",   "🎯")
local espPage,    espBtn    = makeTab("ESP",       "👁")
local movePage,   moveBtn   = makeTab("Movement",  "⚡")
local visualPage, visualBtn = makeTab("Visuals",   "🔵")

-- open first tab immediately
aimbotPage.Visible             = true
aimbotBtn.BackgroundTransparency = 0.6
aimbotBtn.TextColor3           = Color3.fromRGB(255, 255, 255)

-- ─── Aimbot Tab ───────────────────────────────────────────────────────────────

makeSection(aimbotPage, "Aimbot")
makeToggle(aimbotPage, "Enable Aimbot",       false, function(v) _G.AimbotEnabled   = v end)
makeToggle(aimbotPage, "Require Right Click", true,  function(v) _G.AimbotRightClick = v end)

makeSection(aimbotPage, "Target")
makeToggle(aimbotPage, "Aim at Murderer", true,  function(v) _G.AimMurderer = v end)
makeToggle(aimbotPage, "Aim at Sheriff",  false, function(v) _G.AimSheriff  = v end)

makeSection(aimbotPage, "Settings")
makeSlider(aimbotPage, "Smoothing",  1,  30,  12,  function(v) _G.AimbotSmoothing = v end)
makeSlider(aimbotPage, "FOV Radius", 50, 500, 180, function(v) _G.AimbotFOV       = v end)
makeToggle(aimbotPage, "Show FOV Circle", true, function(v) _G.ShowFOV = v end)

_G.AimbotEnabled    = false
_G.AimbotRightClick = true
_G.AimMurderer      = true
_G.AimSheriff       = false
_G.AimbotSmoothing  = 12
_G.AimbotFOV        = 180
_G.ShowFOV          = true

-- ─── ESP Tab ──────────────────────────────────────────────────────────────────

makeSection(espPage, "ESP")
makeToggle(espPage, "Box ESP",      false, function(v) _G.BoxESP      = v end)
makeToggle(espPage, "Chams ESP",    false, function(v) _G.ChamsESP    = v end)
makeToggle(espPage, "Name ESP",     true,  function(v) _G.NameESP     = v end)
makeToggle(espPage, "Distance ESP", true,  function(v) _G.DistanceESP = v end)

makeSection(espPage, "Colors")
local colorNote = Instance.new("TextLabel")
colorNote.Text               = "🔴 Murderer  🟢 Sheriff  ⚪ Innocent"
colorNote.Font               = Enum.Font.Gotham
colorNote.TextSize           = 11
colorNote.TextColor3         = Color3.fromRGB(200, 200, 200)
colorNote.BackgroundTransparency = 1
colorNote.Size               = UDim2.new(1, 0, 0, 22)
colorNote.TextXAlignment     = Enum.TextXAlignment.Left
colorNote.ZIndex             = 6
colorNote.Parent             = espPage

_G.BoxESP      = false
_G.ChamsESP    = false
_G.NameESP     = true
_G.DistanceESP = true

-- ─── Movement Tab ─────────────────────────────────────────────────────────────

makeSection(movePage, "Movement")
makeToggle(movePage, "Noclip",        false, function(v) _G.NoclipEnabled  = v end)
makeToggle(movePage, "Speedhack",     false, function(v) _G.SpeedEnabled   = v end)
makeToggle(movePage, "Infinite Jump", false, function(v) _G.InfJumpEnabled = v end)

makeSection(movePage, "Speed")
makeSlider(movePage, "Speed Multiplier", 1, 3, 1, function(v) _G.SpeedMultiplier = v end)

_G.NoclipEnabled   = false
_G.SpeedEnabled    = false
_G.InfJumpEnabled  = false
_G.SpeedMultiplier = 1

-- ─── Visuals Tab ──────────────────────────────────────────────────────────────

makeSection(visualPage, "Crosshair")
makeToggle(visualPage, "Custom Crosshair", true, function(v) _G.CrosshairEnabled = v end)

makeSection(visualPage, "Style")
makeSlider(visualPage, "Size",      4,  30, 14, function(v) _G.CrosshairSize  = v end)
makeSlider(visualPage, "Gap",       0,  12, 4,  function(v) _G.CrosshairGap   = v end)
makeSlider(visualPage, "Thickness", 1,  4,  1,  function(v) _G.CrosshairThick = v end)

_G.CrosshairEnabled = true
_G.CrosshairSize    = 14
_G.CrosshairGap     = 4
_G.CrosshairThick   = 1

-- ─── Hint ────────────────────────────────────────────────────────────────────

local hint = Instance.new("TextLabel")
hint.Text               = TOGGLE_KEY.Name .. " — toggle UI"
hint.Font               = Enum.Font.Gotham
hint.TextSize           = 10
hint.TextColor3         = Color3.fromRGB(90, 90, 90)
hint.BackgroundTransparency = 1
hint.Size               = UDim2.new(1, 0, 0, 14)
hint.Position           = UDim2.new(0, 0, 1, -16)
hint.TextXAlignment     = Enum.TextXAlignment.Center
hint.ZIndex             = 6
hint.Parent             = main
