if string.lower(RequiredScript) == "lib/managers/hudmanager" then
    local init_original = HUDManager.init

    HUDManager.WOLFGANGHUD_PD2LAYOUT_PADDING = 20

    function HUDManager:init(...)
        local layout = WolfgangHUD and WolfgangHUD:getSetting({ "HUD", "LAYOUT" }, 1)
        self._wolfganghud_layout_is_vanilla = layout == 1
        self._wolfganghud_layout_is_pd2 = layout == 2
        init_original(self, ...)
    end

    function HUDManager:wolfganghud_layout_is_vanilla()
        return self._wolfganghud_layout_is_vanilla
    end

    function HUDManager:wolfganghud_layout_is_pd2()
        return self._wolfganghud_layout_is_pd2
    end
elseif string.lower(RequiredScript) == "lib/managers/hudmanagerpd2" then
    local _setup_ingame_hud_saferect_original = HUDManager._setup_ingame_hud_saferect
    local _layout_teammate_panels_original = HUDManager._layout_teammate_panels
    local _create_objectives_original = HUDManager._create_objectives

    function HUDManager:_setup_ingame_hud_saferect(...)
        _setup_ingame_hud_saferect_original(self, ...)

        if not self:wolfganghud_layout_is_pd2() then
            return
        end

        local hud = managers.hud:script(PlayerBase.INGAME_HUD_SAFERECT)
        if not hud then
            WolfgangHUD:print_log("[PD2Layout] hud is null", "error")
            return
        end

        local teammates_panel = hud.panel:child("teammates_panel")
        if not teammates_panel then
            WolfgangHUD:print_log("[PD2Layout] teammates_panel is null", "error")
            return
        end

        teammates_panel:set_halign("grow")
        teammates_panel:set_valign("bottom")
        teammates_panel:set_w(hud.panel:w())
        teammates_panel:set_h(self:teampanels_height())
        teammates_panel:set_left(0)
        teammates_panel:set_bottom(hud.panel:h())

        if managers.savefile._save_icon then
            managers.savefile._save_icon:offset_position(0, 0)
        end

        -- workaround for starting game with disabled ai
        if not Global.game_settings.team_ai then
            self:_layout_teammate_panels()
        end
    end

    function HUDManager:_layout_teammate_panels()
        if not self:wolfganghud_layout_is_pd2() then
            _layout_teammate_panels_original(self)
            return
        end

        local hud = managers.hud:script(PlayerBase.INGAME_HUD_SAFERECT)
        if not hud then
            WolfgangHUD:print_log("[PD2Layout] hud is null", "error")
            return
        end

        local teammates_panel = hud.panel:child("teammates_panel")
        if not teammates_panel then
            WolfgangHUD:print_log("[PD2Layout] teammates_panel is null", "error")
            return
        end

        local weapons_panel = hud.panel:child("weapons_panel")
        if not weapons_panel then
            WolfgangHUD:print_log("[PD2Layout] weapons_panel is null", "error")
            return
        end

        for i = 1, 4 do
            local panel = self._teammate_panels[i]
            if not panel or not panel._object then
                WolfgangHUD:print_log("[PD2Layout] teammate panel %i is null", i, "error")
                return
            end
            local is_player = i == self.PLAYER_PANEL
            if is_player then
                panel:set_x(teammates_panel:w() - panel:w() - self.WOLFGANGHUD_PD2LAYOUT_PADDING)
            else
                panel:set_x(math.floor(teammates_panel:w() / 4 * (i - 1)))
            end
            panel:set_y(teammates_panel:h() - panel:h() -
                (is_player and (weapons_panel:h() + self.WOLFGANGHUD_PD2LAYOUT_PADDING) or 0))
        end
    end

    function HUDManager:get_pd2style_carry_bottom()
        local hud = managers.hud:script(PlayerBase.INGAME_HUD_SAFERECT)
        local weapons_panel = hud.panel:child("weapons_panel")
        return hud.panel:h()
            - weapons_panel:h() - self.WOLFGANGHUD_PD2LAYOUT_PADDING
            - self._teammate_panels[self.PLAYER_PANEL]:h() - self.WOLFGANGHUD_PD2LAYOUT_PADDING
    end

    function HUDManager:get_vanilla_notification_bottom()
        if managers.hudlist and managers.hudlist:get_y() then
            return managers.hudlist:get_y() - self.WOLFGANGHUD_PD2LAYOUT_PADDING
        end
        return nil
    end

    function HUDManager:get_pd2style_notification_bottom()
        return self:get_pd2style_carry_bottom() -
            --(self._carry_hud._object:alpha() ~= 0 and
            (self._carry_hud:h() + self.WOLFGANGHUD_PD2LAYOUT_PADDING)
        --or 0)
    end

    function HUDManager:_create_objectives(hud, ...)
        _create_objectives_original(self, hud, ...)
        if not self:wolfganghud_layout_is_pd2() then
            return
        end

        if not self._hud_objectives then
            WolfgangHUD:print_log("[PD2Layout] hud_objectives is null", "error")
            return
        end

        self._hud_objectives:set_x(0)
        self._hud_objectives._object:set_halign("left")
    end
elseif string.lower(RequiredScript) == "lib/managers/hud/hudcarry" then
    local _size_panel_original = HUDCarry._size_panel
    local _animate_show_carry_original = HUDCarry._animate_show_carry
    local _animate_hide_carry_original = HUDCarry._animate_hide_carry

    function HUDCarry:_size_panel(...)
        _size_panel_original(self, ...)
        if not managers.hud:wolfganghud_layout_is_pd2() then
            return
        end

        self._object:set_x(self._object:parent():w() - self:w() - managers.hud.WOLFGANGHUD_PD2LAYOUT_PADDING)
    end

    function HUDCarry:_animate_show_carry(...)
        if not managers.hud:wolfganghud_layout_is_pd2() then
            _animate_show_carry_original(self, ...)
            return
        end

        local duration = 0.5
        local t = self._object:alpha() * duration
        local bottom = managers.hud:get_pd2style_carry_bottom()

        while t < duration do
            local dt = coroutine.yield()

            t = t + dt

            local current_alpha = Easing.quartic_out(t, 0, 1, duration)

            self._object:set_alpha(current_alpha)

            local current_bottom_distance = Easing.quartic_out(t, HUDCarry.BOTTOM_DISTANCE_WHILE_HIDDEN,
                -HUDCarry.BOTTOM_DISTANCE_WHILE_HIDDEN, duration)

            self._object:set_bottom(bottom - current_bottom_distance)
        end

        self._object:set_alpha(1)
        self._object:set_bottom(bottom)
    end

    function HUDCarry:_animate_hide_carry(...)
        if not managers.hud:wolfganghud_layout_is_pd2() then
            _animate_hide_carry_original(self, ...)
            return
        end

        local duration = 0.25
        local t = (1 - self._object:alpha()) * duration
        local bottom = managers.hud:get_pd2style_carry_bottom()

        while t < duration do
            local dt = coroutine.yield()

            t = t + dt

            local current_alpha = Easing.quartic_out(t, 1, -1, duration)

            self._object:set_alpha(current_alpha)

            local current_bottom_distance = Easing.quartic_out(t, 0, HUDCarry.BOTTOM_DISTANCE_WHILE_HIDDEN, duration)

            self._object:set_bottom(bottom - current_bottom_distance)
        end

        self._object:set_alpha(0)
        self._object:set_bottom(bottom - HUDCarry.BOTTOM_DISTANCE_WHILE_HIDDEN)
    end
elseif string.lower(RequiredScript) == "lib/managers/hud/hudobjectivebase" then
    local set_visible_original = HUDObjectiveBase.set_visible
    local set_hidden_original = HUDObjectiveBase.set_hidden
    local _animate_show_original = HUDObjectiveBase._animate_show
    local _animate_hide_original = HUDObjectiveBase._animate_hide

    function HUDObjectiveBase:is_tab_screen()
        return self._object:parent():parent():name() == "tab_screen"
    end

    function HUDObjectiveBase:set_visible(...)
        set_visible_original(self, ...)
        if self:is_tab_screen() or not managers.hud:wolfganghud_layout_is_pd2() then
            return
        end

        self._object:set_x(0)
    end

    function HUDObjectiveBase:set_hidden(...)
        set_hidden_original(self, ...)
        if self:is_tab_screen() or not managers.hud:wolfganghud_layout_is_pd2() then
            return
        end

        self._object:set_x(self.OFFSET_WHILE_HIDDEN)
    end

    function HUDObjectiveBase:_animate_show(panel, delay, ...)
        if self:is_tab_screen() or not managers.hud:wolfganghud_layout_is_pd2() then
            _animate_show_original(self, panel, delay, ...)
            return
        end

        local duration = 0.2
        local t = 0

        self._object:set_visible(true)
        self._object:set_alpha(0)
        self._object:set_x(self.OFFSET_WHILE_HIDDEN)

        if delay then
            wait(delay)
        end

        while t < duration do
            local dt = coroutine.yield()

            t = t + dt

            local current_alpha = Easing.quartic_out(t, 0, 1, duration)

            self._object:set_alpha(current_alpha)

            local current_offset = Easing.quartic_out(t, self.OFFSET_WHILE_HIDDEN,
                -self.OFFSET_WHILE_HIDDEN, duration)

            self._object:set_x(current_offset)
        end

        self._object:set_alpha(1)
        self._object:set_x(0)
    end

    function HUDObjectiveBase:_animate_hide(panel, delay, ...)
        if self:is_tab_screen() or not managers.hud:wolfganghud_layout_is_pd2() then
            _animate_hide_original(self, panel, delay, ...)
            return
        end

        local duration = 0.15
        local t = (1 - self._object:alpha()) * duration

        self._object:set_x(0)

        if delay then
            wait(delay)
        end

        while t < duration do
            local dt = coroutine.yield()

            t = t + dt

            local current_alpha = Easing.quartic_in(t, 1, -1, duration)

            self._object:set_alpha(current_alpha)

            local current_offset = Easing.quartic_in(t, 0, self.OFFSET_WHILE_HIDDEN, duration)

            self._object:set_x(current_offset)
        end

        self._object:set_alpha(0)
        self._object:set_x(self.OFFSET_WHILE_HIDDEN)
        self._object:set_visible(false)
    end
elseif string.lower(RequiredScript) == "lib/managers/hud/hudobjectivesub" then
    local _create_objective_text_original = HUDObjectiveSub._create_objective_text
    local _create_amount_original = HUDObjectiveSub._create_amount
    local _create_checkbox_original = HUDObjectiveSub._create_checkbox
    local complete_original = HUDObjectiveSub.complete

    function HUDObjectiveSub:_create_objective_text(...)
        _create_objective_text_original(self, ...)
        if self:is_tab_screen() or not managers.hud:wolfganghud_layout_is_pd2() then
            return
        end

        self._objective_text:set_halign("left")
        self._objective_text:set_align("left")
    end

    function HUDObjectiveSub:_create_amount(...)
        _create_amount_original(self, ...)
        if self:is_tab_screen() or not managers.hud:wolfganghud_layout_is_pd2() then
            return
        end

        self._amount_panel:set_halign("left")
        self._amount_panel:set_x(0)
    end

    function HUDObjectiveSub:_create_checkbox(...)
        _create_checkbox_original(self, ...)
        if self:is_tab_screen() or not managers.hud:wolfganghud_layout_is_pd2() then
            return
        end

        self._checkbox_panel:set_x(0)
        self._objective_text:set_x(self._checkbox_panel:w() + self.OBJECTIVE_TEXT_PADDING_RIGHT)
    end

    function HUDObjectiveSub:complete(...)
        complete_original(self, ...)
        if self:is_tab_screen() or not managers.hud:wolfganghud_layout_is_pd2() then
            return
        end

        self._objective_text:set_x(self._checkbox_panel:w() + self.OBJECTIVE_TEXT_PADDING_RIGHT)
    end
elseif string.lower(RequiredScript) == "lib/managers/hud/hudobjectivemain" then
    local _create_timer_original = HUDObjectiveMain._create_timer
    local show_timer_original = HUDObjectiveMain.show_timer
    local hide_timer_original = HUDObjectiveMain.hide_timer

    function HUDObjectiveMain:_create_timer(...)
        _create_timer_original(self, ...)
        if self:is_tab_screen() or not managers.hud:wolfganghud_layout_is_pd2() then
            return
        end

        self._timer_panel:set_halign("left")
        self._timer_panel:set_x(self.OBJECTIVE_TEXT_PADDING_RIGHT)
    end

    function HUDObjectiveMain:show_timer(...)
        if self:is_tab_screen() or not managers.hud:wolfganghud_layout_is_pd2() then
            show_timer_original(self, ...)
            return
        end

        self._timer_panel:set_x(0)
        self._objective_text:set_x(self._timer_panel:w() + self.OBJECTIVE_TEXT_PADDING_RIGHT)
    end

    function HUDObjectiveMain:hide_timer(...)
        if self:is_tab_screen() or not managers.hud:wolfganghud_layout_is_pd2() then
            hide_timer_original(self, ...)
            return
        end

        self._timer_panel:set_right(0)
        if not self._amount_panel then
            self._objective_text:set_x(0)
        else
            self._objective_text:set_x(self._timer_panel:w() + self.OBJECTIVE_TEXT_PADDING_RIGHT)
        end
    end
elseif string.lower(RequiredScript) == "lib/managers/hud/hudnotification" then
    local init_original = HUDNotification.init
    local init_activeduty_original = HUDNotificationActiveDuty.init
    local init_dogtag_original = HUDNotificationDogTag.init
    local init_raidunlocked_original = HUDNotificationRaidUnlocked.init
    local init_consumablepickup_original = HUDNotificationConsumablePickup.init
    local init_greeditem_original = HUDNotificationGreedItem.init
    local _create_items_panel_original = HUDNotificationGreedItem._create_items_panel
    local init_cardfail_original = HUDNotificationCardFail.init
    local init_candyprogression_original = HUDNotificationCandyProgression.init
    local _create_panel_original = HUDNotificationWeaponChallenge._create_panel
    local _fit_size_original = HUDNotificationWeaponChallenge._fit_size

    function HUDNotification:wh_fix_bottom(original_init_func, ...)
        if not self.ORIGINAL_BOTTOM then
            self.ORIGINAL_BOTTOM = self.BOTTOM
        end
        if managers.hud:wolfganghud_layout_is_pd2() then
            self.BOTTOM = managers.hud:get_pd2style_notification_bottom() -- fixes all other (but HUDNotification and HUDNotificationWeaponChallenge)
        else--if managers.hud:wolfganghud_layout_is_vanilla() then
            self.BOTTOM = managers.hud:get_vanilla_notification_bottom()
        end
        original_init_func(self, ...)
        if self.ORIGINAL_BOTTOM ~= self.BOTTOM then -- fixes HUDNotification
            self._object:set_bottom(self.BOTTOM)
        end
    end

    -- fixes HUDNotification
    function HUDNotification:init(notification_data, ...)
        self:wh_fix_bottom(init_original, notification_data, ...)
        if self.ORIGINAL_BOTTOM ~= self.BOTTOM then -- fixes HUDNotification
            if self._panel_shape_y and self._panel_shape_h then
                self._panel_shape_y = self.BOTTOM - self._panel_shape_h
            end
        end
    end

    -- fixes HUDNotificationActiveDuty
    function HUDNotificationActiveDuty:init(notification_data, ...)
        self:wh_fix_bottom(init_activeduty_original, notification_data, ...)
    end

    -- fixes HUDNotificationDogTag
    function HUDNotificationDogTag:init(notification_data, ...)
        self:wh_fix_bottom(init_dogtag_original, notification_data, ...)
    end

    -- fixes HUDNotificationRaidUnlocked
    function HUDNotificationRaidUnlocked:init(notification_data, ...)
        self:wh_fix_bottom(init_raidunlocked_original, notification_data, ...)
    end

    -- fixes HUDNotificationConsumablePickup
    function HUDNotificationConsumablePickup:init(notification_data, ...)
        self:wh_fix_bottom(init_consumablepickup_original, notification_data, ...)
    end

    -- fixes HUDNotificationGreedItem
    function HUDNotificationGreedItem:init(notification_data, ...)
        self:wh_fix_bottom(init_greeditem_original, notification_data, ...)
    end

    function HUDNotificationGreedItem:_create_items_panel(...)
        _create_items_panel_original(self, ...)
        if self.ORIGINAL_BOTTOM ~= self.BOTTOM then
            self._items_panel:set_bottom((self.BOTTOM - self.HEIGHT) + self.ITEMS_HEIGHT / 2)
        end
    end

    -- fixes HUDNotificationCardFail
    function HUDNotificationCardFail:init(notification_data, ...)
        self:wh_fix_bottom(init_cardfail_original, notification_data, ...)
    end

    -- fixes HUDNotificationCandyProgression
    function HUDNotificationCandyProgression:init(notification_data, ...)
        self:wh_fix_bottom(init_candyprogression_original, notification_data, ...)
    end

    -- fixes HUDNotificationWeaponChallenge
    function HUDNotificationWeaponChallenge:_create_panel(...)
        if managers.hud:wolfganghud_layout_is_pd2() then
            self.Y = managers.hud:get_pd2style_notification_bottom() - self.HEIGHT
        elseif managers.hud:get_vanilla_notification_bottom() then
            self.Y = managers.hud:get_vanilla_notification_bottom() - self.HEIGHT
        end
        _create_panel_original(self, ...)
    end

    function HUDNotificationWeaponChallenge:_fit_size(...)
        _fit_size_original(self, ...)
        if self.Y then
            self._object:set_y(self.Y)
        end
    end
elseif string.lower(RequiredScript) == "lib/managers/hud/huddriving" then
    local _animate_show_original = HUDDriving._animate_show
    local _animate_hide_original = HUDDriving._animate_hide

    function HUDDriving:_animate_show(...)
        if not managers.hud:wolfganghud_layout_is_pd2() then
            _animate_show_original(self, ...)
            return
        end

        local duration = 0.5
        local t = self._object:alpha() * duration

        while t < duration do
            local dt = coroutine.yield()

            t = t + dt

            local current_alpha = Easing.quartic_out(t, 0, 1, duration)

            self._object:set_alpha(current_alpha)

            local current_bottom_distance = Easing.quartic_out(t, HUDDriving.BOTTOM_DISTANCE_WHILE_HIDDEN,
                -HUDDriving.BOTTOM_DISTANCE_WHILE_HIDDEN, duration)

            self._object:set_bottom(self._object:parent():h() - HUDTeammatePeer.DEFAULT_H -
                managers.hud.WOLFGANGHUD_PD2LAYOUT_PADDING - current_bottom_distance)
        end

        self._object:set_alpha(1)
        self._object:set_bottom(self._object:parent():h() - HUDTeammatePeer.DEFAULT_H -
            managers.hud.WOLFGANGHUD_PD2LAYOUT_PADDING)
    end

    function HUDDriving:_animate_hide(...)
        if not managers.hud:wolfganghud_layout_is_pd2() then
            _animate_hide_original(self, ...)
            return
        end

        local duration = 0.25
        local t = (1 - self._object:alpha()) * duration

        while t < duration do
            local dt = coroutine.yield()

            t = t + dt

            local current_alpha = Easing.quartic_out(t, 1, -1, duration)

            self._object:set_alpha(current_alpha)

            local current_bottom_distance = Easing.quartic_out(t, 0, HUDDriving.BOTTOM_DISTANCE_WHILE_HIDDEN, duration)

            self._object:set_bottom(self._object:parent():h() - HUDTeammatePeer.DEFAULT_H -
                managers.hud.WOLFGANGHUD_PD2LAYOUT_PADDING - current_bottom_distance)
        end

        self._object:set_alpha(0)
        self._object:set_bottom(self._object:parent():h() - HUDTeammatePeer.DEFAULT_H -
            managers.hud.WOLFGANGHUD_PD2LAYOUT_PADDING - HUDDriving.BOTTOM_DISTANCE_WHILE_HIDDEN)
        self._object:set_visible(false)
        self:_on_hidden()
    end
elseif string.lower(RequiredScript) == "lib/managers/hud/hudturret" then
    local _create_heat_indicator_original = HUDTurret._create_heat_indicator
    local _create_shell_original = HUDTurret._create_shell

    function HUDTurret:_create_heat_indicator(...)
        _create_heat_indicator_original(self, ...)
        if not managers.hud or not managers.hud:wolfganghud_layout_is_pd2() then
            return
        end

        self._heat_indicator_panel:set_bottom(self._object:h() - HUDTeammatePeer.DEFAULT_H -
            managers.hud.WOLFGANGHUD_PD2LAYOUT_PADDING)
    end

    function HUDTurret:_create_shell(...)
        _create_shell_original(self, ...)
        if not managers.hud or not managers.hud:wolfganghud_layout_is_pd2() then
            return
        end

        self._shell_bg:set_bottom(self._object:h() - HUDTeammatePeer.DEFAULT_H -
            managers.hud.WOLFGANGHUD_PD2LAYOUT_PADDING)
        self._shell_fade:set_center_y(self._shell_bg:center_y())
        self._shell:set_center_y(self._shell_bg:center_y())
    end
elseif string.lower(RequiredScript) == "lib/managers/hud/hudsaveicon" then
    local offset_position_original = HUDSaveIcon.offset_position

    function HUDSaveIcon:offset_position(dx, dy, ...)
        offset_position_original(self, dx, dy, ...)
        if not managers.hud or not managers.hud:wolfganghud_layout_is_pd2() then
            return
        end

        if dx == 0 and dy == 0 then
            self._panel:set_bottom(self._workspace_panel:h() - 80)
            self._panel:set_center_x(self._workspace_panel:w() / 2)
        end
    end
elseif string.lower(RequiredScript) == "lib/managers/hud/hudplayercustody" then
    local _create_spectator_info_original = HUDPlayerCustody._create_spectator_info
    function HUDPlayerCustody:_create_spectator_info(parent, ...)
        _create_spectator_info_original(self, parent, ...)
        if not managers.hud or not managers.hud:wolfganghud_layout_is_pd2() then
            return
        end

        self._spectator_panel:set_bottom(parent:h() - HUDTeammatePeer.DEFAULT_H -
            managers.hud.WOLFGANGHUD_PD2LAYOUT_PADDING)
    end
elseif string.lower(RequiredScript) == "lib/managers/hud/hudstatuseffects" then
    local init_original = HUDStatusEffects.init

    function HUDStatusEffects:init(hud, ...)
        if not self.ORIGINAL_BOTTOM then
            self.ORIGINAL_BOTTOM = self.BOTTOM
        end
        if managers.hud:wolfganghud_layout_is_pd2() then
            self.BOTTOM = 160
        else
            self.BOTTOM = self.ORIGINAL_BOTTOM
        end
        return init_original(self, hud, ...)
    end
end
