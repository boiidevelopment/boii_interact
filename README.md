# BOII Interact UI

![INTERACT_THUMB](https://github.com/user-attachments/assets/d8c428f3-5b69-4a2c-a0fe-78f154f6a0a8)


## Overview

BOII Interact UI is a lightweight, proximity-based interaction system using FiveM's DUI functions. 
This script allows you to define zones where players can interact with objects or locations using key presses. 
Each zone can display an interactive UI with customizable actions tied to key inputs.

Enjoy

## Features

- **Proximity-Based Interaction:** Zones become interactive when players are nearby.
- **Customizable Actions:** Assign specific actions to key presses (functions, client events, or server events).
- **Entity Highlighting:** Optionally highlight entities with outlines to make them more visually apparent.
- **Item Requirements:** Restrict zone visibility based on item possession (optional).

## 💹 Dependencies

- **[boii_utils](https://github.com/boiidevelopment/boii_utils)** - For cross framework itemv and job checks.

## How To

# Adding A Zone:
----------------

You can add a zone using the export `add_zone` an example of this is below.
```lua
exports.boii_interact:add_zone({
    id = 'vending_machine', -- Unique ID for the zone
    coords = vector4(0.0, 0.0, 0.0, 0.0), -- Coordinates
    header = 'INTERACT', -- UI Header
    icon = 'fa-solid fa-gear', -- Header Icon
    keys = { -- Keys table: You have multiple keys

        -- Key 1
        {
            key = 'e', -- Key to use; refer to KEYS at top of file
            label = 'Do Something', -- Label for the key
            action_type = 'function', -- Type of action: 'function' or 'client' / 'server' respectively for events
            action = function() -- Action function example
                notify('INTERACT', 'Doing something? Who knows its not coded yet..', 'info', 3500)
            end,
            -- action = 'boii_interact:cl:test_event', -- Example event remove the action = function above and replace action type with client/server.
            should_hide = true -- If pressing key should hide the UI or not
        }
    },
    entity = 'prop_vend_soda_02', -- Example entity: vending machine **optional**
    outline = true, -- If entity is provided and outline is true a outline will be displayed around the object
    -- item = { id = 'lockpick', quantity = 1 } -- Item required to see the zone **optional: if no item is provided zone will show**
    -- job = { -- Job/s required to see the zone **optional: if no job section is provided zone will show**
    --  names = { 'police', 'sheriff' }, -- Allowed job names
    --  on_duty = true -- Only show interaction if player is on duty
    --},
})
```
# Managing Zones:
----------------- 

You have 2 options to manage the zones;

Params: 
- ZONE_ID: The 'id' used when you `add_zone`
- ACTION: The action to perform on the zone; 'show', 'hide', 'remove'

Option 1: `manage_zone`

```lua
exports.boii_interact:manage_zone(ZONE_ID, ACTION)
```

Examples:

```lua
exports.boii_interact:manage_zone('vending_machine', 'show')
exports.boii_interact:manage_zone('vending_machine', 'hide')
exports.boii_interact:manage_zone('vending_machine', 'remove')
```

Option 2: 

`show_zone`:

```lua
exports.boii_interact:show_zone(ZONE_ID)
exports.boii_interact:show_zone('vending_machine')
```

`hide_zone`:

```lua
exports.boii_interact:hide_zone(ZONE_ID)
exports.boii_interact:hide_zone('vending_machine')
```

`remove_zone`:

```lua
exports.boii_interact:remove_zone(ZONE_ID)
exports.boii_interact:remove_zone('vending_machine')
```
