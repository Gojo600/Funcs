getgenv().getgc = function() -- Semi-Functional (will only get objects within the game)
    local metatable = setmetatable({ game, ["GC"] = {} }, { ["__mode"] = "v" })

	for _, v in game:GetDescendants() do
		table.insert(metatable, v)
	end

	repeat task.wait() until not metatable["GC"]

	local non_gc = {}
	for _, c in metatable do
		table.insert(non_gc, c)
	end
	return non_gc
end

getgenv().getloadedmodules = function(excludeCore) -- Semi-Functional (will return all modules, not loaded modules)
    local modules, core_gui = {}, game:GetDescendants()
	for _, module in ipairs(game:GetDescendants()) do
		if module:IsA("ModuleScript") and (not excludeCore or not module:IsDescendantOf(core_gui)) then
			modules[#modules + 1] = module
		end
	end
	return modules
end

getgenv().getrunningscripts = function() -- Semi-Functional (will return all enabled scripts, not running scripts)
    local scripts = {}
	for _, v in pairs(game:GetDescendants()) do
		if v:IsA("LocalScript") and v.Enabled then table.insert(scripts, v) end
	end
	return scripts
end

getgenv().getscripts = function() -- Semi-Functional (will only return scripts within game)
    local result = {}

    for _, descendant in ipairs(game:GetDescendants()) do
        if descendant:IsA("LocalScript") or descendant:IsA("ModuleScript") then
            table.insert(result, descendant)
        end
    end

    return result
end

getgenv().getsenv = function(script_instance)
    local env = getfenv(debug.info(2, 'f'))
	return setmetatable({
		script = script_instance,
	}, {
		__index = function(self, index)
			return env[index] or rawget(self, index)
		end,
		__newindex = function(self, index, value)
			xpcall(function()
				env[index] = value
			end, function()
				rawset(self, index, value)
			end)
		end,
	})
end

getgenv().getscripthash = function(Script)
    return Script:GetHash()
end

getgenv().getrenv = function()
    return {
        print = print, warn = warn, error = error, assert = assert, collectgarbage = collectgarbage, require = require,
        select = select, tonumber = tonumber, tostring = tostring, type = type, xpcall = xpcall,
        pairs = pairs, next = next, ipairs = ipairs, newproxy = newproxy, rawequal = rawequal, rawget = rawget,
        rawset = rawset, rawlen = rawlen, gcinfo = gcinfo,
    
        coroutine = {
            create = coroutine.create, resume = coroutine.resume, running = coroutine.running,
            status = coroutine.status, wrap = coroutine.wrap, yield = coroutine.yield,
        },
    
        bit32 = {
            arshift = bit32.arshift, band = bit32.band, bnot = bit32.bnot, bor = bit32.bor, btest = bit32.btest,
            extract = bit32.extract, lshift = bit32.lshift, replace = bit32.replace, rshift = bit32.rshift, xor = bit32.xor,
        },
    
        math = {
            abs = math.abs, acos = math.acos, asin = math.asin, atan = math.atan, atan2 = math.atan2, ceil = math.ceil,
            cos = math.cos, cosh = math.cosh, deg = math.deg, exp = math.exp, floor = math.floor, fmod = math.fmod,
            frexp = math.frexp, ldexp = math.ldexp, log = math.log, log10 = math.log10, max = math.max, min = math.min,
            modf = math.modf, pow = math.pow, rad = math.rad, random = math.random, randomseed = math.randomseed,
            sin = math.sin, sinh = math.sinh, sqrt = math.sqrt, tan = math.tan, tanh = math.tanh
        },
    
        string = {
            byte = string.byte, char = string.char, find = string.find, format = string.format, gmatch = string.gmatch,
            gsub = string.gsub, len = string.len, lower = string.lower, match = string.match, pack = string.pack,
            packsize = string.packsize, rep = string.rep, reverse = string.reverse, sub = string.sub,
            unpack = string.unpack, upper = string.upper,
        },
    
        table = {
            concat = table.concat, insert = table.insert, pack = table.pack, remove = table.remove, sort = table.sort,
            unpack = table.unpack,
        },
    
        utf8 = {
            char = utf8.char, charpattern = utf8.charpattern, codepoint = utf8.codepoint, codes = utf8.codes,
            len = utf8.len, nfdnormalize = utf8.nfdnormalize, nfcnormalize = utf8.nfcnormalize,
        },
    
        os = {
            clock = os.clock, date = os.date, difftime = os.difftime, time = os.time,
        },
    
        delay = delay, elapsedTime = elapsedTime, spawn = spawn, tick = tick, time = time, typeof = typeof,
        UserSettings = UserSettings, version = version, wait = wait,
    
        task = {
            defer = task.defer, delay = task.delay, spawn = task.spawn, wait = task.wait,
        },
    
        debug = {
            traceback = debug.traceback, profilebegin = debug.profilebegin, profileend = debug.profileend,
        },
    
        game = game, workspace = workspace,
    
        getmetatable = getmetatable, setmetatable = setmetatable
    }
end

local stuff = {}
local everything = {game}

game.DescendantRemoving:Connect(function(des)
    stuff[des] = 'REMOVE'
end)

game.DescendantAdded:Connect(function(des)
    stuff[des] = true
    table.insert(everything, des)
end)

for i, v in pairs(game:GetDescendants()) do
    table.insert(everything, v)
end

getgenv().getnilinstances = function() -- Semi-Functional
	local nilInstances = {}

    for i, v in pairs(everything) do
        if v.Parent ~= nil then continue end
        table.insert(nilInstances, v)
    end

    return nilInstances
end

getgenv().fireclickdetector = function(object, distance)
    if distance then assert(type(distance) == "number", "The second argument must be number") end

    local OldMaxDistance, OldParent = object["MaxActivationDistance"], object["Parent"]
    local tmp = Instance.new("Part", workspace)

    tmp["CanCollide"], tmp["Anchored"], tmp["Transparency"] = false, true, 1
    tmp["Size"] = Vector3.new(30, 30, 30)
    object["Parent"] = tmp
    object["MaxActivationDistance"] = math["huge"]

    local Heartbeat = run_service["Heartbeat"]:Connect(function()
    local camera = workspace["CurrentCamera"]
    tmp["CFrame"] = camera["CFrame"] * CFrame.new(0, 0, -20) + camera["CFrame"]["LookVector"]
    virtual_user:ClickButton1(Vector2.new(20, 20), camera["CFrame"])
    end)

    object["MouseClick"]:Once(function()
        Heartbeat:Disconnect()
        object["MaxActivationDistance"] = OldMaxDistance
        object["Parent"] = OldParent
        tmp:Destroy()
    end)
end

getgenv().getcallbackvalue = function(a) -- Semi-Functional (Will NOT pass UNC)
    assert(typeof(a) == "function" or a:IsA("BindableFunction"), "argument is not a 'function' or 'BindableFunction'")
    
    if typeof(a) == "Instance" then
        local b, c = pcall(function()
            return a["Invoke"]
        end)
        
        if b and typeof(c) == "function" then
            return c()
        end
    end
    
    return a()
end

getgenv().getconnections = function(signal) -- Semi-Functional (Will NOT pass UNC)
    local c = signal:Connect(function() return end)
    c:Disconnect()
    return c
end

getgenv().getcustomasset = function(path) -- Semi-Functional (will not load from file)
    local cache = {}
	local cacheFile = function(path: string)
		if not cache[path] then
			local success, assetId = pcall(function()
				return game:GetService("ContentProvider"):PreloadAsync({path})
			end)
			if success then
				cache[path] = assetId
			else
				error("Failed to preload asset: " .. path)
			end
		end
		return cache[path]
	end

	return noCache and ("rbxasset://" .. path) or ("rbxasset://" .. (cacheFile(path) or path))
end

getgenv().gethui = function()
    local hui = Instance.new("ScreenGui")
	local success, H = pcall(function()
		return game:GetService("CoreGui").RobloxGui
	end)
	
	if success and H then
		if not hui.Parent then
			hui.Parent = H.Parent
		end
		return hui
	else
		if not hui.Parent then
			hui.Parent = game:GetService("Players").LocalPlayer.PlayerGui
		end
	end
	return hui
end

getgenv().getinstances = function() -- Semi-Functional (will not grab instances outside of game)
    return game:GetDescendants()
end

getgenv().isscriptable = function(a, b)
    assert(typeof(a) == "Instance", "argument #1 is not an 'Instance'", 0)
    assert(typeof(b) == "string", "argument #2 is not a 'string'", 0)
    
    local old
    local c, d = pcall(function()
        old = a[b]
        a[b] = "bombom"
        return a[b] == "bombom"
    end)
    
    if c then
        a[b] = old
    end
    
    return c
end
local coreGui = game:GetService("CoreGui")

local camera = workspace.CurrentCamera
local drawingUI = Instance.new("ScreenGui")
drawingUI.Name = "Drawing | Xeno"
drawingUI.IgnoreGuiInset = true
drawingUI.DisplayOrder = 0x7fffffff
drawingUI.Parent = coreGui

local drawingIndex = 0
local drawingFontsEnum = {
	[0] = Font.fromEnum(Enum.Font.Roboto),
	[1] = Font.fromEnum(Enum.Font.Legacy),
	[2] = Font.fromEnum(Enum.Font.SourceSans),
	[3] = Font.fromEnum(Enum.Font.RobotoMono)
}

local function getFontFromIndex(fontIndex)
	return drawingFontsEnum[fontIndex]
end

local function convertTransparency(transparency)
	return math.clamp(1 - transparency, 0, 1)
end

local baseDrawingObj = setmetatable({
	Visible = true,
	ZIndex = 0,
	Transparency = 1,
	Color = Color3.new(),
	Remove = function(self)
		setmetatable(self, nil)
	end,
	Destroy = function(self)
		setmetatable(self, nil)
	end,
	SetProperty = function(self, index, value)
		if self[index] ~= nil then
			self[index] = value
		else
			warn("Attempted to set invalid property: " .. tostring(index))
		end
	end,
	GetProperty = function(self, index)
		if self[index] ~= nil then
			return self[index]
		else
			warn("Attempted to get invalid property: " .. tostring(index))
			return nil
		end
	end,
	SetParent = function(self, parent)
		self.Parent = parent
	end
}, {
	__add = function(t1, t2)
		local result = {}
		for index, value in pairs(t1) do
			result[index] = value
		end
		for index, value in pairs(t2) do
			result[index] = value
		end
		return result
	end
})

local DrawingLib = {}
DrawingLib.Fonts = {
	["UI"] = 0,
	["System"] = 1,
	["Plex"] = 2,
	["Monospace"] = 3
}

function DrawingLib.createLine()
	local lineObj = ({
		From = Vector2.zero,
		To = Vector2.zero,
		Thickness = 1
	} + baseDrawingObj)

	local lineFrame = Instance.new("Frame")
	lineFrame.Name = drawingIndex
	lineFrame.AnchorPoint = Vector2.new(0.5, 0.5)
	lineFrame.BorderSizePixel = 0

	lineFrame.Parent = drawingUI
	return setmetatable({Parent = drawingUI}, {
		__newindex = function(_, index, value)
			if lineObj[index] == nil then 
				warn("Invalid property: " .. tostring(index))
				return 
			end

			if index == "From" or index == "To" then
				local direction = (index == "From" and lineObj.To or value) - (index == "From" and value or lineObj.From)
				local center = (lineObj.To + lineObj.From) / 2
				local distance = direction.Magnitude
				local theta = math.deg(math.atan2(direction.Y, direction.X))

				lineFrame.Position = UDim2.fromOffset(center.X, center.Y)
				lineFrame.Rotation = theta
				lineFrame.Size = UDim2.fromOffset(distance, lineObj.Thickness)
			elseif index == "Thickness" then
				lineFrame.Size = UDim2.fromOffset((lineObj.To - lineObj.From).Magnitude, value)
			elseif index == "Visible" then
				lineFrame.Visible = value
			elseif index == "ZIndex" then
				lineFrame.ZIndex = value
			elseif index == "Transparency" then
				lineFrame.BackgroundTransparency = convertTransparency(value)
			elseif index == "Color" then
				lineFrame.BackgroundColor3 = value
			elseif index == "Parent" then
				lineFrame.Parent = value
			end
			lineObj[index] = value
		end,
		__index = function(self, index)
			if index == "Remove" or index == "Destroy" then
				return function()
					lineFrame:Destroy()
					lineObj:Remove()
				end
			end
			return lineObj[index]
		end,
		__tostring = function() return "Drawing" end
	})
end

function DrawingLib.createText()
	local textObj = ({
		Text = "",
		Font = DrawingLib.Fonts.UI,
		Size = 0,
		Position = Vector2.zero,
		Center = false,
		Outline = false,
		OutlineColor = Color3.new()
	} + baseDrawingObj)

	local textLabel, uiStroke = Instance.new("TextLabel"), Instance.new("UIStroke")
	textLabel.Name = drawingIndex
	textLabel.AnchorPoint = Vector2.new(0.5, 0.5)
	textLabel.BorderSizePixel = 0
	textLabel.BackgroundTransparency = 1

	local function updateTextPosition()
		local textBounds = textLabel.TextBounds
		local offset = textBounds / 2
		textLabel.Size = UDim2.fromOffset(textBounds.X, textBounds.Y)
		textLabel.Position = UDim2.fromOffset(textObj.Position.X + (not textObj.Center and offset.X or 0), textObj.Position.Y + offset.Y)
	end

	textLabel:GetPropertyChangedSignal("TextBounds"):Connect(updateTextPosition)

	uiStroke.Thickness = 1
	uiStroke.Enabled = textObj.Outline
	uiStroke.Color = textObj.Color

	textLabel.Parent, uiStroke.Parent = drawingUI, textLabel

	return setmetatable({Parent = drawingUI}, {
		__newindex = function(_, index, value)
			if textObj[index] == nil then 
				warn("Invalid property: " .. tostring(index))
				return 
			end

			if index == "Text" then
				textLabel.Text = value
			elseif index == "Font" then
				textLabel.FontFace = getFontFromIndex(math.clamp(value, 0, 3))
			elseif index == "Size" then
				textLabel.TextSize = value
			elseif index == "Position" then
				updateTextPosition()
			elseif index == "Center" then
				textLabel.Position = UDim2.fromOffset((value and camera.ViewportSize / 2 or textObj.Position).X, textObj.Position.Y)
			elseif index == "Outline" then
				uiStroke.Enabled = value
			elseif index == "OutlineColor" then
				uiStroke.Color = value
			elseif index == "Visible" then
				textLabel.Visible = value
			elseif index == "ZIndex" then
				textLabel.ZIndex = value
			elseif index == "Transparency" then
				local transparency = convertTransparency(value)
				textLabel.TextTransparency = transparency
				uiStroke.Transparency = transparency
			elseif index == "Color" then
				textLabel.TextColor3 = value
			elseif index == "Parent" then
				textLabel.Parent = value
			end
			textObj[index] = value
		end,
		__index = function(self, index)
			if index == "Remove" or index == "Destroy" then
				return function()
					textLabel:Destroy()
					textObj:Remove()
				end
			elseif index == "TextBounds" then
				return textLabel.TextBounds
			end
			return textObj[index]
		end,
		__tostring = function() return "Drawing" end
	})
end

function DrawingLib.createCircle()
	local circleObj = ({
		Radius = 150,
		Position = Vector2.zero,
		Thickness = 0.7,
		Filled = false
	} + baseDrawingObj)

	local circleFrame, uiCorner, uiStroke = Instance.new("Frame"), Instance.new("UICorner"), Instance.new("UIStroke")
	circleFrame.Name = drawingIndex
	circleFrame.AnchorPoint = Vector2.new(0.5, 0.5)
	circleFrame.BorderSizePixel = 0

	uiCorner.CornerRadius = UDim.new(1, 0)
	circleFrame.Size = UDim2.fromOffset(circleObj.Radius, circleObj.Radius)
	uiStroke.Thickness = circleObj.Thickness
	uiStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

	circleFrame.Parent, uiCorner.Parent, uiStroke.Parent = drawingUI, circleFrame, circleFrame

	return setmetatable({Parent = drawingUI}, {
		__newindex = function(_, index, value)
			if circleObj[index] == nil then 
				warn("Invalid property: " .. tostring(index))
				return 
			end

			if index == "Radius" then
				local radius = value * 2
				circleFrame.Size = UDim2.fromOffset(radius, radius)
			elseif index == "Position" then
				circleFrame.Position = UDim2.fromOffset(value.X, value.Y)
			elseif index == "Thickness" then
				uiStroke.Thickness = math.clamp(value, 0.6, 0x7fffffff)
			elseif index == "Filled" then
				circleFrame.BackgroundTransparency = value and convertTransparency(circleObj.Transparency) or 1
				uiStroke.Enabled = not value
			elseif index == "Visible" then
				circleFrame.Visible = value
			elseif index == "ZIndex" then
				circleFrame.ZIndex = value
			elseif index == "Transparency" then
				local transparency = convertTransparency(value)
				circleFrame.BackgroundTransparency = circleObj.Filled and transparency or 1
				uiStroke.Transparency = transparency
			elseif index == "Color" then
				circleFrame.BackgroundColor3 = value
				uiStroke.Color = value
			elseif index == "Parent" then
				circleFrame.Parent = value
			end
			circleObj[index] = value
		end,
		__index = function(self, index)
			if index == "Remove" or index == "Destroy" then
				return function()
					circleFrame:Destroy()
					circleObj:Remove()
				end
			end
			return circleObj[index]
		end,
		__tostring = function() return "Drawing" end
	})
end

function DrawingLib.createSquare()
	local squareObj = ({
		Size = Vector2.zero,
		Position = Vector2.zero,
		Thickness = 0.7,
		Filled = false
	} + baseDrawingObj)

	local squareFrame, uiStroke = Instance.new("Frame"), Instance.new("UIStroke")
	squareFrame.Name = drawingIndex
	squareFrame.BorderSizePixel = 0

	squareFrame.Parent, uiStroke.Parent = drawingUI, squareFrame

	return setmetatable({Parent = drawingUI}, {
		__newindex = function(_, index, value)
			if squareObj[index] == nil then 
				warn("Invalid property: " .. tostring(index))
				return 
			end

			if index == "Size" then
				squareFrame.Size = UDim2.fromOffset(value.X, value.Y)
			elseif index == "Position" then
				squareFrame.Position = UDim2.fromOffset(value.X, value.Y)
			elseif index == "Thickness" then
				uiStroke.Thickness = math.clamp(value, 0.6, 0x7fffffff)
			elseif index == "Filled" then
				squareFrame.BackgroundTransparency = value and convertTransparency(squareObj.Transparency) or 1
				uiStroke.Enabled = not value
			elseif index == "Visible" then
				squareFrame.Visible = value
			elseif index == "ZIndex" then
				squareFrame.ZIndex = value
			elseif index == "Transparency" then
				local transparency = convertTransparency(value)
				squareFrame.BackgroundTransparency = squareObj.Filled and transparency or 1
				uiStroke.Transparency = transparency
			elseif index == "Color" then
				squareFrame.BackgroundColor3 = value
				uiStroke.Color = value
			elseif index == "Parent" then
				squareFrame.Parent = value
			end
			squareObj[index] = value
		end,
		__index = function(self, index)
			if index == "Remove" or index == "Destroy" then
				return function()
					squareFrame:Destroy()
					squareObj:Remove()
				end
			end
			return squareObj[index]
		end,
		__tostring = function() return "Drawing" end
	})
end

function DrawingLib.createImage()
	local imageObj = ({
		Data = "",
		DataURL = "rbxassetid://0",
		Size = Vector2.zero,
		Position = Vector2.zero
	} + baseDrawingObj)

	local imageFrame = Instance.new("ImageLabel")
	imageFrame.Name = drawingIndex
	imageFrame.BorderSizePixel = 0
	imageFrame.ScaleType = Enum.ScaleType.Stretch
	imageFrame.BackgroundTransparency = 1

	imageFrame.Parent = drawingUI

	return setmetatable({Parent = drawingUI}, {
		__newindex = function(_, index, value)
			if imageObj[index] == nil then 
				warn("Invalid property: " .. tostring(index))
				return 
			end

			if index == "Data" then
			elseif index == "DataURL" then
				imageFrame.Image = value
			elseif index == "Size" then
				imageFrame.Size = UDim2.fromOffset(value.X, value.Y)
			elseif index == "Position" then
				imageFrame.Position = UDim2.fromOffset(value.X, value.Y)
			elseif index == "Visible" then
				imageFrame.Visible = value
			elseif index == "ZIndex" then
				imageFrame.ZIndex = value
			elseif index == "Transparency" then
				imageFrame.ImageTransparency = convertTransparency(value)
			elseif index == "Color" then
				imageFrame.ImageColor3 = value
			elseif index == "Parent" then
				imageFrame.Parent = value
			end
			imageObj[index] = value
		end,
		__index = function(self, index)
			if index == "Remove" or index == "Destroy" then
				return function()
					imageFrame:Destroy()
					imageObj:Remove()
				end
			elseif index == "Data" then
				return nil 
			end
			return imageObj[index]
		end,
		__tostring = function() return "Drawing" end
	})
end

function DrawingLib.createQuad()
	local quadObj = ({
		PointA = Vector2.zero,
		PointB = Vector2.zero,
		PointC = Vector2.zero,
		PointD = Vector2.zero,
		Thickness = 1,
		Filled = false
	} + baseDrawingObj)

	local _linePoints = {
		A = DrawingLib.createLine(),
		B = DrawingLib.createLine(),
		C = DrawingLib.createLine(),
		D = DrawingLib.createLine()
	}

	local fillFrame = Instance.new("Frame")
	fillFrame.Name = drawingIndex .. "_Fill"
	fillFrame.BorderSizePixel = 0
	fillFrame.BackgroundTransparency = quadObj.Transparency
	fillFrame.BackgroundColor3 = quadObj.Color
	fillFrame.ZIndex = quadObj.ZIndex
	fillFrame.Visible = quadObj.Visible and quadObj.Filled

	fillFrame.Parent = drawingUI

	return setmetatable({Parent = drawingUI}, {
		__newindex = function(_, index, value)
			if quadObj[index] == nil then 
				warn("Invalid property: " .. tostring(index))
				return 
			end

			if index == "PointA" then
				_linePoints.A.From = value
				_linePoints.B.To = value
			elseif index == "PointB" then
				_linePoints.B.From = value
				_linePoints.C.To = value
			elseif index == "PointC" then
				_linePoints.C.From = value
				_linePoints.D.To = value
			elseif index == "PointD" then
				_linePoints.D.From = value
				_linePoints.A.To = value
			elseif index == "Thickness" or index == "Visible" or index == "Color" or index == "ZIndex" then
				for _, linePoint in pairs(_linePoints) do
					linePoint[index] = value
				end
				if index == "Visible" then
					fillFrame.Visible = value and quadObj.Filled
				elseif index == "Color" then
					fillFrame.BackgroundColor3 = value
				elseif index == "ZIndex" then
					fillFrame.ZIndex = value
				end
			elseif index == "Filled" then
				for _, linePoint in pairs(_linePoints) do
					linePoint.Transparency = value and 1 or quadObj.Transparency
				end
				fillFrame.Visible = value
			elseif index == "Parent" then
				fillFrame.Parent = value
			end
			quadObj[index] = value
		end,
		__index = function(self, index)
			if index == "Remove" or index == "Destroy" then
				return function()
					for _, linePoint in pairs(_linePoints) do
						linePoint:Remove()
					end
					fillFrame:Destroy()
					quadObj:Remove()
				end
			end
			return quadObj[index]
		end,
		__tostring = function() return "Drawing" end
	})
end

function DrawingLib.createTriangle()
	local triangleObj = ({
		PointA = Vector2.zero,
		PointB = Vector2.zero,
		PointC = Vector2.zero,
		Thickness = 1,
		Filled = false
	} + baseDrawingObj)

	local _linePoints = {
		A = DrawingLib.createLine(),
		B = DrawingLib.createLine(),
		C = DrawingLib.createLine()
	}

	local fillFrame = Instance.new("Frame")
	fillFrame.Name = drawingIndex .. "_Fill"
	fillFrame.BorderSizePixel = 0
	fillFrame.BackgroundTransparency = triangleObj.Transparency
	fillFrame.BackgroundColor3 = triangleObj.Color
	fillFrame.ZIndex = triangleObj.ZIndex
	fillFrame.Visible = triangleObj.Visible and triangleObj.Filled

	fillFrame.Parent = drawingUI

	return setmetatable({Parent = drawingUI}, {
		__newindex = function(_, index, value)
			if triangleObj[index] == nil then 
				warn("Invalid property: " .. tostring(index))
				return 
			end

			if index == "PointA" then
				_linePoints.A.From = value
				_linePoints.B.To = value
			elseif index == "PointB" then
				_linePoints.B.From = value
				_linePoints.C.To = value
			elseif index == "PointC" then
				_linePoints.C.From = value
				_linePoints.A.To = value
			elseif index == "Thickness" or index == "Visible" or index == "Color" or index == "ZIndex" then
				for _, linePoint in pairs(_linePoints) do
					linePoint[index] = value
				end
				if index == "Visible" then
					fillFrame.Visible = value and triangleObj.Filled
				elseif index == "Color" then
					fillFrame.BackgroundColor3 = value
				elseif index == "ZIndex" then
					fillFrame.ZIndex = value
				end
			elseif index == "Filled" then
				for _, linePoint in pairs(_linePoints) do
					linePoint.Transparency = value and 1 or triangleObj.Transparency
				end
				fillFrame.Visible = value
			elseif index == "Parent" then
				fillFrame.Parent = value
			end
			triangleObj[index] = value
		end,
		__index = function(self, index)
			if index == "Remove" or index == "Destroy" then
				return function()
					for _, linePoint in pairs(_linePoints) do
						linePoint:Remove()
					end
					fillFrame:Destroy()
					triangleObj:Remove()
				end
			end
			return triangleObj[index]
		end,
		__tostring = function() return "Drawing" end
	})
end

function DrawingLib.createFrame()
	local frameObj = ({
		Size = UDim2.new(0, 100, 0, 100),
		Position = UDim2.new(0, 0, 0, 0),
		Color = Color3.new(1, 1, 1),
		Transparency = 0,
		Visible = true,
		ZIndex = 1
	} + baseDrawingObj)

	local frame = Instance.new("Frame")
	frame.Name = drawingIndex
	frame.Size = frameObj.Size
	frame.Position = frameObj.Position
	frame.BackgroundColor3 = frameObj.Color
	frame.BackgroundTransparency = convertTransparency(frameObj.Transparency)
	frame.Visible = frameObj.Visible
	frame.ZIndex = frameObj.ZIndex
	frame.BorderSizePixel = 0

	frame.Parent = drawingUI

	return setmetatable({Parent = drawingUI}, {
		__newindex = function(_, index, value)
			if frameObj[index] == nil then
				warn("Invalid property: " .. tostring(index))
				return
			end

			if index == "Size" then
				frame.Size = value
			elseif index == "Position" then
				frame.Position = value
			elseif index == "Color" then
				frame.BackgroundColor3 = value
			elseif index == "Transparency" then
				frame.BackgroundTransparency = convertTransparency(value)
			elseif index == "Visible" then
				frame.Visible = value
			elseif index == "ZIndex" then
				frame.ZIndex = value
			elseif index == "Parent" then
				frame.Parent = value
			end
			frameObj[index] = value
		end,
		__index = function(self, index)
			if index == "Remove" or index == "Destroy" then
				return function()
					frame:Destroy()
					frameObj:Remove()
				end
			end
			return frameObj[index]
		end,
		__tostring = function() return "Drawing" end
	})
end

task.spawn(function()
    wait(3)
    local Players = game:GetService("Players")
    local player = Players.LocalPlayer
    local headshotUrl = "https://www.roblox.com/headshot-thumbnail/image?userId=" .. player.UserId .. "&width=420&height=420&format=png"

    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "[Zenora]",
        Text = "Injected! 😀",
        Duration = 20,
        Icon = headshotUrl  -- Set the player's headshot as the icon
    })

    print("[-] Injected Zenora Freemium to Roblox\nhttps://discord.gg/exploitnews")
end)


function DrawingLib.createScreenGui()
	local screenGuiObj = ({
		IgnoreGuiInset = true,
		DisplayOrder = 0,
		ResetOnSpawn = true,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
		Enabled = true
	} + baseDrawingObj)

	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = drawingIndex
	screenGui.IgnoreGuiInset = screenGuiObj.IgnoreGuiInset
	screenGui.DisplayOrder = screenGuiObj.DisplayOrder
	screenGui.ResetOnSpawn = screenGuiObj.ResetOnSpawn
	screenGui.ZIndexBehavior = screenGuiObj.ZIndexBehavior
	screenGui.Enabled = screenGuiObj.Enabled

	screenGui.Parent = coreGui

	return setmetatable({Parent = coreGui}, {
		__newindex = function(_, index, value)
			if screenGuiObj[index] == nil then
				warn("Invalid property: " .. tostring(index))
				return
			end

			if index == "IgnoreGuiInset" then
				screenGui.IgnoreGuiInset = value
			elseif index == "DisplayOrder" then
				screenGui.DisplayOrder = value
			elseif index == "ResetOnSpawn" then
				screenGui.ResetOnSpawn = value
			elseif index == "ZIndexBehavior" then
				screenGui.ZIndexBehavior = value
			elseif index == "Enabled" then
				screenGui.Enabled = value
			elseif index == "Parent" then
				screenGui.Parent = value
			end
			screenGuiObj[index] = value
		end,
		__index = function(self, index)
			if index == "Remove" or index == "Destroy" then
				return function()
					screenGui:Destroy()
					screenGuiObj:Remove()
				end
			end
			return screenGuiObj[index]
		end,
		__tostring = function() return "Drawing" end
	})
end

function DrawingLib.createTextButton()
	local buttonObj = ({
		Text = "Button",
		Font = DrawingLib.Fonts.UI,
		Size = 20,
		Position = UDim2.new(0, 0, 0, 0),
		Color = Color3.new(1, 1, 1),
		BackgroundColor = Color3.new(0.2, 0.2, 0.2),
		Transparency = 0,
		Visible = true,
		ZIndex = 1,
		MouseButton1Click = nil
	} + baseDrawingObj)

	local button = Instance.new("TextButton")
	button.Name = drawingIndex
	button.Text = buttonObj.Text
	button.FontFace = getFontFromIndex(buttonObj.Font)
	button.TextSize = buttonObj.Size
	button.Position = buttonObj.Position
	button.TextColor3 = buttonObj.Color
	button.BackgroundColor3 = buttonObj.BackgroundColor
	button.BackgroundTransparency = convertTransparency(buttonObj.Transparency)
	button.Visible = buttonObj.Visible
	button.ZIndex = buttonObj.ZIndex

	button.Parent = drawingUI

	local buttonEvents = {}

	return setmetatable({
		Parent = drawingUI,
		Connect = function(_, eventName, callback)
			if eventName == "MouseButton1Click" then
				if buttonEvents["MouseButton1Click"] then
					buttonEvents["MouseButton1Click"]:Disconnect()
				end
				buttonEvents["MouseButton1Click"] = button.MouseButton1Click:Connect(callback)
			else
				warn("Invalid event: " .. tostring(eventName))
			end
		end
	}, {
		__newindex = function(_, index, value)
			if buttonObj[index] == nil then
				warn("Invalid property: " .. tostring(index))
				return
			end

			if index == "Text" then
				button.Text = value
			elseif index == "Font" then
				button.FontFace = getFontFromIndex(math.clamp(value, 0, 3))
			elseif index == "Size" then
				button.TextSize = value
			elseif index == "Position" then
				button.Position = value
			elseif index == "Color" then
				button.TextColor3 = value
			elseif index == "BackgroundColor" then
				button.BackgroundColor3 = value
			elseif index == "Transparency" then
				button.BackgroundTransparency = convertTransparency(value)
			elseif index == "Visible" then
				button.Visible = value
			elseif index == "ZIndex" then
				button.ZIndex = value
			elseif index == "Parent" then
				button.Parent = value
			elseif index == "MouseButton1Click" then
				if typeof(value) == "function" then
					if buttonEvents["MouseButton1Click"] then
						buttonEvents["MouseButton1Click"]:Disconnect()
					end
					buttonEvents["MouseButton1Click"] = button.MouseButton1Click:Connect(value)
				else
					warn("Invalid value for MouseButton1Click: expected function, got " .. typeof(value))
				end
			end
			buttonObj[index] = value
		end,
		__index = function(self, index)
			if index == "Remove" or index == "Destroy" then
				return function()
					button:Destroy()
					buttonObj:Remove()
				end
			end
			return buttonObj[index]
		end,
		__tostring = function() return "Drawing" end
	})
end

function DrawingLib.createTextLabel()
	local labelObj = ({
		Text = "Label",
		Font = DrawingLib.Fonts.UI,
		Size = 20,
		Position = UDim2.new(0, 0, 0, 0),
		Color = Color3.new(1, 1, 1),
		BackgroundColor = Color3.new(0.2, 0.2, 0.2),
		Transparency = 0,
		Visible = true,
		ZIndex = 1
	} + baseDrawingObj)

	local label = Instance.new("TextLabel")
	label.Name = drawingIndex
	label.Text = labelObj.Text
	label.FontFace = getFontFromIndex(labelObj.Font)
	label.TextSize = labelObj.Size
	label.Position = labelObj.Position
	label.TextColor3 = labelObj.Color
	label.BackgroundColor3 = labelObj.BackgroundColor
	label.BackgroundTransparency = convertTransparency(labelObj.Transparency)
	label.Visible = labelObj.Visible
	label.ZIndex = labelObj.ZIndex

	label.Parent = drawingUI

	return setmetatable({Parent = drawingUI}, {
		__newindex = function(_, index, value)
			if labelObj[index] == nil then
				warn("Invalid property: " .. tostring(index))
				return
			end

			if index == "Text" then
				label.Text = value
			elseif index == "Font" then
				label.FontFace = getFontFromIndex(math.clamp(value, 0, 3))
			elseif index == "Size" then
				label.TextSize = value
			elseif index == "Position" then
				label.Position = value
			elseif index == "Color" then
				label.TextColor3 = value
			elseif index == "BackgroundColor" then
				label.BackgroundColor3 = value
			elseif index == "Transparency" then
				label.BackgroundTransparency = convertTransparency(value)
			elseif index == "Visible" then
				label.Visible = value
			elseif index == "ZIndex" then
				label.ZIndex = value
			elseif index == "Parent" then
				label.Parent = value
			end
			labelObj[index] = value
		end,
		__index = function(self, index)
			if index == "Remove" or index == "Destroy" then
				return function()
					label:Destroy()
					labelObj:Remove()
				end
			end
			return labelObj[index]
		end,
		__tostring = function() return "Drawing" end
	})
end

function DrawingLib.createTextBox()
	local boxObj = ({
		Text = "",
		Font = DrawingLib.Fonts.UI,
		Size = 20,
		Position = UDim2.new(0, 0, 0, 0),
		Color = Color3.new(1, 1, 1),
		BackgroundColor = Color3.new(0.2, 0.2, 0.2),
		Transparency = 0,
		Visible = true,
		ZIndex = 1
	} + baseDrawingObj)

	local textBox = Instance.new("TextBox")
	textBox.Name = drawingIndex
	textBox.Text = boxObj.Text
	textBox.FontFace = getFontFromIndex(boxObj.Font)
	textBox.TextSize = boxObj.Size
	textBox.Position = boxObj.Position
	textBox.TextColor3 = boxObj.Color
	textBox.BackgroundColor3 = boxObj.BackgroundColor
	textBox.BackgroundTransparency = convertTransparency(boxObj.Transparency)
	textBox.Visible = boxObj.Visible
	textBox.ZIndex = boxObj.ZIndex

	textBox.Parent = drawingUI

	return setmetatable({Parent = drawingUI}, {
		__newindex = function(_, index, value)
			if boxObj[index] == nil then
				warn("Invalid property: " .. tostring(index))
				return
			end

			if index == "Text" then
				textBox.Text = value
			elseif index == "Font" then
				textBox.FontFace = getFontFromIndex(math.clamp(value, 0, 3))
			elseif index == "Size" then
				textBox.TextSize = value
			elseif index == "Position" then
				textBox.Position = value
			elseif index == "Color" then
				textBox.TextColor3 = value
			elseif index == "BackgroundColor" then
				textBox.BackgroundColor3 = value
			elseif index == "Transparency" then
				textBox.BackgroundTransparency = convertTransparency(value)
			elseif index == "Visible" then
				textBox.Visible = value
			elseif index == "ZIndex" then
				textBox.ZIndex = value
			elseif index == "Parent" then
				textBox.Parent = value
			end
			boxObj[index] = value
		end,
		__index = function(self, index)
			if index == "Remove" or index == "Destroy" then
				return function()
					textBox:Destroy()
					boxObj:Remove()
				end
			end
			return boxObj[index]
		end,
		__tostring = function() return "Drawing" end
	})
end

getgenv().Drawing = {
    Fonts = {
        ["UI"] = 0,
        ["System"] = 1,
        ["Plex"] = 2,
        ["Monospace"] = 3
    },
    
    new = function(drawingType)
        drawingIndex += 1
        if drawingType == "Line" then
            return DrawingLib.createLine()
        elseif drawingType == "Text" then
            return DrawingLib.createText()
        elseif drawingType == "Circle" then
            return DrawingLib.createCircle()
        elseif drawingType == "Square" then
            return DrawingLib.createSquare()
        elseif drawingType == "Image" then
            return DrawingLib.createImage()
        elseif drawingType == "Quad" then
            return DrawingLib.createQuad()
        elseif drawingType == "Triangle" then
            return DrawingLib.createTriangle()
        elseif drawingType == "Frame" then
            return DrawingLib.createFrame()
        elseif drawingType == "ScreenGui" then
            return DrawingLib.createScreenGui()
        elseif drawingType == "TextButton" then
            return DrawingLib.createTextButton()
        elseif drawingType == "TextLabel" then
            return DrawingLib.createTextLabel()
        elseif drawingType == "TextBox" then
            return DrawingLib.createTextBox()
        else
            error("Invalid drawing type: " .. tostring(drawingType))
        end
    end
}

getgenv().isrenderobj = function(drawingObj)
    local success, isrenderobj = pcall(function()
		return drawingObj.Parent == drawingUI
	end)
	if not success then return false end
	return isrenderobj
end

getgenv().getrenderproperty = function(drawingObj, property)
	local success, drawingProperty  = pcall(function()
		return drawingObj[property]
	end)
	if not success then return end

	if drawingProperty ~= nil then
		return drawingProperty
	end
end

getgenv().setrenderproperty = function(drawingObj, property, value)
	assert(getgenv().getrenderproperty(drawingObj, property), "'" .. tostring(property) .. "' is not a valid property of " .. tostring(drawingObj) .. ", " .. tostring(typeof(drawingObj)))
	drawingObj[property]  = value
end

getgenv().cleardrawcache = function()
	for _, drawing in drawingUI:GetDescendants() do
		drawing:Remove()
	end
end
getgenv().debug = { -- debug.getinfo is the only one possible in Luau
    getinfo = function(f, options) -- Semi-Functional (nups do not work due to debug.getupvalues not being able to be accessed)
        if type(options) == "string" then
            options = string.lower(options) 
        else
            options = "sflnu"
        end
        local result = {}
        for index = 1, #options do
            local option = string.sub(options, index, index)
            if "s" == option then
                local short_src = debug.info(f, "s")
                result.short_src = short_src
                result.source = "=" .. short_src
                result.what = if short_src == "[C]" then "C" else "Lua"
            elseif "f" == option then
                result.func = debug.info(f, "f")
            elseif "l" == option then
                result.currentline = debug.info(f, "l")
            elseif "n" == option then
                result.name = debug.info(f, "n")
            elseif "u" == option or option == "a" then
                local numparams, is_vararg = debug.info(f, "a")
                result.numparams = numparams
                result.is_vararg = if is_vararg then 1 else 0
                if "u" == option then
                    result.nups = -1
                end
            end
        end
        return result
    end
}
local b64 = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"

getgenv().getc = function(str)
    local sum = 0
    for _, code in utf8.codes(str) do
        sum = sum + code
    end
    return sum
end

getgenv().str2hexa = function(a)
    return string.gsub(
        a,
        ".",
        function(b)
            return string.format("%02x", string.byte(b))
        end
    )
end

getgenv().num2s = function(c, d)
    local a = ""
    for e = 1, d do
        local f = c % 256
        a = string.char(f) .. a
        c = (c - f) / 256
    end
    return a
end

getgenv().s232num = function(a, e)
    local d = 0
    for g = e, e + 3 do
        d = d * 256 + string.byte(a, g)
    end
    return d
end

getgenv().preproc = function(h, i)
    local j = 64 - (i + 9) % 64
    i = num2s(8 * i, 8)
    h = h .. "\128" .. string.rep("\0", j) .. i
    assert(#h % 64 == 0)
    return h
end

getgenv().k = function(h, e, l)
    local m = {}
    local n = {
        0x428a2f98,
        0x71374491,
        0xb5c0fbcf,
        0xe9b5dba5,
        0x3956c25b,
        0x59f111f1,
        0x923f82a4,
        0xab1c5ed5,
        0xd807aa98,
        0x12835b01,
        0x243185be,
        0x550c7dc3,
        0x72be5d74,
        0x80deb1fe,
        0x9bdc06a7,
        0xc19bf174,
        0xe49b69c1,
        0xefbe4786,
        0x0fc19dc6,
        0x240ca1cc,
        0x2de92c6f,
        0x4a7484aa,
        0x5cb0a9dc,
        0x76f988da,
        0x983e5152,
        0xa831c66d,
        0xb00327c8,
        0xbf597fc7,
        0xc6e00bf3,
        0xd5a79147,
        0x06ca6351,
        0x14292967,
        0x27b70a85,
        0x2e1b2138,
        0x4d2c6dfc,
        0x53380d13,
        0x650a7354,
        0x766a0abb,
        0x81c2c92e,
        0x92722c85,
        0xa2bfe8a1,
        0xa81a664b,
        0xc24b8b70,
        0xc76c51a3,
        0xd192e819,
        0xd6990624,
        0xf40e3585,
        0x106aa070,
        0x19a4c116,
        0x1e376c08,
        0x2748774c,
        0x34b0bcb5,
        0x391c0cb3,
        0x4ed8aa4a,
        0x5b9cca4f,
        0x682e6ff3,
        0x748f82ee,
        0x78a5636f,
        0x84c87814,
        0x8cc70208,
        0x90befffa,
        0xa4506ceb,
        0xbef9a3f7,
        0xc67178f2
    }
    for g = 1, 16 do
        m[g] = s232num(h, e + (g - 1) * 4)
    end
    for g = 17, 64 do
        local o = m[g - 15]
        local p = bit32.bxor(bit32.rrotate(o, 7), bit32.rrotate(o, 18), bit32.rshift(o, 3))
        o = m[g - 2]
        local q = bit32.bxor(bit32.rrotate(o, 17), bit32.rrotate(o, 19), bit32.rshift(o, 10))
        m[g] = (m[g - 16] + p + m[g - 7] + q) % 2 ^ 32
    end
    local r, s, b, t, u, v, w, x = l[1], l[2], l[3], l[4], l[5], l[6], l[7], l[8]
    for e = 1, 64 do
        local p = bit32.bxor(bit32.rrotate(r, 2), bit32.rrotate(r, 13), bit32.rrotate(r, 22))
        local y = bit32.bxor(bit32.band(r, s), bit32.band(r, b), bit32.band(s, b))
        local z = (p + y) % 2 ^ 32
        local q = bit32.bxor(bit32.rrotate(u, 6), bit32.rrotate(u, 11), bit32.rrotate(u, 25))
        local A = bit32.bxor(bit32.band(u, v), bit32.band(bit32.bnot(u), w))
        local B = (x + q + A + n[e] + m[e]) % 2 ^ 32
        x = w
        w = v
        v = u
        u = (t + B) % 2 ^ 32
        t = b
        b = s
        s = r
        r = (B + z) % 2 ^ 32
    end
    l[1] = (l[1] + r) % 2 ^ 32
    l[2] = (l[2] + s) % 2 ^ 32
    l[3] = (l[3] + b) % 2 ^ 32
    l[4] = (l[4] + t) % 2 ^ 32
    l[5] = (l[5] + u) % 2 ^ 32
    l[6] = (l[6] + v) % 2 ^ 32
    l[7] = (l[7] + w) % 2 ^ 32
    l[8] = (l[8] + x) % 2 ^ 32
end

getgenv().crypt = {
    base64encode = function(data)
        return (data:gsub('.', function(x) 
			local r,b='',x:byte()
			for i=8,1,-1 do r=r..(b%2^i-b%2^(i-1)>0 and '1' or '0') end
			return r
		end)..'0000'):gsub('%d%d%d?%d?%d?%d?', function(x)
			if (#x < 6) then return '' end
			local c=0
			for i=1,6 do c=c+(x:sub(i,i)=='1' and 2^(6-i) or 0) end
			return b64:sub(c+1,c+1)
		end)..({'','==','='})[#data%3+1]
    end,
    base64decode = function(data)
        data = data:gsub('[^'..b64..'=]', '')
		return (data:gsub('.', function(x)
			if (x == '=') then return '' end
			local r,f='',b64:find(x)-1
			for i=6,1,-1 do r=r..(f%2^i-f%2^(i-1)>0 and '1' or '0') end
			return r
		end):gsub('%d%d%d?%d?%d?%d?%d?%d?', function(x)
			if (#x ~= 8) then return '' end
			local c=0
			for i=1,8 do c=c+(x:sub(i,i)=='1' and 2^(8-i) or 0) end
			return string.char(c)
		end)) 
    end,
    base64_decode = base64decode,
    base64_encode = base64encode,
    base64 = {
        encode = base64encode,
        decode = base64decode
    },
    encrypt = function(data, key, iv, mode)
        assert(type(data) == "string", "Data must be a string")
		assert(type(key) == "string", "Key must be a string")

		mode = mode or "CBC"
		iv = iv or crypt.generatebytes(16)

		local byteChange = (getc(mode) + getc(iv) + getc(key)) % 256
		local res = {}

		for i = 1, #data do
			local byte = (string.byte(data, i) + byteChange) % 256
			table.insert(res, string.char(byte))
		end

		local encrypted = table.concat(res)
		return crypt.base64encode(encrypted), iv
    end,
    decrypt = function(data, key, iv, mode)
        assert(type(data) == "string", "Data must be a string")
		assert(type(key) == "string", "Key must be a string")
		assert(type(iv) == "string", "IV must be a string")

		mode = mode or "CBC"

		local decodedData = crypt.base64decode(data)
		local byteChange = (getc(mode) + getc(iv) + getc(key)) % 256
		local res = {}

		for i = 1, #decodedData do
			local byte = (string.byte(decodedData, i) - byteChange) % 256
			table.insert(res, string.char(byte))
		end

		return table.concat(res)
    end,
    generatebytes = function(size)
        local bytes = table.create(size)

		for i = 1, size do
			bytes[i] = string.char(math.random(0, 255))
		end

		return crypt.base64encode(table.concat(bytes))
    end,
    generatekey = function()
        return crypt.generatebytes(32)
    end,
    hash = function(h)
        h = preproc(h, #h)
        local l = {0x6a09e667, 0xbb67ae85, 0x3c6ef372, 0xa54ff53a, 0x510e527f, 0x9b05688c, 0x1f83d9ab, 0x5be0cd19}
        for e = 1, #h, 64 do
            k(h, e, l)
        end
        return str2hexa(
            num2s(l[1], 4) ..
                num2s(l[2], 4) ..
                    num2s(l[3], 4) .. num2s(l[4], 4) .. num2s(l[5], 4) .. num2s(l[6], 4) .. num2s(l[7], 4) .. num2s(l[8], 4)
        )
    end
}

getgenv().checkcaller = function() -- Semi-Functional
	local info = debug.info(getgenv, 'slnaf')
	return debug.info(1, 'slnaf')==info
end

getgenv().clonefunction = function(func)
    return function(...) return func(...) end
end

getgenv().getcallingscript = function()
    for i = 3, 0, -1 do
		local f = debug.info(i, "f")
		if not f then
			continue
		end

		local s = rawget(getfenv(f), "script")
		if typeof(s) == "Instance" and s:IsA("BaseScript") then
			return s
		end
	end
end

getgenv().getscriptclosure = function(s) -- Semi-Functional (only works on modulescripts)
    return function()
		return table.clone(require(s))
	end
end
getgenv().getscriptfunction = getgenv().getscriptclosure

getgenv().hookfunction = function(func, rep) -- Semi-Functional (Will NOT pass UNC) (wont work on local things or things outside the script env)
    for i, v in pairs(getfenv()) do
        if v == func then
            getfenv()[i] = rep
        end
    end
end
getgenv().replaceclosure = getgenv().hookfunction

getgenv().iscclosure = function(func)
    return debug.info(func, "s") == "[C]"
end

getgenv().islclosure = function(func)
    return debug.info(func, "s") ~= "[C]"
end

getgenv().isexecutorclosure = function(func)
    for _, genv in getgenv() do
        if genv == func then
            return true
        end
    end
    local function check(t)
        local isglobal = false
        for i, v in t do
            if type(v) == "table" then
                check(v)
            end
            if v == func then
                isglobal = true
            end
        end
        return isglobal
    end
    if check(getgenv().getrenv()) then
        return false
    end
    return true
end
getgenv().checkclosure = getgenv().isgetgenv()closure
getgenv().isourclosure = getgenv().isgetgenv()closure

getgenv().newcclosure = function(func) -- Semi-Functional (bad implementation)
    if iscclosure(func) then
        return func
    end

    return coroutine.wrap(function(...)
        local args = {...}

        while true do
            args = { coroutine.yield(func(unpack(args))) }
        end
    end)
end

getgenv().newlclosure = function(func)
    return function(...)
        return func(...)
    end
end
getgenv().invalidated = {}
getgenv().cache = {
    invalidate = function(object)
        local function clone(object)
			local old_archivable = object.Archivable
			local clone

			object.Archivable = true
			clone = object:Clone()
			object.Archivable = old_archivable

			return clone
		end

		local clone = clone(object)
		local oldParent = object.Parent

		table.insert(invalidated, object)

		object:Destroy()
		clone.Parent = oldParent
    end,
    iscached = function(object)
        return table.find(invalidated, object) == nil
    end,
    replace = function(object, new_object)
        if object:IsA("BasePart") and new_object:IsA("BasePart") then
			invalidate(object)
			table.insert(invalidated, new_object)
		end
    end
}
