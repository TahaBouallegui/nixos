{
  flake.nixosModules.remote-builds =
    { ... }:
    {
      # Distributed builds: heavy or uncached derivations (nvidia kernel
      # module, dsh node-modules, texlive assembly) build on robotechServer
      # instead of the laptop, and lingangu's own store doubles as the shared
      # cache — a drv already built there is copied back, never rebuilt.
      # Auth rides Tailscale SSH (tailnet policy grants root@lingangu;
      # cert-based, no keys to distribute; tailscale keeps its ssh host keys
      # stable across restarts). The builder host must never import this
      # module itself.
      nix.distributedBuilds = true;

      # lingangu substitutes from the public caches itself; only genuinely
      # uncached work gets compiled there.
      nix.settings.builders-use-substitutes = true;

      nix.buildMachines = [
        {
          # Tailscale SSH answers non-interactively for root, no sshKey needed.
          sshUser = "root";
          hostName = "lingangu";
          systems = [ "x86_64-linux" ];
          maxJobs = 3;
          speedFactor = 2;
        }
      ];

      programs.ssh.knownHosts = {
        lingangu = {
          extraHostNames = [ "100.68.187.8" ];
          publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBtej8GHEWIm+pz6rZPLdXf1lMh62v/+vetyCPMeek4d";
        };
        lingangu-ecdsa = {
          hostNames = [ "lingangu" "100.68.187.8" ];
          publicKey = "ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBO/a8q8XmTmBGbdqmBphqJeDtAB9JCVf37vs/mu8poJcPkJO/pnZX4VbLpNu7DUVEc7I93E1ua3QnpBMkqTbN18=";
        };
        lingangu-rsa = {
          hostNames = [ "lingangu" "100.68.187.8" ];
          publicKey = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDdtcHxN7kd6yXR9EPAbrvrZ1IPFvAAranfJdaqCJlEvVn59Ekyr6YBsC3waSTRzkE3b+7FkdvshRQFi5way3RPvG3BaHPSWPpRYhkqr8Jb4unjDA70ZQ/mAmIIy615Hze+ZCaj4Brt7fyk6fpeMdDGlFiaJxbnyUHRdyNllskEyRRJI6VlvPe5CGDYYE0IP0Cm5uUiVuR9XrakF8bqcFM2nIS6qObd5lD+Wc5oV8oGu95VeWE8V6kJouJ58xryTrRzgi1XcSfh/S+0sJtU/XThxs2ObtfI3SAFil1/vTdvxBkBjoSsdG62guTzQM4Gno2GFfpUshhPP6bWgjHGj9o5S9tKe6fls81I+9+/LiAYFAB30yxsZiXbLFUTTNDfgGtUA/LWV+mEbyJpIOKFkdg+3lZvT+8x49x0xTvCDemtZxGVMfxGk/Y5G3S6A9nLjoe2x5hU6SnNiOhM998dW2NX8Vku5SDj7hG2xwgeJb2CIflEVldzqrfb7oayDmd+8/VXRS/3jxkyXC7cZMif4JorqcBUtbroSV/APfbcZQLgUXfbFEBCCKSl11VNp5Fz8ItUM6qJ81xxolUtybzpDVCDe6IhoPP3Io6Z+V3yW401sob7BRxKnOj2kV1abSI69Rbo+pPidwiem8z/VsmR/tS9LS8nam54v5n9qTRJbbJwjQ==";
        };
      };
    };
}
