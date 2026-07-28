return {
	General = {
		name = '24/7 Shop',
		blip = { id = 59, colour = 69, scale = 0.8 },
		inventory = {
			{ name = 'water_bottle', price = 5 },
			{ name = 'taco', price = 8 },
			{ name = 'sandwich', price = 10 },
			{ name = 'burger', price = 12 },
			{ name = 'cola', price = 6 },
			{ name = 'coffee', price = 7 },
			{ name = 'bandage', price = 15, metadata = { type = 'medical' } },
			{ name = 'repairkit', price = 250 },
			{ name = 'cleaningkit', price = 80 },
		},
		locations = {
			vec3(25.7, -1347.3, 29.49),
			vec3(-3038.71, 585.9, 7.9),
			vec3(-3241.47, 1001.14, 12.83),
			vec3(1728.66, 6414.16, 35.03),
			vec3(1697.99, 4924.4, 42.06),
			vec3(1961.48, 3739.96, 32.34),
			vec3(547.79, 2671.79, 42.15),
			vec3(2679.25, 3280.12, 55.24),
			vec3(2557.94, 382.05, 108.62),
			vec3(373.55, 325.56, 103.56),
		},
		targets = {
			{ loc = vec3(25.06, -1347.32, 29.5), length = 0.7, width = 0.5, heading = 0.0, minZ = 29.5, maxZ = 29.9, distance = 1.5 },
			{ loc = vec3(-3039.18, 585.13, 7.91), length = 0.6, width = 0.5, heading = 15.0, minZ = 7.91, maxZ = 8.31, distance = 1.5 },
			{ loc = vec3(-3242.2, 1000.58, 12.83), length = 0.6, width = 0.6, heading = 175.0, minZ = 12.83, maxZ = 13.23, distance = 1.5 },
			{ loc = vec3(1728.39, 6414.95, 35.04), length = 0.6, width = 0.6, heading = 65.0, minZ = 35.04, maxZ = 35.44, distance = 1.5 },
			{ loc = vec3(1698.37, 4923.43, 42.06), length = 0.5, width = 0.5, heading = 235.0, minZ = 42.06, maxZ = 42.46, distance = 1.5 },
			{ loc = vec3(1960.54, 3740.28, 32.34), length = 0.6, width = 0.5, heading = 120.0, minZ = 32.34, maxZ = 32.74, distance = 1.5 },
			{ loc = vec3(548.5, 2671.25, 42.16), length = 0.6, width = 0.5, heading = 10.0, minZ = 42.16, maxZ = 42.56, distance = 1.5 },
			{ loc = vec3(2678.29, 3279.94, 55.24), length = 0.6, width = 0.5, heading = 330.0, minZ = 55.24, maxZ = 55.64, distance = 1.5 },
			{ loc = vec3(2557.19, 381.4, 108.62), length = 0.6, width = 0.5, heading = 0.0, minZ = 108.62, maxZ = 109.02, distance = 1.5 },
			{ loc = vec3(373.13, 326.29, 103.57), length = 0.6, width = 0.5, heading = 345.0, minZ = 103.57, maxZ = 103.97, distance = 1.5 },
		}
	},

	Liquor = {
		name = 'Liquor Store',
		blip = { id = 93, colour = 69, scale = 0.8 },
		inventory = {
			{ name = 'water_bottle', price = 8 },
			{ name = 'cola', price = 8 },
			{ name = 'coffee', price = 10 },
		},
		locations = {
			vec3(-1222.76, -907.97, 12.33),
			vec3(-1487.22, -379.24, 40.16),
			vec3(-2968.44, 390.74, 15.04),
			vec3(1166.04, 2709.85, 38.16),
			vec3(1135.77, -983.2, 46.42),
			vec3(-560.34, 274.82, 82.11),
		},
		targets = {
			{ loc = vec3(-1222.9, -908.4, 12.33), length = 0.6, width = 0.5, heading = 30.0, minZ = 12.33, maxZ = 12.73, distance = 1.5 },
			{ loc = vec3(-1487.6, -379.5, 40.16), length = 0.6, width = 0.5, heading = 130.0, minZ = 40.16, maxZ = 40.56, distance = 1.5 },
			{ loc = vec3(-2968.6, 391.1, 15.04), length = 0.6, width = 0.5, heading = 10.0, minZ = 15.04, maxZ = 15.44, distance = 1.5 },
			{ loc = vec3(1165.6, 2709.8, 38.16), length = 0.6, width = 0.5, heading = 170.0, minZ = 38.16, maxZ = 38.56, distance = 1.5 },
			{ loc = vec3(1135.6, -983.6, 46.42), length = 0.6, width = 0.5, heading = 280.0, minZ = 46.42, maxZ = 46.82, distance = 1.5 },
			{ loc = vec3(-560.6, 274.8, 82.11), length = 0.6, width = 0.5, heading = 180.0, minZ = 82.11, maxZ = 82.51, distance = 1.5 },
		}
	},

	PoliceArmory = {
		name = 'PD Armory',
		blip = { id = 526, colour = 38, scale = 0.7 },
		inventory = {
			{ name = 'weapon_stungun', price = 0, group = shared.police, metadata = { serial = 'PD-' .. math.random(100000, 999999) }, ammo = nil },
			{ name = 'weapon_nightstick', price = 0, group = shared.police },
			{ name = 'weapon_flashlight', price = 0, group = shared.police },
			{ name = 'weapon_pistol', price = 0, group = shared.police },
			{ name = 'weapon_combatpdw', price = 0, group = shared.police, ammo = { name = 'ammo-9', count = 120 } },
			{ name = 'weapon_carbinerifle', price = 0, group = shared.police, ammo = { name = 'ammo-rifle', count = 180 } },
			{ name = 'weapon_pumpshotgun', price = 0, group = shared.police, ammo = { name = 'ammo-shotgun', count = 40 } },
			{ name = 'weapon_pistol50', price = 0, group = shared.police, ammo = { name = 'ammo-9', count = 60 } },
			{ name = 'weapon_specialcarbine', price = 0, group = shared.police, ammo = { name = 'ammo-rifle2', count = 240 } },
			{ name = 'weapon_assaultshotgun', price = 0, group = shared.police, ammo = { name = 'ammo-shotgun', count = 80 } },
			{ name = 'weapon_sniperrifle', price = 0, group = shared.police, ammo = { name = 'ammo-sniper', count = 20 } },
			{ name = 'weapon_flashbang', price = 0, group = shared.police },
			{ name = 'pistol_ammo', price = 0, group = shared.police },
			{ name = 'rifle_ammo', price = 0, group = shared.police },
			{ name = 'shotgun_ammo', price = 0, group = shared.police },
			{ name = 'smg_ammo', price = 0, group = shared.police },
			{ name = 'police_radio', price = 0, group = shared.police },
			{ name = 'police_cuff', price = 0, group = shared.police },
			{ name = 'police_evidencebag', price = 0, group = shared.police },
			{ name = 'police_stormram', price = 0, group = shared.police },
		},
		groups = shared.police,
		locations = {
			vec3(452.3, -991.4, 30.7),
		},
	},

	EMSArmory = {
		name = 'EMS Armory',
		blip = { id = 61, colour = 1, scale = 0.7 },
		inventory = {
			{ name = 'bandage', price = 0, group = shared.ems },
			{ name = 'firstaid', price = 0, group = shared.ems },
			{ name = 'painkillers', price = 0, group = shared.ems },
			{ name = 'antibiotic', price = 0, group = shared.ems },
			{ name = 'morphine', price = 0, group = shared.ems },
			{ name = 'suturekit', price = 0, group = shared.ems },
			{ name = 'defib', price = 0, group = shared.ems },
			{ name = 'ems_radio', price = 0, group = shared.ems },
			{ name = 'ems_bag', price = 0, group = shared.ems },
		},
		groups = shared.ems,
		locations = {
			vec3(296.5, -590.0, 43.3),
		},
	},

	Hardware = {
		name = 'Hardware Store',
		blip = { id = 402, colour = 69, scale = 0.8 },
		inventory = {
			{ name = 'lockpick', price = 200 },
			{ name = 'screwdriver', price = 50 },
			{ name = 'repairkit', price = 300 },
			{ name = 'advancedrepairkit', price = 800 },
			{ name = 'cleaningkit', price = 100 },
			{ name = 'tirekit', price = 200 },
		},
		locations = {
			vec3(45.56, -1749.08, 29.6),
		},
		targets = {
			{ loc = vec3(45.0, -1749.0, 29.6), length = 0.8, width = 0.6, heading = 0, minZ = 29.6, maxZ = 30.0, distance = 1.5 },
		}
	},

	Ammunation = {
		name = 'Ammu-Nation',
		blip = { id = 110, colour = 69, scale = 0.7 },
		inventory = {
			{ name = 'WEAPON_PISTOL', price = 5000, license = 'weapon', metadata = { registered = true } },
			{ name = 'WEAPON_VINTAGEPISTOL', price = 3500, license = 'weapon', metadata = { registered = true } },
			{ name = 'WEAPON_SNSPISTOL', price = 4000, license = 'weapon', metadata = { registered = true } },
			{ name = 'WEAPON_PUMPSHOTGUN', price = 8000, license = 'weapon', metadata = { registered = true } },
		},
		locations = {
			vec3(21.63, -1106.82, 29.8),
			vec3(811.52, -2156.25, 29.62),
			vec3(-662.63, -935.15, 21.83),
			vec3(1696.12, 3760.85, 34.71),
			vec3(-330.05, 6083.57, 31.45),
			vec3(252.65, -49.56, 69.94),
			vec3(22.77, -1107.55, 29.8),
		},
	},

	Jewelry = {
		name = 'Vangelico Jewelry',
		blip = { id = 617, colour = 3, scale = 0.8 },
		inventory = {
			{ name = 'gold_ring', price = 5000 },
			{ name = 'diamond_ring', price = 25000 },
			{ name = 'platinum_ring', price = 50000 },
			{ name = 'goldchain', price = 7500 },
			{ name = 'rolex', price = 15000 },
		},
		locations = {
			vec3(-629.6, -239.9, 38.1),
		},
		targets = {
			{ loc = vec3(-630.0, -238.5, 38.1), length = 0.8, width = 0.6, heading = 0, minZ = 38.1, maxZ = 38.5, distance = 1.5 },
		}
	},

	BlackMarket = {
		name = 'Black Market',
		blip = { id = 500, colour = 1, scale = 0.6 },
		inventory = {
			{ name = 'WEAPON_MICROSMG', price = 15000 },
			{ name = 'WEAPON_ASSAULTRIFLE', price = 35000 },
			{ name = 'WEAPON_SAWNOFFSHOTGUN', price = 12000 },
			{ name = 'lockpick', price = 500 },
			{ name = 'hacker_device', price = 10000 },
			{ name = 'drill', price = 25000 },
		},
		locations = {
			vec3(129.1, -1280.8, 29.27),
		},
	},
}
