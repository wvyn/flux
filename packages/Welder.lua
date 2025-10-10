-- v1.0.2
local Welder = {}

export type WeldType = "Weld" | "WeldConstraint" | "Motor6D"
function Welder.weldPart(
	weldType: WeldType,
	part0: BasePart,
	part1: BasePart,
	weldProperties: {
		PreserveCFrame: boolean?,
		
		Name: string,
		Enabled: boolean,
		
		C0: CFrame?,
		C1: CFrame?,
		
		Parent: Instance?,
	}?
): Weld | WeldConstraint | Motor6D
	weldProperties = weldProperties or {}
	local weld = Instance.new(weldType)
	weld.Part0 = part0
	weld.Part1 = part1
	if weldProperties.PreserveCFrame then weld.C0 = weld.Part0.CFrame:Inverse() * weld.Part1.CFrame end
	if weldProperties.C0 then weld.C0 *= weldProperties.C0 end
	if weldProperties.C1 then weld.C1 *= weldProperties.C1 end
	
	if weldProperties.Enabled ~= nil then weld.Enabled = weldProperties.Enabled end
	if weldProperties.Name then weld.Name = weldProperties.Name end
	
	weld.Parent = weldProperties.Parent or part0
	return weld
end

function Welder.weldModel(
	model: Model,
	partProperties: {
		Root: BasePart?,

		Anchored: boolean?,
		CanCollide: boolean?,
		CanTouch: boolean?,
		CanQuery: boolean?,
		Material: Enum.Material?,
		Color: Color3?,
		CastShadow: boolean?,
		Reflectance: number?,
		Locked: boolean?,
		Massless: boolean?,

		UsePartColor: boolean?
	}
)
	local root: BasePart = partProperties.Root or model.PrimaryPart or model:FindFirstChildWhichIsA("BasePart")
	assert(root, "No root part to weld to.")

	for _, part: Instance in next, model:GetDescendants() do
		if part:IsA("BasePart") then
			local weld = Welder.weldPart("Weld", root, part, { Name = part.Name, PreserveCFrame = true })
			if partProperties then
				for propertyName, propertyValue in next, partProperties do
					if propertyName == "Root" then continue end
					part[propertyName] = propertyValue
				end
			end
		end
	end

	return {
		Model = model,
		Root = root
	}
end

return Welder