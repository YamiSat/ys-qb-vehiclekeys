-----------------------
----   Variables   ----
-----------------------
local QBCore = exports['qb-core']:GetCoreObject()

local state = {}
-----------------------
----   Threads     ----
-----------------------

-----------------------
---- Server Events ----
-----------------------

-- Event to give keys. receiver can either be a single id, or a table of ids.
-- Must already have keys to the vehicle, trigger the event from the server, or pass forcegive paramter as true.
RegisterNetEvent('qb-vehiclekeys:server:GiveVehicleKeys', function(receiver, plate)
    local giver = source

    if HasKeys(receiver, plate) then
        TriggerClientEvent('QBCore:Notify', giver, Lang:t("notify.haskey"), 'error')
    else
        if Config.Debug then print("^5Debug^7: ^3Creating key") end
        state[plate] = 1
        TriggerEvent('qb-vehiclekeys:server:CreateKeys', receiver, 1, plate)
        TriggerClientEvent('QBCore:Notify', receiver, Lang:t("notify.vgetkeys"), "success")
    end
end)

RegisterNetEvent('qb-vehiclekeys:server:AcquireVehicleKeys', function(plate)
    local src = source
    GiveKeys(src, plate)
end)

RegisterNetEvent('qb-vehiclekeys:server:breakLockpick', function(itemName)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then
        return
    end
    if not (itemName == Config.lockpick or itemName == "advancedlockpick") then
        return
    end
    if Player.Functions.RemoveItem(itemName, 1) then
        TriggerClientEvent("inventory:client:ItemBox", source, QBCore.Shared.Items[itemName], "remove")
    end
end)

RegisterNetEvent('qb-vehiclekeys:server:CreateKeys', function(receiver, howMany, veh)
    if Config.Debug then
        print("^5Debug^7: ^3creating key with metadata^7: " .. tostring(veh))
    end
    local description =  'PLATE NRO: ' .. veh
    local metadata = {
        description = '',
        plate = ' '
    }
    metadata.description = veh
    metadata.plate = veh
    AddMetadataItem(receiver, 'vehiclekeys', howMany, metadata)
end)

QBCore.Functions.CreateUseableItem("vehiclekeys", function(source, item)
    local Player = QBCore.Functions.GetPlayer(source)
    if Player.Functions.GetItemByName(item.name) then
        TriggerClientEvent('vehiclekeys:start', source)
    end
end)

QBCore.Functions.CreateUseableItem(Config.lockpick, function(source, item) 
    local Player = QBCore.Functions.GetPlayer(source)
    if Player.Functions.GetItemByName(item.name) then
        TriggerClientEvent('vehiclekeys:startlockpick', source)
    end
end)

QBCore.Functions.CreateCallback('vehiclekeys:Haskey', function(source, cb, plate)
    if Config.Debug then print("^5Debug^7: ^3Enter to callback ") end
    if Config.Debug then print("^5Debug^7: ^3plate to verify^7: " .. tostring(plate)) end
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local result = false

    if Player.PlayerData.items ~= nil and next(Player.PlayerData.items) ~= nil then
        for k, v in pairs(Player.PlayerData.items) do
            if Player.PlayerData.items[k] ~= nil then
                if Config.Debug then print("^5Debug^7: ^3CHECKING INVENTORY SLOT NRO ^7: " .. k) end
                if Player.PlayerData.items[k].name == "vehiclekeys" then
                    --   local x = Player.Functions.GetItemByName(Player.PlayerData.items[k].name) 
                    local x = Player.PlayerData.items[k]
                    local metadata = GetItemMetadata(x)
                    if Config.Debug then print("^5Debug^7: ^3The metadata in this key is PLATE^7: " .. tostring(metadata.plate)) end
                    if metadata.plate == plate then
                        if Config.Debug then print("^5Debug^7: ^3A key for the plate^7: " .. tostring(metadata.plate) .. ' has been found in the inventory') end
                        result = true
                    end
                end
            end
        end
    end -- return result
    cb(result)
end)


function GiveKeys(id, plate)
    local Player = QBCore.Functions.GetPlayer(id)
    if not Player then
        return
    end
    print('PLAYER ID' .. id)
-- print('entro a givekeys para crear llave' .. plate)
TriggerEvent('qb-vehiclekeys:server:GiveVehicleKeys', id, plate)
    if not plate then
        if GetVehiclePedIsIn(GetPlayerPed(id), false) ~= 0 then
            plate = QBCore.Shared.Trim(GetVehicleNumberPlateText(GetVehiclePedIsIn(GetPlayerPed(id), false)))
        else
            TriggerClientEvent('QBCore:Notify', id, Lang:t("notify.vgetkeys"))    
            if Config.Debug then  print('^5Debug^7: entro a givekeys para crear llave' .. plate) end
            TriggerEvent('qb-vehiclekeys:server:GiveVehicleKeys', id, plate)
        end
     end

end
exports('GiveKeys', GiveKeys)

QBCore.Functions.CreateCallback('vehiclekeys:state', function(source, cb, plate)
    if Config.Debug then print("^5Debug^7: ^3Enter to vehiclekeys:state ") end

    local result

    if state[plate] == 2 then
        result = 2
        if Config.Debug then print("^5Debug^7: ^3vehiclekeys:state: true = LOCKED") end
    elseif state[plate] == nil then 
        result = 3
        state[plate] = 2
        if Config.Debug then print("^5Debug^7: ^3vehiclekeys:state: nil = LOCKED") end
    else
        result = 1
     if Config.Debug then print("^5Debug^7: ^3vehiclekeys:state: false =  UNLOCKED ") end

    end
    cb(result)
end)


RegisterNetEvent('qb-vehiclekeys:server:setVehLockState', function(vehNetId, states, plate)
    SetVehicleDoorsLocked(NetworkGetEntityFromNetworkId(vehNetId), states)

 if state[plate] then  
    if states == 2 then
       state[plate] = 2

       if Config.Debug then print("^5Debug^7: ^3vehiclekeys:state: LOCKED ") end
     elseif states == 1 then
        state[plate] = 1
        if Config.Debug then print("^5Debug^7: ^3vehiclekeys:state: UNLOCKED ") end
     end
  else
 state[plate] = states
end
end)

RegisterNetEvent('qb-vehiclekeys:server:RemoveKeys', function(plate)
    RemoveKeys(source, plate)
end)



QBCore.Commands.Add("givekeys", Lang:t("addcom.givekeys"), {{
    name = Lang:t("addcom.givekeys_id"),
    help = Lang:t("addcom.givekeys_id_help")
}}, false, function(source, args)
    local src = source
    TriggerClientEvent('qb-vehiclekeys:client:GiveKeys', src, tonumber(args[1]))
end)

QBCore.Commands.Add("addkeys", Lang:t("addcom.addkeys"), {{
    name = Lang:t("addcom.addkeys_id"),
    help = Lang:t("addcom.addkeys_id_help")
}, {
    name = Lang:t("addcom.addkeys_plate"),
    help = Lang:t("addcom.addkeys_plate_help")
}}, true, function(source, args)
    local src = source
    if not args[1] or not args[2] then
        TriggerClientEvent('QBCore:Notify', src, Lang:t("notify.fpid"))
        return
    end
    GiveKeys(tonumber(args[1]), args[2])
end, 'admin')

QBCore.Commands.Add("removekeys", Lang:t("addcom.rkeys"), {{
    name = Lang:t("addcom.rkeys_id"),
    help = Lang:t("addcom.rkeys_id_help")
}, {
    name = Lang:t("addcom.rkeys_plate"),
    help = Lang:t("addcom.rkeys_plate_help")
}}, true, function(source, args)
  --  print('entro al comando')
    local src = source
    if not args[1] or not args[2] then
        TriggerClientEvent('QBCore:Notify', src, Lang:t("notify.fpid"))
        return
    end
    RemoveKeys(tonumber(args[1]), args[2])
end, 'admin')

