-- [[ PEGASUS HUB - MALAM SAMA OPAH / NENEK ]]
-- [[ CREATED BY: AI ASSISTANT ]]
-- [[ VERSION: 1.0.0 ]]

-- [ LAYANAN ]
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")

-- [ VARIABEL LOKAL ]
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local Camera = Workspace.CurrentCamera

-- [ KONFIGURASI GAME (SESUAIKAN DENGAN GAME ANDA) ]
local GameConfig = {
    Remotes = ReplicatedStorage:WaitForChild("Remotes"), -- Ganti dengan folder remote yang benar
    KeysFolder = Workspace:WaitForChild("Keys"), -- Ganti dengan folder tempat key berada
    PasscodeObject = Workspace:WaitForChild("Passcode"), -- Ganti dengan objek passcode
    GuardNPC = Workspace:WaitForChild("Opah"), -- Ganti dengan nama NPC Opah/Nenek
    AutoWinEvent = "AutoWin", -- Ganti dengan nama Remote Event untuk Auto Win
    AutoSecretEvent = "SecretEnding", -- Ganti dengan nama Remote Event untuk Secret Ending
    CollectKeyEvent = "CollectKey", -- Ganti dengan nama Remote Event untuk collect key
    CollectPasscodeEvent = "CollectPasscode", -- Ganti dengan nama Remote Event untuk collect passcode
}

-- [ STATE ]
local PegasusHub = {
    Enabled = true,
    Tabs = {},
    Features = {},
    ESP = {},
    Teleport = {},
    Connections = {},
}

-- [ FUNGSI UTILITAS ]
local function Create(instanceType, properties)
    local inst = Instance.new(instanceType)
    for k, v in pairs(properties) do
        inst[k] = v
    end
    return inst
end

local function Notify(title, text)
    -- Implementasi notifikasi (bisa menggunakan StarterGui:SetCore)
    print("[PEGASUS HUB] " .. title .. ": " .. text)
end

-- [ MEMBUAT UI ]
local function CreateUI()
    local ScreenGui = Create("ScreenGui", {
        Name = "PegasusHubUI",
        Parent = PlayerGui,
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    })

    -- Frame Utama
    local MainFrame = Create("Frame", {
        Name = "MainFrame",
        Parent = ScreenGui,
        Size = UDim2.new(0, 600, 0, 400),
        Position = UDim2.new(0.5, -300, 0.5, -200),
        BackgroundColor3 = Color3.fromRGB(20, 20, 20),
        BorderSizePixel = 0,
        ClipsDescendants = true
    })

    -- Sudut Membulat
    Create("UICorner", { CornerRadius = UDim.new(0, 8), Parent = MainFrame })

    -- Sidebar Kiri
    local Sidebar = Create("Frame", {
        Name = "Sidebar",
        Parent = MainFrame,
        Size = UDim2.new(0, 150, 1, 0),
        BackgroundColor3 = Color3.fromRGB(25, 25, 25),
        BorderSizePixel = 0
    })

    -- Badge / Logo (Menggunakan Gambar Kedua)
    local BadgeImage = Create("ImageLabel", {
        Name = "Badge",
        Parent = Sidebar,
        Size = UDim2.new(0, 40, 0, 40),
        Position = UDim2.new(0, 10, 0, 10),
        BackgroundTransparency = 1,
        Image = "rbxassetid://YOUR_IMAGE_ID_HERE", -- Ganti dengan ID gambar kedua Anda
        ScaleType = Enum.ScaleType.Fit
    })

    -- Judul
    local Title = Create("TextLabel", {
        Name = "Title",
        Parent = Sidebar,
        Size = UDim2.new(1, -20, 0, 30),
        Position = UDim2.new(0, 60, 0, 15),
        BackgroundTransparency = 1,
        Text = "PEGASUS HUB",
        TextColor3 = Color3.fromRGB(255, 255, 255),
        Font = Enum.Font.GothamBold,
        TextSize = 16,
        TextXAlignment = Enum.TextXAlignment.Left
    })

    -- Search Bar (Opsional)
    local SearchBar = Create("TextBox", {
        Name = "Search",
        Parent = Sidebar,
        Size = UDim2.new(1, -20, 0, 30),
        Position = UDim2.new(0, 10, 0, 60),
        BackgroundColor3 = Color3.fromRGB(40, 40, 40),
        TextColor3 = Color3.fromRGB(200, 200, 200),
        PlaceholderText = "Search...",
        Font = Enum.Font.Gotham,
        TextSize = 12,
        ClearTextOnFocus = false
    })
    Create("UICorner", { CornerRadius = UDim.new(0, 4), Parent = SearchBar })

    -- Tombol Tab
    local TabContainer = Create("Frame", {
        Name = "Tabs",
        Parent = Sidebar,
        Size = UDim2.new(1, 0, 1, -100),
        Position = UDim2.new(0, 0, 0, 100),
        BackgroundTransparency = 1
    })

    local TabList = {
        { Name = "Main", Icon = "🏠" },
        { Name = "ESP", Icon = "👁️" },
        { Name = "Teleport", Icon = "📍" }
    }

    local function CreateTabButton(tabData, yOffset)
        local Btn = Create("TextButton", {
            Name = tabData.Name .. "Tab",
            Parent = TabContainer,
            Size = UDim2.new(1, -20, 0, 30),
            Position = UDim2.new(0, 10, 0, yOffset),
            BackgroundColor3 = Color3.fromRGB(40, 40, 40),
            Text = tabData.Icon .. " " .. tabData.Name,
            TextColor3 = Color3.fromRGB(200, 200, 200),
            Font = Enum.Font.Gotham,
            TextSize = 12,
            TextXAlignment = Enum.TextXAlignment.Left
        })
        Create("UICorner", { CornerRadius = UDim.new(0, 4), Parent = Btn })
        return Btn
    end

    for i, tabData in ipairs(TabList) do
        local btn = CreateTabButton(tabData, (i - 1) * 35)
        btn.MouseButton1Click:Connect(function()
            -- Logika ganti tab
            print("Tab " .. tabData.Name .. " diklik")
        end)
    end

    -- Konten Utama (Kanan)
    local Content = Create("Frame", {
        Name = "Content",
        Parent = MainFrame,
        Size = UDim2.new(1, -150, 1, 0),
        Position = UDim2.new(0, 150, 0, 0),
        BackgroundColor3 = Color3.fromRGB(30, 30, 30),
        BorderSizePixel = 0
    })

    -- Judul Konten
    local ContentTitle = Create("TextLabel", {
        Name = "ContentTitle",
        Parent = Content,
        Size = UDim2.new(1, -20, 0, 40),
        Position = UDim2.new(0, 10, 0, 10),
        BackgroundTransparency = 1,
        Text = "Main",
        TextColor3 = Color3.fromRGB(255, 255, 255),
        Font = Enum.Font.GothamBold,
        TextSize = 18,
        TextXAlignment = Enum.TextXAlignment.Left
    })

    -- Tombol Close
    local CloseBtn = Create("TextButton", {
        Name = "CloseBtn",
        Parent = MainFrame,
        Size = UDim2.new(0, 30, 0, 30),
        Position = UDim2.new(1, -35, 0, 5),
        BackgroundColor3 = Color3.fromRGB(200, 50, 50),
        Text = "−",
        TextColor3 = Color3.fromRGB(255, 255, 255),
        Font = Enum.Font.GothamBold,
        TextSize = 18
    })
    Create("UICorner", { CornerRadius = UDim.new(0, 4), Parent = CloseBtn })

    -- Badge Bulat saat Close
    local FloatingBadge = Create("ImageButton", {
        Name = "FloatingBadge",
        Parent = ScreenGui,
        Size = UDim2.new(0, 50, 0, 50),
        Position = UDim2.new(0, 20, 0.5, -25),
        BackgroundTransparency = 1,
        Image = "rbxassetid://YOUR_IMAGE_ID_HERE",
        Visible = false
    })
    Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = FloatingBadge })

    -- Logika Buka/Tutup
    CloseBtn.MouseButton1Click:Connect(function()
        MainFrame.Visible = false
        FloatingBadge.Visible = true
    end)

    FloatingBadge.MouseButton1Click:Connect(function()
        MainFrame.Visible = true
        FloatingBadge.Visible = false
    end)

    return ScreenGui
end

-- [ FITUR UTAMA ]
local function SetupMainFeatures()
    -- 1. Auto Win
    PegasusHub.Features.AutoWin = function(state)
        if state then
            -- Implementasi: Panggil remote event atau manipulasi nilai
            Notify("Auto Win", "Diaktifkan")
        else
            Notify("Auto Win", "Dinonaktifkan")
        end
    end

    -- 2. Auto Secret Ending
    PegasusHub.Features.AutoSecret = function(state)
        if state then
            Notify("Auto Secret Ending", "Diaktifkan")
        else
            Notify("Auto Secret Ending", "Dinonaktifkan")
        end
    end

    -- 3. Auto Start
    PegasusHub.Features.AutoStart = function(state)
        if state then
            Notify("Auto Start", "Diaktifkan")
        else
            Notify("Auto Start", "Dinonaktifkan")
        end
    end

    -- 4. Inf Stamina
    PegasusHub.Features.InfStamina = function(state)
        if state then
            Notify("Inf Stamina", "Diaktifkan")
            -- Loop untuk menjaga stamina
            PegasusHub.Connections.InfStamina = RunService.Heartbeat:Connect(function()
                -- Set stamina ke nilai maksimum
            end)
        else
            Notify("Inf Stamina", "Dinonaktifkan")
            if PegasusHub.Connections.InfStamina then
                PegasusHub.Connections.InfStamina:Disconnect()
            end
        end
    end

    -- 5. Collect Key
    PegasusHub.Features.CollectKey = function()
        Notify("Collect Key", "Mengumpulkan semua key...")
        -- Implementasi: Loop melalui folder Keys dan panggil remote
    end

    -- 6. Collect Passcode
    PegasusHub.Features.CollectPasscode = function()
        Notify("Collect Passcode", "Mengumpulkan passcode...")
        -- Implementasi: Panggil remote atau manipulasi nilai
    end
end

-- [ FITUR ESP ]
local function SetupESP()
    -- ESP Player
    PegasusHub.ESP.Player = function(state)
        if state then
            Notify("ESP Player", "Diaktifkan")
            -- Loop untuk membuat ESP
        else
            Notify("ESP Player", "Dinonaktifkan")
            -- Hapus ESP
        end
    end

    -- ESP Key
    PegasusHub.ESP.Key = function(state)
        if state then
            Notify("ESP Key", "Diaktifkan")
            -- Loop untuk menampilkan key
        else
            Notify("ESP Key", "Dinonaktifkan")
        end
    end

    -- ESP Passcode
    PegasusHub.ESP.Passcode = function(state)
        if state then
            Notify("ESP Passcode", "Diaktifkan")
        else
            Notify("ESP Passcode", "Dinonaktifkan")
        end
    end

    -- ESP Guard (Opah/Nenek)
    PegasusHub.ESP.Guard = function(state)
        if state then
            Notify("ESP Guard", "Diaktifkan")
            -- Implementasi: Skeleton ESP
        else
            Notify("ESP Guard", "Dinonaktifkan")
        end
    end
end

-- [ FITUR TELEPORT ]
local function SetupTeleport()
    -- Teleport Key
    PegasusHub.Teleport.Key = function(keyName)
        Notify("Teleport Key", "Teleport ke " .. keyName)
        -- Implementasi: Set HumanoidRootPart ke posisi key
    end

    -- Teleport to Player
    PegasusHub.Teleport.Player = function(playerName)
        Notify("Teleport Player", "Teleport ke " .. playerName)
        -- Implementasi: Set HumanoidRootPart ke posisi player
    end

    -- Teleport to Passcode
    PegasusHub.Teleport.Passcode = function()
        Notify("Teleport Passcode", "Teleport ke passcode")
        -- Implementasi: Set HumanoidRootPart ke posisi passcode
    end
end

-- [ INISIALISASI ]
local function Initialize()
    CreateUI()
    SetupMainFeatures()
    SetupESP()
    SetupTeleport()
    Notify("PEGASUS HUB", "Berhasil dimuat!")
end

-- [ EKSEKUSI ]
Initialize()
