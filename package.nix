{
  lib,
  stdenv,
  rustPlatform,
  libcosmicAppHook,
  just,
  util-linuxMinimal,
}:

rustPlatform.buildRustPackage {
  pname = "cosmic-applet-separator";
  version = (lib.importTOML ./cosmic-applet-separator/Cargo.toml).package.version;

  # Only what the build needs, so editing flake.nix / README doesn't rebuild.
  src = lib.fileset.toSource {
    root = ./.;
    fileset = lib.fileset.unions [
      ./Cargo.toml
      ./Cargo.lock
      ./justfile
      ./cosmic-applet-separator
      ./data
      ./i18n
    ];
  };

  # Reads the git dependencies (libcosmic, ...) straight from Cargo.lock,
  # so there is no cargoHash to maintain.
  cargoLock = {
    lockFile = ./Cargo.lock;
    allowBuiltinFetchGit = true;
  };

  nativeBuildInputs = [
    just
    util-linuxMinimal # `rev`, used by the justfile's icon install recipe
    libcosmicAppHook # runtime libs, linker args and wrapping for libcosmic apps
  ];

  # cargoBuildHook already compiles; `just install` only copies files into $out
  # (binary, .desktop, icon, metainfo), exactly like upstream's install target.
  dontUseJustBuild = true;
  dontUseJustCheck = true;

  justFlags = [
    "--set"
    "prefix"
    (placeholder "out")
    "--set"
    "target"
    "${stdenv.hostPlatform.rust.cargoShortTarget}/release"
  ];

  meta = {
    description = "Separator applet for the COSMIC dock and panel";
    license = lib.licenses.gpl3Only;
    mainProgram = "cosmic-applet-separator";
    platforms = lib.platforms.linux;
  };
}
