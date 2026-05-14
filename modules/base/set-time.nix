{
  self,
  inputs,
  ...
}: {
  flake.nixosModules.fixed-boot-date = {
    config,
    pkgs,
    lib,
    ...
  }: {
    # Systemd oneshot that runs early in boot
    systemd.services.set-boot-date = {
      description = "Force a fixed date/time on boot";
      wantedBy = ["multi-user.target"];
      before = [
        "systemd-timesyncd.service"
        "chronyd.service"
        "ntpd.service"
      ];
      serviceConfig = {
        Type = "oneshot";
        ExecStart = "${pkgs.coreutils}/bin/date -s '2026-05-14 10:54'";
      };
    };

    # Prevent the clock from being corrected afterwards
    services.timesyncd.enable = lib.mkForce false;

    # If you ever use chrony or ntpd, disable them too:
    # services.chrony.enable = false;
    # services.ntp.enable = false;
  };
}
