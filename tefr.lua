getgenv().CFG = {
    ['Debuggers'] = { ['KeepCoreGUI'] = false }, -- dont need to mess with
    ['Stuff'] = { ['Stat Gui'] = true, ['Optimizer'] = true, ['Daycare'] = true }
}
getgenv().HIPPO_KEY = ""

repeat task.wait() until game:IsLoaded()
repeat task.wait() until game:GetService('Players').LocalPlayer
repeat task.wait() until not game.Players.LocalPlayer.PlayerGui:FindFirstChild('__INTRO')

if not CFG['Debuggers'] or (CFG['Debuggers'] and CFG['Debuggers']['KeepCoreGUI'] == false) then for _, v in pairs(game:GetService('CoreGui'):GetDescendants()) do pcall(function() v:Destroy() end) end end

local Active = workspace.__THINGS.__INSTANCE_CONTAINER.Active
local ReplicatedStorage = cloneref(game.ReplicatedStorage)
local Library = ReplicatedStorage:WaitForChild('Library')
local HttpService = game:GetService('HttpService')
local Client = Library:WaitForChild('Client')
local Players = game:GetService('Players')
local LocalPlayer = Players.LocalPlayer
local StoredUIDs = {}
local SaveMod, MasteryCmds, OrbCmds, NetworkLibrary = require(Client.Save), require(Client.MasteryCmds), require(Client.OrbCmds.Orb), require(Client.Network)
local Network,TextLabels,ReelCount = {},{},0

local ROD_DATA = {
    ['Wooden Fishing Rod'] = { Next_Rod = 'Sturdy Fishing Rod', Cost_Of_Next = 100, Rank_Current_Rod = 1, Icon = "rbxassetid://16028878115", ColorText = Color3.new(1, 1, 1) },
    ['Sturdy Fishing Rod'] = { Next_Rod = 'Advanced Fishing Rod', Cost_Of_Next = 2500, Rank_Current_Rod = 2, Icon = "rbxassetid://16028878219", ColorText = Color3.new(0.5, 0.5, 0.5) },
    ['Advanced Fishing Rod'] = { Next_Rod = 'Super Fishing Rod', Cost_Of_Next = 25000, Rank_Current_Rod = 3, Icon = "rbxassetid://16028879358", ColorText = Color3.new(0.5, 0.7, 0.5) },
    ['Super Fishing Rod'] = { Next_Rod = 'Pro Fishing Rod', Cost_Of_Next = 100000, Rank_Current_Rod = 4, Icon = "rbxassetid://16028878295", ColorText = Color3.new(1, 0.5, 0) },
    ['Pro Fishing Rod'] = { Next_Rod = 'Platinum Fishing Rod', Cost_Of_Next = 40000, Rank_Current_Rod = 5, Icon = "rbxassetid://16028878776", ColorText = Color3.new(1, 1, 0) },
    ['Golden Fishing Rod'] = { Next_Rod = 'Platinum Fishing Rod', Cost_Of_Next = 40000, Rank_Current_Rod = 6, Icon = "rbxassetid://16028878947", ColorText = Color3.new(1, 0.8, 0) },
    ['Platinum Fishing Rod'] = { Next_Rod = 'Emerald Fishing Rod', Cost_Of_Next = 150000, Rank_Current_Rod = 7, Icon = "rbxassetid://16028878591", ColorText = Color3.new(0, 1, 0) },
    ['Emerald Fishing Rod'] = { Next_Rod = 'Sapphire Fishing Rod', Cost_Of_Next = 425000, Rank_Current_Rod = 8, Icon = "rbxassetid://16028879073", ColorText = Color3.new(0, 1, 1) },
    ['Sapphire Fishing Rod'] = { Next_Rod = 'Amethyst Fishing Rod', Cost_Of_Next = 2250000, Rank_Current_Rod = 9, Icon = "rbxassetid://16028878380", ColorText = Color3.new(0.5, 0, 1) },
    ['Amethyst Fishing Rod'] = { Next_Rod = 'NO NEXT ROD', Cost_Of_Next = math.huge, Rank_Current_Rod = 10, Icon = "rbxassetid://16028879272", ColorText = Color3.new(1, 1, 1) },
    ['Diamond Fishing Rod'] = { Next_Rod = 'NO NEXT ROD', Cost_Of_Next = math.huge, Rank_Current_Rod = 11, Icon = "rbxassetid://16028879185", ColorText = Color3.new(1, 1, 1) },
}

--[[ Allow Connect to CMDs ]]
Network.FireServer = function(name, ...) return NetworkLibrary.Fire(name, ...) end
Network.InvokeServer = function(name, ...) return NetworkLibrary.Invoke(name, ...) end
Network.Fired = function(name, ...) return NetworkLibrary.Fired(name, ...) end

--[[ Overall Functions ]]
FormatWithCommas = function(number) return tostring(number):reverse():gsub('%d%d%d', '%1,'):reverse():gsub('^,', '') end
MiniGame = function(Option, Name) setthreadidentity(2) pcall(function() require(Client.InstancingCmds)[Option](Name) end) setthreadidentity(7) end
CheckForItem = function(Id) for Type, List in pairs(SaveMod.Get()['Inventory']) do for i, v in pairs(List) do if v.id == Id then local AM = (v._am) or 1 return i, AM, Type end end end end
GetPetAssetID = function(PetName, PetType) local PetInfo = require(ReplicatedStorage.Library.Directory.Pets)[PetName] local PetAssetID = PetType == 1 and PetInfo.goldenThumbnail or PetInfo.thumbnail return string.gsub(PetAssetID, 'rbxassetid://', '') end
GetExist = function(Type, Item) local stackKey = HttpService:JSONEncode({id = Item.id, sh = Item.sh, pt = Item.pt, tn = Item.tn}) local exist = require(Client.ExistCountCmds).Get({ Class = {Name = Type}, IsA = function(hmm) return hmm == Type end, GetId = function() return Item.id end, StackKey = function() return stackKey end }) or '???' return exist end
GetRAP = function(Class, itemTable) local rap = require(Client.DevRAPCmds).Get({Class = {Name = Class},IsA = function(InputClass) return InputClass == Class end,GetId = function() return itemTable['id'] end,StackKey = function() local stackKey = HttpService:JSONEncode({id = itemTable['id'],sh = itemTable['sh'],pt = itemTable['pt'],tn = itemTable['tn']}) return stackKey end}) or 0 return rap end

FishingRank = function() return MasteryCmds.GetLevel('Fishing') end GetActive = function() return tostring(Active:GetChildren()[1]) end
GetCastVector = function() local ActiveZone = GetActive() if ActiveZone == 'Fishing' then return Vector3.new(1123.921 + math.random(-10, 10), 72, -3532.623 + math.random(-10, 10)) elseif ActiveZone == 'AdvancedFishing' then return Vector3.new(1322.391 + math.random(-10, 10), 61, -4454.638 + math.random(-10, 10)) end end
GetCurrentRod = function()
    local FishRank, CurrentRod = 0, nil
    for _, v in pairs(SaveMod.Get()['Inventory']['Misc']) do
        if string.find(v.id, 'Rod') then
            if ROD_DATA[v.id].Rank_Current_Rod > FishRank then
                FishRank = ROD_DATA[v.id].Rank_Current_Rod
                CurrentRod = v.id
            end
        end
    end
    return CurrentRod, FishRank
enda

local CurrentTask, CurrentTool, Fishing_Rank, StatsCount, StartTime = "Idle", "Wooden Fishing Rod", tostring(FishingRank()), {Pools = 0, DeepPool = 0}, os.clock()
local GuiText = {{Title = "Status", Text = CurrentTask },{Title = "Time", Text = "00:00:00"},{Title = "StatsCount", Text = "Pools: " .. StatsCount.Pools .. " | Deep Pools: " .. StatsCount.DeepPool},{Title = "HugesRank", Text = "Huges: " .. (HugesCount or 0) .. " | Fishing Rank: " .. (Fishing_Rank or 0)},{Title = "Rod", Text = LocalPlayer.Name .. " | " .. CurrentTool},}

-- Create GUI
if CFG['Stuff']["Stat Gui"] then
    local HippoHavenGui = Instance.new("ScreenGui", LocalPlayer.PlayerGui)
    local HippoHavenBG = Instance.new("Frame", HippoHavenGui)
    local HippoHavenToolImage = Instance.new("ImageLabel", HippoHavenGui)
    local HippoHavenLogo = Instance.new("ImageLabel", HippoHavenBG)

    HippoHavenGui.Name, HippoHavenBG.Name, HippoHavenToolImage.Name,HippoHavenLogo.Name = "HippoHavenGui", "HippoHavenBG", "HippoHavenToolImage", "HippoHavenLogo"
    
    HippoHavenBG.BorderSizePixel = 0; HippoHavenBG.Position = UDim2.new(0, 0, 0, -200); HippoHavenBG.ZIndex = 1; HippoHavenBG.Size = UDim2.new(2, 0, 2, 0); HippoHavenBG.BackgroundColor3 = Color3.new(0, 0, 0)

    HippoHavenToolImage.Size, HippoHavenToolImage.BackgroundTransparency = UDim2.new(0, 50, 0, 50), 1
    HippoHavenLogo.Size, HippoHavenLogo.BackgroundTransparency, HippoHavenLogo.Image, HippoHavenLogo.Position = UDim2.new(0, 150, 0, 150), 1, "http://www.roblox.com/asset/?id=86931545305488", UDim2.new(0, 20, 0, 20)

    local HippoHavenTextLabels, HippoHavenLabelHeight, HippoHavenYOffset = {}, 60, -(#GuiText * 60 / 2)
    for _, HippoHavenTextTable in ipairs(GuiText) do
        local HippoHavenTextLabel = Instance.new("TextLabel", HippoHavenGui)
        HippoHavenTextLabel.Name = "HippoHavenTextLabel_" .. HippoHavenTextTable.Title
        HippoHavenTextLabel.Text, HippoHavenTextLabel.Font = HippoHavenTextTable.Text, Enum.Font.FredokaOne
        HippoHavenTextLabel.TextSize, HippoHavenTextLabel.TextColor3, HippoHavenTextLabel.BackgroundTransparency = 50, Color3.new(1, 1, 1), 1
        HippoHavenTextLabel.Position, HippoHavenTextLabel.AnchorPoint = UDim2.new(0.5, 0, 0.5, HippoHavenYOffset), Vector2.new(0.5, 0.5)
        HippoHavenTextLabel.Size = UDim2.new(0, HippoHavenTextLabel.TextBounds.X + 125, 0, HippoHavenLabelHeight)
        HippoHavenYOffset = HippoHavenYOffset + HippoHavenLabelHeight
        TextLabels[HippoHavenTextTable.Title] = HippoHavenTextLabel
    end

    UIUpdate = function()
        local ElapsedTime = os.clock() - StartTime
        local Hours, Minutes, Seconds = math.floor(ElapsedTime / 3600), math.floor((ElapsedTime % 3600) / 60), math.floor(ElapsedTime % 60)
        local CurrentRod, FishRank = GetCurrentRod()
        
        GuiText[1].Text = CurrentTask or "Idle"
        GuiText[2].Text = string.format("%02d:%02d:%02d", Hours, Minutes, Seconds)
        GuiText[3].Text = "Pools: " .. StatsCount.Pools .. " | Deep Pools: " .. StatsCount.DeepPool
        GuiText[4].Text = "Huges: " .. tostring(#StoredUIDs) .. " | Rank: " .. FishingRank() .. " +" .. (FishingRank() - Fishing_Rank)
        GuiText[5].Text = LocalPlayer.Name .. " | " .. CurrentRod
        
        for _, TextTable in ipairs(GuiText) do
            local TextLabel = TextLabels[TextTable.Title]
            if TextLabel then
                TextLabel.Text = TextTable.Text
                if string.find(TextTable.Title, "Rod") then
                    TextLabel.TextColor3 = ROD_DATA[CurrentRod].ColorText
                    HippoHavenToolImage.Image = ROD_DATA[CurrentRod].Icon
                    HippoHavenToolImage.Position = UDim2.new(0.5, -TextLabel.Size.X.Offset / 2 - HippoHavenToolImage.Size.X.Offset - 10, 0.5, TextLabel.Position.Y.Offset - 20)
                end
            end
        end
    end

    task.spawn(function() 
        while task.wait(1) do 
            UIUpdate() 
        end 
    end)
    task.wait(5)
end

--[[ Go W1 ]] if game.PlaceId ~= 8737899170 then CurrentTask = 'Going to W1' task.wait(1) while game.PlaceId ~= 8737899170 do ReplicatedStorage.Network['World1Teleport']:InvokeServer() task.wait(5) end end
--[[ Anti AFK ]] game:GetService('Players').LocalPlayer.Idled:Connect(function() game:GetService('VirtualUser'):CaptureController() game:GetService('VirtualUser'):Button2Down(Vector2.new(0,0), game:GetService('Workspace').CurrentCamera.CFrame) task.wait(1) game:GetService('VirtualUser'):Button2Up(Vector2.new(0,0), game:GetService('Workspace').CurrentCamera.CFrame) end); local old; old = hookmetamethod(game,'__namecall',(function(...) local self,arg = ... if not checkcaller() then if tostring(self) == '__BLUNDER' or tostring(self) == 'Idle Tracking: Update Timer' or tostring(self) == 'Move Server' then return end end return old(...) end)); ReplicatedStorage.Network['Idle Tracking: Stop Timer']:FireServer(); game:GetService('Players').LocalPlayer.PlayerScripts.Scripts.Core['Idle Tracking'].Enabled = false; game:GetService('Players').LocalPlayer.PlayerScripts.Scripts.Core['Server Closing'].Enabled = false; task.spawn(function() while task.wait(100) do game:GetService('VirtualUser'):CaptureController() game:GetService('VirtualUser'):SetKeyDown('0x20') task.wait(1) game:GetService('VirtualUser'):SetKeyUp('0x20') end end)
--[[ Claim Mail ]] task.spawn(function() while task.wait(30) do ReplicatedStorage.Network:WaitForChild('Mailbox: Claim All'):InvokeServer() end end)


--[[ Player Opt Vars ]] local PlayerObjectsDestroy = {BodyColors = true, Pants = true, Shirt = true, Accessory = true}
--[[ Workspace Opt Vars ]] 
local ExcludeRepstorage, PartClassNames, DestroyClass, DisableClass = 
    {'__THINGS', '__DEBRIS', 'Camera', 'CurrentCamera', 'Terrain', 'Border'},
    {'Basepart', 'Part', 'WedgePart', 'TrussPart', 'CornerWedgePart', 'MeshPart', 'UnionOperation', 'CylinderPart', 'Ball'},
    {'Clothing', 'SurfaceAppearance', 'BaseWrap', 'Decal', 'Texture'},
    {'ParticleEmitter', 'Trail', 'Smoke', 'Fire', 'Sparkles'}

--[[ Things Opt Vars ]] 
local THINGS_Children_Destroy = {'Breakables', 'Booths','ExclusiveEggPets', 'ExclusiveEggs', 'RandomEvents', 'Ornaments', 'HiddenPresents', 'Ski Chairs', 'ShinyRelics', 'BalloonGifts', 'Eggs', 'CustomEggs', 'PetCubes', 'PrisonFriends', 'Tycoons', 'MagicOrbs', 'ChristmasSleighPath', 'RenderedEggs'}
local Lighting, MaterialService, Terrain = game:GetService("Lighting"), game:GetService("MaterialService"), workspace:FindFirstChildOfClass("Terrain")

Terrain.WaterWaveSize, Terrain.WaterWaveSpeed, Terrain.WaterReflectance, Terrain.WaterTransparency, Lighting.GlobalShadows, Lighting.FogEnd, Lighting.ShadowSoftness, Lighting.Brightness, Lighting.TimeOfDay = 0, 0, 0, 0, false, 9e9, 0, 0, "00:00:00"
pcall(function() sethiddenproperty(workspace:FindFirstChildOfClass("Terrain"), "Decoration", false) end) pcall(function() sethiddenproperty(game:GetService("Lighting"), "Technology", 2) end)
for _, v in pairs(Lighting:GetChildren()) do if v:IsA("BlurEffect") or v:IsA("SunRaysEffect") or v:IsA("ColorCorrectionEffect") or v:IsA("BloomEffect") or v:IsA("DepthOfFieldEffect") then pcall(function() v.Enabled = false end) end end

if not CFG['Debuggers'] or (CFG['Debuggers'] and CFG['Debuggers']['KeepCoreGUI'] == false) then table.insert(DestroyClass, 'TextLabel') end

if CFG['Stuff']['Optimizer'] then
    CurrentTask = 'Player Optimazations' task.wait(3)
    --[[ Player Management ]]
    HandlePlayer = function(player)
        pcall(function() player.leaderstats:Destroy() end)
        if player.Character then
            for _, v in pairs(player.Character:GetDescendants()) do
                pcall(function()
                    if PlayerObjectsDestroy[v.ClassName] then
                        v:Destroy()
                    elseif not string.find(v.Name, 'HippoHaven') then
                        v.Transparency = 1
                    end
                end)
            end
        end
    end
    pcall(function() workspace.Map:Destroy() end)

    
    for _,v in ipairs(game.Players:GetPlayers()) do HandlePlayer(v) end
    game.Players.PlayerAdded:Connect(function(v) HandlePlayer(v) end)

    --[[ Local Player Scripts ]]
    for _,v in pairs(LocalPlayer.PlayerScripts:GetDescendants()) do 
        pcall(function() v.Enabled = false end) 
    end

    --[[ Player Gui ]]
    for _,v in pairs(game.Players.LocalPlayer.PlayerGui:GetDescendants()) do
        if not string.find(v.Name,'HippoHaven') then
            pcall(function() v.Enabled = false v:GetPropertyChangedSignal('Enabled'):Connect(function() v.Enabled = false end) end)
        end
    end
    
    CurrentTask = 'Workspace Optimazations' task.wait(3)

    --[[ Workspace Cleanup ]]
    for _,v in pairs(workspace:GetChildren()) do if not table.find(ExcludeRepstorage, v.Name) and not (v:IsA('Model') and v.PrimaryPart and v.PrimaryPart.Name == 'HumanoidRootPart') then v.Parent = ReplicatedStorage end end
    
    --[[ Things silly ]]
    for _, v in ipairs(workspace.__THINGS:GetChildren()) do if table.find(THINGS_Children_Destroy, v.Name) then for _, i in ipairs(v:GetChildren()) do i:Destroy() end elseif not (v.Name == "Orbs" or v.Name == "__INSTANCE_CONTAINER" or v.Name == "Lootbags") then v.Parent = ReplicatedStorage end end

    OptamizeParts = function(v)
        pcall(function()
            if not v:IsDescendantOf(game.Players.LocalPlayer.PlayerGui) then
                if string.find(v.Name, "SAFETY_NET") or string.find(v.Name, "FlyBorder") then
                    v:Destroy()
                elseif table.find(PartClassNames, v.ClassName) then
                    pcall(function()
                        v.Material = Enum.Material.Plastic
                        v.Reflectance = 0
                        v.Massless = true
                        v.Transparency = 1
    
                        if v:IsA("MeshPart") or v:IsA("UnionOperation") then
                            v.MeshId = ""
                            v.TextureID = ""
                        end
                    end)
                elseif table.find(DestroyClass, v.ClassName) then
                    v:Destroy()
                elseif v:IsA("Explosion") then
                    v.BlastPressure = 1
                    v.BlastRadius = 1
                    v.Visible = false
    
                elseif v:IsA("PostEffect") then
                    v.Enabled = false
    
                elseif table.find(DisableClass, v.ClassName) then
                    v.Enabled = false
                elseif v:IsDescendantOf("CoreGui") then
                    v.Transparency = 1
                end
            end
        end)
    end
    
    local partopt = 0
    for _, v in pairs(game:GetDescendants()) do
        OptamizeParts(v) partopt += 1 if partopt >= 1000 then game:GetService("RunService").Heartbeat:Wait() partopt = 0 end
    end
    workspace.DescendantAdded:Connect(function(v) OptamizeParts(v) end)

    task.wait(3)
    CurrentTask = 'Done Optamizing 🥳!'
end
task.wait(5)


local IsFishingSuccess, HasCasted, IsHooked, IsCatching = false, false, false, false
if not Executed then
    Network.Fired("Instancing_FireCustomFromServer"):Connect(function(Zone, CMD, plr)
        if Zone == GetActive() and (tostring(plr) == LocalPlayer.Name or CMD == "StartAttemptCatch") then
            local DeepPool = Active[Zone].Interactable:FindFirstChild('DeepPool')
            local CastArea = DeepPool and FishingRank() >= 30 and DeepPool.Position or GetCastVector()

            if CMD == "Cast" then
                IsFishingSuccess, HasCasted, CurrentTask = false, true, "Casting"
                if DeepPool then
                    StatsCount.DeepPool += 1
                else
                    StatsCount.Pools += 1
                end
            elseif CMD == "Hook" then
                HasCasted, IsHooked, CurrentTask = false, true, "Reeling"
                while not IsCatching do
                    Network.InvokeServer('Instancing_InvokeCustomFromClient', Zone, "RequestReel") task.wait()
                end
            elseif CMD == "StartAttemptCatch" then
                IsHooked, IsCatching, CurrentTask = false, true, "Tapping"
                while not IsFishingSuccess do
                    Network.InvokeServer('Instancing_InvokeCustomFromClient', Zone, "Clicked") game:GetService("RunService").Heartbeat:Wait()
                end 
            elseif CMD == "FishingSuccess" then
                ReelCount += 1
                IsCatching, IsFishingSuccess, CurrentTask = false, true, "Finished"
                if Zone == "Fishing" then
                    local CurrentRod, FishRank = GetCurrentRod()
                    local FishingZone = (not CheckForItem('Wooden Fishing Rod') and 'Fishing') or (FishRank < 5 and 'Fishing') or 'AdvancedFishing'
                    if FishingZone == "AdvancedFishing" then
                        MiniGame('Leave', "Fishing")
                        task.wait(1)
                        repeat 
                            MiniGame('Enter', FishingZone) 
                            task.wait(1) 
                        until Active:FindFirstChild("AdvancedFishing")
                    end
                end
                CurrentTask = "Casting"
                while not HasCasted do
                    Network.InvokeServer('Instancing_InvokeCustomFromClient', Zone, "RequestCast", CastArea) task.wait()
                end
                CurrentTask = "Casting"
                while not HasCasted do
                    Network.InvokeServer('Instancing_InvokeCustomFromClient', Zone, "RequestCast", CastArea) task.wait()
                end
            end
        end
    end)
end

task.spawn(function()
    local CurrentRod, FishRank = GetCurrentRod()
    if not CheckForItem('Wooden Fishing Rod') then
        task.spawn(function()
            while not CheckForItem('Wooden Fishing Rod') do
                Network.FireServer('Instancing_FireCustomFromClient', 'Fishing', 'ClaimRod') task.wait(1)
            end
        end)
    end

    if ROD_DATA[CurrentRod].Next_Rod ~= 'NO NEXT ROD' then
        task.spawn(function()
            while task.wait(5) do if ROD_DATA[CurrentRod].Next_Rod == 'NO NEXT ROD' then break end
                if ROD_DATA[CurrentRod].Cost_Of_Next <= require(ReplicatedStorage.Library.Client.CurrencyCmds).Get('Fishing') then
                    Network.InvokeServer('FishingMerchant_PurchaseRod', ROD_DATA[CurrentRod].Next_Rod)
                    CurrentRod, FishRank = GetCurrentRod()
                end
            end
        end)
    end
end)


while task.wait(1) do
    if Active:FindFirstChild('AdvancedFishing') or Active:FindFirstChild('Fishing') then
        local DeepPool = Active[GetActive()].Interactable:FindFirstChild('DeepPool')
        local CastArea = DeepPool and FishingRank() >= 30 and DeepPool.Position or GetCastVector()
        while not Casted do
            Network.InvokeServer('Instancing_InvokeCustomFromClient', GetActive(), "RequestCast", CastArea) task.wait(0.1)
        end
        break
    end
    local CurrentRod, FishRank = GetCurrentRod()
    local FishingZone = (not CheckForItem('Wooden Fishing Rod') and 'Fishing') or (FishRank < 5 and 'Fishing') or 'AdvancedFishing' 
    CurrentTask = ("Entering: " .. FishingZone) print(FishingZone)
    MiniGame('Enter', FishingZone) task.wait(1)
end


task.spawn(function()
    local RandomHiddenSpot = CFrame.new(math.random(-100000, 100000), math.random(1, 100), math.random(-100000, 100000))
    while task.wait(30) do
        local HRP = game.Players.LocalPlayer.Character:WaitForChild("HumanoidRootPart")
        HRP.Anchored = true 
        HRP.CFrame = RandomHiddenSpot 
    end
end)


getgenv().Executed = true
