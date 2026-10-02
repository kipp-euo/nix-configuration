{ ... }:
{
  # services.auto-cpufreq = {
  #   enable = true;
  #   settings = {
  #     battery = {
  #       governor = "powersave";
  #       turbo = "never";
  #     };
  #     charger = {
  #       governor = "performance";
  #       turbo = "auto";
  #     };
  #   };
  # };
  services.tlp = {
    enable = true;
    settings = {
      CPU_ENERGY_PERF_POLICY_ON_BAT = "power";
      PLATFORM_PROFILE_ON_BAT = "low-power";
      AMDGPU_ABM_LEVEL_ON_BAT = 3;

      SOUND_POWER_SAVE_ON_AC = 0;
      SOUND_POWER_SAVE_ON_BAT = 0;
      WIFI_PWR_ON_BAT = "off";
      WOL_DISABLE = "N";
      NMI_WATCHDOG = 1;
      RUNTIME_PM_ON_BAT = "on";
      USB_AUTOSUSPEND = 0;
    };
  };
}
