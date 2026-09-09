-- Hotel Minus SOLO REVIVE MODE Script
-- Instant revive button + auto-revive on death (solo only)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
local humanoid = character:WaitForChild("Humanoid")

-- Settings
local PLAYER_SPEED = 150
local PLAYER_HEALTH = 99999
local PLAYER_JUMP = 300
local AUTO_HEAL = true
local HEAL_RATE = 100
local DOOR_DETECT_RANGE = 100
local AUTO_OPEN_DOORS = true
local REVIVE_BUTTON = Enum.KeyCode.R -- Press R to revive
local NO_ACCELERATION = true

-- Boost player stats
humanoid.MaxHealth = PLAYER_HEALTH
humanoid.Health = PLAYER_HEALTH
humanoid.WalkSpeed = PLAYER_SPEED
humanoid.JumpPower = PLAYER_JUMP

-- Function to check if player is solo
local function isSoloMode()
    local playerCount = 0
    for _, plr in pairs(Players:GetPlayers()) do
        if plr.Character then
            playerCount = playerCount + 1
        end
    end
    return playerCount <= 1
end

-- Function to revive player
local function revivePlayer()
    if not character or not humanoidRootPart then return end
    
    character = player.Character
    humanoidRootPart = character:WaitForChild("HumanoidRootPart")
    humanoid = character:WaitForChild("Humanoid")
    
    humanoid.MaxHealth = PLAYER_HEALTH
    humanoid.Health = PLAYER_HEALTH
    humanoid.WalkSpeed = PLAYER_SPEED
    humanoid.JumpPower = PLAYER_JUMP
    
    print("✓ REVIVED! Back in the game!")
end

-- Function to heal player
local function healPlayer()
    if AUTO_HEAL and humanoid and humanoid.Health < humanoid.MaxHealth then
        humanoid.Health = math.min(humanoid.Health + HEAL_RATE, humanoid.MaxHealth)
    end
end

-- Function to disable acceleration (instant speed)
local function disableAcceleration()
    if humanoid then
        humanoid.WalkSpeed = PLAYER_SPEED
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
                    local openValue = obj.Parent:FindFirstChild("Open")
                    if openValue and openValue:IsA("BoolValue") then
                        openValue.Value = true
                    end
                    
                    for _, remote in pairs(obj.Parent:FindFirstChildOfClass("RemoteEvent") or {}) do
                        pcall(function()
                            remote:FireServer("Open")
                        end)
                    end
                    
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
end)

-- Auto-revive on death (solo only)
humanoid.Died:Connect(function()
    if isSoloMode() then
        print("💀 You died! Auto-reviving (solo mode)...")
        wait(0.1)
        revivePlayer()
    end
end)

-- Button to manually revive (press R)
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if input.KeyCode == REVIVE_BUTTON then
        if isSoloMode() then
            print("🔄 Revive button pressed!")
            revivePlayer()
        else
            print("⚠️ Revive only works in solo mode!")
        end
    end
end)

-- Maintain player speed (no acceleration)
humanoid:GetPropertyChangedSignal("WalkSpeed"):Connect(function()
    if humanoid.WalkSpeed ~= PLAYER_SPEED then
        humanoid.WalkSpeed = PLAYER_SPEED
    end
end)

-- Main loop
RunService.Heartbeat:Connect(function()
    if not character or not humanoidRootPart or not humanoid then return end
    
    -- Auto heal player
    healPlayer()
    
    -- Keep jump power high
    humanoid.JumpPower = PLAYER_JUMP
    
    -- Disable acceleration (instant speed)
    if NO_ACCELERATION then
        disableAcceleration()
    end
    
    -- Auto-open doors
    autoOpenDoors()
    
    -- Auto-revive on death (solo only)
    if humanoid.Health <= 0 and isSoloMode() then
        wait(0.1)
        revivePlayer()
    end
end)

print("✓✓✓ SOLO REVIVE MODE ACTIVATED! ✓✓✓")
print("⚡ Speed: 150 (NO ACCELERATION - instant!)")
print("❤️ Health: 99999 (GOD MODE)")
print("📈 Jump Power: 300")
print("🚪 Auto-opens doors within 100 studs")
print("💀 Auto-revive on death (SOLO ONLY)")
print("🔄 Press R to manually revive!")
print("⚠️ Revive features only work when you're alone on the server!")
