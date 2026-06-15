{ self, inputs, ... }: {
    flake.nixosModules.distrobox = { config, pkgs, ... }: {
        virtualisation.podman = {
            enable = true;
            dockerCompat = true;
        };
        environment.systemPackages = [ pkgs.distrobox ];
    };
    
}
