if string.lower(RequiredScript) == "lib/managers/menu/raid_menu/controls/raidguicontrollistitemraids" then
    local _layout_raid_name_original = RaidGUIControlListItemRaids._layout_raid_name

    local icon_size = tweak_data.gui.font_sizes.small - 2

    local override_not_stealthable = {
        ["silo"] = true, -- Countdown
    }

    local override_partially_stealthable = {
        -- 'Operation days as missions' compat:
        ["fake_mission_clear_skies_mini_raid_1_park"] = true,        -- Communication Breakdown / Clear Skies 1/6
        ["fake_mission_clear_skies_radio_defense"] = true,           -- London Calling / Clear Skies 4/6
        --["fake_mission_clear_skies_flakturm"] = true,                -- Blinding Heimdall / Clear Skies 6/6
        ["fake_mission_oper_flamable_mini_raid_1_park"] = true,      -- Cloak And Dagger / Rhinegold 1/4
        ["fake_mission_oper_flamable_mini_raid_2_destroyed"] = true, -- Fuel For The Fire / Rhinegold 2/4
        ["fake_mission_oper_flamable_castle"] = true,                -- Firestarter / Rhinegold 4/4
    }

    local override_completely_stealthable = {
        ["flakturm"] = true,                               -- Odin's Fall
        -- 'Operation days as missions' compat:
        ["fake_mission_clear_skies_gold_rush"] = true,        -- Enigmatic / Clear Skies 2/6
        ["fake_mission_clear_skies_mini_raid_2_park"] = true, -- Burning Man / Clear Skies 3/6
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
