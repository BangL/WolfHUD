if string.lower(RequiredScript) == "lib/managers/hudmanagerpd2" then

    local set_suspicion_original = HUDManager.set_suspicion
    function HUDManager:set_suspicion(status, ...)
        set_suspicion_original(self, status, ...)
        if self._hud_suspicion.feed_value then
            if type(status) == "boolean" then
                if status then
                    self._hud_suspicion:feed_value(1)
                end
            else
                self._hud_suspicion:feed_value(status)
            end
        end
    end

elseif string.lower(RequiredScript) == "lib/managers/hud/hudsuspicion" then

    local init_original = HUDSuspicion.init
    function HUDSuspicion:init(hud, sound_source, ...)
        init_original(self, hud, sound_source, ...)

        self._scale = 1
        self._misc_panel = self._suspicion_panel:panel({
            name = "misc_panel"
        })

        local scale = 1.175
        local suspicion_left = self._suspicion_panel:bitmap({
            texture = "guis/textures/pd2/hud_stealthmeter",
            name = "suspicion_left",
            h = 128,
            w = 128,
            alpha = 1,
            layer = 1,
            blend_mode = "add",
            visible = true,
            render_template = "VertexColorTexturedRadial",
            valign = "center",
            color = Color.white
        })

        suspicion_left:set_size(suspicion_left:w() * scale, suspicion_left:h() * scale)
        suspicion_left:set_center_x(self._suspicion_panel:w() / 2)
        suspicion_left:set_center_y(self._suspicion_panel:h() / 2)

        local suspicion_right = self._suspicion_panel:bitmap({
            texture = "guis/textures/pd2/hud_stealthmeter",
            name = "suspicion_right",
            h = 128,
            w = 128,
            alpha = 1,
            layer = 1,
            blend_mode = "add",
            visible = true,
            render_template = "VertexColorTexturedRadial",
            valign = "center",
            color = Color.white
        })

        suspicion_right:set_size(suspicion_right:w() * scale, suspicion_right:h() * scale)
        suspicion_right:set_center(suspicion_left:center())
        suspicion_left:set_texture_rect(128, 0, -128, 128)

        local suspicion_detected = self._suspicion_panel:text({
            name = "suspicion_detected",
            vertical = "center",
            align = "center",
            alpha = 0,
            layer = 2,
            text = utf8.to_upper(managers.localization:text("wolfganghud_suspicion_detected")),
            font_size = tweak_data.menu.pd2_medium_font_size,
            font = tweak_data.menu.pd2_medium_font
        })

        suspicion_detected:set_center(suspicion_left:center())

        local hud_stealth_eye = self._misc_panel:bitmap({
            texture = "guis/textures/pd2/hud_stealth_eye",
            name = "hud_stealth_eye",
            h = 32,
            alpha = 0,
            w = 32,
            layer = 1,
            blend_mode = "add",
            visible = true,
            valign = "center"
        })

        hud_stealth_eye:set_center(suspicion_left:center_x(), suspicion_left:bottom() - 4)

        local hud_stealth_exclam = self._misc_panel:bitmap({
            texture = "guis/textures/pd2/hud_stealth_exclam",
            name = "hud_stealth_exclam",
            h = 32,
            alpha = 0,
            w = 32,
            layer = 1,
            blend_mode = "add",
            visible = true,
            valign = "center"
        })

        hud_stealth_exclam:set_center(suspicion_left:center_x(), suspicion_left:top() - 4)

        self._suspicion_text_panel = self._suspicion_panel:panel({
            name = "suspicion_text_panel",
            visible = true,
            x = 0,
            y = 0,
            h = self._suspicion_panel:h(),
            w = self._suspicion_panel:w(),
            layer = 1
        })

        self._suspicion_text = self._suspicion_text_panel:text({
            name = "suspicion_text",
            visible = true,
            text = "",
            valign = "center",
            align = "center",
            layer = 2,
            color = Color.white,
            font = tweak_data.gui.fonts.din_compressed_outlined_32,
            font_size = 28,
            h = 64
        })
        self._suspicion_text:set_y((math.round(self._suspicion_text_panel:h() / 4)))

        self._eye_animation = nil
        self._suspicion_value = 0
        self._hud_timeout = 0
    end

    function HUDSuspicion:animate_eye()
        if self._eye_animation then
            return
        end

        self._suspicion_value = 0
        self._discovered = nil
        self._back_to_stealth = nil

        self:rescale()

        local visible = WolfgangHUD:getSetting({"HUD", "Suspicion", "SHOW_PD2HUD"}, true)
        self._suspicion_panel:child("suspicion_left"):set_visible(visible)
        self._suspicion_panel:child("suspicion_right"):set_visible(visible)
        self._suspicion_panel:child("suspicion_detected"):set_visible(visible and WolfgangHUD:getSetting({"HUD", "Suspicion", "SHOW_DETECTED_TEXT"}, false))
        self._misc_panel:child("hud_stealth_eye"):set_visible(visible)
        self._misc_panel:child("hud_stealth_exclam"):set_visible(visible)

        local show_ring = WolfgangHUD:getSetting({"HUD", "Suspicion", "SHOW_RING_BG"}, false)
        self._suspicion_panel:child("ring"):set_visible(not show_ring)

        if WolfgangHUD:getSetting({"HUD", "Suspicion", "SHOW_PERCENTAGE_NUMERIC"}, true) and not self._text_animation then
            self._text_animation = self._suspicion_text_panel:animate(callback(self, self, "_animate_text"),
                self._suspicion_text)
        end

        local function animate_func(o, self)
            local wanted_value = 0
            local value = wanted_value
            local suspicion_left = o:child("suspicion_left")
            local suspicion_right = o:child("suspicion_right")
            local suspicion_detected = o:child("suspicion_detected")
            local misc_panel = o:child("misc_panel")

            local function animate_hide_misc(o)
                local hud_stealth_eye = o:child("hud_stealth_eye")
                local start_alpha = hud_stealth_eye:alpha()

                wait(1.8)
                over(0.1, function(p)
                    hud_stealth_eye:set_alpha(math.lerp(start_alpha, 0, p))
                end)
            end

            local function animate_show_misc(o)
                local hud_stealth_eye = o:child("hud_stealth_eye")
                local start_alpha = hud_stealth_eye:alpha()

                over(0.1, function(p)
                    hud_stealth_eye:set_alpha(math.lerp(start_alpha, 1, p))
                end)
            end

            misc_panel:stop()
            misc_panel:animate(animate_show_misc)

            local c = math.lerp(1, 0, math.clamp((value - 0.75) * 4, 0, 1))
            local dt = nil
            local detect_me = false
            local time_to_end = 4

            while true do
                if not alive(o) then
                    return
                end

                dt = coroutine.yield()
                self._hud_timeout = self._hud_timeout - dt

                if self._hud_timeout < 0 then
                    self._back_to_stealth = true
                end

                if self._discovered then
                    self._discovered = nil

                    if not detect_me then
                        detect_me = true
                        wanted_value = 1
                        self._suspicion_value = wanted_value

                        -- self._sound_source:post_event("hud_suspicion_discovered")

                        local function animate_detect_text(o)
                            local c = 0
                            local s = 0
                            local a = 0
                            local font_scale = o:font_scale()

                            over(0.8, function(p)
                                c = math.lerp(1, 0, math.clamp((p - 0.75) * 6, 0, 1))
                                s = math.lerp(0, 1, math.min(1, p * 2))
                                a = math.lerp(0, 1, math.min(1, p * 3))

                                o:set_alpha(a)
                                o:set_font_scale(font_scale * s)
                                o:set_color(Color(1, c, c))
                            end)
                        end

                        suspicion_detected:stop()
                        suspicion_detected:animate(animate_detect_text)
                    end
                end

                if not detect_me and wanted_value ~= self._suspicion_value then
                    wanted_value = self._suspicion_value
                end

                if (not detect_me or time_to_end < 2) and self._back_to_stealth then
                    self._back_to_stealth = nil
                    detect_me = false
                    wanted_value = 0
                    self._suspicion_value = wanted_value

                    misc_panel:stop()
                    misc_panel:animate(animate_hide_misc)
                end

                value = math.lerp(value, wanted_value, 0.9)
                c = math.lerp(1, 0, value)

                if math.abs(value - wanted_value) < 0.01 then
                    value = wanted_value
                end

                suspicion_left:set_position_z(0.5 + value * 0.5)
                suspicion_right:set_position_z(0.5 + value * 0.5)

                local misc_panel = o:child("misc_panel")
                local hud_stealth_exclam = misc_panel:child("hud_stealth_exclam")

                hud_stealth_exclam:set_alpha(math.clamp((value - 0.5) * 2, 0, 1))

                if value == 1 then
                    time_to_end = time_to_end - dt

                    if time_to_end <= 0 then
                        self._eye_animation = nil

                        self:hide()

                        return
                    end
                elseif value <= 0 then
                    time_to_end = time_to_end - dt * 2

                    if time_to_end <= 0 then
                        self._eye_animation = nil

                        self:hide()

                        return
                    end
                elseif time_to_end ~= 4 then
                    time_to_end = 4

                    misc_panel:stop()
                    misc_panel:animate(animate_show_misc)
                end
            end
        end

        -- self._sound_source:post_event("hud_suspicion_start")

        self._eye_animation = self._suspicion_panel:animate(animate_func, self)

    end

    function HUDSuspicion:show()
        self:animate_eye()
        self._suspicion_panel:set_visible(true)
    end

    function HUDSuspicion:hide()
        if self._text_animation then
            self._suspicion_text_panel:stop(self._text_animation)

            self._text_animation = nil
        end

        if self._eye_animation then
            self._suspicion_panel:stop(self._eye_animation)

            self._eye_animation = nil

            -- self._sound_source:post_event("hud_suspicion_end")
        end

        self._suspicion_value = 0
        self._discovered = nil
        self._back_to_stealth = nil

        if alive(self._misc_panel) then
            self._misc_panel:stop()
            self._misc_panel:child("hud_stealth_eye"):set_alpha(0)
            self._misc_panel:child("hud_stealth_exclam"):set_alpha(0)
        end

        if alive(self._suspicion_panel) then
            self._suspicion_panel:set_visible(false)
            self._suspicion_panel:child("suspicion_detected"):stop()
            self._suspicion_panel:child("suspicion_detected"):set_alpha(0)
        end
    end

    function HUDSuspicion:back_to_stealth()
        self._back_to_stealth = true
        self:hide()
    end

    function HUDSuspicion:feed_value(value)
        self:show()
        self._suspicion_value = math.min(value, 1)
        self._hud_timeout = 5
    end

    function HUDSuspicion:rescale()
        local scale = WolfgangHUD:getSetting({"HUD", "Suspicion", "SCALE"}, 1)
        if self._scale ~= scale then
            local suspicion_left = self._suspicion_panel:child("suspicion_left")
            local suspicion_right = self._suspicion_panel:child("suspicion_right")
            local suspicion_detected = self._suspicion_panel:child("suspicion_detected")
            local hud_stealth_eye = self._misc_panel:child("hud_stealth_eye")
            local hud_stealth_exclam = self._misc_panel:child("hud_stealth_exclam")
            suspicion_left:set_size((suspicion_left:w() / self._scale) * scale,
                (suspicion_left:h() / self._scale) * scale)
            suspicion_right:set_size((suspicion_right:w() / self._scale) * scale,
                (suspicion_right:h() / self._scale) * scale)
            suspicion_detected:set_font_size((suspicion_detected:font_size() / self._scale) * scale)
            local fontSize = (self._suspicion_text:font_size() / self._scale) * scale
            self._suspicion_text:set_font_size(fontSize)
            hud_stealth_eye:set_size((hud_stealth_eye:w() / self._scale) * scale,
                (hud_stealth_eye:h() / self._scale) * scale)
            hud_stealth_exclam:set_size((hud_stealth_exclam:w() / self._scale) * scale,
                (hud_stealth_exclam:h() / self._scale) * scale)
            suspicion_left:set_center_x(self._suspicion_panel:w() / 2)
            suspicion_left:set_center_y(self._suspicion_panel:h() / 2)
            suspicion_right:set_center(suspicion_left:center())
            hud_stealth_eye:set_center(suspicion_left:center_x(), suspicion_left:bottom() - 4)
            hud_stealth_exclam:set_center(suspicion_left:center_x(), suspicion_left:top() - 4)
            self._suspicion_text:set_y(suspicion_left:top() + (suspicion_left:center_y() - suspicion_left:top()) / 2 -
                                           self._suspicion_text:font_size() / 2)
            self._scale = scale
        end
    end

    function HUDSuspicion:set_detection(text_item, detection)
        detection = math.clamp(detection, 0, 1)
        local color = math.lerp(WolfgangHUD:getColorSetting({"HUD", "Suspicion", "COLOR_START"}, "white"),
            WolfgangHUD:getColorSetting({"HUD", "Suspicion", "COLOR_END"}, "orange"), detection)
        text_item:set_color(color)
        text_item:set_text(string.format("%d%%", detection * 100))
    end

    function HUDSuspicion:_animate_text(suspicion_panel, suspicion_text)
        while true do
            local detection = self:_is_detected() and 1 or self._suspicion_value or 0
            self:set_detection(suspicion_text, detection)
            coroutine.yield()
        end
    end

    function HUDSuspicion:_is_detected()
        local detected_text = self._suspicion_panel and self._suspicion_panel:child("suspicion_detected")
        return self._discovered or self._suspicion_value and self._suspicion_value >= 1 or detected_text and
                   detected_text:visible() and detected_text:alpha() > 0
    end

end
