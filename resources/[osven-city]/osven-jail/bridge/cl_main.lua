RegisterNetEvent('osven-jail:client:startSentence', function(seconds)
    SendNUIMessage({ type = 'START_SENTENCE', seconds = seconds })
end)

RegisterNetEvent('osven-jail:client:released', function()
    SendNUIMessage({ type = 'RELEASED' })
end)

RegisterNetEvent('osven-jail:client:communityProgress', function(percent, secondsLeft)
    SendNUIMessage({ type = 'COMMUNITY_PROGRESS', percent = percent, secondsLeft = secondsLeft })
end)

RegisterNUICallback('jail:startCS', function(_, cb)
    cb({})
    TriggerServerEvent('osven-jail:server:startCommunityService')
end)
