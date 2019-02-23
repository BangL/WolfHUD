
local _update_throw_link_original = CarryData._update_throw_link

function CarryData:_update_throw_link(...)
	if not JimHUD:GetOption({"EQUIPMENT", "DISABLE_BOT_CATCH"}, true) then
		return _update_throw_link_original(self, ...)
	end
end
