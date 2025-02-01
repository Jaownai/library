local Library = {}
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

function Library:CreateWindow(name)
    -- Clone the ScreenGui template
    local gui = script.Parent:WaitForChild("Library"):Clone()
    gui.Name = name
    gui.Parent = game.Players.LocalPlayer.PlayerGui
    
    local window = {}
    local currentTab = nil
    local tabs = {}
    
    -- Set window name
    gui.Base.SelectionHolder.NameAndLogoHolder.Name.Text = name
    
    -- Dragging functionality
    local dragging
    local dragInput
    local dragStart
    local startPos
    
    local function updateDrag(input)
        local delta = input.Position - dragStart
        gui.Base.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
    
    gui.Base.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = gui.Base.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    
    gui.Base.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            updateDrag(input)
        end
    end)
    
    -- Tab functionality
    function window:CreateTab(tabName, imageId)
        local tab = {}
        local tabButton = gui.Base.SelectionHolder.TabSelectionHolder.ScrollingFrame.tab1:Clone()
        tabButton.Parent = gui.Base.SelectionHolder.TabSelectionHolder.ScrollingFrame
        tabButton.Text = tabName
        tabButton.Name = tabName
        
        if imageId then
            tabButton.Imagebuttontab1.Image = imageId
        end
        
        local pageLeft = gui.Base.FunctionHolder.PageLeft:Clone()
        pageLeft.Name = tabName .. "Page"
        pageLeft.Parent = gui.Base.FunctionHolder
        pageLeft.Visible = false
        
        tabs[tabName] = {button = tabButton, page = pageLeft}
        
        -- Tab selection handling
        tabButton.MouseButton1Click:Connect(function()
            if currentTab then
                tabs[currentTab].page.Visible = false
                tabs[currentTab].button.BackgroundTransparency = 1
                tabs[currentTab].button.TextTransparency = 0.8
                tabs[currentTab].button.Imagebuttontab1.ImageTransparency = 0.8
            end
            
            pageLeft.Visible = true
            tabButton.BackgroundTransparency = 0
            tabButton.TextTransparency = 0
            tabButton.Imagebuttontab1.ImageTransparency = 0
            currentTab = tabName
        end)
        
        if currentTab == nil then
            currentTab = tabName
            pageLeft.Visible = true
            tabButton.BackgroundTransparency = 0
            tabButton.TextTransparency = 0
            tabButton.Imagebuttontab1.ImageTransparency = 0
        end
        
        -- Element creation functions
        function tab:CreateToggle(name, description, callback)
            local toggle = gui.Base.FunctionHolder.PageLeft.Toggle:Clone()
            toggle.Parent = pageLeft
            toggle.ToggleNameFunction.Text = name
            toggle.ToggleTextLabelDescription.Text = description
            
            local enabled = false
            local toggleButton = toggle.ToggleTextLabelDescription.FrameToggleOff.Toggle
            
            toggleButton.MouseButton1Click:Connect(function()
                enabled = not enabled
                
                local goal = {
                    Position = enabled and UDim2.new(0.6, 0, 0.12, 0) or UDim2.new(0, 0, 0.12, 0),
                    BackgroundColor3 = enabled and Color3.fromRGB(200, 200, 200) or Color3.fromRGB(122, 122, 122)
                }
                
                TweenService:Create(toggleButton, TweenInfo.new(0.2), goal):Play()
                
                if callback then
                    callback(enabled)
                end
            end)
            
            return toggle
        end
        
        function tab:CreateInput(name, description, default, callback)
            local input = gui.Base.FunctionHolder.PageLeft.Input:Clone()
            input.Parent = pageLeft
            input.InputNameFunction.Text = name
            input.InputTextLabelDescription.Text = description
            input.InputTextLabelDescription.FrameInput.Inputtext.Text = default or ""
            
            input.InputTextLabelDescription.FrameInput.Inputtext.FocusLost:Connect(function()
                if callback then
                    callback(input.InputTextLabelDescription.FrameInput.Inputtext.Text)
                end
            end)
            
            return input
        end
        
        function tab:CreateKeybind(name, description, default, callback)
            local keybind = gui.Base.FunctionHolder.PageLeft.Keybind:Clone()
            keybind.Parent = pageLeft
            keybind.KeybindNameFunction.Text = name
            keybind.KeybindTextLabelDescription.Text = description
            keybind.KeybindTextLabelDescription.FrameInputHolder.KeybindInput.Text = default or "None"
            
            local listening = false
            local currentKey = default
            
            keybind.KeybindTextLabelDescription.FrameInputHolder.KeybindInput.MouseButton1Click:Connect(function()
                listening = true
                keybind.KeybindTextLabelDescription.FrameInputHolder.KeybindInput.Text = "..."
            end)
            
            UserInputService.InputBegan:Connect(function(input)
                if listening then
                    if input.UserInputType == Enum.UserInputType.Keyboard then
                        currentKey = input.KeyCode
                        keybind.KeybindTextLabelDescription.FrameInputHolder.KeybindInput.Text = tostring(currentKey)
                        listening = false
                        if callback then
                            callback(currentKey)
                        end
                    end
                elseif input.KeyCode == currentKey then
                    if callback then
                        callback(currentKey)
                    end
                end
            end)
            
            return keybind
        end
        
        function tab:CreateDropdown(name, description, options, callback)
            local dropdown = gui.Base.FunctionHolder.PageRight.Dropdown:Clone()
            dropdown.Parent = pageLeft
            dropdown.DropdownNameFunction.Text = name
            dropdown.DropdownOffTextLabelDescription.Text = description
            
            local isOpen = false
            local resultDropdown = dropdown.DropdownOnTextLabelDescription.ResultDropdownOn
            resultDropdown.Visible = false
            
            -- Clear default buttons
            for _, child in ipairs(resultDropdown:GetChildren()) do
                if child:IsA("TextButton") then
                    child:Destroy()
                end
            end
            
            -- Create option buttons
            for _, option in ipairs(options) do
                local button = Instance.new("TextButton")
                button.Parent = resultDropdown
                button.Size = UDim2.new(0, 75, 0, 25)
                button.BackgroundTransparency = 1
                button.Text = option
                button.TextColor3 = Color3.fromRGB(126, 126, 126)
                button.TextSize = 14
                button.Font = Enum.Font.SourceSans
                button.TextXAlignment = Enum.TextXAlignment.Left
                
                local padding = Instance.new("UIPadding")
                padding.Parent = button
                padding.PaddingLeft = UDim.new(0, 8)
                
                button.MouseButton1Click:Connect(function()
                    dropdown.DropdownOffTextLabelDescription.DropdownHolder.dropdownOff.Text = option
                    resultDropdown.Visible = false
                    isOpen = false
                    if callback then
                        callback(option)
                    end
                end)
            end
            
            dropdown.DropdownOffTextLabelDescription.DropdownHolder.dropdownOff.MouseButton1Click:Connect(function()
                isOpen = not isOpen
                resultDropdown.Visible = isOpen
            end)
            
            return dropdown
        end
        
        function tab:CreateButton(name, description, callback)
            local button = gui.Base.FunctionHolder.PageRight.Button:Clone()
            button.Parent = pageLeft
            button.ButtonNameFunction.Text = name
            button.ButtonHolder.ButtonHolderButtonPlace.TextButton.Text = description
            
            button.ButtonHolder.ButtonHolderButtonPlace.TextButton.MouseButton1Click:Connect(function()
                if callback then
                    callback()
                end
            end)
            
            return button
        end
        
        function tab:CreateSlider(name, min, max, default, callback)
            local slider = gui.Base.FunctionHolder.PageRight.Silder:Clone()
            slider.Parent = pageLeft
            slider.SilderBarNameFunction.Text = name
            
            local sliderBar = slider.SilderHolder.SilderBar
            local sliderDrag = sliderBar.SilderDrag
            local sliderFill = sliderBar.SilderBar50
            
            local dragging = false
            local value = default or min
            
            local function updateSlider(input)
                local pos = math.clamp((input.Position.X - sliderBar.AbsolutePosition.X) / sliderBar.AbsoluteSize.X, 0, 1)
                local newValue = math.floor(min + (max - min) * pos)
                value = newValue
                
                sliderDrag.Position = UDim2.new(pos, -6, -0.417, 0)
                sliderFill.Size = UDim2.new(pos, 0, 1, 0)
                
                if callback then
                    callback(value)
                end
            end
            
            sliderDrag.MouseButton1Down:Connect(function()
                dragging = true
            end)
            
            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    dragging = false
                end
            end)
            
            UserInputService.InputChanged:Connect(function(input)
                if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                    updateSlider(input)
                end
            end)
            
            -- Set initial value
            local initialPos = (value - min) / (max - min)
            sliderDrag.Position = UDim2.new(initialPos, -6, -0.417, 0)
            sliderFill.Size = UDim2.new(initialPos, 0, 1, 0)
            
            return slider
        end
        
        return tab
    end
    
    -- Close button functionality
    gui.Base.PageSelectHolder.DeleteUi.MouseButton1Click:Connect(function()
        gui:Destroy()
    end)
    
    return window
end

return Library

