// Advanced Garage System - UI Code
let currentVehicles = [];
let selectedVehicle = null;
let garageConfig = {};
let currentGarage = "";
let garageType = "public";
let vehicleCategories = {};
let vehicleTypes = {};
let vehicleClassifications = {};
let vehicleStatuses = {};

// Main UI functions
function initializeUI() {
    // Set up buttons
    document.getElementById('btn-close').addEventListener('click', closeUI);
    document.getElementById('btn-preview').addEventListener('click', previewVehicle);
    document.getElementById('btn-spawn').addEventListener('click', spawnVehicle);
    document.getElementById('btn-transfer').addEventListener('click', showTransferModal);
    document.getElementById('btn-impound').addEventListener('click', showImpoundModal);
    document.getElementById('confirm-transfer').addEventListener('click', transferVehicle);
    document.getElementById('confirm-impound').addEventListener('click', releaseFromImpound);
    
    // Category buttons
    const categoryButtons = document.querySelectorAll('.category-buttons .btn');
    categoryButtons.forEach(button => {
        button.addEventListener('click', function() {
            const category = this.getAttribute('data-category');
            setCategoryActive(category);
            filterVehicles(category);
        });
    });
    
    // Set default transfer fee text
    document.getElementById('transfer-fee').textContent = `$${formatNumber(1000)}`;
    document.getElementById('impound-fee').textContent = `$${formatNumber(5000)}`;
}

function openUI(data) {
    // Save config data
    garageConfig = data.config;
    currentGarage = data.garage;
    garageType = data.garageType;
    vehicleCategories = data.config.vehicleCategories;
    vehicleTypes = data.config.vehicleTypes;
    vehicleClassifications = data.config.vehicleClassifications;
    vehicleStatuses = data.config.statuses;
    
    // Update UI elements
    document.getElementById('garage-title').textContent = data.config.title;
    document.getElementById('garage-name').textContent = data.garage;
    
    if (data.config.logo) {
        document.getElementById('garage-logo').src = data.config.logo;
    }
    
    // Apply dark/light mode
    if (data.config.darkMode) {
        document.body.classList.add('bg-dark');
        document.body.classList.add('text-white');
    } else {
        document.body.classList.remove('bg-dark');
        document.body.classList.remove('text-white');
    }
    
    // Show/hide vehicle stats
    const vehicleStats = document.querySelector('.vehicle-stats');
    if (data.config.showVehicleStats) {
        vehicleStats.style.display = 'block';
    } else {
        vehicleStats.style.display = 'none';
    }
    
    // Show/hide vehicle mods
    const vehicleMods = document.querySelector('.vehicle-mods');
    if (data.config.showVehicleMods) {
        vehicleMods.style.display = 'block';
    } else {
        vehicleMods.style.display = 'none';
    }
    
    // Show the UI container
    const container = document.getElementById('garage-container');
    container.style.display = 'block';
    setTimeout(() => {
        container.classList.add('active');
    }, 10);
    
    // Set default active category
    setCategoryActive(data.config.defaultCategory || 'all');
    
    // Show transfer fee
    document.getElementById('transfer-fee').textContent = `$${formatNumber(1000)}`;
    
    // Show/hide transfer button based on garage type
    const transferContainer = document.querySelector('.btn-transfer-container');
    const impoundContainer = document.querySelector('.btn-impound-container');
    
    if (garageType === 'impound') {
        transferContainer.style.display = 'none';
        impoundContainer.style.display = 'block';
    } else {
        transferContainer.style.display = 'block';
        impoundContainer.style.display = 'none';
    }
}

function closeUI() {
    const container = document.getElementById('garage-container');
    container.classList.remove('active');
    
    setTimeout(() => {
        container.style.display = 'none';
        
        // Reset data
        currentVehicles = [];
        selectedVehicle = null;
        
        // Clear vehicles grid
        document.getElementById('vehicles-grid').innerHTML = '';
        
        // Hide vehicle details
        document.querySelector('.vehicle-details').style.display = 'none';
        document.querySelector('.no-vehicle-selected').style.display = 'flex';
        
        // Send NUI message to close
        sendMessage('closeMenu', {});
    }, 300);
}

function setVehicles(vehicles) {
    // Save vehicles data
    currentVehicles = vehicles;
    
    // Get active category
    const activeCategory = document.querySelector('.category-buttons .btn.active');
    const category = activeCategory ? activeCategory.getAttribute('data-category') : 'all';
    
    // Filter and display vehicles
    filterVehicles(category);
}

function filterVehicles(category) {
    // Clear vehicles grid
    const vehiclesGrid = document.getElementById('vehicles-grid');
    vehiclesGrid.innerHTML = '';
    
    // Filter vehicles by category
    let filteredVehicles;
    
    if (category === 'all') {
        filteredVehicles = currentVehicles;
    } else {
        filteredVehicles = currentVehicles.filter(vehicle => {
            switch (category) {
                case 'cars':
                    return vehicle.type === 'car';
                case 'bikes':
                    return vehicle.type === 'bike' || vehicle.type === 'bicycle';
                case 'boats':
                    return vehicle.type === 'boat';
                case 'planes':
                    return vehicle.type === 'plane';
                case 'helicopters':
                    return vehicle.type === 'helicopter';
                default:
                    return true;
            }
        });
    }
    
    // Create vehicle cards
    filteredVehicles.forEach(vehicle => {
        // Create vehicle card HTML
        const vehicleCard = document.createElement('div');
        vehicleCard.className = 'col-md-3 col-sm-6 col-6';
        vehicleCard.innerHTML = `
            <div class="vehicle-card" data-plate="${vehicle.plate}">
                <div class="vehicle-image">
                    <!-- Using icon instead of image -->
                    <div class="vehicle-icon">
                        <i class="${getVehicleIcon(vehicle.type)}"></i>
                    </div>
                    <div class="vehicle-status-badge" style="background-color: ${vehicleStatuses[vehicle.status]?.color || '#777'}">
                        ${vehicleStatuses[vehicle.status]?.label || vehicle.status}
                    </div>
                </div>
                <div class="vehicle-info">
                    <div class="vehicle-name">${vehicle.name}</div>
                    <div class="vehicle-plate">${vehicle.plate}</div>
                </div>
            </div>
        `;
        
        vehiclesGrid.appendChild(vehicleCard);
        
        // Add click event to vehicle card
        const card = vehicleCard.querySelector('.vehicle-card');
        card.addEventListener('click', () => selectVehicle(vehicle));
    });
    
    // Show "no vehicles" message if no vehicles are found
    if (filteredVehicles.length === 0) {
        vehiclesGrid.innerHTML = `
            <div class="col-12 text-center mt-5">
                <i class="fas fa-car fa-3x mb-3" style="opacity: 0.5;"></i>
                <h4>Keine Fahrzeuge gefunden</h4>
                <p>In dieser Kategorie sind keine Fahrzeuge verfügbar.</p>
            </div>
        `;
    }
}

function selectVehicle(vehicle) {
    // Save selected vehicle
    selectedVehicle = vehicle;
    
    // Update vehicle details UI
    document.getElementById('selected-vehicle-name').textContent = vehicle.name;
    document.getElementById('vehicle-plate').textContent = vehicle.plate;
    
    // Set vehicle status
    const statusElement = document.getElementById('vehicle-status');
    statusElement.textContent = vehicleStatuses[vehicle.status]?.label || vehicle.status;
    statusElement.className = 'badge';
    statusElement.style.backgroundColor = vehicleStatuses[vehicle.status]?.color || '#777';
    
    // Update vehicle stats
    if (vehicle.fuel !== undefined) {
        document.getElementById('fuel-level').style.width = `${vehicle.fuel}%`;
    }
    
    if (vehicle.health) {
        const engineHealth = (vehicle.health.engine / 1000) * 100;
        const bodyHealth = (vehicle.health.body / 1000) * 100;
        
        document.getElementById('engine-health').style.width = `${engineHealth}%`;
        document.getElementById('body-health').style.width = `${bodyHealth}%`;
        
        // Change color based on health level
        if (engineHealth < 30) {
            document.getElementById('engine-health').className = 'progress-bar bg-danger';
        } else if (engineHealth < 70) {
            document.getElementById('engine-health').className = 'progress-bar bg-warning';
        } else {
            document.getElementById('engine-health').className = 'progress-bar bg-success';
        }
        
        if (bodyHealth < 30) {
            document.getElementById('body-health').className = 'progress-bar bg-danger';
        } else if (bodyHealth < 70) {
            document.getElementById('body-health').className = 'progress-bar bg-warning';
        } else {
            document.getElementById('body-health').className = 'progress-bar bg-success';
        }
    }
    
    // Update vehicle mods list
    const modList = document.getElementById('mod-list');
    modList.innerHTML = '';
    
    if (vehicle.props) {
        // Engine
        if (vehicle.props.modEngine !== undefined && vehicle.props.modEngine !== -1) {
            const modItem = document.createElement('div');
            modItem.className = 'mod-item';
            modItem.innerHTML = `<i class="fas fa-tachometer-alt"></i> Motor: <span class="mod-value">Level ${vehicle.props.modEngine + 1}</span>`;
            modList.appendChild(modItem);
        }
        
        // Brakes
        if (vehicle.props.modBrakes !== undefined && vehicle.props.modBrakes !== -1) {
            const modItem = document.createElement('div');
            modItem.className = 'mod-item';
            modItem.innerHTML = `<i class="fas fa-cogs"></i> Bremsen: <span class="mod-value">Level ${vehicle.props.modBrakes + 1}</span>`;
            modList.appendChild(modItem);
        }
        
        // Transmission
        if (vehicle.props.modTransmission !== undefined && vehicle.props.modTransmission !== -1) {
            const modItem = document.createElement('div');
            modItem.className = 'mod-item';
            modItem.innerHTML = `<i class="fas fa-cog"></i> Getriebe: <span class="mod-value">Level ${vehicle.props.modTransmission + 1}</span>`;
            modList.appendChild(modItem);
        }
        
        // Suspension
        if (vehicle.props.modSuspension !== undefined && vehicle.props.modSuspension !== -1) {
            const modItem = document.createElement('div');
            modItem.className = 'mod-item';
            modItem.innerHTML = `<i class="fas fa-car-side"></i> Fahrwerk: <span class="mod-value">Level ${vehicle.props.modSuspension + 1}</span>`;
            modList.appendChild(modItem);
        }
        
        // Armor
        if (vehicle.props.modArmor !== undefined && vehicle.props.modArmor !== -1) {
            const modItem = document.createElement('div');
            modItem.className = 'mod-item';
            modItem.innerHTML = `<i class="fas fa-shield-alt"></i> Panzerung: <span class="mod-value">Level ${vehicle.props.modArmor + 1}</span>`;
            modList.appendChild(modItem);
        }
        
        // Turbo
        if (vehicle.props.modTurbo) {
            const modItem = document.createElement('div');
            modItem.className = 'mod-item';
            modItem.innerHTML = `<i class="fas fa-bolt"></i> Turbo: <span class="mod-value">Installiert</span>`;
            modList.appendChild(modItem);
        }
        
        // Xenon Headlights
        if (vehicle.props.modXenon) {
            const modItem = document.createElement('div');
            modItem.className = 'mod-item';
            modItem.innerHTML = `<i class="fas fa-lightbulb"></i> Xenon-Scheinwerfer: <span class="mod-value">Installiert</span>`;
            modList.appendChild(modItem);
        }
    }
    
    // Show "no mods" message if no mods are found
    if (modList.childElementCount === 0) {
        modList.innerHTML = `<div class="text-center text-muted">Keine Modifikationen vorhanden</div>`;
    }
    
    // Highlight selected vehicle card
    const vehicleCards = document.querySelectorAll('.vehicle-card');
    vehicleCards.forEach(card => {
        if (card.getAttribute('data-plate') === vehicle.plate) {
            card.classList.add('selected');
        } else {
            card.classList.remove('selected');
        }
    });
    
    // Update button states based on vehicle status
    const previewButton = document.getElementById('btn-preview');
    const spawnButton = document.getElementById('btn-spawn');
    const transferButton = document.getElementById('btn-transfer');
    const impoundButton = document.getElementById('btn-impound');
    
    // Enable/disable buttons based on vehicle status
    if (vehicle.status === 'stored') {
        previewButton.disabled = false;
        spawnButton.disabled = false;
        transferButton.disabled = false;
        impoundButton.disabled = true;
    } else if (vehicle.status === 'out') {
        previewButton.disabled = true;
        spawnButton.disabled = true;
        transferButton.disabled = true;
        impoundButton.disabled = true;
    } else if (vehicle.status === 'impounded') {
        previewButton.disabled = true;
        spawnButton.disabled = true;
        transferButton.disabled = true;
        impoundButton.disabled = false;
    }
    
    // Hide vehicle details if current garage is impound but vehicle is not impounded
    if (garageType === 'impound' && vehicle.status !== 'impounded') {
        impoundButton.disabled = true;
    }
    
    // Show vehicle details
    document.querySelector('.vehicle-details').style.display = 'block';
    document.querySelector('.no-vehicle-selected').style.display = 'none';
}

function previewVehicle() {
    if (!selectedVehicle) return;
    
    // Send preview request to game
    sendMessage('previewVehicle', {props: selectedVehicle.props});
}

function spawnVehicle() {
    if (!selectedVehicle) return;
    
    // Send spawn request to game
    sendMessage('spawnVehicle', {plate: selectedVehicle.plate});
}

function showTransferModal() {
    if (!selectedVehicle) return;
    
    // Get available garages
    sendMessage('getGarages', {vehicleType: selectedVehicle.type}, (data) => {
        // Populate garage select
        const garageSelect = document.getElementById('garage-select');
        garageSelect.innerHTML = '';
        
        data.garages.forEach(garage => {
            const option = document.createElement('option');
            option.value = garage.id;
            option.textContent = garage.name;
            garageSelect.appendChild(option);
        });
        
        // Show modal
        const modal = new bootstrap.Modal(document.getElementById('transferModal'));
        modal.show();
    });
}

function transferVehicle() {
    if (!selectedVehicle) return;
    
    const targetGarage = document.getElementById('garage-select').value;
    
    // Send transfer request to game
    sendMessage('transferVehicle', {
        plate: selectedVehicle.plate,
        targetGarage: targetGarage
    }, (response) => {
        // Close modal
        const modal = bootstrap.Modal.getInstance(document.getElementById('transferModal'));
        modal.hide();
        
        if (response.status) {
            // Remove vehicle from list
            const index = currentVehicles.findIndex(v => v.plate === selectedVehicle.plate);
            if (index !== -1) {
                currentVehicles.splice(index, 1);
                
                // Get active category
                const activeCategory = document.querySelector('.category-buttons .btn.active');
                const category = activeCategory ? activeCategory.getAttribute('data-category') : 'all';
                
                // Update UI
                filterVehicles(category);
                
                // Reset selection
                document.querySelector('.vehicle-details').style.display = 'none';
                document.querySelector('.no-vehicle-selected').style.display = 'flex';
                selectedVehicle = null;
            }
        }
    });
}

function showImpoundModal() {
    if (!selectedVehicle || selectedVehicle.status !== 'impounded') return;
    
    // Show modal
    const modal = new bootstrap.Modal(document.getElementById('impoundModal'));
    modal.show();
}

function releaseFromImpound() {
    if (!selectedVehicle) return;
    
    // Send impound release request to game
    sendMessage('payImpound', {
        plate: selectedVehicle.plate
    }, (response) => {
        // Close modal
        const modal = bootstrap.Modal.getInstance(document.getElementById('impoundModal'));
        modal.hide();
        
        if (response.status) {
            // Remove vehicle from list
            const index = currentVehicles.findIndex(v => v.plate === selectedVehicle.plate);
            if (index !== -1) {
                currentVehicles.splice(index, 1);
                
                // Get active category
                const activeCategory = document.querySelector('.category-buttons .btn.active');
                const category = activeCategory ? activeCategory.getAttribute('data-category') : 'all';
                
                // Update UI
                filterVehicles(category);
                
                // Reset selection
                document.querySelector('.vehicle-details').style.display = 'none';
                document.querySelector('.no-vehicle-selected').style.display = 'flex';
                selectedVehicle = null;
            }
        }
    });
}

// Helper functions
function setCategoryActive(category) {
    const buttons = document.querySelectorAll('.category-buttons .btn');
    buttons.forEach(button => {
        if (button.getAttribute('data-category') === category) {
            button.classList.add('active');
            button.classList.remove('btn-outline-secondary');
            button.classList.add('btn-secondary');
        } else {
            button.classList.remove('active');
            button.classList.add('btn-outline-secondary');
            button.classList.remove('btn-secondary');
        }
    });
}

function getVehicleIcon(type) {
    switch (type) {
        case 'car':
            return 'fas fa-car';
        case 'bike':
            return 'fas fa-motorcycle';
        case 'bicycle':
            return 'fas fa-bicycle';
        case 'boat':
            return 'fas fa-ship';
        case 'plane':
            return 'fas fa-plane';
        case 'helicopter':
            return 'fas fa-helicopter';
        case 'military':
            return 'fas fa-fighter-jet';
        case 'commercial':
            return 'fas fa-truck';
        default:
            return 'fas fa-car';
    }
}

function formatNumber(num) {
    return num.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ",");
}

// NUI Message Handler
function sendMessage(action, data = {}, cb = () => {}) {
    fetch(`https://${GetParentResourceName()}/${action}`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json; charset=UTF-8',
        },
        body: JSON.stringify(data)
    })
    .then(resp => resp.json())
    .then(resp => cb(resp))
    .catch(err => {
        console.error(`Error in sendMessage: ${err}`);
        cb({status: false, error: err});
    });
}

// NUI Event Listeners
window.addEventListener('message', (event) => {
    const data = event.data;
    
    switch (data.action) {
        case 'open':
            openUI(data);
            break;
        case 'close':
            closeUI();
            break;
        case 'setVehicles':
            setVehicles(data.vehicles);
            break;
        default:
            console.log(`Unknown action: ${data.action}`);
            break;
    }
});

// Close UI on escape key
document.addEventListener('keydown', function(event) {
    if (event.key === 'Escape') {
        closeUI();
    }
});

// Initialize on document ready
document.addEventListener('DOMContentLoaded', initializeUI);