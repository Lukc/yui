
local sdl = require "SDL"

local Object = require "object"

local _M = {}

---
-- Default values. Try not to rely on those.
_M.width = nil
_M.height = nil

_M.x = 0
_M.y = 0

-- The real- variants are the values actually used by yurui. They’re calculated
-- not only with the widget’s configuration, but with the parent’s as well.
-- For example, realX will be the child offset (widget.x) plus the parent’s
-- realX.

_M.realWidth = 0
_M.realHeight = 0

_M.realX = 0
_M.realY = 0

---
-- Indicates whether or not a point is located within a widget.
function _M:within(p)
	return
		p.x >= self.realX and p.x < self.realX + self.realWidth and
		p.y >= self.realY and p.y < self.realY + self.realHeight
end

---
-- Adds a child to an element.
function _M:addChild(child)
	self.children[#self.children+1] = child
	child.parent = self

	return self
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

		root.clickedElement = self
		self.clicked = true

		if self.clickable then
			self:triggerEvent("mouseDown", event.button)

			return true
		else
			return self:triggerEvent("mouseDown", event.button)
		end
	end
end

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

		if root.clickedElement == self then
			self:setFocus()

			return self:triggerEvent("click", event.button)
		end
	end
end

function _M:drawChildren(renderer)
	for i = 1, #self.children do
		local child = self.children[i]

		if child then
			child:draw(renderer)
		end
	end
end

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

function _M:update(dt)
	self:triggerEvent("update")

	self:updateChildren(dt)
end

function _M:triggerEvent(event, ...)
	if self.eventListeners[event] then
		return self.eventListeners[event](self, ...)
	end
end

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
-- @todo Triggers too many events (focusLost and focusReceived can both be
--       triggered during a single update).
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
end

return Object(_M)

