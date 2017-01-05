-- Copyright Tai "DuCake" Kedzierski 2017
-- Provided to you under the terms of the GNU Lesser General Pulbic License v3.0
-- You may copy, modify and redistribute this software as long as you provide
-- these same rights to those to whom you distribute the software to, and provide the
-- source code of your version on request from those same people.
-- See gnu.org for more information.

-- ========================================================

-- This mod causes the block to cast light downwards for a far distance

minetest.register_node("spotlight:luminance",{
	drawtype = "airlike",
	paramtype = "light",
	light_source = 10,
	sunlight_propagates = true,
	pointable = false,
	buildable_to = true,
	walkable = false,
	groups = {luminance = 1},
})


minetest.register_node("spotlight:lamp",{
	paramtype = "light",
	light_source = 14,
	sunlight_propagates = true,
	tiles = {"default_meselamp.png^[colorize:blue:100"},
	groups = {cracky = 3, luminance_source = 1},
	sounds = default.node_sound_glass_defaults(),
})

local function cascade_down(pos, fromnode, destnode)
	local nodename = minetest.get_node(pos).name
	
	local i = 0
	while nodename == fromnode do
		minetest.swap_node(pos, {name=destnode})

		pos = {x=pos.x, y=pos.y-1, z=pos.z}
		nodename = minetest.get_node(pos).name
		i = i+1
	end
end

minetest.register_abm({
	nodenames = "group:luminance",
	interval = 1,
	chance = 1,
	catch_up = false,
	action = function(pos)
		local over = {x=pos.x, y=pos.y+1, z=pos.z}
		local under = {x=pos.x, y=pos.y-1, z=pos.z}

		local overnode = minetest.registered_nodes[minetest.get_node(over).name]
		local undernode = minetest.get_node(under).name
		if overnode.groups then
			if not ( overnode.groups.luminance_source or overnode.groups.luminance ) then
				cascade_down(pos, "spotlight:luminance", "air")
				return
			elseif undernode == "air" then
				cascade_down(under, "air", "spotlight:luminance")
			end
		end
	end
})

minetest.register_abm({
	nodenames = "group:luminance_source",
	interval = 1,
	chance = 1,
	catch_up = false,
	action = function(pos)
		local under = {x=pos.x, y=pos.y-1, z=pos.z}

		local undernode = minetest.get_node(under).name
		if undernode == "air" then
			cascade_down(under, "air", "spotlight:luminance")
		end
	end
})
