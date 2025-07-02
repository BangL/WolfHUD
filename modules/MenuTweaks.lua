if string.lower(RequiredScript) == "lib/managers/menumanager" then
    local create_controller_original = MenuManager.create_controller
    function MenuManager:create_controller(...)
        create_controller_original(self, ...)
        if self._is_start_menu then
            RaidMenuHelper:RegisterMenu({
                input = "MenuInput",
                name = "mission_join_menu",
                renderer = "MenuRenderer",
                id = "mission_join_menu",
                content_file = "gamedata/raid/menus/mission_join_menu",
                callback_handler = MenuCallbackHandler:new(),
                config = {
                    {
                        _meta = "menu",
                        id = "mission_join_menu",
                        {
                            _meta = "default_node",
                            name = "mission_join"
                        },
                        {
                            _meta = "node",
                            gui_class = "MenuNodeGuiRaid",
                            name = "mission_join",
                            topic_id = "menu_mission_join",
                            menu_components = "raid_menu_header raid_menu_footer raid_menu_mission_join",
                            node_background_width = 0.4,
                            node_padding = 30,
                            no_item_parent = false
                        }
                    }
                }
            })
        end
    end
elseif string.lower(RequiredScript) == "lib/managers/menu/raid_menu/raidmainmenugui" then
    local _list_menu_data_source_original = RaidMainMenuGui._list_menu_data_source

    function RaidMainMenuGui:_list_menu_data_source(...)
        local _list_items = _list_menu_data_source_original(self, ...)
        if WolfgangHUD:getSetting({ "MENU", "ADD_JOIN_MENU_OFFLINE" }, true) then
            table.insert(_list_items, 21, {
                callback = "on_multiplayer_clicked",
                availability_flags = {
                    RaidGUIItemAvailabilityFlag.IS_IN_CAMP,
                    RaidGUIItemAvailabilityFlag.IS_SINGLEPLAYER
                },
                text = managers.localization:to_upper_text("menu_servers"),
                icon = "menu_item_servers"
            })
        end
        if WolfgangHUD:getSetting({ "MENU", "STREAMLINE" }, true) then
            for _, item in ipairs(_list_items) do
                item.item_font_size = nil
                item.item_h = nil
            end
        end
        return _list_items
    end

    Hooks:PostHook(RaidMainMenuGui, "_layout_version_id", "RaidMainMenuGuiPostLayoutVersionString_WolfgangHUD",
        function(self)
            if self._version_id then
                self._version_id:set_width(1000)
                self._version_id:set_text(self._version_id:text() .. " | WolfgangHUD v" .. WolfgangHUD:getVersion())
            end
        end
    )
elseif string.lower(RequiredScript) == "lib/managers/menu/raid_menu/missionjoingui" then
    local _join_game_original = MissionJoinGui._join_game

    function MissionJoinGui:_join_game(...)
        local selected_row = self._table_servers:get_selected_row()
        if selected_row and selected_row:get_data() then
            Global.game_settings.single_player = false
        end
        return _join_game_original(self, ...)
    end
end
