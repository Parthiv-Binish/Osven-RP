Config = {}

-- Ring types
Config.Rings = {
    ['gold_ring'] = { label = 'Gold Ring', price = 5000, description = 'Simple gold band' },
    ['diamond_ring'] = { label = 'Diamond Ring', price = 25000, description = 'A ring with a small diamond' },
    ['platinum_ring'] = { label = 'Platinum Ring', price = 50000, description = 'Premium platinum with diamonds' },
}

-- Ceremony locations
Config.CeremonyLocations = {
    {
        label = 'St. Philip Church',
        coords = vec3(-817.5, 186.3, 72.2),
        heading = 30.0,
        ped = `s_f_y_priest_01`,
    },
}

-- Benefits
Config.SpouseHealthRegen = 5    -- HP per 10 seconds when near spouse
Config.SpouseProximityRange = 20.0
Config.DivorcePrice = 10000

-- Marriage UI key
Config.OpenMarriageKey = 'F5'
