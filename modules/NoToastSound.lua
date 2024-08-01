local _animate_present_original = HUDToastNotification._animate_present

function HUDToastNotification:_animate_present(panel, duration, ...)
    if not (WolfgangHUD and WolfgangHUD:getSetting({ "SOUND", "MUTE_TOASTS" }, false)) then
        _animate_present_original(self, panel, duration, ...)
        return
    end

    -- sadly we must copy the entire func, as the sound calls are inline

    local x_travel = 60
    local blink_duration = 0.62
    local fade_in_duration = 0.38
    local fade_out_duration = 0.36
    local sustain_duration = duration - blink_duration
    local t = 0

    self._object:set_alpha(1)
    self._title:set_alpha(0)
    self._text:set_alpha(0)
    self._icon:set_alpha(0)
    self._icon_panel:set_alpha(0)
    self._background:set_w(0)
    self._object:set_center_x(self._object:parent():w() / 2)
    self._background:set_center_x(self._object:w() / 2)
    --managers.hud:post_event("objective_activated_in")

    while t < blink_duration do
        local dt = coroutine.yield()
        t = t + dt
        local current_alpha = 0.3 + math.abs(math.sin(t * 680)) * 0.7

        self._icon:set_alpha(current_alpha)

        current_alpha = Easing.quintic_out(t, 0, 1, blink_duration * 0.35)

        self._icon_panel:set_alpha(current_alpha)

        local current_icon_size = HUDToastNotification.ICON_SIZE * current_alpha

        self._icon:set_size(current_icon_size, current_icon_size)
        self._icon:set_center(self._icon_panel:w() / 2, self._icon_panel:h() / 2)
    end

    self._icon:set_alpha(1)
    self._icon_panel:set_alpha(1)

    t = 0

    while fade_in_duration > t do
        local dt = coroutine.yield()
        t = t + dt
        local current_alpha = Easing.quartic_out(t, 0, 1, fade_in_duration * 0.75)

        self._icon_panel:set_alpha(1 - current_alpha)
        self._title:set_alpha(current_alpha)
        self._text:set_alpha(current_alpha)

        local current_kern = -(1 - current_alpha) * 10

        self._title:set_kern(current_kern)
        self._text:set_kern(current_kern)

        local current_width = Easing.quintic_out(t, 0, HUDToastNotification.W, fade_in_duration)

        self._background:set_w(current_width)
        self._background:set_center_x(self._object:w() / 2)

        local current_icon_size = HUDToastNotification.ICON_SIZE + current_width * 0.33

        self._icon:set_size(current_icon_size, current_icon_size)
        self._icon:set_center(self._icon_panel:w() / 2, self._icon_panel:h() / 2)
    end

    self._object:set_alpha(1)
    self._title:set_alpha(1)
    self._text:set_alpha(1)
    self._text:set_kern(0)
    self._icon_panel:set_alpha(0)
    self._background:set_w(HUDToastNotification.W)
    self._background:set_center_x(self._object:w() / 2)
    self._text:stop()
    self._text:animate(UIAnimation.animate_text_glow, HUDToastNotification.TEXT_GLOW_COLOR, 0.48, 0.042, 0.8)
    wait(sustain_duration)
    --managers.hud:post_event("objective_activated_out")

    t = 0

    while fade_out_duration > t do
        local dt = coroutine.yield()
        t = t + dt
        local current_alpha = Easing.quartic_in_out(t, 1, -1, fade_out_duration)

        self._object:set_alpha(current_alpha)

        local current_offset = math.lerp(0, x_travel, 1 - current_alpha)

        self._object:set_center_x(self._object:parent():w() / 2 + current_offset)
        self._text:set_center_x(self._object:w() / 2 + current_offset * 1.4)
    end

    self._object:set_alpha(0)
    self._object:set_center_x(self._object:parent():w() / 2)
    self._text:stop()
    self._text:set_text("")
    self:_present_done()
end
