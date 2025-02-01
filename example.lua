local library = {}

-- Create new window
function library:CreateWindow()
    local uiObject = {
        Tabs = {},
        CurrentTab = nil
    }

    -- Create main window
    local gui = game.Players.LocalPlayer.PlayerGui:WaitForChild("Library") 
    local base = gui:WaitForChild("Base")
    
    -- Make window draggable
    local UserInputService = game:GetService("UserInputService")
    local dragging
    local dragInput
    local dragStart
    local startPos

    local function update(input)
        local delta = input.Position - dragStart
        base.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end

    base.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = base.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    base.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            update(input)
        end
    end)

    -- Handle Discord button
    local discordButton = base.SelectionHolder.DiscordHolder.ServerJoinText
    discordButton.MouseButton1Click:Connect(function()
        setclipboard("https://discord.gg/yourserver") -- Replace with your Discord link
    end)

    -- Handle close button
    local closeButton = base.DeleteUi
    closeButton.MouseButton1Click:Connect(function()
        gui:Destroy()
    end)

    -- Create tab function
    function uiObject:CreateTab(name, icon)
        local tab = {
            Buttons = {},
            Toggles = {},
            Inputs = {},
            Dropdowns = {},
            Sliders = {}
        }
        
        -- Create tab button
        local scrollFrame = base.SelectionHolder.TabSelectionHolder.ScrollingFrame
        local tabButton = scrollFrame.tab1:Clone()
        tabButton.Name = name
        tabButton.Text = name:upper()
        tabButton.Parent = scrollFrame
        
        if icon then
            tabButton.Imagebuttontab1.Image = icon
        end
        
        -- Create tab content
        local pageLeft = base.FunctionHolder.PageLeft:Clone()
        pageLeft.Name = name .. "Content"
        pageLeft.Visible = false
        pageLeft.Parent = base.FunctionHolder
        
        -- Handle tab selection
        tabButton.MouseButton1Click:Connect(function()
            if uiObject.CurrentTab then
                uiObject.CurrentTab.Visible = false
            end
            pageLeft.Visible = true
            uiObject.CurrentTab = pageLeft
            
            -- Update tab visual selection
            for _, tab in pairs(scrollFrame:GetChildren()) do
                if tab:IsA("TextButton") then
                    tab.BackgroundTransparency = 1
                    tab.TextTransparency = 0.8
                    tab:FindFirstChild("Imagebuttontab1").ImageTransparency = 0.8
                end
            end
            tabButton.BackgroundTransparency = 0
            tabButton.TextTransparency = 0
            tabButton.Imagebuttontab1.ImageTransparency = 0
        end)

        -- Create elements functions
        function tab:CreateToggle(name, description, callback)
            local toggle = base.FunctionHolder.PageLeft.Toggle:Clone()
            toggle.ToggleNameFunction.Text = name
            toggle.Parent = pageLeft
            
            local toggleButton = toggle.ToggleTextLabelDescription.FrameToggleOff.Toggle
            local isEnabled = false
            
            toggleButton.MouseButton1Click:Connect(function()
                isEnabled = not isEnabled
                if isEnabled then
                    toggleButton.Position = UDim2.new(0.6, 0, 0.12, 0)
                    toggleButton.BackgroundColor3 = Color3.fromRGB(200, 200, 200)
                else
                    toggleButton.Position = UDim2.new(0, 0, 0.12, 0)
                    toggleButton.BackgroundColor3 = Color3.fromRGB(122, 122, 122)
                end
                if callback then callback(isEnabled) end
            end)
            
            return toggle
        end

        function tab:CreateInput(name, description, callback)
            local input = base.FunctionHolder.PageLeft.Input:Clone()
            input.InputNameFunction.Text = name
            input.InputTextLabelDescription.Text = description
            input.Parent = pageLeft
            
            local textBox = input.InputTextLabelDescription.FrameInput.Inputtext
            textBox.FocusLost:Connect(function()
                if callback then callback(textBox.Text) end
            end)
            
            return input
        end

        function tab:CreateButton(name, callback)
            local button = Button:Clone()
            button.DropdownNameFunction.Text = name
            button.Parent = pageLeft
            
            local buttonElement = button.ButtonHolder.Button.TextButton
            buttonElement.MouseButton1Click:Connect(function()
                if callback then callback() end
            end)
            
            return button
        end

        function tab:CreateSlider(name, min, max, default, callback)
            local slider = Button_3:Clone()
            slider.DropdownNameFunction.Text = name
            slider.Parent = pageLeft
            
            local sliderBar = slider.ButtonHolder.Button
            local sliderFill = sliderBar.Button
            local sliderHandle = sliderBar.Frame
            local dragging = false
            
            local function updateSlider(input)
                local pos = math.clamp((input.Position.X - sliderBar.AbsolutePosition.X) / sliderBar.AbsoluteSize.X, 0, 1)
                local value = math.floor(min + (max - min) * pos)
                
                sliderFill.Size = UDim2.new(pos, 0, 1, 0)
                sliderHandle.Position = UDim2.new(pos, -6, -0.417, 0)
                
                if callback then callback(value) end
            end
            
            sliderHandle.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    dragging = true
                end
            end)
            
            sliderHandle.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    dragging = false
                end
            end)
            
            UserInputService.InputChanged:Connect(function(input)
                if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                    updateSlider(input)
                end
            end)
            
            -- Set default value
            if default then
                local pos = (default - min) / (max - min)
                sliderFill.Size = UDim2.new(pos, 0, 1, 0)
                sliderHandle.Position = UDim2.new(pos, -6, -0.417, 0)
            end
            
            return slider
        end

        function tab:CreateDropdown(name, options, callback)
            local dropdown = base.FunctionHolder.PageRight.Dropdown:Clone()
            dropdown.DropdownNameFunction.Text = name
            dropdown.Parent = pageLeft
            
            local dropdownButton = dropdown.DropdownHolder.dropdownOff
            local optionsList = dropdown.ResultDropdownOn
            optionsList.Visible = false
            
            -- Add options
            for _, option in pairs(options) do
                local optionButton = optionsList.TextButton:Clone()
                optionButton.Text = option
                optionButton.Parent = optionsList
                
                optionButton.MouseButton1Click:Connect(function()
                    if callback then callback(option) end
                    dropdownButton.Text = option
                    optionsList.Visible = false
                end)
            end
            
            dropdownButton.MouseButton1Click:Connect(function()
                optionsList.Visible = not optionsList.Visible
            end)
            
            return dropdown
        end

        self.Tabs[name] = tab
        return tab
    end

    return uiObject
end

return library
