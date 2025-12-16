-- FULL WORKING SCRIPT (Rayfield UI)
-- 4 Tabs: Info, Weapon (Aimbot), Player (Fly + ESP + Noclip), Misc
-- Key system with save: hello
-- ESP uses MultipleOptions dropdown
-- Theme: Amethystıawdawdawdawdawda

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "War Tycoonw",
   LoadingTitle = "War Tycoon",
   LoadingSubtitle = "by Seny3103",
   Theme = "Amethyst",
   ConfigurationSaving = {
       Enabled = true,
       FolderName = "WarTycoon",
       FileName = "MainConfig"
   },
   KeySystem = true,
   KeySettings = {
      Title = "War Tycoon Key System",
      Subtitle = "Enter Your Key",
      Note = "You can get the key from our Discord server:\nhttps://discord.gg/BD9pGdrb",
      FileName = "wartycoon_key",
      SaveKey = true,
      GrabKeyFromSite = false,
      Key = "hello"
   }
})

-- SERVICES
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

-------------------------------------------------
-- A I M B O T
-------------------------------------------------
local aimbotEnabled = false
local aimFOV = 150
local aimSmooth = 0.25
local aimMaxDistance = 500
local aimPart = "Head"

local fovCircle = Drawing.new("Circle")
fovCircle.Thickness = 1
fovCircle.Filled = false
fovCircle.Color = Color3.fromRGB(255,255,255)
fovCircle.Visible = false

local function getClosestPlayer()
    local closest, dist = nil, math.huge
    local lchar = LocalPlayer.Character
    local lhrp = lchar and lchar:FindFirstChild("HumanoidRootPart")
    if not lhrp then return nil end

    for _,plr in pairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer
        and plr.Character
        and plr.Character:FindFirstChild(aimPart)
        and plr.Character:FindFirstChild("HumanoidRootPart") then

            local worldDist = (lhrp.Position - plr.Character.HumanoidRootPart.Position).Magnitude
            if worldDist <= aimMaxDistance then
                local pos, onScreen = Camera:WorldToViewportPoint(plr.Character[aimPart].Position)
                if onScreen then
                    local mag = (
                        Vector2.new(pos.X,pos.Y)
                        - Vector2.new(Camera.ViewportSize.X/2,Camera.ViewportSize.Y/2)
                    ).Magnitude

                    if mag < aimFOV and mag < dist then
                        dist = mag
                        closest = plr
                    end
                end
            end
        end
    end
    return closest
end

RunService.RenderStepped:Connect(function()
    fovCircle.Position = Vector2.new(Camera.ViewportSize.X/2,Camera.ViewportSize.Y/2)
    fovCircle.Radius = aimFOV
    fovCircle.Visible = aimbotEnabled

    if aimbotEnabled and UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
        local target = getClosestPlayer()
        if target and target.Character and target.Character:FindFirstChild(aimPart) then
            Camera.CFrame = Camera.CFrame:Lerp(
                CFrame.new(Camera.CFrame.Position, target.Character[aimPart].Position),
                aimSmooth
            )
        end
    end
end)

-------------------------------------------------
-- F L Y
-------------------------------------------------
local flyEnabled = false
local flySpeed = 60
local flySmooth = 0.15
local gyro, vel

local function startFly()
    local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    gyro = Instance.new("BodyGyro", hrp)
    gyro.P = 9e4
    gyro.MaxTorque = Vector3.new(9e9,9e9,9e9)

    vel = Instance.new("BodyVelocity", hrp)
    vel.MaxForce = Vector3.new(9e9,9e9,9e9)
    vel.Velocity = Vector3.zero
end

local function stopFly()
    if gyro then gyro:Destroy() gyro=nil end
    if vel then vel:Destroy() vel=nil end
end

RunService.RenderStepped:Connect(function()
    if flyEnabled and vel then
        local dir = Vector3.zero
        local cf = Camera.CFrame
        if UIS:IsKeyDown(Enum.KeyCode.W) then dir += cf.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.S) then dir -= cf.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.A) then dir -= cf.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.D) then dir += cf.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.Space) then dir += Vector3.new(0,1,0) end
        if UIS:IsKeyDown(Enum.KeyCode.LeftControl) then dir -= Vector3.new(0,1,0) end

        vel.Velocity = vel.Velocity:Lerp(dir * flySpeed, flySmooth)
        gyro.CFrame = cf
    end
end)

-------------------------------------------------
-- N O C L I P
-------------------------------------------------
local noclipEnabled = false
local originalCanCollide = {}
RunService.Stepped:Connect(function()
    local char = LocalPlayer.Character
    if not char then return end

    for _, part in pairs(char:GetDescendants()) do
        if part:IsA("BasePart") then
            if noclipEnabled then
                if originalCanCollide[part] == nil then
                    originalCanCollide[part] = part.CanCollide
                end
                part.CanCollide = false
            else
                if originalCanCollide[part] ~= nil then
                    part.CanCollide = originalCanCollide[part]
                    originalCanCollide[part] = nil
                end
            end
        end
    end
end)

-------------------------------------------------
-- E S P
-------------------------------------------------
local espEnabled = false
local espOptions = {Box=true,Line=true,Name=true,Distance=true}
local espDrawings = {}

local function clearESP()
    for _,v in pairs(espDrawings) do v:Remove() end
    espDrawings = {}
end

local function getTeamColor(plr)
    if plr.TeamColor then return plr.TeamColor.Color end
    return Color3.new(1,1,1)
end

local function getTeamName(plr)
    if plr.Team then return plr.Team.Name end
    return "No Team"
end

RunService.RenderStepped:Connect(function()
    clearESP()
    if not espEnabled then return end

    local lchar = LocalPlayer.Character
    local lhrp = lchar and lchar:FindFirstChild("HumanoidRootPart")
    if not lhrp then return end

    for _,plr in pairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
            local hrp = plr.Character.HumanoidRootPart
            local pos, onScreen = Camera:WorldToViewportPoint(hrp.Position)
            if onScreen then
                local dist = (lhrp.Position - hrp.Position).Magnitude
                local teamColor = getTeamColor(plr)

                if espOptions.Line then
                    local line = Drawing.new("Line")
                    line.From = Vector2.new(Camera.ViewportSize.X/2,Camera.ViewportSize.Y)
                    line.To = Vector2.new(pos.X,pos.Y)
                    line.Thickness = 1
                    line.Color = teamColor
                    line.Visible = true
                    table.insert(espDrawings,line)
                end

                if espOptions.Box then
                    local box = Drawing.new("Square")
                    box.Size = Vector2.new(30,50)
                    box.Position = Vector2.new(pos.X-15,pos.Y-25)
                    box.Thickness = 1
                    box.Color = teamColor
                    box.Filled = true
                    box.Transparency = 0.3
                    box.Visible = true
                    table.insert(espDrawings,box)
                end

                if espOptions.Name then
                    local name = Drawing.new("Text")
                    name.Text = plr.Name .. " (" .. getTeamName(plr) .. ")"
                    name.Size = 14
                    name.Center = true
                    name.Position = Vector2.new(pos.X,pos.Y-40)
                    name.Color = teamColor
                    name.Visible = true
                    table.insert(espDrawings,name)
                end

                if espOptions.Distance then
                    local dtext = Drawing.new("Text")
                    dtext.Text = math.floor(dist) .. "m"
                    dtext.Size = 14
                    dtext.Center = true
                    dtext.Position = Vector2.new(pos.X,pos.Y+35)
                    dtext.Color = teamColor
                    dtext.Visible = true
                    table.insert(espDrawings,dtext)
                end
            end
        end
    end
end)

-------------------------------------------------
-- R A Y F I E L D   U I
-------------------------------------------------
local InfoTab = Window:CreateTab("Info")
local WeaponTab = Window:CreateTab("Weapon")
local PlayerTab = Window:CreateTab("Player")
local MiscTab = Window:CreateTab("Misc")

-- INFO
InfoTab:CreateParagraph({
    Title = "Status",
    Content = "In development."
})
InfoTab:CreateParagraph({
    Title = "Features",
    Content = "• Aimbot (FOV, Smooth, Distance, Target Part)\n• Admin Fly (Speed & Smooth)\n• ESP (Box, Line, Name, Team, Distance – Team Color Based)\n• Noclip"
})

-- WEAPON / AIMBOT
local AimbotSection = WeaponTab:CreateSection("Aimbot")
WeaponTab:CreateToggle({Name="Aimbot",CurrentValue=false,Callback=function(v) aimbotEnabled=v end})
WeaponTab:CreateSlider({Name="FOV",Range={50,500},Increment=10,CurrentValue=aimFOV,Callback=function(v) aimFOV=v end})
WeaponTab:CreateSlider({Name="Smooth",Range={1,100},Increment=1,CurrentValue=aimSmooth*100,Callback=function(v) aimSmooth=v/100 end})
WeaponTab:CreateSlider({Name="Max Distance",Range={50,2000},Increment=50,CurrentValue=aimMaxDistance,Callback=function(v) aimMaxDistance=v end})
WeaponTab:CreateDropdown({Name="Aim Part",Options={"Head","HumanoidRootPart"},CurrentOption="Head",Callback=function(v) if typeof(v)=="table" then aimPart=v[1] else aimPart=v end end})
WeaponTab:CreateColorPicker({Name="FOV Circle Color",Color=fovCircle.Color,Callback=function(c) fovCircle.Color=c end})

-- PLAYER / FLY
local FlySection = PlayerTab:CreateSection("Fly")
PlayerTab:CreateToggle({Name="Fly",CurrentValue=false,Callback=function(v) flyEnabled=v if v then startFly() else stopFly() end end})
PlayerTab:CreateSlider({Name="Fly Speed",Range={10,200},Increment=5,CurrentValue=flySpeed,Callback=function(v) flySpeed=v end})
PlayerTab:CreateSlider({Name="Fly Smooth",Range={1,100},Increment=1,CurrentValue=flySmooth*100,Callback=function(v) flySmooth=v/100 end})

-- PLAYER / ESP (MultipleOptions)
local ESPSection = PlayerTab:CreateSection("ESP")
PlayerTab:CreateToggle({Name="ESP Enabled",CurrentValue=false,Callback=function(v) espEnabled=v end})
PlayerTab:CreateDropdown({Name="ESP Options",Options={"Box","Line","Name & Team","Distance"},CurrentOption={"Box","Line","Name & Team","Distance"},MultipleOptions=true,Callback=function(selected)
    espOptions.Box=table.find(selected,"Box")~=nil
    espOptions.Line=table.find(selected,"Line")~=nil
    espOptions.Name=table.find(selected,"Name & Team")~=nil
    espOptions.Distance=table.find(selected,"Distance")~=nil
end})

-- PLAYER / NOCLIP
local NoclipSection = PlayerTab:CreateSection("Noclip")
PlayerTab:CreateToggle({Name="Noclip",CurrentValue=false,Callback=function(v) noclipEnabled=v end})

-- MISC
MiscTab:CreateParagraph({Title="Information",Content="New features will be added soon."})

