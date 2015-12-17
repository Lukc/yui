
local sdl = require "SDL"
local ttf = require "SDL.ttf"

local Object = require "object"
local Widget = require "widgets.widget"

local _M = {}

_M.backgroundColor = 0x000000

function _M:addChild(child)
	Widget.addChild(self, child)
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
	self.focused = {}

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
end

return Object(_M, Widget)

