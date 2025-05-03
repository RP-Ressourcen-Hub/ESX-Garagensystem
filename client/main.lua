-- Advanced Garage System für ESX/QBCore
Framework = nil
local PlayerData = {}
local CurrentGarage = nil
local CurrentVehicles = {}
local PreviewVehicle = nil
local InGarageMenu = false
local DoesFetchingVehicles = false
local NearestGarage = nil
local isInitialized = false

-- Initialize Framework
CreateThread(function()
    if GetResourceState('es_extended') == 'started' then
        while not ESX do
            TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
            Wait(0)
        end
        
        while not ESX.IsPlayerLoaded() do
            Wait(100)
        end
        
        Framework = 'ESX'
        PlayerData = ESX.GetPlayerData()
        
        RegisterNetEvent('esx:playerLoaded')
        AddEventHandler('esx:playerLoaded', function(xPlayer)
            PlayerData = xPlayer
        end)
        
        RegisterNetEvent('esx:setJob')
        AddEventHandler('esx:setJob', function(job)
            PlayerData.job = job
        end)
    elseif GetResourceState('qb-core') == 'started' then
        QBCore = exports['qb-core']:GetCoreObject()
        
        RegisterNetEvent('QBCore:Client:OnPlayerLoaded')
        AddEventHandler('QBCore:Client:OnPlayerLoaded', function()
            PlayerData = QBCore.Functions.GetPlayerData()
        end)
        
        RegisterNetEvent('QBCore:Client:OnJobUpdate')
        AddEventHandler('QBCore:Client:OnJobUpdate', function(job)
            PlayerData.job = job
        end)
        
        while PlayerData.citizenid == nil do
            PlayerData = QBCore.Functions.GetPlayerData()
            Wait(100)
        end
        
        Framework = 'QBCore'
    else
        print("^1GARAGE SYSTEM ERROR: Kein ESX oder QBCore Framework erkannt!^0")
    end
    
    isInitialized = true
    InitializeGarageSystem()
end)

function InitializeGarageSystem()
    -- Erstelle Blips
    CreateGarageBlips()
    
    -- Tastenbelegung
    if Config.UseKeyMapping then
        RegisterKeyMapping('garage', 'Öffnet das Garagenmenü', 'keyboard', Config.KeyMapping)
    end
    
    -- Kommandos
    if Config.UseCommand then
        RegisterCommand('garage', function()
            if IsNearGarage() then
                OpenGarageMenu(NearestGarage)
            else
                ShowNotification(_U('not_near_garage'))
            end
        end, false)
    end
    
    -- Main Thread für Marker und Interaktion
    CreateThread(function()
        while true do
            local sleep = 1000
            local playerPed = PlayerPedId()
            local playerCoords = GetEntityCoords(playerPed)
            local isInVehicle = IsPedInAnyVehicle(playerPed, false)
            
            NearestGarage = nil
            local nearestDistance = math.huge
            
            for garageName, garage in pairs(Config.Garages) do
                -- Menüpunkt
                local menuDist = #(playerCoords - garage.menu_point.coords)
                if menuDist < nearestDistance then
                    nearestDistance = menuDist
                    NearestGarage = garageName
                end
                
                -- Marker und Interaktion für Menü
                if menuDist < 50.0 then
                    sleep = 0
                    if Config.DrawMarker and menuDist < 50.0 then
                        DrawMarker(Config.MarkerType, garage.menu_point.coords, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 
                                  Config.MarkerSize.x, Config.MarkerSize.y, Config.MarkerSize.z, 
                                  Config.MarkerColor.r, Config.MarkerColor.g, Config.MarkerColor.b, Config.MarkerColor.a, 
                                  false, true, 2, false, nil, nil, false)
                    end
                    
                    if menuDist < garage.menu_point.radius then
                        sleep = 0
                        DrawText3D(garage.menu_point.coords.x, garage.menu_point.coords.y, garage.menu_point.coords.z + 1.0, _U('press_to_open_garage') .. ' [E]')
                        
                        if IsControlJustReleased(0, 38) then -- E key
                            OpenGarageMenu(garageName)
                        end
                    end
                end
                
                -- Einpark-Punkt, nur wenn im Fahrzeug
                if isInVehicle then
                    local parkingDist = #(playerCoords - garage.parking_point.coords)
                    if parkingDist < garage.parking_point.radius then
                        sleep = 0
                        DrawText3D(garage.parking_point.coords.x, garage.parking_point.coords.y, garage.parking_point.coords.z + 1.0, _U('press_to_store_vehicle') .. ' [H]')
                        
                        if IsControlJustReleased(0, 74) then -- H key
                            StoreVehicleInGarage(garageName)
                        end
                    end
                end
            end
            
            Wait(sleep)
        end
    end)
end

function CreateGarageBlips()
    for garageName, garage in pairs(Config.Garages) do
        if garage.blip then
            local blip = AddBlipForCoord(garage.menu_point.coords)
            SetBlipSprite(blip, Config.BlipSprite)
            SetBlipDisplay(blip, 4)
            SetBlipScale(blip, Config.BlipScale)
            SetBlipColour(blip, Config.BlipColor)
            SetBlipAsShortRange(blip, true)
            
            BeginTextCommandSetBlipName("STRING")
            if garage.type == "impound" then
                AddTextComponentString(garage.label .. " (Beschlagnahme)")
            else
                AddTextComponentString(garage.label)
            end
            EndTextCommandSetBlipName(blip)
        end
    end
end

function OpenGarageMenu(garageName)
    if InGarageMenu then return end
    
    local garage = Config.Garages[garageName]
    if not garage then return end
    
    -- Überprüfe Berechtigungen
    if garage.type == "job" and garage.allowed_jobs and next(garage.allowed_jobs) then
        local hasJob = false
        for _, job in ipairs(garage.allowed_jobs) do
            if PlayerData.job and PlayerData.job.name == job then
                hasJob = true
                break
            end
        end
        
        if not hasJob then
            ShowNotification(_U('no_job_access'))
            return
        end
    end
    
    if garage.type == "gang" and garage.allowed_gangs and next(garage.allowed_gangs) then
        local hasGang = false
        for _, gang in ipairs(garage.allowed_gangs) do
            if PlayerData.gang and PlayerData.gang.name == gang then
                hasGang = true
                break
            end
        end
        
        if not hasGang then
            ShowNotification(_U('no_gang_access'))
            return
        end
    end
    
    CurrentGarage = garageName
    InGarageMenu = true
    DoesFetchingVehicles = true
    
    -- Hole Fahrzeuge vom Server
    TriggerServerEvent('garage:server:GetVehicles', garageName)
    
    -- Öffne NUI
    SendNUIMessage({
        action = "open",
        garage = garage.label,
        garageType = garage.type,
        config = {
            title = Config.UI.title,
            logo = Config.UI.logo,
            darkMode = Config.UI.darkMode,
            showVehicleStats = Config.UI.showVehicleStats,
            showVehicleMods = Config.UI.showVehicleMods,
            vehicleCategories = Config.VehicleCategories,
            defaultCategory = Config.UI.defaultCategory,
            vehicleTypes = Config.VehicleTypes,
            vehicleClassifications = Config.VehicleClassifications,
            statuses = Config.VehicleStatuses
        }
    })
    
    SetNuiFocus(true, true)
end

function StoreVehicleInGarage(garageName)
    local garage = Config.Garages[garageName]
    if not garage then return end
    
    local playerPed = PlayerPedId()
    local vehicle = GetVehiclePedIsIn(playerPed, false)
    
    if not DoesEntityExist(vehicle) then
        ShowNotification(_U('not_in_vehicle'))
        return
    end
    
    -- Überprüfe, ob der Fahrzeugtyp in dieser Garage erlaubt ist
    local vehicleType = GetVehicleType(vehicle)
    local isAllowed = false
    
    for _, allowedType in ipairs(garage.allowed_vehicles) do
        if vehicleType == allowedType then
            isAllowed = true
            break
        end
    end
    
    if not isAllowed then
        ShowNotification(_U('vehicle_type_not_allowed'))
        return
    end
    
    -- Überprüfe, ob der Spieler der Besitzer des Fahrzeugs ist
    local plate = GetVehicleNumberPlateText(vehicle)
    if plate then
        plate = string.gsub(plate, "^%s*(.-)%s*$", "%1") -- Trim whitespace
    end
    
    -- Sammel Fahrzeugdaten
    local vehicleProps = GetVehicleProperties(vehicle)
    local health = {
        engine = GetVehicleEngineHealth(vehicle),
        body = GetVehicleBodyHealth(vehicle),
        tank = GetVehiclePetrolTankHealth(vehicle)
    }
    local damages = {}
    
    if Config.SaveVehicleDamage then
        -- Sammle Schäden (gebrochene Fenster, Türen, etc.)
        damages = {
            windows = {},
            doors = {},
            tyres = {}
        }
        
        for i = 0, 7 do
            damages.windows[i] = not IsVehicleWindowIntact(vehicle, i)
        end
        
        for i = 0, 5 do
            damages.doors[i] = IsVehicleDoorDamaged(vehicle, i)
        end
        
        for i = 0, 7 do
            damages.tyres[i] = IsVehicleTyreBurst(vehicle, i, false)
        end
    end
    
    local fuel = 0
    if Config.SaveVehicleFuel then
        -- Hole Kraftstoffstand (je nach verwendetem Ressourcen-System)
        -- Für ESX Legacy natives:
        fuel = GetVehicleFuelLevel(vehicle)
        
        -- Für LegacyFuel, FRFuel etc. könnte ein Export verwendet werden
        -- z.B.: fuel = exports["LegacyFuel"]:GetFuel(vehicle)
    end
    
    TriggerServerEvent('garage:server:SaveVehicle', garageName, plate, vehicleProps, health, damages, fuel)
    
    -- Lösche Fahrzeug und benachrichtige Spieler
    DeleteEntity(vehicle)
    ShowNotification(_U('vehicle_stored'))
end

RegisterNetEvent('garage:client:ReceiveVehicles')
AddEventHandler('garage:client:ReceiveVehicles', function(vehicles)
    DoesFetchingVehicles = false
    CurrentVehicles = vehicles
    
    -- Übertrage Fahrzeuge an UI
    SendNUIMessage({
        action = "setVehicles",
        vehicles = vehicles
    })
end)

-- NUI Callbacks
RegisterNUICallback('spawnVehicle', function(data, cb)
    cb({status = true})
    SpawnGarageVehicle(data.plate)
    CloseGarageMenu()
end)

RegisterNUICallback('previewVehicle', function(data, cb)
    cb({status = true})
    PreviewGarageVehicle(data.props)
end)

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

RegisterNUICallback('payImpound', function(data, cb)
    local plate = data.plate
    
    if Config.EnableImpound then
        TriggerServerEvent('garage:server:PayImpound', plate)
        cb({status = true})
    else
        cb({status = false, message = _U('impound_not_enabled')})
    end
end)

RegisterNUICallback('closeMenu', function(data, cb)
    cb({status = true})
    CloseGarageMenu()
end)

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

-- Fahrzeug-Funktionen
function SpawnGarageVehicle(plate)
    if not plate or not CurrentGarage then return end
    
    local garage = Config.Garages[CurrentGarage]
    if not garage then return end
    
    local spawnPoint = nil
    
    -- Finde einen freien Spawn-Punkt
    for _, point in ipairs(garage.spawn_points) do
        if IsSpawnPointClear(point.coords, point.radius) then
            spawnPoint = point
            break
        end
    end
    
    if not spawnPoint then
        ShowNotification(_U('no_spawn_point'))
        return
    end
    
    -- Hole Fahrzeugdaten vom Server und spawne es
    TriggerServerEvent('garage:server:SpawnVehicle', plate, CurrentGarage, spawnPoint)
    
    if PreviewVehicle then
        DeleteEntity(PreviewVehicle)
        PreviewVehicle = nil
    end
end

function PreviewGarageVehicle(vehicleProps)
    if not vehicleProps or not CurrentGarage then return end
    
    -- Lösche vorheriges Vorschaufahrzeug, falls vorhanden
    if PreviewVehicle ~= nil then
        DeleteEntity(PreviewVehicle)
        PreviewVehicle = nil
    end
    
    local garage = Config.Garages[CurrentGarage]
    if not garage then return end
    
    -- Bestimme die Position für die Vorschau
    local playerPed = PlayerPedId()
    local previewCoords = GetOffsetFromEntityInWorldCoords(playerPed, 0.0, Config.UI.vehiclePreviewDistance, 0.0)
    local previewHeading = GetEntityHeading(playerPed) - 180.0
    
    -- Erstelle das Fahrzeug
    local hash = GetHashKey(vehicleProps.model)
    RequestModel(hash)
    
    local attempts = 0
    while not HasModelLoaded(hash) and attempts < 50 do
        Wait(10)
        attempts = attempts + 1
    end
    
    if not HasModelLoaded(hash) then
        ShowNotification(_U('model_not_found'))
        return
    end
    
    PreviewVehicle = CreateVehicle(hash, previewCoords.x, previewCoords.y, previewCoords.z, previewHeading, false, false)
    SetEntityAsMissionEntity(PreviewVehicle, true, true)
    SetVehicleProperties(PreviewVehicle, vehicleProps)
    SetEntityAlpha(PreviewVehicle, 200, false)
    SetVehicleDoorsLocked(PreviewVehicle, 2)
    FreezeEntityPosition(PreviewVehicle, true)
    SetEntityCollision(PreviewVehicle, false, false)
    SetModelAsNoLongerNeeded(hash)
    
    -- Rotation-Effekt, wenn aktiviert
    if Config.RotateVehicle then
        CreateThread(function()
            while PreviewVehicle ~= nil do
                local heading = GetEntityHeading(PreviewVehicle)
                SetEntityHeading(PreviewVehicle, heading + 0.3)
                Wait(10)
            end
        end)
    end
end

RegisterNetEvent('garage:client:SpawnVehicle')
AddEventHandler('garage:client:SpawnVehicle', function(vehicleProps, spawnPoint, health, damages, fuel)
    local model = vehicleProps.model
    local hash = GetHashKey(model)
    
    RequestModel(hash)
    
    local attempts = 0
    while not HasModelLoaded(hash) and attempts < 50 do
        Wait(10)
        attempts = attempts + 1
    end
    
    if not HasModelLoaded(hash) then
        ShowNotification(_U('model_not_found'))
        return
    end
    
    local vehicle = CreateVehicle(hash, spawnPoint.coords.x, spawnPoint.coords.y, spawnPoint.coords.z, spawnPoint.heading, true, false)
    SetVehicleProperties(vehicle, vehicleProps)
    SetEntityAsMissionEntity(vehicle, true, true)
    
    -- Stelle Fahrzeugzustand wieder her
    if Config.RestoreVehicleDamage and health then
        SetVehicleEngineHealth(vehicle, health.engine)
        SetVehicleBodyHealth(vehicle, health.body)
        SetVehiclePetrolTankHealth(vehicle, health.tank)
    end
    
    -- Stelle Schäden wieder her
    if Config.RestoreVehicleDamage and damages then
        -- Fenster
        if damages.windows then
            for windowId, isBroken in pairs(damages.windows) do
                if isBroken then
                    SmashVehicleWindow(vehicle, windowId)
                end
            end
        end
        
        -- Türen
        if damages.doors then
            for doorId, isDamaged in pairs(damages.doors) do
                if isDamaged then
                    SetVehicleDoorBroken(vehicle, doorId, true)
                end
            end
        end
        
        -- Reifen
        if damages.tyres then
            for tyreId, isBurst in pairs(damages.tyres) do
                if isBurst then
                    SetVehicleTyreBurst(vehicle, tyreId, true, 1000.0)
                end
            end
        end
    end
    
    -- Stelle Kraftstoff wieder her
    if Config.RestoreVehicleFuel and fuel then
        -- Für ESX Legacy natives:
        SetVehicleFuelLevel(vehicle, fuel)
        
        -- Für LegacyFuel, FRFuel etc.:
        -- exports["LegacyFuel"]:SetFuel(vehicle, fuel)
    end
    
    -- Setze den Spieler in das Fahrzeug
    TaskWarpPedIntoVehicle(PlayerPedId(), vehicle, -1)
    
    -- Gib dem Spieler die Schlüssel, falls aktiviert
    if Config.UseCarKeys then
        TriggerServerEvent('garage:server:GiveKeys', vehicleProps.plate)
    end
    
    SetModelAsNoLongerNeeded(hash)
    ShowNotification(_U('vehicle_spawned'))
end)

function CloseGarageMenu()
    InGarageMenu = false
    SetNuiFocus(false, false)
    
    SendNUIMessage({
        action = "close"
    })
    
    if PreviewVehicle then
        DeleteEntity(PreviewVehicle)
        PreviewVehicle = nil
    end
    
    CurrentGarage = nil
end

-- Hilfsfunktionen
function IsNearGarage()
    return NearestGarage ~= nil and #(GetEntityCoords(PlayerPedId()) - Config.Garages[NearestGarage].menu_point.coords) < Config.Garages[NearestGarage].menu_point.radius
end

function IsSpawnPointClear(coords, radius)
    local vehicles = GetGamePool('CVehicle')
    
    for _, vehicle in ipairs(vehicles) do
        if DoesEntityExist(vehicle) then
            local vehicleCoords = GetEntityCoords(vehicle)
            local distance = #(coords - vehicleCoords)
            
            if distance < radius then
                return false
            end
        end
    end
    
    return true
end

function GetVehicleType(vehicle)
    local vehicleClass = GetVehicleClass(vehicle)
    
    -- Wandle die Fahrzeugklasse in einen Typ um
    if vehicleClass == 8 then
        return "bike"
    elseif vehicleClass == 13 then
        return "bicycle"
    elseif vehicleClass == 14 then
        return "boat"
    elseif vehicleClass == 15 or vehicleClass == 16 then
        return "helicopter"
    elseif vehicleClass == 19 then
        return "military"
    elseif vehicleClass == 21 then
        return "train"
    elseif vehicleClass == 18 then
        return "emergency"
    elseif vehicleClass == 16 then
        return "plane"
    elseif vehicleClass == 10 or vehicleClass == 11 or vehicleClass == 12 or vehicleClass == 20 then
        return "commercial"
    else
        return "car"
    end
end

function DrawText3D(x, y, z, text)
    -- Get screen coords
    local onScreen, _x, _y = World3dToScreen2d(x, y, z)
    
    if onScreen then
        -- Calculate text scale to use
        local dist = #(GetGameplayCamCoords() - vector3(x, y, z))
        local scale = (1 / dist) * 2
        local fov = (1 / GetGameplayCamFov()) * 100
        scale = scale * fov
        
        -- Format text
        SetTextScale(0.0 * scale, 0.35 * scale)
        SetTextFont(4)
        SetTextColour(255, 255, 255, 255)
        SetTextDropshadow(0, 0, 0, 0, 255)
        SetTextDropShadow()
        SetTextOutline()
        SetTextCentre(true)
        
        -- Diplay text
        SetTextEntry("STRING")
        AddTextComponentString(text)
        DrawText(_x, _y)
    end
end

function ShowNotification(msg)
    if Framework == 'ESX' then
        ESX.ShowNotification(msg)
    elseif Framework == 'QBCore' then
        QBCore.Functions.Notify(msg)
    else
        -- Fallback zu nativen Benachrichtigungen
        BeginTextCommandThefeedPost("STRING")
        AddTextComponentSubstringPlayerName(msg)
        EndTextCommandThefeedPostTicker(true, false)
    end
end

-- Fahrzeug-Eigenschafts-Funktionen
function GetVehicleProperties(vehicle)
    if DoesEntityExist(vehicle) then
        local colorPrimary, colorSecondary = GetVehicleColours(vehicle)
        local pearlescentColor, wheelColor = GetVehicleExtraColours(vehicle)
        local extras = {}
        
        for extraId = 0, 20 do
            if DoesExtraExist(vehicle, extraId) then
                extras[tostring(extraId)] = IsVehicleExtraTurnedOn(vehicle, extraId) and 1 or 0
            end
        end
        
        local liveryCount = GetVehicleLiveryCount(vehicle)
        local modLivery = GetVehicleMod(vehicle, 48)
        
        if modLivery ~= -1 and liveryCount == 0 then
            liveryCount = GetNumVehicleMods(vehicle, 48) + 1
        end
        
        local neonEnabled = {
            IsVehicleNeonLightEnabled(vehicle, 0),
            IsVehicleNeonLightEnabled(vehicle, 1),
            IsVehicleNeonLightEnabled(vehicle, 2),
            IsVehicleNeonLightEnabled(vehicle, 3)
        }
        
        local neonColor = table.pack(GetVehicleNeonLightsColour(vehicle))
        local tyreSmokeColor = table.pack(GetVehicleTyreSmokeColor(vehicle))
        local custom = {
            model = GetEntityModel(vehicle),
            plate = GetVehicleNumberPlateText(vehicle),
            plateIndex = GetVehicleNumberPlateTextIndex(vehicle),
            health = GetEntityHealth(vehicle),
            dirtLevel = GetVehicleDirtLevel(vehicle),
            color1 = colorPrimary,
            color2 = colorSecondary,
            pearlescentColor = pearlescentColor,
            wheelColor = wheelColor,
            wheels = GetVehicleWheelType(vehicle),
            windowTint = GetVehicleWindowTint(vehicle),
            neonEnabled = neonEnabled,
            neonColor = neonColor,
            tyreSmokeColor = tyreSmokeColor,
            modSpoilers = GetVehicleMod(vehicle, 0),
            modFrontBumper = GetVehicleMod(vehicle, 1),
            modRearBumper = GetVehicleMod(vehicle, 2),
            modSideSkirt = GetVehicleMod(vehicle, 3),
            modExhaust = GetVehicleMod(vehicle, 4),
            modFrame = GetVehicleMod(vehicle, 5),
            modGrille = GetVehicleMod(vehicle, 6),
            modHood = GetVehicleMod(vehicle, 7),
            modFender = GetVehicleMod(vehicle, 8),
            modRightFender = GetVehicleMod(vehicle, 9),
            modRoof = GetVehicleMod(vehicle, 10),
            modEngine = GetVehicleMod(vehicle, 11),
            modBrakes = GetVehicleMod(vehicle, 12),
            modTransmission = GetVehicleMod(vehicle, 13),
            modHorns = GetVehicleMod(vehicle, 14),
            modSuspension = GetVehicleMod(vehicle, 15),
            modArmor = GetVehicleMod(vehicle, 16),
            modNitrous = GetVehicleMod(vehicle, 17),
            modTurbo = IsToggleModOn(vehicle, 18),
            modSubwoofer = GetVehicleMod(vehicle, 19),
            modSmokeEnabled = IsToggleModOn(vehicle, 20),
            modHydraulics = IsToggleModOn(vehicle, 21),
            modXenon = IsToggleModOn(vehicle, 22),
            modFrontWheels = GetVehicleMod(vehicle, 23),
            modBackWheels = GetVehicleMod(vehicle, 24),
            modPlateHolder = GetVehicleMod(vehicle, 25),
            modVanityPlate = GetVehicleMod(vehicle, 26),
            modTrimA = GetVehicleMod(vehicle, 27),
            modOrnaments = GetVehicleMod(vehicle, 28),
            modDashboard = GetVehicleMod(vehicle, 29),
            modDial = GetVehicleMod(vehicle, 30),
            modDoorSpeaker = GetVehicleMod(vehicle, 31),
            modSeats = GetVehicleMod(vehicle, 32),
            modSteeringWheel = GetVehicleMod(vehicle, 33),
            modShifterLeavers = GetVehicleMod(vehicle, 34),
            modAPlate = GetVehicleMod(vehicle, 35),
            modSpeakers = GetVehicleMod(vehicle, 36),
            modTrunk = GetVehicleMod(vehicle, 37),
            modHydrolic = GetVehicleMod(vehicle, 38),
            modEngineBlock = GetVehicleMod(vehicle, 39),
            modAirFilter = GetVehicleMod(vehicle, 40),
            modStruts = GetVehicleMod(vehicle, 41),
            modArchCover = GetVehicleMod(vehicle, 42),
            modAerials = GetVehicleMod(vehicle, 43),
            modTrimB = GetVehicleMod(vehicle, 44),
            modTank = GetVehicleMod(vehicle, 45),
            modWindows = GetVehicleMod(vehicle, 46),
            modLivery = modLivery,
            liveryCount = liveryCount,
            modCustomTyres = GetVehicleModVariation(vehicle, 23),
            extras = extras,
            xenonColor = GetVehicleXenonLightsColour(vehicle),
            tyreSmokeR = tyreSmokeColor[1],
            tyreSmokeG = tyreSmokeColor[2],
            tyreSmokeB = tyreSmokeColor[3],
            dashboardColor = GetVehicleDashboardColor(vehicle),
            interiorColor = GetVehicleInteriorColor(vehicle),
            fuelLevel = GetVehicleFuelLevel(vehicle)
        }
        
        return custom
    else
        return {}
    end
end

function SetVehicleProperties(vehicle, props)
    if DoesEntityExist(vehicle) then
        SetVehicleModKit(vehicle, 0)
        
        if props.plate then
            SetVehicleNumberPlateText(vehicle, props.plate)
        end
        
        if props.plateIndex then
            SetVehicleNumberPlateTextIndex(vehicle, props.plateIndex)
        end
        
        if props.health then
            SetEntityHealth(vehicle, props.health)
        end
        
        if props.dirtLevel then
            SetVehicleDirtLevel(vehicle, props.dirtLevel)
        end
        
        if props.color1 then
            local color1, color2 = GetVehicleColours(vehicle)
            SetVehicleColours(vehicle, props.color1, color2)
        end
        
        if props.color2 then
            local color1, color2 = GetVehicleColours(vehicle)
            SetVehicleColours(vehicle, color1, props.color2)
        end
        
        if props.pearlescentColor then
            local pearlescentColor, wheelColor = GetVehicleExtraColours(vehicle)
            SetVehicleExtraColours(vehicle, props.pearlescentColor, wheelColor)
        end
        
        if props.wheelColor then
            local pearlescentColor, wheelColor = GetVehicleExtraColours(vehicle)
            SetVehicleExtraColours(vehicle, pearlescentColor, props.wheelColor)
        end
        
        if props.wheels then
            SetVehicleWheelType(vehicle, props.wheels)
        end
        
        if props.windowTint then
            SetVehicleWindowTint(vehicle, props.windowTint)
        end
        
        if props.neonEnabled then
            SetVehicleNeonLightEnabled(vehicle, 0, props.neonEnabled[1])
            SetVehicleNeonLightEnabled(vehicle, 1, props.neonEnabled[2])
            SetVehicleNeonLightEnabled(vehicle, 2, props.neonEnabled[3])
            SetVehicleNeonLightEnabled(vehicle, 3, props.neonEnabled[4])
        end
        
        if props.neonColor then
            SetVehicleNeonLightsColour(vehicle, props.neonColor[1], props.neonColor[2], props.neonColor[3])
        end
        
        if props.tyreSmokeColor then
            SetVehicleTyreSmokeColor(vehicle, props.tyreSmokeColor[1], props.tyreSmokeColor[2], props.tyreSmokeColor[3])
        end
        
        if props.modSpoilers then
            SetVehicleMod(vehicle, 0, props.modSpoilers, false)
        end
        
        if props.modFrontBumper then
            SetVehicleMod(vehicle, 1, props.modFrontBumper, false)
        end
        
        if props.modRearBumper then
            SetVehicleMod(vehicle, 2, props.modRearBumper, false)
        end
        
        if props.modSideSkirt then
            SetVehicleMod(vehicle, 3, props.modSideSkirt, false)
        end
        
        if props.modExhaust then
            SetVehicleMod(vehicle, 4, props.modExhaust, false)
        end
        
        if props.modFrame then
            SetVehicleMod(vehicle, 5, props.modFrame, false)
        end
        
        if props.modGrille then
            SetVehicleMod(vehicle, 6, props.modGrille, false)
        end
        
        if props.modHood then
            SetVehicleMod(vehicle, 7, props.modHood, false)
        end
        
        if props.modFender then
            SetVehicleMod(vehicle, 8, props.modFender, false)
        end
        
        if props.modRightFender then
            SetVehicleMod(vehicle, 9, props.modRightFender, false)
        end
        
        if props.modRoof then
            SetVehicleMod(vehicle, 10, props.modRoof, false)
        end
        
        if props.modEngine then
            SetVehicleMod(vehicle, 11, props.modEngine, false)
        end
        
        if props.modBrakes then
            SetVehicleMod(vehicle, 12, props.modBrakes, false)
        end
        
        if props.modTransmission then
            SetVehicleMod(vehicle, 13, props.modTransmission, false)
        end
        
        if props.modHorns then
            SetVehicleMod(vehicle, 14, props.modHorns, false)
        end
        
        if props.modSuspension then
            SetVehicleMod(vehicle, 15, props.modSuspension, false)
        end
        
        if props.modArmor then
            SetVehicleMod(vehicle, 16, props.modArmor, false)
        end
        
        if props.modNitrous then
            SetVehicleMod(vehicle, 17, props.modNitrous, false)
        end
        
        if props.modTurbo then
            ToggleVehicleMod(vehicle, 18, props.modTurbo)
        end
        
        if props.modSubwoofer then
            SetVehicleMod(vehicle, 19, props.modSubwoofer, false)
        end
        
        if props.modSmokeEnabled then
            ToggleVehicleMod(vehicle, 20, props.modSmokeEnabled)
        end
        
        if props.modHydraulics then
            ToggleVehicleMod(vehicle, 21, props.modHydraulics)
        end
        
        if props.modXenon then
            ToggleVehicleMod(vehicle, 22, props.modXenon)
        end
        
        if props.modFrontWheels then
            SetVehicleMod(vehicle, 23, props.modFrontWheels, props.modCustomTyres)
        end
        
        if props.modBackWheels then
            SetVehicleMod(vehicle, 24, props.modBackWheels, props.modCustomTyres)
        end
        
        if props.modPlateHolder then
            SetVehicleMod(vehicle, 25, props.modPlateHolder, false)
        end
        
        if props.modVanityPlate then
            SetVehicleMod(vehicle, 26, props.modVanityPlate, false)
        end
        
        if props.modTrimA then
            SetVehicleMod(vehicle, 27, props.modTrimA, false)
        end
        
        if props.modOrnaments then
            SetVehicleMod(vehicle, 28, props.modOrnaments, false)
        end
        
        if props.modDashboard then
            SetVehicleMod(vehicle, 29, props.modDashboard, false)
        end
        
        if props.modDial then
            SetVehicleMod(vehicle, 30, props.modDial, false)
        end
        
        if props.modDoorSpeaker then
            SetVehicleMod(vehicle, 31, props.modDoorSpeaker, false)
        end
        
        if props.modSeats then
            SetVehicleMod(vehicle, 32, props.modSeats, false)
        end
        
        if props.modSteeringWheel then
            SetVehicleMod(vehicle, 33, props.modSteeringWheel, false)
        end
        
        if props.modShifterLeavers then
            SetVehicleMod(vehicle, 34, props.modShifterLeavers, false)
        end
        
        if props.modAPlate then
            SetVehicleMod(vehicle, 35, props.modAPlate, false)
        end
        
        if props.modSpeakers then
            SetVehicleMod(vehicle, 36, props.modSpeakers, false)
        end
        
        if props.modTrunk then
            SetVehicleMod(vehicle, 37, props.modTrunk, false)
        end
        
        if props.modHydrolic then
            SetVehicleMod(vehicle, 38, props.modHydrolic, false)
        end
        
        if props.modEngineBlock then
            SetVehicleMod(vehicle, 39, props.modEngineBlock, false)
        end
        
        if props.modAirFilter then
            SetVehicleMod(vehicle, 40, props.modAirFilter, false)
        end
        
        if props.modStruts then
            SetVehicleMod(vehicle, 41, props.modStruts, false)
        end
        
        if props.modArchCover then
            SetVehicleMod(vehicle, 42, props.modArchCover, false)
        end
        
        if props.modAerials then
            SetVehicleMod(vehicle, 43, props.modAerials, false)
        end
        
        if props.modTrimB then
            SetVehicleMod(vehicle, 44, props.modTrimB, false)
        end
        
        if props.modTank then
            SetVehicleMod(vehicle, 45, props.modTank, false)
        end
        
        if props.modWindows then
            SetVehicleMod(vehicle, 46, props.modWindows, false)
        end
        
        if props.modLivery then
            SetVehicleMod(vehicle, 48, props.modLivery, false)
            SetVehicleLivery(vehicle, props.modLivery)
        end
        
        if props.xenonColor ~= nil then
            SetVehicleXenonLightsColour(vehicle, props.xenonColor)
        end
        
        if props.extras then
            for extraId, state in pairs(props.extras) do
                SetVehicleExtra(vehicle, tonumber(extraId), state == 0)
            end
        end
        
        if props.dashboardColor then
            SetVehicleDashboardColor(vehicle, props.dashboardColor)
        end
        
        if props.interiorColor then
            SetVehicleInteriorColor(vehicle, props.interiorColor)
        end
        
        if props.tyreSmokeR and props.tyreSmokeG and props.tyreSmokeB then
            SetVehicleTyreSmokeColor(vehicle, props.tyreSmokeR, props.tyreSmokeG, props.tyreSmokeB)
        end
        
        if props.fuelLevel then
            SetVehicleFuelLevel(vehicle, props.fuelLevel)
        end
    end
end