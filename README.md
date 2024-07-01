In the past I tried multiple key scripts from different creators and none of them convinced me, the only vehicle key script that I liked was qb-vehiclekeys, but we know that it has a series of bugs and poor client/server synchronization, besides that it lacks a function to use the keys as items in the inventory, so I decided to modify this script, add new functions and fix bugs.

I rewrote a large part of the code keeping most of the original qb-vehiclekeys exports and events, resulting in an alternative version that allows the use of physical keys (items) with metadata making it possible for each key to be unique for a certain vehicle.

Among other changes, my version of qb-vehiclekeys allows:

- Sending alerts when a player tries to steal a vehicle through the police dispatch and RCORE Dispatch.

- Lockpicking minigame was replaced by qb-minigames so the latter is a dependency of this script in order to work properly.

- A hacking minigame was added via qb-minigames when a player tries to wire a vehicle.

- An alternative item (carlock) was added as a lockpick, you can change the item to use as a lockpick when forcing the locks of vehicle doors in the config.

- Support for ox_Inventory and (OLD) qb-inventory to be able to use physical keys, that is, to be able to use this modified version you need one of these two inventory systems.

- A series of animations and key props were added.

## Dependencies

qb-minigames
ox_inventory / qb-inventory
origin police or rcore dispatch if you want your server's police to receive an alert every time a player tries to steal a vehicle.

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

ensure
