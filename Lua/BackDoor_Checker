local found = false
local findings = {}
local foundBit32 = false
local foundRequire = false
local foundMarketplaceInfo = false

local function skibidi_sigma(script)
	if script.Source:find("bit32") then
		table.insert(findings, {pattern = "bit32", script = script:GetFullName()})
		found = true
		foundBit32 = true
	end

	for line in script.Source:gmatch("[^\r\n]+") do
		local requireStatement = line:match("require%s*%(%d+%)")
		if requireStatement then
			table.insert(findings, {pattern = requireStatement, script = script:GetFullName()})
			found = true
			foundRequire = true
		end

		local marketplaceInfo = line:match("MarketplaceService:GetProductInfo")
		if marketplaceInfo then
			table.insert(findings, {pattern = "MarketplaceService:GetProductInfo", script = script:GetFullName()})
			found = true
			foundMarketplaceInfo = true
		end
	end
end

local function ass()
	for _, child in ipairs(game:GetDescendants()) do
		if child:IsA("ModuleScript") or child:IsA("LocalScript") or child:IsA("Script") then
			skibidi_sigma(child)
		end
	end
end

ass()

local logFile = Instance.new("ModuleScript")
logFile.Name = "LogFile"
logFile.Parent = game

local logContent = "--[[ Log Content\n\n"

if found then
	for _, entry in ipairs(findings) do
		logContent = logContent .. "Found '" .. entry.pattern .. "' in: " .. entry.script .. "\n"
	end
else
	logContent = logContent .. "Not found.\n"
end

if not foundBit32 then
	logContent = logContent .. "'bit32' not found.\n"
end

if not foundRequire then
	logContent = logContent .. "'require(rbxassetid)' not found.\n"
end

if not foundMarketplaceInfo then
	logContent = logContent .. "'MarketplaceService:GetProductInfo' not found.\n"
end

logContent = logContent .. "\n]]"

logFile.Source = logContent
warn("Log file created and written to Workspace as 'LogFile'.")
