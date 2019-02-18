

if string.lower(RequiredScript) == "lib/managers/menu/blackmarketgui" then

	local populate_armors_original = BlackMarketGui.populate_armors

	function BlackMarketGui:populate_armors(data)
		if JimHUD:getSetting({"INVENTORY", "FIX_ARMOR_SORTING"}, true) then
			local get_sorted_armors_original = BlackMarketManager.get_sorted_armors
			BlackMarketManager.get_sorted_armors = function(self, hide_locked)
				local sort_data = {}
				local armor_level_data = {}
				for id, d in pairs(Global.blackmarket_manager.armors) do
					table.insert(sort_data, id)
				end
				for level, data in pairs(tweak_data.upgrades.level_tree) do
					if data.upgrades then
						for _, upgrade in ipairs(data.upgrades) do
							local def = tweak_data.upgrades.definitions[upgrade]
							if def.armor_id then
								armor_level_data[def.armor_id] = level
							end
						end
					end
				end
				table.sort(sort_data, function(x, y)
					local x_level = tonumber(string.sub(x, 7))
					local y_level = tonumber(string.sub(y, 7))
					return x_level < y_level
				end)
				return sort_data, armor_level_data
			end
			populate_armors_original(self, data)
			BlackMarketManager.get_sorted_armors = get_sorted_armors_original
		else
			populate_armors_original(self, data)
		end
	end

end