function playerConfig(playername)
    return global.brave_new_world.players[playername]
end

function forceConfig(forcename)
    return global.brave_new_world.forces[forcename]
end

script.on_event(defines.events.on_player_created, function(event)
    -- TODO: setup player & force config properly
    if not global.brave_new_world then
        global.brave_new_world = {
            players = {},
            forces = {}
        }
    end
    local player = game.players[event.player_index]
    if not global.brave_new_world.players[player.name] then
        global.brave_new_world.players[player.name] = {
            remove_entities = {}
        }
    end
    local force = player.force
    if not global.brave_new_world.forces[force.name] then
        global.brave_new_world.forces[force.name] = {}
    end
    local character = player.character
    player.character = nil
    if character then
        character.destroy()
    end
    player.force.manual_mining_speed_modifier = -0.99999999 -- allows removing ghosts with right-click
    player.force.manual_crafting_speed_modifier = -1
    player.insert{name = "deconstruction-planner", count = 1}

    -- setup exploration boundary
    forceConfig(force.name).explore_boundary = {{-64, -64}, {64, 64}} -- TODO: depends on player/force location, this won't work for multiforce games (with different locations)
    force.chart(player.surface, {{-160, -160}, {160, 160}})

    -- build initial structures
    local x = -14 -- leftmost structure coordinate
    local y = -9 -- topmost structure coordinate
    local surface = player.surface
    -- place dirt beneath structures
    local tiles = {}
    for xx = x, x + 27 do
        for yy = y, y + 12 do
            table.insert(tiles, {name = "grass-dry", position = {xx, yy}})
        end
    end
    surface.set_tiles(tiles)
    -- remove trees/stones
    local entities = surface.find_entities_filtered{area = {{x - 2, y - 2}, {x + 29, y + 14}}, force = "neutral"}
    for _, entity in pairs(entities) do
        entity.destroy()
    end
    -- place walls
    for xx = x + 11, x + 16 do
        surface.create_entity{name = "stone-wall", position = {xx, y + 2}, force = force}
        surface.create_entity{name = "stone-wall", position = {xx, y + 10}, force = force}
    end
    for yy = y + 2, y + 10 do
        surface.create_entity{name = "stone-wall", position = {x + 11, yy}, force = force}
        surface.create_entity{name = "stone-wall", position = {x + 16, yy}, force = force}
    end
    -- roboport
    local roboport = surface.create_entity{name = "roboport", position = {x + 14, y + 5}, force = force}
    roboport.minable = false
    local roboport_inventory = roboport.get_inventory(defines.inventory.roboport_robot)
    roboport_inventory.insert{name = "construction-robot", count = 50}
    roboport_inventory.insert{name = "logistic-robot", count = 50}
    roboport_inventory = roboport.get_inventory(defines.inventory.roboport_material)
    roboport_inventory.insert{name = "repair-pack", count = 10}
    -- radar
    local radar = surface.create_entity{name = "radar", position = {x + 13, y + 8}, force = force}
    radar.minable = false
    -- electric pole
    local electric_pole = surface.create_entity{name = "medium-electric-pole", position = {x + 15, y + 7}, force = force}
    electric_pole.minable = false
    -- chests
    local chest = surface.create_entity{name = "logistic-chest-storage", position = {x + 15, y + 8}, force = force}
    chest.minable = false
    local chest_inventory = chest.get_inventory(defines.inventory.chest)
    chest_inventory.insert{name = "iron-plate", count = 800}
    chest_inventory.insert{name = "copper-plate", count = 800}
    chest_inventory.insert{name = "coal", count = 200}
    chest_inventory.insert{name = "stone", count = 50}
    chest_inventory.insert{name = "transport-belt", count = 250}
    chest_inventory.insert{name = "underground-belt", count = 20}
    chest_inventory.insert{name = "splitter", count = 20}
    chest_inventory.insert{name = "medium-electric-pole", count = 50}
    chest_inventory.insert{name = "inserter", count = 20}
    chest_inventory.insert{name = "offshore-pump", count = 2}
    chest_inventory.insert{name = "pipe", count = 50}
    chest_inventory.insert{name = "boiler", count = 3}
    chest_inventory.insert{name = "steam-engine", count = 2}
    chest_inventory.insert{name = "assembling-machine-1", count = 4}
    chest_inventory.insert{name = "electric-mining-drill", count = 4}
    chest_inventory.insert{name = "stone-furnace", count = 4}
    chest_inventory.insert{name = "roboport", count = 4}
    chest_inventory.insert{name = "logistic-chest-storage", count = 4}
    chest_inventory.insert{name = "logistic-chest-passive-provider", count = 4}
    chest_inventory.insert{name = "logistic-chest-requester", count = 4}
    chest_inventory.insert{name = "lab", count = 2}
    chest = surface.create_entity{name = "logistic-chest-storage", position = {x + 15, y + 9}, force = force}
    chest.minable = false
    -- solar panels and accumulators (left side)
    surface.create_entity{name = "solar-panel", position = {x + 3, y + 3}, force = force}
    surface.create_entity{name = "solar-panel", position = {x + 3, y + 6}, force = force}
    surface.create_entity{name = "solar-panel", position = {x + 3, y + 9}, force = force}
    surface.create_entity{name = "solar-panel", position = {x + 6, y + 9}, force = force}
    surface.create_entity{name = "solar-panel", position = {x + 9, y + 3}, force = force}
    surface.create_entity{name = "solar-panel", position = {x + 9, y + 9}, force = force}
    surface.create_entity{name = "medium-electric-pole", position = {x + 7, y + 5}, force = force}
    surface.create_entity{name = "accumulator", position = {x + 6, y + 3}, force = force}
    surface.create_entity{name = "accumulator", position = {x + 6, y + 5}, force = force}
    surface.create_entity{name = "accumulator", position = {x + 6, y + 7}, force = force}
    surface.create_entity{name = "accumulator", position = {x + 8, y + 7}, force = force}
    surface.create_entity{name = "accumulator", position = {x + 10, y + 7}, force = force}
    -- solar panels and accumulators (right side)
    surface.create_entity{name = "solar-panel", position = {x + 18, y + 3}, force = force}
    surface.create_entity{name = "solar-panel", position = {x + 18, y + 9}, force = force}
    surface.create_entity{name = "solar-panel", position = {x + 21, y + 9}, force = force}
    surface.create_entity{name = "solar-panel", position = {x + 24, y + 3}, force = force}
    surface.create_entity{name = "solar-panel", position = {x + 24, y + 6}, force = force}
    surface.create_entity{name = "solar-panel", position = {x + 24, y + 9}, force = force}
    surface.create_entity{name = "medium-electric-pole", position = {x + 20, y + 5}, force = force}
    surface.create_entity{name = "accumulator", position = {x + 18, y + 7}, force = force}
    surface.create_entity{name = "accumulator", position = {x + 20, y + 7}, force = force}
    surface.create_entity{name = "accumulator", position = {x + 22, y + 3}, force = force}
    surface.create_entity{name = "accumulator", position = {x + 22, y + 5}, force = force}
    surface.create_entity{name = "accumulator", position = {x + 22, y + 7}, force = force}
end)

script.on_event(defines.events.on_put_item, function(event)
    local player = game.players[event.player_index]
    if not player.cursor_stack.valid_for_read or player.cursor_stack.name == "blueprint" then
        return
    end
    playerConfig(player.name).cursor_stack = {name = player.cursor_stack.name, count = player.cursor_stack.count}
end)

script.on_event(defines.events.on_built_entity, function(event)
    local entity = event.created_entity
    if entity.name == "entity-ghost" then
        return
    end
    if entity.name == "straight-rail" or entity.name == "curved-rail" then
        -- rail laying is a bit annoying. ghosting won't work, so just allow it
        return
    end
    local player = game.players[event.player_index]
    local config = playerConfig(player.name)
    local surface = entity.surface
    local force = entity.force
    local position = entity.position
    local area = {{position.x - 0.5, position.y - 0.5}, {position.x + 0.5, position.y + 0.5}}
    player.cursor_stack.set_stack{name = "blueprint", count = 1}
    player.cursor_stack.create_blueprint{surface = entity.surface, force = force, area = area}
    if player.cursor_stack.get_blueprint_entities() then
        entity.order_deconstruction(force)
        player.cursor_stack.build_blueprint{surface = surface, force = force, position = position}
        local ghost_entity = surface.find_entity("entity-ghost", position)
        if ghost_entity then
            config.remove_entities[game.tick + 120] = entity
            entity.minable = false
            entity.operable = false
        else
            -- can't place ghost beneath some entities for some reason (rails, offshore pumps (sometimes)). we'll have to allow placing those :(
            entity.cancel_deconstruction(force)
            if config.cursor_stack then
                config.cursor_stack.count = config.cursor_stack.count - 1
                if config.cursor_stack.count <= 0 then
                    config.cursor_stack = nil
                end
            end
        end
    end
    player.cursor_stack.set_stack(config.cursor_stack)
    config.cursor_stack = nil
end)

function inventoryChanged(event)
    local player = game.players[event.player_index]
    -- player is only allowed to carry 1 of each item that can be placed as entity
    -- everything else goes into entity opened or entity beneath mouse cursor
    -- if no opened entity nor entity beneath mouse cursor, drop on ground
    -- exceptions:
    -- red, green and copper wires (need those for circuitry)
    -- deconstruction planner, blueprints and blueprint book
    -- locomotive, wagons?
    -- modules?
    -- upgrade builder?
    local entity = player.opened or player.selected
    local inventory = player.get_inventory(defines.inventory.god_main).get_contents()
    for name, count in pairs(player.get_inventory(defines.inventory.god_quickbar).get_contents()) do
        inventory[name] = inventory[name] and (inventory[name] + count) or count
    end
    for name, count in pairs(inventory) do
        local to_remove = count - itemCountAllowed(name, count)
        if to_remove > 0 then
            local inserted = entity and entity.insert{name = name, count = to_remove} or 0
            if to_remove - inserted > 0 then
                -- TODO: some message about carrying items isn't allowed
                player.surface.spill_item_stack(entity and entity.position or player.position, {name = name, count = to_remove - inserted})
            end
            player.remove_item{name = name, count = to_remove}
        end
    end
end

function itemCountAllowed(name, count)
    if name == "red-wire" or name == "green-wire" or name == "copper-cable" then
        -- need these for circuitry
        return count
    elseif name == "blueprint" or name == "deconstruction-planner" or name == "blueprint-book" then
        -- these only place ghosts
        return count
    elseif name == "diesel-locomotive" or name == "cargo-wagon" or name == "rail" then
        -- locomotives and wagons must be placed manually
        -- also allowing rails due to issue with placing rail ghosts beneath deconstructed rails
        return count
    elseif string.match(name, ".*module.*") then
        -- allow modules
        return count
    elseif game.item_prototypes[name].place_result then
        -- allow player to keep one of items that place entities
        return 1
    end
    return 0
end

script.on_event(defines.events.on_player_main_inventory_changed, inventoryChanged)
script.on_event(defines.events.on_player_quickbar_inventory_changed, inventoryChanged)
script.on_event(defines.events.on_player_cursor_stack_changed, function(event)
    local player = game.players[event.player_index]
    local cursor = player.cursor_stack
    if cursor and cursor.valid_for_read then
        local count_remaining = itemCountAllowed(cursor.name, cursor.count)
        local to_remove = cursor.count - count_remaining
        if to_remove > 0 then
            local entity = player.opened or player.selected
            local inserted = entity and entity.insert{name = cursor.name, count = to_remove} or 0
            if to_remove - inserted > 0 then
                -- TODO: some message about carrying items isn't allowed
                player.surface.spill_item_stack(entity and entity.position or player.position, {name = cursor.name, count = to_remove - inserted})
            end
            if count_remaining > 0 then
                cursor.count = count_remaining
            else
                cursor.clear()
            end
        end
    end
end)

script.on_event(defines.events.on_entity_died, function(event)
    local entity = event.entity
    if entity.force.name == "enemy" then
        -- spawn alien artifact
        entity.surface.spill_item_stack(entity.position, {name = "alien-artifact", count = 1})
    end
end)

script.on_event(defines.events.on_sector_scanned, function(event)
    local position = event.chunk_position
    local radar = event.radar
    local force_config = forceConfig(radar.force.name)
    local x = ((position.x <= 0 and (position.x + 4)) or (position.x > 0 and (position.x - 4))) * 32
    local y = ((position.y <= 0 and (position.y + 4)) or (position.y > 0 and (position.y - 4))) * 32
    if x < force_config.explore_boundary[1][1] then
        force_config.explore_boundary[1][1] = x
    elseif x > force_config.explore_boundary[2][1] then
        force_config.explore_boundary[2][1] = x
    end
    if y < force_config.explore_boundary[1][2] then
        force_config.explore_boundary[1][2] = y
    elseif y > force_config.explore_boundary[2][2] then
        force_config.explore_boundary[2][2] = y
    end
end)

script.on_event(defines.events.on_tick, function(event)
    for _, player in pairs(game.players) do
        local force_config = forceConfig(player.force.name)
        -- prevent player from exploring
        local teleport = player.position
        if teleport.x < force_config.explore_boundary[1][1] then
            teleport.x = force_config.explore_boundary[1][1]
        elseif teleport.x > force_config.explore_boundary[2][1] then
            teleport.x = force_config.explore_boundary[2][1]
        end
        if teleport.y < force_config.explore_boundary[1][2] then
            teleport.y = force_config.explore_boundary[1][2]
        elseif teleport.y > force_config.explore_boundary[2][2] then
            teleport.y = force_config.explore_boundary[2][2]
        end
        player.teleport(teleport)

        -- remove player placed entities (this is a "hack" to make placing eg. power poles less aggravating, can't hold down button and move for placing ghosts)
        local player_config = playerConfig(player.name)
        local remove_entity = player_config.remove_entities[game.tick]
        if remove_entity then
            if remove_entity.valid then
                remove_entity.destroy()
            end
            player_config.remove_entities[game.tick] = nil
        end
    end
end)
