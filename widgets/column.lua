
---
-- Column class.
--
-- Columns are containers that edit their children’s position to make them
-- fit as if they had been aligned in a column.
-- 
-- If a child has an `align` property of `center`, it will be horizontally
-- centered in the column.
--
-- @classmod Column

local Object = require "object"

local Widget = require "widgets.widget"

local _M = {}

---
-- Column updating method.
function _M:update(dt)
	local height = 0

	for i = 1, #self.children do
		local child = self.children[i]
		local offset = 0

		if not child.width then
			child.realWidth = self.realWidth
		end

		if self.align == "center" then
			offset = (self.realWidth - child.realWidth) / 2
		end

		child.realY = self.realY + child.y + height
		child.realX = self.realX + offset

		height = height + child.realHeight

		child:update(dt)
	end
end

---
-- Column drawing method.
--
-- If available, uses the `drawColumn` theme element to draw itself.
--
-- @todo Take care of graphical overflows.
-- @see Widget:draw
function _M:draw(renderer)
	if not self:themeDraw("Column", renderer) then
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
end

return Object(_M, Widget)

