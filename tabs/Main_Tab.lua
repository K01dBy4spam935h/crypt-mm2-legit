-- Creates the Main tab page
local page = _G.UI:MakeTab("Main", (_G.Config.TabIcons or {}).Main or "rbxassetid://0")
_G.Pages["Main"].page.Visible = true
_G.Pages["Main"].btn.BackgroundTransparency = 0.65
_G.Pages["Main"].lbl.TextColor3 = Color3.fromRGB(255,255,255)
-- sections fill this tab: ExecutorInfo, RoundTimer (info section)
