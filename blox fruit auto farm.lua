-- Services
local TweenService = game:GetService("TweenService")
local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
local workspace = game:GetService("Workspace")
local runService = game:GetService("RunService")
local replicatedStorage = game:GetService("ReplicatedStorage")
local compass = replicatedStorage:WaitForChild("Compass") -- Assuming Compass is relevant for questing

-- UI Setup for Mod Menu
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Parent = player:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 200, 0, 250)
frame.Position = UDim2.new(0, 10, 0, 10)
frame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
frame.Parent = ScreenGui

local autoFarmButton = Instance.new("TextButton")
autoFarmButton.Size = UDim2.new(0, 180, 0, 50)
autoFarmButton.Position = UDim2.new(0, 10, 0, 10)
autoFarmButton.Text = "Toggle Auto Farm"
autoFarmButton.Parent = frame

local autoQuestButton = Instance.new("TextButton")
autoQuestButton.Size = UDim2.new(0, 180, 0, 50)
autoQuestButton.Position = UDim2.new(0, 10, 0, 70)
autoQuestButton.Text = "Toggle Auto Quest"
autoQuestButton.Parent = frame

local teleportButton = Instance.new("TextButton")
teleportButton.Size = UDim2.new(0, 180, 0, 50)
teleportButton.Position = UDim2.new(0, 10, 0, 130)
teleportButton.Text = "Teleport to Quest"
teleportButton.Parent = frame

-- Variables for toggles
local autoFarmActive = false
local autoQuestActive = false
local currentQuest = nil
local nextQuestNPC = nil

-- Toggle Functions
autoFarmButton.MouseButton1Click:Connect(function()
    autoFarmActive = not autoFarmActive
    print("Auto Farm: " .. tostring(autoFarmActive))
end)

autoQuestButton.MouseButton1Click:Connect(function()
    autoQuestActive = not autoQuestActive
    print("Auto Quest: " .. tostring(autoQuestActive))
end)

teleportButton.MouseButton1Click:Connect(function()
    teleportToQuestLocation()
end)

-- Helper Functions
local function findQuestNPC()
    -- Find the closest NPC that gives the next quest (placeholder logic, replace based on game structure)
    for _, npc in pairs(workspace:GetChildren()) do
        if npc:FindFirstChild("HumanoidRootPart") and npc:FindFirstChild("QuestGiver") then
            return npc
        end
    end
    return nil
end

-- Function to interact with the NPC and start a new quest
local function startNewQuest(npc)
    -- Interact with the NPC and start the quest
    local questButton = npc:FindFirstChild("QuestButton")
    if questButton then
        questButton:Click()
        print("Quest started: " .. npc.Name)
        currentQuest = npc.Name
    end
end

-- Function to teleport to a quest NPC location (automatically detected)
local function teleportToQuestLocation()
    if nextQuestNPC then
        humanoidRootPart.CFrame = nextQuestNPC.HumanoidRootPart.CFrame
        print("Teleported to: " .. nextQuestNPC.Name)
    end
end

-- Function to automatically detect the need for the next quest
local function detectNextQuest()
    -- Detect the nearest NPC that gives the next quest
    nextQuestNPC = findQuestNPC()
    
    if nextQuestNPC then
        -- Teleport to that NPC
        teleportToQuestLocation()
        -- Start the quest automatically
        startNewQuest(nextQuestNPC)
    end
end

-- Function to start farming/attacking enemies
local function startAutoFarm()
    -- Find closest enemy to the character
    local targetEnemy = findClosestEnemy()
    if targetEnemy then
        magnetToEnemy(targetEnemy)
        attackEnemy(targetEnemy)
    end
end

-- Main Loop: Handles auto quest, auto farm, and quest progression
runService.Heartbeat:Connect(function()
    if autoFarmActive then
        startAutoFarm()
    end
    
    if autoQuestActive then
        detectNextQuest()
    end
end)

-- Quest Completion Check (based on quest mechanics in the game)
function checkQuestCompletion(questName)
    -- Example logic to check if the quest is completed (customize this)
    return true -- Replace this with the actual condition that checks if the quest is completed
end

-- Function to find the closest enemy
function findClosestEnemy()
    local closestEnemy = nil
    local shortestDistance = math.huge
    for _, enemy in pairs(workspace:GetChildren()) do
        if enemy:FindFirstChild("HumanoidRootPart") and enemy ~= character then
            local distance = (humanoidRootPart.Position - enemy.HumanoidRootPart.Position).Magnitude
            if distance < shortestDistance then
                closestEnemy = enemy
                shortestDistance = distance
            end
        end
    end
    return closestEnemy
end

-- Function to magnet to the enemy
function magnetToEnemy(enemy)
    humanoidRootPart.CFrame = CFrame.new(enemy.HumanoidRootPart.Position)
end

-- Function to attack the enemy
function attackEnemy(enemy)
    local humanoid = enemy:FindFirstChild("Humanoid")
    if humanoid and humanoid.Health > 0 then
        humanoid:TakeDamage(10)  -- Adjust damage value here
    end
end

