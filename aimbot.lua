local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- CONFIGURAÇÕES
local VELOCIDADE_MIRA = 0.9 
local FOV_RAIO = 180 
_G.AimbotAtivado = true

-- INTERFACE OTIMIZADA (Não bloqueia os controles)
local function criarMenu()
    -- Se já existir um menu, remove para não duplicar
    if LocalPlayer:WaitForChild("PlayerGui"):FindFirstChild("DeltaAimbotSafe") then
        LocalPlayer.PlayerGui.DeltaAimbotSafe:Destroy()
    end

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "DeltaAimbotSafe"
    -- ResetOnSpawn falso evita que o botão suma quando você morre
    ScreenGui.ResetOnSpawn = false 
    -- IgnoreGuiInset garante que o botão não empurre os controles do jogo
    ScreenGui.IgnoreGuiInset = true 
    ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

    local MainButton = Instance.new("TextButton")
    MainButton.Size = UDim2.new(0, 110, 0, 40)
    -- Posição alterada para o topo direito (longe do analógico e do botão de pulo)
    MainButton.Position = UDim2.new(0.8, 0, 0.05, 0) 
    MainButton.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    MainButton.BackgroundTransparency = 0.3 -- Um pouco transparente para ver o mapa atrás
    MainButton.TextColor3 = Color3.fromRGB(0, 255, 127)
    MainButton.Text = "AIM: LIGADO"
    MainButton.Font = Enum.Font.GothamBold
    MainButton.TextSize = 14
    MainButton.Parent = ScreenGui

    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 10)
    Corner.Parent = MainButton

    MainButton.MouseButton1Click:Connect(function()
        _G.AimbotAtivado = not _G.AimbotAtivado
        if _G.AimbotAtivado then
            MainButton.Text = "AIM: LIGADO"
            MainButton.TextColor3 = Color3.fromRGB(0, 255, 127)
        else
            MainButton.Text = "AIM: DESLIGADO"
            MainButton.TextColor3 = Color3.fromRGB(255, 50, 50)
        end
    end)
end

-- CHECAGEM DE VISIBILIDADE
local function estaVisivel(targetPart)
    local character = LocalPlayer.Character
    if not character then return false end
    local params = RaycastParams.new()
    params.FilterDescendantsInstances = {character, Camera}
    params.FilterType = Enum.RaycastFilterType.Exclude
    local result = workspace:Raycast(Camera.CFrame.Position, (targetPart.Position - Camera.CFrame.Position).Unit * 500, params)
    return result and result.Instance:IsDescendantOf(targetPart.Parent)
end

-- BUSCA DE ALVO
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

-- LOOP
RunService.RenderStepped:Connect(function()
    if _G.AimbotAtivado then
        local alvo = getTarget()
        if alvo then
            Camera.CFrame = Camera.CFrame:Lerp(CFrame.lookAt(Camera.CFrame.Position, alvo.Position), VELOCIDADE_MIRA)
            local tool = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Tool")
            if tool then tool:Activate() end
        end
    end
end)

criarMenu()
