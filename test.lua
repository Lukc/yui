
local sdl = require "SDL"

local yui = require "init"

local _, err yui.init()

if err then
	print(err)

	os.exit(42)
end

local _, err = yui:loadFont("default", "DejaVuSans.ttf", 18)

if err then
	print(err)

	os.exit(47)
end

local w = yui.Window {
	width = 800,
	height = 600,

	flags = {sdl.window.Resizable},

	title = "Yui Test Window",

	yui.Frame {
		width = 280,
		height = 170,

		titleSize = 40,

		-- As the parent is not a Container, we’ll be better off just giving
		-- its position.
		x = 100,
		y = 100,

		events = {
			-- Implementing some simple Drag’n’Drop.
			update = function(self)
				if self.dndData then
					local state, x, y = sdl.getMouseState()

					self.x = x - self.dndData.x
					self.y = y - self.dndData.y
				end
			end,
			mouseDown = function(self, button)
				local state, x, y = sdl.getMouseState()

				self.dndData = {
					x = x - self.realX,
					y = y - self.realY
				}
			end,
			mouseUp = function(self, button)
				self.dndData = nil
			end,

			-- More primitive debug here.
			click = function(self, button)
				print("click event:", button)
			end,
			hoverChange = function(self, state)
				print("hoverChange event:", state)
			end
		},

		yui.Label {
			x = 100,
			y = 90,

			text = "",

			events = {
				update = function(self)
					self:setText("FPS: " .. tostring(yui.FPS - yui.FPS % 0.1))
				end
			}
		},

		yui.Button {
			width = 80,
			height = 120,
			x = 10,
			y = 40,

			yui.Label {
				text = "Test",

				align = "center",
				vAlign = "middle",
			},

			events = {
				click = function(self, button)
					print("click event: ", button)
				end,
			},

			yui.Button {
				width = 40,
				height = 40,
				x = 0,
				y = 40,

				events = {
					hoverChange = function(self, state)
						print("hoverChange event:", state)
					end,
					click = function(self)
						-- Let’s block our parents’ onClick.
						return true
					end
				}
			},
		},
		yui.Button {
			width = 40,
			height = 40,
			x = 100,
			y = 40,
		},
	}
}

while yui:run {w} do end

