local InputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Player = game.Players.LocalPlayer

local SlideKeybind = Enum.KeyCode.LeftShift
local DashKeybind = Enum.KeyCode.Q

local SlidingEvent = script.Parent:WaitForChild("Events"):WaitForChild("SlideEvent")
local DashEvent = script.Parent:WaitForChild("Events"):WaitForChild("DashEvent")
local CamPosEvent = script.Parent:WaitForChild("Events"):WaitForChild("CamPos")

local LeftOrRight = nil
local HoldingW = false

local ServerScript = script.Parent.MSServer

CamPosEvent.OnClientInvoke = function()
	return game.Workspace.CurrentCamera.CFrame
end

InputService.InputBegan:Connect(function(Input, InGui)
	
	if not InGui then	

		if Input.KeyCode == Enum.KeyCode.A then
			
			LeftOrRight = "Left"
			SlidingEvent:FireServer(nil,LeftOrRight,HoldingW)
		
		elseif Input.KeyCode == Enum.KeyCode.D then
			
			LeftOrRight = "Right"
			SlidingEvent:FireServer(nil,LeftOrRight,HoldingW)
			
		end
		
		if Input.KeyCode == Enum.KeyCode.W then	
			
			HoldingW = true
			SlidingEvent:FireServer(nil,LeftOrRight,HoldingW)
			
		end
		
		if Input.KeyCode == SlideKeybind then
			
			SlidingEvent:FireServer(true,LeftOrRight,HoldingW)
				
		elseif Input.KeyCode == DashKeybind then
			
			DashEvent:FireServer()
				
		end
		
		
	end
	
end)

InputService.InputEnded:Connect(function(Input, InGui)
	if not InGui then
		
		if Input.KeyCode == Enum.KeyCode.A then

			LeftOrRight = nil
			SlidingEvent:FireServer(nil,LeftOrRight,HoldingW)

		elseif Input.KeyCode == Enum.KeyCode.D then

			LeftOrRight = nil
			SlidingEvent:FireServer(nil,LeftOrRight,HoldingW)
		end
		
		if Input.KeyCode == Enum.KeyCode.W then	
			HoldingW = false
			SlidingEvent:FireServer(nil,LeftOrRight,HoldingW)
		end
		
	end
	
	
	if InGui or Input.KeyCode == SlideKeybind then
		
		SlidingEvent:FireServer(false)
		
	end	
	
end)

local StaminaUiFolder = Player.PlayerGui:WaitForChild("ClientHpAndStamGui"):WaitForChild("StaminaBar")

RunService.RenderStepped:Connect(function()
	local HowManyStaminaSplits = math.ceil(ServerScript:GetAttribute("MaxStamina")/25)
	
	local MaxHeightOfBar = (ServerScript:GetAttribute("MaxStamina")-75)/1500 + 0.3 
	local SizeOfBar = UDim2.new(0.01,0,math.max(MaxHeightOfBar/(ServerScript:GetAttribute("MaxStamina")/ServerScript:GetAttribute("Stamina")),0),0)
	local PositionOfBar = UDim2.new(0.183,0,0.615 + math.min((-MaxHeightOfBar)/(ServerScript:GetAttribute("MaxStamina")/ServerScript:GetAttribute("Stamina")),0) + 0.3,0)
	
	StaminaUiFolder.TheStaminaBarFrame.Size = SizeOfBar
	StaminaUiFolder.TheStaminaBarFrame.Position = PositionOfBar
	
	StaminaUiFolder.StaminaNumber.Text = math.floor(ServerScript:GetAttribute("Stamina")) .. "/" .. math.floor(ServerScript:GetAttribute("MaxStamina"))
	StaminaUiFolder.StaminaNumber.Position = UDim2.new(0.14,0,0.615 + math.min((-MaxHeightOfBar)/(ServerScript:GetAttribute("MaxStamina")/ServerScript:GetAttribute("Stamina")),0) + 0.25,0)
	
	local ColorGradingAmount = math.ceil(math.lerp(0,HowManyStaminaSplits,(1+ServerScript:GetAttribute("Stamina"))/ServerScript:GetAttribute("MaxStamina")))
	local AmountOfColor = Color3.new(0.12549, 1, 0.941176):Lerp(Color3.new(0.0313725, 0, 1),1-(ColorGradingAmount/HowManyStaminaSplits))
	StaminaUiFolder.TheStaminaBarFrame.BackgroundColor3 = AmountOfColor
	
	if not ServerScript:GetAttribute("CanSlide") then
		
		print("CantSlide")
		
	end
	
end)

