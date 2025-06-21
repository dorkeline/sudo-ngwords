{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    systems.url = "github:nix-systems/default-linux";
  };

  outputs = inputs @ {
    self,
    nixpkgs,
    flake-parts,
    ...
  }:
    flake-parts.lib.mkFlake {inherit inputs;} {
      systems = import inputs.systems;

      flake.overlays.default = final: prev: {
        sudo-nx-ngwords = final.sudo.overrideAttrs (old: {
          configureFlags =
            (old.configureFlags or [])
            ++ [
              "--with-insults"
              "--with-goons-insults"
            ];

          patches =
            (old.patches or [])
            ++ [
              ./src/0001-Replace-the-Goons-insults-with-insults-from-the-Nint.patch
            ];
        });
      };

      flake.nixosModules.default = {pkgs, ...}: {
        nixpkgs.overlays = [self.overlays.default];

        security.sudo.package = pkgs.sudo-nx-ngwords;
      };

      perSystem = {pkgs, ...}: {
        packages = let
          pkgs' = self.overlays.default pkgs pkgs;
        in
          pkgs' // {default = pkgs'.sudo-nx-ngwords;};

        formatter = pkgs.alejandra;
      };
    };
}
