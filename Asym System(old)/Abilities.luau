local AbilityMethods = {}


local CharecterAbilityTable = {
	["Zombie"] = {},
	["Construct"] = {}, 
	["Spirit"] = {},
	["Alien"] = {},
	["SerialKiller"] = {},
	["TestRig"] = {Abilities = {M1={Keybind = "M1",Cd = 0.1},SuperTestAbility = {Keybind = "Ability1",Cd = 15}}},
	
	
	
}

local TestRigAbils = CharecterAbilityTable.TestRig.Abilities

function TestRigAbils.M1.AbilityFunction(plr)
	print("ServerRegistered")
	local TestAbilFunction = function()
		local Charecter = plr.Character
		for i = 0,10 do
			CreateHitbox(Charecter.HumanoidRootPart.Position,10,Vector3.new(2,5,5),nil,Charecter,nil)
			task.wait(0.01)
		end
	end
	task.spawn(TestAbilFunction)
	
end


function TestRigAbils.SuperTestAbility.AbilityFunction()
	print("SuperTestAbilityFired")
end


local DebrisService = game:GetService("Debris")
function CreateHitbox(Position, DistanceFromModel ,Size, Model,Charecter,Orientation)

	local HitboxPart = Instance.new("Part")
	HitboxPart.Name = "HitboxPart"
	HitboxPart.Anchored = true
	HitboxPart.Orientation = Charecter.HumanoidRootPart.Orientation
	if Orientation then

		HitboxPart.Orientation = Orientation

	end
	HitboxPart.Color = Color3.new(1, 0.423529, 0.423529)
	HitboxPart.Transparency = 0.7
	HitboxPart.Position = Position + (Charecter.HumanoidRootPart.CFrame.LookVector * DistanceFromModel)
	HitboxPart.Size = Size
	HitboxPart.Material = Enum.Material.Glass
	HitboxPart.CanQuery = false

	HitboxPart.CanCollide = false
	if Model then
		HitboxPart.Parent = Model
		HitboxPart.Position = Model.Position
		HitboxPart.Parent = game.Workspace.Hitboxes

	else
		HitboxPart.Parent = game.Workspace.Hitboxes
	end
	local TableOflisted = {Charecter}
	local OverlapParams = OverlapParams.new(TableOflisted,Enum.RaycastFilterType.Exclude,0)
	local ThingsInHitbox = workspace:GetPartsInPart(HitboxPart,OverlapParams)
	local PlayersInHitbox = {}

	DebrisService:AddItem(HitboxPart,3)

	for _,v in pairs(ThingsInHitbox) do

		if not v:FindFirstChild("DamageBox") then continue end

		if not v.Parent:IsA("Model") then continue end

		if not v.Parent:FindFirstChild("Humanoid") then continue end
		if v.Parent:FindFirstChild("Humanoid").Health <= 0 then continue end

		if table.find(PlayersInHitbox,v.Parent) then continue end


		table.insert(PlayersInHitbox,v.Parent)

	end
	if #PlayersInHitbox > 0 then
		return PlayersInHitbox
	else
		return nil
	end


end
 
function AbilityMethods.ActivatePlayerAbilities(player,GameCharecter)
	
	local initatior = script.AbilityInitatior:Clone()
	initatior.Parent = player.Character
	initatior.Enabled = true
	
	local AbilityTable = CharecterAbilityTable[GameCharecter]
	
	local AbilityGUIscreen = script.Abilities:Clone()
	AbilityGUIscreen.Parent = player.PlayerGui
	AbilityGUIscreen.Enabled = true

	for i,v in pairs(AbilityTable.Abilities) do
		
		local AbilityFrame = script.AbilityFrame:Clone()
		AbilityFrame.Parent = AbilityGUIscreen.GeneralFrame
		AbilityFrame.Name = i
		AbilityFrame.Keybind.Text = v.Keybind --replace with datastore.get(v.Keybind)
		AbilityFrame.AbilityName.Text = i
	end

	
end

function AbilityMethods.UseAbility(Abilitykey,player)
	
	local GameCharecter = player:WaitForChild("GameCharecter").Value
	local AbilityTable = CharecterAbilityTable[GameCharecter].Abilities
	

	for _,v in pairs(AbilityTable) do
		
		if v.Keybind == Abilitykey then
			v.AbilityFunction(player)
		end
		
	end
			
end

return AbilityMethods
