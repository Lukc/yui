
local sdl = require "SDL"

local yui = require "init"

local w = yui.Window {
	width = 800,
	height = 600,

	flags = {sdl.window.Resizable},

	title = "Yui Test Window",

	yui.Widget {
		width = 180,
		height = 40,

		-- As the parent is not a Container, we’ll be better off just giving
		-- its position.
		x = 100,
		y = 100
	}
}

while yui:run {w} do end

