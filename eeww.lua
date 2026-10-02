-- SpeedRun v2 | standalone WalkSpeed + Save/TP (Delta/mobile friendly)
local p = game.Players.LocalPlayer
local DEFAULT_WS = 16
local MIN_SPEED = 16
local MAX_SPEED = 1000
local POS_DIR = "SpeedRun"
local POS_FILE = "SpeedRun/pos.txt"

for _, g in ipairs({game.CoreGui, p.PlayerGui}) do
  pcall(function()
    local o = g:FindFirstChild("SpeedRunUI")
    if o then o:Destroy() end
  end)
end

local speed = 100
local enabled = false
local savedCF = nil
local refresh, apply

-- load saved position
pcall(function()
  if isfile and isfile(POS_FILE) then
    local nums = {}
    for n in readfile(POS_FILE):gmatch("(-?%d+%.?%d*)") do
      table.insert(nums, tonumber(n))
    end
    if #nums >= 12 then
      savedCF = CFrame.new(nums[1], nums[2], nums[3], nums[4], nums[5], nums[6],
        nums[7], nums[8], nums[9], nums[10], nums[11], nums[12])
    end
  end
end)

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
  Size = UDim2.new(0, 220, 0, 168),
  Position = UDim2.new(0.5, -110, 0.3, 0),
  BackgroundColor3 = Color3.fromRGB(25, 25, 30),
  BorderSizePixel = 0,
  Active = true,
  Draggable = true,
}, gui)
mk("UICorner", {CornerRadius = UDim.new(0, 8)}, main)

mk("TextLabel", {
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
  Size = UDim2.new(1, -16, 0, 24),
  Position = UDim2.new(0, 8, 0, 28),
  BackgroundTransparency = 1,
  Font = Enum.Font.Gotham,
  TextSize = 15,
  TextColor3 = Color3.fromRGB(140, 200, 255),
  Text = "Speed: 100",
}, main)

local row = mk("Frame", {
  Size = UDim2.new(1, -16, 0, 30),
  Position = UDim2.new(0, 8, 0, 54),
  BackgroundTransparency = 1,
}, main)

local minus = mk("TextButton", {
  Size = UDim2.new(0, 58, 0, 30),
  Position = UDim2.new(0, 0, 0, 0),
  BackgroundColor3 = Color3.fromRGB(60, 60, 70),
  Font = Enum.Font.GothamBold,
  TextSize = 17,
  TextColor3 = Color3.fromRGB(255, 255, 255),
  Text = "-10",
}, row)
mk("UICorner", {CornerRadius = UDim.new(0, 6)}, minus)

local plus = mk("TextButton", {
  Size = UDim2.new(0, 58, 0, 30),
  Position = UDim2.new(1, -58, 0, 0),
  BackgroundColor3 = Color3.fromRGB(60, 60, 70),
  Font = Enum.Font.GothamBold,
  TextSize = 17,
  TextColor3 = Color3.fromRGB(255, 255, 255),
  Text = "+10",
}, row)
mk("UICorner", {CornerRadius = UDim.new(0, 6)}, plus)

local box = mk("TextBox", {
  Size = UDim2.new(1, -132, 0, 30),
  Position = UDim2.new(0, 66, 0, 0),
  BackgroundColor3 = Color3.fromRGB(40, 40, 48),
  Font = Enum.Font.GothamBold,
  TextSize = 16,
  TextColor3 = Color3.fromRGB(255, 255, 255),
  Text = "100",
  ClearTextOnFocus = false,
}, row)
mk("UICorner", {CornerRadius = UDim.new(0, 6)}, box)

local tog = mk("TextButton", {
  Size = UDim2.new(1, -16, 0, 30),
  Position = UDim2.new(0, 8, 0, 90),
  BackgroundColor3 = Color3.fromRGB(180, 60, 60),
  Font = Enum.Font.GothamBold,
  TextSize = 14,
  TextColor3 = Color3.fromRGB(255, 255, 255),
  Text = "OFF",
}, main)
mk("UICorner", {CornerRadius = UDim.new(0, 6)}, tog)

local row2 = mk("Frame", {
  Size = UDim2.new(1, -16, 0, 30),
  Position = UDim2.new(0, 8, 0, 126),
  BackgroundTransparency = 1,
}, main)

local saveBtn = mk("TextButton", {
  Size = UDim2.new(0.5, -4, 1, 0),
  Position = UDim2.new(0, 0, 0, 0),
  BackgroundColor3 = Color3.fromRGB(40, 120, 220),
  Font = Enum.Font.GothamBold,
  TextSize = 14,
  TextColor3 = Color3.fromRGB(255, 255, 255),
  Text = "Save Pos",
}, row2)
mk("UICorner", {CornerRadius = UDim.new(0, 6)}, saveBtn)

local tpBtn = mk("TextButton", {
  Size = UDim2.new(0.5, -4, 1, 0),
  Position = UDim2.new(0.5, 4, 0, 0),
  BackgroundColor3 = Color3.fromRGB(60, 170, 80),
  Font = Enum.Font.GothamBold,
  TextSize = 14,
  TextColor3 = Color3.fromRGB(255, 255, 255),
  Text = "TP",
}, row2)
mk("UICorner", {CornerRadius = UDim.new(0, 6)}, tpBtn)

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
local function press(fn)
  return function()
    if busy then return end
    busy = true
    pcall(fn)
    task.wait(0.25)
    busy = false
  end
end

refresh = function()
  lbl.Text = "Speed: " .. tostring(speed)
  if box.Text ~= tostring(speed) then box.Text = tostring(speed) end
  tog.Text = enabled and "ON" or "OFF"
  tog.BackgroundColor3 = enabled and Color3.fromRGB(60, 170, 80) or Color3.fromRGB(180, 60, 60)
  tpBtn.Text = savedCF and "TP" or "No Pos"
end

apply = function()
  local c = p.Character
  local h = c and c:FindFirstChildOfClass("Humanoid")
  if h then
    pcall(function() h.WalkSpeed = enabled and speed or DEFAULT_WS end)
  end
end

local function savePos()
  local c = p.Character
  local hrp = c and c:FindFirstChild("HumanoidRootPart")
  if not hrp then return end
  savedCF = hrp.CFrame
  pcall(function()
    if makefolder and isfolder and not isfolder(POS_DIR) then makefolder(POS_DIR) end
    if writefile then writefile(POS_FILE, table.concat({savedCF:GetComponents()}, ",")) end
  end)
  refresh()
end

local function tpPos()
  if not savedCF then return end
  local c = p.Character
  local hrp = c and c:FindFirstChild("HumanoidRootPart")
  if hrp then pcall(function() hrp.CFrame = savedCF end) end
end

local function bump(d)
  speed = math.max(MIN_SPEED, math.min(MAX_SPEED, speed + d))
  refresh()
  apply()
end

minus.Activated:Connect(press(function() bump(-10) end))
minus.MouseButton1Click:Connect(press(function() bump(-10) end))
plus.Activated:Connect(press(function() bump(10) end))
plus.MouseButton1Click:Connect(press(function() bump(10) end))

box.FocusLost:Connect(function(enter)
  if not enter then return end
  local n = tonumber(box.Text)
  if n then
    speed = math.max(MIN_SPEED, math.min(MAX_SPEED, math.floor(n)))
  end
  refresh()
  apply()
end)

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

saveBtn.Activated:Connect(press(savePos))
saveBtn.MouseButton1Click:Connect(press(savePos))
tpBtn.Activated:Connect(press(tpPos))
tpBtn.MouseButton1Click:Connect(press(tpPos))

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

-- fast keep-alive loop (game resets WalkSpeed)
task.spawn(function()
  while gui.Parent do
    if enabled then apply() end
    task.wait(0.1)
  end
end)
p.CharacterAdded:Connect(function()
  task.wait(1)
  apply()
end)

refresh()