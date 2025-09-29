RegisterNetEvent('addKeyVehicle')
AddEventHandler('addKeyVehicle', function(target, plate)
    local xTarget = ESX.GetPlayerFromId(target)
    
    if target ~= nil and plate ~= nil then
        MySQL.Async.execute('INSERT INTO vehicle_key (identifier, plate, label) VALUES (@identifier, @plate, @label)', {
            ['@identifier'] = xTarget.identifier,
            ['@plate'] = plate,
            ['@label'] = xTarget.getName()
        })
    end
end)

ESX.RegisterServerCallback('GetKeyVehicle', function(source, cb, plaque)
    local xPlayer = ESX.GetPlayerFromId(source)

    MySQL.Async.fetchAll("SELECT 1 FROM owned_vehicles WHERE owner = @identifier AND plate = @plate", {
        ['@plate'] = plaque,
        ['@identifier'] = xPlayer.identifier
    }, function(row)
        if row[1] ~= nil then
            cb(true)
        else
            MySQL.Async.fetchAll("SELECT 1 FROM vehicle_key WHERE identifier = @identifier AND plate = @plate", {
                ['@plate'] = plaque,
                ['@identifier'] = xPlayer.identifier
            }, function(row_keys)
                if row_keys[1] ~= nil then
                    cb(true)
                else
                    if Config and Config.lfTerritory == true then
                        MySQL.Async.fetchAll("SELECT cm.id_crew, cm.id_grade, cg.key_vehicle FROM crew_membres cm LEFT JOIN crew_grades cg ON cm.id_grade = cg.id_grade WHERE cm.identifier = @identifier", {
                            ["@identifier"] = xPlayer.identifier
                        }, function(row2)
                            if row2[1] and row2[1].id_crew and row2[1].key_vehicle == 1 then
                                local IdCrew = row2[1].id_crew
                                MySQL.Async.fetchAll("SELECT 1 FROM crew_vehicles WHERE plate = @plate AND crew = @crew", {
                                    ['@plate'] = plaque,
                                    ['@crew'] = IdCrew
                                }, function(row3)
                                    if row3[1] then
                                        cb(true)
                                    else
                                        MySQL.Async.fetchAll("SELECT 1 FROM jobs_vehicles WHERE plate = @plate AND job = @job", {
                                            ['@plate'] = plaque,
                                            ['@job'] = xPlayer.job.name
                                        }, function(row4)
                                            if row4[1] then
                                                cb(true)
                                            else
                                                cb(false)
                                                xPlayer.showNotification(Lang.noKeys)
                                            end
                                        end)
                                    end
                                end)
                            else
                                MySQL.Async.fetchAll("SELECT 1 FROM jobs_vehicles WHERE plate = @plate AND job = @job", {
                                    ['@plate'] = plaque,
                                    ['@job'] = xPlayer.job.name
                                }, function(row5)
                                    if row5[1] then
                                        cb(true)
                                    else
                                        cb(false)
                                        xPlayer.showNotification(Lang.noKeys)
                                    end
                                end)
                            end
                        end)
                    else
                        MySQL.Async.fetchAll("SELECT 1 FROM jobs_vehicles WHERE plate = @plate AND job = @job", {
                            ['@plate'] = plaque,
                            ['@job'] = xPlayer.job.name
                        }, function(row5)
                            if row5[1] then
                                cb(true)
                            else
                                cb(false)
                                xPlayer.showNotification(Lang.noKeys)
                            end
                        end)
                    end
                end
            end)
        end
    end)
end)

function CheckVehicleKeyPermission(xPlayer, plate)
    local owned = MySQL.Sync.fetchAll("SELECT 1 FROM owned_vehicles WHERE owner = @identifier AND plate = @plate", {
        ['@plate'] = plate,
        ['@identifier'] = xPlayer.identifier
    })
    if owned[1] then return true end
    local directKey = MySQL.Sync.fetchAll("SELECT 1 FROM vehicle_key WHERE identifier = @identifier AND plate = @plate", {
        ['@plate'] = plate,
        ['@identifier'] = xPlayer.identifier
    })
    if directKey[1] then return true end
    if Config and Config.lfTerritory == true then
        local crew = MySQL.Sync.fetchAll("SELECT cm.id_crew, cm.id_grade, cg.key_vehicle FROM crew_membres cm LEFT JOIN crew_grades cg ON cm.id_grade = cg.id_grade WHERE cm.identifier = @identifier", {
            ["@identifier"] = xPlayer.identifier
        })
        if crew[1] and crew[1].id_crew and crew[1].key_vehicle == 1 then
            local crewVeh = MySQL.Sync.fetchAll("SELECT 1 FROM crew_vehicles WHERE plate = @plate AND crew = @crew", {
                ['@plate'] = plate,
                ['@crew'] = crew[1].id_crew
            })
            if crewVeh[1] then return true end
        end
    end
    local jobVeh = MySQL.Sync.fetchAll("SELECT 1 FROM jobs_vehicles WHERE plate = @plate AND job = @job", {
        ['@plate'] = plate,
        ['@job'] = xPlayer.job.name
    })
    if jobVeh[1] then return true end

    return false
end

RegisterNetEvent('vehicle:syncLock')
AddEventHandler('vehicle:syncLock', function(netId, lockStatus, isLocking)
    local source = source
    local xPlayer = ESX.GetPlayerFromId(source)
    
    if not xPlayer then return end
    
    local vehicle = NetworkGetEntityFromNetworkId(netId)
    if vehicle and DoesEntityExist(vehicle) then
        local plate = GetVehicleNumberPlateText(vehicle)

        if CheckVehicleKeyPermission(xPlayer, plate) then
            TriggerClientEvent('vehicle:syncLockClient', -1, netId, lockStatus, isLocking)
        end
    end
end)

RegisterNetEvent('vehicle:syncDoor')
AddEventHandler('vehicle:syncDoor', function(netId, doorId, isOpen)
    local source = source
    local xPlayer = ESX.GetPlayerFromId(source)
    
    if not xPlayer then return end
    
    local vehicle = NetworkGetEntityFromNetworkId(netId)
    if vehicle and DoesEntityExist(vehicle) then
        local plate = GetVehicleNumberPlateText(vehicle)
        
        if CheckVehicleKeyPermission(xPlayer, plate) then
            TriggerClientEvent('vehicle:syncDoor', -1, netId, doorId, isOpen)
        end
    end
end)
