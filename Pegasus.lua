-- [[ PEGASUS HUB - MALAM SAMA OPAH / NENEK ]]
-- [[ VERSI PERBAIKAN - UI & FITUR DASAR ]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local Camera = Workspace.CurrentCamera

-- ================= KONFIGURASI GAMBAR =================
-- GANTI ANGKA DI BAWAH INI DENGAN ID GAMBAR BULAT YANG ANDA KIRIM
local BADGE_IMAGE_ID = "rbxassetid://1314520" -- <--- GANTI ID INI
-- ======================================================

-- State Aplikasi
local PegasusHub = {
    Tabs = {},
    ActiveTab = "Main",
    Connections = {},
    ESPObjects = {},
    Toggles = {}
}

-- Fungsi Bantuan untuk Membuat UI
local function Create(instanceType, properties)
    local inst = Instance.new(instanceType)
    for k, v in pairs(properties) do
        inst[k] = v
    end
    return inst
end

-- Fungsi Notifikasi (Bisa diganti dengan sistem notifikasi executor)
local function Notify(title, text)
    print("[PEGASUS HUB] " .. title .. ": " .. text)
    -- Implementasi notifikasi visual bisa ditambahkan di sini
end

-- ================= MEMBUAT UI =================
local function CreateUI()
    local ScreenGui = Create("ScreenGui", {
        Name = "PegasusHubUI",
        Parent = PlayerGui,
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        DisplayOrder = 999
    })

    -- Frame Utama
    local MainFrame = Create("Frame", {
        Name = "MainFrame",
        Parent = ScreenGui,
        Size = UDim2.new(0, 650, 0, 420),
        Position = UDim2.new(0.5, -325, 0.5, -210),
        BackgroundColor3 = Color3.fromRGB(15, 15, 15),
        BorderSizePixel = 0,
    })
    Create("UICorner", { CornerRadius = UDim.new(0, 8), Parent = MainFrame })
    Create("UIStroke", { Color = Color3.fromRGB(50, 50, 50), Thickness = 1, Parent = MainFrame })

    -- Sidebar Kiri
    local Sidebar = Create("Frame", {
        Name = "Sidebar",
        Parent = MainFrame,
        Size = UDim2.new(0, 160, 1, 0),
        BackgroundColor3 = Color3.fromRGB(20, 20, 20),
        BorderSizePixel = 0
    })
    Create("UICorner", { CornerRadius = UDim.new(0, 8), Parent = Sidebar })
    -- Menutupi sudut kanan sidebar agar lurus
    Create("Frame", {
        Parent = Sidebar,
        Size = UDim2.new(0, 10, 1, 0),
        Position = UDim2.new(1, -10, 0, 0),
        BackgroundColor3 = Color3.fromRGB(20, 20, 20),
        BorderSizePixel = 0
    })

    -- Badge / Logo di Sidebar
    local BadgeImage = Create("ImageLabel", {
        Name = "Badge",
        Parent = Sidebar,
        Size = UDim2.new(0, 40, 0, 40),
        Position = UDim2.new(0, 10, 0, 15),
        BackgroundTransparency = 1,
        Image = BADGE_IMAGE_ID,
        ScaleType = Enum.ScaleType.Fit
    })
    Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = BadgeImage })

    -- Judul
    local Title = Create("TextLabel", {
        Name = "Title",
        Parent = Sidebar,
        Size = UDim2.new(1, -60, 0, 30),
        Position = UDim2.new(0, 60, 0, 20),
        BackgroundTransparency = 1,
        Text = "PEGASUS HUB",
        TextColor3 = Color3.fromRGB(255, 255, 255),
        Font = Enum.Font.GothamBold,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left
    })

    -- Container Tombol Tab
    local TabContainer = Create("Frame", {
        Name = "Tabs",
        Parent = Sidebar,
        Size = UDim2.new(1, -20, 1, -80),
        Position = UDim2.new(0, 10, 0, 70),
        BackgroundTransparency = 1
    })
    Create("UIListLayout", { Padding = UDim.new(0, 5), Parent = TabContainer })

    local TabList = {
        { Name = "Main", Icon = "🏠" },
        { Name = "ESP", Icon = "👁️" },
        { Name = "Teleport", Icon = "📍" }
    }

    -- Tombol Tab
    for _, tabData in ipairs(TabList) do
        local Btn = Create("TextButton", {
            Name = tabData.Name .. "Tab",
            Parent = TabContainer,
            Size = UDim2.new(1, 0, 0, 35),
            BackgroundColor3 = Color3.fromRGB(30, 30, 30),
            Text = "  " .. tabData.Icon .. "  " .. tabData.Name,
            TextColor3 = Color3.fromRGB(200, 200, 200),
            Font = Enum.Font.Gotham,
            TextSize = 12,
            TextXAlignment = Enum.TextXAlignment.Left
        })
        Create("UICorner", { CornerRadius = UDim.new(0, 4), Parent = Btn })
        
        Btn.MouseButton1Click:Connect(function()
            PegasusHub.ActiveTab = tabData.Name
            for _, otherBtn in pairs(TabContainer:GetChildren()) do
                if otherBtn:IsA("TextButton") then
                    otherBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
                    otherBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
                end
            end
            Btn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
            Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
            -- Trigger update content
            PegasusHub.UpdateContent(tabData.Name)
        end)
    end

    -- Konten Utama (Kanan)
    local Content = Create("Frame", {
        Name = "Content",
        Parent = MainFrame,
        Size = UDim2.new(1, -160, 1, 0),
        Position = UDim2.new(0, 160, 0, 0),
        BackgroundColor3 = Color3.fromRGB(22, 22, 22),
        BorderSizePixel = 0
    })
    Create("UICorner", { CornerRadius = UDim.new(0, 8), Parent = Content })

    -- Judul Konten (Dinamis)
    local ContentTitle = Create("TextLabel", {
        Name = "ContentTitle",
        Parent = Content,
        Size = UDim2.new(1, -20, 0, 40),
        Position = UDim2.new(0, 10, 0, 10),
        BackgroundTransparency = 1,
        Text = "Survivor : Main",
        TextColor3 = Color3.fromRGB(255, 255, 255),
        Font = Enum.Font.GothamBold,
        TextSize = 16,
        TextXAlignment = Enum.TextXAlignment.Left
    })

    -- Area Scroll untuk Fitur
    local ScrollFrame = Create("ScrollingFrame", {
        Name = "ScrollFrame",
        Parent = Content,
        Size = UDim2.new(1, -20, 1, -60),
        Position = UDim2.new(0, 10, 0, 50),
        BackgroundTransparency = 1,
        ScrollBarThickness = 4,
        CanvasSize = UDim2.new(0, 0, 0, 0)
    })
    Create("UIListLayout", { Padding = UDim.new(0, 8), Parent = ScrollFrame })

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

    -- Floating Badge (Saat di-close)
    local FloatingBadge = Create("ImageButton", {
        Name = "FloatingBadge",
        Parent = ScreenGui,
        Size = UDim2.new(0, 60, 0, 60),
        Position = UDim2.new(0, 20, 0.5, -30),
        BackgroundTransparency = 1,
        Image = BADGE_IMAGE_ID,
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

    -- Fungsi Update Konten saat Tab Diklik
    PegasusHub.UpdateContent = function(tabName)
        ContentTitle.Text = "Survivor : " .. tabName
        
        -- Hapus konten lama
        for _, child in pairs(ScrollFrame:GetChildren()) do
            if not child:IsA("UIListLayout") then
                child:Destroy()
            end
        end

        -- Fitur Main
        if tabName == "Main" then
            local features = {
                "Auto Win", "Auto Secret Ending", "Auto Start (Lobby)", 
                "Inf Stamina", "Collect Key", "Collect Passcode"
            }
            for _, feat in ipairs(features) do
                PegasusHub.CreateToggle(ScrollFrame, feat, function(state)
                    Notify("Main", feat .. " = " .. tostring(state))
                    -- Logika fitur di sini
                    if feat == "Inf Stamina" then
                        if state then
                            PegasusHub.Connections.InfStamina = RunService.Heartbeat:Connect(function()
                                -- Logika stamina infinite
                            end)
                        else
                            if PegasusHub.Connections.InfStamina then
                                PegasusHub.Connections.InfStamina:Disconnect()
                            end
                        end
                    end
                end)
            end
            
        -- Fitur ESP
        elseif tabName == "ESP" then
            local features = {
                "ESP Player (Hitbox Merah)", 
                "ESP Key", 
                "ESP Passcode", 
                "ESP Guard/Opah (Skeleton)"
            }
            for _, feat in ipairs(features) do
                PegasusHub.CreateToggle(ScrollFrame, feat, function(state)
                    Notify("ESP", feat .. " = " .. tostring(state))
                    -- Logika ESP di sini (Highlight/BillboardGui)
                end)
            end

        -- Fitur Teleport
        elseif tabName == "Teleport" then
            -- Teleport Key
            local keyBtn = Create("TextButton", {
                Parent = ScrollFrame,
                Size = UDim2.new(1, 0, 0, 35),
                BackgroundColor3 = Color3.fromRGB(40, 40, 40),
                Text = "Teleport to Key (Dropdown)",
                TextColor3 = Color3.fromRGB(255, 255, 255),
                Font = Enum.Font.Gotham,
                TextSize = 12
            })
            Create("UICorner", { CornerRadius = UDim.new(0, 4), Parent = keyBtn })

            -- Teleport Player
            local playerBtn = Create("TextButton", {
                Parent = ScrollFrame,
                Size = UDim2.new(1, 0, 0, 35),
                BackgroundColor3 = Color3.fromRGB(40, 40, 40),
                Text = "Teleport to Player (Dropdown)",
                TextColor3 = Color3.fromRGB(255, 255, 255),
                Font = Enum.Font.Gotham,
                TextSize = 12
            })
            Create("UICorner", { CornerRadius = UDim.new(0, 4), Parent = playerBtn })

            -- Teleport Passcode
            local passBtn = Create("TextButton", {
                Parent = ScrollFrame,
                Size = UDim2.new(1, 0, 0, 35),
                BackgroundColor3 = Color3.fromRGB(40, 40, 40),
                Text = "Teleport to Passcode (TP)",
                TextColor3 = Color3.fromRGB(255, 255, 255),
                Font = Enum.Font.Gotham,
                TextSize = 12
            })
            Create("UICorner", { CornerRadius = UDim.new(0, 4), Parent = passBtn })
            
            passBtn.MouseButton1Click:Connect(function()
                -- Logika Teleport Passcode
                Notify("Teleport", "Mencari Passcode...")
            end)
        end
        
        -- Update Canvas Size agar scroll berfungsi
        task.wait()
        ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, #ScrollFrame:GetChildren() * 43)
    end

    -- Fungsi Helper untuk Membuat Toggle Button
    PegasusHub.CreateToggle = function(parent, text, callback)
        local toggleFrame = Create("Frame", {
            Parent = parent,
            Size = UDim2.new(1, 0, 0, 35),
            BackgroundColor3 = Color3.fromRGB(30, 30, 30),
            BorderSizePixel = 0
        })
        Create("UICorner", { CornerRadius = UDim.new(0, 4), Parent = toggleFrame })

        local label = Create("TextLabel", {
            Parent = toggleFrame,
            Size = UDim2.new(1, -50, 1, 0),
            Position = UDim2.new(0, 10, 0, 0),
            BackgroundTransparency = 1,
            Text = text,
            TextColor3 = Color3.fromRGB(200, 200, 200),
            Font = Enum.Font.Gotham,
            TextSize = 12,
            TextXAlignment = Enum.TextXAlignment.Left
        })

        local toggleBtn = Create("TextButton", {
            Parent = toggleFrame,
            Size = UDim2.new(0, 35, 0, 20),
            Position = UDim2.new(1, -45, 0.5, -10),
            BackgroundColor3 = Color3.fromRGB(50, 50, 50),
            Text = "",
            AutoButtonColor = false
        })
        Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = toggleBtn })

        local indicator = Create("Frame", {
            Parent = toggleBtn,
            Size = UDim2.new(0, 16, 0, 16),
            Position = UDim2.new(0, 2, 0.5, -8),
            BackgroundColor3 = Color3.fromRGB(150, 150, 150),
            BorderSizePixel = 0
        })
        Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = indicator })

        local isToggled = false
        toggleBtn.MouseButton1Click:Connect(function()
            isToggled = not isToggled
            if isToggled then
                toggleBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 50)
                TweenService:Create(indicator, TweenInfo.new(0.2), {Position = UDim2.new(1, -18, 0.5, -8)}):Play()
            else
                toggleBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
                TweenService:Create(indicator, TweenInfo.new(0.2), {Position = UDim2.new(0, 2, 0.5, -8)}):Play()
            end
            if callback then callback(isToggled) end
        end)
    end

    -- Set Tab Default
    PegasusHub.UpdateContent("Main")
    local defaultTab = TabContainer:FindFirstChild("MainTab")
    if defaultTab then
        defaultTab.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        defaultTab.TextColor3 = Color3.fromRGB(255, 255, 255)
    end
end

-- ================= INISIALISASI =================
pcall(function()
    CreateUI()
    Notify("PEGASUS HUB", "Berhasil dimuat! Tekan '-' untuk menyembunyikan UI.")
end)
