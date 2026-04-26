{
    flake.nixosModules.kicad = { pkgs-stable, ... }: {
        environment.systemPackages = 
            [
                pkgs-stable.kicad
            ];
    };
}
