return {
	-- Drug processing
	{
		name = 'drug_processing',
		items = {
			{
				name = 'weed_bag',
				ingredients = {
					weed_leaf = 5,
				},
				duration = 5000,
				count = 1,
			},
			{
				name = 'coke_bag',
				ingredients = {
					coke_brick = 1,
				},
				duration = 10000,
				count = 10,
			},
			{
				name = 'meth_bag',
				ingredients = {
					metalscrap = 2,
					plastic = 1,
				},
				duration = 15000,
				count = 1,
			},
		},
		points = {
			vec3(1392.0, 3608.0, 35.0),
			vec3(89.0, 3700.0, 30.0),
		},
		zones = {
			{
				coords = vec3(1392.0, 3608.0, 35.0),
				size = vec3(2.0, 2.0, 1.0),
				distance = 1.5,
				rotation = 0,
			},
			{
				coords = vec3(89.0, 3700.0, 30.0),
				size = vec3(2.0, 2.0, 1.0),
				distance = 1.5,
				rotation = 0,
			},
		},
		blip = { id = 496, colour = 1, scale = 0.6 },
	},

	-- Scrap metal processing
	{
		name = 'scrap_processing',
		items = {
			{
				name = 'steel',
				ingredients = {
					metalscrap = 3,
				},
				duration = 8000,
				count = 1,
			},
			{
				name = 'copper',
				ingredients = {
					metalscrap = 2,
				},
				duration = 5000,
				count = 1,
			},
			{
				name = 'aluminum',
				ingredients = {
					metalscrap = 2,
				},
				duration = 6000,
				count = 1,
			},
		},
		points = {
			vec3(1074.0, -2001.0, 31.0),
		},
		zones = {
			{
				coords = vec3(1074.0, -2001.0, 31.0),
				size = vec3(3.0, 3.0, 1.0),
				distance = 1.5,
				rotation = 0,
			},
		},
		blip = { id = 566, colour = 5, scale = 0.7 },
	},

	-- Lockpick crafting
	{
		name = 'lockpick_crafting',
		items = {
			{
				name = 'lockpick',
				ingredients = {
					metalscrap = 2,
					plastic = 1,
				},
				duration = 10000,
				count = 1,
			},
			{
				name = 'hacker_device',
				ingredients = {
					copper = 3,
					plastic = 2,
					steel = 1,
				},
				duration = 30000,
				count = 1,
			},
		},
		points = {
			vec3(129.0, -1280.0, 29.3),
		},
		zones = {
			{
				coords = vec3(129.0, -1280.0, 29.3),
				size = vec3(1.5, 1.5, 1.0),
				distance = 1.5,
				rotation = 0,
			},
		},
		blip = { id = 566, colour = 1, scale = 0.6 },
	},
}
