
---
-- Window class and constructor.
--
-- @classmod Window

local sdl = require "SDL"
local ttf = require "SDL.ttf"

local Object = require "object"
local Widget = require "widgets.widget"

local _M = {}

---
-- Default window background color.
_M.backgroundColor = 0x000000

---
-- @see Widget:draw
function _M:draw(renderer)
	self:themeDraw("Window", renderer)

	Widget.draw(self, renderer)

	self:triggerEvent("draw", renderer)
end

---
-- Makes it so that no child is marked as being hovered on.
--
-- Triggers the corresponding events accordingly.
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

---
-- Generic events handler.
-- @todo Check all events are related to this window before returning true,
--  which marks the event as being properly processed in yui.run().
function _M:handleEvent(event)
	if event.type == sdl.event.Quit then
		self:triggerEvent("quit")
	elseif event.type == sdl.event.KeyDown then
		self:handleKeyboardEvent("keyDown", event)
		return true
	elseif event.type == sdl.event.KeyUp then
		self:handleKeyboardEvent("keyUp", event)
		return true
	elseif event.type == sdl.event.TextInput then
		self:handleKeyboardEvent("textInput", event)
		return true
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
		self.clickedElement[event.button].clicked = false
		self.clickedElement[event.button] = false

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

---
-- Key press events handler.
--
-- @param eventName Name of the event to handle.
-- @param event An SDL event.
function _M:handleKeyboardEvent(eventName, event)
	for i = #self.focusedElements, 1, -1 do
		local element = self.focusedElements[i]

		if element.handleKeyboardEvent then
			element:handleKeyboardEvent(eventName, event)

			return true
		else
			local r = element:triggerEvent(eventName, event)

			if r then
				return r
			end
		end
	end

	self:triggerEvent(eventName, event)
end

---
-- Triggers `update` and `resize` events on self as needed.
--
-- Its `realWidth` and `realHeight` values are also updated to match the size
-- of the actual SDL window.
--
-- @see Widget:update
function _M:update(dt)
	self.lastWidth, self.lastHeight = self.realWidth, self.realHeight
	self.realWidth, self.realHeight = self.window:getSize()

	if self.lastWidth ~= self.realWidth
	or self.lastHeight ~= self.realHeight then
		self.resized = true

		self:triggerEvent("resize")
	else
		self.resized = false
	end

	self:triggerEvent("update", dt)

	Widget.updateChildren(self, dt)
end

---
-- Constructor.
-- @todo A lot of things are currently stored in Window, but should not.
--  fonts, for example, should be UI-wide, not Window-related.
-- @todo We should not expect to receive SDL flags or constants from the
--  outside. Although it works in the short run, it’ll prove problematic
--  if we decide to support multiple backends later.
--
-- @see Widget
function _M:new(arg)
	Widget.new(self, arg)

	self.root = self
	self.focusedElements = {}
	self.hoveredElements = {}

	-- For further references. This will be replaced by a widget.
	self.clicked = false

	self.fonts = {}

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
			self.exit = true
		end
	end
end

return Object(_M, Widget)

