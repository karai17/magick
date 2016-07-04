local ffi = require("ffi")
local lib, can_resize
do
  local _obj_0 = require("magick.wand.lib")
  lib, can_resize = _obj_0.lib, _obj_0.can_resize
end
lib.MagickWandGenesis()
local Image
Image = require("magick.wand.image").Image
return {
  mode = "image_magick",
  Image = Image,
  load_image = (function()
    local _base_0 = Image
    local _fn_0 = _base_0.load
    return function(...)
      return _fn_0(_base_0, ...)
    end
  end)(),
  load_image_from_blob = (function()
    local _base_0 = Image
    local _fn_0 = _base_0.load_from_blob
    return function(...)
      return _fn_0(_base_0, ...)
    end
  end)()
}