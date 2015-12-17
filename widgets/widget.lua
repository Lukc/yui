
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

function _M:updateChildren()
	for i = 1, #self.children do
		local child = self.children[i]

		if child then
			child.realX = child.x + self.realX
			child.realY = child.y + self.realY

			child:update()
		end
	end
end

function _M:update()
	self:triggerEvent("update")

	self:updateChildren()
end

function _M:triggerEvent(event, ...)
	if self.eventListeners[event] then
		return self.eventListeners[event]
	end
end

function _M:setFocus()
	local root = self:getRoot()

	for i = 1, #root.focused do
		root.focused[i].focused = false

		root.focused[i]:triggerEvent("focusChange")
		root.focused[i]:triggerEvent("focusLost")

		root.focused[i] = nil
	end

	local e = self
	while e.parent do
		e.focused = true

		root.focused[#root.focused+1] = e

		root.focused[i]:triggerEvent("focusChange")
		root.focused[i]:triggerEvent("focusReceived")

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
end

return Object(_M)

