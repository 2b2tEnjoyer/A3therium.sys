local Module = {}
local Lighting = game:GetService("Lighting")
local SkyboxPresets = {
    ["default"] = "rbxassetid://445586801",
    ["night"] = "rbxassetid://445586802"
}

function Module:apply(config)
    self:update(config)
end

function Module:update(config)
    if config.mod_skybox then
        local preset = config.skybox_preset or "default"
        local skyId = SkyboxPresets[preset]
        if skyId then
            local sky = Instance.new("Sky")
            sky.SkyboxBk = skyId
            sky.SkyboxDn = skyId
            sky.SkyboxFt = skyId
            sky.SkyboxLf = skyId
            sky.SkyboxRt = skyId
            sky.SkyboxUp = skyId
            sky.Parent = Lighting
            for _, child in ipairs(Lighting:GetChildren()) do
                if child:IsA("Sky") and child ~= sky then child:Destroy() end
            end
        end
    else
        for _, child in ipairs(Lighting:GetChildren()) do
            if child:IsA("Sky") then child:Destroy() end
        end
    end
end

return Module
