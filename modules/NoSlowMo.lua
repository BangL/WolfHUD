if string.lower(RequiredScript) == "lib/tweak_data/timespeedeffecttweakdata" then

	local init_original = TimeSpeedEffectTweakData.init

	local FORCE_ENABLE = {
		mission_effects = true,
	}

	function TimeSpeedEffectTweakData:init(...)
		init_original(self, ...)
		if WolfgangHUD:getSetting({"GAMEPLAY", "NO_SLOWMOTION"}, true) then
			local function disable_effect(table)
				for name, data in pairs(table) do
					if not FORCE_ENABLE[name] then
						if type(data) == "table" then
							if data.speed and data.sustain then
								data.speed = 1
								data.fade_in_delay = 0
								data.fade_in = 0
								data.sustain = 0
								data.fade_out = 0
							else
								disable_effect(data)
							end
						end
					end
				end
			end
			disable_effect(self)
		end
	end

end