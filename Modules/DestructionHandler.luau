local DestructionModule = {}


local PityPercent = 0.85
local CollectionService = game:GetService("CollectionService")
local DebriService = game:GetService("Debris")
local TweenService = game:GetService("TweenService")

local CleanGoal = {Transparency = 1}
local CleanTweenInfo = TweenInfo.new(0.25,Enum.EasingStyle.Exponential,Enum.EasingDirection.InOut,-1,true,0)

function TestSphere(Range,Pos)
	local TestPart = Instance.new("Part")
	TestPart.Size = Vector3.new(Range,Range,Range)
	TestPart.Shape = Enum.PartType.Ball
	TestPart.Anchored = true
	TestPart.CanCollide = false
	TestPart.CanTouch = false
	TestPart.CanQuery = false
	TestPart.Transparency = 0.5
	CollectionService:AddTag(TestPart,"TrueAnchored")
	TestPart.Parent = workspace
	TestPart.Position = Pos
	DebriService:AddItem(TestPart,1)
end


function Clean(Part)
	
	task.wait(10)
	local CleanTween = TweenService:Create(Part,CleanTweenInfo,CleanGoal)
	CleanTween:Play()
	DebriService:AddItem(Part,5.12)
	
end

function Unweld(Part)
	for __,v in pairs(Part:GetDescendants()) do
		if v:IsA("Weld") or v:IsA("WeldConstraint") or v:IsA("Motor6D") or v:IsA("Snap") or v:IsA("HingeConstraint") or v:IsA("BallSocketConstraint") then
			v:Destroy()
		end
	end
	local ConnectedParts = Part:GetConnectedParts()
	for __,a in pairs(ConnectedParts) do
		if a:IsA("Part") or a:IsA("UnionOperation") or a:IsA("MeshPart") or a:IsA("BasePart") then
			for __,v in pairs(a:GetDescendants()) do
				if v:IsA("Weld") or v:IsA("WeldConstraint") or v:IsA("Motor6D") or v:IsA("Snap") or v:IsA("HingeConstraint") or v:IsA("BallSocketConstraint") then
					v:Destroy()
				end
			end
			
		end
	end
end

function DestructionModule:DeathOfPart(Part)
	task.spawn(Clean,Part)
	Part.CanCollide = true
	Part.CanQuery = false
	Part.CanTouch = false
end

function DestructionModule:Explosion(Pos,Range,Power,SelfHit,DamageToObjects,DamageToHumanoid,PlayerWhoFired,PlayerFling,UnAnchorsParts)
	
	
	local OverlapParams = OverlapParams.new()
	OverlapParams.FilterType = Enum.RaycastFilterType.Exclude
	if not SelfHit and PlayerWhoFired then OverlapParams.FilterDescendantsInstances = {} end
	

	local PartsInRadius = workspace:GetPartBoundsInRadius(Pos,Range)
	
	local PartsHit = {}
	local PlayersHit = {}
	
	
	for __,Part in pairs(PartsInRadius) do
		if ((Part.Position - Pos) * PityPercent).Magnitude < Range then
			
			table.insert(PartsHit,Part)
			
		end
		
	end

	for __ , Part in pairs(PartsHit) do
		
		
		local Distance = (Part.Position - Pos).Magnitude
		local VelocityMult = ((Power^2)*math.log(Distance+1,9))/(math.sqrt(Distance)+3) + Power
		
		if Part.Parent:FindFirstChild("Humanoid") and PlayerWhoFired and not table.find(PlayersHit,Part.Parent) and PlayerFling then
			
			if PlayerWhoFired.Team ~=  game.Players:GetPlayerFromCharacter(Part.Parent).Team or PlayerWhoFired == game.Players:GetPlayerFromCharacter(Part.Parent) then
				
				local Humanoid =  Part.Parent:FindFirstChild("Humanoid")

				Humanoid:ChangeState(Enum.HumanoidStateType.Freefall) 
			
				local LvAttachment = Instance.new("Attachment")
				LvAttachment.Parent = Part.Parent.HumanoidRootPart
				LvAttachment.Position = Vector3.new(0,0,0)
			
			
				local LinearVelocity = Instance.new("LinearVelocity")
				LinearVelocity.MaxForce = math.huge
				LinearVelocity.Attachment0 = LvAttachment
				LinearVelocity.Parent = Part.Parent.HumanoidRootPart
				if PlayerWhoFired == game.Players:GetPlayerFromCharacter(Part.Parent) then
					LinearVelocity.VectorVelocity = (Humanoid.Parent.HumanoidRootPart.Position - Pos).Unit * VelocityMult/(Humanoid.Parent.HumanoidRootPart.AssemblyMass/5)
					Humanoid:TakeDamage(math.round(DamageToHumanoid/3))
				else
					LinearVelocity.VectorVelocity = (Humanoid.Parent.HumanoidRootPart.Position - Pos).Unit * VelocityMult/(Humanoid.Parent.HumanoidRootPart.AssemblyMass/2)
				end
				DebriService:AddItem(LinearVelocity, 0.02)
				DebriService:AddItem(LvAttachment, 0.02)
			
				if Humanoid.Parent ~= PlayerWhoFired.Character then
					Humanoid:TakeDamage(DamageToHumanoid)
				end
				table.insert(PlayersHit,Part.Parent)
			end
		else
			if not CollectionService:HasTag(Part,"TrueAnchored") and Part.Parent:FindFirstChild("Humanoid") == nil and Part.Parent.Parent:FindFirstChild("Humanoid") == nil and ((Part.Position - Pos).Unit * VelocityMult).Magnitude > Part.Mass * 4.5 and (not Part:FindFirstAncestor(string.upper(PlayerWhoFired.Team.Name:gsub("Team",""))) or Part.Name == "Path")  then
				if UnAnchorsParts then
					Part.Anchored = false
					Unweld(Part)
					pcall (function() if PlayerWhoFired then Part:SetNetworkOwner(PlayerWhoFired) end end)
					Part.AssemblyLinearVelocity = (Part.Position - Pos + Vector3.new(0,Power,0)).Unit * VelocityMult * 4 / Part.AssemblyMass
				end
				if DamageToObjects > 0 then
					if Part:GetAttribute("PartHP") then
						Part:SetAttribute("PartHP",Part:GetAttribute("PartHP") - DamageToObjects)
						
						local HitTweenInfo = TweenInfo.new(0.25,Enum.EasingStyle.Exponential,Enum.EasingDirection.InOut,1,true,0)
						local HitTween = TweenService:Create(Part,HitTweenInfo,CleanGoal)
			
					else
						Part:SetAttribute("PartHP",(math.round(Part.Mass)) - DamageToObjects)
					end
					if Part:GetAttribute("PartHP") <= 0 then
						Part.Anchored = false
						Unweld(Part)
						pcall (function() if PlayerWhoFired then Part:SetNetworkOwner(PlayerWhoFired) end end)
						Part.AssemblyLinearVelocity = (Part.Position - Pos + Vector3.new(0,Power,0)).Unit * VelocityMult
						self:DeathOfPart(Part)
					end
				end
				
			end
		end
		
		
	end
	

end




function DestructionModule.SetHP(List)
	
	for __,v in pairs(List) do
		if v:IsA("Part") then
			if not v:GetAttribute("PartHP") then
				v:SetAttribute("PartHP",(math.round(v.Mass)))
			end
		end
		
	end
	
end

return DestructionModule
