-- Crypt-MM2-Legit | UI

local Players        = game:GetService("Players")
local TweenService   = game:GetService("TweenService")
local UserInput      = game:GetService("UserInputService")
local ContentProvider = game:GetService("ContentProvider")
local Stats          = game:GetService("Stats")
local lp             = Players.LocalPlayer

local cfg        = _G.Config or {}
local BG         = cfg.BackgroundDecal   or "rbxassetid://0"
local ICON_IMG   = cfg.MinimizeIconDecal or "rbxassetid://0"
local TOGGLE_KEY = cfg.ToggleKey         or Enum.KeyCode.RightShift
local WIN_SIZE   = cfg.WindowSize        or UDim2.new(0, 560, 0, 440)
local ICON_SIZE  = cfg.IconSize          or UDim2.new(0, 54, 0, 54)
local START_POS  = cfg.StartPosition     or UDim2.new(0.5, -280, 0.5, -220)

-- ── DECAL FIX: NEVER use gethui() for image-bearing GUIs ─────────────────────
-- gethui() (CoreGui) blocks decal rendering on most executors.
-- PlayerGui always renders images correctly.
local gui = Instance.new("ScreenGui")
gui.Name             = "CryptMM2"
gui.ResetOnSpawn     = false
gui.ZIndexBehavior   = Enum.ZIndexBehavior.Sibling
gui.IgnoreGuiInset   = true
gui.DisplayOrder     = 999
gui.Parent           = lp:WaitForChild("PlayerGui")  -- KEY FIX: NOT gethui()

-- ── Main Window ──────────────────────────────────────────────────────────────

local main = Instance.new("Frame")
main.Name                   = "Main"
main.Size                   = WIN_SIZE
main.Position               = START_POS
main.BackgroundColor3       = Color3.fromRGB(8, 8, 12)  -- solid fallback always visible
main.BackgroundTransparency = 0
main.BorderSizePixel        = 0
main.Active                 = true
main.Draggable              = true
main.ClipsDescendants       = true
main.Parent                 = gui

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 14)
mainCorner.Parent       = main

local mainStroke = Instance.new("UIStroke")
mainStroke.Color        = Color3.fromRGB(255, 255, 255)
mainStroke.Thickness    = 1.5
mainStroke.Transparency = 0.65
mainStroke.Parent       = main

-- DECAL FIX: ImageLabel as the surface — preload async so image actually appears
local bgImg = Instance.new("ImageLabel")
bgImg.Name                  = "BG"
bgImg.Image                 = BG
bgImg.Size                  = UDim2.new(1, 0, 1, 0)
bgImg.BackgroundTransparency = 1   -- frame transparent; image IS the surface
bgImg.ImageTransparency     = 0
bgImg.ScaleType             = Enum.ScaleType.Stretch
bgImg.ZIndex                = 1
bgImg.Parent                = main

-- Preload so it actually shows
task.spawn(function()
    ContentProvider:PreloadAsync({bgImg})
end)

-- Slight dark wash for readability
local wash = Instance.new("Frame")
wash.Size                   = UDim2.new(1, 0, 1, 0)
wash.BackgroundColor3       = Color3.fromRGB(0, 0, 0)
wash.BackgroundTransparency = 0.5
wash.BorderSizePixel        = 0
wash.ZIndex                 = 2
wash.Parent                 = main

local washC = Instance.new("UICorner")
washC.CornerRadius = UDim.new(0, 14)
washC.Parent       = wash

-- ── Title Bar ────────────────────────────────────────────────────────────────

local tb = Instance.new("Frame")
tb.Size                   = UDim2.new(1, 0, 0, 40)
tb.BackgroundColor3       = Color3.fromRGB(0, 0, 0)
tb.BackgroundTransparency = 0.35
tb.BorderSizePixel        = 0
tb.ZIndex                 = 5
tb.Parent                 = main

local tbC = Instance.new("UICorner")
tbC.CornerRadius = UDim.new(0, 14)
tbC.Parent       = tb

local tbSq = Instance.new("Frame")
tbSq.Size                   = UDim2.new(1, 0, 0, 14)
tbSq.Position               = UDim2.new(0, 0, 1, -14)
tbSq.BackgroundColor3       = Color3.fromRGB(0, 0, 0)
tbSq.BackgroundTransparency = 0.35
tbSq.BorderSizePixel        = 0
tbSq.ZIndex                 = 5
tbSq.Parent                 = tb

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
titleLbl.Parent             = tb

local accent = Instance.new("Frame")
accent.Size                   = UDim2.new(1, 0, 0, 1)
accent.Position               = UDim2.new(0, 0, 0, 40)
accent.BackgroundColor3       = Color3.fromRGB(255, 255, 255)
accent.BackgroundTransparency = 0.8
accent.BorderSizePixel        = 0
accent.ZIndex                 = 4
accent.Parent                 = main

-- ── Circle Buttons ───────────────────────────────────────────────────────────

local function circleBtn(color, xOff)
    local b = Instance.new("TextButton")
    b.Size                   = UDim2.new(0, 14, 0, 14)
    b.Position               = UDim2.new(1, xOff, 0.5, -7)
    b.BackgroundColor3       = color
    b.BorderSizePixel        = 0
    b.Text                   = ""
    b.AutoButtonColor        = false
    b.ZIndex                 = 9
    b.Parent                 = tb
    local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(1,0); c.Parent = b
    b.MouseEnter:Connect(function()
        TweenService:Create(b, TweenInfo.new(0.1), {BackgroundTransparency=0.35}):Play()
    end)
    b.MouseLeave:Connect(function()
        TweenService:Create(b, TweenInfo.new(0.1), {BackgroundTransparency=0}):Play()
    end)
    return b
end

local closeBtn = circleBtn(Color3.fromRGB(220, 55, 55),  -28)
local minBtn   = circleBtn(Color3.fromRGB(230, 130, 30), -48)

-- ── Minimized Icon ───────────────────────────────────────────────────────────

local iconFrame = Instance.new("Frame")
iconFrame.Size                   = ICON_SIZE
iconFrame.Position               = START_POS
iconFrame.BackgroundColor3       = Color3.fromRGB(10, 10, 14)
iconFrame.BackgroundTransparency = 0
iconFrame.BorderSizePixel        = 0
iconFrame.Active                 = true
iconFrame.Visible                = false
iconFrame.ZIndex                 = 20
iconFrame.Parent                 = gui   -- parented to same gui

local iconFC = Instance.new("UICorner"); iconFC.CornerRadius = UDim.new(0,12); iconFC.Parent = iconFrame
local iconFS = Instance.new("UIStroke"); iconFS.Color = Color3.fromRGB(255,255,255); iconFS.Thickness = 1; iconFS.Transparency = 0.65; iconFS.Parent = iconFrame

local iconImg = Instance.new("ImageLabel")
iconImg.Image                = ICON_IMG
iconImg.Size                 = UDim2.new(1,-8,1,-8)
iconImg.Position             = UDim2.new(0,4,0,4)
iconImg.BackgroundTransparency = 1
iconImg.ScaleType            = Enum.ScaleType.Fit
iconImg.ZIndex               = 21
iconImg.Parent               = iconFrame

task.spawn(function() ContentProvider:PreloadAsync({iconImg}) end)

-- Manual drag for minimized icon
local iconDragging, iconDragStart, iconStartPos = false, nil, nil
iconFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        iconDragging  = true
        iconDragStart = input.Position
        iconStartPos  = iconFrame.Position
    end
end)
iconFrame.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        iconDragging = false
    end
end)
UserInput.InputChanged:Connect(function(input)
    if iconDragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - iconDragStart
        iconFrame.Position = UDim2.new(
            iconStartPos.X.Scale,
            iconStartPos.X.Offset + delta.X,
            iconStartPos.Y.Scale,
            iconStartPos.Y.Offset + delta.Y
        )
    end
end)

local iconBtn = Instance.new("TextButton")
iconBtn.Size                 = UDim2.new(1,0,1,0)
iconBtn.BackgroundTransparency = 1
iconBtn.Text                 = ""
iconBtn.ZIndex               = 22
iconBtn.Parent               = iconFrame

-- ── Minimize / Close ─────────────────────────────────────────────────────────

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
iconBtn.MouseButton1Click:Connect(function()
    if not iconDragging then restore() end
end)
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

local sl = Instance.new("UIListLayout"); sl.Padding = UDim.new(0,4); sl.HorizontalAlignment = Enum.HorizontalAlignment.Center; sl.Parent = sidebar
local sp = Instance.new("UIPadding"); sp.PaddingTop = UDim.new(0,8); sp.PaddingLeft = UDim.new(0,5); sp.PaddingRight = UDim.new(0,5); sp.Parent = sidebar

local sdiv = Instance.new("Frame")
sdiv.Size                   = UDim2.new(0,1,1,-42)
sdiv.Position               = UDim2.new(0,118,0,41)
sdiv.BackgroundColor3       = Color3.fromRGB(255,255,255)
sdiv.BackgroundTransparency = 0.82
sdiv.BorderSizePixel        = 0
sdiv.ZIndex                 = 4
sdiv.Parent                 = main

-- ── Content ───────────────────────────────────────────────────────────────────

local contentArea = Instance.new("Frame")
contentArea.Size                   = UDim2.new(1,-126,1,-50)
contentArea.Position               = UDim2.new(0,122,0,46)
contentArea.BackgroundTransparency = 1
contentArea.ClipsDescendants       = true
contentArea.ZIndex                 = 4
contentArea.Parent                 = main

-- ── Notification System ───────────────────────────────────────────────────────

local notifHolder = Instance.new("Frame")
notifHolder.Size                   = UDim2.new(0, 260, 1, 0)
notifHolder.Position               = UDim2.new(1, -270, 0, 0)
notifHolder.BackgroundTransparency = 1
notifHolder.ZIndex                 = 100
notifHolder.Parent                 = gui

local notifLayout = Instance.new("UIListLayout")
notifLayout.VerticalAlignment  = Enum.VerticalAlignment.Bottom
notifLayout.Padding            = UDim.new(0, 6)
notifLayout.Parent             = notifHolder

local notifPad = Instance.new("UIPadding")
notifPad.PaddingBottom = UDim.new(0, 12)
notifPad.PaddingRight  = UDim.new(0, 8)
notifPad.Parent        = notifHolder

local typeColors = {
    success = Color3.fromRGB(60,  200,  80),
    error   = Color3.fromRGB(220, 55,   55),
    info    = Color3.fromRGB(100, 170, 255),
    warn    = Color3.fromRGB(230, 160,  30),
}

_G.Notify = function(message, ntype)
    ntype = ntype or "info"
    local col = typeColors[ntype] or typeColors.info

    local card = Instance.new("Frame")
    card.Size                   = UDim2.new(1, 0, 0, 46)
    card.BackgroundColor3       = Color3.fromRGB(10, 10, 16)
    card.BackgroundTransparency = 0.1
    card.BorderSizePixel        = 0
    card.ZIndex                 = 101
    card.Parent                 = notifHolder

    local cc = Instance.new("UICorner"); cc.CornerRadius = UDim.new(0,8); cc.Parent = card
    local cs = Instance.new("UIStroke"); cs.Color = col; cs.Thickness = 1.5; cs.Transparency = 0.3; cs.Parent = card

    -- color bar on left
    local bar = Instance.new("Frame")
    bar.Size             = UDim2.new(0, 3, 1, 0)
    bar.BackgroundColor3 = col
    bar.BorderSizePixel  = 0
    bar.ZIndex           = 102
    bar.Parent           = card
    local bc = Instance.new("UICorner"); bc.CornerRadius = UDim.new(0,4); bc.Parent = bar

    local lbl = Instance.new("TextLabel")
    lbl.Text               = message
    lbl.Font               = Enum.Font.Gotham
    lbl.TextSize           = 12
    lbl.TextColor3         = Color3.fromRGB(230, 230, 230)
    lbl.BackgroundTransparency = 1
    lbl.Size               = UDim2.new(1, -14, 1, 0)
    lbl.Position           = UDim2.new(0, 10, 0, 0)
    lbl.TextXAlignment     = Enum.TextXAlignment.Left
    lbl.TextWrapped        = true
    lbl.ZIndex             = 102
    lbl.Parent             = card

    -- slide in
    card.Position = UDim2.new(1, 10, 0, 0)
    TweenService:Create(card, TweenInfo.new(0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
        Position = UDim2.new(0, 0, 0, 0)
    }):Play()

    -- auto dismiss after 3.5s
    task.delay(3.5, function()
        TweenService:Create(card, TweenInfo.new(0.3, Enum.EasingStyle.Quart), {
            BackgroundTransparency = 1,
            Position = UDim2.new(1, 10, 0, 0)
        }):Play()
        task.wait(0.35)
        card:Destroy()
    end)
end

-- ── Widget Builders ───────────────────────────────────────────────────────────

local function makeSection(parent, text, order)
    local c = Instance.new("Frame")
    c.Size                   = UDim2.new(1, 0, 0, 0)
    c.AutomaticSize          = Enum.AutomaticSize.Y
    c.BackgroundColor3       = Color3.fromRGB(255, 255, 255)
    c.BackgroundTransparency = 0.92
    c.BorderSizePixel        = 0
    c.LayoutOrder            = order or 1
    c.ZIndex                 = 5
    c.Parent                 = parent

    local cc = Instance.new("UICorner"); cc.CornerRadius = UDim.new(0,8); cc.Parent = c
    local cl = Instance.new("UIListLayout"); cl.Padding = UDim.new(0,3); cl.SortOrder = Enum.SortOrder.LayoutOrder; cl.Parent = c
    local cp = Instance.new("UIPadding"); cp.PaddingTop = UDim.new(0,4); cp.PaddingBottom = UDim.new(0,6); cp.PaddingLeft = UDim.new(0,6); cp.PaddingRight = UDim.new(0,6); cp.Parent = c

    local hdr = Instance.new("Frame")
    hdr.Size                   = UDim2.new(1, 0, 0, 22)
    hdr.BackgroundTransparency = 1
    hdr.LayoutOrder            = 0
    hdr.ZIndex                 = 6
    hdr.Parent                 = c

    local hl = Instance.new("TextLabel"); hl.Text = text:upper(); hl.Font = Enum.Font.GothamBold; hl.TextSize = 10; hl.TextColor3 = Color3.fromRGB(255,255,255); hl.BackgroundTransparency = 1; hl.Size = UDim2.new(1,0,1,0); hl.TextXAlignment = Enum.TextXAlignment.Left; hl.ZIndex = 7; hl.Parent = hdr

    local hline = Instance.new("Frame"); hline.Size = UDim2.new(1,0,0,1); hline.Position = UDim2.new(0,0,1,-1); hline.BackgroundColor3 = Color3.fromRGB(255,255,255); hline.BackgroundTransparency = 0.8; hline.BorderSizePixel = 0; hline.ZIndex = 7; hline.Parent = hdr

    return c
end

local function makeToggle(parent, label, default, cb, order)
    default = (default == true)
    local row = Instance.new("Frame"); row.Size = UDim2.new(1,0,0,32); row.BackgroundTransparency = 1; row.LayoutOrder = order or 1; row.ZIndex = 6; row.Parent = parent

    local lbl = Instance.new("TextLabel"); lbl.Text = label; lbl.Font = Enum.Font.Gotham; lbl.TextSize = 12; lbl.TextColor3 = Color3.fromRGB(225,225,225); lbl.BackgroundTransparency = 1; lbl.Size = UDim2.new(1,-50,1,0); lbl.Position = UDim2.new(0,6,0,0); lbl.TextXAlignment = Enum.TextXAlignment.Left; lbl.ZIndex = 7; lbl.Parent = row

    local track = Instance.new("Frame"); track.Size = UDim2.new(0,36,0,18); track.Position = UDim2.new(1,-40,0.5,-9); track.BackgroundColor3 = default and Color3.fromRGB(255,255,255) or Color3.fromRGB(45,45,50); track.BorderSizePixel = 0; track.ZIndex = 7; track.Parent = row
    local tc = Instance.new("UICorner"); tc.CornerRadius = UDim.new(1,0); tc.Parent = track

    local knob = Instance.new("Frame"); knob.Size = UDim2.new(0,14,0,14); knob.Position = default and UDim2.new(1,-16,0.5,-7) or UDim2.new(0,2,0.5,-7); knob.BackgroundColor3 = default and Color3.fromRGB(0,0,0) or Color3.fromRGB(130,130,130); knob.BorderSizePixel = 0; knob.ZIndex = 8; knob.Parent = track
    local kc = Instance.new("UICorner"); kc.CornerRadius = UDim.new(1,0); kc.Parent = knob

    local state = default
    local ti = TweenInfo.new(0.13, Enum.EasingStyle.Quad)

    local hit = Instance.new("TextButton"); hit.Size = UDim2.new(1,0,1,0); hit.BackgroundTransparency = 1; hit.Text = ""; hit.ZIndex = 9; hit.Parent = row
    hit.MouseButton1Click:Connect(function()
        state = not state
        TweenService:Create(track, ti, {BackgroundColor3 = state and Color3.fromRGB(255,255,255) or Color3.fromRGB(45,45,50)}):Play()
        TweenService:Create(knob, ti, {Position = state and UDim2.new(1,-16,0.5,-7) or UDim2.new(0,2,0.5,-7), BackgroundColor3 = state and Color3.fromRGB(0,0,0) or Color3.fromRGB(130,130,130)}):Play()
        if cb then cb(state) end
    end)
    return function() return state end
end

local function makeSlider(parent, label, mn, mx, def, cb, order)
    local row = Instance.new("Frame"); row.Size = UDim2.new(1,0,0,46); row.BackgroundTransparency = 1; row.LayoutOrder = order or 1; row.ZIndex = 6; row.Parent = parent

    local lbl = Instance.new("TextLabel"); lbl.Font = Enum.Font.Gotham; lbl.TextSize = 12; lbl.TextColor3 = Color3.fromRGB(225,225,225); lbl.BackgroundTransparency = 1; lbl.Size = UDim2.new(1,-10,0,20); lbl.Position = UDim2.new(0,6,0,4); lbl.TextXAlignment = Enum.TextXAlignment.Left; lbl.ZIndex = 7; lbl.Parent = row

    local tbg = Instance.new("Frame"); tbg.Size = UDim2.new(1,-12,0,4); tbg.Position = UDim2.new(0,6,1,-12); tbg.BackgroundColor3 = Color3.fromRGB(45,45,50); tbg.BorderSizePixel = 0; tbg.ZIndex = 7; tbg.Parent = row
    local tbc = Instance.new("UICorner"); tbc.CornerRadius = UDim.new(1,0); tbc.Parent = tbg

    local fill = Instance.new("Frame"); fill.Size = UDim2.new((def-mn)/(mx-mn),0,1,0); fill.BackgroundColor3 = Color3.fromRGB(255,255,255); fill.BorderSizePixel = 0; fill.ZIndex = 8; fill.Parent = tbg
    local fc = Instance.new("UICorner"); fc.CornerRadius = UDim.new(1,0); fc.Parent = fill

    local value = def; lbl.Text = label .. ":  " .. value
    local dragging = false
    local hit = Instance.new("TextButton"); hit.Size = UDim2.new(1,0,1,0); hit.BackgroundTransparency = 1; hit.Text = ""; hit.ZIndex = 9; hit.Parent = row

    local function upd(input)
        local rel = math.clamp((input.Position.X - tbg.AbsolutePosition.X) / tbg.AbsoluteSize.X, 0, 1)
        value = math.floor(mn + rel*(mx-mn)); fill.Size = UDim2.new(rel,0,1,0); lbl.Text = label .. ":  " .. value
        if cb then cb(value) end
    end
    hit.MouseButton1Down:Connect(function() dragging = true end)
    UserInput.InputChanged:Connect(function(i) if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then upd(i) end end)
    UserInput.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end end)
    return function() return value end
end

local function makeLabel(parent, text, order)
    local l = Instance.new("TextLabel"); l.Text = text; l.Font = Enum.Font.Gotham; l.TextSize = 11; l.TextColor3 = Color3.fromRGB(170,170,180); l.BackgroundTransparency = 1; l.Size = UDim2.new(1,0,0,16); l.TextXAlignment = Enum.TextXAlignment.Left; l.LayoutOrder = order or 99; l.ZIndex = 7; l.Parent = parent
    return l
end

-- Copy-to-clipboard button next to a label
local function makeCopyRow(parent, labelText, getValue, order)
    local row = Instance.new("Frame"); row.Size = UDim2.new(1,0,0,26); row.BackgroundTransparency = 1; row.LayoutOrder = order or 1; row.ZIndex = 6; row.Parent = parent

    local lbl = Instance.new("TextLabel"); lbl.Text = labelText; lbl.Font = Enum.Font.Gotham; lbl.TextSize = 11; lbl.TextColor3 = Color3.fromRGB(180,180,190); lbl.BackgroundTransparency = 1; lbl.Size = UDim2.new(1,-54,1,0); lbl.Position = UDim2.new(0,4,0,0); lbl.TextXAlignment = Enum.TextXAlignment.Left; lbl.ZIndex = 7; lbl.Parent = row

    local copyBtn = Instance.new("TextButton"); copyBtn.Size = UDim2.new(0,46,0,20); copyBtn.Position = UDim2.new(1,-48,0.5,-10); copyBtn.BackgroundColor3 = Color3.fromRGB(255,255,255); copyBtn.BackgroundTransparency = 0.8; copyBtn.BorderSizePixel = 0; copyBtn.Font = Enum.Font.GothamBold; copyBtn.TextSize = 10; copyBtn.TextColor3 = Color3.fromRGB(255,255,255); copyBtn.Text = "COPY"; copyBtn.AutoButtonColor = false; copyBtn.ZIndex = 8; copyBtn.Parent = row
    local cc = Instance.new("UICorner"); cc.CornerRadius = UDim.new(0,5); cc.Parent = copyBtn

    copyBtn.MouseButton1Click:Connect(function()
        local val = getValue()
        if setclipboard then
            setclipboard(tostring(val))
            copyBtn.Text = "✓"
            lbl.TextColor3 = Color3.fromRGB(60, 200, 80)
            task.delay(1.5, function()
                copyBtn.Text = "COPY"
                lbl.TextColor3 = Color3.fromRGB(180,180,190)
            end)
        end
    end)

    return lbl  -- return so caller can update text
end

-- ── Tab Builder ───────────────────────────────────────────────────────────────

local tabPages   = {}
local tabButtons = {}

local function makeTab(name, iconId)
    local btn = Instance.new("Frame"); btn.Size = UDim2.new(1,0,0,32); btn.BackgroundColor3 = Color3.fromRGB(255,255,255); btn.BackgroundTransparency = 0.92; btn.BorderSizePixel = 0; btn.ZIndex = 6; btn.Parent = sidebar

    local bc = Instance.new("UICorner"); bc.CornerRadius = UDim.new(0,7); bc.Parent = btn

    local ico = Instance.new("ImageLabel"); ico.Image = iconId or "rbxassetid://0"; ico.Size = UDim2.new(0,14,0,14); ico.Position = UDim2.new(0,7,0.5,-7); ico.BackgroundTransparency = 1; ico.ScaleType = Enum.ScaleType.Fit; ico.ZIndex = 7; ico.Parent = btn

    local bLbl = Instance.new("TextLabel"); bLbl.Text = name; bLbl.Font = Enum.Font.GothamSemibold; bLbl.TextSize = 11; bLbl.TextColor3 = Color3.fromRGB(150,150,150); bLbl.BackgroundTransparency = 1; bLbl.Size = UDim2.new(1,-26,1,0); bLbl.Position = UDim2.new(0,24,0,0); bLbl.TextXAlignment = Enum.TextXAlignment.Left; bLbl.ZIndex = 7; bLbl.Parent = btn

    local click = Instance.new("TextButton"); click.Size = UDim2.new(1,0,1,0); click.BackgroundTransparency = 1; click.Text = ""; click.ZIndex = 8; click.Parent = btn

    local page = Instance.new("ScrollingFrame"); page.Size = UDim2.new(1,0,1,0); page.BackgroundTransparency = 1; page.BorderSizePixel = 0; page.ScrollBarThickness = 2; page.ScrollBarImageColor3 = Color3.fromRGB(255,255,255); page.CanvasSize = UDim2.new(0,0,0,0); page.AutomaticCanvasSize = Enum.AutomaticSize.Y; page.ZIndex = 5; page.Visible = false; page.Parent = contentArea

    local pl = Instance.new("UIListLayout"); pl.Padding = UDim.new(0,6); pl.SortOrder = Enum.SortOrder.LayoutOrder; pl.Parent = page
    local pp = Instance.new("UIPadding"); pp.PaddingTop = UDim.new(0,8); pp.PaddingBottom = UDim.new(0,8); pp.PaddingLeft = UDim.new(0,5); pp.PaddingRight = UDim.new(0,8); pp.Parent = page

    tabPages[name]   = {page=page, btn=btn, lbl=bLbl}
    tabButtons[name] = {btn=btn, lbl=bLbl}

    click.MouseButton1Click:Connect(function()
        for _, t in pairs(tabPages) do t.page.Visible = false; t.btn.BackgroundTransparency = 0.92; t.lbl.TextColor3 = Color3.fromRGB(150,150,150) end
        page.Visible = true; btn.BackgroundTransparency = 0.65; bLbl.TextColor3 = Color3.fromRGB(255,255,255)
    end)

    return page, click
end

-- ── Build Tabs ────────────────────────────────────────────────────────────────

local mainPage,     _ = makeTab("Main",      cfg.Icon_Main         or "rbxassetid://0")
local aimbotPage,   _ = makeTab("Aimbot",    cfg.Icon_Aimbot       or "rbxassetid://0")
local visPage,      _ = makeTab("Visuals",   cfg.Icon_Visuals      or "rbxassetid://0")
local lpPage,       _ = makeTab("LocalPlayer", cfg.Icon_LocalPlayer or "rbxassetid://0")
local murdPage,     _ = makeTab("Murderer",  cfg.Icon_Murderer     or "rbxassetid://0")
local sheriffPage,  _ = makeTab("Sheriff",   cfg.Icon_Sheriff      or "rbxassetid://0")
local farmPage,     _ = makeTab("Farm",      cfg.Icon_Farm         or "rbxassetid://0")

-- open Main tab
tabPages["Main"].page.Visible = true
tabPages["Main"].btn.BackgroundTransparency = 0.65
tabPages["Main"].lbl.TextColor3 = Color3.fromRGB(255,255,255)

-- ── Main Tab ──────────────────────────────────────────────────────────────────

local infoS = makeSection(mainPage, "Welcome", 1)

local welcomeL = Instance.new("TextLabel"); welcomeL.Text = "Welcome,  " .. lp.DisplayName; welcomeL.Font = Enum.Font.GothamBold; welcomeL.TextSize = 16; welcomeL.TextColor3 = Color3.fromRGB(255,255,255); welcomeL.BackgroundTransparency = 1; welcomeL.Size = UDim2.new(1,0,0,24); welcomeL.TextXAlignment = Enum.TextXAlignment.Left; welcomeL.LayoutOrder = 1; welcomeL.ZIndex = 7; welcomeL.Parent = infoS

local usernameL = Instance.new("TextLabel"); usernameL.Text = "@" .. lp.Name; usernameL.Font = Enum.Font.Gotham; usernameL.TextSize = 11; usernameL.TextColor3 = Color3.fromRGB(140,140,155); usernameL.BackgroundTransparency = 1; usernameL.Size = UDim2.new(1,0,0,16); usernameL.TextXAlignment = Enum.TextXAlignment.Left; usernameL.LayoutOrder = 2; usernameL.ZIndex = 7; usernameL.Parent = infoS

local creditL = Instance.new("TextLabel"); creditL.Text = "Created by Crypt0"; creditL.Font = Enum.Font.GothamBold; creditL.TextSize = 10; creditL.TextColor3 = Color3.fromRGB(100,100,120); creditL.BackgroundTransparency = 1; creditL.Size = UDim2.new(1,0,0,14); creditL.TextXAlignment = Enum.TextXAlignment.Left; creditL.LayoutOrder = 3; creditL.ZIndex = 7; creditL.Parent = infoS

local serverS = makeSection(mainPage, "Server", 2)

local jobLbl    = makeCopyRow(serverS, "Job ID:    loading...",   function() return game.JobId   end, 1)
local placeLbl  = makeCopyRow(serverS, "Place ID:  loading...",   function() return game.PlaceId end, 2)
local countLbl  = makeLabel(serverS, "Players: loading...", 3)
local pingLbl   = makeCopyRow(serverS, "Ping: loading...", function()
    return math.floor(Stats.Network.ServerStatsItem["Data Ping"]:GetValue())
end, 4)

task.spawn(function()
    while task.wait(1) do
        pcall(function()
            jobLbl.Text   = "Job ID:    " .. tostring(game.JobId):sub(1,22) .. "…"
            placeLbl.Text = "Place ID:  " .. tostring(game.PlaceId)
            countLbl.Text = "Players:   " .. #Players:GetPlayers() .. " / " .. Players.MaxPlayers
            pingLbl.Text  = "Ping:      " .. math.floor(Stats.Network.ServerStatsItem["Data Ping"]:GetValue()) .. " ms"
        end)
    end
end)

-- ── Aimbot Tab ────────────────────────────────────────────────────────────────

local abS = makeSection(aimbotPage, "Aimbot", 1)
makeToggle(abS, "Enable Aimbot",       false, function(v) _G.AimbotEnabled    = v end, 1)
makeToggle(abS, "Require Right Click", false, function(v) _G.AimbotRightClick = v end, 2)

local tgtS = makeSection(aimbotPage, "Target", 2)
makeToggle(tgtS, "Aim at Murderer", false, function(v) _G.AimMurderer = v end, 1)
makeToggle(tgtS, "Aim at Sheriff",  false, function(v) _G.AimSheriff  = v end, 2)
makeLabel(tgtS, "Both off = aim everyone", 3)

local abSet = makeSection(aimbotPage, "Settings", 3)
makeSlider(abSet, "Smoothing",   1, 15,  2,   function(v) _G.AimbotSmoothing = v end, 1)
makeSlider(abSet, "FOV Radius",  20,600, 250, function(v) _G.AimbotFOV       = v end, 2)
makeToggle(abSet, "Show FOV",          false, function(v) _G.ShowFOV       = v end, 3)
makeToggle(abSet, "Target Tracer",     false, function(v) _G.TargetTracer  = v end, 4)

local tbS = makeSection(aimbotPage, "Triggerbot", 4)
makeToggle(tbS, "Enable Triggerbot",   false, function(v) _G.TriggerEnabled = v end, 1)
makeToggle(tbS, "Trigger: Murderer",   false, function(v) _G.TriggerMurd    = v end, 2)
makeToggle(tbS, "Trigger: Sheriff",    false, function(v) _G.TriggerSheriff = v end, 3)
makeLabel(tbS,  "Both off = trigger all", 4)
makeSlider(tbS, "Trigger FOV",  5, 100, 30, function(v) _G.TriggerFOV = v end, 5)

_G.AimbotEnabled    = false
_G.AimbotRightClick = false
_G.AimMurderer      = false
_G.AimSheriff       = false
_G.AimbotSmoothing  = 2
_G.AimbotFOV        = 250
_G.ShowFOV          = false
_G.TargetTracer     = false
_G.TriggerEnabled   = false
_G.TriggerMurd      = false
_G.TriggerSheriff   = false
_G.TriggerFOV       = 30

-- ── Visuals Tab (includes ESP) ─────────────────────────────────────────────────

local espS = makeSection(visPage, "ESP", 1)
makeToggle(espS, "Box ESP",      false, function(v) _G.BoxESP      = v end, 1)
makeToggle(espS, "Chams ESP",    false, function(v) _G.ChamsESP    = v end, 2)
makeToggle(espS, "Name ESP",     false, function(v) _G.NameESP     = v end, 3)
makeToggle(espS, "Distance ESP", false, function(v) _G.DistanceESP = v end, 4)
makeToggle(espS, "Tracers",      false, function(v) _G.Tracers     = v end, 5)

local xhS = makeSection(visPage, "Crosshair", 2)
makeToggle(xhS, "Custom Crosshair", false, function(v) _G.CrosshairEnabled = v end, 1)
makeToggle(xhS, "RGB Spinning",     false, function(v) _G.CrosshairRGB     = v end, 2)
makeSlider(xhS, "Size",      4,  30, 14, function(v) _G.CrosshairSize  = v end, 3)
makeSlider(xhS, "Gap",       0,  12, 4,  function(v) _G.CrosshairGap   = v end, 4)
makeSlider(xhS, "Thickness", 1,  4,  1,  function(v) _G.CrosshairThick = v end, 5)
makeSlider(xhS, "Spin Speed",1,  20, 5,  function(v) _G.CrosshairSpin  = v end, 6)

_G.BoxESP           = false
_G.ChamsESP         = false
_G.NameESP          = false
_G.DistanceESP      = false
_G.Tracers          = false
_G.CrosshairEnabled = false
_G.CrosshairRGB     = false
_G.CrosshairSize    = 14
_G.CrosshairGap     = 4
_G.CrosshairThick   = 1
_G.CrosshairSpin    = 5

-- ── Local Player Tab ──────────────────────────────────────────────────────────

local mvS = makeSection(lpPage, "Movement", 1)
makeToggle(mvS, "Noclip",        false, function(v) _G.NoclipEnabled  = v end, 1)
makeToggle(mvS, "Speedhack",     false, function(v) _G.SpeedEnabled   = v end, 2)
makeToggle(mvS, "Infinite Jump", false, function(v) _G.InfJumpEnabled = v end, 3)
makeSlider(mvS, "Speed Mult",  1, 3, 1, function(v) _G.SpeedMultiplier = v end, 4)

local invisS = makeSection(lpPage, "Visibility", 2)
makeToggle(invisS, "Invisibility (Server)",  false, function(v) _G.InvisEnabled  = v end, 1)
makeLabel(invisS, "Others see you invisible", 2)
makeLabel(invisS, "You see outline of self",  3)

local gunS = makeSection(lpPage, "Auto Gun", 3)
makeToggle(gunS, "Auto Collect Gun",  false, function(v) _G.AutoGun = v end, 1)
makeLabel(gunS,  "Uses touch-fire — instant, no lag", 2)

local hbS = makeSection(lpPage, "Hitbox", 4)
makeToggle(hbS, "Hitbox Expander", false, function(v) _G.HitboxEnabled = v end, 1)
makeToggle(hbS, "Silent Aim Mode", false, function(v) _G.SilentAim     = v end, 2)
makeLabel(hbS,  "Silent Aim expands Murd/Sheriff huge", 3)
makeSlider(hbS, "Hitbox Size",  2, 15, 6, function(v) _G.HitboxSize    = v end, 4)
makeSlider(hbS, "Silent Size", 10, 80, 40, function(v) _G.SilentAimSize = v end, 5)

_G.NoclipEnabled   = false
_G.SpeedEnabled    = false
_G.InfJumpEnabled  = false
_G.SpeedMultiplier = 1
_G.InvisEnabled    = false
_G.AutoGun         = false
_G.HitboxEnabled   = false
_G.SilentAim       = false
_G.HitboxSize      = 6
_G.SilentAimSize   = 40

-- ── Murderer Tab ──────────────────────────────────────────────────────────────

local mkS = makeSection(murdPage, "Knife Assist", 1)
makeToggle(mkS, "Knife Aura",      false, function(v) _G.KnifeAura     = v end, 1)
makeSlider(mkS, "Aura Range", 5, 50, 15, function(v) _G.KnifeAuraRange = v end, 2)
makeToggle(mkS, "Auto Stab (nearest)", false, function(v) _G.AutoStab  = v end, 3)

local mkV = makeSection(murdPage, "Visibility", 2)
makeToggle(mkV, "Show Innocents Only", false, function(v) _G.ShowInnocentsOnly = v end, 1)

_G.KnifeAura      = false
_G.KnifeAuraRange = 15
_G.AutoStab       = false
_G.ShowInnocentsOnly = false

-- ── Sheriff Tab ───────────────────────────────────────────────────────────────

local shS = makeSection(sheriffPage, "Sheriff Tools", 1)
makeToggle(shS, "Auto Shoot Murderer",  false, function(v) _G.AutoShoot      = v end, 1)
makeToggle(shS, "Show Murderer Arrow",  false, function(v) _G.MurdererArrow  = v end, 2)
makeSlider(shS, "Auto Shoot Range", 10, 200, 60, function(v) _G.AutoShootRange = v end, 3)

_G.AutoShoot      = false
_G.MurdererArrow  = false
_G.AutoShootRange = 60

-- ── Farm Tab ─────────────────────────────────────────────────────────────────

local farmS = makeSection(farmPage, "Coin Farm", 1)
makeToggle(farmS, "Auto Collect Coins", false, function(v) _G.CoinFarm = v end, 1)
makeLabel(farmS, "Walks to nearby coins", 2)

local afkS = makeSection(farmPage, "AFK", 2)
makeToggle(afkS, "Anti-AFK",           false, function(v) _G.AntiAFK = v end, 1)
makeLabel(afkS,  "Prevents disconnect", 2)

_G.CoinFarm = false
_G.AntiAFK  = false

-- ── Footer hint ───────────────────────────────────────────────────────────────

local hint = Instance.new("TextLabel"); hint.Text = "Right Shift — toggle"; hint.Font = Enum.Font.Gotham; hint.TextSize = 10; hint.TextColor3 = Color3.fromRGB(70,70,80); hint.BackgroundTransparency = 1; hint.Size = UDim2.new(1,0,0,14); hint.Position = UDim2.new(0,0,1,-16); hint.TextXAlignment = Enum.TextXAlignment.Center; hint.ZIndex = 6; hint.Parent = main
