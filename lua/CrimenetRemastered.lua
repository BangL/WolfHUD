if string.lower(RequiredScript) == "lib/managers/crimenetmanager" then

	CrimeNetGui.GRID_SAFE_RECT = {1750, 900}
	CrimeNetGui.DIFF_COLORS = {
		Color(0/6, 6/6, 0),	-- normal
		Color(1/6, 5/6, 0),	-- hard
		Color(2/6, 4/6, 0),	-- very hard
		Color(3/6, 3/6, 0),	-- overkill
		Color(4/6, 2/6, 0),	-- mayhem
		Color(5/6, 1/6, 0),	-- death wish
		Color(6/6, 0/6, 0),	-- death sentence
	}

		-- get settings
	local init_original = CrimeNetGui.init
	function CrimeNetGui:init(...)
		self._sort_by_difficulty = JimHUD:getSetting({"CRIMENET", "SORT_BY_DIFFICULTY"}, true)
		self._colorize_by_difficulty = JimHUD:getSetting({"CRIMENET", "COLORIZE_BY_DIFFICULTY"}, true)
		self._reduce_glow = JimHUD:getSetting({"CRIMENET", "REDUCE_GLOW"}, true)
		self._job_scale = JimHUD:getSetting({"CRIMENET", "JOB_SCALE"}, true)
		self._columns = #CrimeNetGui.DIFF_COLORS
		self._rows = 10
		self._margins = {113, 152, 0, 0}
		init_original(self, ...)
	end

	-- callback, which gets called when creating borders
	local _create_polylines_original = CrimeNetGui._create_polylines
	function CrimeNetGui:_create_polylines()
		if JimHUD:getSetting({"CRIMENET", "HIDE_BORDERS"}, true) then
			self._region_locations = {} -- used by _set_zoom()
		else
			_create_polylines_original(self)
		end
	end

	-- callback, which gets called when creating the crimenet grid with random locations
	local _create_locations_original = CrimeNetGui._create_locations
	function CrimeNetGui:_create_locations(...)
		_create_locations_original(self, ...)

		-- replace grid for custom sorting - originally taken from PocoHUD, but optimized.
		if self._sort_by_difficulty then
			local newDots = {}
			for i = 1, self._columns do
				for j = 1, self._rows do
					local newX = self._margins[1] + (CrimeNetGui.GRID_SAFE_RECT[1] - self._margins[1] - self._margins[3]) * i / self._columns
					local newY = self._margins[2] + (CrimeNetGui.GRID_SAFE_RECT[2] - self._margins[2] - self._margins[4]) * ((i % 2 == 0) and j or (j - 0.5)) / self._rows
					table.insert(newDots, {math.round(newX), math.round(newY)})
				end
			end
			self._locations[1][1].dots = newDots -- replace backend data of _get_contact_locations()
		end
	end

	-- callback, which gets called when reserving a position on the grid while creating a new job entry
	local _get_job_location_original = CrimeNetGui._get_job_location
	function CrimeNetGui:_get_job_location(data, ...)
		local result = _get_job_location_original(self, data, ...)

		-- sort by difficulty - originally taken from PocoHUD, but optimized.
		if self._sort_by_difficulty then
			local diff = (data and data.difficulty_id or 2) - 1
			local diffX = self._margins[1] + (CrimeNetGui.GRID_SAFE_RECT[1] - self._margins[1] - self._margins[3]) * diff / self._columns
			local locations = self:_get_contact_locations() -- get next position from self._locations
			local sorted = {}
			for k, dot in pairs(locations[1].dots) do
				if not dot[3] then
					table.insert(sorted, dot)
				end
			end
			if #sorted > 0 then
				local abs = math.abs
				table.sort(sorted, function(a, b)
					return abs(diffX - a[1]) < abs(diffX - b[1])
				end)
				local dot = sorted[1]
				local x, y = dot[1], dot[2]
				local map = self._map_panel:child("map")
				local tw = math.max(map:texture_width(), 1)
				local th = math.max(map:texture_height(), 1)
				x = math.round(x / tw * self._map_size_w)
				y = math.round(y / th * self._map_size_h)
				return x, y, dot
			end
		else
			return result
		end

	end

	-- create job entry
	local _create_job_gui_original = CrimeNetGui._create_job_gui
	function CrimeNetGui:_create_job_gui(data, type, fixed_x, fixed_y, fixed_location, ...)

		-- hack scaling (text size)
		local size = tweak_data.menu.pd2_small_font_size -- keep original scaling
		tweak_data.menu.pd2_small_font_size = size * self._job_scale -- apply temp scaling
		local result = _create_job_gui_original(self, data, type, fixed_x, fixed_y, fixed_location, ...)
		tweak_data.menu.pd2_small_font_size = size -- revert temp scaling

		if result.side_panel then
			-- apply scaling (icon size)
			local job_plan_icon = result.side_panel:child("job_plan_icon")
			local host_name = result.side_panel:child("host_name")
			if job_plan_icon and host_name then
				job_plan_icon:set_size(job_plan_icon:w() * self._job_scale, job_plan_icon:h() * self._job_scale)
				host_name:set_position(job_plan_icon:right() + 2, 0) -- fix align
			end
			-- colorize by difficulty
			local job_name = result.side_panel:child("job_name")
			if self._colorize_by_difficulty and job_name and not data.mutators and not data.is_crime_spree and type ~= "crime_spree" then
				job_name:set_color(CrimeNetGui.DIFF_COLORS[(data.difficulty_id or 2) - 1] or Color.white)
			end
		end
		-- reduce glow
		if result.heat_glow and self._reduce_glow then
			result.heat_glow:set_alpha(result.heat_glow:alpha() * 0.5)
		end
		return result
	end

	-- update job entry
	local update_server_job_original = CrimeNetGui.update_server_job
	function CrimeNetGui:update_server_job(data, i, ...)
		update_server_job_original(self, data, i, ...)

		-- get job data
		local job_index = data.id or i
		local job = self._jobs[job_index]

		-- colorize by difficulty
		if job.side_panel and self._colorize_by_difficulty and not data.mutators and not data.is_crime_spree then
			job.side_panel:child("job_name"):set_color(CrimeNetGui.DIFF_COLORS[(data.difficulty_id or 2) - 1] or Color.white)
		end
	end

elseif string.lower(RequiredScript) == "lib/managers/menu/items/contractbrokerheistitem" then

	local function make_fine_text(text)
		local _, _, w, h = text:text_rect()
		text:set_size(w, h)
		text:set_position(math.round(text:x()), math.round(text:y()))
		return w, h
	end

	function ContractBrokerHeistItem:init(parent_panel, job_data, idx, ...)

		-- set fields
		self._parent = parent_panel
		self._job_data = job_data

		-- get job info
		local job_tweak = tweak_data.narrative:job_data(job_data.job_id)
		local contact = job_tweak.contact
		local contact_tweak = tweak_data.narrative.contacts[contact]
		local dlc_name_text, dlc_color = self:get_dlc_name_and_color(job_tweak)
		local is_dlc = (dlc_name_text ~= nil) and (dlc_name_text ~= "")

		-- get settings
		local line_height = JimHUD:getSetting({"CRIMENET", "BROKER_LINE_HEIGHT"}, 22)
		local line_padding = JimHUD:getSetting({"CRIMENET", "BROKER_LINE_PADDING"}, 1)
		local hide_image = JimHUD:getSetting({"CRIMENET", "BROKER_HIDE_IMAGE"}, true)
		local hide_contact = JimHUD:getSetting({"CRIMENET", "BROKER_HIDE_CONTACT"}, false)
		local hide_dlc = (not is_dlc) or JimHUD:getSetting({"CRIMENET", "BROKER_HIDE_DLC_TAG"}, true)
		local hide_new = (not job_data.is_new) or JimHUD:getSetting({"CRIMENET", "BROKER_HIDE_NEW_TAG"}, true)

		-- enforce max font size values and see if we can fit in two lines accordingly
		local one_line_font_size_max = 22
		local two_line_font_size_max = 48
		local content_height = line_height - line_padding
		local font_size = math.min(content_height * 0.8, one_line_font_size_max)
		local two_lines = false
		if content_height >= one_line_font_size_max * 2 + line_padding then -- usable space is bigger than two lines would be, so..
			two_lines = true -- use two lines
			font_size = math.min(content_height * 0.8 / 2, two_line_font_size_max) -- enforce max font size
		end
		-- pick font by size: small <= one_line_font_size_max > large
		local font = (font_size > one_line_font_size_max) and tweak_data.menu.pd2_large_font or tweak_data.menu.pd2_small_font

		-- get text padding from line padding, but enforce min value
		local min_padding = 3
		local text_padding = math.max(line_padding, min_padding)

		-- create panel
		self._panel = parent_panel:panel({
			halign = "grow",
			layer = 10,
			valign = "top",
			x = 0,
			y = line_height * (idx - 1),
			h = line_height
		})

		-- create background
		self._background = self._panel:rect({
			blend_mode = "add",
			alpha = 0.4,
			halign = "grow",
			layer = -1,
			valign = "grow",
			y = line_padding,
			h = content_height,
			color = job_data.enabled and tweak_data.screen_colors.button_stage_3 or tweak_data.screen_colors.important_1,
			visible = false,
		})

		-- create image panel
		self._image_panel = self._panel:panel({
			halign = "left",
			layer = 1,
			valign = "center",
			x = 0,
			y = line_padding,
			w = not hide_image and content_height * 1.7777777777777777 or 0,
			h = content_height,
			visible = not hide_image,
		})
		-- try get image
		local has_image = false
		if job_tweak.contract_visuals and job_tweak.contract_visuals.preview_image then
			local data = job_tweak.contract_visuals.preview_image
			local path, rect = nil
			if data.id then
				path = "guis/dlcs/" .. (data.folder or "bro") .. "/textures/pd2/crimenet/" .. data.id
				rect = data.rect
			elseif data.icon then
				path, rect = tweak_data.hud_icons:get_icon_data(data.icon)
			end
			if path and DB:has(Idstring("texture"), path) then
				self._image_panel:bitmap({
					valign = "scale",
					layer = 2,
					blend_mode = "add",
					halign = "scale",
					texture = path,
					texture_rect = rect,
					w = self._image_panel:w(),
					h = self._image_panel:h(),
					color = Color.white
				})
				self._image = self._image_panel:rect({
					alpha = 1,
					layer = 1,
					color = Color.black
				})
				has_image = true
			end
		end
		-- fallback image
		if not has_image then
			local color = Color.red
			local error_message = "Missing Preview Image"
			self._image_panel:rect({
				alpha = 0.4,
				layer = 1,
				color = color
			})
			self._image_panel:text({
				vertical = "center",
				wrap = true,
				align = "center",
				word_wrap = true,
				layer = 2,
				text = error_message,
				font = font,
				font_size = font_size
			})
			BoxGuiObject:new(self._image_panel:panel({layer = 100}), {sides = {1, 1, 1, 1}})
		end

		-- create job name
		local job_name = self._panel:text({
			layer = 1,
			vertical = "center",
			align = "left",
			halign = "left",
			valign = "top",
			text = managers.localization:to_upper_text(job_tweak.name_id),
			font = font,
			font_size = font_size,
			color = job_data.enabled and tweak_data.screen_colors.text or tweak_data.screen_colors.important_1
		})
		make_fine_text(job_name)
		if two_lines and not hide_contact then -- two lines and contact visible?
			job_name:set_top(self._image_panel:center_y()) -- y: below contact
		else
			job_name:set_center_y(self._image_panel:center_y()) -- y: center
		end
		-- x: right to image + padding
		job_name:set_left((not hide_image and self._image_panel:right() or 0) + text_padding)

		-- create contact name
		local contact_name = self._panel:text({
			alpha = two_lines and 0.8 or 0.7,
			layer = 1,
			vertical = "center",
			align = "left",
			halign = "left",
			valign = "top",
			text = not hide_contact and managers.localization:to_upper_text(contact_tweak.name_id) or "",
			font = font,
			font_size = font_size * (two_lines and 0.9 or 0.7),
			color = tweak_data.screen_colors.text,
			visible = not hide_contact
		})
		make_fine_text(contact_name)
		if two_linesand and not hide_contact then -- two lines and visible?
			contact_name:set_bottom(self._image_panel:center_y()) -- y: above job name
			contact_name:set_left(job_name:left()) -- x: align with job name
		else
			contact_name:set_center_y(self._image_panel:center_y()) -- y: center
			contact_name:set_left(job_name:right() + text_padding) -- x: right to job name + padding
		end

		-- create dlc tag
		if not hide_dlc then
			local dlc_name = self._panel:text({
				alpha = 1,
				vertical = "top",
				layer = 1,
				align = "left",
				halign = "left",
				valign = "top",
				text = dlc_name_text,
				font = font,
				font_size = font_size * 0.9,
				color = dlc_color
			})
			make_fine_text(dlc_name)
			if two_lines and not hide_contact then -- two lines and contact visible?
				dlc_name:set_bottom(job_name:top()) -- y: above job name
				dlc_name:set_left(contact_name:right() + text_padding) -- x: right to contact name + padding
			else
				dlc_name:set_center_y(job_name:center_y()) -- y: center
				dlc_name:set_left(job_name:right() + text_padding) -- x: right to job name + padding
			end
		end

		-- create new tag
		if not hide_new then
			local new_name = self._panel:text({
				alpha = 1,
				vertical = "top",
				layer = 1,
				align = "left",
				halign = "left",
				valign = "top",
				text = managers.localization:to_upper_text("menu_new"),
				font = font,
				font_size = font_size * 0.9,
				color = Color(255, 105, 254, 59) / 255
			})
			make_fine_text(new_name)
			if two_lines and not hide_contact then -- two lines and contact visible?
				new_name:set_bottom(job_name:top()) -- y: above job name
				new_name:set_left((hide_dlc and contact_name or dlc_name):right() + text_padding) -- x: right to dlc or contact name + padding
			else
				new_name:set_center_y(job_name:center_y()) -- y: center
				new_name:set_left((hide_dlc and job_name or dlc_name):right() + text_padding) -- x: right to dlc or job name + padding
			end
		end

		-- create icon panel
		local icons_panel = self._panel:panel({
			valign = "top",
			halign = "right",
			h = line_height,
			w = self._panel:w(),
		})
		icons_panel:set_right(self._panel:w())
		local last_icon = nil

		-- fav icon
		local icon_size = font_size * 1.1
		self._favourite = icons_panel:bitmap({
			texture = "guis/dlcs/bro/textures/pd2/favourite",
			vertical = "top",
			align = "right",
			halign = "right",
			alpha = 0.8,
			valign = "top",
			color = Color.white,
			w = icon_size,
			h = icon_size,
		})
		self._favourite:set_center_y(job_name:center_y()) -- y: center
		self._favourite:set_right(icons_panel:w() - text_padding) -- x: align right
		last_icon = self._favourite

		-- day icon
		local day_text = icons_panel:text({
			layer = 1,
			vertical = "center",
			align = "right",
			halign = "right",
			valign = "center",
			text = self:get_heist_day_text(),
			font = font,
			font_size = font_size * 0.9,
			color = tweak_data.screen_colors.text
		})
		make_fine_text(day_text)
		day_text:set_center_y(job_name:center_y()) -- y: center
		day_text:set_right(last_icon:left() - text_padding) -- x: left to last icon
		last_icon = day_text

		-- len icon
		local length_icon = icons_panel:text({
			layer = 1,
			vertical = "center",
			align = "right",
			halign = "right",
			valign = "center",
			text = self:get_heist_day_icon(),
			font = font,
			font_size = font_size * 0.7,
			color = tweak_data.screen_colors.text
		})
		make_fine_text(length_icon)
		length_icon:set_center_y(job_name:center_y()) -- y: center
		length_icon:set_right(last_icon:left() - text_padding) -- x: left to last icon
		last_icon = length_icon

		-- stealth icon
		if self:is_stealthable() then
			local stealth = icons_panel:text({
				layer = 1,
				vertical = "center",
				align = "right",
				halign = "right",
				valign = "center",
				text = managers.localization:get_default_macro("BTN_GHOST"),
				font = font,
				font_size = font_size,
				color = tweak_data.screen_colors.text
			})
			make_fine_text(stealth)
			stealth:set_center_y(job_name:center_y()) -- y: center
			stealth:set_right(last_icon:left() - text_padding) -- x: left to last icon
			last_icon = stealth
		end

		-- last played icon
		local last_played = self._panel:text({
			alpha = 0.7,
			vertical = "center",
			layer = 1,
			align = "right",
			halign = "right",
			valign = "center",
			text = self:get_last_played_text(),
			font = font,
			font_size = font_size * (two_lines and 0.8 or 0.7),
			color = tweak_data.screen_colors.text
		})
		make_fine_text(last_played)
		if two_lines then
			last_played:set_bottom(job_name:top())
			last_played:set_right(self._panel:right() - text_padding)
		else
			last_played:set_center_y(job_name:center_y())
			last_played:set_right(last_icon:left() - text_padding * 2)
		end

		-- refresh
		self:refresh()
	end

end