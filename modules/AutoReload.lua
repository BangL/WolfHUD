if string.lower(RequiredScript) == "lib/units/beings/player/states/playerstandard" then
	local _check_action_primary_attack_original = PlayerStandard._check_action_primary_attack

	function PlayerStandard:_check_action_primary_attack(t, input, ...)
		local reload_auto = WolfgangHUD:getSetting({ "GAMEPLAY", "AUTO_RELOAD" }, true)
		local reload_single = WolfgangHUD:getSetting({ "GAMEPLAY", "AUTO_RELOAD_SINGLE" }, true)

		if reload_auto or reload_single then
			if self._ext_inventory:equipped_selection() == PlayerInventory.SLOT_4 then
				return
			end

			if self._ext_inventory:equipped_selection() == PlayerInventory.SLOT_3 then
				return
			end

			local action_wanted = input.btn_primary_attack_state or input.btn_primary_attack_release

			if action_wanted then
				local action_forbidden = self:_is_reloading() or self:_changing_weapon() or self:_is_meleeing()
					or self._use_item_expire_t or self:_interacting() or self:_is_throwing_projectile()
					or self:_is_deploying_bipod() or self:_is_comm_wheel_active() or self:_is_throwing_grenade()
					or self:_is_throwing_coin(t)

				if not action_forbidden then
					if self._equipped_unit then
						local weap_base = self._equipped_unit:base()
						local fire_mode = weap_base:fire_mode()

						if managers.buff_effect:is_effect_active(BuffEffectManager.EFFECT_PLAYERS_CAN_ONLY_USE_SINGLE_FIRE) then
							fire_mode = "single"
						end

						if ((fire_mode == "single" and reload_single) or (fire_mode ~= "single" and reload_auto))
							and weap_base.clip_empty and weap_base:clip_empty()
							and not weap_base:out_of_ammo()
							and not self:_is_using_bipod() then
							self:_start_action_reload_enter(t)
							return true
						end
					end
				end
			end
		end
		return _check_action_primary_attack_original(self, t, input, ...)
	end
end
