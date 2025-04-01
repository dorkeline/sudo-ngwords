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
        sudo-nx-ngwords = prev.sudo.overrideAttrs (old: {
          configureFlags =
            old.configureFlags
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
        nixpkgs.overlays = [self.nixosModules.default];

        security.sudo.package = pkgs.sudo-nx-ngwords;
      };

      perSystem = {pkgs, ...}: {
        packages = let
          myPkgs = self.overlays.default pkgs pkgs;
        in
          myPkgs // {default = myPkgs.sudo-nx-ngwords;};

        formatter = pkgs.alejandra;
      };
    };
}
