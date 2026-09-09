-- Hotel Minus ULTIMATE EASY MODE Script
-- Auto-revive, helper entities, everything ez

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
local humanoid = character:WaitForChild("Humanoid")

-- Settings
local PLAYER_SPEED = 150 -- SUPER fast
local PLAYER_HEALTH = 99999 -- Basically invincible
local PLAYER_JUMP = 300 -- Flying
local AUTO_HEAL = true
local HEAL_RATE = 100 -- Heal SUPER fast
local DOOR_DETECT_RANGE = 100 -- Auto-open doors within 100 studs
local AUTO_OPEN_DOORS = true
local AUTO_REVIVE = true
local SPAWN_HELPERS = true
local MAX_HELPERS = 3

-- Tables
local helperEntities = {}
local reviveInProgress = false

-- Boost player stats
humanoid.MaxHealth = PLAYER_HEALTH
humanoid.Health = PLAYER_HEALTH
humanoid.WalkSpeed = PLAYER_SPEED
humanoid.JumpPower = PLAYER_JUMP

-- Function to heal player
local function healPlayer()
    if AUTO_HEAL and humanoid and humanoid.Health < humanoid.MaxHealth then
        humanoid.Health = math.min(humanoid.Health + HEAL_RATE, humanoid.MaxHealth)
    end
end

-- Function to create a helper entity
local function createHelperEntity()
    if #helperEntities >= MAX_HELPERS then return end
    
    local helper = Instance.new("Model")
    helper.Name = "HelperEntity_" .. math.random(1000, 9999)
    
    -- Create body (blue sphere = friendly)
    local head = Instance.new("Part")
    head.Name = "Head"
    head.Shape = Enum.PartType.Ball
    head.Size = Vector3.new(2, 2, 2)
    head.Color = Color3.fromRGB(0, 100, 255) -- Blue = helper
    head.CanCollide = true
    head.Parent = helper
    
    -- Create humanoid
    local helperHumanoid = Instance.new("Humanoid")
    helperHumanoid.MaxHealth = 100
    helperHumanoid.Health = 100
    helperHumanoid.Parent = helper
    
    -- Spawn near player
    local spawnOffset = Vector3.new(
        math.random(-30, 30),
        10,
        math.random(-30, 30)
    )
    head.CFrame = humanoidRootPart.CFrame + spawnOffset
    
    helper.PrimaryPart = head
    helper:SetPrimaryPartCFrame(head.CFrame)
    helper.Parent = workspace
    
    table.insert(helperEntities, helper)
    print("✓ Helper entity spawned! Total: " .. #helperEntities)
end

-- Function to make helpers follow and protect
local function helperFollowPlayer()
    for _, helper in pairs(helperEntities) do
        if not helper or not helper.Parent then return end
        
        local helperHead = helper:FindFirstChild("Head")
        local helperHumanoid = helper:FindFirstChild("Humanoid")
        
        if helperHead and helperHumanoid and helperHumanoid.Health > 0 then
            local distance = (helperHead.Position - humanoidRootPart.Position).Magnitude
            
            -- Follow player closely
            if distance > 20 then
                helperHumanoid:MoveTo(humanoidRootPart.Position + Vector3.new(math.random(-10, 10), 0, math.random(-10, 10)))
            end
            
            -- Keep helper alive
            if helperHumanoid.Health < helperHumanoid.MaxHealth then
                helperHumanoid.Health = helperHumanoid.MaxHealth
            end
        end
    end
end

-- Function to auto-revive player
local function autoRevivePlayer()
    if not AUTO_REVIVE or reviveInProgress then return end
    
    if humanoid.Health <= 0 then
        reviveInProgress = true
        print("💀 You died! Reviving...")
        
        wait(1)
        
        -- Teleport back to spawn or safe location
        humanoidRootPart.CFrame = CFrame.new(0, 50, 0)
        humanoid.Health = PLAYER_HEALTH
        humanoid.WalkSpeed = PLAYER_SPEED
        
        reviveInProgress = false
        print("✓ Revived! You're back in the game!")
    end
end

-- Function to auto-open nearby doors
local function autoOpenDoors()
    if not AUTO_OPEN_DOORS or not humanoidRootPart then return end
    
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj.Name:match("Door") or obj.Name:match("door") or obj.Parent.Name:match("Door") then
            local objPos = obj:IsA("Part") and obj.Position or (obj.PrimaryPart and obj.PrimaryPart.Position)
            if objPos then
                local distance = (objPos - humanoidRootPart.Position).Magnitude
                
                if distance < DOOR_DETECT_RANGE then
                    -- Try to find and trigger door opening
                    local openValue = obj.Parent:FindFirstChild("Open")
                    if openValue and openValue:IsA("BoolValue") then
                        openValue.Value = true
                    end
                    
                    -- Try RemoteEvent/RemoteFunction
                    for _, remote in pairs(obj.Parent:FindFirstChildOfClass("RemoteEvent") or {}) do
                        pcall(function()
                            remote:FireServer("Open")
                        end)
                    end
                    
                    -- Make door invisible/passable
                    if obj:IsA("Part") then
                        obj.CanCollide = false
                        obj.Transparency = 0.9
                    end
                end
            end
        end
    end
end

-- Handle respawns
player.CharacterAdded:Connect(function(newCharacter)
    character = newCharacter
    humanoidRootPart = character:WaitForChild("HumanoidRootPart")
    humanoid = character:WaitForChild("Humanoid")
    humanoid.MaxHealth = PLAYER_HEALTH
    humanoid.Health = PLAYER_HEALTH
    humanoid.WalkSpeed = PLAYER_SPEED
    humanoid.JumpPower = PLAYER_JUMP
    reviveInProgress = false
end)

-- Maintain player speed
humanoid:GetPropertyChangedSignal("WalkSpeed"):Connect(function()
    if humanoid.WalkSpeed < PLAYER_SPEED then
        humanoid.WalkSpeed = PLAYER_SPEED
    end
end)

-- Spawn helpers periodically
local helperSpawnTime = 0
local function spawnHelpersPeriodicly()
    local currentTime = tick()
    if currentTime - helperSpawnTime >= 8 and #helperEntities < MAX_HELPERS then
        createHelperEntity()
        helperSpawnTime = currentTime
    end
end

-- Main loop
RunService.Heartbeat:Connect(function()
    if not character or not humanoidRootPart or not humanoid then return end
    
    -- Auto heal player
    healPlayer()
    
    -- Keep jump power high
    humanoid.JumpPower = PLAYER_JUMP
    
    -- Auto-open doors
    autoOpenDoors()
    
    -- Helper entities follow and protect
    helperFollowPlayer()
    
    -- Spawn new helpers
    spawnHelpersPeriodicly()
    
    -- Auto-revive on death
    autoRevivePlayer()
end)

print("✓✓✓ ULTIMATE EASY MODE ACTIVATED! ✓✓✓")
print("⚡ Speed: 150 (INSANE!)")
print("❤️ Health: 99999 (GOD MODE)")
print("📈 Jump Power: 300 (FLY!)")
print("🚪 Auto-opens doors within 100 studs")
print("💙 Helper entities spawn every 8 seconds (max 3)")
print("💀 Auto-revive on death - NEVER STAY DEAD!")
print("😎 Pure CHILL mode - literally IMPOSSIBLE to lose!")
