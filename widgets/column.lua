
local Object = require "object"

local Widget = require "widgets.widget"

local _M = {}

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

-- @fixme Take care of overflows.
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

function _M:new(arg)
	Widget.new(self, arg)

	self.align = arg.align
end

return Object(_M, Widget)

