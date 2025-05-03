-- Advanced Garage System für ESX/QBCore
Framework = nil
local VehiclesTable = {}

-- Initialize Framework
CreateThread(function()
    if GetResourceState('es_extended') == 'started' then
        ESX = exports["es_extended"]:getSharedObject()
        Framework = 'ESX'
        print("^2Garage System: ESX Framework erkannt.^0")
    elseif GetResourceState('qb-core') == 'started' then
        QBCore = exports['qb-core']:GetCoreObject()
        Framework = 'QBCore'
        print("^2Garage System: QBCore Framework erkannt.^0")
    else
        print("^1Garage System: Kein Framework (ESX oder QBCore) gefunden!^0")
        return
    end
    
    InitializeTables()
end)

function InitializeTables()
    if Framework == 'ESX' then
        MySQL.query('SELECT * FROM owned_vehicles', function(result)
            if result and #result > 0 then
                for _, vehicle in ipairs(result) do
                    local plate = vehicle.plate
                    local props = json.decode(vehicle.vehicle)
                    if plate and props then
                        VehiclesTable[plate] = {
                            owner = vehicle.owner,
                            stored = vehicle.stored == 1,
                            garage = vehicle.garage or 'legion_square',
                            type = props.model and GetVehicleTypeFromModel(props.model) or 'car',
                            props = props,
                            job = vehicle.job or 'none',
                            health = json.decode(vehicle.health or '{"engine":1000,"body":1000,"tank":1000}'),
                            damages = json.decode(vehicle.damages or '{}'),
                            fuel = vehicle.fuel or 100,
                            impounded = vehicle.impounded == 1
                        }
                    end
                end
                
                print("^2Garage System: " .. #result .. " Fahrzeuge geladen.^0")
            else
                print("^3Garage System: Keine Fahrzeuge in der Datenbank gefunden.^0")
            end
        end)
    elseif Framework == 'QBCore' then
        MySQL.query('SELECT * FROM player_vehicles', function(result)
            if result and #result > 0 then
                for _, vehicle in ipairs(result) do
                    local plate = vehicle.plate
                    local props = json.decode(vehicle.mods)
                    if plate and props then
                        VehiclesTable[plate] = {
                            owner = vehicle.citizenid,
                            stored = vehicle.state == 1,
                            garage = vehicle.garage or 'legion_square',
                            type = props.model and GetVehicleTypeFromModel(props.model) or 'car',
                            props = props,
                            job = 'none',
                            health = json.decode(vehicle.health or '{"engine":1000,"body":1000,"tank":1000}'),
                            damages = json.decode(vehicle.damages or '{}'),
                            fuel = vehicle.fuel or 100,
                            impounded = vehicle.state == 2
                        }
                    end
                end
                
                print("^2Garage System: " .. #result .. " Fahrzeuge geladen.^0")
            else
                print("^3Garage System: Keine Fahrzeuge in der Datenbank gefunden.^0")
            end
        end)
    end
end

-- Fahrzeug-Typ aus Modell ermitteln
function GetVehicleTypeFromModel(model)
    -- Diese Funktion könnte verbessert werden mit einer umfangreicheren Fahrzeugtypdatenbank
    -- Hier ein vereinfachter Ansatz basierend auf Hash-Bereichen
    local hash = tonumber(model)
    
    -- Fahrzeuge nach Hash identifizieren (sehr vereinfacht)
    local boats = {
        [-1043459709] = true, -- Dinghy
        [-272956171] = true,  -- Jetmax
        [1033245328] = true,  -- Dinghy2
        [861409633] = true,   -- Jetmax
        [-1600252419] = true, -- Dinghy3
        [1070967343] = true,  -- Toro
        [290013743] = true,   -- Submersible
        [231083307] = true,   -- Speeder
        [400514754] = true,   -- Squalo
        [-282946103] = true,  -- Suntrap
        [1336872304] = true,  -- Toro
        [908897389] = true,   -- Tropic
    }
    
    local planes = {
        [970385471] = true,   -- Hydra
        [621481054] = true,   -- Luxor
        [-1281684762] = true, -- Lazer
        [1058115860] = true,  -- Vestra
        [-1746576111] = true, -- Titan
        [1981688531] = true,  -- Titan
        [970356638] = true,   -- Duster
        [-1214505995] = true, -- Shamal
        [1981688531] = true,  -- Titan
    }
    
    local helis = {
        [744705981] = true,   -- Frogger
        [1044954915] = true,  -- Skylift
        [788747387] = true,   -- Buzzard
        [-339587598] = true,  -- Swift
        [-1660661558] = true, -- Volatus
        [-1523619553] = true, -- Valkyrie2
        [353883353] = true,   -- Polmav
    }
    
    local bikes = {
        [1672195559] = true,  -- Akuma
        [-2115793025] = true, -- Avarus
        [2154536131] = true,  -- Bagger
        [-114291515] = true,  -- Bati
        [-891462355] = true,  -- Bati2
        [86520421] = true,    -- BF400
        [11251904] = true,    -- Carbon RS
        [6774487] = true,     -- Chimera
        [390201602] = true,   -- Cliffhanger
        [2006142190] = true,  -- Daemon
        [-1404136503] = true, -- Daemon2
        [822018448] = true,   -- Defiler
        [-239841468] = true,  -- Double
        [-1670998136] = true, -- Enduro
        [1753414259] = true,  -- Esskey
        [-1842748181] = true, -- Faggio
        [55628203] = true,    -- Faggio2
        [-1289178744] = true, -- Faggio3
    }
    
    if boats[hash] then
        return "boat"
    elseif planes[hash] then
        return "plane"
    elseif helis[hash] then
        return "helicopter"
    elseif bikes[hash] then
        return "bike"
    else
        return "car" -- Default zu Auto wenn nicht speziell erkannt
    end
end

-- Events
RegisterNetEvent('garage:server:GetVehicles')
AddEventHandler('garage:server:GetVehicles', function(garageName)
    local source = source
    local garage = Config.Garages[garageName]
    
    if not garage then
        return
    end
    
    local identifier = GetPlayerIdentifier(source)
    if not identifier then return end
    
    local vehicles = {}
    
    for plate, vehicle in pairs(VehiclesTable) do
        if vehicle.owner == identifier then
            -- Fahrzeugtyp-Überprüfung
            local allowedVehicle = false
            for _, allowedType in ipairs(garage.allowed_vehicles) do
                if vehicle.type == allowedType then
                    allowedVehicle = true
                    break
                end
            end
            
            if allowedVehicle then
                -- Bestimme Status
                local status = 'stored'
                if vehicle.impounded then
                    status = 'impounded'
                elseif not vehicle.stored then
                    status = 'out'
                end
                
                -- Fahrzeug nur im aktuellen Garagentyp anzeigen
                if garage.type == 'impound' and status == 'impounded' then
                    table.insert(vehicles, {
                        plate = plate,
                        name = GetVehicleNameFromModel(vehicle.props.model),
                        model = vehicle.props.model,
                        type = vehicle.type,
                        props = vehicle.props,
                        status = status,
                        garage = vehicle.garage,
                        job = vehicle.job,
                        fuel = vehicle.fuel,
                        health = vehicle.health,
                        damages = vehicle.damages
                    })
                elseif garage.type ~= 'impound' and (status == 'stored' and vehicle.garage == garageName) then
                    table.insert(vehicles, {
                        plate = plate,
                        name = GetVehicleNameFromModel(vehicle.props.model),
                        model = vehicle.props.model,
                        type = vehicle.type,
                        props = vehicle.props,
                        status = status,
                        garage = vehicle.garage,
                        job = vehicle.job,
                        fuel = vehicle.fuel,
                        health = vehicle.health,
                        damages = vehicle.damages
                    })
                elseif garage.type ~= 'impound' and status == 'out' and vehicle.garage == garageName then
                    table.insert(vehicles, {
                        plate = plate,
                        name = GetVehicleNameFromModel(vehicle.props.model),
                        model = vehicle.props.model,
                        type = vehicle.type,
                        props = vehicle.props,
                        status = status,
                        garage = vehicle.garage,
                        job = vehicle.job,
                        fuel = vehicle.fuel,
                        health = vehicle.health,
                        damages = vehicle.damages
                    })
                end
            end
        end
    end
    
    TriggerClientEvent('garage:client:ReceiveVehicles', source, vehicles)
end)

RegisterNetEvent('garage:server:SaveVehicle')
AddEventHandler('garage:server:SaveVehicle', function(garageName, plate, vehicleProps, health, damages, fuel)
    local source = source
    local identifier = GetPlayerIdentifier(source)
    if not identifier then return end
    
    -- Säubere das Kennzeichen
    plate = string.gsub(plate, "^%s*(.-)%s*$", "%1")
    
    -- Überprüfe, ob das Fahrzeug existiert und dem Spieler gehört
    local found = false
    local vehicleOwner = nil
    
    if VehiclesTable[plate] then
        vehicleOwner = VehiclesTable[plate].owner
        found = true
    end
    
    if found and vehicleOwner == identifier then
        -- Aktualisiere Fahrzeugdaten
        VehiclesTable[plate].stored = true
        VehiclesTable[plate].garage = garageName
        VehiclesTable[plate].props = vehicleProps
        VehiclesTable[plate].health = health
        VehiclesTable[plate].damages = damages
        VehiclesTable[plate].fuel = fuel
        
        -- Speichere Daten in Datenbank
        if Framework == 'ESX' then
            MySQL.update('UPDATE owned_vehicles SET vehicle = ?, garage = ?, stored = ?, health = ?, damages = ?, fuel = ? WHERE plate = ?',
                {json.encode(vehicleProps), garageName, 1, json.encode(health), json.encode(damages), fuel, plate})
        elseif Framework == 'QBCore' then
            MySQL.update('UPDATE player_vehicles SET mods = ?, garage = ?, state = ?, health = ?, damages = ?, fuel = ? WHERE plate = ?',
                {json.encode(vehicleProps), garageName, 1, json.encode(health), json.encode(damages), fuel, plate})
        end
    else
        -- Fahrzeug nicht gefunden oder gehört nicht dem Spieler
        -- Hier könnte optional ein automatisches Registrierungssystem für neue Fahrzeuge implementiert werden
        TriggerClientEvent('garage:client:ShowNotification', source, _U('vehicle_not_owned'))
        return
    end
end)

RegisterNetEvent('garage:server:SpawnVehicle')
AddEventHandler('garage:server:SpawnVehicle', function(plate, garageName, spawnPoint)
    local source = source
    local identifier = GetPlayerIdentifier(source)
    if not identifier then return end
    
    -- Säubere das Kennzeichen
    plate = string.gsub(plate, "^%s*(.-)%s*$", "%1")
    
    -- Überprüfe, ob das Fahrzeug existiert und dem Spieler gehört
    if VehiclesTable[plate] and VehiclesTable[plate].owner == identifier then
        local vehicle = VehiclesTable[plate]
        
        -- Überprüfen, ob Fahrzeug in dieser Garage ist und eingelagert ist
        if vehicle.garage == garageName and vehicle.stored and not vehicle.impounded then
            -- Aktualisiere Fahrzeugdaten
            VehiclesTable[plate].stored = false
            
            -- Speichere Daten in Datenbank
            if Framework == 'ESX' then
                MySQL.update('UPDATE owned_vehicles SET stored = ? WHERE plate = ?', {0, plate})
            elseif Framework == 'QBCore' then
                MySQL.update('UPDATE player_vehicles SET state = ? WHERE plate = ?', {0, plate})
            end
            
            -- Sende Fahrzeugdaten zum Client
            TriggerClientEvent('garage:client:SpawnVehicle', source, vehicle.props, spawnPoint, vehicle.health, vehicle.damages, vehicle.fuel)
        elseif vehicle.impounded then
            TriggerClientEvent('garage:client:ShowNotification', source, _U('vehicle_impounded'))
        else
            TriggerClientEvent('garage:client:ShowNotification', source, _U('vehicle_not_in_garage'))
        end
    else
        TriggerClientEvent('garage:client:ShowNotification', source, _U('vehicle_not_owned'))
    end
end)

RegisterNetEvent('garage:server:TransferVehicle')
AddEventHandler('garage:server:TransferVehicle', function(plate, currentGarage, targetGarage)
    local source = source
    local identifier = GetPlayerIdentifier(source)
    if not identifier then return end
    
    -- Säubere das Kennzeichen
    plate = string.gsub(plate, "^%s*(.-)%s*$", "%1")
    
    -- Überprüfe, ob das Fahrzeug existiert und dem Spieler gehört
    if VehiclesTable[plate] and VehiclesTable[plate].owner == identifier then
        local vehicle = VehiclesTable[plate]
        
        -- Überprüfen, ob Fahrzeug in aktueller Garage und eingelagert ist
        if vehicle.garage == currentGarage and vehicle.stored and not vehicle.impounded then
            -- Kosten berechnen und abziehen
            local canPay = true
            
            if Config.TransferFee > 0 then
                if Framework == 'ESX' then
                    local xPlayer = ESX.GetPlayerFromId(source)
                    if xPlayer.getMoney() >= Config.TransferFee then
                        xPlayer.removeMoney(Config.TransferFee)
                    elseif xPlayer.getAccount('bank').money >= Config.TransferFee then
                        xPlayer.removeAccountMoney('bank', Config.TransferFee)
                    else
                        canPay = false
                    end
                elseif Framework == 'QBCore' then
                    local Player = QBCore.Functions.GetPlayer(source)
                    if Player.PlayerData.money['cash'] >= Config.TransferFee then
                        Player.Functions.RemoveMoney('cash', Config.TransferFee)
                    elseif Player.PlayerData.money['bank'] >= Config.TransferFee then
                        Player.Functions.RemoveMoney('bank', Config.TransferFee)
                    else
                        canPay = false
                    end
                end
            end
            
            if canPay then
                -- Aktualisiere Fahrzeugdaten
                VehiclesTable[plate].garage = targetGarage
                
                -- Speichere Daten in Datenbank
                if Framework == 'ESX' then
                    MySQL.update('UPDATE owned_vehicles SET garage = ? WHERE plate = ?', {targetGarage, plate})
                elseif Framework == 'QBCore' then
                    MySQL.update('UPDATE player_vehicles SET garage = ? WHERE plate = ?', {targetGarage, plate})
                end
                
                TriggerClientEvent('garage:client:ShowNotification', source, _U('vehicle_transferred'))
            else
                TriggerClientEvent('garage:client:ShowNotification', source, _U('not_enough_money'))
            end
        else
            TriggerClientEvent('garage:client:ShowNotification', source, _U('vehicle_not_in_garage'))
        end
    else
        TriggerClientEvent('garage:client:ShowNotification', source, _U('vehicle_not_owned'))
    end
end)

RegisterNetEvent('garage:server:PayImpound')
AddEventHandler('garage:server:PayImpound', function(plate)
    local source = source
    local identifier = GetPlayerIdentifier(source)
    if not identifier then return end
    
    -- Säubere das Kennzeichen
    plate = string.gsub(plate, "^%s*(.-)%s*$", "%1")
    
    -- Überprüfe, ob das Fahrzeug existiert und dem Spieler gehört
    if VehiclesTable[plate] and VehiclesTable[plate].owner == identifier then
        local vehicle = VehiclesTable[plate]
        
        -- Überprüfen, ob Fahrzeug beschlagnahmt ist
        if vehicle.impounded then
            -- Kosten berechnen und abziehen
            local canPay = true
            
            if Config.ImpoundFee > 0 then
                if Framework == 'ESX' then
                    local xPlayer = ESX.GetPlayerFromId(source)
                    if xPlayer.getMoney() >= Config.ImpoundFee then
                        xPlayer.removeMoney(Config.ImpoundFee)
                    elseif xPlayer.getAccount('bank').money >= Config.ImpoundFee then
                        xPlayer.removeAccountMoney('bank', Config.ImpoundFee)
                    else
                        canPay = false
                    end
                elseif Framework == 'QBCore' then
                    local Player = QBCore.Functions.GetPlayer(source)
                    if Player.PlayerData.money['cash'] >= Config.ImpoundFee then
                        Player.Functions.RemoveMoney('cash', Config.ImpoundFee)
                    elseif Player.PlayerData.money['bank'] >= Config.ImpoundFee then
                        Player.Functions.RemoveMoney('bank', Config.ImpoundFee)
                    else
                        canPay = false
                    end
                end
            end
            
            if canPay then
                -- Aktualisiere Fahrzeugdaten
                VehiclesTable[plate].impounded = false
                VehiclesTable[plate].stored = true
                VehiclesTable[plate].garage = 'legion_square' -- Standard-Garage nach Auslösung
                
                -- Speichere Daten in Datenbank
                if Framework == 'ESX' then
                    MySQL.update('UPDATE owned_vehicles SET impounded = ?, stored = ?, garage = ? WHERE plate = ?', {0, 1, 'legion_square', plate})
                elseif Framework == 'QBCore' then
                    MySQL.update('UPDATE player_vehicles SET state = ?, garage = ? WHERE plate = ?', {1, 'legion_square', plate})
                end
                
                TriggerClientEvent('garage:client:ShowNotification', source, _U('vehicle_released'))
            else
                TriggerClientEvent('garage:client:ShowNotification', source, _U('not_enough_money'))
            end
        else
            TriggerClientEvent('garage:client:ShowNotification', source, _U('vehicle_not_impounded'))
        end
    else
        TriggerClientEvent('garage:client:ShowNotification', source, _U('vehicle_not_owned'))
    end
end)

RegisterNetEvent('garage:server:GiveKeys')
AddEventHandler('garage:server:GiveKeys', function(plate)
    local source = source
    
    if not Config.UseCarKeys then return end
    
    -- Hier könnte ein Schlüsselsystem integriert werden
    -- Beispiel: TriggerEvent('keys:addKey', source, plate)
    
    -- Da wir kein spezifisches Schlüsselsystem haben, nur eine Benachrichtigung senden
    TriggerClientEvent('garage:client:ShowNotification', source, _U('keys_received'))
end)

-- Hilfsfunktionen
function GetPlayerIdentifier(source)
    if Framework == 'ESX' then
        local xPlayer = ESX.GetPlayerFromId(source)
        if xPlayer then
            return xPlayer.identifier
        end
    elseif Framework == 'QBCore' then
        local Player = QBCore.Functions.GetPlayer(source)
        if Player then
            return Player.PlayerData.citizenid
        end
    end
    
    return nil
end

function GetVehicleNameFromModel(model)
    -- Hier könnte ein umfassendes System zur Fahrzeugnamenermittlung implementiert werden
    -- Vereinfacht: Model-Hash zurückgeben, wenn kein Name gefunden wird
    local vehicleNames = {
        -- Autos
        [GetHashKey('adder')] = 'Adder',
        [GetHashKey('zentorno')] = 'Zentorno',
        [GetHashKey('t20')] = 'T20',
        [GetHashKey('kuruma')] = 'Kuruma',
        [GetHashKey('bati')] = 'Bati 801',
        [GetHashKey('faggio')] = 'Faggio',
        [GetHashKey('blista')] = 'Blista',
        -- Füge mehr hinzu nach Bedarf
    }
    
    return vehicleNames[model] or 'Unknown (' .. model .. ')'
end