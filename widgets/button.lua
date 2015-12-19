
---
-- Button class.
--
-- Buttons are meant to have a `Label` child unless you want to manually draw
-- them.
--
-- Buttons are clickable.
--
-- @classmod Button

local Object = require "object"

local Widget = require "widgets.widget"

local _M = {}

---
-- Button drawing method.
--
-- Uses the `drawButton` theme element to draw itself if available.
--
-- @see Widget:draw
function _M:draw(renderer)
	if not self:themeDraw("Button", renderer) then
		if self.hovered then
			renderer:setDrawColor(0x00FFFF)
		else
			renderer:setDrawColor(0x008888)
		end

		renderer:drawRect(self:rectangle())
	end

	self:drawChildren(renderer)
end

---
-- Button constructor.
--
-- @see Widget:new
function _M:new(arg)
	Widget.new(self, arg)

	self.clickable = true
end

return Object(_M, Widget)

