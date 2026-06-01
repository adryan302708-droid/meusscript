--[[ 
ESP de barra de vida ultra-moderna: vidro, gradiente, efeito neon e números!
Com cores específicas para herbívoros (branco) e outros (amarelo)
COM SISTEMA DE ATIVAR/DESATIVAR PELA TECLA K (CORRIGIDO)
--]]

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

-- Configuração
local ESP_ENABLED = true  -- Começa ativado
local TOGGLE_KEY = Enum.KeyCode.K  -- Tecla para ativar/desativar

-- Lista de herbívoros comuns em jogos de dinossauro
local herbivores = {
    -- Herbívoros clássicos
    "Triceratops", "Stegosaurus", "Brachiosaurus", "Diplodocus", "Parasaurolophus",
    "Ankylosaurus", "Pachycephalosaurus", "Gallimimus", "Iguanodon", "Camarasaurus",
    "Apatosaurus", "Argentinosaurus", "Kentrosaurus", "Styracosaurus", "Protoceratops",
    "Edmontosaurus", "Hadrosaurus", "Maiasaura", "Ouranosaurus", "Psittacosaurus",
    -- Herbívoros pequenos/médios
    "Hypsilophodon", "Leaellynasaura", "Dryosaurus", "Oryctodromeus", "Thescelosaurus",
    "Plateosaurus", "Massospondylus", "Mussaurus", "Saltasaurus", "Amargasaurus",
    -- Mais herbívoros populares
    "Therizinosaurus", "Deinocheirus", "Oviraptor", "Citipati", "Corythosaurus",
    "Lambeosaurus", "Tsintaosaurus", "Shantungosaurus", "Edmontonia", "Euoplocephalus",
    "Saichania", "Pinacosaurus", "Zuniceratops", "Einiosaurus", "Centrosaurus"
}

-- Tabela para armazenar todas as conexões ativas
local activeConnections = {}
local activePlayers = {}
local pendingPlayers = {} -- Jogadores que aguardam ESP

-- Função para verificar se um dinossauro é herbívoro
function isHerbivore(dinoName)
    if not dinoName then return false end
    local lowerName = dinoName:lower()
    for _, herb in pairs(herbivores) do
        if lowerName:find(herb:lower()) or herb:lower():find(lowerName) then
            return true
        end
    end
    return false
end

-- Função para obter a cor baseada no tipo de dinossauro
function getDinoColor(dinoName)
    if isHerbivore(dinoName) then
        return Color3.fromRGB(255, 255, 255) -- Branco para herbívoros
    else
        return Color3.fromRGB(255, 255, 0) -- Amarelo para outros (carnívoros/onívoros)
    end
end

function addHighlight(char, dinoType)
    -- Remove highlight antigo se existir
    if char:FindFirstChild("ESP_Highlight") then
        char.ESP_Highlight:Destroy()
    end
    
    local hg = Instance.new("Highlight")
    hg.Name = "ESP_Highlight"
    hg.FillTransparency = 1
    hg.OutlineTransparency = 0
    hg.OutlineColor = getDinoColor(dinoType)
    hg.Parent = char
    hg.Enabled = ESP_ENABLED
end

function addHealthBar(char, dinoType)
    -- Remove health bar antiga se existir
    if char:FindFirstChild("ESP_HealthBar") then
        char.ESP_HealthBar:Destroy()
    end
    
    local dinoColor = getDinoColor(dinoType)
    local neonColor = dinoType == "herbivore" and Color3.fromRGB(255,255,200) or Color3.fromRGB(255,200,0)
    
    local gui = Instance.new("BillboardGui")
    gui.Name = "ESP_HealthBar"
    gui.Size = UDim2.new(4,0,0.7,0)
    gui.StudsOffset = Vector3.new(0,6.2,0)
    gui.AlwaysOnTop = true
    gui.MaxDistance = 500
    gui.Enabled = ESP_ENABLED
    gui.Parent = char

    local glass = Instance.new("Frame", gui)
    glass.Name = "Glass"
    glass.Size = UDim2.new(1,0,1,0)
    glass.BackgroundColor3 = dinoType == "herbivore" and Color3.fromRGB(60,60,66) or Color3.fromRGB(40,60,66)
    glass.BackgroundTransparency = 0.35
    glass.BorderSizePixel = 0

    -- Glow/Neon Glass Effect com cor específica
    local glassGlow = Instance.new("UIStroke", glass)
    glassGlow.Thickness = 4
    glassGlow.Color = neonColor
    glassGlow.Transparency = 0.64
    glassGlow.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    local glassCorner = Instance.new("UICorner", glass)
    glassCorner.CornerRadius = UDim.new(1,0)

    -- Sombra furta-cor suave abaixo da barra
    local shadow = Instance.new("Frame", glass)
    shadow.Name = "Shadow"
    shadow.Size = UDim2.new(0.94,0,0.19,0)
    shadow.Position = UDim2.new(0.03,0,0.71,0)
    shadow.BackgroundColor3 = neonColor
    shadow.BackgroundTransparency = 0.7
    shadow.BorderSizePixel = 0
    shadow.ZIndex = 0
    local shadowCorner = Instance.new("UICorner", shadow)
    shadowCorner.CornerRadius = UDim.new(1,0)
    local shadowGradient = Instance.new("UIGradient", shadow)
    
    if dinoType == "herbivore" then
        shadowGradient.Color = ColorSequence.new{
            ColorSequenceKeypoint.new(0, Color3.fromRGB(200,200,255)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(255,255,200)),
        }
    else
        shadowGradient.Color = ColorSequence.new{
            ColorSequenceKeypoint.new(0, Color3.fromRGB(255,200,0)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(255,255,100)),
        }
    end
    
    shadowGradient.Transparency = NumberSequence.new{
        NumberSequenceKeypoint.new(0,0.9),
        NumberSequenceKeypoint.new(0.5,0.7),
        NumberSequenceKeypoint.new(1,1),
    }

    -- Barra real com gradiente
    local bar = Instance.new("Frame", glass)
    bar.Name = "Bar"
    bar.Position = UDim2.new(0.03,0,0.21,0)
    bar.Size = UDim2.new(0.94,0,0.58,0)
    bar.BackgroundColor3 = dinoType == "herbivore" and Color3.fromRGB(200,255,200) or Color3.fromRGB(0,255,128)
    bar.BorderSizePixel = 0
    bar.ZIndex = 2
    local barCorner = Instance.new("UICorner", bar)
    barCorner.CornerRadius = UDim.new(1,0)
    local neonGrad = Instance.new("UIGradient", bar)
    neonGrad.Name = "Neon"
    
    if dinoType == "herbivore" then
        neonGrad.Color = ColorSequence.new{
            ColorSequenceKeypoint.new(0,Color3.fromRGB(200,255,200)),
            ColorSequenceKeypoint.new(1,Color3.fromRGB(255,255,200)),
        }
    else
        neonGrad.Color = ColorSequence.new{
            ColorSequenceKeypoint.new(0,Color3.fromRGB(0,255,160)),
            ColorSequenceKeypoint.new(1,Color3.fromRGB(255,200,0)),
        }
    end

    -- Efeito pulsante animado na barra
    local pulseConnection
    pulseConnection = RunService.RenderStepped:Connect(function()
        if bar and bar.Parent and ESP_ENABLED then
            neonGrad.Offset = Vector2.new(math.sin(tick())*0.15, 0)
        end
    end)
    
    -- Armazena a conexão para limpeza
    table.insert(activeConnections, pulseConnection)

    -- Texto central em negrito com sombra
    local txt = Instance.new("TextLabel", glass)
    txt.Name = "LifeText"
    txt.BackgroundTransparency = 1
    txt.Position = UDim2.new(0,0,0,0)
    txt.Size = UDim2.new(1,0,1,0)
    txt.Font = Enum.Font.GothamBlack
    txt.TextScaled = true
    txt.Text = "Vida"
    txt.TextColor3 = dinoType == "herbivore" and Color3.fromRGB(255,255,230) or Color3.fromRGB(230,255,255)
    txt.TextStrokeTransparency = 0.26
    txt.TextStrokeColor3 = dinoType == "herbivore" and Color3.fromRGB(50,50,35) or Color3.fromRGB(0,25,35)
    txt.ZIndex = 3
end

function updateHealthBar(char)
    if not ESP_ENABLED then return end
    
    local gui = char:FindFirstChild("ESP_HealthBar")
    local humanoid = char:FindFirstChildWhichIsA("Humanoid")
    if not gui or not humanoid then return end
    local glass = gui:FindFirstChild("Glass")
    local bar = glass and glass:FindFirstChild("Bar")
    local txt = glass and glass:FindFirstChild("LifeText")
    local neonGrad = bar and bar:FindFirstChild("Neon")
    if not (bar and txt and neonGrad) then return end
    local health = math.max(humanoid.Health,0)
    local maxH = humanoid.MaxHealth > 0 and humanoid.MaxHealth or 1
    local pct = math.clamp(health/maxH,0,1)
    local finalW = 0.94 * pct
    bar.Size = UDim2.new(finalW,0,0.58,0)

    -- Cor de gradiente baseada na porcentagem de vida
    local hsv = Color3.fromHSV(pct * 0.33, 1, 1)
    bar.BackgroundColor3 = hsv
    
    -- Atualiza o gradiente baseado no tipo de dinossauro
    local dinoType = char:GetAttribute("DinoType") or "unknown"
    if dinoType == "herbivore" then
        neonGrad.Color = ColorSequence.new{
            ColorSequenceKeypoint.new(0, hsv),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(255,255,200))
        }
    else
        neonGrad.Color = ColorSequence.new{
            ColorSequenceKeypoint.new(0, hsv),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(255,200,0))
        }
    end
    
    txt.Text = string.format("<b>%d / %d</b>",health,maxH)
    txt.RichText = true
    txt.TextColor3 = hsv:Lerp(Color3.fromRGB(230,255,255), 0.55*(1-pct))
end

function cleanupESP(char)
    if char:FindFirstChild("ESP_Highlight") then 
        char.ESP_Highlight:Destroy()
    end
    if char:FindFirstChild("ESP_HealthBar") then 
        char.ESP_HealthBar:Destroy()
    end
end

-- Função para desativar completamente o ESP
function disableESP()
    ESP_ENABLED = false
    
    -- Desativa todos os Highlights e HealthBars
    for _, player in pairs(Players:GetPlayers()) do
        if player.Character then
            local highlight = player.Character:FindFirstChild("ESP_Highlight")
            if highlight then
                highlight.Enabled = false
            end
            
            local healthBar = player.Character:FindFirstChild("ESP_HealthBar")
            if healthBar then
                healthBar.Enabled = false
            end
        end
    end
    
    print("[ESP] DESATIVADO - Pressione K para ativar")
end

-- Função para recriar ESP para um jogador específico
function refreshESPForPlayer(player)
    if player == LocalPlayer then
        if LocalPlayer.Character then
            local dinoName = getDinoNameFromCharacter(LocalPlayer.Character)
            local isHerb = isHerbivore(dinoName)
            local dinoType = isHerb and "herbivore" or "carnivore"
            LocalPlayer.Character:SetAttribute("DinoType", dinoType)
            LocalPlayer.Character:SetAttribute("DinoName", dinoName)
            addHighlight(LocalPlayer.Character, dinoType)
            addHealthBar(LocalPlayer.Character, dinoType)
            updateHealthBar(LocalPlayer.Character)
        end
    else
        if player.Character then
            local dinoName = getDinoNameFromCharacter(player.Character)
            local isHerb = isHerbivore(dinoName)
            local dinoType = isHerb and "herbivore" or "carnivore"
            player.Character:SetAttribute("DinoType", dinoType)
            player.Character:SetAttribute("DinoName", dinoName)
            addHighlight(player.Character, dinoType)
            addHealthBar(player.Character, dinoType)
            updateHealthBar(player.Character)
        end
    end
end

-- Função para recriar ESP para todos os jogadores
function refreshESPForAllPlayers()
    for _, player in pairs(Players:GetPlayers()) do
        refreshESPForPlayer(player)
    end
end

-- Função para ativar completamente o ESP (RECRIANDO TUDO)
function enableESP()
    ESP_ENABLED = true
    
    -- Recria o ESP para todos os jogadores (garante que tudo esteja funcionando)
    refreshESPForAllPlayers()
    
    print("[ESP] ATIVADO - Pressione K para desativar")
end

-- Função para alternar o ESP
function toggleESP()
    if ESP_ENABLED then
        disableESP()
    else
        enableESP()
    end
end

-- Função para obter o nome do dinossauro do personagem
function getDinoNameFromCharacter(char)
    -- Tenta encontrar o nome em diferentes lugares comuns
    local nameParts = {}
    
    -- Verifica em partes do corpo/modelo
    for _, child in pairs(char:GetChildren()) do
        if child:IsA("Model") or child:IsA("MeshPart") or child:IsA("Part") then
            table.insert(nameParts, child.Name)
        end
    end
    
    -- Verifica o nome do personagem
    if char.Name and char.Name ~= "" then
        table.insert(nameParts, char.Name)
    end
    
    -- Verifica se tem um atributo especificando o tipo
    local dinoTypeAttr = char:GetAttribute("DinoType")
    if dinoTypeAttr then
        return dinoTypeAttr
    end
    
    local dinoNameAttr = char:GetAttribute("DinoName")
    if dinoNameAttr then
        return dinoNameAttr
    end
    
    -- Junta tudo e procura por nomes de dinossauros
    local fullName = table.concat(nameParts, " ")
    
    -- Verifica cada parte separadamente
    for _, part in pairs(nameParts) do
        for _, herb in pairs(herbivores) do
            if part:find(herb) or herb:find(part) then
                return herb
            end
        end
    end
    
    return fullName
end

function addSelfESP()
    local char = LocalPlayer.Character
    if not char then return end
    
    local dinoName = getDinoNameFromCharacter(char)
    local isHerb = isHerbivore(dinoName)
    local dinoType = isHerb and "herbivore" or "carnivore"
    
    -- Armazena o tipo no personagem para referência futura
    char:SetAttribute("DinoType", dinoType)
    char:SetAttribute("DinoName", dinoName)
    
    addHighlight(char, dinoType)
    addHealthBar(char, dinoType)
    
    local humanoid = char:FindFirstChildWhichIsA("Humanoid")
    if humanoid then
        local healthConn = humanoid.HealthChanged:Connect(function()
            updateHealthBar(char)
        end)
        table.insert(activeConnections, healthConn)
    end
    
    local connection
    connection = RunService.RenderStepped:Connect(function()
        if not char:IsDescendantOf(game) then
            if connection then connection:Disconnect() end
            cleanupESP(char)
            return
        end
        if ESP_ENABLED then
            updateHealthBar(char)
        end
    end)
    table.insert(activeConnections, connection)
    
    char.AncestryChanged:Connect(function(_,parent)
        if not char:IsDescendantOf(game) then
            if connection then connection:Disconnect() end
            cleanupESP(char)
        end
    end)
    
    updateHealthBar(char)
end

function espPlayer(player)
    if player == LocalPlayer then return end
    
    local function onchar(char)
        RunService.RenderStepped:Wait()
        
        local dinoName = getDinoNameFromCharacter(char)
        local isHerb = isHerbivore(dinoName)
        local dinoType = isHerb and "herbivore" or "carnivore"
        
        -- Armazena o tipo no personagem
        char:SetAttribute("DinoType", dinoType)
        char:SetAttribute("DinoName", dinoName)
        
        -- Só adiciona o ESP se estiver ativado
        if ESP_ENABLED then
            addHighlight(char, dinoType)
            addHealthBar(char, dinoType)
        end
        
        local humanoid = char:FindFirstChildWhichIsA("Humanoid")
        if humanoid then
            local healthConn = humanoid.HealthChanged:Connect(function()
                if ESP_ENABLED then
                    updateHealthBar(char)
                end
            end)
            table.insert(activeConnections, healthConn)
        end
        
        local cn
        cn = RunService.RenderStepped:Connect(function()
            if not char:IsDescendantOf(game) then
                if cn then cn:Disconnect() end
                cleanupESP(char)
                return
            end
            if ESP_ENABLED then
                updateHealthBar(char)
            end
        end)
        table.insert(activeConnections, cn)
        
        if ESP_ENABLED then
            updateHealthBar(char)
        end
        
        char.AncestryChanged:Connect(function(_,parent)
            if not char:IsDescendantOf(game) then
                if cn then cn:Disconnect() end
                cleanupESP(char)
            end
        end)
    end
    
    player.CharacterAdded:Connect(onchar)
    if player.Character then onchar(player.Character) end
end

-- Sistema de tecla para ativar/desativar
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if input.KeyCode == TOGGLE_KEY then
        toggleESP()
    end
end)

-- Adiciona ESP para todos os outros jogadores
for _,p in pairs(Players:GetPlayers()) do
    if p ~= LocalPlayer then
        espPlayer(p)
    end
end

-- Adiciona ESP para o próprio jogador
addSelfESP()

-- Conecta eventos
Players.PlayerAdded:Connect(espPlayer)

LocalPlayer.CharacterAdded:Connect(function(char)
    wait(0.1)
    addSelfESP()
end)

Players.PlayerRemoving:Connect(function(p)
    if p.Character then cleanupESP(p.Character) end
end)

-- Atualização periódica
spawn(function()
    while true do
        wait(5)
        if ESP_ENABLED and LocalPlayer.Character and not LocalPlayer.Character:FindFirstChild("ESP_HealthBar") then
            addSelfESP()
        end
    end
end)

-- Função manual para adicionar/atualizar tipos de dinossauros
_G.SetDinoType = function(character, isHerbivore)
    if not character then return end
    local dinoType = isHerbivore and "herbivore" or "carnivore"
    character:SetAttribute("DinoType", dinoType)
    
    -- Recria o ESP com a nova cor
    cleanupESP(character)
    addHighlight(character, dinoType)
    addHealthBar(character, dinoType)
    updateHealthBar(character)
end

-- Função para controlar o ESP manualmente via script
_G.EnableESP = enableESP
_G.DisableESP = disableESP
_G.ToggleESP = toggleESP

-- Função para recriar ESP manualmente
_G.RefreshESP = refreshESPForAllPlayers

print("ESP Carregado! Herbívoros = Branco | Outros = Amarelo")
print("Pressione K para ATIVAR/DESATIVAR o ESP (CORRIGIDO)")
print("Use _G.EnableESP(), _G.DisableESP() ou _G.ToggleESP() para controle manual")
print("Use _G.RefreshESP() para recriar o ESP manualmente")
