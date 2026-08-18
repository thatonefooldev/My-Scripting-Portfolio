local MovementScript = script
local AttabuteTable = MovementScript:GetAttributes()
local Stamina = AttabuteTable.MaxStamina
local IsSprinting = false
local SprintingBuffer = false

local Humanoid = game.Players.LocalPlayer.Character.Humanoid
local cam = game.Workspace.CurrentCamera
local TweenService = game:GetService("TweenService")
local TweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, false, 0)

local RunService = game:GetService("RunService") 
local UserInputService = game:GetService("UserInputService")

--local MovementModule = require()



local TweenFOV = function()
	local CurrentVectorSpeed = script.Parent.HumanoidRootPart.AssemblyLinearVelocity * Vector3.new(1, 0, 1)
	local CurrentSpeed = CurrentVectorSpeed.Magnitude
	
	local Tweengoal
	if IsSprinting and CurrentSpeed > 1/2 * AttabuteTable.WalkSpeed  then
		Tweengoal = {FieldOfView = AttabuteTable.SprintSpeed * 4}
	elseif not IsSprinting or CurrentSpeed < 1/2 * AttabuteTable.WalkSpeed then
		Tweengoal = {FieldOfView = 70}
	end
	TweenService:Create(cam, TweenInfo,Tweengoal):Play()
	
end

function SprintBufferFunc()

	local OldStamgain = AttabuteTable.StaminaGain
	SprintingBuffer = true
	script:SetAttribute("StaminaGain",OldStamgain/2)
	task.spawn(TweenFOV)
	task.wait(2)
	script:SetAttribute("StaminaGain",OldStamgain)
	SprintingBuffer = false

end

RunService.RenderStepped:Connect(function(DeltaTime)
	
	pcall(function()
		
		local CurrentVectorSpeed = script.Parent.HumanoidRootPart.AssemblyLinearVelocity * Vector3.new(1, 0, 1)
		local CurrentSpeed = CurrentVectorSpeed.Magnitude
	

		if IsSprinting and not SprintingBuffer and CurrentSpeed > 1/2 * AttabuteTable.WalkSpeed then
			Humanoid.WalkSpeed = AttabuteTable.SprintSpeed
			Stamina -= AttabuteTable.StaminaDrain * DeltaTime
			local Tweengoal ={FieldOfView = AttabuteTable.SprintSpeed * 3}
			if Stamina <= 0 then
				IsSprinting = false
				task.spawn(SprintBufferFunc)
			end
		end

		if not IsSprinting or CurrentSpeed < 1/2 * AttabuteTable.WalkSpeed then

			Humanoid.WalkSpeed = AttabuteTable.WalkSpeed
			Stamina += AttabuteTable.StaminaGain * DeltaTime

		end
		Stamina = math.clamp(Stamina, 0, AttabuteTable.MaxStamina)
		MovementScript:SetAttribute("Stamina", Stamina)
		AttabuteTable = MovementScript:GetAttributes()

		
	end)

end)

UserInputService.InputBegan:Connect(function(input, gameProcessed)

	if not gameProcessed and input.KeyCode == Enum.KeyCode.LeftShift and Stamina > 0 and not SprintingBuffer then

		IsSprinting = true
		task.spawn(TweenFOV)
	end

end)

UserInputService.InputEnded:Connect(function(input, gameProcessed)

	if not gameProcessed and input.KeyCode == Enum.KeyCode.LeftShift then

		IsSprinting = false
		task.spawn(TweenFOV)
	end

end)
