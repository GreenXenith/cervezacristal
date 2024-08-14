-- This code is provided under the CC0 1.0 Universal license
-- If that doesn't work for you, it is also licensed under the Unlicense, Public Domain, and WTFPL

local math_abs, math_max, math_min = math.abs, math.max, math.min
local fades = {}

minetest.register_globalstep(function(dtime)
    for i, fade in pairs(fades) do
        local player = minetest.get_player_by_name(fade.player)
        if not player then
            fades[i] = nil
            return
        end

        if fade[1] == 0 then
            fades[i] = nil

            if fade[5] then
                fade[5](player, fade[4])
            end

            return
        end

        local opacity
        if fade[1] < 0 then
            fade[1] = math_min(0, fade[1] + dtime * (1 / fade[2]))
            opacity = 255 * math_abs(fade[1])
        else
            fade[1] = math_max(0, fade[1] - dtime * (1 / fade[2]))
            opacity = 255 * (1 - fade[1])
        end

        player:hud_change(fade[4], "text", fade[3] .. "^[opacity:" .. opacity)
    end
end)

local function hud_fade(player, direction, duration, element, callback)
    local name = player:get_player_name()
    local hud_id, texture

    if type(element) == "number" then
        hud_id = element
        texture = player:hud_get(element).text
    else
        hud_id = player:hud_add({
            hud_elem_type = "image",
            text = element.texture .. "^[opacity:" .. 255 * math_max(0, direction),
            scale = element.scale,
            position = element.position,
            alignment = element.alignment,
        })

        texture = element.texture
    end

    table.insert(fades, {direction, duration, texture, hud_id, callback, player = name})

    return hud_id
end

local function cervezacristal(player)
    local name = player:get_player_name()

    minetest.sound_play("cervezacristal_jingle", {
        to_player = name,
    }, true)

    minetest.after(4, function()
        if player then
            local size_win = minetest.get_player_window_information(name).size
            local size_icn = {x = 789, y = 862}
            local scale_y = (size_win.y / 2) / size_icn.y
            local scale_x = scale_y * (size_icn.x / size_icn.y)

            local logo = hud_fade(player, 1, 0.5, {
                texture = "cervezacristal_logo.png",
                scale = {x = scale_x, y = scale_y},
                position = {x = 0.5, y = 0.5},
                alignment = {x = 0, y = 0},
            })

            minetest.after(4, function()
                if player then
                    hud_fade(player, -1, 0.5, logo, function(p, id) p:hud_remove(id) end)
                end
            end)
        end
    end)
end

minetest.register_node("cervezacristal:cervezacristal", {
    description = "Cerveza Cristal",
    drawtype = "mesh",
    mesh = "cervezacristal.obj",
    tiles = {"cervezacristal.png"},
    inventory_image = "cervezacristal_inv.png",
    selection_box = {type = "fixed", fixed = {-2 / 16, -8 / 16, -2 / 16, 2 / 16, 1 / 16, 2 / 16}},
    collision_box = {type = "fixed", fixed = {-2 / 16, -8 / 16, -2 / 16, 2 / 16, 1 / 16, 2 / 16}},
	paramtype = "light",
    paramtype2 = "facedir",
	sunlight_propagates = true,
	groups = {cracky = 3, oddly_breakable_by_hand = 3},
	sounds = minetest.global_exists("default") and default.node_sound_glass_defaults(),
    after_place_node = function(_, player) cervezacristal(player) end,
})
