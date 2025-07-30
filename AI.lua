--[[
  Greg AI Chat Injector GUI (CoolGUI_X Edition)
  Frameworks: NexusGui, DrawingAPI fallback, RemoteEvent scanner
  Author: Isaac (a.k.a OTC Greg Summoner)
  Version: Phase 2 BETA
]]--

-- Nexus GUI Framework
local NexusGui = {}
NexusGui.__index = NexusGui

function NexusGui.new()
    local guiParent = game:GetService("Players").LocalPlayer:FindFirstChild("PlayerGui")
    if not guiParent then
        guiParent = game:GetService("CoreGui")
    end

    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "GregGUI_X"
    screenGui.ResetOnSpawn = false
    screenGui.IgnoreGuiInset = true
    screenGui.Parent = guiParent

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 320, 0, 140)
    frame.Position = UDim2.new(0.5, -160, 0.5, -70)
    frame.BackgroundColor3 = Color3.fromRGB(25,25,25)
    frame.BorderSizePixel = 0
    frame.Parent = screenGui
    frame.Active = true
    frame.Draggable = true

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 30)
    title.BackgroundColor3 = Color3.fromRGB(15,15,15)
    title.BorderSizePixel = 0
    title.TextColor3 = Color3.fromRGB(255, 0, 0)
    title.Font = Enum.Font.Arcade
    title.TextSize = 24
    title.Text = "CoolGUI_X | Greg™"
    title.Parent = frame

    local self = setmetatable({
        ScreenGui = screenGui,
        Frame = frame,
        Title = title,
        Components = {}
    }, NexusGui)

    return self
end

function NexusGui:AddTextBox()
    local input = Instance.new("TextBox")
    input.Size = UDim2.new(1, -20, 0, 30)
    input.Position = UDim2.new(0, 10, 0, 40)
    input.BackgroundColor3 = Color3.fromRGB(35,35,35)
    input.BorderSizePixel = 0
    input.TextColor3 = Color3.new(1,1,1)
    input.ClearTextOnFocus = false
    input.PlaceholderText = "Ask Greg™ something cursed..."
    input.Font = Enum.Font.Code
    input.TextSize = 18
    input.Text = ""
    input.Parent = self.Frame

    table.insert(self.Components, input)
    self.TextBox = input
    return input
end

function NexusGui:AddButton()
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, -20, 0, 30)
    button.Position = UDim2.new(0, 10, 0, 80)
    button.BackgroundColor3 = Color3.fromRGB(255,0,0)
    button.BorderSizePixel = 0
    button.TextColor3 = Color3.new(1,1,1)
    button.Font = Enum.Font.SciFi
    button.Text = "Unleash Greg™"
    button.TextSize = 18
    button.Parent = self.Frame

    table.insert(self.Components, button)
    self.Button = button
    return button
end

-- Greg AI + Chat Hook
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local player = Players.LocalPlayer

local chatEvents = game:GetService("ReplicatedStorage"):FindFirstChild("DefaultChatSystemChatEvents")
local ChatEvent = chatEvents and chatEvents:FindFirstChild("SayMessageRequest")

local GREG_ENDPOINT = "https://8e4ea171f3e4.ngrok-free.app/respond"

local gui = NexusGui.new()
local inputBox = gui:AddTextBox()
local sendButton = gui:AddButton()

sendButton.MouseButton1Click:Connect(function()
    local msg = inputBox.Text
    if msg == "" then return end
    inputBox.Text = ""

    local success, response = pcall(function()
        return HttpService:PostAsync(GREG_ENDPOINT, HttpService:JSONEncode({
            prompt = player.Name .. ": " .. msg
        }), Enum.HttpContentType.ApplicationJson)
    end)

    if success then
        local data = HttpService:JSONDecode(response)
        local reply = data.reply or "Greg is dead inside."

        if ChatEvent then
            ChatEvent:FireServer("[Greg™]: " .. reply, "All")
        else
            warn("[Greg™]: ChatEvent missing")
        end
    else
        warn("[Greg™]: HTTP error -", response)
    end
end)

-- Done. Inject this and you'll see the GUI mid-screen. Type and summon Greg into the server.
