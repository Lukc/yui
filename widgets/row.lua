
---
-- Row class.
--
-- Row are containers that edit their children’s position to make them
-- fit as if they had been aligned in a row.
-- 
-- If a child has a `vAlign` property of `middle`, it will be vertically
-- centered in the row.
--
-- @classmod Row

local Object = require "object"

local Widget = require "widgets.widget"

local _M = {}

---
-- Row updating method.
--
-- @todo Maybe… we should factorize this and Column:update?
function _M:update(dt)
	local width = 0

	for i = 1, #self.children do
		local child = self.children[i]
		local offset = 0

		if not child.height then
			child.realHeight = self.realHeight
		end

		if self.vAlign == "middle" then
			offset = (self.realHeight - child.realHeight) / 2
		end

		child.realY = self.realY + offset
		child.realX = self.realX + child.x + width

		if i ~= 1 then
			child.realX = child.realX + (self.spacing or 0) * (i - 1)
		else
			child.realX = child.realX + (self.padding or 0)
		end

		width = width + child.realWidth

		child:update(dt)
	end
end

---
-- Row drawing method.
--
-- If available, uses the `drawRow` theme element to draw itself.
--
-- @todo Take care of graphical overflows.
-- @see Widget:draw
function _M:draw(renderer)
	if not self:themeDraw("Row", renderer) then
		if self.hovered then
			renderer:setDrawColor(0xFF0000)
		else
			renderer:setDrawColor(0x880000)
		end

		renderer:drawRect(self:rectangle())
	end

	self:drawChildren(renderer)
end

---
-- Constructor.
--
-- @see Widget:new
function _M:new(arg)
	Widget.new(self, arg)

	self.align = arg.align

	self.spacing = arg.spacing
end

return Object(_M, Widget)

