if string.lower(RequiredScript) == "lib/setups/menusetup" then
    local init_game_original = MenuSetup.init_game

    function MenuSetup:init_game(...)
        local gsm = init_game_original(self, ...)
        if WolfgangHUD:getSetting({ "MENU", "SKIP_INTRO" }, false) then
            gsm:set_boot_intro_done(true)
            gsm:change_state_by_name("menu_titlescreen")
        end
        return gsm
    end
end
