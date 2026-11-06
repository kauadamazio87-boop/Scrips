-- Carrega a biblioteca Rayfield
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- CONFIGURAÇÕES INICIAIS (Mantidas do seu script)
local VELOCIDADE_MIRA = 0.9 
local FOV_RAIO = 180 
local AimbotAtivado = true
local TiroAutomatico = true

-- ============================================
-- CRIA A JANELA DO RAYFIELD
-- ============================================
local Window = Rayfield:CreateWindow({
   Name = "Rayfield Aimbot",
   LoadingTitle = "Carregando...",
   LoadingSubtitle = "by Delta Mobile",
   ConfigurationSaving = { Enabled = false },
   KeySystem = false
})

local Tab = Window:CreateTab("Aimbot", 4483362458)

-- ============================================
-- CONTROLES DA INTERFACE
-- ============================================
Tab:CreateToggle({
   Name = "Ativar Aimbot",
   CurrentValue = AimbotAtivado,
   Flag = "AimbotToggle",
   Callback = function(State)
       AimbotAtivado = State
   end,
})

Tab:CreateToggle({
   Name = "Tiro Automático",
   CurrentValue = TiroAutomatico,
   Flag = "TiroAuto",
   Callback = function(State)
       TiroAutomatico = State
   end,
})

Tab:CreateSlider({
   Name = "Velocidade da Mira",
   Range = {10, 100},
   Increment = 5,
   Suffix = "%",
   CurrentValue = 90, -- 90 = 0.9
   Flag = "VelocidadeMira",
   Callback = function(Value)
       VELOCIDADE_MIRA = Value / 100
   end,
})

Tab:CreateSlider({
   Name = "Tamanho do FOV",
   Range = {50, 500},
   Increment = 10,
   Suffix = "px",
   CurrentValue = 180,
   Flag = "FOV",
   Callback = function(Value)
       FOV_RAIO = Value
   end,
})

-- ============================================
-- LÓGICA DO SEU AIMBOT (MANTIDA)
-- ============================================
local function estaVisivel(targetPart)
    local character = LocalPlayer.Character
    if not character then return false end
    local params = RaycastParams.new()
    params.FilterDescendantsInstances = {character, Camera}
    params.FilterType = Enum.RaycastFilterType.Exclude
    local result = workspace:Raycast(Camera.CFrame.Position, (targetPart.Position - Camera.CFrame.Position).Unit * 500, params)
    return result and result.Instance:IsDescendantOf(targetPart.Parent)
end

local function getTarget()
    local closest = nil
    local dist = FOV_RAIO
    local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)

    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("Head") then
            local hum = p.Character:FindFirstChild("Humanoid")
            if hum and hum.Health > 0 then
                local pos, onScreen = Camera:WorldToViewportPoint(p.Character.Head.Position)
                if onScreen then
                    local magnitude = (Vector2.new(pos.X, pos.Y) - center).Magnitude
                    if magnitude < dist and estaVisivel(p.Character.Head) then
                        dist = magnitude
                        closest = p.Character.Head
                    end
                end
            end
        end
    end
    return closest
end

-- ============================================
-- LOOP PRINCIPAL
-- ============================================
RunService.RenderStepped:Connect(function()
    if AimbotAtivado then
        local alvo = getTarget()
        if alvo then
            Camera.CFrame = Camera.CFrame:Lerp(CFrame.lookAt(Camera.CFrame.Position, alvo.Position), VELOCIDADE_MIRA)
            
            if TiroAutomatico then
                local tool = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Tool")
                if tool then tool:Activate() end
            end
        end
    end
end)

print("✅ Aimbot Rayfield carregado com sucesso!")
