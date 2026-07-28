local circlePromise = nil
local thermiteOpen = false
local thermitePromise = nil

-- ============ CIRCLE ============

local function Circle(cb, circles, seconds)
    if circles == nil or circles < 1 then circles = 1 end
    if seconds == nil or seconds < 1 then seconds = 10 end
    circlePromise = promise.new()
    SendNUIMessage({ action = 'circle-start', circles = circles, time = seconds })
    SetNuiFocus(true, true)
    local result = Citizen.Await(circlePromise)
    cb(result)
end
exports('Circle', Circle)

RegisterNUICallback('circle-fail', function(_, cb)
    if circlePromise then circlePromise:resolve(false) end
    circlePromise = nil
    SetNuiFocus(false, false)
    cb('ok')
end)

RegisterNUICallback('circle-success', function(_, cb)
    if circlePromise then circlePromise:resolve(true) end
    circlePromise = nil
    SetNuiFocus(false, false)
    cb('ok')
end)

-- ============ THERMITE ============

RegisterNUICallback('thermite-callback', function(data, cb)
    SetNuiFocus(false, false)
    if thermitePromise then thermitePromise:resolve(data.success) end
    thermitePromise = nil
    thermiteOpen = false
    cb('ok')
end)

local function Thermite(cb, time, gridsize, wrong)
    if thermiteOpen then return end
    thermitePromise = promise.new()
    if time == nil then time = 10 end
    if gridsize == nil then gridsize = 6 end
    if wrong == nil then wrong = 3 end
    thermiteOpen = true
    SendNUIMessage({ action = 'thermite-start', time = time, gridsize = gridsize, wrong = wrong })
    SetNuiFocus(true, true)
    local result = Citizen.Await(thermitePromise)
    cb(result)
end
exports('Thermite', Thermite)

-- ============ STUB EXPORTS (ps-ui compat for other minigames not ported) ============

exports('Maze', function(cb, _) if cb then cb(true) end end)
exports('VarHack', function(cb, _, _) if cb then cb(true) end end)
exports('Scrambler', function(cb) if cb then cb(true) end end)
exports('DisplayText', function(_, _) end)
exports('HideText', function() end)
exports('StatusShow', function(_, _) end)
exports('StatusHide', function() end)
