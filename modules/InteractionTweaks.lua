if string.lower(RequiredScript) == "lib/units/interactions/interactionext" then
    local interact_start_original = BaseInteractionExt.interact_start
    local health_pickup_interact_blocked_original = HealthPickupInteractionExt._interact_blocked
    local health_pickup_selected_original = HealthPickupInteractionExt.selected

    BaseInteractionExt.STEALTH_TURRETS_TIMEOUT = WolfgangHUD:getTweakEntry("STEALTH_TURRETS_TIMEOUT", "number", 0.25) --Timeout for 2 InteractKey pushes, to prevent accidents in stealth

    local TURRET_INTERACTIONS = {
        turret_m2 = true,
        turret_flak_88 = true,
        turret_flakvierling = true,
    }

    function BaseInteractionExt:interact_start(player, locator, ...)
        local t = Application:time()
        if WolfgangHUD:getSetting({ "GAMEPLAY", "INTERACTION", "TURRETS_STEALTH_DISABLED" }, true)
            and managers.groupai:state():whisper_mode()
            and self.tweak_data and table.has(TURRET_INTERACTIONS, self.tweak_data)
            and (t - (self._last_turret_interact_t or 0) >= BaseInteractionExt.STEALTH_TURRETS_TIMEOUT) then
            self._last_turret_interact_t = t
            return false
        end
        return interact_start_original(self, player, locator, ...)
    end

    function HealthPickupInteractionExt:_interact_blocked(player, ...)
        if self.tweak_data == "health_bag_big" then
            local player_damage = player:character_damage()
            if player_damage:get_revives() >= (player_damage._class_tweak_data.damage.BASE_LIVES + managers.player:upgrade_value("player", "additional_lives", 0)) then
                if WolfgangHUD:getSetting({ "GAMEPLAY", "INTERACTION", "REVIVE_BLOCK_MAX_REVIVES" }, true) then
                    -- disallow when maximum revives, with custom hint
                    return true, false, "wolfganghud_hint_maximum_revives"
                end
            elseif WolfgangHUD:getSetting({ "GAMEPLAY", "INTERACTION", "REVIVE_ALLOW_FULL_HEALTH" }, true) then
                -- allow when below maximum revives, even if full health
                return false
            end
        end
        return health_pickup_interact_blocked_original(self, player, ...)
    end

    function HealthPickupInteractionExt:selected(player)
        if player ~= nil
            and self.tweak_data == "health_bag_big"
            and self:can_select(player) then
            local player_damage = player:character_damage()
            if player_damage:get_revives() >= (player_damage._class_tweak_data.damage.BASE_LIVES + managers.player:upgrade_value("player", "additional_lives", 0)) then
                if WolfgangHUD:getSetting({ "GAMEPLAY", "INTERACTION", "REVIVE_BLOCK_MAX_REVIVES" }, true) then
                    -- hide interaction prompt at max revives
                    self._hide_interaction_prompt = true
                end
            elseif WolfgangHUD:getSetting({ "GAMEPLAY", "INTERACTION", "REVIVE_ALLOW_FULL_HEALTH" }, true) then
                -- copy of original, but skipped health check
                local result = BaseInteractionExt.selected(self, player)
                self._hide_interaction_prompt = nil
                return result
            end
        end
        return health_pickup_selected_original(self, player)
    end
elseif string.lower(RequiredScript) == "lib/units/pickups/healthpackpickup" then
    local _pickup_original = HealthPackPickup._pickup

    function HealthPackPickup:_pickup(unit, ...)
        if unit then
            local character_damage = unit:character_damage()
            if character_damage
                and not self._picked_up
                and not character_damage:dead()
                and self.tweak_data == "health_big"
                and character_damage:full_health()
                and WolfgangHUD:getSetting({ "GAMEPLAY", "INTERACTION", "REVIVE_ALLOW_FULL_HEALTH" }, true) then
                -- copy of original, but without all that health stuff
                managers.player:player_unit():character_damage():recover_down()
                self._picked_up = true
                if Network:is_client() then
                    managers.network:session():send_to_host("sync_pickup", self._unit)
                end
                self:consume()
                return true
            end
        end

        return _pickup_original(self, unit, ...)
    end
end
