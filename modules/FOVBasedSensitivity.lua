
if string.lower(RequiredScript) == "lib/managers/menumanager" then

	function MenuManager:set_mouse_sensitivity(zoomed)
		local zoom_sense = zoomed
		local sense_x, sense_y = nil, nil
		if zoom_sense then
			sense_x = managers.user:get_setting("camera_zoom_sensitivity_x")
			sense_y = managers.user:get_setting("camera_zoom_sensitivity_y")
		else
			sense_x = managers.user:get_setting("camera_sensitivity_x")
			sense_y = managers.user:get_setting("camera_sensitivity_y")
		end
		if zoomed and WolfgangHUD:getSetting({"GAMEPLAY", "FOV_BASED_SENSIVITY"}, true) and alive(managers.player:player_unit()) then
			local state = managers.player:player_unit():movement():current_state()
			if alive(state._equipped_unit) then
				local fov = managers.user:get_setting("fov_multiplier")
				local base = state._equipped_unit:base()
				local scale = (base.zoom and base:zoom() or 65) * (fov + 1) / 2 / (65 * fov)
				sense_x = sense_x * scale
				sense_y = sense_y * scale
			end
		end
		local multiplier = Vector3()
		mvector3.set_x(multiplier, sense_x * self._look_multiplier.x)
		mvector3.set_y(multiplier, sense_y * self._look_multiplier.y)
		self._controller:get_setup():get_connection("look"):set_multiplier(multiplier)
		managers.controller:rebind_connections()
	end

end