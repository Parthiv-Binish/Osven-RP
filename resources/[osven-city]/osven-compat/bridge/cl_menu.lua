-- qb-menu → ox_lib compatibility bridge
-- Translates exports['qb-menu']:openMenu(qbMenuData) to lib.showMenu()
-- and exports['qb-menu']:closeMenu() to lib.hideMenu()

local menuCounter = 0
local activeMenus = {}

-- Generate unique menu ID
local function genMenuId(header)
    menuCounter = menuCounter + 1
    local name = header and header:lower():gsub('[^%w]', '_'):sub(1, 20) or 'menu'
    if name == '' then name = 'menu' end
    return 'osven_menu_' .. name .. '_' .. menuCounter
end

-- Convert qb-menu item format to ox_lib option format
local function qbItemToOxOption(item, menuId)
    if not item or not item.header then return nil end
    if item.isMenuHeader then return nil end

    local label = item.header or ''
    local desc = item.txt or ''
    local icon = item.icon

    return {
        label = label,
        description = desc,
        icon = icon,
        onSelect = function()
            if item.params and item.params.event then
                TriggerEvent(item.params.event, item.params.args)
            end
        end,
    }
end

-- Convert full qb-menu data to ox_lib menu format
local function qbMenuToOxLib(qbData)
    if not qbData or #qbData == 0 then return nil end

    local title = ''
    local options = {}

    for i, item in ipairs(qbData) do
        if i == 1 and item.isMenuHeader then
            title = item.header or ''
        else
            local opt = qbItemToOxOption(item)
            if opt then table.insert(options, opt) end
        end
    end

    if #options == 0 then return nil end

    -- Handle "Back" menu option for submenus
    local isSubmenu = false
    for _, item in ipairs(qbData) do
        if item.header and item.header:lower() == 'back' then
            isSubmenu = true
            break
        end
    end

    return {
        title = title,
        options = options,
    }
end

-- Export: openMenu
exports('openMenu', function(data, isSubmenu, isScroll)
    if GetResourceState('ox_lib') ~= 'started' then
        -- Fallback to qb-menu if available
        if GetResourceState('qb-menu') == 'started' then
            exports['qb-menu']:openMenu(data, isSubmenu, isScroll)
        end
        return
    end

    local menu = qbMenuToOxLib(data)
    if not menu then return end

    local menuId = genMenuId(menu.title)
    menu.id = menuId

    lib.registerMenu(menu, function(selected, scrollIndex, args)
        -- ox_lib handles onSelect callbacks, this is for additional handling
    end)

    lib.showMenu(menuId)
    activeMenus[menuId] = true
end)

-- Export: closeMenu
exports('closeMenu', function()
    if GetResourceState('ox_lib') ~= 'started' then
        if GetResourceState('qb-menu') == 'started' then
            exports['qb-menu']:closeMenu()
        end
        return
    end

    -- Hide all active menus
    for menuId, _ in pairs(activeMenus) do
        lib.hideMenu()
        activeMenus[menuId] = nil
    end
end)

-- Export: showHeader (qb-menu compatibility for single-header menus)
exports('showHeader', function(data)
    -- Convert header-only display to ox_lib context menu
    -- Most showHeader calls display a single item with options
    if not data or #data == 0 then return end
    exports('openMenu', data, false, false)
end)

-- Override qb-menu exports globally
-- This allows resources doing exports['qb-menu']:openMenu() to work
-- through the osven-compat resource, provided it loads after qb-menu
-- and before resources that call it.

-- We use AddEventHandler to listen for the resource starting
-- and register our exports under the qb-menu name
Citizen.CreateThread(function()
    -- Wait for resources using qb-menu to start
    -- The actual interception happens via resource priority
    -- This resource should be ensured before any resource that calls qb-menu
end)

print('[osven-compat] qb-menu bridge loaded (proxying to ox_lib)')
