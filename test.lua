
local sdl = require "SDL"

local yui = require "init"

local w = yui.Window {
	width = 800,
	height = 600,

	flags = {sdl.window.Resizable},

	title = "Yui Test Window",

	yui.Button {
		width = 180,
		height = 180,

		-- As the parent is not a Container, we’ll be better off just giving
		-- its position.
		x = 100,
		y = 100,

		yui.Button {
			width = 40,
			height = 120,
			x = 0,
			y = 0,

			yui.Button {
				width = 40,
				height = 40,
				x = 0,
				y = 40,

				events = {
					hoverChange = function(self, state)
						print("hoverChange event:", state)
					end
				}
			},
		},
		yui.Button {
			width = 40,
			height = 40,
			x = 40,
			y = 0,
		},
	}
}

while yui:run {w} do end

