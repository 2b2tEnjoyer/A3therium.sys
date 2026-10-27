local Module = {}
local camera = workspace.CurrentCamera

function Module:apply(config)
    self:update(config)
end

function Module:update(config)
    if config.mod_fov then
        local targetFov = tonumber(config.fov_value) or 80
        camera.FieldOfView = targetFov
    else
        camera.FieldOfView = 70
    end
end

return Module
