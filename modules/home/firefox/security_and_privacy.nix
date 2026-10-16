{ ... }:
{
  programs.firefox = {
    policies = {
      DisableTelemetry = true;
      DisableFirefoxStudies = true;
      HttpsOnlyMode = "enabled";
      EnableTrackingProtection = {
        Value = true;
        Locked = false;
        Category = "strict";
        Cryptomining = true;
        Fingerprinting = true;
        EmailTracking = true;
        SuspectedFingerprinting = true;
        BaselineExceptions = true;
        ConvenienceExceptions = true;
      };
      DNSOverHTTPS = {
        Enabled = true;
        Locked = false;
        Fallback = false;
      };
      EncryptedMediaExtensions = {
        Enabled = true;
        Locked = true;
      };
    };
    profiles.default.settings = {
      "extensions.formautofill.creditCards.enabled" = false;
      "extensions.formautofill.addresses.enabled" = false;
    };
  };
}
