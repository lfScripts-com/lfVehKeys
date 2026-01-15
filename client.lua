if Config and Config.ESXMode == 'old' then
    ESX = ESX or nil
    TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
else
    ESX = exports["es_extended"]:getSharedObject()
end

-- Fonction helper pour les notifications
function ShowNotification(message, notifyType, title)
    notifyType = notifyType or "info"
    title = title or ""
    
    if Config and Config.NotifySystem == 'notify' then
        -- Utiliser esx_notify avec les types error/success
        local length = 3000
        if notifyType == "error" or notifyType == "success" then
            exports["esx_notify"]:Notify(notifyType, length, message, title)
        else
            exports["esx_notify"]:Notify("info", length, message, title)
        end
    else
        -- Utiliser ESX.ShowNotification par défaut
        ESX.ShowNotification(message)
    end
end
function LockVehicle(vehicle)
    local playerPed = GetPlayerPed(-1)
    local isInVehicle = IsPedInAnyVehicle(playerPed, false)
    
    -- Charger l'animation seulement si le joueur n'est pas dans un véhicule
    if not isInVehicle then
        RequestAnimDict("anim@mp_player_intmenu@key_fob@")
        while not HasAnimDictLoaded("anim@mp_player_intmenu@key_fob@") do
            Citizen.Wait(100)
        end
    end
    
    local locked = GetVehicleDoorLockStatus(vehicle)
    local netId = NetworkGetNetworkIdFromEntity(vehicle)
    if locked == 1 or locked == 0 then
        SetVehicleDoorsLocked(vehicle, 2)
        PlayVehicleDoorCloseSound(vehicle, 1)
        -- Jouer l'animation seulement si le joueur n'est pas dans un véhicule
        if not isInVehicle then
            TaskPlayAnim(playerPed, "anim@mp_player_intmenu@key_fob@", "fob_click", 8.0, 8.0, -1, 48, 1, false, false, false)
        end
        ShowNotification(Lang.locked, "success")
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
        -- Jouer l'animation seulement si le joueur n'est pas dans un véhicule
        if not isInVehicle then
            TaskPlayAnim(playerPed, "anim@mp_player_intmenu@key_fob@", "fob_click", 8.0, 8.0, -1, 48, 1, false, false, false)
        end
        ShowNotification(Lang.unlocked, "success")
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
        ShowNotification(Lang.noVehicle, "error")
    end
end

if Config and (Config.LockKeyEnabled == nil or Config.LockKeyEnabled == true) then
    RegisterKeyMapping('lockcar', Lang.keymapLabel, 'keyboard', (Config and Config.LockKey) or 'U')
    RegisterCommand('lockcar', function()
        OpenCloseVehicle()
    end)
end

if Config and Config.ox_target and GetResourceState('ox_target') == 'started' then
    exports.ox_target:addGlobalVehicle({
        {
            name = 'lfvehkeys_toggle',
            icon = 'fa-solid fa-key',
            label = Lang.keymapLabel,
            onSelect = function(data)
                OpenCloseVehicle()
            end
        }
    })
end
