-- qb-input → ox_lib compatibility bridge
-- Translates exports['qb-input']:ShowInput(qbInputData, callback) to lib.inputDialog()

-- Convert qb-input format to ox_lib inputDialog format
local function qbInputToOxLib(data)
    if not data or not data.inputs then return nil, nil end

    local title = data.header or 'Input'
    local options = {}

    for _, input in ipairs(data.inputs) do
        local opt = {
            type = input.type or 'input',
            label = input.text or '',
            placeholder = input.placeholder or '',
            default = input.default or '',
            required = input.isRequired or false,
            min = input.min or 0,
            max = input.max or 999999,
        }

        if opt.type == 'number' then
            opt.type = 'number'
            opt.min = input.min or 0
            opt.max = input.max or 999999
        elseif opt.type == 'date' or opt.type == 'date' then
            opt.type = 'date'
        end

        table.insert(options, opt)
    end

    return title, options
end

-- Export: ShowInput
exports('ShowInput', function(data, cb)
    if GetResourceState('ox_lib') ~= 'started' then
        -- Fallback to qb-input if available
        if GetResourceState('qb-input') == 'started' then
            exports['qb-input']:ShowInput(data, cb)
        end
        return
    end

    local title, options = qbInputToOxLib(data)
    if not title or not options or #options == 0 then
        if cb then cb({}) end
        return
    end

    local result = lib.inputDialog(title, options)

    if result then
        -- Convert array result to named table (qb-input style)
        local named = {}
        for i, input in ipairs(data.inputs) do
            named[input.name] = result[i]
        end
        named[1] = result[1]
        named[2] = result[2]
        if cb then cb(named) end
    else
        if cb then cb({}) end
    end
end)

print('[osven-compat] qb-input bridge loaded (proxying to ox_lib)')
