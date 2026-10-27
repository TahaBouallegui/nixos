{ inputs, ... }:
{
  flake.nixosModules.league =
    { pkgs, ... }:
    {
      # Unofficial: runs Riot's *macOS* League client through Darling
      # (userspace Darwin translation, no kernel module, no VM) -- the only
      # way around Vanguard on Linux. Riot-unapproved; the upstream README
      # itself warns of permanent bans: spare account, no ranked.
      # x86_64-linux only. First `darling-lol --installer` builds the
      # patched Darling into a per-user workspace (budget 50+ GB); never
      # delete build/nix-gcroots/ there -- it keeps the mutable runtime's
      # store closure alive against the weekly nix.gc in base/nix.nix.

      environment.systemPackages = [
        inputs.darling-lol.packages.${pkgs.system}.default
      ];

      # Rootless launcher needs a subordinate UID/GID range per user;
      # newuidmap/newgidmap are already setuid-wrapped and unprivileged
      # userns is on, so this is the whole requirement. Materializes the
      # same atb:100000:65536 entry already sitting (undeclared) in
      # /etc/subuid on amal.
      users.users."atb".autoSubUidGidRange = true;
    };
}
