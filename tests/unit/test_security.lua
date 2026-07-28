-- Security validation tests for Osven City resources
-- Run with: lua tests/unit/test_security.lua

local fs = require('lfs')  -- LuaFileSystem
local ok, checks = true, 0
local issues = {}

-- Patterns that indicate potential security issues
local patterns = {
    { pattern = 'TriggerServerEvent', severity = 'warning', msg = 'Client triggering server events directly (verify rate-limited)' },
    { pattern = 'TriggerClientEvent', severity = 'info', msg = 'Server pushing to client' },
    { pattern = 'RegisterNetEvent.-client:', severity = 'warning', msg = 'Client net event (verify source validation on server side)' },
    { pattern = 'RegisterNUICallback', severity = 'info', msg = 'NUI callback (always validate server-side)' },
    { pattern = 'ExecuteCommand', severity = 'error', msg = 'ExecuteCommand from Lua (potential arbitrary command execution)' },
    { pattern = 'LoadResourceFile', severity = 'warning', msg = 'Loading resource files dynamically' },
}

-- Check all resource bridge files
local function scanBridgeFiles(path)
    for file in fs.dir(path) do
        if file:match('^sv_.*%.lua$') or file:match('^.*sv.*%.lua$') then
            local fullPath = path .. '/' .. file
            for line in io.lines(fullPath) do
                checks = checks + 1
                for _, p in ipairs(patterns) do
                    if line:find(p.pattern) then
                        table.insert(issues, {
                            file = fullPath,
                            line = line,
                            severity = p.severity,
                            msg = p.msg,
                        })
                    end
                end
            end
        end
    end
end

-- Run
scanBridgeFiles('resources/[osven-city]')

-- Report
if #issues > 0 then
    for _, issue in ipairs(issues) do
        if issue.severity == 'error' then
            ok = false
            print('[FAIL] ' .. issue.file .. ': ' .. issue.msg)
            print('       -> ' .. issue.line)
        end
    end
end

print('Security scan complete: ' .. checks .. ' checks, ' .. #issues .. ' findings')
if ok then
    print('All security checks passed.')
    os.exit(0)
else
    print('Security issues found.')
    os.exit(1)
end
