
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

local theme = {
	drawButton = function(self, renderer)
		local rectangle = self:rectangle()

		if self.clicked and self.hovered then
			renderer:setDrawColor(0x44BBFF)
		elseif self.hovered then
			renderer:setDrawColor(0xDDDDDD)
		else
			renderer:setDrawColor(0xCCCCCC)
		end

		renderer:fillRect(rectangle)

		renderer:setDrawColor(0x888888)

		renderer:drawRect(rectangle)
	end,
	drawFrame = function(self, renderer)
		local body = self:rectangle()
		body.h = body.h - self.titleHeight
		body.y = body.y + self.titleHeight
		local header = self:rectangle()
		header.h = self.titleHeight

		renderer:setDrawColor(0xEEEEEE)
		renderer:fillRect(body)

		renderer:setDrawColor(0x333333)
		renderer:fillRect(header)
	end,

	defaultFontColor = 0x000000
}

local w = yui.Window {
	width = 800,
	height = 600,

	flags = {sdl.window.Resizable},

	title = "Yui Test Window",

	theme = theme,

	yui.Frame {
		width = 280,
		height = 180,

		titleHeight = 40,

		-- As the parent is not a Container, we’ll be better off just giving
		-- its position.
		x = 100,
		y = 110,

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
				if button == sdl.mouseButton.Left then
					local state, x, y = sdl.getMouseState()

					self.dndData = {
						x = x - self.realX,
						y = y - self.realY
					}
				end
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

		yui.Column {
			width = 100,
			height = 120,

			y = 50,
			x = 10,

			yui.Button {
				height = 40,

				yui.Label {
					text = "Line 1",
					align = "center",
					vAlign = "middle"
				}
			},
			yui.Button {
				height = 40,

				yui.Label {
					text = "Line 2",
					align = "center",
					vAlign = "middle"
				}
			},
			yui.Button {
				height = 40,

				yui.Label {
					text = "Line 3",
					align = "center",
					vAlign = "middle"
				}
			}
		},

		yui.Button {
			width = 40,
			height = 40,
			x = 120,
			y = 50,
		},

		yui.Label {
			x = 120,
			y = 100,

			events = {
				update = function(self)
					self:setText("FPS: " .. tostring(yui.FPS - yui.FPS % 0.1))
				end
			}
		},
	}
}

while yui:run {w} do end

