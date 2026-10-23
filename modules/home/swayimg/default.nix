{ ... }:
{
  programs.swayimg = {
    enable = true;
    initLua = ''
      swayimg.decoration = false
      swayimg.dnd_button = "MouseLeft"
      swayimg.imagelist.adjacent = true
      swayimg.text.visible = false
      swayimg.viewer.default_scale = "fit"
      swayimg.viewer.set_window_background("auto")
      swayimg.slideshow.timeout = 10
    '';
  };
}
