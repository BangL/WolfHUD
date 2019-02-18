
if string.lower(RequiredScript) == "lib/states/ingameaccesscamera" then

	local at_enter_original = IngameAccessCamera.at_enter

	function IngameAccessCamera:at_enter(old_state, ...)
		if JimHUD:getSetting({"CustomHUD", "COLORED_CAM"}, true) then
			local set_default_color_grading_original = CoreEnvironmentControllerManager.set_default_color_grading
			managers.environment_controller.set_default_color_grading = function(self, color_grading, ignore_user_setting)
				set_default_color_grading_original(self, "color_on", true) -- override
			end
			at_enter_original(self, old_state, ...)
			managers.environment_controller.set_default_color_grading = set_default_color_grading_original
		else
			at_enter_original(self, old_state, ...)
		end
	end

end