-- Notification exports for other resources

--- Send a notification toast
--- @param data table { type, title, message, duration }
exports('Notify', function(data)
    SendNUI('notify', {
        type = data.type or 'info',
        title = data.title or '',
        message = data.message or '',
        duration = data.duration or 5000,
    })
end)

--- Send an admin broadcast (persistent until dismissed)
exports('AdminBroadcast', function(message)
    SendNUI('notify', {
        type = 'admin',
        title = '📢 ADMIN BROADCAST',
        message = message,
    })
end)

-- Register global notify command for backwards compat
RegisterNetEvent('QBCore:Notify', function(message, type, duration)
    exports('Notify', {
        type = type or 'info',
        message = message,
        duration = duration or 5000,
    })
end)

RegisterNetEvent('ox_lib:notify', function(data)
    exports('Notify', {
        type = data.type or 'info',
        title = data.title or '',
        message = data.description or '',
        duration = data.duration or 5000,
    })
end)
