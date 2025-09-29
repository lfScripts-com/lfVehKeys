function LockVehicle(vehicle)
    RequestAnimDict("anim@mp_player_intmenu@key_fob@")
    while not HasAnimDictLoaded("anim@mp_player_intmenu@key_fob@") do
        Citizen.Wait(100)
    end
    local locked = GetVehicleDoorLockStatus(vehicle)
    local netId = NetworkGetNetworkIdFromEntity(vehicle)
    if locked == 1 or locked == 0 then
        SetVehicleDoorsLocked(vehicle, 2)
        PlayVehicleDoorCloseSound(vehicle, 1)
        TaskPlayAnim(GetPlayerPed(-1), "anim@mp_player_intmenu@key_fob@", "fob_click", 8.0, 8.0, -1, 48, 1, false, false, false)
        ESX.ShowNotification("Vous avez ~r~verrouillé~s~ votre véhicule.")
        SetVehicleLights(vehicle, 2)
        Wait(200)
        SetVehicleLights(vehicle, 0)
        Wait(200)
        SetVehicleLights(vehicle, 2)
        Wait(400)
        SetVehicleLights(vehicle, 0)
        TriggerServerEvent('vehicle:syncLock', netId, 2, true)
    elseif locked == 2 then
        SetVehicleDoorsLocked(vehicle, 1)
        PlayVehicleDoorOpenSound(vehicle, 0)
        TaskPlayAnim(GetPlayerPed(-1), "anim@mp_player_intmenu@key_fob@", "fob_click", 8.0, 8.0, -1, 48, 1, false, false, false)
        ESX.ShowNotification("Vous avez ~g~déverrouillé~s~ votre véhicule.")
        SetVehicleLights(vehicle, 2)
        Wait(200)
        SetVehicleLights(vehicle, 0)
        Wait(200)
        SetVehicleLights(vehicle, 2)
        Wait(400)
        SetVehicleLights(vehicle, 0)
        TriggerServerEvent('vehicle:syncLock', netId, 1, false)
    end
end

RegisterNetEvent('vehicle:syncLockClient')
AddEventHandler('vehicle:syncLockClient', function(netId, lockStatus, isLocking)
    local vehicle = NetworkGetEntityFromNetworkId(netId)
    if vehicle and DoesEntityExist(vehicle) then
        SetVehicleDoorsLocked(vehicle, lockStatus)
        if isLocking then
            PlayVehicleDoorCloseSound(vehicle, 1)
            SetVehicleLights(vehicle, 2)
            Wait(200)
            SetVehicleLights(vehicle, 0)
            Wait(200)
            SetVehicleLights(vehicle, 2)
            Wait(400)
            SetVehicleLights(vehicle, 0)
        else
            PlayVehicleDoorOpenSound(vehicle, 0)
            SetVehicleLights(vehicle, 2)
            Wait(200)
            SetVehicleLights(vehicle, 0)
            Wait(200)
            SetVehicleLights(vehicle, 2)
            Wait(400)
            SetVehicleLights(vehicle, 0)
        end
    end
end)

RegisterNetEvent('vehicle:syncDoor')
AddEventHandler('vehicle:syncDoor', function(netId, doorId, isOpen)
    local vehicle = NetworkGetEntityFromNetworkId(netId)
    if vehicle and DoesEntityExist(vehicle) then
        if isOpen then
            SetVehicleDoorOpen(vehicle, doorId, false, false)
        else
            SetVehicleDoorShut(vehicle, doorId, false)
        end
    end
end)

function ToggleVehicleDoor(vehicle, doorId)
    local netId = NetworkGetNetworkIdFromEntity(vehicle)
    if netId then
        local isOpen = IsVehicleDoorDamaged(vehicle, doorId) == false and GetVehicleDoorAngleRatio(vehicle, doorId) > 0.0
        if isOpen then
            SetVehicleDoorShut(vehicle, doorId, false)
            TriggerServerEvent('vehicle:syncDoor', netId, doorId, false)
        else
            SetVehicleDoorOpen(vehicle, doorId, false, false)
            TriggerServerEvent('vehicle:syncDoor', netId, doorId, true)
        end
    end
end

function OpenCloseVehicle()
    local playerPed = GetPlayerPed(-1)
    local coords = GetEntityCoords(playerPed, true)
    local vehicle, distance = ESX.Game.GetClosestVehicle(coords)
    if distance < 3 then
        ESX.TriggerServerCallback('GetKeyVehicle', function(cb)
            if cb then
                LockVehicle(vehicle)
            end
        end, GetVehicleNumberPlateText(vehicle))
    else
        ESX.ShowNotification("~r~Il n'y a pas de véhicule près de vous.")
    end
end

RegisterKeyMapping('lockcar', '% - Clés de véhicule', 'keyboard', 'U')

RegisterCommand('lockcar', function()
    OpenCloseVehicle()
end)
