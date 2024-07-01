local QBCore = exports['qb-core']:GetCoreObject()

function rcore_dispatch()
    local vehicle = GetVehicleData() 
    local text =
        'Estan tratando de robar un vehiculo modelo %s pintado de color %s en mi posición. ¡Por favor, llamen a la policía!'
    text = string.format(text, vehicle.model, vehicle.color)
   print(vehicle.model)
    local data = {
        code = '10-64 - Car theft', -- string -> The alert code, can be for example '10-64' or a little bit longer sentence like '10-64 - Shop robbery'
        default_priority = 'low', -- 'low' | 'medium' | 'high' -> The alert priority
        coords = coords, -- vector3 -> The coords of the alert
        job = 'police', -- string | table -> The job, for example 'police' or a table {'police', 'ambulance'}
        text = text, -- string -> The alert text
        type = 'car_robbery', -- alerts | shop_robbery | car_robbery | bank_robbery -> The alert type to track stats
        blip_time = 5, -- number (optional) -> The time until the blip fades
        --    image = image.attachments[1].proxy_url,
        vehicle_colour =  vehicle.color,
        vehicle_plate = vehicle.plate,
        --     custom_sound = 'url_to_sound.mp3', -- string (optional) -> The url to the sound to play with the alert
        blip = { -- Blip table (optional)
            sprite = 225, -- number -> The blip sprite: Find them here (https://docs.fivem.net/docs/game-references/blips/#blips)
            colour = 3, -- number -> The blip colour: Find them here (https://docs.fivem.net/docs/game-references/blips/#blip-colors)
            scale = 0.7, -- number -> The blip scale
            text = 'Robo de vehiculo', -- number (optional) -> The blip text
            flashes = false, -- boolean (optional) -> Make the blip flash
            radius = 0 -- number (optional) -> Create a radius blip instead of a normal one
        }
    }
    TriggerServerEvent('rcore_dispatch:server:sendAlert', data)

end

function origen_police()
    local data = GetVehicleData() 
    TriggerServerEvent("SendAlert:police", {
        coords = data.coords,
        title = 'Robo de vehiculo',
        type = 'GENERAL',
        message = 'Estan tratando de robar un vehiculo',
        job = 'police',
        metadata = {
            model = data.model,
            color = {data.R, data.G , data.B},
            plate = data.plate,
            unit = 'ADAM-10'
        }
    })
end
