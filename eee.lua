-- SpeedRun v1 | standalone WalkSpeed (Delta/mobile friendly)
local p = game.Players.LocalPlayer
local DEFAULT_WS = 16

for _, g in ipairs({game.CoreGui, p.PlayerGui}) do
  pcall(function()
    local o = g:FindFirstChild("SpeedRunUI")
    if o then o:Destroy() end
  end)
end

local speed = 60
local enabled = false

local gui = Instance.new("ScreenGui")
gui.Name = "SpeedRunUI"
gui.ResetOnSpawn = false
pcall(function()
  if gethui then gui.Parent = gethui() else gui.Parent = game.CoreGui end
end)
if not gui.Parent then gui.Parent = p.PlayerGui end

local function mk(cls, props, parent)
  local o = Instance.new(cls)
  for k, v in pairs(props) do
    pcall(function() o[k] = v end)
  end
  o.Parent = parent
  return o
end

local main = mk("Frame", {
  Name = "Main",
  Size = UDim2.new(0, 220, 0, 130),
  Position = UDim2.new(0.5, -110, 0.3, 0),
  BackgroundColor3 = Color3.fromRGB(25, 25, 30),
  BorderSizePixel = 0,
  Active = true,
  Draggable = true,
}, gui)
mk("UICorner", {CornerRadius = UDim.new(0, 8)}, main)

local title = mk("TextLabel", {
  Size = UDim2.new(1, -30, 0, 28),
  Position = UDim2.new(0, 8, 0, 0),
  BackgroundTransparency = 1,
  Font = Enum.Font.GothamBold,
  TextSize = 14,
  TextColor3 = Color3.fromRGB(255, 255, 255),
  TextXAlignment = Enum.TextXAlignment.Left,
  Text = "SpeedRun",
}, main)

local minBtn = mk("TextButton", {
  Size = UDim2.new(0, 22, 0, 22),
  Position = UDim2.new(1, -26, 0, 3),
  BackgroundColor3 = Color3.fromRGB(60, 60, 70),
  Font = Enum.Font.GothamBold,
  TextSize = 14,
  TextColor3 = Color3.fromRGB(255, 255, 255),
  Text = "-",
}, main)
mk("UICorner", {CornerRadius = UDim.new(0, 6)}, minBtn)

local lbl = mk("TextLabel", {
  Size = UDim2.new(1, -16, 0, 26),
  Position = UDim2.new(0, 8, 0, 30),
  BackgroundTransparency = 1,
  Font = Enum.Font.Gotham,
  TextSize = 16,
  TextColor3 = Color3.fromRGB(140, 200, 255),
  Text = "Speed: 60",
}, main)

local row = mk("Frame", {
  Size = UDim2.new(1, -16, 0, 30),
  Position = UDim2.new(0, 8, 0, 58),
  BackgroundTransparency = 1,
}, main)

local minus = mk("TextButton", {
  Size = UDim2.new(0, 60, 0, 30),
  Position = UDim2.new(0, 0, 0, 0),
  BackgroundColor3 = Color3.fromRGB(60, 60, 70),
  Font = Enum.Font.GothamBold,
  TextSize = 18,
  TextColor3 = Color3.fromRGB(255, 255, 255),
  Text = "-5",
}, row)
mk("UICorner", {CornerRadius = UDim.new(0, 6)}, minus)

local plus = mk("TextButton", {
  Size = UDim2.new(0, 60, 0, 30),
  Position = UDim2.new(1, -60, 0, 0),
  BackgroundColor3 = Color3.fromRGB(60, 60, 70),
  Font = Enum.Font.GothamBold,
  TextSize = 18,
  TextColor3 = Color3.fromRGB(255, 255, 255),
  Text = "+5",
}, row)
mk("UICorner", {CornerRadius = UDim.new(0, 6)}, plus)

local box = mk("TextBox", {
  Size = UDim2.new(0, 76, 0, 30),
  Position = UDim2.new(0.5, -38, 0, 0),
  BackgroundColor3 = Color3.fromRGB(40, 40, 48),
  Font = Enum.Font.GothamBold,
  TextSize = 16,
  TextColor3 = Color3.fromRGB(255, 255, 255),
  Text = "60",
  ClearTextOnFocus = false,
}, row)
mk("UICorner", {CornerRadius = UDim.new(0, 6)}, box)
boxRef = box

box.FocusLost:Connect(function(enter)
  if not enter then return end
  local n = tonumber(box.Text)
  if n then
    speed = math.clamp(math.floor(n), 16, 500)
  end
  box.Text = tostring(speed)
  refresh()
  apply()
end)

local tog = mk("TextButton", {
  Size = UDim2.new(1, -16, 0, 30),
  Position = UDim2.new(0, 8, 0, 92),
  BackgroundColor3 = Color3.fromRGB(180, 60, 60),
  Font = Enum.Font.GothamBold,
  TextSize = 14,
  TextColor3 = Color3.fromRGB(255, 255, 255),
  Text = "OFF",
}, main)
mk("UICorner", {CornerRadius = UDim.new(0, 6)}, tog)

-- floating icon to reopen
local icon = mk("TextButton", {
  Name = "Icon",
  Size = UDim2.new(0, 44, 0, 44),
  Position = UDim2.new(0, 12, 0.45, 0),
  BackgroundColor3 = Color3.fromRGB(40, 120, 220),
  Font = Enum.Font.GothamBold,
  TextSize = 16,
  TextColor3 = Color3.fromRGB(255, 255, 255),
  Text = "SR",
  Visible = false,
  Active = true,
  Draggable = true,
}, gui)
mk("UICorner", {CornerRadius = UDim.new(1, 0)}, icon)

local busy = false
local boxRef = nil
local function press(fn)
  return function()
    if busy then return end
    busy = true
    pcall(fn)
    task.wait(0.25)
    busy = false
  end
end

local function refresh()
  lbl.Text = "Speed: " .. tostring(speed)
  if boxRef then boxRef.Text = tostring(speed) end
  tog.Text = enabled and "ON" or "OFF"
  tog.BackgroundColor3 = enabled and Color3.fromRGB(60, 170, 80) or Color3.fromRGB(180, 60, 60)
end

local function apply()
  local c = p.Character
  local h = c and c:FindFirstChildOfClass("Humanoid")
  if h then
    pcall(function() h.WalkSpeed = enabled and speed or DEFAULT_WS end)
  end
end

minus.Activated:Connect(press(function()
  speed = math.max(16, speed - 5)
  refresh()
  apply()
end))
plus.Activated:Connect(press(function()
  speed = math.min(500, speed + 5)
  refresh()
  apply()
end))
minus.MouseButton1Click:Connect(press(function()
  speed = math.max(16, speed - 5)
  refresh()
  apply()
end))
plus.MouseButton1Click:Connect(press(function()
  speed = math.min(500, speed + 5)
  refresh()
  apply()
end))

tog.Activated:Connect(press(function()
  enabled = not enabled
  refresh()
  apply()
end))
tog.MouseButton1Click:Connect(press(function()
  enabled = not enabled
  refresh()
  apply()
end))

minBtn.Activated:Connect(press(function()
  main.Visible = false
  icon.Visible = true
end))
minBtn.MouseButton1Click:Connect(press(function()
  main.Visible = false
  icon.Visible = true
end))
icon.Activated:Connect(press(function()
  icon.Visible = false
  main.Visible = true
end))
icon.MouseButton1Click:Connect(press(function()
  icon.Visible = false
  main.Visible = true
end))

-- keep speed (games often reset WalkSpeed)
task.spawn(function()
  while gui.Parent do
    if enabled then apply() end
    task.wait(0.5)
  end
end)
p.CharacterAdded:Connect(function()
  task.wait(1)
  apply()
end)

refresh()
