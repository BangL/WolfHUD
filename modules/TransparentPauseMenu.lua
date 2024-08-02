if string.lower(RequiredScript) == "lib/managers/menu/raid_menu/raidmenuscenemanager" then

	local show_background_original = RaidMenuSceneManager.show_background
	local hide_background_original = RaidMenuSceneManager.hide_background

	function RaidMenuSceneManager:show_background()
		show_background_original(self)
		local bg = self._background_image._panel
		if bg and alive(bg) and not self._pause_menu_enabled or not WolfgangHUD:getSetting({"MENU", "TRANSPARENT_PAUSE_MENU"}, false) then
			bg:show()
		end
	end

	function RaidMenuSceneManager:hide_background()
		hide_background_original(self)
		local bg = self._background_image._panel
		if bg and alive(bg) then
			bg:hide()
		end
	end

end