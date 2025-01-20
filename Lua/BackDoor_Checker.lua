-- Made by Car(Charlotte) and Soul(No)
--False positives may be found during usage.
local found = false
local findings = {}
local bit32Found = false
local requireFound = false
local marketplaceInfoFound = false
local backdoorFound = false

local backdoorPatterns = {
	"getfenv", "setfenv", "loadstring", "bit32", "require%s*%b()",
	"\\%d+\\%d+", "0x%x+", "%w+%=%w+", "[A-Za-z0-9%p]{8,}"
}

local whitelist = {
	"LogFile_Old",
	"LogFile",

}

local function isWhitelisted(script)
	for _, whitelistedName in ipairs(whitelist) do
		if script:GetFullName():find(whitelistedName) then
			return true
		end
	end
	return false
end

local function BeginFind(script)
	if not script.Source or isWhitelisted(script) then return end

	local sourceLower = script.Source:lower()
	local lineNumber = 0

	for line in script.Source:gmatch("[^\r\n]+") do
		lineNumber = lineNumber + 1
		local lineLower = line:lower()

		if lineLower:find("require%s*%b()") then
			table.insert(findings, {pattern = "require()", script = script:GetFullName(), line = lineNumber})
			found = true
			requireFound = true
		end

		if lineLower:find("bit32") then
			table.insert(findings, {pattern = "bit32", script = script:GetFullName(), line = lineNumber})
			found = true
			bit32Found = true
		end

		if lineLower:find("marketplaceservice:getproductinfo") then
			table.insert(findings, {pattern = "MarketplaceService:GetProductInfo", script = script:GetFullName(), line = lineNumber})
			found = true
			marketplaceInfoFound = true
		end

		for _, pattern in ipairs(backdoorPatterns) do
			if lineLower:find(pattern) then
				table.insert(findings, {pattern = pattern, script = script:GetFullName(), type = "Backdoor", line = lineNumber})
				found = true
				backdoorFound = true
			end
		end
	end
end

local function scanScripts()
	for _, child in ipairs(game:GetDescendants()) do
		if child:IsA("ModuleScript") or child:IsA("LocalScript") or child:IsA("Script") then
			BeginFind(child)
		end
	end
end

scanScripts()

local function renameOldLogFile()
	local oldLogFile = game:FindFirstChild("LogFile")
	if oldLogFile then
		oldLogFile.Name = "LogFile_Old"
		warn("Old log file renamed to 'LogFile_Old'.")
	end
end

local function createNewLogFile(content)
	renameOldLogFile()
	wait(1)
	local logFile = Instance.new("ModuleScript")
	logFile.Name = "LogFile"
	logFile.Parent = game
	logFile.Source = content
	warn("New log file created and written to Workspace as 'LogFile'.")
end

local function createLogFile()
	local maxSourceLength = 200000
	local logContent = "--[[ Log Content\n\n"

	local function addToLogContent(text)
		if #logContent + #text >= maxSourceLength then
			createNewLogFile(logContent .. "\n]]")
			logContent = "--[[ Log Content\n\n"
		end
		logContent = logContent .. text
	end

	if found then
		local currentScript = ""
		for _, entry in ipairs(findings) do
			if entry.script ~= currentScript then
				currentScript = entry.script
				addToLogContent(string.format("---- Script: %s ----\n\n", currentScript))
			end
			if entry.type == "Backdoor" then
				addToLogContent(string.format("⚠️ Potential Backdoor found: '%s' in: %s | LINE: %d\n\n", entry.pattern or "N/A", entry.script or "N/A", entry.line or -1))
			else
				addToLogContent(string.format("Found '%s' in: %s | LINE: %d\n\n", entry.pattern or "N/A", entry.script or "N/A", entry.line or -1))
			end
		end
	else
		addToLogContent("Not found.\n\n")
	end

	if not bit32Found then
		addToLogContent("'bit32' not found.\n\n")
	end

	if not requireFound then
		addToLogContent("'require(rbxassetid)' not found.\n\n")
	end

	if not marketplaceInfoFound then
		addToLogContent("'MarketplaceService:GetProductInfo' not found.\n\n")
	end

	if not backdoorFound then
		addToLogContent("No potential backdoors found.\n\n")
	end

	if #logContent > 20 then
		createNewLogFile(logContent .. "\n]]")
	end
end

createLogFile()
