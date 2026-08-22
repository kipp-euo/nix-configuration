{ ... }:
{
  xdg.mimeApps.defaultApplications."video/*" = [ "mpv.desktop" ];
  programs.mpv = {
    enable = true;
    config = {
      loop-file = "inf";
      loop-playlist = "inf";
      sub-auto = "fuzzy";
      gpu-api = "opengl";
      hwdec = "nvdec";
      scale = "ewa_lanczossharp";
      cscale = "ewa_lanczossharp";
      profile = "high-quality";
      video-sync = "display-resample";
      interpolation = true;

      background-color="#f7f7ff";
    };
  };
}
