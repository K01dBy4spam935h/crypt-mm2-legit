-- Settings tab: Keybind section

local UserInput = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local page = _G.Pages["Settings"].page
local kbS  = _G.UI:MakeSection(page, "Keybind", 1)

local kbLabel = _G.UI:Label(kbS, "Toggle key:  " .. ((_G.ToggleKeyCode or Enum.KeyCode.RightControl).Name), 1)

local kbRow = Instance.new("Frame"); kbRow.Size=UDim2.new(1,0,0,32); kbRow.BackgroundTransparency=1; kbRow.LayoutOrder=2; kbRow.ZIndex=6; kbRow.Parent=kbS
local kbBtn = Instance.new("TextButton"); kbBtn.Size=UDim2.new(1,0,0,28); kbBtn.BackgroundColor3=Color3.fromRGB(255,255,255); kbBtn.BackgroundTransparency=0.85; kbBtn.BorderSizePixel=0; kbBtn.Font=Enum.Font.GothamBold; kbBtn.TextSize=12; kbBtn.TextColor3=Color3.fromRGB(255,255,255); kbBtn.Text="Click to rebind"; kbBtn.ZIndex=7; kbBtn.Parent=kbRow
local kbC = Instance.new("UICorner"); kbC.CornerRadius=UDim.new(0,6); kbC.Parent=kbBtn

kbBtn.MouseButton1Click:Connect(function()
    if _G._BindingKey then return end
    _G._BindingKey=true; kbBtn.Text="▶ Press any key…"; kbBtn.TextColor3=Color3.fromRGB(255,220,50)
end)

UserInput.InputBegan:Connect(function(input, gp)
    if not _G._BindingKey then return end
    if input.UserInputType~=Enum.UserInputType.Keyboard then return end
    _G._BindingKey=false; _G.ToggleKeyCode=input.KeyCode
    kbBtn.Text=input.KeyCode.Name; kbBtn.TextColor3=Color3.fromRGB(60,220,100)
    kbLabel.Text="Toggle key:  "..input.KeyCode.Name
    if _G.Notify then _G.Notify("Keybind → "..input.KeyCode.Name,"success") end
end)
