-- General config
swayimg.set_mode("viewer")                -- mode at startup
swayimg.enable_antialiasing(true)         -- anti-aliasing
swayimg.enable_decoration(false)           -- window title/buttons/borders
swayimg.enable_overlay(false)             -- window overlay mode
swayimg.enable_exif_orientation(true)     -- image orientation by EXIF
swayimg.set_dnd_button("MouseLeft")      -- drag-and-drop mouse button

-- Format specific parameters
swayimg.set_format_params('raw', { camera_wb = true }) -- use camera white balance

-- Image list configuration
swayimg.imagelist.set_order("numeric")    -- list order
swayimg.imagelist.enable_reverse(false)   -- reverse order
swayimg.imagelist.enable_recursive(false) -- recursive directory reading
swayimg.imagelist.enable_adjacent(false)  -- add adjacent files from same dir
swayimg.imagelist.enable_fsmon(true)      -- enable file system monitoring

-- Text overlay configuration
swayimg.text.hide()
-- swayimg.text.set_font("monospace")        -- font name
-- swayimg.text.set_size(24)                 -- font size in pixels
-- swayimg.text.set_spacing(0)               -- line spacing
-- swayimg.text.set_padding(10)              -- padding from window edge
-- swayimg.text.set_foreground(0xffcccccc)   -- foreground text color
-- swayimg.text.set_background(0x00000000)   -- text background color
-- swayimg.text.set_shadow(0x0d000000)       -- text shadow color
-- swayimg.text.set_timeout(5)               -- layer hide timeout
-- swayimg.text.set_status_timeout(3)        -- status message hide timeout

-- Image viewer mode
swayimg.viewer.set_default_scale("fit")      -- default image scale
swayimg.viewer.set_default_position("center")    -- default image position
swayimg.viewer.set_drag_button("MouseLeft")      -- mouse button to drag image
swayimg.viewer.set_window_background(0xfff7f7ff) -- window background color
swayimg.viewer.set_image_chessboard(20, 0xff333333, 0xff4c4c4c) -- chessboard
swayimg.viewer.enable_centering(true)            -- enable automatic centering
swayimg.viewer.enable_loop(true)                 -- enable image list loop mode
swayimg.viewer.limit_preload(1)                  -- number of images to preload
swayimg.viewer.limit_history(1)                  -- number of the history cache
swayimg.viewer.set_pinch_factor(1.0)             -- pinch gesture factor

-- bind mouse vertical scroll button with pressed Ctrl to zoom in the image at mouse pointer coordinates
swayimg.viewer.on_mouse("Ctrl-ScrollUp", function()
  local pos = swayimg.get_mouse_pos()
  local scale = swayimg.viewer.get_scale()
  scale = scale + scale / 10
  swayimg.viewer.set_abs_scale(scale, pos.x, pos.y);
end)


-- Slide show mode, same config as for viewer mode with the following defaults:
swayimg.slideshow.set_timeout(5)                    -- timeout to switch image
swayimg.slideshow.set_default_scale("fit")          -- default image scale
swayimg.slideshow.set_window_background("auto")     -- window background mode
swayimg.slideshow.limit_history(0)                  -- number of the history cache
swayimg.slideshow.set_text("topleft", { "{name}" }) -- top left text block scheme


-- Gallery mode
swayimg.gallery.set_aspect("fill")                  -- thumbnail aspect ratio
swayimg.gallery.set_thumb_size(200)                 -- thumbnail size in pixels
swayimg.gallery.set_padding_size(5)                 -- padding between thumbnails
swayimg.gallery.set_border_size(5)                  -- border size for selected thumbnail
swayimg.gallery.set_border_color(0xffaaaaaa)        -- border color for selected thumbnail
swayimg.gallery.set_selected_scale(1.15)            -- scale for selected thumbnail
swayimg.gallery.set_selected_color(0xff404040)      -- background color for selected thumbnail
swayimg.gallery.set_unselected_color(0xff202020)    -- background color for unselected thumbnail
swayimg.gallery.set_window_color(0xff000000)        -- window background color
swayimg.gallery.set_pinch_factor(100.0)             -- pinch gesture factor
swayimg.gallery.enable_hover(true)                  -- enable mouse following
swayimg.gallery.limit_cache(100)                    -- number of thumbnails stored in memory
swayimg.gallery.enable_embedded_thumb(true)         -- use embedded thumbnails
swayimg.gallery.enable_preload(false)               -- preloading invisible thumbnails
swayimg.gallery.enable_pstore(false)                -- enable persistent storage for thumbnails

--
-- Other configuration examples
--

-- force set scale mode on window resize (useful for tiling compositors)
swayimg.on_window_resize(function()
  swayimg.viewer.set_fix_scale("optimal")
end)

