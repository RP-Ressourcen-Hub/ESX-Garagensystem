# 🚗 Advanced Garage System

Ein fortschrittliches Garagensystem für FiveM-Server, das vollständig mit ESX und QBCore kompatibel ist. Dieses System bietet eine umfassende Verwaltung aller Fahrzeugtypen (Autos, Motorräder, Boote, Flugzeuge, Helikopter) mit einer modernen und benutzerfreundlichen Oberfläche.

## 📋 Features

### Umfassendes Garagen-Management
- Vollständige Unterstützung aller Fahrzeugtypen in separaten Garagen
- Automatische Erkennung und Klassifizierung von Fahrzeugen
- Beschlagnahmungssystem mit Auslösegebühren
- Fahrzeugtransfer zwischen verschiedenen Garagen
- Job-spezifische Garagen mit Berechtigungsprüfung
- Gang/Organisations-Garagen mit Mitgliedsprüfung

### Erweiterte Fahrzeug-Verwaltung
- Speichern und Wiederherstellen des Fahrzeugzustands (Schäden, Kraftstoff)
- Detaillierte Fahrzeugstatistiken und Modifikationsanzeige
- Fahrzeugvorschau vor dem Ausparken
- Integrierter Fahrzeugschlüssel-Support
- Parkplatzbelegungsprüfung beim Ausparken

### Moderne Benutzeroberfläche
- Responsive und intuitive UI mit modernem Design
- Fahrzeugkategorien für einfache Filterung
- Detaillierte Fahrzeuginformationen und Statistiken
- Status-basierte Farbkodierung für schnelle Orientierung
- Vollständig animierte UI-Elemente für bessere Benutzererfahrung

## ⚙️ Installation

1. Kopiere den Ordner `[garage]` in dein `/resources/[esx]`-Verzeichnis
2. Füge `ensure [esx]/[garage]` zu deiner `server.cfg` hinzu
3. Importiere die SQL-Datei `garage.sql` in deine Datenbank (falls du spezielle Tabellen benötigst)
4. Konfiguriere die Einstellungen in `config/config.lua` nach deinen Bedürfnissen
5. Starte deinen Server neu

## 🔧 Konfiguration

Das System bietet umfangreiche Konfigurationsmöglichkeiten in der `config/config.lua`:

### Grundlegende Einstellungen
```lua
Config.Locale = 'de' -- Spracheinstellung
Config.UseCommand = true -- Garage über Befehl öffnen (/garage)
Config.KeyMapping = 'F6' -- Taste zum Öffnen der Garage
Config.DrawMarker = true -- Marker an Garagen-Punkten anzeigen
```

### Garage-Definitionen
```lua
Config.Garages = {
    ["legion_square"] = {
        label = "Legion Square Garage",
        type = "public", -- public, job, gang, impound
        allowed_jobs = {}, -- Nur für bestimmte Jobs
        allowed_gangs = {}, -- Nur für bestimmte Gangs
        allowed_vehicles = {"car", "bike", "bicycle"}, -- Erlaubte Fahrzeugtypen
        blip = true, -- Blip auf der Karte anzeigen
        -- Spawn-Punkte, Park-Punkte und Menü-Punkte...
    }
}
```

## 📊 Datenbankstruktur

Die Garage nutzt die folgenden Tabellen:

### ESX Framework
- `owned_vehicles`: Enthält die Fahrzeugdaten mit zusätzlichen Feldern für Garage-Status

### QBCore Framework
- `player_vehicles`: Enthält die Fahrzeugdaten mit zusätzlichen Feldern für Garage-Status

## 🔌 Exports und Trigger Events

### Client-Exports
```lua
-- Überprüft, ob ein Fahrzeug in einer bestimmten Garage ist
exports['esx_garage']:IsVehicleInGarage(plate, garageName)

-- Öffnet das Garagenmenü an einem bestimmten Ort
exports['esx_garage']:OpenGarageMenu(garageName)
```

### Server-Exports
```lua
-- Speichert ein Fahrzeug in einer Garage
exports['esx_garage']:StoreVehicle(source, plate, garageName)

-- Lässt ein Fahrzeug aus der Beschlagnahme frei
exports['esx_garage']:ReleaseVehicleFromImpound(source, plate)
```

### Trigger Events (Client)
```lua
-- Fahrzeug in einer Garage speichern
TriggerEvent('garage:storeVehicle', garageName)

-- Garagenmenü öffnen
TriggerEvent('garage:openMenu', garageName)
```

### Trigger Events (Server)
```lua
-- Fahrzeug in einer Garage speichern
TriggerServerEvent('garage:server:SaveVehicle', garageName, plate, props, health, damages, fuel)

-- Fahrzeug aus einer Garage nehmen
TriggerServerEvent('garage:server:SpawnVehicle', plate, garageName, spawnPoint)
```

## 📝 Hinweise

- Für eine vollständige Kompatibilität mit dem Framework, verwende die Standardmethoden zum Speichern von Fahrzeugen
- Nutze die Exports und Events, um das Garagensystem in andere Ressourcen zu integrieren
- Das System unterstützt erweiterte Fahrzeugdaten, wie Tuning, Schäden und Kraftstoff

## 📌 Support und Updates

Wir bieten regelmäßige Updates und Support für dieses System an. Bei Fragen, Problemen oder Verbesserungsvorschlägen stehen wir dir gerne zur Verfügung.

---

© 2025 Dein Server Name. Alle Rechte vorbehalten.