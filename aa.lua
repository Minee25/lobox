-- OkieShop v9 | Rayfield UI (Eazvy/UILibs -> Rayfield)
local p = game.Players.LocalPlayer

local function containers()
  local c = {}
  pcall(function() if gethui then table.insert(c, gethui()) end end)
  table.insert(c, game.CoreGui)
  table.insert(c, p.PlayerGui)
  return c
end
local function inList(t, v)
  for _, x in ipairs(t) do if x == v then return true end end
  return false
end

-- destroy old UIs (old Rayfield + all our old versions)
local OLD = {"OkieShopUI","OkieShopEditor","Rayfield","Rayfield-Old","SuperUI","ProUX","StepEasy","StepUX","StepPro","StepRec","Rec9193","RecL","SuperDebug","Dbg","NearDbg","AC","AC2","Full93","Full93F","FullTP","Farm9193","Walk93","Tp93","Mini93"}
for _, c in ipairs(containers()) do
  for _, v in pairs(c:GetChildren()) do
    if inList(OLD, v.Name) or v:GetAttribute("SuperUI") or v:GetAttribute("OkieShop") then
      pcall(function() v:Destroy() end)
    end
  end
end

-- snapshot before loading Rayfield so we can find its ScreenGui
local before = {}
for _, c in ipairs(containers()) do
  for _, v in pairs(c:GetChildren()) do before[v] = true end
end

-- asset rbxassetid://10804731440 (TabList.Template) ไม่มี Shadow/Image/UIStroke
-- -> patch source ให้สร้าง child ที่ขาดก่อน Rayfield ใช้งาน
local MARK = 'local Rayfield = game:GetObjects("rbxassetid://10804731440")[1]'
local PATCH = [=[local Rayfield = game:GetObjects("rbxassetid://10804731440")[1]
pcall(function()
	local function E(parent, name, class)
		if not parent then return nil, false end
		local c = parent:FindFirstChild(name)
		if c then return c, false end
		local n = Instance.new(class)
		n.Name = name
		n.Parent = parent
		return n, true
	end
	local main = Rayfield:FindFirstChild("Main")
	if main then
		local tabList = main:FindFirstChild("TabList")
		if tabList then
			for _, tpl in ipairs(tabList:GetChildren()) do
				if tpl:IsA("Frame") and tpl.Name ~= "Placeholder" then
					local sh, isNew = E(tpl, "Shadow", "ImageLabel")
					if sh and isNew then
						sh.BackgroundTransparency = 1
						sh.Size = UDim2.new(1, 8, 1, 8)
						sh.Position = UDim2.new(0, -4, 0, -4)
						sh.ZIndex = math.max(0, tpl.ZIndex - 1)
						sh.Image = ""
					end
					local im, imNew = E(tpl, "Image", "ImageLabel")
					if im and imNew then im.Visible = false im.BackgroundTransparency = 1 end
					local st, stNew = E(tpl, "UIStroke", "UIStroke")
					if st and stNew then st.Transparency = 1 end
				end
			end
		end
		local els = main:FindFirstChild("Elements")
		local et = els and els:FindFirstChild("Template")
		if et then
			for _, el in ipairs(et:GetChildren()) do
				if el:IsA("Frame") or el:IsA("ScrollingFrame") then
					local st, stNew = E(el, "UIStroke", "UIStroke")
					if st and stNew then st.Transparency = 1 end
					local ti, tiNew = E(el, "Title", "TextLabel")
					if ti then
						ti.BackgroundTransparency = 1
						if tiNew then ti.Text = "" end
					end
					local nm = el.Name
					if nm == "Toggle" then
						local sw = E(el, "Switch", "Frame")
						local ind = E(sw, "Indicator", "Frame")
						E(sw, "UIStroke", "UIStroke")
						E(ind, "UIStroke", "UIStroke")
						E(el, "Interact", "TextButton")
					elseif nm == "Slider" then
						local m = E(el, "Main", "Frame")
						E(m, "UIStroke", "UIStroke")
						E(m, "Progress", "Frame")
						E(m, "Information", "TextLabel")
						E(m, "Interact", "TextButton")
					elseif nm == "Button" then
						E(el, "Interact", "TextButton")
						E(el, "ElementIndicator", "TextLabel")
					elseif nm == "Paragraph" then
						E(el, "Content", "TextLabel")
					elseif nm == "Input" then
						local f = E(el, "InputFrame", "Frame")
						E(f, "UIStroke", "UIStroke")
						E(f, "InputBox", "TextBox")
					end
				end
			end
			-- if a template is missing entirely, build a minimal one
			local function buildTpl(name, h)
				local f, isNew = E(et, name, "Frame")
				if not f or not isNew then return f end
				f.Size = UDim2.new(1, -10, 0, h)
				f.BackgroundTransparency = 1
				local st = E(f, "UIStroke", "UIStroke")
				if st then st.Transparency = 1 end
				local ti = E(f, "Title", "TextLabel")
				ti.BackgroundTransparency = 1
				ti.Text = ""
				ti.Position = UDim2.new(0, 10, 0, 5)
				ti.Size = UDim2.new(1, -70, 0, 20)
				ti.Font = Enum.Font.Gotham
				ti.TextSize = 14
				ti.TextColor3 = Color3.fromRGB(255, 255, 255)
				ti.TextXAlignment = Enum.TextXAlignment.Left
				return f
			end
			local tog = buildTpl("Toggle", 50)
			if tog then
				local sw, swNew = E(tog, "Switch", "Frame")
				if swNew then
					sw.Size = UDim2.new(0, 40, 0, 22)
					sw.Position = UDim2.new(1, -50, 0.5, -11)
					sw.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
					local ind = E(sw, "Indicator", "Frame")
					ind.Size = UDim2.new(0, 17, 0, 17)
					ind.Position = UDim2.new(1, -20, 0.5, 0)
					ind.AnchorPoint = Vector2.new(0.5, 0.5)
					ind.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
					E(sw, "UIStroke", "UIStroke")
					E(ind, "UIStroke", "UIStroke")
				end
				local it, itNew = E(tog, "Interact", "TextButton")
				if itNew then
					it.Size = UDim2.new(1, 0, 1, 0)
					it.BackgroundTransparency = 1
					it.Text = ""
					it.ZIndex = 5
				end
			end
			local sld = buildTpl("Slider", 70)
			if sld then
				local m, mNew = E(sld, "Main", "Frame")
				if mNew then
					m.Position = UDim2.new(1, -50, 0.5, -12)
					m.Size = UDim2.new(1, -170, 0, 24)
					m.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
					E(m, "UIStroke", "UIStroke")
					local pr = E(m, "Progress", "Frame")
					pr.Size = UDim2.new(0, 5, 1, 0)
					pr.BackgroundColor3 = Color3.fromRGB(90, 140, 255)
					local inf = E(m, "Information", "TextLabel")
					inf.BackgroundTransparency = 1
					inf.Size = UDim2.new(1, 0, 1, 0)
					inf.Font = Enum.Font.Gotham
					inf.TextSize = 12
					inf.TextColor3 = Color3.fromRGB(255, 255, 255)
					local it = E(m, "Interact", "TextButton")
					it.Size = UDim2.new(1, 0, 1, 0)
					it.BackgroundTransparency = 1
					it.Text = ""
					it.ZIndex = 5
				end
			end
			local btn = buildTpl("Button", 50)
			if btn then
				local it, itNew = E(btn, "Interact", "TextButton")
				if itNew then
					it.Size = UDim2.new(1, 0, 1, 0)
					it.BackgroundTransparency = 1
					it.Text = ""
					it.ZIndex = 5
				end
				local ei = E(btn, "ElementIndicator", "TextLabel")
				ei.BackgroundTransparency = 1
				ei.Position = UDim2.new(1, -60, 0.5, -8)
				ei.Size = UDim2.new(0, 50, 0, 16)
				ei.Font = Enum.Font.Gotham
				ei.TextSize = 12
				ei.TextColor3 = Color3.fromRGB(255, 255, 255)
			end
			local par = buildTpl("Paragraph", 90)
			if par then
				local co, coNew = E(par, "Content", "TextLabel")
				if coNew then
					co.BackgroundTransparency = 1
					co.Position = UDim2.new(0, 10, 0, 30)
					co.Size = UDim2.new(1, -20, 1, -40)
					co.Font = Enum.Font.Gotham
					co.TextSize = 13
					co.TextColor3 = Color3.fromRGB(200, 200, 200)
					co.TextWrapped = true
					co.TextXAlignment = Enum.TextXAlignment.Left
					co.TextYAlignment = Enum.TextYAlignment.Top
				end
			end
			buildTpl("Label", 50)
			buildTpl("SectionTitle", 28)
			buildTpl("SectionSpacing", 10)
			local inp = buildTpl("Input", 60)
			if inp then
				local f, fNew = E(inp, "InputFrame", "Frame")
				if fNew then
					f.Position = UDim2.new(1, -150, 0.5, -15)
					f.Size = UDim2.new(0, 130, 0, 30)
					f.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
					E(f, "UIStroke", "UIStroke")
					local box = E(f, "InputBox", "TextBox")
					box.Size = UDim2.new(1, -10, 1, -8)
					box.Position = UDim2.new(0, 5, 0, 4)
					box.BackgroundTransparency = 1
					box.Font = Enum.Font.Gotham
					box.TextSize = 13
					box.TextColor3 = Color3.fromRGB(255, 255, 255)
					box.TextXAlignment = Enum.TextXAlignment.Left
				end
			end
		end
	end
	if not Rayfield:FindFirstChild("Notifications") then
		local nf = Instance.new("Frame")
		nf.Name = "Notifications"
		nf.Size = UDim2.new(0, 340, 0, 400)
		nf.BackgroundTransparency = 1
		nf.Visible = false
		nf.Parent = Rayfield
		local t = Instance.new("Frame")
		t.Name = "Template"
		t.Size = UDim2.new(1, 0, 0, 80)
		t.BackgroundTransparency = 1
		t.Visible = false
		t.Parent = nf
	end
end)
]=]

local okR, Rayfield = pcall(function()
  local src = game:HttpGet("https://raw.githubusercontent.com/jensonhirst/Rayfield/main/source")
  if type(src) ~= "string" or #src < 1000 then error("HttpGet bad response") end
  local i = src:find(MARK, 1, true)
  if i then
    src = src:sub(1, i - 1) .. PATCH .. src:sub(i + #MARK)
  else
    warn("OkieShop: patch marker not found, running unpatched")
  end
  return loadstring(src)()
end)
if not okR or not Rayfield then
  warn("Rayfield load fail:", Rayfield)
  return
end

local rgui = nil
for _, c in ipairs(containers()) do
  for _, v in pairs(c:GetChildren()) do
    if not before[v] and v.Name ~= "OkieShopUI" and v.Name ~= "OkieShopEditor" then rgui = v end
  end
end

-- hide Rayfield built-in Hide button (its restore needs key K = impossible on mobile)
pcall(function()
  if rgui then
    local topbar = rgui:FindFirstChild("Topbar", true)
    if topbar then
      local h = topbar:FindFirstChild("Hide", true)
      if h then h.Visible = false end
    end
  end
end)

-- ================= state =================
_G.DefaultDelay = 1.5
_G.Steps = _G.Steps or {}
_G.Loop = false _G.Go = false _G.Farm = false _G.Claim = false
_G.Fly = false _G.Float = false _G.SpeedOn = false
_G.WalkSpeed = 16 _G.FlySpeed = 60

local function fmt(s)
  return string.format("%.2f,%.2f,%.2f", s.X, s.Y, s.Z)..(s.D and (","..string.format("%.1f", s.D)) or "")
end
local function stepsText()
  local t = {}
  for _, s in ipairs(_G.Steps) do table.insert(t, fmt(s)) end
  return table.concat(t, "\n")
end
local function parseSteps(txt)
  local ns = {}
  for part in string.gmatch(txt or "", "[^\n;]+") do
    local x, y, z, d = string.match(part, "([%-%d%.]+),%s*([%-%d%.]+),%s*([%-%d%.]+),?%s*([%-%d%.]*)")
    if x then
      table.insert(ns, {X = tonumber(x), Y = tonumber(y), Z = tonumber(z), D = tonumber(d) or nil})
    end
  end
  return ns
end
local DB = "OkieShop/steps.txt"
local function saveDB()
  pcall(function() if makefolder and not isfolder("OkieShop") then makefolder("OkieShop") end end)
  pcall(function() if writefile then writefile(DB, stepsText()) end end)
end
local function loadDB()
  pcall(function()
    if readfile then
      local txt = readfile(DB)
      if txt then local ns = parseSteps(txt) if #ns > 0 then _G.Steps = ns end end
    end
  end)
end
loadDB()
if #_G.Steps == 0 then
  _G.Steps = {
    {X = 4500.97, Y = 6.5, Z = 178.9,  D = 1.5},
    {X = 4501.04, Y = 6.5, Z = 265.46, D = 1.5},
    {X = 4501.03, Y = 6.5, Z = 368.24, D = 1.5},
    {X = 4489.77, Y = 6.8, Z = 427.45, D = 3},
  }
  saveDB()
end

local R = game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("Remotes")
local Click = R:WaitForChild("PlayerClick")
local Train = R:WaitForChild("RequestTrain")
local ClaimR = R:WaitForChild("ClaimPlaytimeReward")
local UIS = game:GetService("UserInputService")
local Run = game:GetService("RunService")

local function notify(t, c)
  pcall(function() Rayfield:Notify({Title = t, Content = c, Duration = 3.5}) end)
end
local function tp(s)
  local hrp = p.Character and p.Character:FindFirstChild("HumanoidRootPart")
  if hrp then hrp.CFrame = CFrame.new(s.X, s.Y + 3, s.Z) end
end

-- ================= window =================
local Window = Rayfield:CreateWindow({
  Name = "OkieShop",
  LoadingTitle = "OkieShop",
  LoadingSubtitle = "Super 91-93",
  ConfigurationSaving = { Enabled = false, FileName = "OkieShop" },
  Discord = { Enabled = false },
  KeySystem = false,
})

-- ================= floating icon + minimize =================
local iconGui = Instance.new("ScreenGui")
iconGui.Name = "OkieShopUI"
iconGui:SetAttribute("OkieShop", true)
iconGui.ResetOnSpawn = false
iconGui.DisplayOrder = 99999
pcall(function() iconGui.Parent = gethui() end)
if not iconGui.Parent then iconGui.Parent = game.CoreGui end
if not iconGui.Parent then iconGui.Parent = p.PlayerGui end

local icon = Instance.new("TextButton", iconGui)
icon.Size = UDim2.new(0, 56, 0, 56)
icon.Position = UDim2.new(1, -68, 0, 90)
icon.Text = "OS"
icon.TextSize = 18
icon.Font = Enum.Font.GothamBlack
icon.TextColor3 = Color3.new(1, 1, 1)
icon.BackgroundColor3 = Color3.fromRGB(37, 122, 247)
Instance.new("UICorner", icon).CornerRadius = UDim.new(1, 0)
local stroke = Instance.new("UIStroke", icon)
stroke.Color = Color3.fromRGB(255, 255, 255)
stroke.Thickness = 2
stroke.Transparency = 0.5
icon.Visible = false

local function mainFrame()
  if not rgui then return nil end
  local m = rgui:FindFirstChild("Main", true)
  if m and m:IsA("Frame") then return m end
  return nil
end

-- inverse of Rayfield Hide() (safety net if UI got hidden some other way)
local function restoreMain()
  local main = mainFrame()
  if not main then return end
  pcall(function()
    main.Visible = true
    main.BackgroundTransparency = 0
    local topbar = main:FindFirstChild("Topbar", true)
    if topbar then
      topbar.BackgroundTransparency = 0
      for _, ch in ipairs(topbar:GetChildren()) do
        if ch:IsA("ImageButton") then ch.ImageTransparency = 0.8
        elseif ch:IsA("TextLabel") then ch.TextTransparency = 0 end
      end
      local d = topbar:FindFirstChild("Divider") if d then d.BackgroundTransparency = 0 end
      local s = topbar:FindFirstChild("UIStroke") if s then s.Transparency = 0 end
    end
    local shadow = main:FindFirstChild("Shadow", true)
    if shadow and shadow:IsA("ImageLabel") then shadow.ImageTransparency = 0.55 end
    local tabList = main:FindFirstChild("TabList", true)
    if tabList then
      for _, tb in ipairs(tabList:GetChildren()) do
        if tb:IsA("Frame") and tb.Name ~= "Placeholder" then
          tb.BackgroundTransparency = 0
          local ti = tb:FindFirstChild("Title") if ti then ti.TextTransparency = 0 end
          local im = tb:FindFirstChild("Image") if im then im.ImageTransparency = 0 end
          local sh = tb:FindFirstChild("Shadow") if sh then sh.ImageTransparency = 0 end
          local s = tb:FindFirstChild("UIStroke") if s then s.Transparency = 0 end
        end
      end
    end
    local elements = main:FindFirstChild("Elements", true)
    if elements then
      for _, tabPg in ipairs(elements:GetChildren()) do
        if tabPg:IsA("ScrollingFrame") and tabPg.Name ~= "Template" and tabPg.Name ~= "Placeholder" then
          for _, el in ipairs(tabPg:GetChildren()) do
            if el:IsA("Frame") and el.Name ~= "SectionSpacing" and el.Name ~= "Placeholder" then
              if el.Name == "SectionTitle" then
                local ti = el:FindFirstChild("Title") if ti then ti.TextTransparency = 0 end
              else
                el.BackgroundTransparency = 0
                local s = el:FindFirstChild("UIStroke") if s then s.Transparency = 0 end
                local ti = el:FindFirstChild("Title") if ti then ti.TextTransparency = 0 end
                for _, ch in ipairs(el:GetChildren()) do
                  if ch:IsA("Frame") or ch:IsA("TextLabel") or ch:IsA("TextBox") or ch:IsA("ImageButton") or ch:IsA("ImageLabel") then
                    ch.Visible = true
                  end
                end
              end
            end
          end
        end
      end
    end
  end)
end

local function hideUI()
  if rgui then pcall(function() rgui.Enabled = false end) end
  icon.Visible = true
end
local function showUI()
  if rgui then pcall(function() rgui.Enabled = true end) end
  restoreMain()
  icon.Visible = false
end
icon.Activated:Connect(showUI)
icon.MouseButton1Click:Connect(showUI)

task.spawn(function()
  while iconGui.Parent do
    local vis = true
    if rgui then
      local m = mainFrame()
      vis = rgui.Enabled ~= false and (m == nil or m.Visible)
    end
    icon.Visible = not vis
    task.wait(0.7)
  end
end)

-- ================= AUTO TAB =================
local AutoTab = Window:CreateTab("Auto")
AutoTab:CreateSection("Teleport / Farm")
local GoToggle = AutoTab:CreateToggle({
  Name = "Start Teleport Loop",
  CurrentValue = false,
  Flag = "GoFlag",
  Callback = function(v)
    _G.Go = v
    if v and #_G.Steps == 0 then
      _G.Go = false
      notify("Steps", "No steps - save positions first")
    end
  end,
})
AutoTab:CreateToggle({
  Name = "Loop (วนซ้ำ)",
  CurrentValue = false,
  Flag = "LoopFlag",
  Callback = function(v) _G.Loop = v end,
})
AutoTab:CreateToggle({
  Name = "Farm (Click + Train)",
  CurrentValue = false,
  Flag = "FarmFlag",
  Callback = function(v) _G.Farm = v end,
})
AutoTab:CreateToggle({
  Name = "Auto Claim Playtime",
  CurrentValue = false,
  Flag = "ClaimFlag",
  Callback = function(v) _G.Claim = v end,
})
AutoTab:CreateSlider({
  Name = "Default Delay (step ไม่ระบุ)",
  Range = {0.5, 10},
  Increment = 0.5,
  Suffix = "s",
  CurrentValue = 1.5,
  Flag = "DefDelayFlag",
  Callback = function(v) _G.DefaultDelay = v end,
})
AutoTab:CreateButton({
  Name = "Minimize (ย่อ + icon ลอย OS)",
  Callback = hideUI,
})

-- ================= PLAYER TAB =================
local PlayerTab = Window:CreateTab("Player")
PlayerTab:CreateSection("Movement")
PlayerTab:CreateToggle({
  Name = "Fly (Joystick/WASD, กระโดด=ขึ้น C/Ctrl=ลง)",
  CurrentValue = false,
  Flag = "FlyFlag",
  Callback = function(v) _G.Fly = v end,
})
PlayerTab:CreateToggle({
  Name = "Float (ลอยกลางอากาศ)",
  CurrentValue = false,
  Flag = "FloatFlag",
  Callback = function(v)
    _G.Float = v
    local hrp = p.Character and p.Character:FindFirstChild("HumanoidRootPart")
    if v and hrp then
      if not _G._bv then
        _G._bv = Instance.new("BodyVelocity", hrp)
        _G._bv.MaxForce = Vector3.new(1e5, 1e5, 1e5)
        _G._bv.Velocity = Vector3.new(0, 0, 0)
      end
    else
      pcall(function() if _G._bv then _G._bv:Destroy() end end)
      _G._bv = nil
    end
  end,
})
PlayerTab:CreateToggle({
  Name = "Speed",
  CurrentValue = false,
  Flag = "SpeedFlag",
  Callback = function(v) _G.SpeedOn = v end,
})
PlayerTab:CreateSlider({
  Name = "WalkSpeed",
  Range = {16, 200},
  Increment = 1,
  CurrentValue = 16,
  Flag = "WalkFlag",
  Callback = function(v) _G.WalkSpeed = v end,
})
PlayerTab:CreateSlider({
  Name = "FlySpeed",
  Range = {10, 300},
  Increment = 5,
  CurrentValue = 60,
  Flag = "FlySpdFlag",
  Callback = function(v) _G.FlySpeed = v end,
})

-- ================= STEPS TAB =================
local StepsTab = Window:CreateTab("Steps")
StepsTab:CreateSection("Step Editor - 1 บรรทัดต่อจุด: x,y,z,delay")
StepsTab:CreateParagraph({
  Title = "Database",
  Content = "steps บันทึกลง OkieShop/steps.txt อัตโนมัติ - จุดตอนนี้: " .. #_G.Steps,
})

-- custom multiline editor (guaranteed to work)
local editorGui = Instance.new("ScreenGui")
editorGui.Name = "OkieShopEditor"
editorGui:SetAttribute("OkieShop", true)
editorGui.ResetOnSpawn = false
editorGui.DisplayOrder = 99998
pcall(function() editorGui.Parent = gethui() end)
if not editorGui.Parent then editorGui.Parent = game.CoreGui end
if not editorGui.Parent then editorGui.Parent = p.PlayerGui end

local ef = Instance.new("Frame", editorGui)
ef.Size = UDim2.new(0, 340, 0, 420)
ef.Position = UDim2.new(0.5, -170, 0.5, -210)
ef.BackgroundColor3 = Color3.fromRGB(22, 24, 30)
ef.Visible = false
ef.Active = true
ef.Draggable = true
Instance.new("UICorner", ef).CornerRadius = UDim.new(0, 10)

local et = Instance.new("TextLabel", ef)
et.Size = UDim2.new(1, 0, 0, 30)
et.BackgroundColor3 = Color3.fromRGB(32, 36, 46)
et.Text = "OkieShop Step Editor"
et.TextSize = 14
et.Font = Enum.Font.GothamBold
et.TextColor3 = Color3.new(1, 1, 1)
Instance.new("UICorner", et).CornerRadius = UDim.new(0, 10)

local ebox = Instance.new("TextBox", ef)
ebox.Position = UDim2.new(0, 8, 0, 36)
ebox.Size = UDim2.new(1, -16, 1, -84)
ebox.MultiLine = true
ebox.ClearTextOnFocus = false
ebox.TextWrapped = true
ebox.TextXAlignment = Enum.TextXAlignment.Left
ebox.TextYAlignment = Enum.TextYAlignment.Top
ebox.TextSize = 13
ebox.Font = Enum.Font.Code
ebox.BackgroundColor3 = Color3.fromRGB(12, 12, 14)
ebox.TextColor3 = Color3.fromRGB(170, 255, 170)
Instance.new("UICorner", ebox).CornerRadius = UDim.new(0, 6)

local function ebtn(txt, xs, fn, col)
  local b = Instance.new("TextButton", ef)
  b.Size = UDim2.new(0.33, -8, 0, 32)
  b.Position = UDim2.new(xs, 0, 1, -40)
  b.Text = txt
  b.TextSize = 13
  b.Font = Enum.Font.GothamMedium
  b.TextColor3 = Color3.new(1, 1, 1)
  b.BackgroundColor3 = col or Color3.fromRGB(55, 60, 72)
  Instance.new("UICorner", b).CornerRadius = UDim.new(0, 8)
  b.Activated:Connect(function() pcall(fn, b) end)
  b.MouseButton1Click:Connect(function() pcall(fn, b) end)
  return b
end

ebtn("APPLY", 0, function()
  local ns = parseSteps(ebox.Text)
  if #ns > 0 then
    _G.Steps = ns
    saveDB()
    notify("Steps", "Saved " .. #ns .. " steps to database")
  else
    notify("Steps", "No valid lines (x,y,z,delay)")
  end
end, Color3.fromRGB(30, 130, 70))

ebtn("CLOSE", 0.33, function() ef.Visible = false end)

ebtn("COPY", 0.66, function()
  pcall(function() setclipboard(ebox.Text) end)
  notify("Copy", "Copied")
end, Color3.fromRGB(40, 90, 150))

local function openEditor()
  ebox.Text = stepsText()
  ef.Visible = true
end

StepsTab:CreateButton({ Name = "Open Step Editor", Callback = openEditor })
StepsTab:CreateButton({
  Name = "Save จุดที่ยืนอยู่ (ใช้ default delay)",
  Callback = function()
    local hrp = p.Character and p.Character:FindFirstChild("HumanoidRootPart")
    if hrp then
      table.insert(_G.Steps, {X = hrp.Position.X, Y = hrp.Position.Y, Z = hrp.Position.Z, D = _G.DefaultDelay})
      saveDB()
      notify("Saved", #_G.Steps .. " steps (delay " .. tostring(_G.DefaultDelay) .. "s)")
    end
  end,
})
StepsTab:CreateSlider({
  Name = "Delay ของจุดล่าสุด",
  Range = {0.5, 10},
  Increment = 0.5,
  Suffix = "s",
  CurrentValue = 1.5,
  Flag = "LastDelayFlag",
  Callback = function(v)
    if #_G.Steps > 0 then
      _G.Steps[#_G.Steps].D = v
      saveDB()
    end
  end,
})
StepsTab:CreateButton({
  Name = "ลบจุดล่าสุด",
  Callback = function()
    table.remove(_G.Steps)
    saveDB()
    notify("Steps", "Left: " .. #_G.Steps)
  end,
})
StepsTab:CreateButton({
  Name = "ล้างทั้งหมด",
  Callback = function()
    _G.Steps = {}
    saveDB()
    notify("Steps", "Cleared")
  end,
})
StepsTab:CreateButton({
  Name = "Copy Steps (backup)",
  Callback = function()
    pcall(function() setclipboard(stepsText()) end)
    notify("Copy", "Copied to clipboard")
  end,
})

-- ================= systems =================
Run.RenderStepped:Connect(function()
  local char = p.Character
  local hrp = char and char:FindFirstChild("HumanoidRootPart")
  local hum = char and char:FindFirstChildOfClass("Humanoid")
  if not hrp or not hum then return end
  if _G.SpeedOn then hum.WalkSpeed = _G.WalkSpeed else hum.WalkSpeed = 16 end
  if _G.Fly then
    local mv = hum.MoveDirection
    local up = 0
    if UIS:IsKeyDown(Enum.KeyCode.Space) or hum.Jump then up = 1 end
    if UIS:IsKeyDown(Enum.KeyCode.LeftControl) or UIS:IsKeyDown(Enum.KeyCode.C) then up = -1 end
    hrp.Velocity = Vector3.new(mv.X, 0, mv.Z) * _G.FlySpeed + Vector3.new(0, up * _G.FlySpeed, 0)
    pcall(function()
      hrp.CFrame = CFrame.new(hrp.Position, hrp.Position + Vector3.new(hrp.CFrame.LookVector.X, 0, hrp.CFrame.LookVector.Z))
    end)
  end
end)

task.spawn(function()
  while true do
    if _G.Go and #_G.Steps > 0 then
      for _, s in ipairs(_G.Steps) do
        if not _G.Go then break end
        task.wait(s.D or _G.DefaultDelay)
        if _G.Go then tp(s) end
      end
      if not _G.Loop then
        _G.Go = false
        pcall(function() GoToggle:Set(false) end)
      end
    else
      task.wait(0.5)
    end
    task.wait(0.2)
  end
end)

task.spawn(function()
  while true do
    if _G.Farm then
      pcall(function() Click:FireServer() end)
      pcall(function() Train:FireServer() end)
      task.wait(0.4)
    else
      task.wait(0.5)
    end
  end
end)

task.spawn(function()
  while true do
    if _G.Claim then
      for i = 1, 12 do pcall(function() ClaimR:FireServer(i) end) end
      task.wait(10)
    else
      task.wait(1)
    end
  end
end)

notify("OkieShop", "Loaded (Rayfield) - steps: " .. #_G.Steps)
