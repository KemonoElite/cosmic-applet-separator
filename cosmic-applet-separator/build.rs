use std::fs;
use xdgen::{App, Context, FluentString};

fn main() {
    let ctx = Context::new("../i18n/", "desktop_entries").unwrap();

    // One desktop entry per separator. They all launch the same binary; the
    // panel treats each ID as its own applet, which is what lets you place
    // several separators (same approach as upstream's cosmic-panel-button).
    [
        (
            "com.kemonoelite.CosmicAppletSeparator",
            "cosmic-applet-separator",
        ),
        (
            "com.kemonoelite.CosmicAppletSeparator2",
            "cosmic-applet-separator-2",
        ),
        (
            "com.kemonoelite.CosmicAppletSeparator3",
            "cosmic-applet-separator-3",
        ),
        (
            "com.kemonoelite.CosmicAppletSeparator4",
            "cosmic-applet-separator-4",
        ),
        (
            "com.kemonoelite.CosmicAppletSeparator5",
            "cosmic-applet-separator-5",
        ),
        (
            "com.kemonoelite.CosmicAppletSeparator6",
            "cosmic-applet-separator-6",
        ),
    ]
    .into_iter()
    .map(|(id, name)| {
        let template_path = ["data/", id, ".desktop"].concat();

        let app = App::new(FluentString(name))
            .comment(FluentString("cosmic-applet-separator-comment"))
            .keywords(FluentString("cosmic-applet-separator-keywords"));

        (id, app.expand_desktop(&template_path, &ctx).unwrap())
    })
    .for_each(|(id, contents)| {
        let parent = "../target/xdgen/";
        fs::create_dir_all(parent).unwrap();
        fs::write([parent, id, ".desktop"].concat().as_str(), contents).unwrap();
    });
}
