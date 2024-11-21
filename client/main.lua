--- @section Dependencies

--- Import utility library.
utils = exports.boii_utils:get_utils()

--- @section Constants

local RESOURCE_NAME <const> = GetCurrentResourceName()
local DUI_RANGE <const> = 1.5
local PROXIMITY_CHECK_INTERVAL <const> = 100

--- @section Tables

local dui_objects = {}
local dui_locations = {}

--- @section Variables

local in_proximity = false

--- @section Global functions

--- Send notifications.
--- @param header string: Notification header.
--- @param message string: Notification message.
--- @param type string: Notification type.
--- @param duration number: Notification duration in (ms).
function notify(header, message, type, duration)
    utils.ui.notify({ header = header, message = message, type = type, duration = duration })
end

--- @section Local Functions

--- Creates a DUI object for a specified location
--- @param location_id string: The unique ID of the location
--- @return table: A table containing the DUI object, texture dictionary name, and texture name
local function create_dui(location_id)
    local txd_name, txt_name = location_id, location_id
    local dui_url = 'https://cfx-nui-' .. RESOURCE_NAME .. '/public/index.html'
    local screen_width, screen_height = GetActiveScreenResolution()
    local dui_object = CreateDui(dui_url, screen_width, screen_height)
    CreateRuntimeTextureFromDuiHandle(CreateRuntimeTxd(txd_name), txt_name, GetDuiHandle(dui_object))
    Wait(250)
    return { dui_object = dui_object, txd_name = txd_name, txt_name = txt_name }
end

--- Toggles an entitys outline visibility
--- @param entity number: The entity ID
--- @param state boolean: Whether to enable or disable the outline
local function toggle_outline(entity, state)
    if not entity then return end
    SetEntityDrawOutline(entity, state)
    if state then
        SetEntityDrawOutlineColor(255, 255, 255, 255)
        SetEntityDrawOutlineShader(1)
    end
end

--- Adds a new zone to the DUI system
--- @param options table: A table containing zone options
local function add_zone(options)
    local invoking_resource = GetInvokingResource()
    if not invoking_resource then print('Error: Invoking resource could not be determined.') return end
    if not options.id or (not options.coords and not options.entity) or not options.header or not options.keys then print('Error: Missing required fields for zone.') return end
    dui_locations[invoking_resource] = dui_locations[invoking_resource] or {}
    dui_locations[invoking_resource][options.id] = {
        id = options.id,
        coords = options.coords,
        entity = options.entity,
        header = options.header,
        icon = options.icon,
        keys = options.keys,
        outline = options.outline or false,
        hidden = false,
        in_proximity = false,
        item = options.item,
        job = options.job
    }
end
exports('add_zone', add_zone)

--- Manages a zone's state
--- @param zone_id string: The ID of the zone
--- @param action string: The action to perform
local function manage_zone(zone_id, action)
    local location = dui_locations[zone_id]
    if not location then return end
    if action == 'remove' then
        if dui_objects[zone_id] then
            DestroyDui(dui_objects[zone_id].dui_object)
            dui_objects[zone_id] = nil
        end
        toggle_outline(location.entity, false)
        dui_locations[zone_id] = nil
        return
    end
    if action == 'hide' then
        location.hidden = true
        if dui_objects[zone_id] then
            DestroyDui(dui_objects[zone_id].dui_object)
            dui_objects[zone_id] = nil
        end
        return
    end
    if action == 'show' then
        location.hidden = false
    end
end

--- Manage a zone
--- @param zone_id string: The ID of the zone to remove
--- @param action string: The action type
exports('manage_zone', manage_zone)

--- Removes a zone
--- @param zone_id string: The ID of the zone to remove
exports('remove_zone', function(zone_id)
    manage_zone(zone_id, 'remove')
end)

--- Hides a zone
--- @param zone_id string: The ID of the zone to hide
exports('hide_zone', function(zone_id)
    manage_zone(zone_id, 'hide')
end)

--- Shows a hidden zone
--- @param zone_id string: The ID of the zone to show
exports('show_zone', function(zone_id)
    manage_zone(zone_id, 'show')
end)

--- Performs a key action for a zone
--- @param key_data table: A table containing key action data
--- @param location table: The location table containing zone information
local function perform_key_action(key_data, location)
    local action_handlers = {
        ['function'] = function(action) action() end,
        ['client'] = function(action) TriggerEvent(action) end,
        ['server'] = function(action) TriggerServerEvent(action) end,
    }
    if key_data.should_hide then manage_zone(location.id, 'hide') end
    local handler = action_handlers[key_data.action_type]
    if not handler then print('Error: Incorrect action type for key') return end
    handler(key_data.action)
end

--- Handles key presses for a specific location
--- @param location table: The location table
local function handle_key_presses(location)
    for _, key_data in ipairs(location.keys) do
        local key_lower = string.lower(key_data.key)
        local key_control = utils.keys.get_key(key_lower)
        if IsControlJustReleased(0, key_control) then
            perform_key_action(key_data, location)
        end
    end
end

--- Handles entering proximity of a zone
--- @param location table: The location table
local function enter_proximity(location)
    location.in_proximity = true
    if not dui_objects[location.id] and not location.hidden then
        dui_objects[location.id] = create_dui(location.id)
    end
    toggle_outline(location.entity, location.outline)
end

--- Handles leaving proximity of a zone
--- @param location table: The location table
local function leave_proximity(location)
    location.in_proximity = false
    manage_zone(location.id, 'show')
    toggle_outline(location.entity, false)
    if dui_objects[location.id] then
        DestroyDui(dui_objects[location.id].dui_object)
        dui_objects[location.id] = nil
    end
end

--- Checks if the player has the required job
--- @param location table: The location table
--- @param callback function: The callback function
local function check_job(location, callback)
    if location.job then
        utils.fw.player_has_job(location.job.names, location.job.on_duty or false, function(has_job)
            if has_job then
                callback(true)
            else
                callback(false)
            end
        end)
    else
        callback(true)
    end
end

--- Checks if the player has the required item
--- @param location table: The location table
--- @param callback function: The callback function
local function check_item(location, callback)
    if location.item and location.item.id then
        utils.fw.has_item(location.item.id, location.item.quantity or 1, function(has_item)
            callback(has_item)
        end)
    else
        callback(true)
    end
end

--- Checks proximity to zone
--- @param location table: The location table
--- @param distance number: The distance between the player and the zone
local function handle_proximity(location, distance)
    if distance > DUI_RANGE then
        if location.in_proximity then
            leave_proximity(location)
        end
        return
    end
    check_job(location, function(job_passed)
        if not job_passed then
            if location.in_proximity then
                leave_proximity(location)
            end
            return
        end
        check_item(location, function(item_passed)
            if item_passed and not location.in_proximity then
                enter_proximity(location)
            elseif not item_passed and location.in_proximity then
                leave_proximity(location)
            end
        end)
    end)
end

--- Renders the DUI for a zone
--- @param location table: The location table
local function handle_dui_render(location)
    if not dui_objects[location.id] or location.hidden then return end
    local dui = dui_objects[location.id]
    local player_coords = GetEntityCoords(PlayerPedId())
    SetDrawOrigin(location.coords.x, location.coords.y, player_coords.z + 0.5)
    if HasStreamedTextureDictLoaded(dui.txd_name) then
        DrawInteractiveSprite(dui.txd_name, dui.txt_name, 0, 0, 1.0, 1.0, 0.0, 255, 255, 255, 255)
    end
    SendDuiMessage(dui.dui_object, json.encode({
        action = 'show_dui',
        options = { header = location.header, icon = location.icon, keys = location.keys }
    }))
    handle_key_presses(location)
end

--- Removes all zones for a specific resource
--- @param resource_name string: The name of the resource
local function clear_zones_for_resource(resource_name)
    if dui_locations[resource_name] then
        for zone_id, _ in pairs(dui_locations[resource_name]) do
            manage_zone(zone_id, 'remove')
        end
        dui_locations[resource_name] = nil
    end
    if dui_objects[resource_name] then
        for _, dui_data in pairs(dui_objects[resource_name]) do
            DestroyDui(dui_data.dui_object)
        end
        dui_objects[resource_name] = nil
    end
end

exports('clear_zones', clear_zones_for_resource)

--- @section Threads

--- Periodically check proximity to zones
CreateThread(function()
    while true do
        Wait(PROXIMITY_CHECK_INTERVAL)
        local player_coords = GetEntityCoords(PlayerPedId())
        for resource_name, locations in pairs(dui_locations) do
            for _, location in pairs(locations) do
                local distance = #(player_coords - vector3(location.coords.x, location.coords.y, location.coords.z))
                handle_proximity(location, distance)
            end
        end
    end
end)

--- Render DUIs for zones in proximity
CreateThread(function()
    while true do
        Wait(0)
        for resource_name, locations in pairs(dui_locations) do
            for _, location in pairs(locations) do
                if location.in_proximity then
                    handle_dui_render(location)
                end
            end
        end

        ClearDrawOrigin()
    end
end)

--- @section Testing

local test_zones = {
    -- Zone 1: No job or item check
    {
        id = 'zone_no_restrictions',
        coords = vector4(300.36, -877.83, 29.24, 340.59), 
        header = 'OPEN ZONE',
        icon = 'fa-solid fa-gear',
        keys = {
            {
                key = 'e',
                label = 'Interact',
                action_type = 'function',
                action = function()
                    notify('INTERACT', 'This zone is accessible by everyone without restrictions.', 'success', 3500)
                end,
                should_hide = false
            }
        },
        outline = true
    },

    -- Zone 2: Requires a job check
    {
        id = 'zone_job_restricted',
        coords = vector4(299.45, -880.2, 29.24, 159.56),
        header = 'JOB ONLY',
        icon = 'fa-solid fa-briefcase',
        keys = {
            {
                key = 'e',
                label = 'Interact',
                action_type = 'function',
                action = function()
                    notify('INTERACT', 'This zone is accessible by players with the specified job with optional on duty check.', 'success', 3500)
                end,
                should_hide = true
            }
        },
        outline = true,
        job = {
            names = { 'police', 'sheriff' }, -- Allowed job names
            on_duty = true -- Must be on duty
        }
    },

    -- Zone 3: Requires an item check
    {
        id = 'zone_item_restricted',
        coords = vector4(298.54, -882.69, 29.24, 159.97),
        header = 'ITEM REQUIRED',
        icon = 'fa-solid fa-key',
        keys = {
            {
                key = 'e',
                label = 'Interact 1',
                action_type = 'function',
                action = function()
                    notify('INTERACT', 'This zone is accessible only if players have the required item.', 'info', 3500)
                end,
                should_hide = true
            },
            {
                key = 'h',
                label = 'Interact 2',
                action_type = 'function',
                action = function()
                    notify('INTERACT', 'This zone is accessible only if players have the required item.', 'info', 3500)
                end,
                should_hide = true
            }
        },
        outline = true,
        item = {
            id = 'lockpick', -- Required item ID
            quantity = 1 -- Required quantity
        }
    }
}

RegisterCommand('test_interact', function()
    for _, zone in ipairs(test_zones) do
        exports.boii_interact:add_zone(zone)
    end
    notify('INFO', 'Test zones have been added.', 'success', 3500)
end)
