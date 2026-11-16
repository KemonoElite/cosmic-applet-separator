rootdir := ''
prefix := '/usr'
clean := '0'
debug := '0'
vendor := '0'
target := if debug == '1' { 'debug' } else { 'release' }
vendor_args := if vendor == '1' { '--frozen --offline' } else { '' }
debug_args := if debug == '1' { '' } else { '--release' }
cargo_args := vendor_args + ' ' + debug_args
targetdir := env('CARGO_TARGET_DIR', 'target')
sharedir := rootdir + prefix + '/share'
iconsdir := sharedir + '/icons/hicolor'
prefixdir := prefix + '/bin'
bindir := rootdir + prefixdir
metainfo := 'com.kemonoelite.CosmicAppletSeparator.metainfo.xml'
metainfo-src := 'data' / metainfo
metainfo-dst := clean(rootdir / prefix) / 'share' / 'metainfo' / metainfo
applet-ids := 'com.kemonoelite.CosmicAppletSeparator com.kemonoelite.CosmicAppletSeparator2 com.kemonoelite.CosmicAppletSeparator3 com.kemonoelite.CosmicAppletSeparator4 com.kemonoelite.CosmicAppletSeparator5 com.kemonoelite.CosmicAppletSeparator6'

default: build-release

# Compiles with debug profile
build-debug *args:
    cargo build {{ args }}

# Compiles with release profile
build-release *args: (build-debug '--release' args)

# Compile with a vendored tarball
build-vendored *args: vendor-extract (build-release '--frozen --offline' args)

_install_icons name:
    find {{ name }}/'data'/'icons' -type f -exec echo {} \; | rev | cut -d'/' -f-3 | rev | xargs -d '\n' -I {} install -Dm0644 {{ name }}/'data'/'icons'/{} {{ iconsdir }}/{}

_install_desktops:
    for id in {{ applet-ids }}; do install -Dm0644 target/xdgen/$id.desktop {{ sharedir }}/applications/$id.desktop; done

_install_bin name:
    install -Dm0755 {{ targetdir }}/{{ target }}/{{ name }} {{ bindir }}/{{ name }}

_install_metainfo:
    install -Dm0644 {{ metainfo-src }} {{ metainfo-dst }}

# Installs files into the system
install: (_install_bin 'cosmic-applet-separator') (_install_icons 'cosmic-applet-separator') _install_desktops _install_metainfo

# Vendor Cargo dependencies locally
vendor:
    mkdir -p .cargo
    cargo vendor --locked | head -n -1 > .cargo/config
    echo 'directory = "vendor"' >> .cargo/config
    tar pcf vendor.tar vendor
    rm -rf vendor

# Extracts vendored dependencies
[private]
vendor-extract:
    rm -rf vendor
    tar pxf vendor.tar
