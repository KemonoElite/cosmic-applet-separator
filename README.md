# cosmic-applet-separator

A macOS-style separator applet for the COSMIC dock and panel. It draws a thin
divider line between groups of items (for example between the app tray and the
minimized-windows / workspaces applets). It adapts to panel orientation: a
vertical line on top/bottom panels, a horizontal line on left/right panels.

Laid out like [pop-os/cosmic-applets](https://github.com/pop-os/cosmic-applets),
but contains only this one applet (six separator entries). App ID: `com.kemonoelite.CosmicAppletSeparator`.

## Before the first build

The bundled `Cargo.lock` is upstream's, kept so libcosmic stays pinned to the
same revision. Trim it to this project once and commit the result:

    cargo update --workspace
    # no toolchain installed?  nix shell nixpkgs#cargo nixpkgs#rustc -c cargo update --workspace

Flakes only see files git knows about, so also run `git init && git add -A`
(and `git add` any file you change before rebuilding).

## Build

    just build-release        # or: cargo build --release
    sudo just install         # /usr prefix: binary, .desktop, icon, metainfo

## NixOS

    nix build                 # ./result/bin/cosmic-applet-separator
    nix run
    nix develop               # shell with cargo, clippy, rust-analyzer, just

Use it from your system flake:

    inputs.cosmic-separator.url = "path:/path/to/cosmic-applet-separator";
    # or "github:<you>/cosmic-applet-separator" once pushed

    # NixOS
    environment.systemPackages = [
      inputs.cosmic-separator.packages.${pkgs.stdenv.hostPlatform.system}.default
    ];

    # home-manager
    home.packages = [
      inputs.cosmic-applet-separator.packages.${pkgs.stdenv.hostPlatform.system}.default
    ];

    # or via the overlay: nixpkgs.overlays = [ inputs.cosmic-separator.overlays.default ];
    # then `pkgs.cosmic-applet-separator`

The `.desktop` file lands in `share/applications`, which is how the COSMIC panel
discovers applets.

## Use

The project ships six desktop entries ("Separator" and "Separator 2" through
"Separator 6") that all run the same binary. The panel treats each as its own
applet, and COSMIC only lets you add a given applet once, so six entries means
up to six separators.

Settings -> Desktop -> Dock (or Panel) -> Configure dock applets -> add
"Separator", then drag it to where the divider should sit. Repeat with
"Separator 2", "Separator 3", ... for more dividers.
