
local sdl = require "SDL"
local ttf = require "SDL.ttf"

local Object = require "object"
local Widget = require "widgets.widget"

local _M = {}

_M.backgroundColor = 0x000000

function _M:resetHover(x, y)
	local element
	local i = 1

	while i <= #self.hoveredElements do
		element = self.hoveredElements[i]

		if not element:within {x = x, y = y} then
			break
		end

		i = i + 1
	end

	while i <= #self.hoveredElements do
		local element = self.hoveredElements[i]

		element.hovered = false

		element:triggerEvent("hoverChange", false)
		element:triggerEvent("hoverLost")

		self.hoveredElements[i] = nil

		i = i + 1
	end

	self:setHover(x, y)
end

-- @fixme Check all events are related to this window before returning true,
--        which marks the event as being properly processed in yui.run().
function _M:handleEvent(event)
	if event.type == sdl.event.Quit then
		self:triggerEvent("quit")
	elseif event.type == sdl.event.MouseMotion then
		local _, x, y = sdl.getMouseState()

		self:resetHover(x, y)

		return true
	elseif event.type == sdl.event.MouseButtonDown then
		self:handleMouseButtonDown(event)

		return true
	elseif event.type == sdl.event.MouseButtonUp then
		self:handleMouseButtonUp(event)

		-- Not being clicked on anymore, uh.
		self.clickedElement.clicked = false
		self.clickedElement = false

		return true
	else
		local t

		for k,v in pairs(sdl.event) do
			if event.type == v then
				t = k
				break
			end
		end

		print("Unhandled event:", "SDL.event." .. t)
	end
end

function _M:update()
	self.lastWidth, self.lastHeight = self.realWidth, self.realHeight
	self.realWidth, self.realHeight = self.window:getSize()

	if self.lastWidth ~= self.realWidth
	or self.lastHeight ~= self.realHeight then
		self.resized = true

		self:triggerEvent("resize")
	else
		self.resized = false
	end

	Widget.updateChildren(self)
end

---
-- @todo A lot of things are currently stored in Window, but should not.
--       fonts, for example, should be UI-wide, not Window-related.
-- @todo We should not expect to receive SDL flags or constants from the
--       outside. Although it works in the short run, it’ll prove problematic
--       if we decide to support multiple backends later.
function _M:new(arg)
	Widget.new(self, arg)

	self.root = self
	self.focusedElements = {}
	self.hoveredElements = {}

	-- For further references. This will be replaced by a widget.
	self.clicked = false

	self.fonts = {}

	local r, err = sdl.init {
		sdl.flags.Video
	}

	if not r then
		return nil, err
	end

	r, err = ttf.init()

	if not r then
		return nil, err
	end

	self.window, err = sdl.createWindow {
		flags = arg.flags,
		title = arg.title,

		width = arg.width,
		height = arg.height
	}

	if not self.window then
		return nil, err
	end

	self.renderer, err = sdl.createRenderer(self.window, -1)

	if not self.renderer then
		return nil, err
	end

	-- Default font. In case nothing else could be found later.
	self.fonts[1], err = ttf.open("DejaVuSans.ttf", 36)

	if not self.fonts[1] then
		print(err)
	end

	self.window:setMinimumSize(arg.minWidth or 0, arg.minHeight or 0)

	if not self.eventListeners.quit then
		self.eventListeners.quit = function(self)
			print("Exit requested.")

			self.exit = true
		end
	end
end

return Object(_M, Widget)

