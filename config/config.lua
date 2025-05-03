Config = {}

-- Allgemeine Einstellungen
Config.Locale = 'de'
Config.UseCommand = true               -- Garage über Befehl öffnen (/garage)
Config.UseKeyMapping = true            -- Taste zum Öffnen der Garage verwenden
Config.KeyMapping = 'F6'               -- Taste zum Öffnen der Garage
Config.DrawMarker = true               -- Marker an Garagen-Punkten anzeigen
Config.MarkerType = 36                 -- Markertyp (36 = Parken)
Config.MarkerColor = {r = 0, g = 100, b = 255, a = 100} -- Markerfarbe
Config.MarkerSize = {x = 3.0, y = 3.0, z = 1.0}   -- Markergröße
Config.BlipSprite = 524                -- Blip-Symbol (524 = Garage)
Config.BlipColor = 38                  -- Blip-Farbe (38 = Blau)
Config.BlipScale = 0.8                 -- Blip-Größe
Config.VehiclePreview = true           -- Fahrzeugvorschau anzeigen
Config.RotateVehicle = true            -- Fahrzeug in der Vorschau rotieren
Config.SaveVehicleDamage = true        -- Fahrzeugschaden beim Einparken speichern
Config.SaveVehicleFuel = true          -- Kraftstoffstand beim Einparken speichern
Config.RestoreVehicleDamage = true     -- Fahrzeugschaden beim Ausparken wiederherstellen
Config.RestoreVehicleFuel = true       -- Kraftstoffstand beim Ausparken wiederherstellen
Config.AllowVehicleTransfer = true     -- Erlaubt das Übertragen von Fahrzeugen zwischen Garagen
Config.TransferFee = 1000              -- Gebühr für das Übertragen von Fahrzeugen zwischen Garagen
Config.ImpoundFee = 5000               -- Gebühr für das Auslösen aus der Beschlagnahme
Config.EnableImpound = true            -- Beschlagnahme-System aktivieren
Config.MaxVehiclesPerPlayer = 0        -- Maximale Anzahl an Fahrzeugen pro Spieler (0 = unbegrenzt)
Config.UseCarKeys = true               -- Fahrzeugschlüssel-System nutzen
Config.GenerateNewPlateOnPurchase = true -- Beim Kauf eines Fahrzeugs neues Kennzeichen generieren
Config.CustomPlateText = "FIVEM "      -- Benutzerdefinierter Kennzeichentext (+ 5 zufällige Zeichen)
Config.EnableVehicleHousing = true     -- Erlaubt das Speichern von Fahrzeugen in Eigentumswohnungen
Config.EnableVehicleTracking = true    -- Fahrzeug-Tracking aktivieren (zeigt Standort auf der Karte)
Config.EnableVehicleTuning = true      -- Fahrzeug-Tuning in der Garage speichern

-- Fahrzeugtypen
Config.VehicleTypes = {
    ["car"] = "Auto",
    ["bike"] = "Motorrad",
    ["bicycle"] = "Fahrrad",
    ["boat"] = "Boot",
    ["plane"] = "Flugzeug",
    ["helicopter"] = "Helikopter",
    ["military"] = "Militär",
    ["commercial"] = "Nutzfahrzeug",
    ["emergency"] = "Notdienste"
}

-- Fahrzeug-Klassifikationen
Config.VehicleClassifications = {
    ["personal"] = "Persönlich",     -- Privatfahrzeug
    ["job"] = "Dienstlich",          -- Jobfahrzeug
    ["gang"] = "Organisation",       -- Gangfahrzeug
    ["rented"] = "Gemietet",         -- Gemietetes Fahrzeug
    ["state"] = "Staatlich"          -- Staatsfahrzeug
}

-- Fahrzeugstatus
Config.VehicleStatuses = {
    ["stored"] = {label = "In Garage", color = "#28a745"},      -- Fahrzeug ist in der Garage
    ["out"] = {label = "Ausgeparkt", color = "#dc3545"},        -- Fahrzeug ist ausgeparkt
    ["impounded"] = {label = "Beschlagnahmt", color = "#ffc107"} -- Fahrzeug wurde beschlagnahmt
}

-- Garagen Konfiguration
Config.Garages = {
    -- Stadt-Garagen
    ["legion_square"] = {
        label = "Legion Square Garage",
        type = "public",                                     -- public, job, gang
        allowed_jobs = {},                                   -- Nur für bestimmte Jobs (leer = für alle)
        allowed_gangs = {},                                  -- Nur für bestimmte Gangs (leer = für alle)
        allowed_vehicles = {"car", "bike", "bicycle"},       -- Erlaubte Fahrzeugtypen
        max_slots = 0,                                       -- Maximale Stellplätze (0 = unbegrenzt)
        blip = true,                                         -- Blip auf der Karte anzeigen
        spawn_points = {                                     -- Spawn-Punkte für Fahrzeuge
            {
                coords = vector3(215.55, -810.21, 30.73),
                heading = 339.27,
                radius = 6.0                                 -- Radius um zu prüfen, ob Spawn-Punkt frei ist
            },
            {
                coords = vector3(224.63, -806.11, 30.56),
                heading = 339.96,
                radius = 6.0
            },
            {
                coords = vector3(233.44, -801.74, 30.55),
                heading = 341.65,
                radius = 6.0
            }
        },
        parking_point = {                                    -- Punkt zum Einparken von Fahrzeugen
            coords = vector3(230.78, -797.45, 30.58),
            radius = 15.0                                    -- Radius um Fahrzeuge zu erkennen
        },
        menu_point = {                                       -- Punkt zum Öffnen des Garagenmenüs
            coords = vector3(230.78, -797.45, 30.58),
            radius = 3.0                                     -- Interaktionsradius
        }
    },
    
    ["pink_cage"] = {
        label = "Pink Cage Garage",
        type = "public",
        allowed_jobs = {},
        allowed_gangs = {},
        allowed_vehicles = {"car", "bike", "bicycle"},
        max_slots = 0,
        blip = true,
        spawn_points = {
            {
                coords = vector3(290.96, -339.36, 44.92),
                heading = 249.14,
                radius = 6.0
            },
            {
                coords = vector3(298.95, -333.39, 44.92),
                heading = 249.35,
                radius = 6.0
            }
        },
        parking_point = {
            coords = vector3(294.85, -336.21, 44.92),
            radius = 15.0
        },
        menu_point = {
            coords = vector3(294.85, -336.21, 44.92),
            radius = 3.0
        }
    },
    
    ["vinewood_boulevard"] = {
        label = "Vinewood Boulevard Garage",
        type = "public",
        allowed_jobs = {},
        allowed_gangs = {},
        allowed_vehicles = {"car", "bike", "bicycle"},
        max_slots = 0,
        blip = true,
        spawn_points = {
            {
                coords = vector3(638.15, 206.61, 97.16),
                heading = 68.72,
                radius = 6.0
            },
            {
                coords = vector3(621.50, 193.97, 97.16),
                heading = 70.18,
                radius = 6.0
            }
        },
        parking_point = {
            coords = vector3(629.23, 201.48, 97.10),
            radius = 15.0
        },
        menu_point = {
            coords = vector3(629.23, 201.48, 97.10),
            radius = 3.0
        }
    },
    
    -- Job Garagen
    ["police_garage"] = {
        label = "Police Garage",
        type = "job",
        allowed_jobs = {"police", "sheriff"},
        allowed_gangs = {},
        allowed_vehicles = {"car", "bike", "bicycle", "helicopter"},
        max_slots = 0,
        blip = false,
        spawn_points = {
            {
                coords = vector3(454.62, -1017.37, 28.45),
                heading = 92.39,
                radius = 6.0
            },
            {
                coords = vector3(454.29, -1024.72, 28.47),
                heading = 92.27,
                radius = 6.0
            }
        },
        parking_point = {
            coords = vector3(458.79, -1019.78, 28.29),
            radius = 15.0
        },
        menu_point = {
            coords = vector3(458.79, -1019.78, 28.29),
            radius = 3.0
        }
    },
    
    ["ambulance_garage"] = {
        label = "EMS Garage",
        type = "job",
        allowed_jobs = {"ambulance"},
        allowed_gangs = {},
        allowed_vehicles = {"car", "bike", "helicopter"},
        max_slots = 0,
        blip = false,
        spawn_points = {
            {
                coords = vector3(297.96, -598.28, 43.30),
                heading = 337.70,
                radius = 6.0
            },
            {
                coords = vector3(293.60, -599.58, 43.29),
                heading = 337.97,
                radius = 6.0
            }
        },
        parking_point = {
            coords = vector3(295.65, -601.90, 43.26),
            radius = 15.0
        },
        menu_point = {
            coords = vector3(295.65, -601.90, 43.26),
            radius = 3.0
        }
    },
    
    -- Boot-Garagen
    ["la_puerta_marina"] = {
        label = "La Puerta Marina",
        type = "public",
        allowed_jobs = {},
        allowed_gangs = {},
        allowed_vehicles = {"boat"},
        max_slots = 0,
        blip = true,
        spawn_points = {
            {
                coords = vector3(-802.82, -1406.93, 1.52),
                heading = 230.36,
                radius = 10.0
            },
            {
                coords = vector3(-793.76, -1416.18, 1.59),
                heading = 230.13,
                radius = 10.0
            }
        },
        parking_point = {
            coords = vector3(-798.36, -1412.34, 1.59),
            radius = 20.0
        },
        menu_point = {
            coords = vector3(-797.91, -1417.47, 5.0),
            radius = 5.0
        }
    },
    
    -- Flugzeug-Garagen
    ["lsia_hangar"] = {
        label = "LSIA Hangar",
        type = "public",
        allowed_jobs = {},
        allowed_gangs = {},
        allowed_vehicles = {"plane"},
        max_slots = 0,
        blip = true,
        spawn_points = {
            {
                coords = vector3(-1274.49, -3385.18, 13.94),
                heading = 329.89,
                radius = 15.0
            }
        },
        parking_point = {
            coords = vector3(-1285.03, -3372.15, 13.94),
            radius = 30.0
        },
        menu_point = {
            coords = vector3(-1285.03, -3372.15, 13.94),
            radius = 5.0
        }
    },
    
    -- Helikopter-Garagen
    ["vespucci_helipad"] = {
        label = "Vespucci Helipad",
        type = "public",
        allowed_jobs = {},
        allowed_gangs = {},
        allowed_vehicles = {"helicopter"},
        max_slots = 0,
        blip = true,
        spawn_points = {
            {
                coords = vector3(-736.62, -1456.96, 5.00),
                heading = 49.56,
                radius = 10.0
            }
        },
        parking_point = {
            coords = vector3(-736.62, -1456.96, 5.00),
            radius = 15.0
        },
        menu_point = {
            coords = vector3(-745.73, -1468.68, 5.00),
            radius = 5.0
        }
    },
    
    -- Beschlagnahme
    ["davis_impound"] = {
        label = "Davis Impound",
        type = "impound",
        allowed_jobs = {},
        allowed_gangs = {},
        allowed_vehicles = {"car", "bike", "bicycle"},
        max_slots = 0,
        blip = true,
        spawn_points = {
            {
                coords = vector3(409.14, -1623.39, 29.29),
                heading = 229.21,
                radius = 6.0
            },
            {
                coords = vector3(407.30, -1647.11, 29.29),
                heading = 228.73,
                radius = 6.0
            }
        },
        parking_point = {
            coords = vector3(402.44, -1631.55, 29.29),
            radius = 15.0
        },
        menu_point = {
            coords = vector3(408.98, -1637.08, 29.29),
            radius = 3.0
        }
    }
}

-- Fahrzeugkategorien (für UI-Filter)
Config.VehicleCategories = {
    ["compacts"] = "Kompaktwagen",
    ["sedans"] = "Limousinen",
    ["suvs"] = "SUVs",
    ["coupes"] = "Coupés",
    ["muscle"] = "Muscle Cars",
    ["sportsclassics"] = "Klassische Sportwagen",
    ["sports"] = "Sportwagen",
    ["super"] = "Supersportwagen",
    ["motorcycles"] = "Motorräder",
    ["offroad"] = "Geländewagen",
    ["industrial"] = "Industriefahrzeuge",
    ["utility"] = "Nutzfahrzeuge",
    ["vans"] = "Transporter",
    ["cycles"] = "Fahrräder",
    ["boats"] = "Boote",
    ["helicopters"] = "Helikopter",
    ["planes"] = "Flugzeuge",
    ["service"] = "Servicefahrzeuge",
    ["emergency"] = "Notfallfahrzeuge",
    ["military"] = "Militärfahrzeuge",
    ["commercial"] = "Handelsfahrzeuge",
    ["trains"] = "Züge"
}

-- UI Konfiguration
Config.UI = {
    title = "FAHRZEUG-GARAGE",
    logo = "img/logo.png",
    defaultCategory = "all",
    showVehicleStats = true,
    showVehicleMods = true,
    darkMode = true,
    animations = true,
    transitionSpeed = 0.3,
    vehiclePreviewDistance = 5.0,
    maxVehiclesPerPage = 16
}