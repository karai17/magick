local magick = require("magick")
return describe("magick", function()
  it("has a version", function()
    return assert.truthy(magick.VERSION)
  end)
  describe("parse_size_str", function()
    local parse_size_str
    parse_size_str = require("magick.thumb").parse_size_str
    local src_w, src_h = 500, 300
    local tests = {
      {
        "10x10",
        {
          w = 10
        }
      },
      {
        "50%x50%",
        {
          h = 150
        }
      },
      {
        "50%x50%!",
        {
          w = 250,
          h = 150
        }
      },
      {
        "x10",
        {
          h = 10
        }
      },
      {
        "10x%",
        {
          w = 10
        }
      },
      {
        "10x10%#",
        {
          w = 10,
          h = 30,
          center_crop = true
        }
      },
      {
        "200x300",
        {
          w = 200
        }
      },
      {
        "200x300!",
        {
          w = 200,
          h = 300
        }
      },
      {
        "200x300+10+20",
        {
          w = 200,
          h = 300,
          crop_x = 10,
          crop_y = 20
        }
      }
    }
    for _index_0 = 1, #tests do
      local _des_0 = tests[_index_0]
      local size_str, expected
      size_str, expected = _des_0[1], _des_0[2]
      it("parses " .. tostring(size_str) .. " with source size (" .. tostring(src_w) .. ", " .. tostring(src_h) .. ")", function()
        return assert.same(expected, parse_size_str(size_str, src_w, src_h))
      end)
    end
    local more_tests = {
      {
        "10x10",
        {
          w = 10,
          h = 10
        }
      },
      {
        "10x10#",
        {
          w = 10,
          h = 10,
          center_crop = true
        }
      },
      {
        "50%x50%",
        nil,
        "missing source width for percentage scale"
      },
      {
        "50%x50%!",
        nil,
        "missing source width for percentage scale"
      },
      {
        "x10",
        {
          h = 10
        }
      },
      {
        "10x%",
        {
          w = 10
        }
      },
      {
        "10x10%#",
        nil,
        "missing source height for percentage scale"
      },
      {
        "200x300",
        {
          w = 200,
          h = 300
        }
      },
      {
        "200x300!",
        {
          w = 200,
          h = 300
        }
      },
      {
        "200x300+10+20",
        {
          w = 200,
          h = 300,
          crop_x = 10,
          crop_y = 20
        }
      }
    }
    for _index_0 = 1, #more_tests do
      local _des_0 = more_tests[_index_0]
      local size_str, expected, err
      size_str, expected, err = _des_0[1], _des_0[2], _des_0[3]
      it("parses " .. tostring(size_str) .. " with no source size", function()
        return assert.same({
          expected,
          err
        }, {
          parse_size_str(size_str)
        })
      end)
    end
  end)
  describe("image", function()
    local load_image, load_image_from_blob
    load_image, load_image_from_blob = magick.load_image, magick.load_image_from_blob
    local out_path
    out_path = function(fname)
      return "spec/output_images/" .. tostring(fname)
    end
    local img
    before_each(function()
      img = assert(load_image("spec/test_image.png"))
    end)
    it("destroy", function()
      return img:destroy()
    end)
    it("icon", function()
      assert(img:resize(16, 16))
      return assert(img:write(out_path("icon.ico")))
    end)
    it("resize", function()
      assert(img:resize(nil, 80))
      return assert(img:write(out_path("resize.png")))
    end)
    it("with exception", function()
      return assert.has_error(function()
        return assert(img:set_format("butt"))
      end)
    end)
    it("resize_and_crop", function()
      assert(img:resize_and_crop(500, 1000))
      return assert(img:write(out_path("resize_and_crop.png")))
    end)
    it("blur", function()
      assert(img:blur(3, 10))
      return assert(img:write(out_path("blur.png")))
    end)
    it("rotate", function()
      assert(img:rotate(45))
      return assert(img:write(out_path("rotate.png")))
    end)
    it("quality", function()
      assert(img:set_quality(50))
      assert.same(50, img:get_quality())
      return assert(img:write(out_path("quality.jpg")))
    end)
    it("sharpen", function()
      assert(img:sharpen(1))
      return assert(img:write(out_path("sharpen.png")))
    end)
    it("scale", function()
      assert(img:scale(80))
      return assert(img:write(out_path("scale.png")))
    end)
    it("transpose", function()
      assert(img:transpose())
      return assert(img:write(out_path("transpose.png")))
    end)
    it("transverse", function()
      assert(img:transverse())
      return assert(img:write(out_path("transverse.png")))
    end)
    it("flip", function()
      assert(img:flip())
      return assert(img:write(out_path("flip.png")))
    end)
    it("flop", function()
      assert(img:flop())
      return assert(img:write(out_path("flop.png")))
    end)
    it("composite", function()
      local img2 = img:clone()
      assert(img2:resize(32))
      assert(img:composite(img2, 10, 20))
      return assert(img:write(out_path("composite.png")))
    end)
    it("modulate", function()
      local img2 = img:clone()
      assert(img:modulate(50, 50, 50))
      return assert(img:write(out_path("modulate.png")))
    end)
    it("repage", function()
      local img2 = img:clone()
      img2:crop(10, 10, 10, 10)
      return img2:reset_page()
    end)
    it("should make clone", function()
      local before_w, before_h = img:get_width(), img:get_height()
      local cloned = img:clone()
      assert(cloned:resize(50, 20))
      assert.same(before_w, img:get_width())
      assert.same(before_h, img:get_height())
      assert.same(50, cloned:get_width())
      return assert.same(20, cloned:get_height())
    end)
    it("should return blob", function()
      local blob = img:get_blob()
      local blob_img = load_image_from_blob(blob)
      assert.same(img:get_width(), blob_img:get_width())
      return assert.same(img:get_height(), blob_img:get_height())
    end)
    it("should set format", function()
      assert(img:set_format("bmp"))
      return assert.same("bmp", img:get_format())
    end)
    it("should set gravity", function()
      assert(img:set_gravity("SouthEastGravity"))
      return assert.same("SouthEastGravity", img:get_gravity())
    end)
    it("should set option", function()
      assert(img:set_option("webp", "lossless", "0"))
      return assert.same("0", img:get_option("webp", "lossless"))
    end)
    it("should set property", function()
      assert(img:set_property("exif:Orientation", "1"))
      return assert.same("1", img:get_property("exif:Orientation"))
    end)
    it("should get non-existent property", function()
      return assert.same(nil, img:get_property("NonExistentProperty"))
    end)
    it("should set orientation", function()
      assert(img:set_orientation("TopLeftOrientation"))
      return assert.same("TopLeftOrientation", img:get_orientation())
    end)
    it("should not set orientation", function()
      return assert.has_error(function()
        return assert(img:set_orientation("NonExistentOrientation"))
      end)
    end)
    it("should set interlace scheme", function()
      assert(img:set_interlace_scheme("PlaneInterlace"))
      return assert.same("PlaneInterlace", img:get_interlace_scheme())
    end)
    it("should not set interlace scheme", function()
      return assert.has_error(function()
        return assert(img:set_interlace_scheme("NonExistentInterlaceScheme"))
      end)
    end)
    it("gets depth", function()
      local d = img:get_depth()
      return assert.same(8, d)
    end)
    return it("sets depth", function()
      local img2 = img:clone()
      return img2:set_depth(16)
    end)
  end)
  describe("color_image", function()
    local load_image
    load_image = magick.load_image
    local img
    before_each(function()
      img = assert(load_image("spec/color_test.png"))
    end)
    return it("should get colors of pixels", function()
      local r, g, b, a
      local assert_bytes
      assert_bytes = function(er, eg, eb, ea)
        assert.same(er, math.floor(r * 255))
        assert.same(eg, math.floor(g * 255))
        assert.same(eb, math.floor(b * 255))
        return assert.same(ea, math.floor(a * 255))
      end
      r, g, b, a = img:get_pixel(0, 0)
      assert_bytes(217, 70, 70, 255)
      r, g, b, a = img:get_pixel(1, 0)
      assert_bytes(152, 243, 174, 255)
      r, g, b, a = img:get_pixel(1, 1)
      assert_bytes(255, 240, 172, 255)
      r, g, b, a = img:get_pixel(0, 1)
      return assert_bytes(152, 159, 243, 255)
    end)
  end)
  describe("exif #exif", function()
    it("should strip exif data", function()
      local load_image, load_image_from_blob
      load_image, load_image_from_blob = magick.load_image, magick.load_image_from_blob
      local img = load_image("spec/exif_test.jpg")
      img:strip()
      return img:write("spec/output_images/exif_test.jpg")
    end)
    return it("should read exif data", function()
      local load_image
      load_image = magick.load_image
      local img = load_image("spec/exif_test.jpg")
      return assert.same("NIKON D5100", img:get_property("exif:Model"))
    end)
  end)
  describe("automatic orientation", function()
    return it("should automatically orient", function()
      if os.getenv("TRAVIS") then
        return pending("not available on travis")
      end
      local load_image
      load_image = magick.load_image
      local img = load_image("spec/auto_orient_test.jpg")
      assert.same("BottomRightOrientation", img:get_orientation())
      assert(img:auto_orient())
      assert.same("TopLeftOrientation", img:get_orientation())
      return assert(img:write("spec/output_images/auto_orient.jpg"))
    end)
  end)
  describe("thumb", function()
    local thumb
    thumb = magick.thumb
    local sizes = {
      "150x200",
      "150x200#",
      "30x30+20+20"
    }
    for i, size in ipairs(sizes) do
      it("should create thumb for " .. tostring(size), function()
        return thumb("spec/test_image.png", size, "spec/output_images/thumb_" .. tostring(i) .. ".png")
      end)
    end
  end)
  return describe("gif image", function()
    local load_image, load_image_from_blob
    load_image, load_image_from_blob = magick.load_image, magick.load_image_from_blob
    local out_path
    out_path = function(fname)
      return "spec/output_images/" .. tostring(fname)
    end
    local img
    before_each(function()
      img = assert(load_image("spec/test.gif"))
    end)
    return it("coalesce", function()
      assert(img:coalesce())
      return assert(img:write(out_path("coalesce.gif")))
    end)
  end)
end)
