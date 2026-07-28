Config = Config or {}

-- Armory locations (geofenced zones)
Config.Armories = {
    ['police'] = {
        label = 'PD Armory',
        coords = vector3(461.87, -979.71, 30.69),
        radius = 3.0,
        job = 'police',
    },
    ['sasp'] = {
        label = 'SASP Armory',
        coords = vector3(1846.05, 2605.3, 45.0),
        radius = 3.0,
        job = 'sasp',
    },
    ['ems'] = {
        label = 'EMS Storage',
        coords = vector3(298.48, -599.67, 43.29),
        radius = 3.0,
        job = 'ambulance',
    },
}

-- Weapon tiers by rank
Config.WeaponTiers = {
    ['cadet'] = {
        label = 'Standard Issue',
        rankIndex = 1,
        weapons = {
            { name = 'weapon_stungun', label = 'Taser', ammo = 0, type = 'equip' },
            { name = 'weapon_nightstick', label = 'Nightstick', ammo = 0, type = 'equip' },
            { name = 'weapon_flashlight', label = 'Flashlight', ammo = 0, type = 'equip' },
        },
        items = {
            { name = 'radio', label = 'Radio', type = 'item' },
            { name = 'handcuffs', label = 'Handcuffs', amount = 3 },
        },
    },
    ['officer'] = {
        label = 'Officer Tier',
        rankIndex = 2,
        weapons = {
            { name = 'weapon_pistol', label = 'Pistol', ammo = 60, type = 'equip' },
            { name = 'weapon_combatpdw', label = 'Combat PDW', ammo = 120, type = 'equip' },
            { name = 'weapon_stungun', label = 'Taser', ammo = 0, type = 'equip' },
            { name = 'weapon_nightstick', label = 'Nightstick', ammo = 0, type = 'equip' },
        },
        items = {
            { name = 'radio', label = 'Radio', amount = 1 },
            { name = 'handcuffs', label = 'Handcuffs', amount = 3 },
            { name = 'armor', label = 'Body Armor', amount = 1 },
        },
    },
    ['sergeant'] = {
        label = 'Sergeant Tier',
        rankIndex = 3,
        weapons = {
            { name = 'weapon_pistol', label = 'Pistol', ammo = 60, type = 'equip' },
            { name = 'weapon_carbinerifle', label = 'Carbine Rifle', ammo = 180, type = 'equip' },
            { name = 'weapon_pumpshotgun', label = 'Shotgun', ammo = 40, type = 'equip' },
            { name = 'weapon_stungun', label = 'Taser', ammo = 0, type = 'equip' },
        },
        items = {
            { name = 'radio', label = 'Radio', amount = 1 },
            { name = 'handcuffs', label = 'Handcuffs', amount = 3 },
            { name = 'armor', label = 'Body Armor', amount = 1 },
        },
    },
    ['lieutenant'] = {
        label = 'Lieutenant Tier',
        rankIndex = 4,
        weapons = {
            { name = 'weapon_pistol50', label = 'Pistol .50', ammo = 40, type = 'equip' },
            { name = 'weapon_specialcarbine', label = 'Special Carbine', ammo = 240, type = 'equip' },
            { name = 'weapon_assaultshotgun', label = 'Assault Shotgun', ammo = 60, type = 'equip' },
            { name = 'weapon_stungun', label = 'Taser', ammo = 0, type = 'equip' },
            { name = 'weapon_flashbang', label = 'Flashbang', ammo = 2, type = 'equip' },
        },
        items = {
            { name = 'radio', label = 'Radio', amount = 1 },
            { name = 'handcuffs', label = 'Handcuffs', amount = 3 },
            { name = 'armor', label = 'Heavy Armor', amount = 1 },
        },
    },
    ['chief'] = {
        label = 'Command Tier',
        rankIndex = 5,
        weapons = {
            { name = 'weapon_pistol50', label = 'Pistol .50', ammo = 60, type = 'equip' },
            { name = 'weapon_specialcarbine', label = 'Special Carbine', ammo = 240, type = 'equip' },
            { name = 'weapon_assaultshotgun', label = 'Assault Shotgun', ammo = 80, type = 'equip' },
            { name = 'weapon_sniperrifle', label = 'Sniper Rifle', ammo = 20, type = 'equip' },
            { name = 'weapon_stungun', label = 'Taser', ammo = 0, type = 'equip' },
            { name = 'weapon_flashbang', label = 'Flashbang', ammo = 4, type = 'equip' },
        },
        items = {
            { name = 'radio', label = 'Radio', amount = 1 },
            { name = 'handcuffs', label = 'Handcuffs', amount = 3 },
            { name = 'armor', label = 'Heavy Armor', amount = 1 },
        },
    },
}

-- EMS tiers
Config.EMSTiers = {
    ['trainee'] = {
        label = 'Trainee',
        rankIndex = 1,
        weapons = {},
        items = {
            { name = 'radio', label = 'Radio', amount = 1 },
            { name = 'bandage', label = 'Bandage', amount = 5 },
            { name = 'firstaid', label = 'First Aid Kit', amount = 2 },
        },
    },
    ['emt'] = {
        label = 'EMT',
        rankIndex = 2,
        weapons = {},
        items = {
            { name = 'radio', label = 'Radio', amount = 1 },
            { name = 'bandage', label = 'Bandage', amount = 10 },
            { name = 'firstaid', label = 'First Aid Kit', amount = 5 },
            { name = 'painkillers', label = 'Painkillers', amount = 5 },
        },
    },
    ['paramedic'] = {
        label = 'Paramedic',
        rankIndex = 3,
        weapons = {},
        items = {
            { name = 'radio', label = 'Radio', amount = 1 },
            { name = 'bandage', label = 'Bandage', amount = 15 },
            { name = 'firstaid', label = 'First Aid Kit', amount = 10 },
            { name = 'painkillers', label = 'Painkillers', amount = 10 },
            { name = 'ifak', label = 'IFAK', amount = 3 },
        },
    },
    ['doctor'] = {
        label = 'Head of Medicine',
        rankIndex = 4,
        weapons = {},
        items = {
            { name = 'radio', label = 'Radio', amount = 1 },
            { name = 'bandage', label = 'Bandage', amount = 20 },
            { name = 'firstaid', label = 'First Aid Kit', amount = 15 },
            { name = 'painkillers', label = 'Painkillers', amount = 15 },
            { name = 'ifak', label = 'IFAK', amount = 5 },
            { name = 'morphine', label = 'Morphine', amount = 3 },
        },
    },
}

-- Uniform definitions
Config.Uniforms = {
    ['police'] = {
        job = 'police',
        label = 'PD Uniform',
        components = {
            { id = 3, drawable = 0, texture = 0 },   -- torso
            { id = 4, drawable = 0, texture = 0 },   -- legs
            { id = 5, drawable = 0, texture = 0 },   -- bags/vests
            { id = 6, drawable = 0, texture = 0 },   -- shoes
            { id = 7, drawable = 0, texture = 0 },   -- accessories
            { id = 8, drawable = 0, texture = 0 },   -- undershirt
            { id = 11, drawable = 0, texture = 0 },  -- torso2
        },
    },
    ['ems'] = {
        job = 'ambulance',
        label = 'EMS Uniform',
        components = {
            { id = 3, drawable = 0, texture = 0 },
            { id = 4, drawable = 0, texture = 0 },
            { id = 6, drawable = 0, texture = 0 },
            { id = 8, drawable = 0, texture = 0 },
            { id = 11, drawable = 0, texture = 0 },
        },
    },
}
