-----------------------
----   Functions   ----
-----------------------
local QBCore = exports['qb-core']:GetCoreObject()

local isTakingKeys = false
local isCarjacking = false
local canCarjack = true
local AlertSend = false
local lastPickedVehicle = nil
local usingAdvanced = false
local IsHotwiring = false
local trunkclose = true
local looped = false
local open = false

function robKeyLoop()

    if looped == false then
        looped = true

        while true do
            local sleep = 1000
            if LocalPlayer.state.isLoggedIn then
                sleep = 100

                local ped = PlayerPedId()
                local entering = GetVehiclePedIsTryingToEnter(ped)
                local carIsImmune = false
                if entering ~= 0 and not isBlacklistedVehicle(entering) then
                    sleep = 2000
                    local plate = QBCore.Functions.GetPlate(entering)

                    local driver = GetPedInVehicleSeat(entering, -1)
                    for _, veh in ipairs(Config.ImmuneVehicles) do
                        if GetEntityModel(entering) == joaat(veh) then
                            carIsImmune = true
                        end
                    end
                    -- Driven vehicle logic logica del robo de npc
                    if driver ~= 0 and not IsPedAPlayer(driver) and not HasKeys(plate) and not carIsImmune and not open then
                        if IsEntityDead(driver) then
                            if not isTakingKeys then
                                isTakingKeys = true

                                TriggerServerEvent('qb-vehiclekeys:server:setVehLockState',
                                    NetworkGetNetworkIdFromEntity(entering), 1, QBCore.Functions.GetPlate(veh))
                                QBCore.Functions.Progressbar("steal_keys", Lang:t("progress.takekeys"), 2500, false,
                                    false, {
                                        disableMovement = false,
                                        disableCarMovement = true,
                                        disableMouse = false,
                                        disableCombat = true
                                    }, {}, {}, {}, function() -- Done
                                        TriggerServerEvent('qb-vehiclekeys:server:AcquireVehicleKeys', plate)
                                        isTakingKeys = false
                                    end, function()
                                        isTakingKeys = false
                                    end)
                            end
                        elseif Config.LockNPCDrivingCars then
                            TriggerServerEvent('qb-vehiclekeys:server:setVehLockState',
                                NetworkGetNetworkIdFromEntity(entering), 2, QBCore.Functions.GetPlate(veh))
                        else
                            TriggerServerEvent('qb-vehiclekeys:server:setVehLockState',
                                NetworkGetNetworkIdFromEntity(entering), 1, QBCore.Functions.GetPlate(veh))
                            TriggerServerEvent('qb-vehiclekeys:server:AcquireVehicleKeys', plate)

                            -- Make passengers flee
                            local pedsInVehicle = GetPedsInVehicle(entering)
                            for _, pedInVehicle in pairs(pedsInVehicle) do
                                if pedInVehicle ~= GetPedInVehicleSeat(entering, -1) then
                                    MakePedFlee(pedInVehicle)
                                end
                            end
                        end
                        -- Parked car logic
                    -- elseif driver == 0 and state(plate) and HasKeys(plate)  then -- elseif driver == 0 and entering ~= lastPickedVehicle and not HasKeys(plate) and not isTakingKeys then
                    --     if Config.Debug then print("^5Debug^7: ^3CHECKING PLAYER OWNED ") end
                        -- QBCore.Functions.TriggerCallback('qb-vehiclekeys:server:checkPlayerOwned',
                        --     function(playerOwned)
                        --         if not playerOwned then
                        --             if Config.LockNPCParkedCars then
                        --                 TriggerServerEvent('qb-vehiclekeys:server:setVehLockState',
                        --                     NetworkGetNetworkIdFromEntity(entering), 2, QBCore.Functions.GetPlate(veh))
                        --             else
                        --                 TriggerServerEvent('qb-vehiclekeys:server:setVehLockState',
                        --                     NetworkGetNetworkIdFromEntity(entering), 1, QBCore.Functions.GetPlate(veh))
                        --             end
                        --         end
                        --     end, plate)
                                        --   TriggerServerEvent('qb-vehiclekeys:server:setVehLockState',
                                        --   NetworkGetNetworkIdFromEntity(entering), 1, QBCore.Functions.GetPlate(veh))
                    elseif driver == 0 and not HasKeys(plate) and not isTakingKeys then
                        local result = state(plate)
                       if result == 2 then    
                                       TriggerServerEvent('qb-vehiclekeys:server:setVehLockState',
                                       NetworkGetNetworkIdFromEntity(entering), 2, QBCore.Functions.GetPlate(veh))
                       elseif result == 1 then   
                        TriggerServerEvent('qb-vehiclekeys:server:setVehLockState',
                        NetworkGetNetworkIdFromEntity(entering), 1, QBCore.Functions.GetPlate(veh))
                       elseif result == 3 then   
                            TriggerServerEvent('qb-vehiclekeys:server:setVehLockState',
                            NetworkGetNetworkIdFromEntity(entering), 2, QBCore.Functions.GetPlate(veh))
                        end
                    end
                end
                -- Hotwiring while in vehicle, also keeps engine off for vehicles you don't own keys to
                if IsPedInAnyVehicle(ped, false) and not IsHotwiring then
                    local vehicle = GetVehiclePedIsIn(ped)
                    local plate = QBCore.Functions.GetPlate(vehicle)

                    if GetPedInVehicleSeat(vehicle, -1) == PlayerPedId() then
                        if not HasKeys(plate) and not isBlacklistedVehicle(vehicle) then
                            local vehiclePos = GetOffsetFromEntityInWorldCoords(vehicle, 0.0, 1.0, 0.5)
                            SetVehicleEngineOn(vehicle, false, false, true)

                          --  if HotwiringCooldown == 0 then
                            --    DrawText3D(vehiclePos.x, vehiclePos.y, vehiclePos.z, Lang:t("info.skeys"))
                                if IsControlJustPressed(0, 74) then
                                    Hotwire(vehicle, plate)
                                end
                         --   end
                        end
                    end
                end

                if Config.CarJackEnable and canCarjack then
                    local playerid = PlayerId()
                    local aiming, target = GetEntityPlayerIsFreeAimingAt(playerid)
                    if aiming and (target ~= nil and target ~= 0) then
                        if DoesEntityExist(target) and IsPedInAnyVehicle(target, false) and not IsEntityDead(target) and
                            not IsPedAPlayer(target) then
                            local targetveh = GetVehiclePedIsIn(target)
                            for _, veh in ipairs(Config.ImmuneVehicles) do
                                if GetEntityModel(targetveh) == joaat(veh) then
                                    carIsImmune = true
                                end
                            end
                            if GetPedInVehicleSeat(targetveh, -1) == target and not IsBlacklistedWeapon() then
                                local pos = GetEntityCoords(ped, true)
                                local targetpos = GetEntityCoords(target, true)
                                if #(pos - targetpos) < 5.0 and not carIsImmune then
                                    CarjackVehicle(target)
                                end
                            end
                        end
                    end
                end
                if entering == 0 and not IsPedInAnyVehicle(ped, false) and GetSelectedPedWeapon(ped) ==
                    joaat('WEAPON_UNARMED') then
                    looped = false
                    break
                end
            end
            Wait(sleep)
        end
    end
end

function isBlacklistedVehicle(vehicle)
    local isBlacklisted = false
    for _, v in ipairs(Config.NoLockVehicles) do
        if joaat(v) == GetEntityModel(vehicle) then
            isBlacklisted = true
            break
        end
    end
    if GetVehicleClass(vehicle) == 13 then
        isBlacklisted = true
    end
    return isBlacklisted
end

function addNoLockVehicles(model)
    Config.NoLockVehicles[#Config.NoLockVehicles + 1] = model
end
exports('addNoLockVehicles', addNoLockVehicles)

function removeNoLockVehicles(model)
    for k, v in pairs(Config.NoLockVehicles) do
        if v == model then
            Config.NoLockVehicles[k] = nil
        end
    end
end
exports('removeNoLockVehicles', removeNoLockVehicles)

function ShareKeys()
    local Inputs = exports['qb-input']:ShowInput({
        header = 'Dar una copia de la llave del vehículo',
        submitText = "Dar Copia",
        inputs = {{
            text = "Id del jugador",
            name = "playerid",
            type = "number",
            isRequired = true
        }}
    })
    if Inputs then
        if not Inputs.playerid then
            return
        end
        ExecuteCommand('givekeys ' .. tonumber(Inputs.playerid))
    end
end

HotwiringCooldown = 0
function startHotwiringCooldown()
    HotwiringCooldown = Config.TimeBetweenHotwires
    SetTimeout(Config.TimeBetweenHotwires, function()
        HotwiringCooldown = 0
    end)
end

function GetVehicle()
    local ped = PlayerPedId()
    local vehicle = GetVehiclePedIsIn(ped)
    local pos = GetEntityCoords(ped)

    if vehicle == 0 then
        vehicle = QBCore.Functions.GetClosestVehicle()
        if #(pos - GetEntityCoords(vehicle)) > 6 then
            QBCore.Functions.Notify(Lang:t("notify.vehclose"), "error")
            return
        end
    end

    if not IsEntityAVehicle(vehicle) then
        vehicle = nil
    end
    return vehicle
end

function ToggleVehicleLocks(veh)
    if Config.Debug then print("^5Debug^7: ^3Entering to^7 "..'client function ToggleVehicleLocks') end
    if veh then
        if not isBlacklistedVehicle(veh) then
            if Config.Debug then print("^5Debug^7: ^3Checking if the player has the key^7") end
            if HasKeys(QBCore.Functions.GetPlate(veh)) then
                local ped = PlayerPedId()
                local vehLockStatus = GetVehicleDoorLockStatus(veh)
                local PedCoords = GetEntityCoords(GetPlayerPed(-1))
                local keyspawn =  CreateObject(GetHashKey('sf_prop_sf_car_keys_01a'),PedCoords.x, PedCoords.y,PedCoords.z, true, true, true)
                AttachEntityToEntity(keyspawn, GetPlayerPed(-1), GetPedBoneIndex(GetPlayerPed(-1), 28422),-0.005,0.0,0.0,360.0,360.0,0.0,1,1,0,1,0,1)
                loadAnimDict("anim@mp_player_intmenu@key_fob@")
                TaskPlayAnim(ped, 'anim@mp_player_intmenu@key_fob@', 'fob_click', 3.0, 3.0, -1, 49, 0, false, false,
                    false)
                TriggerServerEvent("InteractSound_SV:PlayWithinDistance", 5, "lock", 0.3)
                Wait(1000)
                DeleteEntity(keyspawn)
                ClearPedTasks(GetPlayerPed(-1))
                NetworkRequestControlOfEntity(veh)
                while NetworkGetEntityOwner(veh) ~= 128 do
                    NetworkRequestControlOfEntity(veh)
                    Wait(0)
                end
                if vehLockStatus == 1 then
                    TriggerServerEvent('qb-vehiclekeys:server:setVehLockState', NetworkGetNetworkIdFromEntity(veh), 2, QBCore.Functions.GetPlate(veh))
                    QBCore.Functions.Notify(Lang:t("notify.vlock"), "success")
                end
                SetVehicleLights(veh, 2)
                Wait(250)
                SetVehicleLights(veh, 1)
                Wait(200)
                SetVehicleLights(veh, 0)
                Wait(300)
                ClearPedTasks(ped)
            else
                QBCore.Functions.Notify(Lang:t("notify.ydhk"), 'error')
            end
        else
            TriggerServerEvent('qb-vehiclekeys:server:setVehLockState', NetworkGetNetworkIdFromEntity(veh), 1, QBCore.Functions.GetPlate(veh))
        end
    end
end

function ToggleVehicleunLocks(veh)
    print('togglevehicleunlocks')
    if veh then
        if not isBlacklistedVehicle(veh) then
            if HasKeys(QBCore.Functions.GetPlate(veh)) then
                local ped = PlayerPedId()
                local vehLockStatus = GetVehicleDoorLockStatus(veh)
                local ped = PlayerPedId()
                local vehLockStatus = GetVehicleDoorLockStatus(veh)
                local PedCoords = GetEntityCoords(GetPlayerPed(-1))
                local keyspawn =  CreateObject(GetHashKey('sf_prop_sf_car_keys_01a'),PedCoords.x, PedCoords.y,PedCoords.z, true, true, true)
                AttachEntityToEntity(keyspawn, GetPlayerPed(-1), GetPedBoneIndex(GetPlayerPed(-1), 28422),-0.005,0.0,0.0,360.0,360.0,0.0,1,1,0,1,0,1)
                loadAnimDict("anim@mp_player_intmenu@key_fob@")
                TaskPlayAnim(ped, 'anim@mp_player_intmenu@key_fob@', 'fob_click', 3.0, 3.0, -1, 49, 0, false, false,
                    false)
                TriggerServerEvent("InteractSound_SV:PlayWithinDistance", 5, "lock", 0.3)
                Wait(1000)
                ClearPedTasks(GetPlayerPed(-1))
                NetworkRequestControlOfEntity(veh)
                DeleteEntity(keyspawn)
                TriggerServerEvent("InteractSound_SV:PlayWithinDistance", 5, "lock", 0.3)
                NetworkRequestControlOfEntity(veh)
                if vehLockStatus == 2 then
                    TriggerServerEvent('qb-vehiclekeys:server:setVehLockState', NetworkGetNetworkIdFromEntity(veh), 1, QBCore.Functions.GetPlate(veh))
                    QBCore.Functions.Notify(Lang:t("notify.vunlock"), "success")
                end
                SetVehicleLights(veh, 2)
                Wait(250)
                SetVehicleLights(veh, 1)
                Wait(200)
                SetVehicleLights(veh, 0)
                Wait(300)
                ClearPedTasks(ped)
            else
                QBCore.Functions.Notify(Lang:t("notify.ydhk"), 'error')
            end
        else
            TriggerServerEvent('qb-vehiclekeys:server:setVehLockState', NetworkGetNetworkIdFromEntity(veh), 1, QBCore.Functions.GetPlate(veh))
        end
    end
end
function ToggleVehicleTrunk(veh)
    if veh then
        if not isBlacklistedVehicle(veh) then
            if HasKeys(QBCore.Functions.GetPlate(veh)) then
                local ped = PlayerPedId()
                local boot = GetEntityBoneIndexByName(GetVehiclePedIsIn(PlayerPedId(), false), 'boot')
                local PedCoords = GetEntityCoords(GetPlayerPed(-1))
                local keyspawn =  CreateObject(GetHashKey('sf_prop_sf_car_keys_01a'),PedCoords.x, PedCoords.y,PedCoords.z, true, true, true)
                AttachEntityToEntity(keyspawn, GetPlayerPed(-1), GetPedBoneIndex(GetPlayerPed(-1), 28422),-0.005,0.0,0.0,360.0,360.0,0.0,1,1,0,1,0,1)
                loadAnimDict("anim@mp_player_intmenu@key_fob@")
                TaskPlayAnim(ped, 'anim@mp_player_intmenu@key_fob@', 'fob_click', 3.0, 3.0, -1, 49, 0, false, false,
                    false)
                    Wait(1000)
                    DeleteEntity(keyspawn)
                    ClearPedTasks(GetPlayerPed(-1))
                --    ClearPedTasks(GetPlayerPed(-1))
                TriggerServerEvent("InteractSound_SV:PlayWithinDistance", 5, "lock", 0.3)
      
                NetworkRequestControlOfEntity(veh)
                if boot ~= -1 or DoesEntityExist(veh) then
                    if trunkclose == true then
                        SetVehicleLights(veh, 2)
                        Wait(150)
                        SetVehicleLights(veh, 0)
                        Wait(150)
                        SetVehicleLights(veh, 2)
                        Wait(150)
                        SetVehicleLights(veh, 0)
                        Wait(150)
                        SetVehicleDoorOpen(veh, 5)
                        trunkclose = false
                        ClearPedTasks(ped)
                    else
                        SetVehicleLights(veh, 2)
                        Wait(150)
                        SetVehicleLights(veh, 0)
                        Wait(150)
                        SetVehicleLights(veh, 2)
                        Wait(150)
                        SetVehicleLights(veh, 0)
                        Wait(150)
                        SetVehicleDoorShut(veh, 5)
                        trunkclose = true
                        ClearPedTasks(ped)
                    end
                end
            else
                QBCore.Functions.Notify(Lang:t("notify.ydhk"), 'error')
            end
        else
            TriggerServerEvent('qb-vehiclekeys:server:setVehLockState', NetworkGetNetworkIdFromEntity(veh), 1, QBCore.Functions.GetPlate(veh))
        end
    end
end


function openmenu()
    TriggerServerEvent("InteractSound_SV:PlayWithinDistance", 0.5, "key", 0.3)
    SendNUIMessage({
        casemenue = 'open'
    })
    SetNuiFocus(true, true)
end
local NotifyCooldown = false
function ToggleEngine(veh)
    print('toggle engine')
    if veh then
        local EngineOn = GetIsVehicleEngineRunning(veh)
        if not isBlacklistedVehicle(veh) then
            if HasKeys(QBCore.Functions.GetPlate(veh))  then
                local ped = PlayerPedId()
                local vehLockStatus = GetVehicleDoorLockStatus(veh)
                local PedCoords = GetEntityCoords(GetPlayerPed(-1))
                local keyspawn =  CreateObject(GetHashKey('sf_prop_sf_car_keys_01a'),PedCoords.x, PedCoords.y,PedCoords.z, true, true, true)
                AttachEntityToEntity(keyspawn, GetPlayerPed(-1), GetPedBoneIndex(GetPlayerPed(-1), 28422),-0.005,0.0,0.0,360.0,360.0,0.0,1,1,0,1,0,1)
                loadAnimDict("anim@mp_player_intmenu@key_fob@")
                TaskPlayAnim(ped, 'anim@mp_player_intmenu@key_fob@', 'fob_click', 3.0, 3.0, -1, 49, 0, false, false,
                    false)
                TriggerServerEvent("InteractSound_SV:PlayWithinDistance", 5, "lock", 0.3)
                Wait(1000)
                DeleteEntity(keyspawn)
                ClearPedTasks(GetPlayerPed(-1))
                if EngineOn then
                    SetVehicleEngineOn(veh, false, false, false)
                else
                    if exports['cdn-fuel']:GetFuel(veh) ~= 0 then
                        SetVehicleEngineOn(veh, true, true, false)
                    else
                        if not NotifyCooldown then
                            RequestAmbientAudioBank("DLC_PILOT_ENGINE_FAILURE_SOUNDS", 0)
                            PlaySoundFromEntity(l_2613, "Landing_Tone", PlayerPedId(),
                                "DLC_PILOT_ENGINE_FAILURE_SOUNDS", 0, 0)
                            NotifyCooldown = true
                            QBCore.Functions.Notify('Sin combustible..', 'cencel')
                            Wait(1500)
                            StopSound(l_2613)
                            Wait(3500)
                            NotifyCooldown = false
                        end
                    end
                end
            end
        end
    end

end

function ToggleVehicleLockswithoutnui(veh)
    if veh then
        if not isBlacklistedVehicle(veh) then
            if Config.Debug then print("^5Debug^7: ^3Checking if the player has the key^7") end
            if HasKeys(QBCore.Functions.GetPlate(veh)) then
                local ped = PlayerPedId()
                local vehLockStatus = GetVehicleDoorLockStatus(veh)
                local PedCoords = GetEntityCoords(GetPlayerPed(-1))
                local keyspawn =  CreateObject(GetHashKey('sf_prop_sf_car_keys_01a'),PedCoords.x, PedCoords.y,PedCoords.z, true, true, true)
                AttachEntityToEntity(keyspawn, GetPlayerPed(-1), GetPedBoneIndex(GetPlayerPed(-1), 28422),-0.005,0.0,0.0,360.0,360.0,0.0,1,1,0,1,0,1)
                loadAnimDict("anim@mp_player_intmenu@key_fob@")
                TaskPlayAnim(ped, 'anim@mp_player_intmenu@key_fob@', 'fob_click', 3.0, 3.0, -1, 49, 0, false, false,
                    false)
                TriggerServerEvent("InteractSound_SV:PlayWithinDistance", 5, "lock", 0.3)
                Wait(1000)
                DeleteEntity(keyspawn)
                ClearPedTasks(GetPlayerPed(-1))
                NetworkRequestControlOfEntity(veh)
                if vehLockStatus == 1 then
                    TriggerServerEvent('qb-vehiclekeys:server:setVehLockState', NetworkGetNetworkIdFromEntity(veh), 2, QBCore.Functions.GetPlate(veh))
                    QBCore.Functions.Notify(Lang:t("notify.vlock"), "success")
                else
                    TriggerServerEvent('qb-vehiclekeys:server:setVehLockState', NetworkGetNetworkIdFromEntity(veh), 1, QBCore.Functions.GetPlate(veh))
                    QBCore.Functions.Notify(Lang:t("notify.vunlock"), "success")
                end

                SetVehicleLights(veh, 2)
                Wait(250)
                SetVehicleLights(veh, 1)
                Wait(200)
                SetVehicleLights(veh, 0)
                Wait(300)
                ClearPedTasks(ped)
            else
                QBCore.Functions.Notify(Lang:t("notify.ydhk"), 'error')
            end
        else
            TriggerServerEvent('qb-vehiclekeys:server:setVehLockState', NetworkGetNetworkIdFromEntity(veh), 1, QBCore.Functions.GetPlate(veh))
        end
    end
end



function GetOtherPlayersInVehicle(vehicle)
    local otherPeds = {}
    for seat = -1, GetVehicleModelNumberOfSeats(GetEntityModel(vehicle)) - 2 do
        local pedInSeat = GetPedInVehicleSeat(vehicle, seat)
        if IsPedAPlayer(pedInSeat) and pedInSeat ~= PlayerPedId() then
            otherPeds[#otherPeds + 1] = pedInSeat
        end
    end
    return otherPeds
end

function GetPedsInVehicle(vehicle)
    local otherPeds = {}
    for seat = -1, GetVehicleModelNumberOfSeats(GetEntityModel(vehicle)) - 2 do
        local pedInSeat = GetPedInVehicleSeat(vehicle, seat)
        if not IsPedAPlayer(pedInSeat) and pedInSeat ~= 0 then
            otherPeds[#otherPeds + 1] = pedInSeat
        end
    end
    return otherPeds
end

function IsBlacklistedWeapon()
    local weapon = GetSelectedPedWeapon(PlayerPedId())
    if weapon ~= nil then
        for _, v in pairs(Config.NoCarjackWeapons) do
            if weapon == joaat(v) then
                return true
            end
        end
    end
    return false
end

function LockpickDoor(isAdvanced)
    print('lockpickdoor')
    local ped = PlayerPedId()
    local pos = GetEntityCoords(ped)
    local vehicle = QBCore.Functions.GetClosestVehicle()

    if vehicle == nil or vehicle == 0 then
        return
    end
    if HasKeys(QBCore.Functions.GetPlate(vehicle)) then
        return
    end
    if #(pos - GetEntityCoords(vehicle)) > 2.5 then
        return
    end
    if GetVehicleDoorLockStatus(vehicle) <= 0 then
        return
    end

    usingAdvanced = isAdvanced
    Config.LockPickDoorEvent()
end

function LockpickFinishCallback(success)
    local vehicle = QBCore.Functions.GetClosestVehicle()

    local chance = math.random()
    if success then
        TriggerServerEvent('hud:server:GainStress', math.random(1, 4))
        lastPickedVehicle = vehicle

        if GetPedInVehicleSeat(vehicle, -1) == PlayerPedId() then
            TriggerServerEvent('qb-vehiclekeys:server:AcquireVehicleKeys', QBCore.Functions.GetPlate(vehicle))
        else
            QBCore.Functions.Notify(Lang:t("notify.vlockpick"), 'success')
            TriggerServerEvent('qb-vehiclekeys:server:setVehLockState', NetworkGetNetworkIdFromEntity(vehicle), 1, QBCore.Functions.GetPlate(veh))
        end

    else
        TriggerServerEvent('hud:server:GainStress', math.random(1, 4))
        AttemptPoliceAlert("steal", GetEntityCoords(PlayerPedId())
    end

    if usingAdvanced then
        if chance <= Config.RemoveLockpickAdvanced then
            TriggerServerEvent("qb-vehiclekeys:server:breakLockpick", "advancedlockpick")
        end
    else
        if chance <= Config.RemoveLockpickNormal then
            TriggerServerEvent("qb-vehiclekeys:server:breakLockpick", "lockpick")
        end
    end
end

inLockpickAnim = function(toggle)
    local playerPed = PlayerPedId()
    ClearPedTasks(playerPed)
    ClearPedSecondaryTask(playerPed)
    if toggle ~= nil then
        if not toggle then
            ClearPedTasks(playerPed)
            ClearPedSecondaryTask(playerPed)
        else
            loadAnimDict('veh@break_in@0h@p_m_one@')
            if not IsEntityPlayingAnim(playerPed, "veh@break_in@0h@p_m_one@", "low_force_entry_ds", 3) then
                TaskPlayAnim(playerPed, "veh@break_in@0h@p_m_one@", "low_force_entry_ds", 1.0, 1.0, 1.0, 25, 0.0, 0, 0, 0)
            end
        end
    end
end

inHotwireAnim = function(toggle)
    local playerPed = PlayerPedId()
    ClearPedTasks(playerPed)
    ClearPedSecondaryTask(playerPed)
    if toggle ~= nil then
        if not toggle then
            ClearPedTasks(playerPed)
            ClearPedSecondaryTask(playerPed)
        else
            loadAnimDict('anim@amb@clubhouse@tutorial@bkr_tut_ig3@')
            if not IsEntityPlayingAnim(playerPed, "anim@amb@clubhouse@tutorial@bkr_tut_ig3@", "machinic_loop_mechandplayer", 3) then
                TaskPlayAnim(playerPed, "anim@amb@clubhouse@tutorial@bkr_tut_ig3@", "machinic_loop_mechandplayer", 1.0, 1.0, 1.0, 16, 0.0, 0, 0, 0)
            end
        end
    end
end

function Hotwire(vehicle, plate)
    local ped = PlayerPedId()
    IsHotwiring = true

    inHotwireAnim(true)

    local success = exports['qb-minigames']:Hacking(5, 30) -- code block size & seconds to solve
    if success then 
        TriggerServerEvent('qb-vehiclekeys:server:AcquireVehicleKeys', plate)
    else 
        QBCore.Functions.Notify(Lang:t("notify.fvlockpick"), "error")
    end
    IsHotwiring = false
    ClearPedTasks(GetPlayerPed(-1))
end

function CarjackVehicle(target)
    if not Config.CarJackEnable then
        return
    end
    isCarjacking = true
    canCarjack = false
    loadAnimDict('mp_am_hold_up')
    local vehicle = GetVehiclePedIsUsing(target)
    local occupants = GetPedsInVehicle(vehicle)
    for p = 1, #occupants do
        local ped = occupants[p]
        CreateThread(function()
            TaskPlayAnim(ped, "mp_am_hold_up", "holdup_victim_20s", 8.0, -8.0, -1, 49, 0, false, false, false)
            PlayPain(ped, 6, 0)
            FreezeEntityPosition(vehicle, true)
            SetVehicleUndriveable(vehicle, true)
        end)
        Wait(math.random(200, 500))
    end
    -- Cancel progress bar if: Ped dies during robbery, car gets too far away
    CreateThread(function()
        while isCarjacking do
            local distance = #(GetEntityCoords(PlayerPedId()) - GetEntityCoords(target))
            if IsPedDeadOrDying(target) or distance > 7.5 then
                TriggerEvent("progressbar:client:cancel")
                FreezeEntityPosition(vehicle, false)
                SetVehicleUndriveable(vehicle, false)
            end
            Wait(100)
        end
    end)
    QBCore.Functions.Progressbar("rob_keys", Lang:t("progress.acjack"), Config.CarjackingTime, false, true, {}, {}, {},
        {}, function()
            local hasWeapon, weaponHash = GetCurrentPedWeapon(PlayerPedId(), true)
            if hasWeapon and isCarjacking then
                local carjackChance
                if Config.CarjackChance[tostring(GetWeapontypeGroup(weaponHash))] then
                    carjackChance = Config.CarjackChance[tostring(GetWeapontypeGroup(weaponHash))]
                else
                    carjackChance = 50
                end
                if math.random(1, 100) <= carjackChance then
                    local plate = QBCore.Functions.GetPlate(vehicle)
                    for p = 1, #occupants do
                        local ped = occupants[p]
                        CreateThread(function()
                            FreezeEntityPosition(vehicle, false)
                            SetVehicleUndriveable(vehicle, false)
                            TaskLeaveVehicle(ped, vehicle, 0)
                            PlayPain(ped, 6, 0)
                            Wait(1250)
                            ClearPedTasksImmediately(ped)
                            PlayPain(ped, math.random(7, 8), 0)
                            MakePedFlee(ped)
                        end)
                    end
                    TriggerServerEvent('hud:server:GainStress', math.random(1, 4))
                    TriggerServerEvent('qb-vehiclekeys:server:AcquireVehicleKeys', plate)
                else
                    QBCore.Functions.Notify(Lang:t("notify.cjackfail"), "error")
                    FreezeEntityPosition(vehicle, false)
                    SetVehicleUndriveable(vehicle, false)
                    MakePedFlee(target)
                    TriggerServerEvent('hud:server:GainStress', math.random(1, 4))
                end
                isCarjacking = false
                Wait(2000)
                AttemptPoliceAlert("carjack", GetEntityCoords(PlayerPedId())
                Wait(Config.DelayBetweenCarjackings)
                canCarjack = true
            end
        end, function()
            MakePedFlee(target)
            isCarjacking = false
            Wait(Config.DelayBetweenCarjackings)
            canCarjack = true
        end)
end

function AttemptPoliceAlert(type, coords)
    if not AlertSend then
        local chance = Config.PoliceAlertChance
        if GetClockHours() >= 1 and GetClockHours() <= 6 then
            chance = Config.PoliceNightAlertChance
        end
       if math.random() <= chance then
           if Config.Debug then print("^5Debug^7: ^3Shooting alert the police ^7") end
            if Config.Dispatch then
                if Config.Debug then print("^5Debug^7: ^3Using Dispatch ^7") end
               policeAlert(coords)
            end
        end
        AlertSend = true
        SetTimeout(Config.AlertCooldown, function()
            AlertSend = false
        end)
    end
end

function RGBToHex(r, g, b)
    local function componentToHex(c)
        local hex = string.format('%02X', c)
        return hex
    end
    local hex = '#' .. componentToHex(r) .. componentToHex(g) .. componentToHex(b)
    return hex
end

function GetVehicleData() 
    local ped = PlayerPedId()
    local veh = GetVehicle()
    local r, g, b = GetVehicleColor(veh)
    local color = RGBToHex(r, g, b)
    local model = GetEntityModel(veh)
    local model_string = GetDisplayNameFromVehicleModel(model)
    local plate = QBCore.Functions.GetPlate(veh)
    local coords = GetEntityCoords(ped)

    data = {
        R = r,
        G = g,
        B = b,
        color = color,
        model = model_string,
        plate = plate,
        coords = coords
    }
 return data
end

function MakePedFlee(ped)
    SetPedFleeAttributes(ped, 0, 0)
    TaskReactAndFleePed(ped, PlayerPedId())
end

function DrawText3D(x, y, z, text)
    SetTextScale(0.35, 0.35)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)
    SetTextEntry("STRING")
    SetTextCentre(true)
    AddTextComponentString(text)
    SetDrawOrigin(x, y, z, 0)
    DrawText(0.0, 0.0)
    local factor = (string.len(text)) / 370
    DrawRect(0.0, 0.0 + 0.0125, 0.017 + factor, 0.03, 0, 0, 0, 75)
    ClearDrawOrigin()
end

function GiveKeys(id, plate)
    local distance = #(GetEntityCoords(PlayerPedId()) - GetEntityCoords(GetPlayerPed(GetPlayerFromServerId(id))))
    if distance < 3.0 and distance > 0.0 then
        TriggerServerEvent('qb-vehiclekeys:server:GiveVehicleKeys', id, plate)
        ExecuteCommand('me Le da una copia de las llaves del vehículo')
    else
        QBCore.Functions.Notify(Lang:t("notify.nonear"), 'error')
    end
end


function HasKeys(plateToCheck)
    if Config.Debug then
        print("^5Debug^7: ^3Entering to ^7: client function HasKeys")
    end
    if plateToCheck then
        if Config.Debug then
            print("^5Debug^7: ^3Cheking plate ^7: " .. plateToCheck)
        end
        if Config.Debug then
            print("^5Debug^7: ^3sending query to server ")
        end
        local p = promise.new()
        QBCore.Functions.TriggerCallback('vehiclekeys:Haskey', function(result)
            p:resolve(result)
        end, plateToCheck)
        return Citizen.Await(p)
    else
        return plateToCheck
    end
end
exports('HasKeys', HasKeys)


function state(plateToCheck)
    if Config.Debug then
        print("^5Debug^7: ^3Entering to ^7: client function state")
    end
    if plateToCheck then
        if Config.Debug then
            print("^5Debug^7: ^3Cheking plate ^7: " .. plateToCheck)
        end
        if Config.Debug then
            print("^5Debug^7: ^3sending query to server ")
        end
        local p = promise.new()
        QBCore.Functions.TriggerCallback('vehiclekeys:state', function(result)
            p:resolve(result)
        end, plateToCheck)
        return Citizen.Await(p)
    else
        return plateToCheck
    end
end


function loadAnimDict(dict)
    while not HasAnimDictLoaded(dict) do
        RequestAnimDict(dict)
        Wait(0)
    end
end
