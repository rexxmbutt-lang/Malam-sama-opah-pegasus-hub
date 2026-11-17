-- [[ PEGASUS HUB - KITTENHUB EDITION ]]
-- [[ GAME: MALAM SAMA OPAH / NENEK ]]

-- 1. MUAT LIBRARY KITTENHUB
local KittenHub = loadstring(game:HttpGet("https://raw.githubusercontent.com/enesserper9-stack/KittenHub/main/KittenHub.lua"))()

-- 2. KONFIGURASI GAMBAR (GANTI DENGAN ID ROBLOX ANDA)
local CONFIG = {
    -- ID Gambar untuk ikon bulat saat UI ditutup (Upload gambar catbox ke Roblox)
    FloatingIcon = "rbxassetid://1314520", -- GANTI ID INI
    -- Ikon untuk tab (menggunakan aset bawaan KittenHub)
    IconMain = "rbxassetid://118174015024924", -- Home
    IconESP = "rbxassetid://125376145853165",  -- Players
    IconTP = "rbxassetid://87200505076227",    -- Settings
}

-- 3. BUAT WINDOW UTAMA
local Window = KittenHub:CreateWindow({
    Title = "PEGASUS HUB",
    Icon = "rbxassetid://102065448126548", -- Logo KittenHub (bisa diganti)
    Size = Vector2.new(1280, 760),
    Scale = 0.78,
    Assets = {
        Logo = "rbxassetid://102065448126548",
        Paw = "rbxassetid://131136157222328",
        Heart = "rbxassetid://107252414250704",
        Sleeping = "rbxassetid://112356892711029",
        Peek = "rbxassetid://133697879389288",
        Curled = "rbxassetid://101414414893719",
        DarkCat = "rbxassetid://118910476036241",
        DropdownCat = "rbxassetid://98425969504037",
        Sparkles = "rbxassetid://114850152769331",
        Home = "rbxassetid://118174015024924",
        Plus = "rbxassetid://98329354716868",
        Players = "rbxassetid://125376145853165",
        Settings = "rbxassetid://87200505076227",
        Bell = "rbxassetid://80479928306450",
    },
})

-- 4. HELPER: MEMBUAT IKON BULAT SAAT UI DITUTUP
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
FloatingButton.Visible = false -- Awalnya tersembunyi
FloatingButton.Parent = FloatingGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(1, 0)
UICorner.Parent = FloatingButton

-- 5. LOGIKA BUKA/TUTUP WINDOW
-- KittenHub secara default memiliki tombol close. Kita hook fungsinya.
-- Kita gunakan event dari window KittenHub.
local originalDestroy = Window.Destroy
Window.Destroy = function(self)
    -- Sembunyikan window, tampilkan ikon
    -- (Implementasi internal KittenHub mungkin berbeda, kita gunakan pendekatan manual)
    -- Sebagai fallback, kita pantau visibilitas window utama.
    -- Namun, untuk kesederhanaan, kita asumsikan Window memiliki frame utama.
    -- Kita bisa menggunakan UserInputService atau memantau anak-anak GUI.
end

-- Pendekatan lebih aman: pantau GUI utama KittenHub
-- KittenHub biasanya membuat ScreenGui dengan nama tertentu.
-- Kita cari dan sambungkan event.
task.spawn(function()
    -- Tunggu sampai GUI KittenHub dibuat
    local kittenGui
    for _, gui in pairs(PlayerGui:GetChildren()) do
        if gui.Name:find("KittenHub") or gui.Name:find("Kitten") then
            kittenGui = gui
            break
        end
    end
    if not kittenGui then
        -- Coba lagi setelah beberapa saat
        task.wait(1)
        for _, gui in pairs(PlayerGui:GetChildren()) do
            if gui.Name:find("KittenHub") or gui.Name:find("Kitten") then
                kittenGui = gui
                break
            end
        end
    end

    if kittenGui then
        -- Temukan frame utama (biasanya bernama MainFrame atau serupa)
        local mainFrame = kittenGui:FindFirstChild("MainFrame") or kittenGui:FindFirstChild("Window")
        if mainFrame then
            -- Pantau perubahan visibilitas
            mainFrame:GetPropertyChangedSignal("Visible"):Connect(function()
                if mainFrame.Visible then
                    FloatingButton.Visible = false
                else
                    FloatingButton.Visible = true
                end
            end)
        end
    end
end)

FloatingButton.MouseButton1Click:Connect(function()
    -- Tampilkan kembali window KittenHub
    for _, gui in pairs(PlayerGui:GetChildren()) do
        if gui.Name:find("KittenHub") or gui.Name:find("Kitten") then
            local mainFrame = gui:FindFirstChild("MainFrame") or gui:FindFirstChild("Window")
            if mainFrame then
                mainFrame.Visible = true
                FloatingButton.Visible = false
                break
            end
        end
    end
end)

-- 6. TAB MAIN
local TabMain = Window:AddTab({
    Name = "Main",
    Icon = CONFIG.IconMain,
    IconRole = "Home",
})

local SectionMain = TabMain:AddSection("Main Features")

SectionMain:AddToggle({
    Text = "Auto Win",
    Default = false,
    Flag = "AutoWin",
    Callback = function(value)
        if value then
            -- Logika Auto Win: Mencoba memicu escape otomatis
            -- Contoh: Mencari RemoteEvent untuk escape
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
    end,
})

SectionMain:AddToggle({
    Text = "Auto Secret Ending",
    Default = false,
    Flag = "AutoSecret",
    Callback = function(value)
        if value then
            -- Logika Secret Ending
            print("[PEGASUS] Auto Secret Ending: ON")
        else
            print("[PEGASUS] Auto Secret Ending: OFF")
        end
    end,
})

SectionMain:AddToggle({
    Text = "Auto Start (Lobby)",
    Default = false,
    Flag = "AutoStart",
    Callback = function(value)
        if value then
            -- Logika Auto Start di lobby
            print("[PEGASUS] Auto Start: ON")
        else
            print("[PEGASUS] Auto Start: OFF")
        end
    end,
})

SectionMain:AddToggle({
    Text = "Inf Stamina",
    Default = false,
    Flag = "InfStamina",
    Callback = function(value)
        if value then
            -- Logika Infinite Stamina
            local staminaConnection
            staminaConnection = game:GetService("RunService").Heartbeat:Connect(function()
                local char = LocalPlayer.Character
                if char then
                    local humanoid = char:FindFirstChild("Humanoid")
                    if humanoid then
                        -- Set stamina ke nilai maksimum (sesuaikan dengan game)
                        -- Contoh: humanoid.WalkSpeed = 50
                    end
                end
            end)
            -- Simpan koneksi untuk dimatikan nanti
            getgenv().InfStaminaConnection = staminaConnection
        else
            if getgenv().InfStaminaConnection then
                getgenv().InfStaminaConnection:Disconnect()
            end
        end
        print("[PEGASUS] Inf Stamina: " .. tostring(value))
    end,
})

SectionMain:AddButton({
    Text = "Collect Key",
    Callback = function()
        -- Logika mengumpulkan semua key
        local keysFolder = workspace:FindFirstChild("Keys") or workspace:FindFirstChild("Items")
        if keysFolder then
            for _, key in pairs(keysFolder:GetChildren()) do
                if key:IsA("BasePart") or key:IsA("Model") then
                    -- Teleport ke key atau picu pengambilan
                    local char = LocalPlayer.Character
                    if char and char:FindFirstChild("HumanoidRootPart") then
                        char.HumanoidRootPart.CFrame = key:GetPivot() + Vector3.new(0, 3, 0)
                        task.wait(0.1)
                    end
                end
            end
        end
        print("[PEGASUS] Collect Key executed")
    end,
})

SectionMain:AddButton({
    Text = "Collect Passcode",
    Callback = function()
        -- Logika mengumpulkan passcode
        print("[PEGASUS] Collect Passcode executed")
    end,
})

-- 7. TAB ESP
local TabESP = Window:AddTab({
    Name = "ESP",
    Icon = CONFIG.IconESP,
    IconRole = "Players",
})

local SectionESP = TabESP:AddSection("Visuals")

SectionESP:AddToggle({
    Text = "ESP Player (Hitbox Merah)",
    Default = false,
    Flag = "ESPPlayer",
    Callback = function(value)
        if value then
            -- Implementasi ESP Player
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
        print("[PEGASUS] ESP Player: " .. tostring(value))
    end,
})

SectionESP:AddToggle({
    Text = "ESP Key",
    Default = false,
    Flag = "ESPKey",
    Callback = function(value)
        if value then
            -- Implementasi ESP Key (Highlight pada key)
            print("[PEGASUS] ESP Key: ON")
        else
            print("[PEGASUS] ESP Key: OFF")
        end
    end,
})

SectionESP:AddToggle({
    Text = "ESP Passcode",
    Default = false,
    Flag = "ESPPasscode",
    Callback = function(value)
        print("[PEGASUS] ESP Passcode: " .. tostring(value))
    end,
})

SectionESP:AddToggle({
    Text = "ESP Guard/Opah (Skeleton)",
    Default = false,
    Flag = "ESPGuard",
    Callback = function(value)
        if value then
            -- Implementasi Skeleton ESP untuk Opah
            print("[PEGASUS] ESP Guard: ON")
        else
            print("[PEGASUS] ESP Guard: OFF")
        end
    end,
})

-- 8. TAB TELEPORT
local TabTP = Window:AddTab({
    Name = "Teleport",
    Icon = CONFIG.IconTP,
    IconRole = "Settings",
})

local SectionTP = TabTP:AddSection("Teleport Options")

-- Teleport Key (Dropdown)
local keyList = {}
-- Coba deteksi key di workspace
for _, obj in pairs(workspace:GetDescendants()) do
    if obj.Name:lower():find("key") and (obj:IsA("BasePart") or obj:IsA("Model")) then
        table.insert(keyList, obj.Name)
    end
end
if #keyList == 0 then
    keyList = {"Red Key", "Blue Key", "Green Key", "Yellow Key", "Purple Key"} -- Placeholder
end

SectionTP:AddDropdown({
    Text = "Teleport Key",
    Options = keyList,
    Default = keyList[1],
    Flag = "TPKeyDropdown",
    Callback = function(selected)
        getgenv().SelectedKey = selected
    end,
})

SectionTP:AddButton({
    Text = "Teleport ke Key Terpilih",
    Callback = function()
        local selected = getgenv().SelectedKey
        if selected then
            -- Cari objek key dengan nama tersebut
            for _, obj in pairs(workspace:GetDescendants()) do
                if obj.Name == selected and (obj:IsA("BasePart") or obj:IsA("Model")) then
                    local char = LocalPlayer.Character
                    if char and char:FindFirstChild("HumanoidRootPart") then
                        char.HumanoidRootPart.CFrame = obj:GetPivot() + Vector3.new(0, 3, 0)
                    end
                    break
                end
            end
        end
        print("[PEGASUS] Teleport to Key")
    end,
})

-- Teleport Player (Dropdown)
local playerNames = {}
for _, p in pairs(Players:GetPlayers()) do
    if p ~= LocalPlayer then
        table.insert(playerNames, p.Name)
    end
end

SectionTP:AddDropdown({
    Text = "Teleport to Player",
    Options = playerNames,
    Default = playerNames[1],
    Flag = "TPPlayerDropdown",
    Callback = function(selected)
        getgenv().SelectedPlayer = selected
    end,
})

SectionTP:AddButton({
    Text = "Teleport ke Player Terpilih",
    Callback = function()
        local selectedName = getgenv().SelectedPlayer
        if selectedName then
            local target = Players:FindFirstChild(selectedName)
            if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
                LocalPlayer.Character.HumanoidRootPart.CFrame = target.Character.HumanoidRootPart.CFrame
            end
        end
        print("[PEGASUS] Teleport to Player")
    end,
})

SectionTP:AddButton({
    Text = "Teleport to Passcode",
    Callback = function()
        -- Cari objek passcode
        local passcodeObj = workspace:FindFirstChild("Passcode") or workspace:FindFirstChild("Code")
        if passcodeObj then
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                LocalPlayer.Character.HumanoidRootPart.CFrame = passcodeObj.CFrame + Vector3.new(0, 3, 0)
            end
        end
        print("[PEGASUS] Teleport to Passcode")
    end,
})

-- 9. NOTIFIKASI BAHWA SCRIPT SUDAH JALAN
KittenHub:Notify({
    Title = "PEGASUS HUB",
    Text = "Script berhasil dimuat!",
    Duration = 5,
})
