
local print_debug = function(text, ...)
	text = string.format("(GameInfo) %s", tostring(text))
	WolfgangHUD:print_log(text, ...)
end

if string.lower(RequiredScript) == "lib/setups/setup" then

	local init_managers_original = Setup.init_managers

	function Setup:init_managers(managers, ...)
		managers.gameinfo = managers.gameinfo or GameInfoManager:new()
		return init_managers_original(self, managers, ...)
	end

	GameInfoManager = GameInfoManager or class()

	GameInfoManager._INTERACTIONS = {
		INTERACTION_TO_CALLBACK = {

			-- valuables
			consumable_mission =				"_pickup_interaction_handler", -- outlaw raid documents
			regular_cache_box =					"_pickup_interaction_handler", -- gold cache
			hold_take_loot =					"_pickup_interaction_handler", -- loot
			press_take_loot =					"_pickup_interaction_handler", -- loot
			hold_take_dogtags =					"_pickup_interaction_handler", -- dogtags
			press_take_dogtags =				"_pickup_interaction_handler", -- dogtags

			-- mission pickups
			take_sps_briefcase =				"_pickup_interaction_handler", -- briefcase
			take_code_book =					"_pickup_interaction_handler", -- code book
			gen_pku_crowbar =					"_pickup_interaction_handler", -- crowbar
			dynamite_x1_pku =					"_pickup_interaction_handler", -- dynamite
			dynamite_x4_pku =					"_pickup_interaction_handler", -- dynamite
			dynamite_x5_pku =					"_pickup_interaction_handler", -- dynamite
			take_dynamite_bag =					"_pickup_interaction_handler", -- dynamite_bag
			hold_take_canister =				"_pickup_interaction_handler", -- fuel canister
			press_take_canister =				"_pickup_interaction_handler", -- fuel canister
			take_enigma =						"_pickup_interaction_handler", -- code device
			hold_take_gas_can =					"_pickup_interaction_handler", -- gas can
			press_take_gas_can =				"_pickup_interaction_handler", -- gas can
			take_gas_tank =						"_pickup_interaction_handler", -- gas tank
			mine_pku =							"_pickup_interaction_handler", -- mine
			take_portable_radio =				"_pickup_interaction_handler", -- portable radio
			take_tools =						"_pickup_interaction_handler", -- repair tools
			take_safe_key =						"_pickup_interaction_handler", -- key
			take_safe_keychain =				"_pickup_interaction_handler", -- keychain
			take_tank_grenade =					"_pickup_interaction_handler", -- tank grenade
			take_tank_shell =					"_pickup_interaction_handler", -- tank shell
			take_thermite =						"_pickup_interaction_handler", -- thermite
			gen_pku_thermite =					"_pickup_interaction_handler", -- thermite
			hold_pku_intelligence =				"_pickup_interaction_handler", -- mission documents
			open_crate_3 =						"_pickup_interaction_handler", -- crowbar crate

			-- combat pickups
			health_bag =						"_pickup_interaction_handler", -- health bag
			health_bag_big =					"_pickup_interaction_handler", -- health bag
			health_bag_small =					"_pickup_interaction_handler", -- health bag
			ammo_bag =							"_pickup_interaction_handler", -- ammo bag
			ammo_bag_big =						"_pickup_interaction_handler", -- ammo bag
			ammo_bag_small =					"_pickup_interaction_handler", -- ammo bag
			grenade_crate =						"_pickup_interaction_handler", -- grenade crate
			grenade_crate_big =					"_pickup_interaction_handler", -- grenade crate
			grenade_crate_small =				"_pickup_interaction_handler", -- grenade crate

			-- flares
			extinguish_flare =					"_pickup_interaction_handler", -- spotter flares

			-- NOT USED
			--[[
			anwser_radio =						"_pickup_interaction_handler", -- mission radio (not a typo)
			close_cargo_door =					"_pickup_interaction_handler", -- cargo door
			close_container =					"_pickup_interaction_handler", -- container
			crane_joystick_release =			"_pickup_interaction_handler", -- crane
			destroy_valve =						"_pickup_interaction_handler", -- valve
			driving_drive =						"_pickup_interaction_handler", -- car
			hold_connect_cable =				"_pickup_interaction_handler",
			hold_contact_mrs_white =			"_pickup_interaction_handler",
			hold_fill_canister =				"_pickup_interaction_handler", -- fill canister
			hold_ignite_flag =					"_pickup_interaction_handler",
			hold_open_barrier =					"_pickup_interaction_handler",
			hold_open_crate_tut =				"_pickup_interaction_handler",
			hold_open_hatch =					"_pickup_interaction_handler", -- open door hatch
			hold_place_canister =				"_pickup_interaction_handler", -- place canister
			hold_place_codemachine =			"_pickup_interaction_handler",
			hold_pull_lever =					"_pickup_interaction_handler", -- mission lever
			hold_remove_latch =					"_pickup_interaction_handler", -- mission latch
			hold_take_empty_canister =			"_pickup_interaction_handler", -- canister
			press_take_empty_canister =			"_pickup_interaction_handler", -- canister
			hold_take_recording_device =		"_pickup_interaction_handler", -- recording device
			press_take_recording_device =		"_pickup_interaction_handler", -- recording device
			hold_start_plane =					"_pickup_interaction_handler", -- plane propeller
			hold_unlock_bank_door =				"_pickup_interaction_handler", -- lockpick: bank door
			lift_trap_door =					"_pickup_interaction_handler",
			load_shell =						"_pickup_interaction_handler", -- load flak
			lockpick_cargo_door =				"_pickup_interaction_handler", -- lockpick: cargo door
			main_menu_select_interaction =		"_pickup_interaction_handler", -- camp tables
			move_crane =						"_pickup_interaction_handler", -- crane
			open_army_crate =					"_pickup_interaction_handler", -- crowbar crate
			open_cargo_door =					"_pickup_interaction_handler", -- cargo door
			open_crate_2 =						"_pickup_interaction_handler", -- crate
			open_door =							"_pickup_interaction_handler", -- cargo door
			open_drop_pod =						"_pickup_interaction_handler", -- airdrop
			open_fusebox =						"_pickup_interaction_handler",
			open_hatch =						"_pickup_interaction_handler", -- hatch
			open_truck_trunk =					"_pickup_interaction_handler", -- truck trunk
			piano_key_instant_01 =				"_pickup_interaction_handler", -- camp: piano
			piano_key_instant_02 =				"_pickup_interaction_handler", -- camp: piano
			piano_key_instant_03 =				"_pickup_interaction_handler", -- camp: piano
			piano_key_instant_04 =				"_pickup_interaction_handler", -- camp: piano
			plant_dynamite =					"_pickup_interaction_handler", -- dynamite bag
			plant_dynamite_bag =				"_pickup_interaction_handler", -- dynamite bag
			revive =							"_pickup_interaction_handler", -- downed teammates
			set_fire_barrel =					"_pickup_interaction_handler",
			set_up_radio =						"_pickup_interaction_handler", -- mission radio
			shut_off_valve =					"_pickup_interaction_handler", -- valve
			sii_lockpick_easy =					"_pickup_interaction_handler", -- lockpick crate/door
			sii_lockpick_easy_y_direction =		"_pickup_interaction_handler", -- lockpick crate/door
			sii_lockpick_medium =				"_pickup_interaction_handler", -- lockpick crate/door
			sii_lockpick_medium_y_direction =	"_pickup_interaction_handler", -- lockpick crate/door
			sii_lockpick_hard =					"_pickup_interaction_handler", -- lockpick crate/door
			sii_lockpick_hard_y_direction =		"_pickup_interaction_handler", -- lockpick crate/door
			sii_tune_radio =					"_pickup_interaction_handler", -- mission radio
			take_flak_shell =					"_pickup_interaction_handler", -- flak shell
			temp_interact_box =					"_pickup_interaction_handler",
			train_yard_open_door =				"_pickup_interaction_handler",
			tune_radio =						"_pickup_interaction_handler", -- mission radio
			turn_on_valve =						"_pickup_interaction_handler", -- valve
			turn_searchlight =					"_pickup_interaction_handler",
			turret_m2 =							"_pickup_interaction_handler", -- turret
			turret_flak_88 =					"_pickup_interaction_handler", -- turret
			turret_flakvierling =				"_pickup_interaction_handler", -- turret
			use_flare =							"_pickup_interaction_handler",
			wake_up_spy =						"_pickup_interaction_handler", -- spy mission
			]]
		},
		INTERACTION_TO_CARRY = {
			corpse_dispose =					"corpse_body", -- fresh corpse
		},
		COMPOSITE_LOOT_UNITS = {
			[3141918] = 4, [3141917] = 3, [3141916] = 2, --[3141932] = 1, -- Kelly vault gold
			[3141938] = 4, [3141937] = 3, [3141933] = 2, --[3141919] = 1, -- Kelly vault gold
			[3141942] = 4, [3141941] = 3, [3141940] = 2, --[3141939] = 1, -- Kelly vault gold
			[3141946] = 4, [3141945] = 3, [3141944] = 2, --[3141943] = 1, -- Kelly vault gold
			[3141950] = 4, [3141949] = 3, [3141948] = 2, --[3141947] = 1, -- Kelly vault gold
			[3141954] = 4, [3141953] = 3, [3141952] = 2, --[3141951] = 1, -- Kelly vault gold
			[3141958] = 4, [3141957] = 3, [3141956] = 2, --[3141955] = 1, -- Kelly vault gold
			[3141962] = 4, [3141961] = 3, [3141960] = 2, --[3141959] = 1, -- Kelly vault gold
		},
	}

	function GameInfoManager:init()
		self._t = 0
		self._scheduled_callbacks = {}
		self._listeners = {}

		self._units = {}
		self._unit_count = {}
		self._loot = {}
		self._pickups = {}
	end

	function GameInfoManager:event(source, ...)
		local target = "_" .. source .. "_event"

		if self[target] then
			self[target](self, ...)
		else
			print_debug("No event handler for %s", target, "error")
		end
	end

	function GameInfoManager:register_listener(listener_id, source_type, event, clbk, keys, data_only)
		local listener_keys

		if keys then
			listener_keys = {}
			for _, key in ipairs(keys) do
				listener_keys[key] = true
			end
		end

		self._listeners[source_type] = self._listeners[source_type] or {}
		self._listeners[source_type][event] = self._listeners[source_type][event] or {}
		self._listeners[source_type][event][listener_id] = {clbk = clbk, keys = listener_keys, data_only = data_only}
	end

	function GameInfoManager:unregister_listener(listener_id, source_type, event)
		if self._listeners[source_type] then
			if self._listeners[source_type][event] then
				self._listeners[source_type][event][listener_id] = nil
			end
		end
	end

	function GameInfoManager:_listener_callback(source, event, key, ...)
		for listener_id, data in pairs(self._listeners[source] and self._listeners[source][event] or {}) do
			if not data.keys or data.keys[key] then
				if data.data_only then
					data.clbk(...)
				else
					data.clbk(event, key, ...)
				end
			end
		end
	end

	-- UNIT

	function GameInfoManager:_unit_event(event, key, data)
		if event == "add" then
			if not self._units[key] then
				local unit_type = data.unit:base()._tweak_table
				self._units[key] = {unit = data.unit, type = unit_type}
				self:_listener_callback("unit", event, key, self._units[key])
				self:_unit_count_event("change", unit_type, 1)
			end
		elseif event == "remove" then
			if self._units[key] then
				self:_listener_callback("unit", event, key, self._units[key])
				self:_unit_count_event("change", self._units[key].type, -1)
				self._units[key] = nil
			end
		end
	end

	function GameInfoManager:_unit_count_event(event, unit_type, value)
		if event == "change" then
			if value ~= 0 then
				self._unit_count[unit_type] = (self._unit_count[unit_type] or 0) + value
				self:_listener_callback("unit_count", "change", unit_type, value)
			end
		elseif event == "set" then
			self:_unit_count_event("change", unit_type, value - (self._unit_count[unit_type] or 0))
		end
	end

	function GameInfoManager:get_units(key)
		if key then
			return self._units[key]
		else
			return self._units
		end
	end

	function GameInfoManager:get_unit_count(id)
		if id then
			return self._unit_count[id] or 0
		else
			return self._unit_count
		end
	end

	-- INTERACTIVE UNIT

	function GameInfoManager:_interactive_unit_event(event, key, data)
		local lookup = GameInfoManager._INTERACTIONS
		local interact_clbk = lookup.INTERACTION_TO_CALLBACK[data.interact_id]
		if interact_clbk then
			self[interact_clbk](self, event, key, data)
		else
			local carry_id = data.unit:carry_data() and data.unit:carry_data():carry_id() or lookup.INTERACTION_TO_CARRY[data.interact_id] or (self._loot[key] and self._loot[key].carry_id)
			self._logged_combos = self._logged_combos or {}
			if carry_id then
				if not self._logged_combos[data.interact_id .. "_" .. carry_id] then
					print_debug("carry interaction! interact_id: %s - carry_id: %s", data.interact_id, carry_id, "info")
					self._logged_combos[data.interact_id .. "_" .. carry_id] = true
				end
				data.carry_id = carry_id
				self:_loot_interaction_handler(event, key, data)
			else
				if not self._logged_combos[data.interact_id] then
					print_debug("interactable unit! interact_id: %s", data.interact_id, "info")
					self._logged_combos[data.interact_id] = true
				end
				self:_listener_callback("interactable_unit", event, key, data.unit, data.interact_id, carry_id)
			end
		end
	end

	function GameInfoManager:_pickup_interaction_handler(event, key, data)
		if event == "add" then
			if not self._pickups[key] then
				self._pickups[key] = {unit = data.unit, interact_id = data.interact_id, value = 1}
				if WolfgangHUD:getSetting({"HUDList", "use_dogtag_values"}, true) and data.unit.loot_drop and data.unit:loot_drop() then
					self._pickups[key].value = data.unit:loot_drop():value()
				end
				self:_listener_callback("pickup", "add", key, self._pickups[key])
				self:_pickup_count_event("change", data.interact_id, self._pickups[key].value, self._pickups[key])
			end
		elseif event == "remove" then
			if self._pickups[key] then
				self:_listener_callback("pickup", "remove", key, self._pickups[key])
				self:_pickup_count_event("change", data.interact_id, -self._pickups[key].value, self._pickups[key])
				self._pickups[key] = nil
			end
		end
	end

	function GameInfoManager:_pickup_count_event(event, interact_id, value, data)
		if event == "change" then
			if value ~= 0 then
				self:_listener_callback("pickup_count", "change", interact_id, value, data)
			end
		end
	end

	function GameInfoManager:get_pickups(key)
		if key then
			return self._pickups[key]
		else
			return self._pickups
		end
	end

	function GameInfoManager:_loot_interaction_handler(event, key, data)
		if event == "add" then
			if not self._loot[key] then
				local composite_lookup = GameInfoManager._INTERACTIONS.COMPOSITE_LOOT_UNITS
				local count = composite_lookup[data.editor_id] or composite_lookup[data.interact_id] or 1

				self._loot[key] = {unit = data.unit, carry_id = data.carry_id, count = count }
				self:_listener_callback("loot", "add", key, self._loot[key])
				self:_loot_count_event("change", data.carry_id, count, self._loot[key])
			end
		elseif self._loot[key] then
			if event == "remove"then
				self:_listener_callback("loot", "remove", key, self._loot[key])
				self:_loot_count_event("change", data.carry_id, -self._loot[key].count, self._loot[key])
				self._loot[key] = nil
			elseif event == "interact" then
				local composite_lookup = GameInfoManager._INTERACTIONS.COMPOSITE_LOOT_UNITS
				local count = composite_lookup[data.editor_id] or composite_lookup[data.interact_id] or 1
				local change = count - self._loot[key].count

				self._loot[key].count = count
				self:_listener_callback("loot", "interact", key, self._loot[key])
				self:_loot_count_event("change", data.carry_id, change, self._loot[key])
			end
		end
	end

	function GameInfoManager:_loot_count_event(event, carry_id, value, data)
		if event == "change" then
			if value ~= 0 then
				self:_listener_callback("loot_count", "change", carry_id, value, data)
			end
		end
	end

	function GameInfoManager:get_loot(key)
		if key then
			return self._loot[key]
		else
			return self._loot
		end
	end

elseif string.lower(RequiredScript) == "lib/managers/enemymanager" then

	local on_enemy_registered_original = EnemyManager.on_enemy_registered
	local on_enemy_unregistered_original = EnemyManager.on_enemy_unregistered

	function EnemyManager:on_enemy_registered(unit, ...)
		managers.gameinfo:event("unit", "add", tostring(unit:key()), {unit = unit})
		on_enemy_registered_original(self, unit, ...)
	end

	function EnemyManager:on_enemy_unregistered(unit, ...)
		managers.gameinfo:event("unit", "remove", tostring(unit:key()))
		on_enemy_unregistered_original(self, unit, ...)
	end

elseif string.lower(RequiredScript) == "lib/managers/objectinteractionmanager" then

	local init_original = ObjectInteractionManager.init
	local update_original = ObjectInteractionManager.update
	local add_unit_original = ObjectInteractionManager.add_unit
	local remove_unit_original = ObjectInteractionManager.remove_unit
	local end_action_interact_original = ObjectInteractionManager.end_action_interact

	function ObjectInteractionManager:init(...)
		init_original(self, ...)
		self._queued_units = {}
	end

	function ObjectInteractionManager:update(t, ...)
		update_original(self, t, ...)
		self:_process_queued_units(t)
	end

	function ObjectInteractionManager:add_unit(unit, ...)
		self:add_unit_clbk(unit)
		return add_unit_original(self, unit, ...)
	end

	function ObjectInteractionManager:remove_unit(unit, ...)
		self:remove_unit_clbk(unit)
		return remove_unit_original(self, unit, ...)
	end

	function ObjectInteractionManager:end_action_interact(...)
		local value = end_action_interact_original(self, ...)

		if alive(self._active_unit) and self._active_unit:interaction() then
			local id = self._active_unit:interaction().tweak_data
			local editor_id = self._active_unit:editor_id()
			managers.gameinfo:event("interactive_unit", "interact", tostring(self._active_unit:key()), {unit = self._active_unit, editor_id = editor_id, interact_id = id})
		end

		return value
	end

	function ObjectInteractionManager:add_unit_clbk(unit)
		self._queued_units[tostring(unit:key())] = unit
	end

	function ObjectInteractionManager:remove_unit_clbk(unit, interact_id)
		local key = tostring(unit:key())

		if self._queued_units[key] then
			self._queued_units[key] = nil
		else
			local id = interact_id or unit:interaction() and unit:interaction().tweak_data
			if id then
				local editor_id = unit:editor_id()
				managers.gameinfo:event("interactive_unit", "remove", key, {unit = unit, editor_id = editor_id, interact_id = id})
			end
		end
	end

	function ObjectInteractionManager:_process_queued_units(t)
		for key, unit in pairs(self._queued_units) do
			if alive(unit) then
				local interact_id = unit:interaction().tweak_data
				local editor_id = unit:editor_id()
				managers.gameinfo:event("interactive_unit", "add", key, {unit = unit, editor_id = editor_id, interact_id = interact_id})
			end
		end

		self._queued_units = {}
	end

elseif string.lower(RequiredScript) == "lib/units/interactions/interactionext" then

	local set_tweak_data_original = BaseInteractionExt.set_tweak_data

	function BaseInteractionExt:set_tweak_data(...)
		local old_tweak = self.tweak_data
		local was_active = self:active()

		set_tweak_data_original(self, ...)

		if was_active and self:active() and self.tweak_data ~= old_tweak then
			managers.interaction:remove_unit_clbk(self._unit, old_tweak)
			managers.interaction:add_unit_clbk(self._unit)
		end
	end

elseif string.lower(RequiredScript) == "lib/units/pickups/greedcacheitem" then

	local on_interacted_original = GreedCacheItem.on_interacted

	function GreedCacheItem:on_interacted(amount, ...)
		local pickup_amount = on_interacted_original(self, amount, ...)

		if self._current_amount == 0 then
			local unit = self._unit
			local key = tostring(unit:key())
			local editor_id = unit:editor_id()
			local interact_id = unit:interaction().tweak_data
			managers.gameinfo:event("interactive_unit", "remove", key, {unit = unit, editor_id = editor_id, interact_id = interact_id})
		end

		return pickup_amount
	end

end
