Config = {}

-- Gang definitions (mirrors qb-core/gangs.lua)
Config.Gangs = {
    ['lostmc']   = { label = 'The Lost MC',   color = '#C23B3B', blip = 76  },
    ['ballas']   = { label = 'Ballas',         color = '#8B3A8B', blip = 77  },
    ['vagos']    = { label = 'Vagos',          color = '#E8A33D', blip = 78  },
    ['cartel']   = { label = 'Cartel',         color = '#2FB6A6', blip = 79  },
    ['families'] = { label = 'Families',       color = '#3A8B3A', blip = 80  },
    ['triads']   = { label = 'Triads',         color = '#E83D3D', blip = 81  },
}

-- Capture settings
Config.CaptureDuration = 60          -- seconds to hold uncontested
Config.ContestReset = 10             -- seconds before contest resets progress
Config.CaptureCooldown = 300         -- seconds before a captured zone can be recaptured (5 min)
Config.CaptureRadius = 50.0          -- radius to be considered "in zone"

-- Income per territory per pay period (in-game 30 min)
Config.TerritoryIncome = 250

-- Territory zone definitions
-- PolyZone-compatible: center + radius for simple circle zones
Config.Territories = {
    -- The Lost MC (Sandy Shores / Route 68)
    ['sandy_shores'] = {
        label = 'Sandy Shores',
        gang = 'lostmc',
        coords = vec3(1050.0, 2200.0, 35.0),
        radius = 100.0,
        description = 'The Lost MC heartland'
    },
    ['grapeseed'] = {
        label = 'Grapeseed',
        gang = 'lostmc',
        coords = vec3(1650.0, 4800.0, 42.0),
        radius = 80.0,
        description = 'Rural farmland'
    },
    ['route68'] = {
        label = 'Route 68',
        gang = 'lostmc',
        coords = vec3(-200.0, 2600.0, 48.0),
        radius = 90.0,
        description = 'Highway through the valley'
    },

    -- Ballas (South Central: Davis, Strawberry)
    ['davis'] = {
        label = 'Davis',
        gang = 'ballas',
        coords = vec3(50.0, -1950.0, 20.0),
        radius = 100.0,
        description = 'South Central stronghold'
    },
    ['strawberry'] = {
        label = 'Strawberry',
        gang = 'ballas',
        coords = vec3(-50.0, -1700.0, 29.0),
        radius = 80.0,
        description = 'Ballas turf'
    },
    ['carson'] = {
        label = 'Carson Ave',
        gang = 'ballas',
        coords = vec3(150.0, -1850.0, 25.0),
        radius = 70.0,
        description = 'Ballas strip'
    },

    -- Vagos (Rancho / El Burro Heights)
    ['rancho'] = {
        label = 'Rancho',
        gang = 'vagos',
        coords = vec3(440.0, -1600.0, 29.0),
        radius = 90.0,
        description = 'Vagos neighborhood'
    },
    ['el_burro'] = {
        label = 'El Burro Heights',
        gang = 'vagos',
        coords = vec3(1200.0, -1400.0, 35.0),
        radius = 80.0,
        description = 'East side hills'
    },
    ['la_mesa'] = {
        label = 'La Mesa',
        gang = 'vagos',
        coords = vec3(800.0, -1900.0, 30.0),
        radius = 75.0,
        description = 'Industrial quarter'
    },

    -- Cartel (Murrieta Heights / Terminal)
    ['murrieta'] = {
        label = 'Murrieta Heights',
        gang = 'cartel',
        coords = vec3(-850.0, -900.0, 20.0),
        radius = 80.0,
        description = 'Cartel operations'
    },
    ['terminal'] = {
        label = 'Terminal',
        gang = 'cartel',
        coords = vec3(-1050.0, -1500.0, 10.0),
        radius = 100.0,
        description = 'Port district'
    },
    ['textile'] = {
        label = 'Textile City',
        gang = 'cartel',
        coords = vec3(-600.0, -700.0, 28.0),
        radius = 70.0,
        description = 'Warehouse district'
    },

    -- Families (Chamberlain Hills)
    ['chamberlain'] = {
        label = 'Chamberlain Hills',
        gang = 'families',
        coords = vec3(-150.0, -1500.0, 35.0),
        radius = 90.0,
        description = 'Families stronghold'
    },
    ['forum_drive'] = {
        label = 'Forum Drive',
        gang = 'families',
        coords = vec3(-250.0, -1650.0, 30.0),
        radius = 70.0,
        description = 'Families strip'
    },
    ['covenant'] = {
        label = 'Covenant Ave',
        gang = 'families',
        coords = vec3(-100.0, -1400.0, 32.0),
        radius = 65.0,
        description = 'Families turf'
    },

    -- Triads (Little Seoul / Pillbox)
    ['little_seoul'] = {
        label = 'Little Seoul',
        gang = 'triads',
        coords = vec3(-750.0, -500.0, 33.0),
        radius = 80.0,
        description = 'Triad district'
    },
    ['pillbox'] = {
        label = 'Pillbox Hill',
        gang = 'triads',
        coords = vec3(-300.0, -300.0, 50.0),
        radius = 75.0,
        description = 'Financial district'
    },
    ['mission_row'] = {
        label = 'Mission Row',
        gang = 'triads',
        coords = vec3(-450.0, -350.0, 40.0),
        radius = 70.0,
        description = 'Triad territory'
    },
}

-- Notification methods
Config.Notify = function(src, msg, type)
    TriggerClientEvent('QBCore:Notify', src, msg, type or 'primary')
end
