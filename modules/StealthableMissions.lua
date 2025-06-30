if string.lower(RequiredScript) == "lib/managers/menu/raid_menu/controls/raidguicontrollistitemraids" then
    local _layout_raid_name_original = RaidGUIControlListItemRaids._layout_raid_name

    local icon_size = tweak_data.gui.font_sizes.small - 2

    local override_not_stealthable = {
        ["silo"] = true, -- Countdown
    }

    local override_partially_stealthable = {
    }

    local override_completely_stealthable = {
        ["flakturm"] = true, -- Odin's Fall
    }

    function RaidGUIControlListItemRaids:_layout_raid_name(params, data, ...)
        _layout_raid_name_original(self, params, data, ...)
        if not self._object or not self._item_label or not data.value or not WolfgangHUD:getSetting({ "MENU", "MARK_STEALTHABLES" }, true) then
            return
        end

        local raid_data = tweak_data.operations.missions[data.value]
        if ((raid_data.stealth_description and raid_data.stealth_description ~= OperationsTweakData.RAID_NOT_STEALTHABLE)
                or override_partially_stealthable[data.value] or override_completely_stealthable[data.value])
            and not override_not_stealthable[data.value] then
            local x, _, w, _ = self._item_label:text_rect()
            self._stealhtable_icon = self:_init_stealthable_icon(x + w + 4, 0,
                (raid_data.stealth_description == OperationsTweakData.RAID_COMPLETELY_STEALTHABLE)
                or override_completely_stealthable[data.value])
            self._stealhtable_icon:set_center_y(RaidGUIControlListItemRaids.NAME_CENTER_Y)
        end
    end

    function RaidGUIControlListItemRaids:_init_stealthable_icon(x, y, completely_stealthable)
        return self._object:bitmap({
            texture = "ui/atlas/raid_atlas_waypoints",
            texture_rect = { 439, 437, 38, 38 },
            x = x,
            y = y,
            w = icon_size,
            h = icon_size,
            blend_mode = "normal",
            color = completely_stealthable and tweak_data.gui.colors.progress_green or tweak_data.gui.colors.raid_grey
        })
    end
end
