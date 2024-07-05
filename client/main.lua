-----------------------
----   Variables   ----
-----------------------
local QBCore = exports['qb-core']:GetCoreObject()

-----------------------
---- Client Events ----
-----------------------

RegisterKeyMapping('togglelocks', 'Coche: Abrir/Cerrar', 'keyboard', 'L')
RegisterCommand('togglelocks', function()
    local ped = PlayerPedId()
    local veh = GetVehicle()
    local plate = QBCore.Functions.GetPlate(veh)
    if IsPedInAnyVehicle(ped, false) then
        ToggleVehicleLockswithoutnui(GetVehicle())
    else
        if Config.UseKeyfob then
            if Config.Debug then
                print("^5Debug^7: ^3Key activated, Entering to ^7: ToggleVehicleLockswithoutnui")
            end
            ToggleVehicleLockswithoutnui(GetVehicle())
        else
            openmenu()
        end
    end
end)

RegisterNetEvent('vehiclekeys:start', function()
    local ped = PlayerPedId()
    local veh = GetVehicle()
    local plate = QBCore.Functions.GetPlate(veh)
    if IsPedInAnyVehicle(ped, false) then
        ToggleVehicleLockswithoutnui(GetVehicle())
    else
        if Config.UseKeyfob then
            if Config.Debug then
                print("^5Debug^7: ^3Key activated, Entering to ^7: ToggleVehicleLockswithoutnui")
            end
            ToggleVehicleLockswithoutnui(GetVehicle())
        else
            openmenu()
        end
    end
end)

-- RegisterKeyMapping('engine', Lang:t("info.engine"), 'keyboard', 'M')
-- RegisterCommand('engine', function()
--     local vehicle = GetVehicle()
--     if vehicle and IsPedInVehicle(PlayerPedId(), vehicle) then
--         ToggleEngine(vehicle)
--     end
-- end)

Citizen.CreateThread(function()
  while true do
     local playerPed = PlayerPedId()  
      SetPedConfigFlag(playerPed, 241, true) -- PED_FLAG_DISABLE_STOPPING_VEHICLE_ENGINE
      SetPedConfigFlag(playerPed, 429, true) -- PED_FLAG_DISABLE_STARTING_VEHICLE_ENGINE

    Citizen.Wait(1000)
  end
end)

RegisterCommand('engine', function()
  local vehicle = GetVehiclePedIsIn(playerPed)

  if not vehicle then
    return
  end

  if GetPedInVehicleSeat(vehicle, -1) ~= playerPed then
    return
  end

  if GetVehicleClass(vehicle) == 13 then
    return
  end
 if HasKeys(QBCore.Functions.GetPlate(vehicle)) then
    SetVehicleEngineOn(vehicle, not GetIsVehicleEngineRunning(vehicle), false, true)
else 
    return
end
end, false)

RegisterKeyMapping('engine', "Engine", 'keyboard', Config.engineKey)



-- AddEventHandler('onResourceStart', function(resourceName)
--     if resourceName == GetCurrentResourceName() and QBCore.Functions.GetPlayerData() ~= {} then
--         GetKeys()
--     end
-- end)

-- Handles state right when the player selects their character and location.
-- RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
--     GetKeys()
-- end)

RegisterNetEvent('qb-vehiclekeys:client:AddKeys', function(plate)
    if Config.Debug then
        print("^5Debug^7: ^3Entering to ^7: client:AddKeys")
    end
    
    local ped = PlayerPedId()
    if IsPedInAnyVehicle(ped, false) then
        local vehicle = GetVehiclePedIsIn(ped)
        local vehicleplate = QBCore.Functions.GetPlate(vehicle)
        if plate == vehicleplate then
            SetVehicleEngineOn(vehicle, false, false, false)
        end
    end
    if Config.Debug then
        print("^5Debug^7: ^3creating key for the plate^7: " .. plate)
    end
    TriggerServerEvent("qb-vehiclekeys:server:CreateKeys", ped, 1, plate)
end)

RegisterNetEvent('qb-vehiclekeys:client:RemoveKeys', function(plate)
 TriggerServerEvent('qb-vehiclekeys:server:RemoveKeys', plate)
end)
--[[
RegisterNetEvent('qb-vehiclekeys:client:ToggleEngine', function()
    local EngineOn = GetIsVehicleEngineRunning(GetVehiclePedIsIn(PlayerPedId()))
    local vehicle = GetVehiclePedIsIn(PlayerPedId(), true)
    if HasKeys(QBCore.Functions.GetPlate(vehicle)) then
        if EngineOn then
            SetVehicleEngineOn(vehicle, false, false, true)
        else
            SetVehicleEngineOn(vehicle, true, false, true)
        end
    end
end)
]]

RegisterNetEvent('qb-vehiclekeys:client:ShareKeys', ShareKeys)

RegisterNetEvent('qb-vehiclekeys:client:GiveKeys', function(id)
    if Config.Debug then
        print("^5Debug^7: ^3Entering to ^7: client:ShareKeys")
    end
    local targetVehicle = GetVehicle()
    if targetVehicle then
        local targetPlate = QBCore.Functions.GetPlate(targetVehicle)
        if HasKeys(targetPlate) then
            if id and type(id) == "number" then -- Give keys to specific ID
                GiveKeys(id, targetPlate)
            else
                if IsPedSittingInVehicle(PlayerPedId(), targetVehicle) then -- Give keys to everyone in vehicle
                    local otherOccupants = GetOtherPlayersInVehicle(targetVehicle)
                    for p = 1, #otherOccupants do
                        TriggerServerEvent('qb-vehiclekeys:server:GiveVehicleKeys',
                            GetPlayerServerId(NetworkGetPlayerIndexFromPed(otherOccupants[p])), targetPlate)
                    end
                else -- Give keys to closest player
                    GiveKeys(GetPlayerServerId(QBCore.Functions.GetClosestPlayer()), targetPlate)
                end
            end
        else
            QBCore.Functions.Notify(Lang:t("notify.ydhk"), 'error')
        end
    end
end)

RegisterNetEvent('QBCore:Client:EnteringVehicle', function()
    robKeyLoop()
end)

RegisterNetEvent('weapons:client:DrawWeapon', function()
    Wait(2000)
    robKeyLoop()
end)

RegisterNetEvent('vehiclekeys:startlockpick', function()
    local ped = PlayerPedId()
    local entering = GetVehiclePedIsTryingToEnter(ped)
    local coords = GetEntityCoords(ped)
    local closestVehicle, distance = QBCore.Functions.GetClosestVehicle(coords)
    if DoesEntityExist(closestVehicle) then
        if not IsPedInAnyVehicle(Ped, false) then
            if GetVehicleDoorLockStatus(closestVehicle) ~= 1 then
                inLockpickAnim(true)
                local success = exports['qb-minigames']:Lockpick(3) -- number of tries
                if success then
                    print('success')
                 --   SetVehicleDoorsLockedForAllPlayers(closestVehicle, false)
                  TriggerServerEvent('qb-vehiclekeys:server:setVehLockState', NetworkGetNetworkIdFromEntity(closestVehicle), 1, QBCore.Functions.GetPlate(closestVehicle))
                    TriggerServerEvent('qb-vehiclekeys:server:breakLockpick', Config.lockpick)
                else
                    TriggerServerEvent('qb-vehiclekeys:server:breakLockpick', Config.lockpick)
                    print('fail')
                end
            else
                inLockpickAnim(false)
            end
        end
    end
      policeAlert(GetEntityCoords(ped))
    ClearPedTasks(GetPlayerPed(-1))
end)

-- Backwards Compatibility ONLY -- Remove at some point --
RegisterNetEvent('vehiclekeys:client:SetOwner', function(plate)
    TriggerServerEvent('qb-vehiclekeys:server:AcquireVehicleKeys', plate)
end)
-- Backwards Compatibility ONLY -- Remove at some point --


-- If in vehicle returns that, otherwise tries 3 different raycasts to get the vehicle they are facing.
-- Raycasts picture: https://i.imgur.com/FRED0kV.png

-----------------------
----   NUICallback   ----
-----------------------
RegisterNUICallback('closui', function()
    SetNuiFocus(false, false)
end)

RegisterNUICallback('unlock', function()
    ToggleVehicleunLocks(GetVehicle())
    SetNuiFocus(false, false)
end)

RegisterNUICallback('lock', function()
    ToggleVehicleLocks(GetVehicle())
    SetNuiFocus(false, false)
end)

RegisterNUICallback('trunk', function()
    ToggleVehicleTrunk(GetVehicle())
    SetNuiFocus(false, false)
end)

RegisterNUICallback('engine', function()
    ToggleEngine(GetVehicle())
    SetNuiFocus(false, false)
end)
