-- Crypt-MM2-Legit | UI

local Players      = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInput    = game:GetService("UserInputService")
local Stats        = game:GetService("Stats")
local lp           = Players.LocalPlayer

local cfg         = _G.Config or {}
local BG          = cfg.BackgroundDecal   or "rbxassetid://0"
local ICON_IMG    = cfg.MinimizeIconDecal or "rbxassetid://0"
local TOGGLE_KEY  = cfg.ToggleKey        or Enum.KeyCode.RightShift
local WIN_SIZE    = cfg.WindowSize       or UDim2.new(0, 540, 0, 420)
local ICON_SIZE   = cfg.IconSize         or UDim2.new(0, 54, 0, 54)
local START_POS   = cfg.StartPosition    or UDim2.new(0.5, -270, 0.5, -210)

-- ── Screen GUI ───────────────────────────────────────────────────────────────

local gui = Instance.new("ScreenGui")
gui.Name           = "CryptMM2"
gui.ResetOnSpawn   = false
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.IgnoreGuiInset = true
gui.Parent         = (gethui and gethui()) or lp.PlayerGui

-- ── Main Window ──────────────────────────────────────────────────────────────

local main = Instance.new("Frame")
main.Name                   = "Main"
main.Size                   = WIN_SIZE
main.Position               = START_POS
main.BackgroundColor3       = Color3.fromRGB(0, 0, 0)
main.BackgroundTransparency = 1  -- transparent; image fills it
main.BorderSizePixel        = 0
main.Active                 = true
main.Draggable              = true
main.ClipsDescendants       = true
main.Parent                 = gui

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 14)
mainCorner.Parent       = main

-- White border stroke
local mainStroke = Instance.new("UIStroke")
mainStroke.Color       = Color3.fromRGB(255, 255, 255)
mainStroke.Thickness   = 1.5
mainStroke.Transparency = 0.6
mainStroke.Parent      = main

-- BG image — IS the UI surface
local bgImg = Instance.new("ImageLabel")
bgImg.Name               = "BG"
bgImg.Image              = BG
bgImg.Size               = UDim2.new(1, 0, 1, 0)
bgImg.Position           = UDim2.new(0, 0, 0, 0)
bgImg.BackgroundColor3   = Color3.fromRGB(8, 8, 12)  -- fallback if no image
bgImg.BackgroundTransparency = 0
bgImg.ImageTransparency  = 0
bgImg.ScaleType          = Enum.ScaleType.Stretch
bgImg.ZIndex             = 1
bgImg.Parent             = main

local bgCorner = Instance.new("UICorner")
bgCorner.CornerRadius = UDim.new(0, 14)
bgCorner.Parent       = bgImg

-- Dark wash over image (so text is readable)
local wash = Instance.new("Frame")
wash.Size                   = UDim2.new(1, 0, 1, 0)
wash.BackgroundColor3       = Color3.fromRGB(0, 0, 0)
wash.BackgroundTransparency = 0.55
wash.BorderSizePixel        = 0
wash.ZIndex                 = 2
wash.Parent                 = main

local washCorner = Instance.new("UICorner")
washCorner.CornerRadius = UDim.new(0, 14)
washCorner.Parent       = wash

-- ── Title Bar ────────────────────────────────────────────────────────────────

local titleBar = Instance.new("Frame")
titleBar.Size                   = UDim2.new(1, 0, 0, 40)
titleBar.BackgroundColor3       = Color3.fromRGB(0, 0, 0)
titleBar.BackgroundTransparency = 0.4
titleBar.BorderSizePixel        = 0
titleBar.ZIndex                 = 5
titleBar.Parent                 = main

local tbTop = Instance.new("UICorner")
tbTop.CornerRadius = UDim.new(0, 14)
tbTop.Parent       = titleBar

local tbSquare = Instance.new("Frame")
tbSquare.Size                   = UDim2.new(1, 0, 0, 14)
tbSquare.Position               = UDim2.new(0, 0, 1, -14)
tbSquare.BackgroundColor3       = Color3.fromRGB(0, 0, 0)
tbSquare.BackgroundTransparency = 0.4
tbSquare.BorderSizePixel        = 0
tbSquare.ZIndex                 = 5
tbSquare.Parent                 = titleBar

local titleLbl = Instance.new("TextLabel")
titleLbl.Text               = "⚰  Crypt MM2"
titleLbl.Font               = Enum.Font.GothamBold
titleLbl.TextSize           = 14
titleLbl.TextColor3         = Color3.fromRGB(255, 255, 255)
titleLbl.BackgroundTransparency = 1
titleLbl.Size               = UDim2.new(1, -90, 1, 0)
titleLbl.Position           = UDim2.new(0, 14, 0, 0)
titleLbl.TextXAlignment     = Enum.TextXAlignment.Left
titleLbl.ZIndex             = 6
titleLbl.Parent             = titleBar

local accent = Instance.new("Frame")
accent.Size                   = UDim2.new(1, 0, 0, 1)
accent.Position               = UDim2.new(0, 0, 0, 40)
accent.BackgroundColor3       = Color3.fromRGB(255, 255, 255)
accent.BackgroundTransparency = 0.78
accent.BorderSizePixel        = 0
accent.ZIndex                 = 4
accent.Parent                 = main

-- ── Circle Buttons (minimize = orange, close = red) ──────────────────────────

local function makeCircleBtn(parent, color, symbol, xOffset)
    local btn = Instance.new("TextButton")
    btn.Size                   = UDim2.new(0, 14, 0, 14)
    btn.Position               = UDim2.new(1, xOffset, 0.5, -7)
    btn.BackgroundColor3       = color
    btn.BorderSizePixel        = 0
    btn.Text                   = ""
    btn.AutoButtonColor        = false
    btn.ZIndex                 = 8
    btn.Parent                 = parent

    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(1, 0)
    c.Parent       = btn

    btn.MouseEnter:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.1), {
            BackgroundTransparency = 0.3
        }):Play()
    end)
    btn.MouseLeave:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.1), {
            BackgroundTransparency = 0
        }):Play()
    end)
    return btn
end

local closeBtn = makeCircleBtn(titleBar, Color3.fromRGB(220, 55, 55),  "✕", -22)
local minBtn   = makeCircleBtn(titleBar, Color3.fromRGB(230, 130, 30), "—", -40)

-- ── Minimized Icon ───────────────────────────────────────────────────────────

local iconFrame = Instance.new("Frame")
iconFrame.Size                   = ICON_SIZE
iconFrame.Position               = START_POS
iconFrame.BackgroundColor3       = Color3.fromRGB(10, 10, 10)
iconFrame.BackgroundTransparency = 0.1
iconFrame.BorderSizePixel        = 0
iconFrame.Active                 = true
iconFrame.Draggable              = true
iconFrame.Visible                = false
iconFrame.ZIndex                 = 20
iconFrame.Parent                 = gui

local iconCorner = Instance.new("UICorner")
iconCorner.CornerRadius = UDim.new(0, 12)
iconCorner.Parent       = iconFrame

local iconStroke = Instance.new("UIStroke")
iconStroke.Color     = Color3.fromRGB(255, 255, 255)
iconStroke.Thickness = 1
iconStroke.Transparency = 0.6
iconStroke.Parent    = iconFrame

local iconImg = Instance.new("ImageLabel")
iconImg.Image                = ICON_IMG
iconImg.Size                 = UDim2.new(1, -8, 1, -8)
iconImg.Position             = UDim2.new(0, 4, 0, 4)
iconImg.BackgroundTransparency = 1
iconImg.ScaleType            = Enum.ScaleType.Fit
iconImg.ZIndex               = 21
iconImg.Parent               = iconFrame

local iconBtn = Instance.new("TextButton")
iconBtn.Size                 = UDim2.new(1, 0, 1, 0)
iconBtn.BackgroundTransparency = 1
iconBtn.Text                 = ""
iconBtn.ZIndex               = 22
iconBtn.Parent               = iconFrame

-- ── Toggle Logic ─────────────────────────────────────────────────────────────

local minimized = false

local function minimize()
    minimized          = true
    iconFrame.Position = main.Position
    main.Visible       = false
    iconFrame.Visible  = true
end

local function restore()
    minimized          = false
    main.Position      = iconFrame.Position
    iconFrame.Visible  = false
    main.Visible       = true
end

minBtn.MouseButton1Click:Connect(minimize)
iconBtn.MouseButton1Click:Connect(restore)
closeBtn.MouseButton1Click:Connect(function() gui:Destroy() end)

UserInput.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == TOGGLE_KEY then
        if minimized then restore() else minimize() end
    end
end)

-- ── Sidebar ──────────────────────────────────────────────────────────────────

local sidebar = Instance.new("Frame")
sidebar.Size                   = UDim2.new(0, 118, 1, -42)
sidebar.Position               = UDim2.new(0, 0, 0, 41)
sidebar.BackgroundColor3       = Color3.fromRGB(0, 0, 0)
sidebar.BackgroundTransparency = 0.5
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
divider.Position               = UDim2.new(0, 118, 0, 41)
divider.BackgroundColor3       = Color3.fromRGB(255, 255, 255)
divider.BackgroundTransparency = 0.82
divider.BorderSizePixel        = 0
divider.ZIndex                 = 4
divider.Parent                 = main

-- ── Content Area ─────────────────────────────────────────────────────────────

local contentArea = Instance.new("Frame")
contentArea.Size                   = UDim2.new(1, -126, 1, -50)
contentArea.Position               = UDim2.new(0, 122, 0, 46)
contentArea.BackgroundTransparency = 1
contentArea.BorderSizePixel        = 0
contentArea.ClipsDescendants       = true
contentArea.ZIndex                 = 4
contentArea.Parent                 = main

-- ── Widget Builders ──────────────────────────────────────────────────────────

-- Section: title + BG container for items
local function makeSection(parent, text)
    -- outer container (returned so you add toggles/sliders inside it)
    local container = Instance.new("Frame")
    container.Size                   = UDim2.new(1, 0, 0, 0)
    container.AutomaticSize          = Enum.AutomaticSize.Y
    container.BackgroundColor3       = Color3.fromRGB(255, 255, 255)
    container.BackgroundTransparency = 0.93
    container.BorderSizePixel        = 0
    container.ZIndex                 = 5
    container.Parent                 = parent

    local cCorner = Instance.new("UICorner")
    cCorner.CornerRadius = UDim.new(0, 8)
    cCorner.Parent       = container

    local cLayout = Instance.new("UIListLayout")
    cLayout.Padding  = UDim.new(0, 4)
    cLayout.SortOrder = Enum.SortOrder.LayoutOrder
    cLayout.Parent   = container

    local cPad = Instance.new("UIPadding")
    cPad.PaddingTop    = UDim.new(0, 4)
    cPad.PaddingBottom = UDim.new(0, 6)
    cPad.PaddingLeft   = UDim.new(0, 6)
    cPad.PaddingRight  = UDim.new(0, 6)
    cPad.Parent        = container

    -- title row inside container
    local titleFrame = Instance.new("Frame")
    titleFrame.Size                   = UDim2.new(1, 0, 0, 22)
    titleFrame.BackgroundTransparency = 1
    titleFrame.BorderSizePixel        = 0
    titleFrame.ZIndex                 = 6
    titleFrame.LayoutOrder            = 0
    titleFrame.Parent                 = container

    local sLbl = Instance.new("TextLabel")
    sLbl.Text               = text:upper()
    sLbl.Font               = Enum.Font.GothamBold
    sLbl.TextSize           = 10
    sLbl.TextColor3         = Color3.fromRGB(255, 255, 255)
    sLbl.BackgroundTransparency = 1
    sLbl.Size               = UDim2.new(1, 0, 1, 0)
    sLbl.TextXAlignment     = Enum.TextXAlignment.Left
    sLbl.ZIndex             = 7
    sLbl.Parent             = titleFrame

    local sLine = Instance.new("Frame")
    sLine.Size                   = UDim2.new(1, 0, 0, 1)
    sLine.Position               = UDim2.new(0, 0, 1, -1)
    sLine.BackgroundColor3       = Color3.fromRGB(255, 255, 255)
    sLine.BackgroundTransparency = 0.8
    sLine.BorderSizePixel        = 0
    sLine.ZIndex                 = 7
    sLine.Parent                 = titleFrame

    return container  -- add widgets into this
end

local function makeToggle(parent, label, default, callback, order)
    default = (default == true)

    local row = Instance.new("Frame")
    row.Size                   = UDim2.new(1, 0, 0, 32)
    row.BackgroundTransparency = 1
    row.BorderSizePixel        = 0
    row.ZIndex                 = 6
    row.LayoutOrder            = order or 1
    row.Parent                 = parent

    local lbl = Instance.new("TextLabel")
    lbl.Text               = label
    lbl.Font               = Enum.Font.Gotham
    lbl.TextSize           = 12
    lbl.TextColor3         = Color3.fromRGB(225, 225, 225)
    lbl.BackgroundTransparency = 1
    lbl.Size               = UDim2.new(1, -52, 1, 0)
    lbl.Position           = UDim2.new(0, 6, 0, 0)
    lbl.TextXAlignment     = Enum.TextXAlignment.Left
    lbl.ZIndex             = 7
    lbl.Parent             = row

    local track = Instance.new("Frame")
    track.Size             = UDim2.new(0, 36, 0, 18)
    track.Position         = UDim2.new(1, -40, 0.5, -9)
    track.BackgroundColor3 = default
        and Color3.fromRGB(255, 255, 255)
        or  Color3.fromRGB(50, 50, 55)
    track.BorderSizePixel  = 0
    track.ZIndex           = 7
    track.Parent           = row

    local tc = Instance.new("UICorner")
    tc.CornerRadius = UDim.new(1, 0)
    tc.Parent       = track

    local knob = Instance.new("Frame")
    knob.Size             = UDim2.new(0, 14, 0, 14)
    knob.Position         = default
        and UDim2.new(1, -16, 0.5, -7)
        or  UDim2.new(0,   2, 0.5, -7)
    knob.BackgroundColor3 = default
        and Color3.fromRGB(0, 0, 0)
        or  Color3.fromRGB(140, 140, 140)
    knob.BorderSizePixel  = 0
    knob.ZIndex           = 8
    knob.Parent           = track

    local kc = Instance.new("UICorner")
    kc.CornerRadius = UDim.new(1, 0)
    kc.Parent       = knob

    local state = default
    local ti    = TweenInfo.new(0.13, Enum.EasingStyle.Quad)

    local hit = Instance.new("TextButton")
    hit.Size                 = UDim2.new(1, 0, 1, 0)
    hit.BackgroundTransparency = 1
    hit.Text                 = ""
    hit.ZIndex               = 9
    hit.Parent               = row

    hit.MouseButton1Click:Connect(function()
        state = not state
        TweenService:Create(track, ti, {
            BackgroundColor3 = state
                and Color3.fromRGB(255, 255, 255)
                or  Color3.fromRGB(50, 50, 55)
        }):Play()
        TweenService:Create(knob, ti, {
            Position = state
                and UDim2.new(1, -16, 0.5, -7)
                or  UDim2.new(0,   2, 0.5, -7),
            BackgroundColor3 = state
                and Color3.fromRGB(0, 0, 0)
                or  Color3.fromRGB(140, 140, 140)
        }):Play()
        if callback then callback(state) end
    end)

    return function() return state end
end

local function makeSlider(parent, label, min, max, default, callback, order)
    local row = Instance.new("Frame")
    row.Size                   = UDim2.new(1, 0, 0, 46)
    row.BackgroundTransparency = 1
    row.BorderSizePixel        = 0
    row.ZIndex                 = 6
    row.LayoutOrder            = order or 1
    row.Parent                 = parent

    local lbl = Instance.new("TextLabel")
    lbl.Font               = Enum.Font.Gotham
    lbl.TextSize           = 12
    lbl.TextColor3         = Color3.fromRGB(225, 225, 225)
    lbl.BackgroundTransparency = 1
    lbl.Size               = UDim2.new(1, -10, 0, 20)
    lbl.Position           = UDim2.new(0, 6, 0, 4)
    lbl.TextXAlignment     = Enum.TextXAlignment.Left
    lbl.ZIndex             = 7
    lbl.Parent             = row

    local trackBg = Instance.new("Frame")
    trackBg.Size             = UDim2.new(1, -12, 0, 4)
    trackBg.Position         = UDim2.new(0, 6, 1, -12)
    trackBg.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
    trackBg.BorderSizePixel  = 0
    trackBg.ZIndex           = 7
    trackBg.Parent           = row

    local tc = Instance.new("UICorner")
    tc.CornerRadius = UDim.new(1, 0)
    tc.Parent       = trackBg

    local fill = Instance.new("Frame")
    fill.Size             = UDim2.new((default - min) / (max - min), 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    fill.BorderSizePixel  = 0
    fill.ZIndex           = 8
    fill.Parent           = trackBg

    local fc = Instance.new("UICorner")
    fc.CornerRadius = UDim.new(1, 0)
    fc.Parent       = fill

    local value = default
    lbl.Text = label .. ":  " .. value

    local dragging = false
    local hit = Instance.new("TextButton")
    hit.Size                 = UDim2.new(1, 0, 1, 0)
    hit.BackgroundTransparency = 1
    hit.Text                 = ""
    hit.ZIndex               = 9
    hit.Parent               = row

    local function upd(input)
        local rel = math.clamp(
            (input.Position.X - trackBg.AbsolutePosition.X) / trackBg.AbsoluteSize.X,
            0, 1)
        value     = math.floor(min + rel * (max - min))
        fill.Size = UDim2.new(rel, 0, 1, 0)
        lbl.Text  = label .. ":  " .. value
        if callback then callback(value) end
    end

    hit.MouseButton1Down:Connect(function() dragging = true end)
    UserInput.InputChanged:Connect(function(i)
        if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then upd(i) end
    end)
    UserInput.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
    end)

    return function() return value end
end

local function makeLabel(parent, text, order)
    local lbl = Instance.new("TextLabel")
    lbl.Text               = text
    lbl.Font               = Enum.Font.Gotham
    lbl.TextSize           = 11
    lbl.TextColor3         = Color3.fromRGB(200, 200, 200)
    lbl.BackgroundTransparency = 1
    lbl.Size               = UDim2.new(1, 0, 0, 18)
    lbl.TextXAlignment     = Enum.TextXAlignment.Left
    lbl.LayoutOrder        = order or 99
    lbl.ZIndex             = 7
    lbl.Parent             = parent
    return lbl
end

-- ── Tab Builder ──────────────────────────────────────────────────────────────

local tabPages   = {}
local tabButtons = {}

local function makeTab(name, iconId)
    local btn = Instance.new("Frame")
    btn.Size                   = UDim2.new(1, 0, 0, 34)
    btn.BackgroundColor3       = Color3.fromRGB(255, 255, 255)
    btn.BackgroundTransparency = 0.92
    btn.BorderSizePixel        = 0
    btn.ZIndex                 = 6
    btn.Parent                 = sidebar

    local bc = Instance.new("UICorner")
    bc.CornerRadius = UDim.new(0, 7)
    bc.Parent       = btn

    -- Decal icon (16x16 inside button)
    local iconImg2 = Instance.new("ImageLabel")
    iconImg2.Image               = iconId or "rbxassetid://0"
    iconImg2.Size                = UDim2.new(0, 16, 0, 16)
    iconImg2.Position            = UDim2.new(0, 8, 0.5, -8)
    iconImg2.BackgroundTransparency = 1
    iconImg2.ScaleType           = Enum.ScaleType.Fit
    iconImg2.ZIndex              = 7
    iconImg2.Parent              = btn

    local bLbl = Instance.new("TextLabel")
    bLbl.Text               = name
    bLbl.Font               = Enum.Font.GothamSemibold
    bLbl.TextSize           = 12
    bLbl.TextColor3         = Color3.fromRGB(160, 160, 160)
    bLbl.BackgroundTransparency = 1
    bLbl.Size               = UDim2.new(1, -32, 1, 0)
    bLbl.Position           = UDim2.new(0, 28, 0, 0)
    bLbl.TextXAlignment     = Enum.TextXAlignment.Left
    bLbl.ZIndex             = 7
    bLbl.Parent             = btn

    -- invisible click area
    local click = Instance.new("TextButton")
    click.Size                 = UDim2.new(1, 0, 1, 0)
    click.BackgroundTransparency = 1
    click.Text                 = ""
    click.ZIndex               = 8
    click.Parent               = btn

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

    local pLayout = Instance.new("UIListLayout")
    pLayout.Padding   = UDim.new(0, 6)
    pLayout.SortOrder = Enum.SortOrder.LayoutOrder
    pLayout.Parent    = page

    local pPad = Instance.new("UIPadding")
    pPad.PaddingTop    = UDim.new(0, 8)
    pPad.PaddingBottom = UDim.new(0, 8)
    pPad.PaddingLeft   = UDim.new(0, 6)
    pPad.PaddingRight  = UDim.new(0, 8)
    pPad.Parent        = page

    tabPages[name]   = {page = page, btn = btn, lbl = bLbl}
    tabButtons[name] = {btn = btn, lbl = bLbl}

    click.MouseButton1Click:Connect(function()
        for _, t in pairs(tabPages) do
            t.page.Visible             = false
            t.btn.BackgroundTransparency = 0.92
            t.lbl.TextColor3           = Color3.fromRGB(160, 160, 160)
        end
        page.Visible               = true
        btn.BackgroundTransparency = 0.65
        bLbl.TextColor3            = Color3.fromRGB(255, 255, 255)
    end)

    return page, click
end

-- ── Build Tabs ───────────────────────────────────────────────────────────────

local mainPage,    _ = makeTab("Main",         cfg.Icon_Main        or "rbxassetid://0")
local aimbotPage,  _ = makeTab("Aimbot",       cfg.Icon_Aimbot      or "rbxassetid://0")
local espPage,     _ = makeTab("ESP",          cfg.Icon_ESP         or "rbxassetid://0")
local movePage,    _ = makeTab("Local Player", cfg.Icon_LocalPlayer or "rbxassetid://0")
local visualPage,  _ = makeTab("Visuals",      cfg.Icon_Visuals     or "rbxassetid://0")

-- open Main tab first
tabPages["Main"].page.Visible             = true
tabPages["Main"].btn.BackgroundTransparency = 0.65
tabPages["Main"].lbl.TextColor3           = Color3.fromRGB(255, 255, 255)

-- ── Main Tab ─────────────────────────────────────────────────────────────────

local infoSection = makeSection(mainPage, "Server Info")
infoSection.LayoutOrder = 1

-- Welcome header
local welcomeLbl = Instance.new("TextLabel")
welcomeLbl.Text               = "Welcome, " .. lp.DisplayName
welcomeLbl.Font               = Enum.Font.GothamBold
welcomeLbl.TextSize           = 16
welcomeLbl.TextColor3         = Color3.fromRGB(255, 255, 255)
welcomeLbl.BackgroundTransparency = 1
welcomeLbl.Size               = UDim2.new(1, 0, 0, 22)
welcomeLbl.TextXAlignment     = Enum.TextXAlignment.Left
welcomeLbl.LayoutOrder        = 1
welcomeLbl.ZIndex             = 7
welcomeLbl.Parent             = infoSection

local usernameLbl = Instance.new("TextLabel")
usernameLbl.Text               = "@" .. lp.Name
usernameLbl.Font               = Enum.Font.Gotham
usernameLbl.TextSize           = 11
usernameLbl.TextColor3         = Color3.fromRGB(160, 160, 170)
usernameLbl.BackgroundTransparency = 1
usernameLbl.Size               = UDim2.new(1, 0, 0, 16)
usernameLbl.TextXAlignment     = Enum.TextXAlignment.Left
usernameLbl.LayoutOrder        = 2
usernameLbl.ZIndex             = 7
usernameLbl.Parent             = infoSection

local creditLbl = Instance.new("TextLabel")
creditLbl.Text               = "Created by Crypt0"
creditLbl.Font               = Enum.Font.GothamBold
creditLbl.TextSize           = 10
creditLbl.TextColor3         = Color3.fromRGB(120, 120, 140)
creditLbl.BackgroundTransparency = 1
creditLbl.Size               = UDim2.new(1, 0, 0, 14)
creditLbl.TextXAlignment     = Enum.TextXAlignment.Left
creditLbl.LayoutOrder        = 3
creditLbl.ZIndex             = 7
creditLbl.Parent             = infoSection

-- Live stats labels (updated every second)
local jobLbl    = makeLabel(infoSection, "Job ID: loading...",     4)
local placeLbl  = makeLabel(infoSection, "Place ID: loading...",   5)
local countLbl  = makeLabel(infoSection, "Players: loading...",    6)
local pingLbl   = makeLabel(infoSection, "Ping: loading...",       7)

task.spawn(function()
    while true do
        pcall(function()
            jobLbl.Text   = "Job ID:    " .. tostring(game.JobId):sub(1, 18) .. "..."
            placeLbl.Text = "Place ID:  " .. tostring(game.PlaceId)
            countLbl.Text = "Players:   " .. #Players:GetPlayers() .. " / " .. Players.MaxPlayers
            pingLbl.Text  = "Ping:      " .. math.floor(Stats.Network.ServerStatsItem["Data Ping"]:GetValue()) .. " ms"
        end)
        task.wait(1)
    end
end)

-- ── Aimbot Tab ───────────────────────────────────────────────────────────────

local abSec = makeSection(aimbotPage, "Aimbot")
abSec.LayoutOrder = 1
makeToggle(abSec, "Enable Aimbot",        false, function(v) _G.AimbotEnabled    = v end, 1)
makeToggle(abSec, "Require Right Click",  false, function(v) _G.AimbotRightClick = v end, 2)

local abTgt = makeSection(aimbotPage, "Target")
abTgt.LayoutOrder = 2
makeToggle(abTgt, "Aim at Murderer", false, function(v) _G.AimMurderer = v end, 1)
makeToggle(abTgt, "Aim at Sheriff",  false, function(v) _G.AimSheriff  = v end, 2)
makeLabel(abTgt,  "If both off — aims at everyone", 3)

local abSet = makeSection(aimbotPage, "Settings")
abSet.LayoutOrder = 3
makeSlider(abSet, "Smoothing",   1,  20,  5,   function(v) _G.AimbotSmoothing = v end, 1)
makeSlider(abSet, "FOV Radius",  20, 600, 250, function(v) _G.AimbotFOV       = v end, 2)
makeToggle(abSet, "Show FOV Circle",    false, function(v) _G.ShowFOV        = v end, 3)
makeToggle(abSet, "Show Target Tracer", false, function(v) _G.TargetTracer   = v end, 4)

_G.AimbotEnabled    = false
_G.AimbotRightClick = false
_G.AimMurderer      = false
_G.AimSheriff       = false
_G.AimbotSmoothing  = 5
_G.AimbotFOV        = 250
_G.ShowFOV          = false
_G.TargetTracer     = false

-- ── ESP Tab ──────────────────────────────────────────────────────────────────

local espSec = makeSection(espPage, "ESP")
espSec.LayoutOrder = 1
makeToggle(espSec, "Box ESP",      false, function(v) _G.BoxESP      = v end, 1)
makeToggle(espSec, "Chams ESP",    false, function(v) _G.ChamsESP    = v end, 2)
makeToggle(espSec, "Name ESP",     false, function(v) _G.NameESP     = v end, 3)
makeToggle(espSec, "Distance ESP", false, function(v) _G.DistanceESP = v end, 4)
makeToggle(espSec, "Tracers",      false, function(v) _G.Tracers     = v end, 5)

local espCol = makeSection(espPage, "Team Colors")
espCol.LayoutOrder = 2
makeLabel(espCol, "Red = Murderer", 1)
makeLabel(espCol, "Cyan = Sheriff", 2)
makeLabel(espCol, "White = Innocent", 3)

_G.BoxESP      = false
_G.ChamsESP    = false
_G.NameESP     = false
_G.DistanceESP = false
_G.Tracers     = false

-- ── Local Player Tab ─────────────────────────────────────────────────────────

local mvSec = makeSection(movePage, "Movement")
mvSec.LayoutOrder = 1
makeToggle(mvSec, "Noclip",          false, function(v) _G.NoclipEnabled  = v end, 1)
makeToggle(mvSec, "Speedhack",       false, function(v) _G.SpeedEnabled   = v end, 2)
makeToggle(mvSec, "Infinite Jump",   false, function(v) _G.InfJumpEnabled = v end, 3)
makeToggle(mvSec, "Invisibility",    false, function(v) _G.InvisEnabled   = v end, 4)
makeSlider(mvSec, "Speed Mult",  1, 3, 1, function(v) _G.SpeedMultiplier = v end, 5)

local gunSec = makeSection(movePage, "Auto Gun")
gunSec.LayoutOrder = 2
makeToggle(gunSec, "Auto Collect Gun", false, function(v) _G.AutoGun = v end, 1)

local hbSec = makeSection(movePage, "Hitbox")
hbSec.LayoutOrder = 3
makeToggle(hbSec, "Hitbox Expander",   false, function(v) _G.HitboxEnabled = v end, 1)
makeSlider(hbSec, "Hitbox Size",  2, 12, 5, function(v) _G.HitboxSize    = v end, 2)

_G.NoclipEnabled   = false
_G.SpeedEnabled    = false
_G.InfJumpEnabled  = false
_G.InvisEnabled    = false
_G.SpeedMultiplier = 1
_G.AutoGun         = false
_G.HitboxEnabled   = false
_G.HitboxSize      = 5

-- ── Visuals Tab ──────────────────────────────────────────────────────────────

local xhSec = makeSection(visualPage, "Crosshair")
xhSec.LayoutOrder = 1
makeToggle(xhSec, "Custom Crosshair", false, function(v) _G.CrosshairEnabled = v end, 1)
makeToggle(xhSec, "RGB Spinning",     false, function(v) _G.CrosshairRGB     = v end, 2)
makeSlider(xhSec, "Size",      4, 30, 14, function(v) _G.CrosshairSize  = v end, 3)
makeSlider(xhSec, "Gap",       0, 12, 4,  function(v) _G.CrosshairGap   = v end, 4)
makeSlider(xhSec, "Thickness", 1, 4,  1,  function(v) _G.CrosshairThick = v end, 5)
makeSlider(xhSec, "Spin Speed",1, 20, 5,  function(v) _G.CrosshairSpin  = v end, 6)

_G.CrosshairEnabled = false
_G.CrosshairRGB     = false
_G.CrosshairSize    = 14
_G.CrosshairGap     = 4
_G.CrosshairThick   = 1
_G.CrosshairSpin    = 5

-- ── Key hint ─────────────────────────────────────────────────────────────────

local hint = Instance.new("TextLabel")
hint.Text               = "Right Shift — toggle"
hint.Font               = Enum.Font.Gotham
hint.TextSize           = 10
hint.TextColor3         = Color3.fromRGB(80, 80, 90)
hint.BackgroundTransparency = 1
hint.Size               = UDim2.new(1, 0, 0, 14)
hint.Position           = UDim2.new(0, 0, 1, -16)
hint.TextXAlignment     = Enum.TextXAlignment.Center
hint.ZIndex             = 6
hint.Parent             = main
