{
  description = "Separator applet for the COSMIC desktop";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

  outputs =
    { self, nixpkgs }:
    let
      supportedSystems = [
        "x86_64-linux"
        "aarch64-linux"
      ];
      forAllSystems =
        f: nixpkgs.lib.genAttrs supportedSystems (system: f nixpkgs.legacyPackages.${system});
    in
    {
      # pkgs.cosmic-applet-separator, for `nixpkgs.overlays = [ inputs.<name>.overlays.default ];`
      overlays.default = final: _prev: {
        cosmic-applet-separator = final.callPackage ./package.nix { };
      };

      packages = forAllSystems (pkgs: rec {
        cosmic-applet-separator = pkgs.callPackage ./package.nix { };
        default = cosmic-applet-separator;
      });

      devShells = forAllSystems (pkgs: {
        default = pkgs.mkShell {
          nativeBuildInputs = with pkgs; [
            libcosmicAppHook
            just
            util-linuxMinimal
            cargo
            rustc
            clippy
            rustfmt
            rust-analyzer
          ];
          RUST_SRC_PATH = pkgs.rustPlatform.rustLibSrc;
        };
      });
    };
}
