
---
-- Core Widget class.
--
-- @classmod Widget

local sdl = require "SDL"

local Object = require "object"

local _M = {}

--- Default requested widget width.
_M.width = nil
--- Default requested widget height.
_M.height = nil

--- Default requested widget x position.
_M.x = 0
--- Default requested widget y position.
_M.y = 0

-- The real- variants are the values actually used by yurui. They’re calculated
-- not only with the widget’s configuration, but with the parent’s as well.
-- For example, realX will be the child offset (widget.x) plus the parent’s
-- realX.

--- Actual widget width.
-- Should not be edited from outside Yui.
_M.realWidth = 0
--- Actual widget height.
-- Should not be edited from outside Yui.
_M.realHeight = 0

--- Actual widget x position.
-- Should not be edited from outside Yui.
_M.realX = 0
--- Actual widget y position.
-- Should not be edited from outside Yui.
_M.realY = 0

---
-- Indicates whether or not a point is located within the rectangle that
-- represents the drawing area of a widget.
function _M:within(p)
	return
		p.x >= self.realX and p.x < self.realX + self.realWidth and
		p.y >= self.realY and p.y < self.realY + self.realHeight
end

---
-- Adds a child to an element.
--
-- @tparam Widget child
function _M:addChild(child)
	self.children[#self.children+1] = child
	child.parent = self

	return self
end

---
-- Returns a luasdl2 rectangle, usable for drawing operations without further
-- modification.
--
-- The dimensions and coordinates of that rectangle are those of the Widget.
function _M:rectangle()
	return {
		x = self.realX,
		y = self.realY,
		w = self.realWidth,
		h = self.realHeight
	}
end

---
-- Removes a child from an element.
function _M:removeChild(child)
	local root = self:getRoot()
	local found = false
	for i = 1, #root.focused do
		if root.focused[i] == child then
			found = true
		end

		if found then
			root.focused[i] = nil
		end
	end

	for i = 1, #self.children do
		if self.children[i] == child then
			for j = i, #self.children do
					self.children[j] = self.children[j+1]
			end

			return i
		end
	end
end

---
-- Returns an element identified by a given id.
--
-- It does go through the whole tree of widgets to get that element, which
-- might make it better not to call this function repetitively.
function _M:getElementById(id)
	if self.id == id then
		return self
	end

	for i = 1, #self.children do
		local child = self.children[i]
		local r = child:getElementById(id)

		if r then
			return r
		end
	end
end

---
-- Returns the root element of a document.
--
-- Usually, that “root element” would be the window containing the widget.
function _M:getRoot()
	while self.parent do
		self = self.parent
	end

	return self
end

---
-- Internal helper to handle mouse events.
function _M:handleMouseButtonDown(event)
	if self:within(event) then
		for i = 1, #self.children do
			local child = self.children[i]

			if child:within(event) then
				local r = child:handleMouseButtonDown(event)

				if r then
					return r
				end
			end
		end

		local root = self:getRoot()

		root.clickedElement[event.button] = self
		self.clicked = true

		if self.clickable then
			self:triggerEvent("mouseDown", event.button)

			return true
		else
			return self:triggerEvent("mouseDown", event.button)
		end
	end
end

---
-- Internal helper to handle mouse events.
function _M:handleMouseButtonUp(event)
	if self:within(event) then
		for i = 1, #self.children do
			local child = self.children[i]

			if child:within(event) then
				local r = child:handleMouseButtonUp(event)

				if r then
					return r
				end
			end
		end

		self:triggerEvent("mouseUp", event.button)

		local root = self:getRoot()

		if root.clickedElement[event.button] == self then
			self:setFocus()

			return self:triggerEvent("click", event.button)
		end
	end
end

---
-- Draws the children of an element on a given SDL2 renderer.
--
-- @see Widget:draw
function _M:drawChildren(renderer)
	for i = 1, #self.children do
		local child = self.children[i]

		if child then
			child:draw(renderer)
		end
	end
end

---
-- Draws the element on a given SDL2 renderer.
function _M:draw(renderer)
	renderer:setDrawColor(0x000000)
	renderer:drawRect {
		w = self.realWidth,
		h = self.realHeight,
		x = self.realX,
		y = self.realY
	}

	self:drawChildren(renderer)
end

---
-- Updates the children of an element.
function _M:updateChildren(dt)
	for i = 1, #self.children do
		local child = self.children[i]

		if child then
			child.realX = child.x + self.realX
			child.realY = child.y + self.realY

			child:update(dt)
		end
	end
end

---
-- Time-based update of an element.
--
-- Also triggers an `update` event.
function _M:update(dt)
	self:triggerEvent("update", dt)

	if self.width then
		self.realWidth = self.width or self.realWidth
	end

	if self.height then
		self.realHeight = self.height or self.realHeight
	end

	self:updateChildren(dt)
end

---
-- Triggers a specific event.
--
-- If the element has an event listener for that particular event, that
-- listener will be called.
--
-- Any additional parameter will be given to the listener when called.
--
-- @param event The name of the event to trigger.
-- @param ...   Anything to give to the event listener.
function _M:triggerEvent(event, ...)
	if self.eventListeners[event] then
		return self.eventListeners[event](self, ...)
	end
end

---
-- Marks an element as being hovered by a mouse cursor.
function _M:setHover(x, y)
	if not self.hovered then
		local root = self:getRoot()

		root.hoveredElements[#root.hoveredElements+1] = self

		self.hovered = true

		self:triggerEvent("hoverChange", true)
		self:triggerEvent("hoverReceived")
	end

	for i = 1, #self.children do
		local child = self.children[i]

		if child:within {x = x, y = y} then
			child:setHover(x, y)
		end
	end
end

---
-- Marks an element being focused.
--
-- Focused elements are the only elements that can receive key press events.
--
-- @todo Triggers too many events (focusLost and focusReceived can both be
--  triggered during a single update).
function _M:setFocus()
	local root = self:getRoot()

	for i = 1, #root.focusedElements do
		root.focusedElements[i].focused = false

		root.focusedElements[i]:triggerEvent("focusChange", false)
		root.focusedElements[i]:triggerEvent("focusLost")

		root.focusedElements[i] = nil
	end

	local fe = root.focusedElements

	local e = self
	while e.parent do
		e.focused = true

		fe[#fe+1] = e

		e:triggerEvent("focusChange", true)
		e:triggerEvent("focusReceived")

		e = e.parent
	end
end

---
-- Gets a theme value for a given element.
--
-- If the element has no theme or an incomplete theme, the value will be
-- looked for in its parents.
--
-- If no parent has the required property, the method will return `nil`.
function _M:themeData(name)
	local element = self

	while element do
		if element.theme and element.theme[name] then
			return element.theme[name]
		end

		element = element.parent
	end
end

---
-- Calls a theme drawing function.
--
-- @see Widget:themeData
function _M:themeDraw(name, renderer)
	local name = "draw" .. name

	local cb = self:themeData(name)

	if cb then
		cb(self, renderer)

		return true
	end
end

---
-- Widget constructor.
--
-- The `height`, `width`, `x` and `y` values can be ignored by specific
-- parents.
--
-- @param arg Table of options. The first integer-indexed values are treated
--  as children to append to the widget.
-- @param arg.height Requested height of the Widget.
-- @param arg.width Requested Width of the Widget.
-- @param arg.x Requested x position.
-- @param arg.y Requested y position.
-- @param arg.theme Widget’s theme, if any.
-- @param arg.id Unique identifier.
-- @param arg.events Table of event listeners. The keys are event names.
function _M:new(arg)
	self.children = {}

	-- Will probably be useful for top-level elements. Much less for
	-- the others.
	self.ids = {}

	for i = 1, #arg do
		self:addChild(arg[i])
	end

	for _, key in pairs {"height", "width", "x", "y"} do
		self[key] = arg[key]
	end

	self.eventListeners = {}

	if arg.events then
		for eventName, listener in pairs(arg.events) do
			self.eventListeners[eventName] = listener
		end
	end

	self.realHeight = self.height
	self.realWidth = self.width

	self.id = arg.id

	self.focused = false
	self.hovered = false

	-- Button-indexed.
	self.clickedElement = {}

	self.theme = arg.theme
end

return Object(_M)

