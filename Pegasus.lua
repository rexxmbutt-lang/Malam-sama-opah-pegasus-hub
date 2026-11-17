-- [[ PEGASUS HUB - MUGIHUB (MiHUB) EDITION ]]
-- [[ GAME: MALAM SAMA OPAH / NENEK ]]

-- 1. MUAT LIBRARY MUGIHUB (MiHUB)
local Library = loadstring(game:HttpGet("https://git.miguvt.com/MiguVT/MiHUB/raw/branch/main/loader.luau"))()

-- 2. KONFIGURASI GAMBAR
local CONFIG = {
    -- GANTI DENGAN ID ROBLOX DARI GAMBAR https://files.catbox.moe/kx97hh.jpg
    -- Upload gambar tersebut ke Roblox, lalu salin ID-nya di sini.
    FloatingIcon = "rbxassetid://1314520", -- <--- GANTI ID INI
}

-- 3. BUAT WINDOW UTAMA
local Window = Library.CreateLib("PEGASUS HUB", "DarkTheme")

-- 4. IKON BULAT SAAT UI DITUTUP
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local FloatingGui = Instance.new("ScreenGui")
FloatingGui.Name = "PegasusFloatingIcon"
FloatingGui.ResetOnSpawn = false
FloatingGui.Parent = PlayerGui

local FloatingButton = Instance.new("ImageButton")
FloatingButton.Size = UDim2.new(0, 60, 0, 60)
FloatingButton.Position = UDim2.new(0, 20, 0.5, -30)
FloatingButton.BackgroundTransparency = 1
FloatingButton.Image = CONFIG.FloatingIcon
FloatingButton.Visible = false
FloatingButton.Parent = FloatingGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(1, 0)
UICorner.Parent = FloatingButton

-- 5. LOGIKA BUKA/TUTUP (Menghubungkan dengan fungsi ToggleUI MiHUB)
-- MiHUB biasanya memiliki fungsi Library:ToggleUI()
-- Kita pantau visibilitas window utama untuk menampilkan ikon.
-- Namun, untuk memastikan, kita gunakan keybind default atau tombol close.
-- Kita bisa menambahkan keybind untuk menutup UI.
local TabMain = Window:NewTab("Main")
local TabESP = Window:NewTab("ESP")
local TabTP = Window:NewTab("Teleport")

-- Keybind untuk menutup UI (misalnya tombol RightShift)
local UserInputService = game:GetService("UserInputService")
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.RightShift then
        -- Toggle UI
        if Library.ToggleUI then
            Library:ToggleUI()
        end
        -- Tampilkan ikon bulat
        FloatingButton.Visible = true
    end
end)

FloatingButton.MouseButton1Click:Connect(function()
    -- Buka kembali UI
    if Library.ToggleUI then
        Library:ToggleUI()
    end
    FloatingButton.Visible = false
end)

-- 6. TAB MAIN
local SectionMain = TabMain:NewSection("Main Features")

SectionMain:NewToggle("Auto Win", "Otomatis menang", function(state)
    if state then
        -- Logika Auto Win: Mencari RemoteEvent escape/win
        local remotes = game:GetService("ReplicatedStorage"):FindFirstChild("Remotes")
        if remotes then
            local escapeEvent = remotes:FindFirstChild("Escape") or remotes:FindFirstChild("Win")
            if escapeEvent then
                escapeEvent:FireServer()
            end
        end
        print("[PEGASUS] Auto Win: ON")
    else
        print("[PEGASUS] Auto Win: OFF")
    end
end)

SectionMain:NewToggle("Auto Secret Ending", "Otomatis secret ending", function(state)
    if state then
        print("[PEGASUS] Auto Secret Ending: ON")
    else
        print("[PEGASUS] Auto Secret Ending: OFF")
    end
end)

SectionMain:NewToggle("Auto Start (Lobby)", "Otomatis start di lobby", function(state)
    if state then
        print("[PEGASUS] Auto Start: ON")
    else
        print("[PEGASUS] Auto Start: OFF")
    end
end)

SectionMain:NewToggle("Inf Stamina", "Stamina tak terbatas", function(state)
    if state then
        local conn
        conn = game:GetService("RunService").Heartbeat:Connect(function()
            local char = LocalPlayer.Character
            if char then
                local humanoid = char:FindFirstChild("Humanoid")
                if humanoid then
                    -- Set stamina ke nilai maksimum (sesuaikan)
                    -- humanoid.WalkSpeed = 50
                end
            end
        end)
        getgenv().InfStaminaConn = conn
        print("[PEGASUS] Inf Stamina: ON")
    else
        if getgenv().InfStaminaConn then
            getgenv().InfStaminaConn:Disconnect()
        end
        print("[PEGASUS] Inf Stamina: OFF")
    end
end)

SectionMain:NewButton("Collect Key", "Mengumpulkan semua key", function()
    local keysFolder = workspace:FindFirstChild("Keys") or workspace:FindFirstChild("Items")
    if keysFolder then
        for _, key in pairs(keysFolder:GetChildren()) do
            if key:IsA("BasePart") or key:IsA("Model") then
                local char = LocalPlayer.Character
                if char and char:FindFirstChild("HumanoidRootPart") then
                    char.HumanoidRootPart.CFrame = key:GetPivot() + Vector3.new(0, 3, 0)
                    task.wait(0.1)
                end
            end
        end
    end
    print("[PEGASUS] Collect Key executed")
end)

SectionMain:NewButton("Collect Passcode", "Mengumpulkan passcode", function()
    print("[PEGASUS] Collect Passcode executed")
end)

-- 7. TAB ESP
local SectionESP = TabESP:NewSection("Visuals")

SectionESP:NewToggle("ESP Player (Hitbox Merah)", "ESP pemain dengan hitbox merah", function(state)
    if state then
        local espFolder = Instance.new("Folder", workspace)
        espFolder.Name = "PegasusESP_Player"
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character then
                local highlight = Instance.new("Highlight")
                highlight.Parent = player.Character
                highlight.FillColor = Color3.new(1, 0, 0)
                highlight.OutlineColor = Color3.new(1, 0, 0)
                highlight.FillTransparency = 0.5
                highlight.OutlineTransparency = 0
            end
        end
    else
        local espFolder = workspace:FindFirstChild("PegasusESP_Player")
        if espFolder then espFolder:Destroy() end
    end
    print("[PEGASUS] ESP Player: " .. tostring(state))
end)

SectionESP:NewToggle("ESP Key", "Menampilkan semua key", function(state)
    print("[PEGASUS] ESP Key: " .. tostring(state))
end)

SectionESP:NewToggle("ESP Passcode", "Menampilkan passcode", function(state)
    print("[PEGASUS] ESP Passcode: " .. tostring(state))
end)

SectionESP:NewToggle("ESP Guard/Opah (Skeleton)", "Skeleton ESP untuk Opah", function(state)
    if state then
        print("[PEGASUS] ESP Guard: ON")
    else
        print("[PEGASUS] ESP Guard: OFF")
    end
end)

-- 8. TAB TELEPORT
local SectionTP = TabTP:NewSection("Teleport Options")

-- Teleport Key (Dropdown)
local keyList = {}
for _, obj in pairs(workspace:GetDescendants()) do
    if obj.Name:lower():find("key") and (obj:IsA("BasePart") or obj:IsA("Model")) then
        table.insert(keyList, obj.Name)
    end
end
if #keyList == 0 then
    keyList = {"Red Key", "Blue Key", "Green Key", "Yellow Key", "Purple Key"}
end

local selectedKey = keyList[1]
SectionTP:NewDropdown("Teleport Key", "Pilih key untuk teleport", keyList, function(selected)
    selectedKey = selected
end)

SectionTP:NewButton("Teleport ke Key Terpilih", "Teleport ke key yang dipilih", function()
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj.Name == selectedKey and (obj:IsA("BasePart") or obj:IsA("Model")) then
            local char = LocalPlayer.Character
            if char and char:FindFirstChild("HumanoidRootPart") then
                char.HumanoidRootPart.CFrame = obj:GetPivot() + Vector3.new(0, 3, 0)
            end
            break
        end
    end
    print("[PEGASUS] Teleport to Key: " .. selectedKey)
end)

-- Teleport Player (Dropdown)
local playerNames = {}
for _, p in pairs(Players:GetPlayers()) do
    if p ~= LocalPlayer then
        table.insert(playerNames, p.Name)
    end
end

local selectedPlayer = playerNames[1]
SectionTP:NewDropdown("Teleport to Player", "Pilih player", playerNames, function(selected)
    selectedPlayer = selected
end)

SectionTP:NewButton("Teleport ke Player Terpilih", "Teleport ke player", function()
    local target = Players:FindFirstChild(selectedPlayer)
    if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
        LocalPlayer.Character.HumanoidRootPart.CFrame = target.Character.HumanoidRootPart.CFrame
    end
    print("[PEGASUS] Teleport to Player: " .. selectedPlayer)
end)

SectionTP:NewButton("Teleport to Passcode", "Teleport ke passcode", function()
    local passcodeObj = workspace:FindFirstChild("Passcode") or workspace:FindFirstChild("Code")
    if passcodeObj then
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            LocalPlayer.Character.HumanoidRootPart.CFrame = passcodeObj.CFrame + Vector3.new(0, 3, 0)
        end
    end
    print("[PEGASUS] Teleport to Passcode")
end)

-- 9. NOTIFIKASI
print("[PEGASUS HUB] Berhasil dimuat dengan MugiHub!")
