local QBCore = exports['qb-core']:GetCoreObject()

policeAlert = function(coords)

    if Config.Dispatch  == "cd_dispatch" then
        local data = exports['cd_dispatch']:GetPlayerInfo()
        TriggerServerEvent('cd_dispatch:AddNotification', {
            job_table = { police, sheriff }, 
            coords = coords,
            title = 'Vehicle Robbery',
            message = 'A '..data.sex..' robbing a Vehicle at '..data.street, 
            flash = 0,
            unique_id = data.unique_id,
            sound = 1,
            blip = {
                sprite = 431, 
                scale = 1.2, 
                colour = 3,
                flashes = false, 
                text = '911 - Vehicle Robbery',
                time = 5,
                radius = 0,
            }
        })
    elseif Config.Dispatch == "qs-dispatch" then
        local playerData = exports['qs-dispatch']:GetPlayerInfo()
        TriggerServerEvent('qs-dispatch:server:CreateDispatchCall', {
            job = { police, sheriff },
            callLocation = coords,
            message = " street_1: ".. playerData.street_1.. " street_2: ".. playerData.street_2.. " sex: ".. playerData.sex,
            flashes = false,
            image = image or nil,
            blip = {
                sprite = 431,
                scale = 1.2,
                colour = 3,
                flashes = false,
                text = 'Vehicle Robbery',
                time = (20 * 1000),     --20 secs
            }
        })
    elseif Config.Dispatch == "ps-dispatch" then
        local dispatchData = {
            message = "Vehicle Robbery",
            codeName = 'vehicle',
            code = '10-90',
            icon = 'fas fa-store',
            priority = 2,
            coords = coords,
            gender = IsPedMale(cache.ped) and 'Male' or 'Female',
            street = "Vehicle",
            camId = nil,
            jobs = { police, sheriff },
        }
        TriggerServerEvent('ps-dispatch:server:notify', dispatchData)
    elseif Config.Dispatch  == "origen_police" then
        local data = {
            code = '10-64', 
            default_priority = 'high', 
            coords = coords, 
            job = { police, sheriff }, 
            text = 'Robo de Vehiculo', 
            type = 'car_robbery', 
            blip_time = 5, 
            blip = {
                sprite = 431, 
                colour = 3, 
                scale = 1.2, 
                text = 'Robo de tienda', 
                flashes = false, 
                radius = 0, 
            }
        }
        TriggerServerEvent("SendAlert:police", {
            coords = GetEntityCoords(PlayerPedId()), -- Coordinates vector3(x, y, z) in which the alert is triggered
            title = "10-96 Robo de Vehiculo", -- Title in the alert header
            type = "ROBERY", -- Alert type (GENERAL, RADARS, 215, DRUGS, FORCE, 48X) This is to filter the alerts in the dashboard
            message = "Una persona se encuentra tratando de robar un vehiculo ¡auxilio!", -- Alert message
        }) 
    end
end
