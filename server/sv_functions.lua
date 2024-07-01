local QBCore = exports['qb-core']:GetCoreObject()

-----------------------
-- Metada Functions  --
-----------------------
function GetItemMetadata(item)
    return item.info ~= nil and item.info or item.metadata ~= nil and item.metadata or {}
end

function AddMetadataItem(source, item, amount, metadata)
    local xPlayer = QBCore.Functions.GetPlayer(source)
    if Config.Inventory == 'ox' then
        exports.ox_inventory:AddItem(source, item, amount, metadata)
    elseif Config.Inventory == 'qb' then
        exports['qb-inventory']:AddItem(source, item, amount, nil, metadata)
        TriggerClientEvent('inventory:client:ItemBox', source, QBCore.Shared.Items['vehiclekeys'], "add")
    end
end
-----------------------
----   Functions   ----
-----------------------

function RemoveKeys(id, plate)
    if Config.Debug then print("^5Debug^7: ^3Enter to REMOVEKEYS EXPORTS, plate to verify^7: " .. tostring(plate)) end
    local Player = QBCore.Functions.GetPlayer(id)
    if Player.PlayerData.items ~= nil and next(Player.PlayerData.items) ~= nil then
        for k, v in pairs(Player.PlayerData.items) do
            if Player.PlayerData.items[k] ~= nil then
                if Config.Debug then print("^5Debug^7: ^3CHECKING INVENTORY SLOT NRO ^7: " .. k) end
                if Player.PlayerData.items[k].name == "vehiclekeys" then
                    local x = Player.PlayerData.items[k]
                    local metadata = GetItemMetadata(x)
                    if Config.Debug then print("^5Debug^7: ^3The metadata in this key is PLATE^7: " .. tostring(metadata.plate)) end
                    if metadata.plate == plate then
                     if Config.Debug then print("^5Debug^7: ^3A key for the plate^7: " .. tostring(metadata.plate) .. 'has been found in the inventory') end
                        Player.Functions.RemoveItem(x, 1, k)
                    end
                end
            end
        end          
    end
end
exports('RemoveKeys', RemoveKeys)



-- debo cambiar esta funcion
function HasKeys(id, plate)
    if Config.Debug then print("^5Debug^7: ^3Enter to HASKEYS EXPORTS, plate to verify^7: " .. tostring(plate)) end
   -- local src = source
    local Player = QBCore.Functions.GetPlayer(id)
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
                        if Config.Debug then print("^5Debug^7: ^3A key for the plate^7: " .. tostring(metadata.plate) .. ' has been found in the inventory '..' SLOT '..k) end
                        return true
                    end
                else
                    if Config.Debug then print("^5Debug^7: ^3There is NO key with plate^7: " .. tostring(plate)..' SLOT '..k) end
                    result = false
                end
            end
        end
    end -- return result
    return result
end
exports('HasKeys', HasKeys)

QBCore.Functions.CreateCallback('qb-vehiclekeys:server:checkPlayerOwned', function(_, cb, plate)
    if Config.Debug then print("^5Debug^7: ^3ENTER TO checkPlayerOwned CALLBACK^7 ") end
    local playerOwned = false
    if HasKeys(_, plate) then
        playerOwned = true
        if Config.Debug then print("^5Debug^7: ^3checkPlayerOwned CALLBACK DETECTED A KEY^7 ") end
    else
        if Config.Debug then print("^5Debug^7: ^3checkPlayerOwned CALLBACK has not detected a key^7 ") end
        playerOwned = false
    end
    cb(playerOwned)
end)