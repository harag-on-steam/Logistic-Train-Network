-- removes all data about surface connections; connection owners won't be notified
function ClearAllSurfaceConnections()
  global.ConnectedSurfaces = {}
  for _, delivery in pairs(global.Dispatcher.Deliveries) do
    delivery.surface_connections = {}
  end
end

local function is_connection_valid(connection)
  local e1 = connection.entity1
  local e2 = connection.entity2
  return e1 and e2 and e1.valid and e2.valid
end

function CleanupSurfaceConnections()
  for surfacePair, connections in pairs(global.ConnectedSurfaces) do
    for entityPair, connection in pairs(connections) do
      if not is_connection_valid(connection) then
        if debug_log then log(string.format("removing invalid connection %s between surfaces %s", entityPair, surfacePair)) end
        connections[entityPair] = nil
      end
    end

    if not next(connections) then
      global.ConnectedSurfaces[surfacePair] = nil
    end
  end

  for delivery_id, delivery in pairs(global.Dispatcher.Deliveries) do
    if delivery.surface_connections then
      for i = #delivery.surface_connections, 1, -1 do
        local connection = delivery.surface_connections[i]
        if not is_connection_valid(connection) then
          if debug_log then log(string.format("Removing invalid surface connection from delivery %d", delivery_id)) end
          table.remove(delivery.surface_connections, i)
        end
      end
    end
  end

  global.connectionCleanupRequired = false
end

-- returns the string "number1|number2" in consistent order: the smaller number is always placed first
local function sorted_pair(number1, number2)
  return (number1 < number2) and (number1..'|'..number2) or (number2..'|'..number1)
end

-- removes the surface connection between the given entities from global.SurfaceConnections. Does nothing if the connection doesn't exist.
function DisconnectSurfaces(entity1, entity2)
  -- ensure received data is valid and usable
  if not( entity1 and entity1.valid and entity1.surface and entity1.surface.index and game.surfaces[entity1.surface.index] ) then
    if debug_log then log("(DisconnectSurfaces) Recieved entity1 was invalid.") end
    return
  end
  if not( entity2 and entity2.valid and entity2.surface and entity2.surface.index and game.surfaces[entity2.surface.index] ) then
    if debug_log then log("(DisconnectSurfaces) Recieved entity2 was invalid.") end
    return
  end

  local surface_pair_key = sorted_pair(entity1.surface.index, entity2.surface.index)
  local surface_connections = global.ConnectedSurfaces[surface_pair_key]

  if surface_connections then
    local entity_pair_key = sorted_pair(entity1.unit_number, entity2.unit_number)
    if debug_log then log("removing surface connection for entities "..entity_pair_key.." between surfaces "..surface_pair_key) end
    surface_connections[entity_pair_key] = nil
  end

  -- same consistent order as in ConnectSurfaces
  if entity1.unit_number > entity2.unit_number then
    entity1, entity2 = entity2, entity1
  end

  -- cleaning up deliveries is important because they are transported via events. 
  -- Factorio silently drops events that reference invalid entities.
  for delivery_id, delivery in pairs(global.Dispatcher.Deliveries) do
    if delivery.surface_connections then
      for i = #delivery.surface_connections, 1, -1 do
        local connection = delivery.surface_connections[i]
        local e1 = connection.entity1
        local e2 = connection.entity2
        if (not (e1 and e2 and e1.valid and e2.valid)) or (e1 == entity1 and e2 == entity2) then
          if debug_log then log(string.format("Removing surface connection from delivery %d", delivery_id)) end
          table.remove(delivery.surface_connections, i)
        end
      end
    end
  end
end

-- adds a surface connection between the given entities; the network_id will be used in delivery processing to discard providers that don't match the surface connection's network_id
function ConnectSurfaces(entity1, entity2, network_id)
  -- ensure received data is valid and usable
  if not( entity1 and entity1.valid and entity1.surface and entity1.surface.index and game.surfaces[entity1.surface.index] ) then
    if debug_log then log("(ConnectSurfaces) Recieved entity1 was invalid.") end
    return
  end
  if not( entity2 and entity2.valid and entity2.surface and entity2.surface.index and game.surfaces[entity2.surface.index] ) then
    if debug_log then log("(ConnectSurfaces) Recieved entity2 was invalid.") end
    return
  end
  if not( network_id and tonumber(network_id, 10) ) then
    if debug_log then log("(ConnectSurfaces) Recieved network_id was no valid integer.") end
    return
  end

  if entity1.surface == entity2.surface then
    if debug_log then
      log(format("(ConnectSurfaces) Entities [%d] and [%d] are on the same surface %s [%d].",
      entity1.unit_number,
      entity2.unit_number,
      entity1.surface.name,
      entity1.surface.index))
    end
    return
  end

  local surface_pair_key = sorted_pair(entity1.surface.index, entity2.surface.index)
  local surface_connections = Get_Or_Create(global.ConnectedSurfaces, surface_pair_key)

  local entity_pair_key = sorted_pair(entity1.unit_number, entity2.unit_number)
  if debug_log then
    log(format("(ConnectSurfaces) Creating surface connection between [%d] on %s [%d] and [%d] on %s [%d].",
    entity1.unit_number,
    entity1.surface.name,
    entity1.surface.index,
    entity2.unit_number,
    entity2.surface.name,
    entity2.surface.index))
  end
  surface_connections[entity_pair_key] = {
    -- enforce a consistent order for repeated calls with the same two entities
    entity1 = entity1.unit_number <= entity2.unit_number and entity1 or entity2,
    entity2 = entity1.unit_number > entity2.unit_number and entity1 or entity2,
    network_id = network_id,
  }
end

-- remove entity references when deleting surfaces
function OnSurfaceRemoved(event)
  -- stop references
  local surfaceID = event.surface_index
  log(format("Removing LTN stops and surface connections on surface [%d].", surfaceID) )
  local surface = game.surfaces[surfaceID]
  if surface then
    local train_stops = surface.find_entities_filtered{type = "train-stop"}
    for _, entity in pairs(train_stops) do
      if ltn_stop_entity_names[entity.name] then
        RemoveStop(entity.unit_number)
      end
    end
  end

  -- surface connections; surface_index will either be the first half of the key or the second
  local first_surface = "^"..surfaceID.."|"
  local second_surface = "|"..surfaceID.."$"

  for surface_pair_key, _ in pairs(global.ConnectedSurfaces) do
    if string.find(surface_pair_key, first_surface) or string.find(surface_pair_key, second_surface) then
      global.ConnectedSurfaces[surface_pair_key] = nil
    end
  end
end