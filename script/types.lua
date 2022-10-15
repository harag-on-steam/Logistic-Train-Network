
--- @alias LtnTrainId integer the LuaTrain.id of a train; also used as the id of a delivery
--- @alias LtnStopId integer the LuaEntity.unit_number of a LTN train stop
--- @alias LtnStopName string the LuaEntity.backer_name of a LTN train stop
--- @alias LtnItem string the type and name of an item joined with a comma, for example "item,wood" or "fluid,water"
--- @alias LtnItemCounts table<LtnItem, integer> mapping from item to count
--- @alias LtnNetworkId integer 
---     A bitset with 32 bits; each bit signals membership in the network corresponding to its bit-position.
---     For example, a hexadecimal value of `0x8000000A` represents membership in networks `2`, `4` and `32`.
---     Tip: Lua integers are signed numbers, so the easiest way to set all bits is to use `-1`.

--- @alias LtnErrorCode
--- | -1 # not initialized
--- | 1  # short circuit / disabled
--- | 2  # duplicate stop name

---------------------------

--- @class LtnTrainStop
---
--- stop data
--- @field active_deliveries LtnTrainId[]
--- @field entity LuaEntity
--- @field input LuaEntity
--- @field output LuaEntity
--- @field lamp_control LuaEntity
--- @field error_code LtnErrorCode
---
--- control signals
--- @field is_depot boolean
--- @field depot_priority integer
--- @field network_id LtnNetworkId
--- @field max_carriages integer
--- @field min_carriages integer
--- @field max_trains integer
--- @field providing_threshold integer
--- @field providing_threshold_stacks integer
--- @field provider_priority integer
--- @field requesting_threshold integer
--- @field requesting_threshold_stacks integer
--- @field requester_priority integer
--- @field locked_slots integer
--- @field no_warnings boolean
---
--- parked train data
--- @field parked_train LuaTrain
--- @field parked_train_id LtnTrainId
--- @field parked_train_faces_stop boolean

---------------------------

--- @class LtnSurfaceConnection 
--- @field entity1 LuaEntity
--- @field entity2 LuaEntity
--- @field network_id LtnNetworkId

---------------------------

--- @class LtnDelivery
--- @field force LuaForce
--- @field train LuaTrain
--- @field from LtnStopName
--- @field from_id LtnStopId
--- @field to LtnStopName
--- @field to_id LtnStopId
--- @field network_id LtnNetworkId
--- @field started integer
--- @field surface_connections LtnSurfaceConnection[]
--- @field shipment LtnItemCounts

---------------------------

--- @class LtnTrainInfo
--- @field capacity integer
--- @field fluid_capacity integer
--- @field force LuaForce
--- @field surface LuaSurface
--- @field depot_priority integer
--- @field network_id LtnNetworkId
--- @field train LuaTrain

---------------------------

--- @class OnStopsUpdatedEvent 
--- @field logistic_train_stops table<LtnStopId, LtnTrainStop>

---------------------------

--- @class OnDispatcherUpdatedEvent
--- @field update_interval integer time in ticks LTN needed to run all updates, varies depending on number of stops and requests
--- @field provided_by_stop table<LtnStopId, LtnItemCounts>
--- @field requests_by_stop table<LtnStopId, LtnItemCounts>
--- @field new_deliveries LtnTrainId[] references to deliveries created this dispatcher cycle
--- @field deliveries table<LtnTrainId, LtnDelivery>
--- @field available_trains table<LtnTrainId, LtnTrainInfo>

---------------------------

--- @class OnDispatcherNoTrainInDepotEvent
--- @field to LtnStopName
--- @field to_id LtnStopId
--- @field network_id LtnNetworkId
--- @field item LtnItem

--- @class OnDispatcherNoTrainMatchedEvent
--- @field to LtnStopName
--- @field to_id LtnStopId
--- @field network_id LtnNetworkId
--- @field from LtnStopName
--- @field from_id LtnStopId
--- @field min_carriages integer
--- @field max_carriages integer
--- @field shipment LtnItemCounts

--- @alias OnDispatcherNoTrainFoundEvent OnDispatcherNoTrainInDepotEvent | OnDispatcherNoTrainMatchedEvent

---------------------------

--- @class OnDeliveryPickupCompleteEvent
--- @field train_id LuaTrainId
--- @field train LuaTrain
--- @field planned_shipment LtnItemCounts
--- @field actual_shipment LtnItemCounts

---------------------------

--- @class OnDeliveryCompletedEvent
--- @field train_id LuaTrainId
--- @field train LuaTrain
--- @field shipment LtnItemCounts

---------------------------

--- @class OnDeliveryFailedEvent
--- @field train_id LuaTrainId
--- @field shipment LtnItemCounts

---------------------------

--- @class OnProviderMissingCargoEvent
--- @field train LuaTrain
--- @field station LuaEntity
--- @field planned_shipment LtnItemCounts
--- @field actual_shipment LtnItemCounts

---------------------------

--- @class OnProviderUnscheduledCargoEvent
--- @field train LuaTrain
--- @field station LuaEntity
--- @field planned_shipment LtnItemCounts
--- @field unscheduled_load LtnItemCounts

---------------------------

--- @class OnRequesterUnscheduledCargEvent
--- @field train LuaTrain
--- @field station LuaEntity
--- @field planned_shipment LtnItemCounts
--- @field unscheduled_load LtnItemCounts

---------------------------

--- @class OnRequesterRemainingCargoEvent
--- @field train LuaTrain
--- @field station LuaEntity
--- @field remaining_load LtnItemCounts

-- just to quiet some diagnostics
local function dummy() end

--- @diagnostic disable: undefined-doc-param

LtnRemoteInterface = {
    -- updates for ltn_stops

    --- @return integer event_id the id the engine generated for the event; needs to be obtained every time a game is loaded
    on_stops_updated = dummy,

    -- updates for dispatcher

    --- @return integer event_id the id the engine generated for the event; needs to be obtained every time a game is loaded
    on_dispatcher_updated = dummy,
    --- @return integer event_id the id the engine generated for the event; needs to be obtained every time a game is loaded
    on_dispatcher_no_train_found = dummy,
    --- @return integer event_id the id the engine generated for the event; needs to be obtained every time a game is loaded
    on_delivery_created = dummy,

    -- update for updated deliveries after leaving provider

    --- @return integer event_id the id the engine generated for the event; needs to be obtained every time a game is loaded
    on_delivery_pickup_complete = dummy,

    -- update for completing deliveries

    --- @return integer event_id the id the engine generated for the event; needs to be obtained every time a game is loaded
    on_delivery_completed = dummy,
    --- @return integer event_id the id the engine generated for the event; needs to be obtained every time a game is loaded
    on_delivery_failed = dummy,

    -- alerts

    --- @return integer event_id the id the engine generated for the event; needs to be obtained every time a game is loaded
    on_provider_missing_cargo = dummy,
    --- @return integer event_id the id the engine generated for the event; needs to be obtained every time a game is loaded
    on_provider_unscheduled_cargo = dummy,
    --- @return integer event_id the id the engine generated for the event; needs to be obtained every time a game is loaded
    on_requester_unscheduled_cargo = dummy,
    --- @return integer event_id the id the engine generated for the event; needs to be obtained every time a game is loaded
    on_requester_remaining_cargo = dummy,

    -- surface connections    

    --- Designates two entities on different surfaces as forming a surface connection.
    ---
    --- Connections are bi-directional but not transitive, i.e. surface A -> B implies B -> A, but A -> B and B -> C does not imply A -> C.  
    --- LTN will generate deliveries between depot and provider on one surface and requester on the other.  
    ---
    --- It is the caller's responsibility to ensure:
    --- 1. trains are moved between surfaces
    --- 2. deliveries are updated to the new train after surface transition, see reassign_delivery()
    --- 3. trains return to their original surface depot
    --- 
    --- @param entity1 LuaEntity one end of the connection
    --- @param entity2 LuaEntity the other end of the connection
    --- @param network_id LtnNetworkId acts as additional mask for potential providers. Calling this function with the same entities and a different network_id will update the connection to the new network_id.
    connect_surfaces = dummy,

    --- Removes a surface connection formed by the two given entities.  
    --- Active deliveries will not be affected.  
    --- It's not necessary to call this function when deleting one or both entities.  
    ---
    --- @param entity1 LuaEntity one end of the connection
    --- @param entity2 LuaEntity the other end of the connection
    disconnect_surfaces = dummy,

    --- Clears all surface connections.  
    --- Active deliveries will not be affected.  
    --- This function exists for debugging purposes, no event is raised to notify connection owners.
    clear_all_surface_connections = dummy,

    --- Re-assigns a delivery to a different train.
    ---
    --- Should be called after creating a train based on another train, for example after moving a train to a different surface.  
    --- It is the caller's responsibility to make sure that the new train's schedule matches the old one's before calling this function.  
    --- Otherwise LTN won't be able to add missing temporary stops for logistic stops that are now on the same surface as the train.
    ---
    --- Calls with an old_train_id without delivery have no effect.  
    --- Don't call this function when coupling trains via script, LTN already handles that through Factorio events.
    ---
    --- @param old_train_id LtnTrainId
    --- @param new_train LuaEntity
    --- @return boolean is_delivery true, if the old train actually was on a delivery that was re-assigned, false otherwise
    reassign_delivery = dummy,
}
