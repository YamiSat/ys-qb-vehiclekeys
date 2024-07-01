## Dependencies
QBcore
ox_inventory or qb-inventory (old)
qb-minigames

# How to install
Add the following line to your QBCore > Shared > Items.lua:

    vehiclekeys             = { name = 'vehiclekeys', label = 'Key', weight = 50, type = 'item', image = 'vehiclekeys.png', unique = true, useable = true, shouldClose = false, combinable = nil, description = '' },

    carlock             = { name = 'carlock', label = 'carlock', weight = 50, type = 'item', image = 'carlock.png', unique = false, useable = true, shouldClose = false, combinable = nil, description = '' },

if you have ox_inventory add the following line to ox_inventory > data > items.lua

	["vehiclekeys"] = {
		label = "Llave",
		weight = 50,
		stack = false,
		close = true,
		description = "Llave de vehiculo",
		client = {
		image = "vehiclekeys.png",
		}
	},

	["carlock"] = {
		label = "Ganzua",
		weight = 50,
		stack = false,
		close = true,
		description = "Ganzua especial para vehiculos",
		client = {
		image = "carlock.png",
		}
	},

ensure ys-qb-vehiclekeys



