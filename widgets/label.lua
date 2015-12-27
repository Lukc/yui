
---
-- Text box widget.
--
-- @classmod Label

local Object = require "object"

local Widget = require "widgets.widget"

local fonts = require "fonts"

local _M = {}

function _M:update()
	Widget.update(self)

	if self.updateNeeded then
		if self.text and self.text ~= "" then
			local _

			local root = self:getRoot()
			local renderer = root.renderer

			local color = self.color or
				self:themeData("defaultFontColor") or 0xFFFFFF
			local font = self.font or
				self:themeData("defaultFont") or "default"

			self.surface =
				fonts[font]:renderUtf8(self.text, "solid", color)

			self.texture =
				renderer:createTextureFromSurface(self.surface)

			_, _, self.realWidth, self.realHeight =
				self.texture:query()
		else
			self.surface = nil
			self.texture = nil

			self.realWidth, self.realHeight = 0, 0
		end

		self.updateNeeded = false
	end

	if self.align == "left" then
		self.realX = self.parent.realX + self.x
	elseif self.align == "center" then
		self.realX = self.parent.realX + self.x +
			(self.parent.realWidth - self.realWidth) / 2
	elseif self.align == "right" then
		self.realX = self.parent.realX + self.x +
			self.parent.realWidth - self.realWidth
	end

	if self.vAlign == "top" then
		self.realY = self.parent.realY + self.y
	elseif self.vAlign == "middle" then
		self.realY = self.parent.realY + self.y +
			(self.parent.realHeight - self.realHeight) / 2
	elseif self.vAlign == "bottom" then
		self.realY = self.parent.realY + self.x +
			self.parent.realHeight - self.realHeight
	end
end

function _M:draw(renderer)
	renderer:setDrawColor(0xFFFFFF)

	if not self.texture then
		return
	end

	local _, _, width, height = self.texture:query()

	self:drawTexture(renderer, self.texture)
end

---
-- Resets the text displayed in the Label, if any.
-- @param text New text to display.
function _M:setText(text)
	self.text = text

	self.updateNeeded = true
end

---
-- Changes the color of the displayed text.
-- @param color New color.
function _M:setColor(color)
	self.color = color

	self.updateNeeded = true
end

---
-- Label constructor.
--
-- @param arg Table of options, given to `Widget:new`
-- @param arg.text Value given to `Label.setText`
-- @param arg.color Color of the text.
-- @param arg.font Font used to draw the text. Defaults to `yui.fonts.default`.
-- @param arg.align `"left"`, `"center"` or "`right`". Defines how the Label
--  will be aligned in its parent.
-- @param arg.vAlign `"top"`, `"middle"` or "`bottom`". Defines how the Label
--  will be aligned in its parent.
--
-- @see Widget:new
-- @see Label:setText
-- @see Label:setColor
function _M:new(arg)
	if type(arg) == "string" then
		print("String arg.")
		arg = {
			text = arg
		}
	end

	Widget.new(self, arg)

	self:setText(arg.text)

	-- Fallbacks are available in theme data.
	-- Secondary fallbacks are hardcoded and you shouldn’t rely on those.
	self.font = arg.font
	self.color = arg.color

	self.align = arg.align or "left"
	self.vAlign = arg.vAlign or "top"
end

return Object(_M, Widget)

