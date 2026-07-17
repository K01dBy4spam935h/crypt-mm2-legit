-- Crypt-MM2-Legit | UI Framework
-- Provides _G.UI with all widget builders, window, notification system
-- Tab content scripts call these to build their UIs

local Players       = game:GetService("Players")
local TweenService  = game:GetService("TweenService")
local UserInput     = game:GetService("UserInputService")
local ContentProvider = game:GetService("ContentProvider")
local InsertService = game:GetService("InsertService")
local lp            = Players.LocalPlayer

local cfg        = _G.Config or {}
local TOGGLE_KEY = cfg.ToggleKey or Enum.KeyCode.RightControl
local WIN_SIZE   = cfg.WindowSize or UDim2.new(0, 560, 0, 440)
local ICON_SIZE  = cfg.IconSize   or UDim2.new(0, 54,  0, 54)
local START_POS  = cfg.StartPos   or UDim2.new(0.5,-280,0.5,-220)

_G.UI    = {}   -- widget API
_G.Pages = {}   -- [tabName] = scrolling page frame

-- ── Image loader — rbxthumb method (confirmed working) ───────────────────────

local function loadImg(label, rawId)
    if not rawId then return end
    local cleanId = tostring(rawId):match("%d+")
    if not cleanId or cleanId == "0" then return end
    label.Image = "rbxthumb://type=Asset&id=" .. cleanId .. "&w=420&h=420"
    label:GetPropertyChangedSignal("IsLoaded"):Connect(function()
        if label.IsLoaded then print("[Crypt] Image loaded: "..cleanId) end
    end)
    task.delay(3, function()
        if not label.IsLoaded then
            label.Image = "rbxassetid://" .. cleanId
        end
    end)
end

_G.UI.LoadImage = loadImg

-- ── Screen GUI ────────────────────────────────────────────────────────────────

local gui = Instance.new("ScreenGui")
gui.Name = "CryptMM2"; gui.ResetOnSpawn = false
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.IgnoreGuiInset = true; gui.DisplayOrder = 999
gui.Parent = lp:WaitForChild("PlayerGui")

-- ── Main window ───────────────────────────────────────────────────────────────

local main = Instance.new("Frame")
main.Name = "Main"; main.Size = WIN_SIZE; main.Position = START_POS
main.BackgroundColor3 = Color3.fromRGB(8, 8, 12)
main.BackgroundTransparency = 0; main.BorderSizePixel = 0
main.Active = true; main.Draggable = true; main.ClipsDescendants = true
main.Parent = gui

local mC = Instance.new("UICorner"); mC.CornerRadius = UDim.new(0,14); mC.Parent = main
local mS = Instance.new("UIStroke"); mS.Color = Color3.fromRGB(255,255,255); mS.Thickness = 1.5; mS.Transparency = 0.65; mS.Parent = main

-- Background image
local bgImg = Instance.new("ImageLabel")
bgImg.Image = ""; bgImg.Size = UDim2.new(1,0,1,0); bgImg.BackgroundTransparency = 1
bgImg.ImageTransparency = 0; bgImg.ScaleType = Enum.ScaleType.Stretch
bgImg.ZIndex = 1; bgImg.Parent = main
_G.UI.BgImg = bgImg

-- Load active background
local activeBG = cfg.Backgrounds and cfg.Backgrounds[cfg.ActiveBackground or 1]
if activeBG then loadImg(bgImg, activeBG.Id) end

local wash = Instance.new("Frame"); wash.Size = UDim2.new(1,0,1,0)
wash.BackgroundColor3 = Color3.fromRGB(0,0,0); wash.BackgroundTransparency = 0.5
wash.BorderSizePixel = 0; wash.ZIndex = 2; wash.Parent = main
local wC = Instance.new("UICorner"); wC.CornerRadius = UDim.new(0,14); wC.Parent = wash

-- ── Title bar ─────────────────────────────────────────────────────────────────

local tb = Instance.new("Frame"); tb.Size = UDim2.new(1,0,0,40)
tb.BackgroundColor3 = Color3.fromRGB(0,0,0); tb.BackgroundTransparency = 0.35
tb.BorderSizePixel = 0; tb.ZIndex = 5; tb.Parent = main
local tbC = Instance.new("UICorner"); tbC.CornerRadius = UDim.new(0,14); tbC.Parent = tb
local tbSq = Instance.new("Frame"); tbSq.Size = UDim2.new(1,0,0,14); tbSq.Position = UDim2.new(0,0,1,-14)
tbSq.BackgroundColor3 = Color3.fromRGB(0,0,0); tbSq.BackgroundTransparency = 0.35; tbSq.BorderSizePixel = 0; tbSq.ZIndex = 5; tbSq.Parent = tb

local titleLbl = Instance.new("TextLabel"); titleLbl.Text = "⚰  Crypt MM2"
titleLbl.Font = Enum.Font.GothamBold; titleLbl.TextSize = 14
titleLbl.TextColor3 = Color3.fromRGB(255,255,255); titleLbl.BackgroundTransparency = 1
titleLbl.Size = UDim2.new(1,-90,1,0); titleLbl.Position = UDim2.new(0,14,0,0)
titleLbl.TextXAlignment = Enum.TextXAlignment.Left; titleLbl.ZIndex = 6; titleLbl.Parent = tb

local accentLine = Instance.new("Frame"); accentLine.Size = UDim2.new(1,0,0,1)
accentLine.Position = UDim2.new(0,0,0,40); accentLine.BackgroundColor3 = Color3.fromRGB(255,255,255)
accentLine.BackgroundTransparency = 0.8; accentLine.BorderSizePixel = 0; accentLine.ZIndex = 4; accentLine.Parent = main

-- ── Circle buttons ────────────────────────────────────────────────────────────

local function circBtn(col, xOff)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(0,14,0,14); b.Position = UDim2.new(1,xOff,0.5,-7)
    b.BackgroundColor3 = col; b.BorderSizePixel = 0; b.Text = ""
    b.AutoButtonColor = false; b.ZIndex = 9; b.Parent = tb
    local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(1,0); c.Parent = b
    b.MouseEnter:Connect(function() TweenService:Create(b,TweenInfo.new(0.1),{BackgroundTransparency=0.35}):Play() end)
    b.MouseLeave:Connect(function() TweenService:Create(b,TweenInfo.new(0.1),{BackgroundTransparency=0}):Play() end)
    return b
end
local closeBtn = circBtn(Color3.fromRGB(220,55,55), -28)
local minBtn   = circBtn(Color3.fromRGB(230,130,30),-48)

-- ── Minimized icon ────────────────────────────────────────────────────────────

local iconFrame = Instance.new("Frame")
iconFrame.Size = ICON_SIZE; iconFrame.Position = START_POS
iconFrame.BackgroundColor3 = Color3.fromRGB(10,10,14); iconFrame.BackgroundTransparency = 0
iconFrame.BorderSizePixel = 0; iconFrame.Active = true; iconFrame.Visible = false
iconFrame.ZIndex = 20; iconFrame.Parent = gui
local iFC = Instance.new("UICorner"); iFC.CornerRadius = UDim.new(0,12); iFC.Parent = iconFrame
local iFS = Instance.new("UIStroke"); iFS.Color = Color3.fromRGB(255,255,255); iFS.Thickness = 1; iFS.Transparency = 0.65; iFS.Parent = iconFrame

local iconImg = Instance.new("ImageLabel"); iconImg.Image = ""
iconImg.Size = UDim2.new(1,-8,1,-8); iconImg.Position = UDim2.new(0,4,0,4)
iconImg.BackgroundTransparency = 1; iconImg.ScaleType = Enum.ScaleType.Fit
iconImg.ZIndex = 21; iconImg.Parent = iconFrame
_G.UI.IconImg = iconImg

local activeIcon = cfg.MinimizeIcons and cfg.MinimizeIcons[cfg.ActiveMinimizeIcon or 1]
if activeIcon then loadImg(iconImg, activeIcon.Id) end

-- Manual drag (centered on cursor)
local iconDrag = {active=false, offX=0, offY=0, moved=false}
iconFrame.InputBegan:Connect(function(input)
    if input.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
    iconDrag.active = true; iconDrag.moved = false
    iconDrag.offX = iconFrame.AbsoluteSize.X/2; iconDrag.offY = iconFrame.AbsoluteSize.Y/2
end)
iconFrame.InputEnded:Connect(function(input)
    if input.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
    if iconDrag.active and not iconDrag.moved then
        iconFrame.Visible = false; main.Position = iconFrame.Position
        main.Visible = true; _G._CryptMin = false
    end
    iconDrag.active = false
end)
UserInput.InputChanged:Connect(function(input)
    if not iconDrag.active or input.UserInputType ~= Enum.UserInputType.MouseMovement then return end
    iconDrag.moved = true
    local mp = UserInput:GetMouseLocation()
    iconFrame.Position = UDim2.fromOffset(mp.X - iconDrag.offX, mp.Y - iconDrag.offY)
end)

-- ── Minimize / Close ──────────────────────────────────────────────────────────

_G._CryptMin = false
_G._CryptGUI = gui

local function minimize()
    _G._CryptMin = true; iconFrame.Position = main.Position
    main.Visible = false; iconFrame.Visible = true
end
local function restore()
    _G._CryptMin = false; main.Position = iconFrame.Position
    iconFrame.Visible = false; main.Visible = true
end

minBtn.MouseButton1Click:Connect(minimize)
closeBtn.MouseButton1Click:Connect(function() gui:Destroy(); _G.__CRYPT_RUNNING = false end)

_G.ToggleKeyCode = TOGGLE_KEY
_G._BindingKey   = false

UserInput.InputBegan:Connect(function(input, gp)
    if gp or _G._BindingKey then return end
    if input.UserInputType ~= Enum.UserInputType.Keyboard then return end
    if input.KeyCode == (_G.ToggleKeyCode or TOGGLE_KEY) then
        if _G._CryptMin then restore() else minimize() end
    end
end)

-- ── Sidebar ───────────────────────────────────────────────────────────────────

local sidebar = Instance.new("Frame"); sidebar.Size = UDim2.new(0,118,1,-42)
sidebar.Position = UDim2.new(0,0,0,41); sidebar.BackgroundColor3 = Color3.fromRGB(0,0,0)
sidebar.BackgroundTransparency = 0.5; sidebar.BorderSizePixel = 0; sidebar.ZIndex = 4; sidebar.Parent = main
local sl = Instance.new("UIListLayout"); sl.Padding = UDim.new(0,4)
sl.HorizontalAlignment = Enum.HorizontalAlignment.Center; sl.Parent = sidebar
local sp = Instance.new("UIPadding"); sp.PaddingTop = UDim.new(0,8)
sp.PaddingLeft = UDim.new(0,5); sp.PaddingRight = UDim.new(0,5); sp.Parent = sidebar

local sdiv = Instance.new("Frame"); sdiv.Size = UDim2.new(0,1,1,-42); sdiv.Position = UDim2.new(0,118,0,41)
sdiv.BackgroundColor3 = Color3.fromRGB(255,255,255); sdiv.BackgroundTransparency = 0.82
sdiv.BorderSizePixel = 0; sdiv.ZIndex = 4; sdiv.Parent = main

local contentArea = Instance.new("Frame"); contentArea.Size = UDim2.new(1,-126,1,-50)
contentArea.Position = UDim2.new(0,122,0,46); contentArea.BackgroundTransparency = 1
contentArea.ClipsDescendants = true; contentArea.ZIndex = 4; contentArea.Parent = main

-- ── Notification system — top right ──────────────────────────────────────────

local notifContainer = Instance.new("Frame")
notifContainer.Size = UDim2.new(0,320,1,0); notifContainer.Position = UDim2.new(1,-330,0,0)
notifContainer.BackgroundTransparency = 1; notifContainer.ZIndex = 200; notifContainer.Parent = gui

local nl = Instance.new("UIListLayout"); nl.VerticalAlignment = Enum.VerticalAlignment.Top
nl.Padding = UDim.new(0,8); nl.Parent = notifContainer
local np = Instance.new("UIPadding"); np.PaddingTop = UDim.new(0,14); np.PaddingRight = UDim.new(0,10); np.Parent = notifContainer

local notifN = 0
local barCols = {
    success=Color3.fromRGB(80,200,100), error=Color3.fromRGB(220,70,70),
    info=Color3.fromRGB(130,180,255),   warn=Color3.fromRGB(240,170,50),
}

_G.Notify = function(msg, ntype)
    ntype = ntype or "info"
    local col = barCols[ntype] or barCols.info
    notifN = notifN + 1

    local card = Instance.new("Frame"); card.Size = UDim2.new(1,0,0,58)
    card.BackgroundColor3 = Color3.fromRGB(20,20,24); card.BackgroundTransparency = 0
    card.BorderSizePixel = 0; card.LayoutOrder = notifN; card.ZIndex = 201
    card.ClipsDescendants = true; card.Parent = notifContainer
    local cC = Instance.new("UICorner"); cC.CornerRadius = UDim.new(0,10); cC.Parent = card
    local cS = Instance.new("UIStroke"); cS.Color = Color3.fromRGB(55,55,60); cS.Thickness = 1; cS.Parent = card

    local bar = Instance.new("Frame"); bar.Size = UDim2.new(0,4,1,0)
    bar.BackgroundColor3 = col; bar.BorderSizePixel = 0; bar.ZIndex = 202; bar.Parent = card
    local bC = Instance.new("UICorner"); bC.CornerRadius = UDim.new(0,4); bC.Parent = bar

    local typeL = Instance.new("TextLabel"); typeL.Text = ntype:upper()
    typeL.Font = Enum.Font.GothamBold; typeL.TextSize = 10; typeL.TextColor3 = col
    typeL.BackgroundTransparency = 1; typeL.Size = UDim2.new(1,-14,0,14)
    typeL.Position = UDim2.new(0,10,0,7); typeL.TextXAlignment = Enum.TextXAlignment.Left
    typeL.ZIndex = 202; typeL.Parent = card

    local msgL = Instance.new("TextLabel"); msgL.Text = msg
    msgL.Font = Enum.Font.GothamSemibold; msgL.TextSize = 13
    msgL.TextColor3 = Color3.fromRGB(235,235,235); msgL.BackgroundTransparency = 1
    msgL.Size = UDim2.new(1,-14,0,22); msgL.Position = UDim2.new(0,10,0,23)
    msgL.TextXAlignment = Enum.TextXAlignment.Left; msgL.TextWrapped = true
    msgL.ZIndex = 202; msgL.Parent = card

    -- Cooldown bar
    local cBg = Instance.new("Frame"); cBg.Size = UDim2.new(1,-8,0,2)
    cBg.Position = UDim2.new(0,4,1,-3); cBg.BackgroundColor3 = Color3.fromRGB(45,45,50)
    cBg.BorderSizePixel = 0; cBg.ZIndex = 202; cBg.Parent = card
    local cBC = Instance.new("UICorner"); cBC.CornerRadius = UDim.new(1,0); cBC.Parent = cBg
    local cFill = Instance.new("Frame"); cFill.Size = UDim2.new(1,0,1,0)
    cFill.BackgroundColor3 = col; cFill.BorderSizePixel = 0; cFill.ZIndex = 203; cFill.Parent = cBg
    local cFC = Instance.new("UICorner"); cFC.CornerRadius = UDim.new(1,0); cFC.Parent = cFill

    card.Position = UDim2.new(1,10,0,0)
    TweenService:Create(card,TweenInfo.new(0.2,Enum.EasingStyle.Quart,Enum.EasingDirection.Out),{Position=UDim2.new(0,0,0,0)}):Play()
    TweenService:Create(cFill,TweenInfo.new(3.2,Enum.EasingStyle.Linear),{Size=UDim2.new(0,0,1,0)}):Play()
    task.delay(3.2,function()
        TweenService:Create(card,TweenInfo.new(0.2,Enum.EasingStyle.Quart),{Position=UDim2.new(1,10,0,0),BackgroundTransparency=1}):Play()
        task.wait(0.25); card:Destroy()
    end)
end

-- ── Widget API ────────────────────────────────────────────────────────────────
-- Tab scripts and section scripts call these

function _G.UI:MakeTab(name, iconId)
    local btn = Instance.new("Frame"); btn.Size = UDim2.new(1,0,0,32)
    btn.BackgroundColor3 = Color3.fromRGB(255,255,255); btn.BackgroundTransparency = 0.92
    btn.BorderSizePixel = 0; btn.ZIndex = 6; btn.Parent = sidebar
    local bC = Instance.new("UICorner"); bC.CornerRadius = UDim.new(0,7); bC.Parent = btn
    local bS = Instance.new("UIStroke"); bS.Color = Color3.fromRGB(60,60,66); bS.Thickness = 1; bS.Transparency = 0.5; bS.Parent = btn

    local ico = Instance.new("ImageLabel"); ico.Image = ""
    ico.Size = UDim2.new(0,14,0,14); ico.Position = UDim2.new(0,7,0.5,-7)
    ico.BackgroundTransparency = 1; ico.ScaleType = Enum.ScaleType.Fit; ico.ZIndex = 7; ico.Parent = btn
    if iconId and iconId ~= "rbxassetid://0" then loadImg(ico, iconId) end

    local bLbl = Instance.new("TextLabel"); bLbl.Text = name
    bLbl.Font = Enum.Font.GothamSemibold; bLbl.TextSize = 11
    bLbl.TextColor3 = Color3.fromRGB(140,140,140); bLbl.BackgroundTransparency = 1
    bLbl.Size = UDim2.new(1,-26,1,0); bLbl.Position = UDim2.new(0,24,0,0)
    bLbl.TextXAlignment = Enum.TextXAlignment.Left; bLbl.ZIndex = 7; bLbl.Parent = btn

    local click = Instance.new("TextButton"); click.Size = UDim2.new(1,0,1,0)
    click.BackgroundTransparency = 1; click.Text = ""; click.ZIndex = 8; click.Parent = btn

    local page = Instance.new("ScrollingFrame"); page.Size = UDim2.new(1,0,1,0)
    page.BackgroundTransparency = 1; page.BorderSizePixel = 0; page.ScrollBarThickness = 2
    page.ScrollBarImageColor3 = Color3.fromRGB(255,255,255); page.CanvasSize = UDim2.new(0,0,0,0)
    page.AutomaticCanvasSize = Enum.AutomaticSize.Y; page.ZIndex = 5; page.Visible = false; page.Parent = contentArea
    local pl = Instance.new("UIListLayout"); pl.Padding = UDim.new(0,6); pl.SortOrder = Enum.SortOrder.LayoutOrder; pl.Parent = page
    local pp = Instance.new("UIPadding"); pp.PaddingTop = UDim.new(0,8); pp.PaddingBottom = UDim.new(0,8)
    pp.PaddingLeft = UDim.new(0,5); pp.PaddingRight = UDim.new(0,8); pp.Parent = page

    _G.Pages[name] = {page=page, btn=btn, lbl=bLbl}

    click.MouseButton1Click:Connect(function()
        for _, t in pairs(_G.Pages) do
            t.page.Visible = false; t.btn.BackgroundTransparency = 0.92
            t.lbl.TextColor3 = Color3.fromRGB(140,140,140)
        end
        page.Visible = true; btn.BackgroundTransparency = 0.65
        bLbl.TextColor3 = Color3.fromRGB(255,255,255)
    end)

    return page
end

function _G.UI:MakeSection(parent, text, order)
    local c = Instance.new("Frame"); c.Size = UDim2.new(1,0,0,0)
    c.AutomaticSize = Enum.AutomaticSize.Y; c.BackgroundColor3 = Color3.fromRGB(255,255,255)
    c.BackgroundTransparency = 0.92; c.BorderSizePixel = 0; c.LayoutOrder = order or 1
    c.ZIndex = 5; c.Parent = parent
    local cC = Instance.new("UICorner"); cC.CornerRadius = UDim.new(0,8); cC.Parent = c
    local cl = Instance.new("UIListLayout"); cl.Padding = UDim.new(0,3); cl.SortOrder = Enum.SortOrder.LayoutOrder; cl.Parent = c
    local cp = Instance.new("UIPadding"); cp.PaddingTop = UDim.new(0,4); cp.PaddingBottom = UDim.new(0,6)
    cp.PaddingLeft = UDim.new(0,6); cp.PaddingRight = UDim.new(0,6); cp.Parent = c

    local hdr = Instance.new("Frame"); hdr.Size = UDim2.new(1,0,0,22)
    hdr.BackgroundTransparency = 1; hdr.LayoutOrder = 0; hdr.ZIndex = 6; hdr.Parent = c
    local hl = Instance.new("TextLabel"); hl.Text = text:upper()
    hl.Font = Enum.Font.GothamBold; hl.TextSize = 10; hl.TextColor3 = Color3.fromRGB(255,255,255)
    hl.BackgroundTransparency = 1; hl.Size = UDim2.new(1,0,1,0); hl.TextXAlignment = Enum.TextXAlignment.Left
    hl.ZIndex = 7; hl.Parent = hdr
    local hline = Instance.new("Frame"); hline.Size = UDim2.new(1,0,0,1); hline.Position = UDim2.new(0,0,1,-1)
    hline.BackgroundColor3 = Color3.fromRGB(255,255,255); hline.BackgroundTransparency = 0.8
    hline.BorderSizePixel = 0; hline.ZIndex = 7; hline.Parent = hdr
    return c
end

function _G.UI:Toggle(parent, label, default, cb, order)
    default = (default == true)
    local row = Instance.new("Frame"); row.Size = UDim2.new(1,0,0,32)
    row.BackgroundTransparency = 1; row.LayoutOrder = order or 1; row.ZIndex = 6; row.Parent = parent
    local lbl = Instance.new("TextLabel"); lbl.Text = label; lbl.Font = Enum.Font.Gotham; lbl.TextSize = 12
    lbl.TextColor3 = Color3.fromRGB(225,225,225); lbl.BackgroundTransparency = 1
    lbl.Size = UDim2.new(1,-50,1,0); lbl.Position = UDim2.new(0,6,0,0)
    lbl.TextXAlignment = Enum.TextXAlignment.Left; lbl.ZIndex = 7; lbl.Parent = row

    local track = Instance.new("Frame"); track.Size = UDim2.new(0,36,0,18)
    track.Position = UDim2.new(1,-40,0.5,-9)
    track.BackgroundColor3 = default and Color3.fromRGB(255,255,255) or Color3.fromRGB(45,45,50)
    track.BorderSizePixel = 0; track.ZIndex = 7; track.Parent = row
    local tC = Instance.new("UICorner"); tC.CornerRadius = UDim.new(1,0); tC.Parent = track

    local knob = Instance.new("Frame"); knob.Size = UDim2.new(0,14,0,14)
    knob.Position = default and UDim2.new(1,-16,0.5,-7) or UDim2.new(0,2,0.5,-7)
    knob.BackgroundColor3 = default and Color3.fromRGB(0,0,0) or Color3.fromRGB(130,130,130)
    knob.BorderSizePixel = 0; knob.ZIndex = 8; knob.Parent = track
    local kC = Instance.new("UICorner"); kC.CornerRadius = UDim.new(1,0); kC.Parent = knob

    local state = default
    local ti = TweenInfo.new(0.13, Enum.EasingStyle.Quad)
    local hit = Instance.new("TextButton"); hit.Size = UDim2.new(1,0,1,0)
    hit.BackgroundTransparency = 1; hit.Text = ""; hit.ZIndex = 9; hit.Parent = row

    hit.MouseButton1Click:Connect(function()
        state = not state
        TweenService:Create(track,ti,{BackgroundColor3=state and Color3.fromRGB(255,255,255) or Color3.fromRGB(45,45,50)}):Play()
        TweenService:Create(knob,ti,{Position=state and UDim2.new(1,-16,0.5,-7) or UDim2.new(0,2,0.5,-7),BackgroundColor3=state and Color3.fromRGB(0,0,0) or Color3.fromRGB(130,130,130)}):Play()
        if cb then cb(state) end
    end)
    return function() return state end
end

function _G.UI:Slider(parent, label, mn, mx, def, cb, order)
    local row = Instance.new("Frame"); row.Size = UDim2.new(1,0,0,46)
    row.BackgroundTransparency = 1; row.LayoutOrder = order or 1; row.ZIndex = 6; row.Parent = parent
    local lbl = Instance.new("TextLabel"); lbl.Font = Enum.Font.Gotham; lbl.TextSize = 12
    lbl.TextColor3 = Color3.fromRGB(225,225,225); lbl.BackgroundTransparency = 1
    lbl.Size = UDim2.new(1,-10,0,20); lbl.Position = UDim2.new(0,6,0,4)
    lbl.TextXAlignment = Enum.TextXAlignment.Left; lbl.ZIndex = 7; lbl.Parent = row

    local tbg = Instance.new("Frame"); tbg.Size = UDim2.new(1,-12,0,4); tbg.Position = UDim2.new(0,6,1,-12)
    tbg.BackgroundColor3 = Color3.fromRGB(45,45,50); tbg.BorderSizePixel = 0; tbg.ZIndex = 7; tbg.Parent = row
    local tC = Instance.new("UICorner"); tC.CornerRadius = UDim.new(1,0); tC.Parent = tbg
    local fill = Instance.new("Frame"); fill.Size = UDim2.new((def-mn)/(mx-mn),0,1,0)
    fill.BackgroundColor3 = Color3.fromRGB(255,255,255); fill.BorderSizePixel = 0; fill.ZIndex = 8; fill.Parent = tbg
    local fC = Instance.new("UICorner"); fC.CornerRadius = UDim.new(1,0); fC.Parent = fill

    local value = def; lbl.Text = label .. "  " .. value
    local dragging = false
    local hit = Instance.new("TextButton"); hit.Size = UDim2.new(1,0,1,0)
    hit.BackgroundTransparency = 1; hit.Text = ""; hit.ZIndex = 9; hit.Parent = row

    local function upd(input)
        local rel = math.clamp((input.Position.X-tbg.AbsolutePosition.X)/tbg.AbsoluteSize.X,0,1)
        value = math.floor(mn+rel*(mx-mn)); fill.Size = UDim2.new(rel,0,1,0); lbl.Text = label.."  "..value
        if cb then cb(value) end
    end
    hit.MouseButton1Down:Connect(function() dragging=true end)
    UserInput.InputChanged:Connect(function(i) if dragging and i.UserInputType==Enum.UserInputType.MouseMovement then upd(i) end end)
    UserInput.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then dragging=false end end)
    return function() return value end
end

function _G.UI:Label(parent, text, order)
    local l = Instance.new("TextLabel"); l.Text = text; l.Font = Enum.Font.Gotham; l.TextSize = 11
    l.TextColor3 = Color3.fromRGB(150,150,165); l.BackgroundTransparency = 1
    l.Size = UDim2.new(1,0,0,16); l.TextXAlignment = Enum.TextXAlignment.Left
    l.LayoutOrder = order or 99; l.ZIndex = 7; l.Parent = parent
    return l
end

function _G.UI:CopyRow(parent, labelText, getValue, order)
    local row = Instance.new("Frame"); row.Size = UDim2.new(1,0,0,26)
    row.BackgroundTransparency = 1; row.LayoutOrder = order or 1; row.ZIndex = 6; row.Parent = parent
    local lbl = Instance.new("TextLabel"); lbl.Text = labelText; lbl.Font = Enum.Font.Gotham; lbl.TextSize = 11
    lbl.TextColor3 = Color3.fromRGB(175,175,190); lbl.BackgroundTransparency = 1
    lbl.Size = UDim2.new(1,-54,1,0); lbl.Position = UDim2.new(0,4,0,0)
    lbl.TextXAlignment = Enum.TextXAlignment.Left; lbl.ZIndex = 7; lbl.Parent = row
    local cb = Instance.new("TextButton"); cb.Size = UDim2.new(0,46,0,20); cb.Position = UDim2.new(1,-48,0.5,-10)
    cb.BackgroundColor3 = Color3.fromRGB(255,255,255); cb.BackgroundTransparency = 0.82; cb.BorderSizePixel = 0
    cb.Font = Enum.Font.GothamBold; cb.TextSize = 10; cb.TextColor3 = Color3.fromRGB(255,255,255)
    cb.Text = "COPY"; cb.AutoButtonColor = false; cb.ZIndex = 8; cb.Parent = row
    local cC = Instance.new("UICorner"); cC.CornerRadius = UDim.new(0,5); cC.Parent = cb
    cb.MouseButton1Click:Connect(function()
        pcall(function() setclipboard(tostring(getValue())) end)
        cb.Text = "✓"; lbl.TextColor3 = Color3.fromRGB(60,200,80)
        task.delay(1.5, function() cb.Text = "COPY"; lbl.TextColor3 = Color3.fromRGB(175,175,190) end)
    end)
    return lbl
end

function _G.UI:Button(parent, label, order, action)
    local row = Instance.new("Frame"); row.Size = UDim2.new(1,0,0,34)
    row.BackgroundTransparency = 1; row.LayoutOrder = order; row.ZIndex = 6; row.Parent = parent
    local btn = Instance.new("TextButton"); btn.Size = UDim2.new(1,0,0,28)
    btn.BackgroundColor3 = Color3.fromRGB(255,255,255); btn.BackgroundTransparency = 0.88
    btn.BorderSizePixel = 0; btn.Font = Enum.Font.GothamBold; btn.TextSize = 12
    btn.TextColor3 = Color3.fromRGB(225,225,225); btn.Text = label; btn.ZIndex = 7; btn.Parent = row
    local bC = Instance.new("UICorner"); bC.CornerRadius = UDim.new(0,7); bC.Parent = btn
    btn.MouseButton1Click:Connect(action)
    btn.MouseEnter:Connect(function() TweenService:Create(btn,TweenInfo.new(0.1),{BackgroundTransparency=0.7}):Play() end)
    btn.MouseLeave:Connect(function() TweenService:Create(btn,TweenInfo.new(0.1),{BackgroundTransparency=0.88}):Play() end)
end

-- Open first tab automatically
task.defer(function()
    task.wait(0.1)
    for name, t in pairs(_G.Pages) do
        t.page.Visible = true; t.btn.BackgroundTransparency = 0.65
        t.lbl.TextColor3 = Color3.fromRGB(255,255,255)
        break
    end
end)

-- Footer
local hint = Instance.new("TextLabel"); hint.Text = "Right Control — toggle"
hint.Font = Enum.Font.Gotham; hint.TextSize = 10; hint.TextColor3 = Color3.fromRGB(70,70,80)
hint.BackgroundTransparency = 1; hint.Size = UDim2.new(1,0,0,14); hint.Position = UDim2.new(0,0,1,-16)
hint.TextXAlignment = Enum.TextXAlignment.Center; hint.ZIndex = 6; hint.Parent = main
