{ config, ... }:
{
  hardware.graphics = {
    enable = true;
    # enable32Bit = true;
  };
  services.xserver.videoDrivers = ["nvidia"];
  hardware.nvidia = {
    package = config.boot.kernelPackages.nvidiaPackages.latest;
    # package = config.boot.kernelPackages.nvidiaPackages.stable;

    open = true;
    nvidiaSettings = true;
    modesetting.enable = true;

    powerManagement.enable = false;
    powerManagement.finegrained = false;
  };
  environment.sessionVariables = {
    # __GL_SHADER_DISK_CACHE_SKIP_CLEANUP = "1";
    __GL_SHADER_DISK_CACHE_SIZE = "10737418240"; # 10 GiB
    __GL_LOG_MAX_ANISO = "4"; # Anisotropic filtering 16x for OpenGL
  };
}

