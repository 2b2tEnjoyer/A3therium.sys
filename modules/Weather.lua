local Module = {}
local Lighting = game:GetService("Lighting")

function Module:apply(config)
    self:update(config)
end

function Module:update(config)
    if config.mod_weather then
        local fogType = config.weather_type or "fog"
        if fogType == "fog" then
            Lighting.FogEnd = 1000
            Lighting.FogColor = Color3.fromRGB(100, 100, 100)
        else
            Lighting.FogEnd = 1e9
        end
    else
        Lighting.FogEnd = 1e9
    end
end

return Module
