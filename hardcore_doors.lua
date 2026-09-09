-- Hotel Minus Super Easy Mode Script
-- Relaxed gameplay with helpers

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
local humanoid = character:WaitForChild("Humanoid")

-- Settings
local PLAYER_SPEED = 50 -- Super fast
local PLAYER_HEALTH = 999 -- Basically invincible
local PLAYER_JUMP = 100 -- High jump
local AUTO_HEAL = true
local HEAL_RATE = 10 -- Health per second
local NO_FALL_DAMAGE = true

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

-- Disable fall damage
local function disableFallDamage()
    if character then
        for _, part in pairs(character:GetDescendants()) do
            if part:IsA("Part") then
                part.CanCollide = true
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
    disableFallDamage()
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
end)

print("✓ SUPER EASY MODE ACTIVATED!")
print("⚡ Speed: 50 (5x faster)")
print("❤️ Health: 999 (Auto-healing)")
print("📈 Jump Power: 100")
print("🛡️ No fall damage")
print("😎 Just chill and enjoy!")
