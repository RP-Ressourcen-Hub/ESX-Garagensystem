-- Hilfsfunktionen für das Garage-System

-- Fahrzeug-Eigenschaften abrufen
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

-- Fahrzeug-Eigenschaften setzen
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

-- 3D-Text zeichnen
function DrawText3D(x, y, z, text)
    -- Screen-Koordinaten berechnen
    local onScreen, _x, _y = World3dToScreen2d(x, y, z)
    
    if onScreen then
        -- Textgröße basierend auf Entfernung berechnen
        local dist = #(GetGameplayCamCoords() - vector3(x, y, z))
        local scale = (1 / dist) * 2
        local fov = (1 / GetGameplayCamFov()) * 100
        scale = scale * fov
        
        -- Text formatieren
        SetTextScale(0.0 * scale, 0.35 * scale)
        SetTextFont(4)
        SetTextColour(255, 255, 255, 255)
        SetTextDropshadow(0, 0, 0, 0, 255)
        SetTextDropShadow()
        SetTextOutline()
        SetTextCentre(true)
        
        -- Text anzeigen
        SetTextEntry("STRING")
        AddTextComponentString(text)
        DrawText(_x, _y)
    end
end

-- Benachrichtigung anzeigen
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

-- Überprüft, ob ein Spawn-Punkt frei ist
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

-- Fahrzeugtyp ermitteln
function GetVehicleType(vehicle)
    local vehicleClass = GetVehicleClass(vehicle)
    
    -- Fahrzeugklasse in Typ umwandeln
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