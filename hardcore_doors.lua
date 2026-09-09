-- Hotel Minus ULTRA EASY MODE Script
-- Auto-open doors when you get close

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
local humanoid = character:WaitForChild("Humanoid")

-- Settings
local PLAYER_SPEED = 100 -- Super duper fast
local PLAYER_HEALTH = 9999 -- God mode
local PLAYER_JUMP = 200 -- Flying jumps
local AUTO_HEAL = true
local HEAL_RATE = 50 -- Heal FAST
local DOOR_DETECT_RANGE = 50 -- Auto-open doors within 50 studs
local AUTO_OPEN_DOORS = true

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

-- Function to auto-open nearby doors
local function autoOpenDoors()
    if not AUTO_OPEN_DOORS or not humanoidRootPart then return end
    
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj.Name:match("Door") or obj.Name:match("door") or obj.Parent.Name:match("Door") then
            local objPos = obj:IsA("Part") and obj.Position or (obj.PrimaryPart and obj.PrimaryPart.Position)
            if objPos then
                local distance = (objPos - humanoidRootPart.Position).Magnitude
                
                -- If door is close, open it
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
                    
                    -- Try simple part movement
                    if obj:IsA("Part") or obj:IsA("Model") then
                        pcall(function()
                            if obj:IsA("Part") then
                                obj.CanCollide = false
                                obj.Transparency = 0.7
                            else
                                for _, part in pairs(obj:FindPartByCFrame(obj:FindFirstChildOfClass("Part").CFrame)) do
                                    part.CanCollide = false
                                end
                            end
                        end)
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

-- Maintain player speed
humanoid:GetPropertyChangedSignal("WalkSpeed"):Connect(function()
    if humanoid.WalkSpeed < PLAYER_SPEED then
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
    
    -- Auto-open doors
    autoOpenDoors()
end)

print("✓ ULTRA EASY MODE ACTIVATED!")
print("⚡ Speed: 100 (insane!)")
print("❤️ Health: 9999 (God mode)")
print("📈 Jump Power: 200")
print("🚪 Auto-opens doors within 50 studs")
print("😎 Pure chill mode - doors open as you approach!")
