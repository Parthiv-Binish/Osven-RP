return {
	-- Police personal lockers (MRPD)
	{
		coords = vec3(452.3, -991.4, 30.7),
		target = {
			loc = vec3(451.25, -994.28, 30.69),
			length = 1.2, width = 5.6, heading = 0,
			minZ = 29.49, maxZ = 32.09,
			label = 'Open personal locker'
		},
		name = 'policelocker',
		label = 'Personal locker',
		owner = true,
		slots = 70, weight = 70000,
		groups = shared.police
	},

	-- Police armory stash (MRPD)
	{
		coords = vec3(461.2, -996.8, 30.7),
		target = {
			loc = vec3(461.8, -998.0, 30.69),
			length = 1.6, width = 2.4, heading = 0,
			minZ = 29.49, maxZ = 31.49,
			label = 'Open armory'
		},
		name = 'pd_armory',
		label = 'PD Armory',
		slots = 100, weight = 200000,
		groups = shared.police
	},

	-- Evidence locker (MRPD)
	{
		coords = vec3(458.97, -982.79, 30.68),
		target = {
			name = 'mrpd_evidence',
			loc = vec3(459.07, -984.07, 30.69),
			length = 1.4, width = 3.2, heading = 0,
			minZ = 29.09, maxZ = 31.89,
			label = 'Open evidence locker'
		},
		name = 'mrpd_evidence',
		label = 'Evidence Locker',
		slots = 200, weight = 400000,
		groups = shared.police
	},

	-- EMS locker
	{
		coords = vec3(298.1, -587.2, 43.3),
		target = {
			loc = vec3(297.5, -586.5, 43.3),
			length = 1.0, width = 2.0, heading = 0,
			minZ = 43.3, maxZ = 44.1,
			label = 'Open EMS locker'
		},
		name = 'ems_locker',
		label = 'EMS Locker',
		owner = true,
		slots = 50, weight = 50000,
		groups = shared.ems
	},

	-- EMS armory stash
	{
		coords = vec3(296.5, -590.0, 43.3),
		target = {
			loc = vec3(297.0, -591.0, 43.3),
			length = 1.2, width = 2.0, heading = 0,
			minZ = 43.3, maxZ = 44.0,
			label = 'Open EMS armory'
		},
		name = 'ems_armory',
		label = 'EMS Armory',
		slots = 80, weight = 100000,
		groups = shared.ems
	},

	-- Jail property storage
	{
		coords = vec3(1698.9, 2564.5, 45.6),
		target = {
			loc = vec3(1698.5, 2565.0, 45.6),
			length = 0.8, width = 1.6, heading = 0,
			minZ = 45.6, maxZ = 46.2,
			label = 'Open property locker'
		},
		name = 'jail_property',
		label = 'Jail Property',
		slots = 40, weight = 30000,
	},

	-- Gang stash
	{
		coords = vec3(978.2, -102.0, 74.8),
		target = {
			loc = vec3(978.0, -101.5, 74.8),
			length = 0.8, width = 0.8, heading = 0,
			minZ = 74.8, maxZ = 75.2,
			label = 'Open gang stash'
		},
		name = 'gang_stash',
		label = 'Gang Stash',
		slots = 100, weight = 150000,
	},
}
