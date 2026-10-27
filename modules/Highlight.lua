local Module = {}

function Module:apply(config)
    self:update(config)
end

function Module:update(config)
    local enabled = config.mod_highlight
    local players = game:GetService("Players").Players
    
    for _, player in ipairs(players) do
        local char = player.Character
        if char then
            local hl = char:FindFirstChildOfClass("Highlight")
            if enabled then
                if not hl then
                    hl = Instance.new("Highlight")
                    hl.FillColor = Color3.fromRGB(0, 255, 150)
                    hl.FillTransparency = 0.5
                    hl.OutlineColor = Color3.fromRGB(0, 255, 150)
                    hl.OutlineTransparency = 0
                    hl.Parent = char
                end
            else
                if hl then hl:Destroy() end
            end
        end
    end
end

return Module
