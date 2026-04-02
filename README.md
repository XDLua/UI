## 📦 การติดตั้ง

```lua
local XDLuaUI = loadstring(game:HttpGet("YOUR_RAW_URL_HERE"))()
```

หรือถ้าใช้ไฟล์ local:

```lua
local XDLuaUI = require(path.to.XDLuaUI)
```

---

## 🚀 Quick Start

```lua
local UI = XDLuaUI:CreateWindow({
    Title = "MY SCRIPT",
    Sub   = "v1.0",
    Logo  = "rbxassetid://YOUR_LOGO_ID",
})

local tab = UI:AddTab("Main", "🏠")

UI:AddSection(tab, "Player")
UI:AddButton(tab, "Click Me", function()
    print("clicked!")
end)
```

---

## 📖 API Reference

### `XDLuaUI:CreateWindow(config)`

สร้างหน้าต่าง UI หลัก รองรับทั้ง table และ string (backward compatible)

```lua
-- แบบ table (แนะนำ)
local UI = XDLuaUI:CreateWindow({
    Title = "SCRIPT NAME",   -- ชื่อหัว (default: "CRIMSON SCRIPT")
    Sub   = "v2.0",          -- ข้อความรอง / version
    Logo  = "rbxassetid://111935661110067"  -- ID รูป Logo
})

-- แบบ string (compat กับ v1.x)
local UI = XDLuaUI:CreateWindow("SCRIPT NAME")
```

**Returns:** `XDLuaUI` object (ใช้เรียก method ต่างๆ ได้เลย)

---

### `UI:AddTab(name, emoji)`

เพิ่ม Tab ในแถบด้านซ้าย

```lua
local tab = UI:AddTab("Combat", "⚔")
local tab2 = UI:AddTab("Visual", "👁")
```

**Returns:** `ScrollingFrame` (content parent — ส่งให้ component ต่างๆ)

---

### `UI:AddSection(parent, text)`

เพิ่มหัวข้อ Section (เส้นคั่นพร้อมข้อความ)

```lua
UI:AddSection(tab, "Aimbot Settings")
```

---

### `UI:AddLabel(parent, text, color?)`

เพิ่มข้อความธรรมดา

```lua
UI:AddLabel(tab, "สถานะ: ใช้งานได้", Color3.fromRGB(40, 200, 100))
```

---

### `UI:AddButton(parent, text, callback)`

เพิ่มปุ่ม (มี Ripple Effect + Hover)

```lua
UI:AddButton(tab, "Teleport to Spawn", function()
    -- code here
end)
```

---

### `UI:AddToggle(parent, text, default, callback)` → `ToggleAPI`

เพิ่ม Toggle Switch

```lua
local tog = UI:AddToggle(tab, "God Mode", false, function(state)
    print("toggle is now:", state)
end)

-- API
tog:Set(true)    -- บังคับเปิด
tog:Get()        -- ดูค่าปัจจุบัน → boolean
```

---

### `UI:AddSlider(parent, text, min, max, default, callback)` → `SliderAPI`

เพิ่ม Slider พร้อม Thumb แบบ interactive

```lua
local sl = UI:AddSlider(tab, "Walk Speed", 0, 100, 16, function(val)
    game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = val
end)

-- API
sl:Set(50)   -- กำหนดค่า
sl:Get()     -- ดูค่าปัจจุบัน → number
```

---

### `UI:AddDropdown(parent, text, list, callback)` → `DropdownAPI`

เพิ่ม Dropdown แบบ multi-select พร้อม animation

```lua
local dd = UI:AddDropdown(tab, "Select Team", {"Red", "Blue", "Green"}, function(selected)
    print(selected) -- table ของสิ่งที่เลือก
end)

-- API
dd:Set("Red")           -- เลือกค่าเดียว + trigger callback
dd:Refresh({"A","B"})   -- อัปเดต list
dd:Clear()              -- ล้างการเลือก
dd:GetSelected()        -- → table ของค่าที่เลือก
```

---

### `UI:AddKeybind(parent, text, defaultKey, callback)` → `KeybindAPI`

เพิ่ม Keybind (คลิกแล้วกดปุ่มเพื่อ set)

```lua
local kb = UI:AddKeybind(tab, "Toggle Menu", Enum.KeyCode.RightShift, function(key)
    print("pressed:", key)
end)

-- API
kb:Set(Enum.KeyCode.F)
kb:Get()   -- → string เช่น "F", "RightShift"
```

---

### `UI:AddTextbox(parent, placeholder, defaultText, callback)` → `TextBox`

เพิ่ม Text Input

```lua
local box = UI:AddTextbox(tab, "ใส่ Player Name...", "", function(text, enterPressed)
    if enterPressed then
        print("Searching:", text)
    end
end)
```

---

### `UI:AddColorPicker(parent, text, default, callback)` → `ColorAPI`

เพิ่ม Color Picker (H/S/V sliders)

```lua
local cp = UI:AddColorPicker(tab, "ESP Color", Color3.fromRGB(255, 0, 0), function(color)
    -- use color
end)

-- API
cp:Set(Color3.fromRGB(0, 255, 0))
cp:Get()   -- → Color3
```

---

### `UI:AddDivider(parent)`

เพิ่มเส้นคั่นแนวนอน

```lua
UI:AddDivider(tab)
```

---

### `UI:Notify(title, message, type?, duration?)`

แสดง Notification มุมขวาล่าง

```lua
UI:Notify("สำเร็จ", "โหลด Script เรียบร้อย", "success", 4)
UI:Notify("ข้อผิดพลาด", "ไม่พบ Player", "error")
UI:Notify("แจ้งเตือน", "เวลาเหลือ 5 นาที", "warning", 6)
UI:Notify("ข้อมูล", "Version 2.0 พร้อมใช้", "info")
```

| type | สี |
|---|---|
| `"info"` | แดง (Accent) |
| `"success"` | เขียว |
| `"warning"` | เหลือง |
| `"error"` | แดงเข้ม |

---

## 🎨 ตัวอย่างสมบูรณ์

```lua
local UI = XDLuaUI:CreateWindow({
    Title = "CRIMSON SCRIPT",
    Sub = "v2.0 BETA",
})

-- Tab: Main
local main = UI:AddTab("Main", "🏠")
UI:AddSection(main, "Player Settings")

local speedSlider = UI:AddSlider(main, "Walk Speed", 0, 200, 16, function(v)
    game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = v
end)

local jumpSlider = UI:AddSlider(main, "Jump Power", 0, 200, 50, function(v)
    game.Players.LocalPlayer.Character.Humanoid.JumpPower = v
end)

UI:AddDivider(main)
UI:AddSection(main, "God Mode")

local godToggle = UI:AddToggle(main, "Enable God Mode", false, function(on)
    -- god mode logic
    UI:Notify("God Mode", on and "เปิดแล้ว" or "ปิดแล้ว", on and "success" or "warning")
end)

UI:AddButton(main, "Reset Character", function()
    game.Players.LocalPlayer.Character.Humanoid.Health = 0
end)

-- Tab: Visual
local visual = UI:AddTab("Visual", "👁")
UI:AddSection(visual, "ESP Settings")

local espColor = UI:AddColorPicker(visual, "ESP Color", Color3.fromRGB(255, 50, 50), function(c)
    -- update ESP color
end)

local espToggle = UI:AddToggle(visual, "Enable ESP", false, function(on)
    -- toggle ESP
end)

-- Tab: Settings
local settings = UI:AddTab("Settings", "⚙")
UI:AddSection(settings, "Keybinds")

UI:AddKeybind(settings, "Toggle GUI", Enum.KeyCode.RightShift, function()
    -- handled by logo button automatically
end)

UI:AddSection(settings, "Info")
UI:AddLabel(settings, "XDLuaUI v2.0 — CRIMSON SCRIPT")
UI:AddLabel(settings, "Made with ❤ for Roblox Executors")

-- Notify เมื่อเปิด
task.wait(0.5)
UI:Notify("ยินดีต้อนรับ", "โหลด CRIMSON SCRIPT สำเร็จ!", "success", 5)
```

---

## ⚙️ Theme Configuration

แก้ไข `Theme` table ในไฟล์ได้เลย:

```lua
local Theme = {
    Main        = Color3.fromRGB(12, 12, 14),    -- พื้นหลังหลัก
    Secondary   = Color3.fromRGB(20, 20, 24),    -- พื้นหลังรอง
    Tertiary    = Color3.fromRGB(28, 28, 34),    -- พื้นหลังที่สาม
    Accent      = Color3.fromRGB(220, 30, 60),   -- สีหลัก (แดง)
    AccentGlow  = Color3.fromRGB(255, 60, 90),   -- สีเรืองแสง
    Text        = Color3.fromRGB(240, 240, 245), -- ข้อความหลัก
    TextDark    = Color3.fromRGB(160, 160, 175), -- ข้อความรอง
    -- ...
}
```

---

## 🐛 การแก้ปัญหา

**GUI ไม่โชว์หลัง spawn ใหม่**
→ ตั้งค่า `ResetOnSpawn = false` ไว้แล้ว ✅ ถ้ายังเป็น — ใส่ script ใน `StarterPlayerScripts`

**Callback error ไม่ทำให้ script หยุด**
→ ทุก callback ใช้ `pcall()` แล้ว ดู output ใน developer console

**Notification ไม่ขึ้น**
→ ต้องเรียก `CreateWindow()` ก่อนถึงจะเรียก `Notify()` ได้

---
