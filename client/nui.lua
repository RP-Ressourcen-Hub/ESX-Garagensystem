-- NUI Callbacks für das Garage-System

-- NUI-Funktionen
function RegisterNUICallbacks()
    -- Spawn-Fahrzeug Callback
    RegisterNUICallback('spawnVehicle', function(data, cb)
        SpawnGarageVehicle(data.plate)
        cb({status = true})
    end)
    
    -- Fahrzeug-Vorschau Callback
    RegisterNUICallback('previewVehicle', function(data, cb)
        PreviewGarageVehicle(data.props)
        cb({status = true})
    end)
    
    -- Fahrzeug-Transfer Callback
    RegisterNUICallback('transferVehicle', function(data, cb)
        local targetGarage = data.targetGarage
        local plate = data.plate
        
        if Config.AllowVehicleTransfer then
            TriggerServerEvent('garage:server:TransferVehicle', plate, CurrentGarage, targetGarage)
            cb({status = true})
        else
            cb({status = false, message = _U('transfer_not_allowed')})
        end
    end)
    
    -- Impound-Zahlung Callback
    RegisterNUICallback('payImpound', function(data, cb)
        local plate = data.plate
        
        if Config.EnableImpound then
            TriggerServerEvent('garage:server:PayImpound', plate)
            cb({status = true})
        else
            cb({status = false, message = _U('impound_not_enabled')})
        end
    end)
    
    -- Menü schließen Callback
    RegisterNUICallback('closeMenu', function(data, cb)
        CloseGarageMenu()
        cb({status = true})
    end)
    
    -- Garagen abrufen Callback
    RegisterNUICallback('getGarages', function(data, cb)
        local garages = {}
        
        for name, garage in pairs(Config.Garages) do
            if name ~= CurrentGarage then
                -- Überprüfe, ob der Spieler Zugriff auf diese Garage hat
                local hasAccess = true
                
                if garage.type == "job" and garage.allowed_jobs and next(garage.allowed_jobs) then
                    hasAccess = false
                    for _, job in ipairs(garage.allowed_jobs) do
                        if PlayerData.job and PlayerData.job.name == job then
                            hasAccess = true
                            break
                        end
                    end
                end
                
                if garage.type == "gang" and garage.allowed_gangs and next(garage.allowed_gangs) then
                    hasAccess = false
                    for _, gang in ipairs(garage.allowed_gangs) do
                        if PlayerData.gang and PlayerData.gang.name == gang then
                            hasAccess = true
                            break
                        end
                    end
                end
                
                -- Überprüfe auch, ob die Fahrzeugtypen kompatibel sind mit der Zielgarage
                local vehicleType = data.vehicleType or "car"
                local typeAllowed = false
                
                for _, allowedType in ipairs(garage.allowed_vehicles) do
                    if vehicleType == allowedType then
                        typeAllowed = true
                        break
                    end
                end
                
                if hasAccess and typeAllowed then
                    table.insert(garages, {
                        id = name,
                        name = garage.label,
                        type = garage.type
                    })
                end
            end
        end
        
        cb({garages = garages})
    end)
end

-- Initialisiere NUI-Callbacks
RegisterNUICallbacks()