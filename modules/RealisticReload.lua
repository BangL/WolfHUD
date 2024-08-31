
if string.lower(RequiredScript) == "lib/units/weapons/raycastweaponbase" then

	local on_reload_original = RaycastWeaponBase.on_reload
	function RaycastWeaponBase:on_reload(...)
		-- if player weapon without tactical reload...
		if self._setup.expend_ammo and not self._use_shotgun_reload and WolfgangHUD:getSetting({"GAMEPLAY", "REALISTIC_RELOAD"}, false) then
			local ammo_base = self.parent_weapon and self.parent_weapon:base() or self
			-- ...subtract the dropped bullets left in the magazine...
			ammo_base:set_ammo_total(ammo_base:get_ammo_total() - ammo_base:get_ammo_remaining_in_clip())
		end
		-- ...and then reload as usual
		on_reload_original(self, ...)
	end

end