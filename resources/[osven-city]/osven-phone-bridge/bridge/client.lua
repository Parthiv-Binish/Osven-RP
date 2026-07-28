-- ============ qb-phone Compat Client ============
-- Only provide exports that map to real NPWD server exports

-- GetPhoneData -> NPWD getPlayerData
exports('GetPhoneData', function(cb)
    local data = lib.callback.await('qb-phone:server:GetPhoneData', false)
    if cb then cb(data) end
    return data
end)

-- SendMessage -> NPWD emitMessage
exports('SendMessage', function(data, cb)
    local result = lib.callback.await('qb-phone:server:sendMessage', false, data)
    if cb then cb(result) end
    return result
end)

-- Note: NPWD handles messages, contacts, calls entirely through the
-- client-side phone app. There are no qb-phone compatible server exports
-- for GetMessages, GetConversations, GetContacts, AddContact, DeleteContact,
-- or GetCalls. These are all handled natively by NPWD's UI.

print('[osven-phone-bridge] Client bridge loaded.')
