local Charecter = script.Parent.Parent
local LocalPlayer = game.Players:GetPlayerFromCharacter(Charecter)
local SlidingEvent = script.Parent:WaitForChild("Events"):WaitForChild("SlideEvent")
local DashEvent = script.Parent:WaitForChild("Events"):WaitForChild("DashEvent")
local CamPosEvent = script.Parent:WaitForChild("Events"):WaitForChild("CamPos")
local SkateAnimation = script:WaitForChild("Skate")
local SkateJumpAnimation = script:WaitForChild("SkateJump")
local DashAnimation = script:WaitForChild("Dash")
local Debris = game:GetService("Debris")

local Sliding = false
local Directional = nil
local HoldingW = false
local CanSlide = true
local CanDash = true

local SlidingStaminaGainBuffer = false
local DashStaminaGainBuffer = false
local OutOfStamina = false

local StaminaCurrent = script:GetAttribute("MaxStamina")
local DeltaTime = 0.01
local TurnAngle = 35


local HumanoidRootPart = Charecter.HumanoidRootPart
local Humanoid = Charecter.Humanoid
local OldJumpPower = Charecter.Humanoid.JumpPower
local SetLinearVelocity = nil
local LinearVelocity = nil
local AlignOrientation = nil
local SkateingAnimationTrack = Humanoid:LoadAnimation(SkateAnimation)
local CamValue = CamPosEvent:InvokeClient(LocalPlayer)

function RemoveFriction(Model,Time)
	local Humanoid = Model:FindFirstChildOfClass("Humanoid")
	
	if Humanoid then

		Humanoid:ChangeState(Enum.HumanoidStateType.Physics)

	end
	for i,v in pairs(Model:GetChildren()) do
		
		
		
		
		if v:IsA("BasePart") then
			v.CustomPhysicalProperties = PhysicalProperties.new(v.CurrentPhysicalProperties.Density,0,0,100,0)
		end
		
	end
	task.wait(Time)
	if Humanoid then

		Humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)

	end

	for i,v in pairs(Model:GetChildren()) do

		if v:IsA("BasePart") then
			v.CustomPhysicalProperties = PhysicalProperties.new(v.CurrentPhysicalProperties.Density, 0.300000012, 0.5, 1, 1, 0.300000012)
		end

	end
end
local RSFire = 0
function RemoveSliding(Time)
	script:SetAttribute("CanSlide",false)
	RSFire +=1
	CanSlide = false
	task.wait(Time)
	RSFire -=1
	if RSFire == 0 then
		CanSlide = true
		script:SetAttribute("CanSlide",true)
	end
end
local OOSFireAmount = 0
function OutOfStaminaFunc(Time)
	OOSFireAmount += 1
	OutOfStamina = true
	task.spawn(RemoveSliding,Time + 0.75)
	CanDash = false
	task.wait(Time)
	OOSFireAmount -=1
	if OOSFireAmount == 0 then
		CanDash = true
		OutOfStamina = false
	end
	StaminaCurrent = 1
end
local SBFDFireAmount = 0
function StamBufferFuncForDash(Time)
	SBFDFireAmount += 1
	DashStaminaGainBuffer = true
	task.wait(Time)
	SBFDFireAmount -= 1
	if SBFDFireAmount == 0 then
		DashStaminaGainBuffer = false
	end
end

local InvFireAmount = 0

function GiveInvincibility(Time)
	InvFireAmount += 1
	if not Charecter:FindFirstChild("PlayerHurtBox") then return end
	
	Charecter:FindFirstChild("PlayerHurtBox"):SetAttribute("Invincible",true)
	
	task.wait(Time)
	InvFireAmount -=1
	if InvFireAmount == 0 then
		Charecter:FindFirstChild("PlayerHurtBox"):SetAttribute("Invincible",false)
	end
end

SlidingEvent.OnServerEvent:Connect(function(plr, IsSliding,DirectionOfSlide,HoldingWArg)
	
	if plr == LocalPlayer then
		if IsSliding ~= nil then
		Sliding = IsSliding 
		end
		Directional = DirectionOfSlide
		HoldingW = HoldingWArg
	end
	
end)

DashEvent.OnServerEvent:Connect(function(plr)
	
	if plr == LocalPlayer then
		if CanDash and StaminaCurrent >= 25 and not Sliding and Humanoid.MoveDirection.Magnitude > 0 then
			StaminaCurrent -= 25
			task.spawn(GiveInvincibility,0.15)
			script:SetAttribute("Stamina",StaminaCurrent)
			if StaminaCurrent <= 0 and not OutOfStamina then
				task.spawn(OutOfStaminaFunc,1.5)
			end
			task.spawn(StamBufferFuncForDash,0.25)
			local HumanoidRootPart = Charecter.HumanoidRootPart
			local DashLV = Instance.new("LinearVelocity")
			DashLV.Name = "DashLV"
			DashLV.MaxForce = 50000
			DashLV.ForceLimitsEnabled = true
			DashLV.ForceLimitMode = Enum.ForceLimitMode.PerAxis
			DashLV.MaxAxesForce = Vector3.new(50000, 50000, 50000)
			DashLV.VectorVelocity = (Humanoid.MoveDirection.Unit + Vector3.new(0,0.3,0)) * Vector3.new(1,1,1) * script:GetAttribute("DashPoints") * HumanoidRootPart.AssemblyMass
			DashLV.Attachment0 = HumanoidRootPart.RootAttachment
			DashLV.Parent = HumanoidRootPart
			task.spawn(RemoveFriction,Charecter,2)
			Debris:AddItem(DashLV,0.05)
		end
	end
	
end)


Humanoid.Died:Connect(function()
	script.Enabled = false
 end)


function ChangeCamValue()
	
	CamValue = CamPosEvent:InvokeClient(LocalPlayer)
	
end



while true do
	task.defer(ChangeCamValue)
	task.defer(function() 
		if LinearVelocity then
			if Humanoid.FloorMaterial == Enum.Material.Air then
				LinearVelocity.MaxAxesForce = Vector3.new(math.huge, 0, math.huge)
			else
				LinearVelocity.MaxAxesForce = Vector3.new(math.huge, 20000, math.huge)
			end

		end
	end)
	StaminaCurrent = math.clamp(StaminaCurrent,-100,script:GetAttribute("MaxStamina"))
	script:SetAttribute("Stamina",StaminaCurrent)
	
	if Sliding and CanSlide and not OutOfStamina and (Humanoid.MoveDirection.Magnitude > 0 or LinearVelocity) then
		Humanoid.JumpPower = (script:GetAttribute("SkateSpeed")*90/4)^0.6
		StaminaCurrent -= DeltaTime * 20 
		StaminaCurrent = math.clamp(StaminaCurrent,0,script:GetAttribute("MaxStamina"))
		SlidingStaminaGainBuffer = true
		HumanoidRootPart.Parent.Humanoid.AutoRotate = false
		
		Charecter.PlayerHurtBox.Size = Vector3.new(2,3,3)
		Charecter.PlayerCollisionBox.Size = Vector3.new(1.974, 2.973, 1.974)
		
		
		if not HumanoidRootPart:FindFirstChild("SlideLinearVelocity") then
			Charecter.PlayerHurtBox.Position -= Vector3.new(0,1,0)
			Charecter.PlayerCollisionBox.Position -= Vector3.new(0,1.5,0)
			local SkateBoardClone = game.ReplicatedStorage.Props.Sk8board:Clone()
			SkateBoardClone.Parent = Charecter
			local Motor6 = SkateBoardClone.Sk8board
			SkateBoardClone.CanCollide = false
			Motor6.Part0 = HumanoidRootPart
			Motor6.Parent = HumanoidRootPart
			
			
			
			
		
			SkateingAnimationTrack:Play(0)

			--Humanoid.HipHeight = -2.5
			LinearVelocity = Instance.new("LinearVelocity")
			LinearVelocity.Name = "SlideLinearVelocity"
			LinearVelocity.MaxForce = math.huge
			LinearVelocity.ForceLimitsEnabled = true
			LinearVelocity.ForceLimitMode = Enum.ForceLimitMode.PerAxis
			LinearVelocity.MaxAxesForce = Vector3.new(math.huge, 0, math.huge)
			LinearVelocity.VectorVelocity = Humanoid.MoveDirection.Unit * Vector3.new(1,0,1) * script:GetAttribute("SkateSpeed")
			SetLinearVelocity = LinearVelocity.VectorVelocity
			LinearVelocity.Attachment0 = HumanoidRootPart.RootAttachment
			LinearVelocity.Parent = HumanoidRootPart
			
			AlignOrientation = Instance.new("AlignOrientation")
			AlignOrientation.Name = "SlideAlignOrientation"
			AlignOrientation.MaxTorque = math.huge
			AlignOrientation.Responsiveness = 100
			AlignOrientation.Mode = Enum.OrientationAlignmentMode.OneAttachment
			AlignOrientation.RigidityEnabled = true
			AlignOrientation.CFrame = CFrame.new(Vector3.new(0,0,0),LinearVelocity.VectorVelocity)
			
			AlignOrientation.Attachment0 = HumanoidRootPart.RootAttachment
			AlignOrientation.Parent = HumanoidRootPart
			
			
			
		end
		
		if HoldingW  and SetLinearVelocity and LinearVelocity then
			
			
		
			SetLinearVelocity = (CamValue.LookVector * Vector3.new(1,0,1) * (script:GetAttribute("SkateSpeed")/40) + SetLinearVelocity*DeltaTime*40).Unit * script:GetAttribute("SkateSpeed")
			
			
			if Directional == "Left" then
				LinearVelocity.VectorVelocity = (TurnAngle/90 * Vector3.new(SetLinearVelocity.Z,0,-SetLinearVelocity.X) + SetLinearVelocity).Unit * script:GetAttribute("SkateSpeed")
			end

			if Directional == "Right" then
				LinearVelocity.VectorVelocity = (TurnAngle/90 * Vector3.new(-SetLinearVelocity.Z,0,SetLinearVelocity.X) + SetLinearVelocity ).Unit  * script:GetAttribute("SkateSpeed")
			end
			if Directional == nil then
				LinearVelocity.VectorVelocity = SetLinearVelocity
			end
			
			
			
		else
			SetLinearVelocity = (CamValue.LookVector * Vector3.new(1,0,1) * (script:GetAttribute("SkateSpeed")/40) + SetLinearVelocity*DeltaTime*40).Unit * script:GetAttribute("SkateSpeed")
			if Directional == "Left" then
				LinearVelocity.VectorVelocity = (TurnAngle/90 * Vector3.new(SetLinearVelocity.Z,0,-SetLinearVelocity.X) + SetLinearVelocity).Unit * script:GetAttribute("SkateSpeed")
			end

			if Directional == "Right" then
				LinearVelocity.VectorVelocity = (TurnAngle/90 * Vector3.new(-SetLinearVelocity.Z,0,SetLinearVelocity.X) + SetLinearVelocity ).Unit  * script:GetAttribute("SkateSpeed")
			end
			if Directional == nil then
				LinearVelocity.VectorVelocity = SetLinearVelocity
			end
		end
		

		if AlignOrientation then
			AlignOrientation.CFrame = CFrame.new(Vector3.new(0,0,0),LinearVelocity.VectorVelocity)
		end
		local RaycastParams = RaycastParams.new()
		RaycastParams.FilterType = Enum.RaycastFilterType.Exclude
		RaycastParams.ExcludeInstances = Charecter:GetDescendants()
		RaycastParams.IgnoreWater = true
		local Raycast = game.Workspace:Raycast(HumanoidRootPart.Position + Vector3.new(0,0,2)  ,HumanoidRootPart.CFrame.LookVector * script:GetAttribute("SkateSpeed")/4,RaycastParams)
		
		if Raycast then
			
			if Raycast.Instance.Parent then
				if not Raycast.Instance.Parent:FindFirstChild("Humanoid") and not Raycast.Instance.Parent:IsA("Accessory") then
					local ShouldBonk = true
					if Raycast.Instance:IsA("Part") then
						
						if Raycast.Instance.Shape == Enum.PartType.Wedge or Raycast.Instance.Shape == Enum.PartType.CornerWedge then
							if Raycast.Instance.Size.Y/(Raycast.Instance.Size * Vector3.new(1,0,1)).Magnitude < 1 then
								
								ShouldBonk = false
								
							end
						end
						
						if Raycast.Instance.Shape == Enum.PartType.Block then
							if Raycast.Instance.Orientation.Y < 45 and Raycast.Instance.Size.Y < 2 then
								
								ShouldBonk = false
								
							end
						end
						
					end
					
					if ShouldBonk then
						SkateingAnimationTrack:Stop(0)
						StaminaCurrent -= 35
						SetLinearVelocity = nil
						LinearVelocity = nil
						SlidingStaminaGainBuffer = false
						Humanoid.JumpPower = OldJumpPower
						Humanoid.HipHeight = 0
						Charecter.PlayerHurtBox.Size = Vector3.new(4,4,4)
						Charecter.PlayerHurtBox.Position += Vector3.new(0,1,0)
						Charecter.PlayerCollisionBox.Position += Vector3.new(0,1.5,0)
						Charecter.PlayerCollisionBox.Size = Vector3.new(1.974, 4.973, 1.974)
						
						if StaminaCurrent <= 0 then
				
							task.spawn(OutOfStaminaFunc,(StaminaCurrent/-35) * 6)
						
						end
			
						if HumanoidRootPart and HumanoidRootPart.Parent then
							HumanoidRootPart.Parent.Humanoid.AutoRotate = true
						end
						for i, v in pairs(HumanoidRootPart:GetChildren()) do
							if v.Name == "SlideLinearVelocity" or v.Name == "SlideAlignOrientation" or v.Name == "Sk8board" then
								v:Destroy()
							end

						end
						
						
						for i,v in pairs(Charecter:GetChildren()) do

							if v:IsA("BasePart") and v.Name == "Sk8board" then
								v:Destroy()
							end

						end

	
						
						task.spawn(RemoveSliding,2)	
						local HumanoidRootPart = Charecter.HumanoidRootPart
						local BonkLV = Instance.new("LinearVelocity")
						BonkLV.Name = "BonkLV"
						BonkLV.MaxForce = 50000
						BonkLV.ForceLimitsEnabled = true
						BonkLV.ForceLimitMode = Enum.ForceLimitMode.PerAxis
						BonkLV.MaxAxesForce = Vector3.new(50000, 50000, 50000)
						BonkLV.VectorVelocity = (HumanoidRootPart.CFrame.LookVector.Unit + Vector3.new(0,0.5,0) ) * Vector3.new(-1,1,-1) * script:GetAttribute("SkateSpeed")/7.5 * HumanoidRootPart.AssemblyMass
						BonkLV.Attachment0 = HumanoidRootPart.RootAttachment
						BonkLV.Parent = HumanoidRootPart
						task.spawn(RemoveFriction,Charecter,2)
						Debris:AddItem(BonkLV,0.05)
					end
				end
				
				if Raycast.Instance.Parent:FindFirstChild("Humanoid") and Raycast.Instance.Parent:FindFirstChild("PlayerHurtBox") and Raycast.Instance.Name == "PlayerHurtBox" then
					
					task.spawn(RemoveSliding,2.5)
					StaminaCurrent -= 15
					
					local HumanoidRootPart = Charecter.HumanoidRootPart
					local BonkLV = Instance.new("LinearVelocity")
					BonkLV.Name = "BonkLV"
					BonkLV.MaxForce = 50000
					BonkLV.ForceLimitsEnabled = true
					BonkLV.ForceLimitMode = Enum.ForceLimitMode.PerAxis
					BonkLV.MaxAxesForce = Vector3.new(50000, 50000, 50000)
					BonkLV.VectorVelocity = (HumanoidRootPart.CFrame.LookVector.Unit + Vector3.new(0,0.5,0) ) * Vector3.new(-1,1,-1) * script:GetAttribute("SkateSpeed")/12.5 * HumanoidRootPart.AssemblyMass
					BonkLV.Attachment0 = HumanoidRootPart.RootAttachment
					BonkLV.Parent = HumanoidRootPart
					task.spawn(RemoveFriction,Charecter,2)
					Debris:AddItem(BonkLV,0.05)
					
					if StaminaCurrent <= 0 then

						task.spawn(OutOfStaminaFunc,(StaminaCurrent/-35) * 6)

					end
					
					if not Raycast.Instance.Parent:FindFirstChild("PlayerHurtBox"):GetAttribute("Invincible") then
						if game.Players:GetPlayerFromCharacter(Raycast.Instance.Parent) then
							if game.Players:GetPlayerFromCharacter(Raycast.Instance.Parent).Team ~= LocalPlayer.Team then
								local Damage = math.max(0,(script:GetAttribute("SkateSpeed")-40) * 2)
								Raycast.Instance.Parent:FindFirstChild("Humanoid").Health -= Damage
							end
						else
							local Damage = math.max(0,(script:GetAttribute("SkateSpeed")-32.5) * 1.5)
							Raycast.Instance.Parent:FindFirstChild("Humanoid").Health -= Damage
						end
					
						if Raycast.Instance.Parent:FindFirstChild("HumanoidRootPart") then
							
							local OtherHumanoidRootPart = Raycast.Instance.Parent:FindFirstChild("HumanoidRootPart")
							local KockBackLV = Instance.new("LinearVelocity")
							KockBackLV.Name = "KockBackLV"
							KockBackLV.MaxForce = 50000
							KockBackLV.ForceLimitsEnabled = true
							KockBackLV.ForceLimitMode = Enum.ForceLimitMode.PerAxis
							KockBackLV.MaxAxesForce = Vector3.new(50000, 50000, 50000)
							KockBackLV.VectorVelocity = ((OtherHumanoidRootPart.CFrame.Position - HumanoidRootPart.CFrame.Position).Unit + Vector3.new(0,0.25,0) ) * Vector3.new(1,1,1) * script:GetAttribute("SkateSpeed")/4.5 * OtherHumanoidRootPart.AssemblyMass
							KockBackLV.Attachment0 = OtherHumanoidRootPart.RootAttachment
							KockBackLV.Parent = OtherHumanoidRootPart
							
							Debris:AddItem(KockBackLV,0.05)
						
						
						end
					end
				end
				
			end
		end
	end
	
	if (not Sliding or not CanSlide ) and  HumanoidRootPart:FindFirstChild("SlideLinearVelocity") then
		SetLinearVelocity = nil
		LinearVelocity = nil
		SlidingStaminaGainBuffer = false
		Humanoid.JumpPower = OldJumpPower
		Charecter.PlayerHurtBox.Size = Vector3.new(4,4,4)
		Charecter.PlayerHurtBox.Position += Vector3.new(0,1,0)
		Humanoid.HipHeight = 0
		SkateingAnimationTrack:Stop(0)
		task.spawn(RemoveSliding,0.5)
		if HumanoidRootPart and HumanoidRootPart.Parent then
			HumanoidRootPart.Parent.Humanoid.AutoRotate = true
		end
		Charecter.PlayerCollisionBox.Position += Vector3.new(0,1.5,0)
		Charecter.PlayerCollisionBox.Size = Vector3.new(1.974, 4.973, 1.974)
		for i, v in pairs(HumanoidRootPart:GetChildren()) do
			if v.Name == "SlideLinearVelocity" or v.Name == "SlideAlignOrientation" or v.Name == "Sk8board" then
				v:Destroy()
			end
			
		
			
		end
		
		for i,v in pairs(Charecter:GetChildren()) do
			
			if v:IsA("BasePart") and v.Name == "Sk8board" then
				v:Destroy()
			end
			
		end
		
		
	end
	
	
	
	if not DashStaminaGainBuffer and not SlidingStaminaGainBuffer and not OutOfStamina then
		StaminaCurrent += DeltaTime * 25
		StaminaCurrent = math.clamp(StaminaCurrent,0,script:GetAttribute("MaxStamina"))
	end
	

	if StaminaCurrent <= 0 and not OutOfStamina then
		task.spawn(OutOfStaminaFunc,1.5)
	end
	
	task.wait(DeltaTime)
	
end

