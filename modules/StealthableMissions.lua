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
        self:wghud_refresh_stealthable_icon()
    end

    function RaidGUIControlListItemRaids:_init_stealthable_icon()
        return self._object:bitmap({
            texture = "ui/atlas/raid_atlas_waypoints",
            texture_rect = { 439, 437, 38, 38 },
            w = icon_size,
            h = icon_size,
            blend_mode = "normal",
            visible = false,
        })
    end

    function RaidGUIControlListItemRaids:wghud_refresh_stealthable_icon()
        if not self._object or not self._item_label or not self._data.value or not WolfgangHUD:getSetting({ "MENU", "MARK_STEALTHABLES" }, true) then
            return
        end

        if not self._stealthable_icon then
            self._stealthable_icon = self:_init_stealthable_icon()
        end

        local raid_data = tweak_data.operations.missions[self._data.value]
        if ((raid_data.stealth_description and raid_data.stealth_description ~= OperationsTweakData.RAID_NOT_STEALTHABLE)
                or override_partially_stealthable[self._data.value] or override_completely_stealthable[self._data.value])
            and not override_not_stealthable[self._data.value] then
            local x, _, w, _ = self._item_label:text_rect()
            self._stealthable_icon:set_x(x + w + 4)
            self._stealthable_icon:set_center_y(RaidGUIControlListItemRaids.NAME_CENTER_Y)

            self._stealthable_icon:set_color(
                ((raid_data.stealth_description == OperationsTweakData.RAID_COMPLETELY_STEALTHABLE)
                    or override_completely_stealthable[self._data.value])
                and tweak_data.gui.colors.progress_green
                or tweak_data.gui.colors.raid_grey)

            self._stealthable_icon:set_visible(true)
        else
            self._stealthable_icon:set_visible(false)
        end
    end
end
