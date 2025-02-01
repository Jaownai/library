local Library = {}
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

-- Constructor for creating new windows
function Library:CreateWindow(name)
	local GUI = game:GetObjects("paste")[1]
	if syn then
		syn.protect_gui(GUI)
	end
	GUI.Parent = game.CoreGui

	local Window = {
		Tabs = {},
		CurrentTab = nil,
		Dragging = false,
		Resizing = false
	}

	-- Set window name
	GUI.Base.FunctionHolder.PageName.Text = name
	GUI.Base.SelectionHolder.NameAndLogoHolder.Name.Text = name

	-- Make window draggable
	local dragInput, dragStart, startPos

	GUI.Base.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			Window.Dragging = true
			dragStart = input.Position
			startPos = GUI.Base.Position

			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					Window.Dragging = false
				end
			end)
		end
	end)

	GUI.Base.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement then
			dragInput = input
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if input == dragInput and Window.Dragging then
			local delta = input.Position - dragStart
			GUI.Base.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
		end
	end)

	-- Make window resizable
	local function updateSize(input)
		local delta = input.Position - dragStart
		local newSize = UDim2.new(
			startPos.X.Scale, 
			math.clamp(startPos.X.Offset + delta.X, 600, 800),
			startPos.Y.Scale,
			math.clamp(startPos.Y.Offset + delta.Y, 400, 600)
		)
		GUI.Base.Size = newSize
	end

	GUI.Base.PageSelectHolder.Resize.MouseButton1Down:Connect(function()
		Window.Resizing = true
		dragStart = UserInputService:GetMouseLocation()
		startPos = GUI.Base.Size

		UserInputService.InputChanged:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseMovement and Window.Resizing then
				updateSize(input)
			end
		end)
	end)

	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			Window.Resizing = false
		end
	end)

	-- Create Tab function
	function Window:CreateTab(name, icon)
		local Tab = {
			Buttons = {},
			Toggles = {},
			Inputs = {},
			Dropdowns = {}
		}

		local newTab = GUI.Base.SelectionHolder.TabSelectionHolder.ScrollingFrame.tab1:Clone()
		newTab.Text = name
		if icon then
			newTab.Imagebuttontab1.Image = icon
		end
		newTab.Parent = GUI.Base.SelectionHolder.TabSelectionHolder.ScrollingFrame

		-- Tab selection handling
		newTab.MouseButton1Click:Connect(function()
			if Window.CurrentTab then
				-- Fade out current tab
				TweenService:Create(Window.CurrentTab, TweenInfo.new(0.2), {
					TextTransparency = 0.8,
					BackgroundTransparency = 1
				}):Play()
			end

			-- Fade in new tab
			TweenService:Create(newTab, TweenInfo.new(0.2), {
				TextTransparency = 0,
				BackgroundTransparency = 0
			}):Play()

			Window.CurrentTab = newTab
		end)

		-- Create Button function
		function Tab:CreateButton(name, callback)
			local button = GUI.Base.FunctionHolder.PageRight.Button:Clone()
			button.Name = name
			button.DropdownNameFunction.Text = name
			button.Parent = GUI.Base.FunctionHolder.PageRight

			button.ButtonHolder.Button.MouseButton1Click:Connect(function()
				if callback then
					callback()
				end
			end)

			return button
		end

		-- Create Toggle function
		function Tab:CreateToggle(name, default, callback)
			local toggle = GUI.Base.FunctionHolder.PageLeft.Toggle:Clone()
			toggle.Name = name
			toggle.ToggleNameFunction.Text = name
			toggle.Parent = GUI.Base.FunctionHolder.PageLeft

			local enabled = default or false
			local toggleButton = toggle.ToggleTextLabelDescription.FrameToggleOff.Toggle

			local function updateToggle()
				local pos = enabled and UDim2.new(0.6, 0, 0.12, 0) or UDim2.new(0, 0, 0.12, 0)
				local color = enabled and Color3.fromRGB(200, 200, 200) or Color3.fromRGB(122, 122, 122)

				TweenService:Create(toggleButton, TweenInfo.new(0.2), {
					Position = pos,
					BackgroundColor3 = color
				}):Play()

				if callback then
					callback(enabled)
				end
			end

			toggle.ToggleTextLabelDescription.FrameToggleOff.InputBegan:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 then
					enabled = not enabled
					updateToggle()
				end
			end)

			updateToggle()
			return toggle
		end

		-- Create Input function
		function Tab:CreateInput(name, placeholder, callback)
			local input = GUI.Base.FunctionHolder.PageLeft.Input:Clone()
			input.Name = name
			input.InputNameFunction.Text = name
			input.Parent = GUI.Base.FunctionHolder.PageLeft

			local textBox = input.InputTextLabelDescription.FrameInput.Inputtext
			textBox.PlaceholderText = placeholder or "Enter text..."

			textBox.FocusLost:Connect(function(enterPressed)
				if enterPressed and callback then
					callback(textBox.Text)
				end
			end)

			return input
		end

		-- Create Dropdown function
		function Tab:CreateDropdown(name, options, callback)
			local dropdown = GUI.Base.FunctionHolder.PageRight.Dropdown:Clone()
			dropdown.Name = name
			dropdown.DropdownNameFunction.Text = name
			dropdown.Parent = GUI.Base.FunctionHolder.PageRight

			local dropdownButton = dropdown.DropdownHolder.dropdownOff
			local resultFrame = dropdown.ResultDropdownOn
			resultFrame.Visible = false

			-- Populate options
			for _, option in ipairs(options) do
				local button = resultFrame.TextButton:Clone()
				button.Text = option
				button.Parent = resultFrame

				button.MouseButton1Click:Connect(function()
					dropdownButton.Text = option
					resultFrame.Visible = false
					if callback then
						callback(option)
					end
				end)
			end

			dropdownButton.MouseButton1Click:Connect(function()
				resultFrame.Visible = not resultFrame.Visible
			end)

			return dropdown
		end
		
		-- Add to the Tab function after CreateDropdown
		function Tab:CreateSlider(name, min, max, default, callback)
			local slider = GUI.Base.FunctionHolder.PageRight.Button:Clone() -- Using Button as base template
			slider.Name = name
			slider.DropdownNameFunction.Text = name
			slider.Parent = GUI.Base.FunctionHolder.PageRight

			-- Set up slider holder
			local sliderHolder = slider.ButtonHolder
			sliderHolder.Name = "SliderHolder"
			sliderHolder.Button:Destroy() -- Remove button template

			-- Create slider background
			local sliderBg = Instance.new("Frame")
			sliderBg.Name = "SliderBackground"
			sliderBg.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
			sliderBg.BorderSizePixel = 0
			sliderBg.Position = UDim2.new(0.055, 0, 0, 0)
			sliderBg.Size = UDim2.new(0, 177, 0, 12)
			sliderBg.Parent = sliderHolder

			local bgCorner = Instance.new("UICorner")
			bgCorner.CornerRadius = UDim.new(0, 7)
			bgCorner.Parent = sliderBg

			-- Create slider fill
			local sliderFill = Instance.new("Frame")
			sliderFill.Name = "SliderFill"
			sliderFill.BackgroundColor3 = Color3.fromRGB(75, 75, 75)
			sliderFill.BorderSizePixel = 0
			sliderFill.Size = UDim2.new(0, 0, 1, 0) -- Will be updated based on value
			sliderFill.Parent = sliderBg

			local fillCorner = Instance.new("UICorner")
			fillCorner.CornerRadius = UDim.new(0, 7)
			fillCorner.Parent = sliderFill

			-- Create slider handle
			local handle = Instance.new("Frame")
			handle.Name = "Handle"
			handle.BackgroundColor3 = Color3.fromRGB(112, 112, 112)
			handle.BorderSizePixel = 0
			handle.Position = UDim2.new(0, -6, 0.5, -11) -- Center vertically, offset by half width
			handle.Size = UDim2.new(0, 12, 0, 22)
			handle.Parent = sliderFill

			local handleCorner = Instance.new("UICorner")
			handleCorner.Parent = handle

			-- Create value display
			local valueDisplay = Instance.new("TextLabel")
			valueDisplay.Name = "ValueDisplay"
			valueDisplay.BackgroundTransparency = 1
			valueDisplay.Position = UDim2.new(0.5, 0, -1, 0)
			valueDisplay.Size = UDim2.new(0, 50, 0, 20)
			valueDisplay.Font = Enum.Font.SourceSans
			valueDisplay.TextColor3 = Color3.fromRGB(122, 122, 122)
			valueDisplay.TextSize = 14
			valueDisplay.Parent = sliderBg

			-- Slider functionality
			local dragging = false
			local value = default or min

			local function updateSlider(input)
				local pos = input.Position
				local abs = sliderBg.AbsolutePosition
				local size = sliderBg.AbsoluteSize

				local relative = math.clamp((pos.X - abs.X) / size.X, 0, 1)
				value = min + (max - min) * relative

				-- Update visual elements
				sliderFill.Size = UDim2.new(relative, 0, 1, 0)
				valueDisplay.Text = math.round(value)

				if callback then
					callback(value)
				end
			end

			sliderBg.InputBegan:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 then
					dragging = true
					updateSlider(input)
				end
			end)

			UserInputService.InputChanged:Connect(function(input)
				if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
					updateSlider(input)
				end
			end)

			UserInputService.InputEnded:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 then
					dragging = false
				end
			end)

			-- Set initial value
			local initialRelative = (default - min) / (max - min)
			sliderFill.Size = UDim2.new(initialRelative, 0, 1, 0)
			valueDisplay.Text = tostring(default)

			return slider
		end

		self.Tabs[name] = Tab
		return Tab
	end

	-- Delete UI function
	GUI.Base.PageSelectHolder.DeleteUi.MouseButton1Click:Connect(function()
		GUI:Destroy()
	end)

	return Window
end

return Library
