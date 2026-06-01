--[[
    AIMBOT TESTE PARA RIVALS
    - Versão simples e direta
--]]

repeat wait() until game:IsLoaded()

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local Camera = workspace.CurrentCamera
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- Configurações
local aimbotEnabled = true
local smoothness = 5
local fovRadius = 150
local aimPart = "Head"

local isShooting = false

-- Função para pegar inimigos vivos
local function getEnemies()
    local enemies = {}
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then
            local char = p.Character
            if char and char.Parent then
                local humanoid = char:FindFirstChild("Humanoid")
                if humanoid and humanoid.Health and humanoid.Health > 0 then
                    local root = char:FindFirstChild("HumanoidRootPart")
                    if root then
                        table.insert(enemies, {
                            player = p,
                            character = char,
                            rootPart = root
                        })
                    end
                end
            end
        end
    end
    return enemies
end

-- Função para pegar o inimigo mais próximo da mira
local function getClosestEnemy()
    local closest = nil
    local closestDist = fovRadius
    local mousePos = Vector2.new(Mouse.X, Mouse.Y)
    
    local enemies = getEnemies()
    
    for _, enemy in ipairs(enemies) do
        local targetPart = enemy.character:FindFirstChild(aimPart) or enemy.rootPart
        if targetPart then
            local screenPos, onScreen = Camera:WorldToScreenPoint(targetPart.Position)
            if onScreen then
                local dist = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).magnitude
                if dist < closestDist then
                    closestDist = dist
                    closest = targetPart
                end
            end
        end
    end
    
    return closest
end

-- Aimbot: mira no inimigo
local function doAimbot()
    if not aimbotEnabled then return end
    if not isShooting then return end
    
    local target = getClosestEnemy()
    if target then
        local targetPos = target.Position
        local newCFrame = CFrame.new(Camera.CFrame.Position, targetPos)
        
        if smoothness > 1 then
            -- Mira suave
            Camera.CFrame = Camera.CFrame:Lerp(newCFrame, 0.2)
        else
            -- Mira instantânea
            Camera.CFrame = newCFrame
        end
    end
end

-- Quando segura o botão de atirar
Mouse.Button1Down:Connect(function()
    isShooting = true
    print("🔫 Atirando - Aimbot ativado!")
end)

-- Quando solta o botão de atirar
Mouse.Button1Up:Connect(function()
    isShooting = false
    print("🔫 Parou de atirar - Aimbot desativado")
end)

-- Também detectar pelo teclado/mouse
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        isShooting = true
        print("🔫 InputBegan - Aimbot ativado!")
    end
end)

UserInputService.InputEnded:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        isShooting = false
        print("🔫 InputEnded - Aimbot desativado")
    end
end)

-- Loop do aimbot (executa a cada frame)
RunService.RenderStepped:Connect(function()
    doAimbot()
end)

-- ========== PAINEL SIMPLES ==========
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "AimbotTest"
screenGui.Parent = PlayerGui

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 300, 0, 200)
mainFrame.Position = UDim2.new(0.5, -150, 0.3, 0)
mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
mainFrame.BorderSizePixel = 2
mainFrame.BorderColor3 = Color3.fromRGB(0, 255, 0)
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Visible = true
mainFrame.Parent = screenGui

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 30)
title.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
title.Text = "AIMBOT TESTE"
title.TextColor3 = Color3.new(1, 1, 1)
title.Font = Enum.Font.GothamBold
title.TextSize = 14
title.Parent = mainFrame

-- Botão ativar/desativar
local toggleBtn = Instance.new("TextButton")
toggleBtn.Size = UDim2.new(0.8, 0, 0, 40)
toggleBtn.Position = UDim2.new(0.1, 0, 0.3, 0)
toggleBtn.Text = "AIMBOT: ON"
toggleBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
toggleBtn.TextColor3 = Color3.new(1, 1, 1)
toggleBtn.Font = Enum.Font.GothamBold
toggleBtn.TextSize = 16
toggleBtn.Parent = mainFrame

toggleBtn.MouseButton1Click:Connect(function()
    aimbotEnabled = not aimbotEnabled
    toggleBtn.Text = aimbotEnabled and "AIMBOT: ON" or "AIMBOT: OFF"
    toggleBtn.BackgroundColor3 = aimbotEnabled and Color3.fromRGB(0, 200, 0) or Color3.fromRGB(200, 0, 0)
    print("Aimbot:", aimbotEnabled and "Ativado" or "Desativado")
end)

-- Slider de suavidade
local smoothLabel = Instance.new("TextLabel")
smoothLabel.Size = UDim2.new(0.8, 0, 0, 20)
smoothLabel.Position = UDim2.new(0.1, 0, 0.55, 0)
smoothLabel.Text = "Suavidade: " .. smoothness
smoothLabel.TextColor3 = Color3.new(1, 1, 1)
smoothLabel.BackgroundTransparency = 1
smoothLabel.Font = Enum.Font.Gotham
smoothLabel.TextSize = 12
smoothLabel.Parent = mainFrame

local smoothSlider = Instance.new("TextButton")
smoothSlider.Size = UDim2.new(0.8, 0, 0, 8)
smoothSlider.Position = UDim2.new(0.1, 0, 0.65, 0)
smoothSlider.BackgroundColor3 = Color3.fromRGB(80, 80, 90)
smoothSlider.BorderSizePixel = 0
smoothSlider.AutoButtonColor = false
smoothSlider.Parent = mainFrame

local smoothFill = Instance.new("Frame")
smoothFill.Size = UDim2.new(smoothness / 20, 0, 1, 0)
smoothFill.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
smoothFill.BorderSizePixel = 0
smoothFill.Parent = smoothSlider

local dragging = false

smoothSlider.MouseButton1Down:Connect(function()
    dragging = true
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local relX = math.clamp((Mouse.X - smoothSlider.AbsolutePosition.X) / smoothSlider.AbsoluteSize.X, 0, 1)
        smoothness = math.floor(1 + relX * 19)
        smoothFill.Size = UDim2.new(relX, 0, 1, 0)
        smoothLabel.Text = "Suavidade: " .. smoothness
    end
end)

-- Status
local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(1, 0, 0, 25)
statusLabel.Position = UDim2.new(0, 0, 0.85, 0)
statusLabel.Text = "Status: Segure o botão esquerdo"
statusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
statusLabel.BackgroundTransparency = 1
statusLabel.Font = Enum.Font.Gotham
statusLabel.TextSize = 11
statusLabel.Parent = mainFrame

-- Tecla INSERT para fechar
UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.Insert then
        mainFrame.Visible = not mainFrame.Visible
    end
end)

print("✅ Script de teste carregado!")
print("📌 SEGURE o botão esquerdo do mouse para ativar o aimbot")
print("📌 Olhe no console (F9) para ver as mensagens")
print("📌 Pressione INSERT para esconder/mostrar o painel")
