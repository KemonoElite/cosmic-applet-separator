// SPDX-License-Identifier: GPL-3.0-only

use cosmic::{
    Element, Task, app,
    applet::{Size, cosmic_panel_config::PanelSize},
    iced::{self, Length, widget::rule::vertical as vertical_rule},
    surface,
    widget::{container, divider},
};

/// Thickness of the separator line, in logical pixels.
const LINE_THICKNESS: u16 = 1;

pub struct Window {
    core: cosmic::app::Core,
}

#[derive(Debug, Clone)]
pub enum Message {
    Surface(surface::Action<Message>),
}

impl cosmic::Application for Window {
    type Message = Message;
    type Executor = cosmic::SingleThreadExecutor;
    type Flags = ();
    const APP_ID: &'static str = "com.kemonoelite.CosmicAppletSeparator";

    fn init(core: cosmic::app::Core, _flags: Self::Flags) -> (Self, app::Task<Message>) {
        (Self { core }, Task::none())
    }

    fn core(&self) -> &cosmic::app::Core {
        &self.core
    }

    fn core_mut(&mut self) -> &mut cosmic::app::Core {
        &mut self.core
    }

    fn style(&self) -> Option<iced::theme::Style> {
        Some(cosmic::applet::style())
    }

    fn update(&mut self, message: Message) -> app::Task<Message> {
        match message {
            Message::Surface(a) => cosmic::task::message(cosmic::Action::Surface(a)),
        }
    }

    fn view(&self) -> Element<'_, Message> {
        let applet = &self.core.applet;
        let is_horizontal = applet.is_horizontal();

        // Same window-size math libcosmic uses for every applet, so the
        // separator is exactly as thick as a regular applet cell.
        let (icon_w, icon_h) = applet.suggested_size(true);
        let (major_padding, minor_padding) = applet.suggested_padding(true);

        // Distance between the line's ends and the panel edge. Same rule the
        // upstream app tray uses for its own pinned/running divider.
        let inset: u16 = match applet.size {
            Size::Hardcoded(_) => 4,
            Size::PanelSize(ref s) => {
                let size = s.get_applet_icon_size_with_padding(false);
                let small_size_threshold = PanelSize::S.get_applet_icon_size_with_padding(false);

                if size <= small_size_threshold { 4 } else { 8 }
            }
        };

        // Breathing room on both sides of the line, along the panel's main axis.
        let gap: u16 = (major_padding / 2).max(2);

        let content: Element<'_, Message> = if is_horizontal {
            // Top/bottom panel: vertical line.
            let cell_height = f32::from(icon_h) + 2.0 * f32::from(minor_padding);
            container(vertical_rule(LINE_THICKNESS))
                .height(Length::Fixed(cell_height))
                .padding([inset, gap])
                .into()
        } else {
            // Left/right panel: horizontal line.
            let cell_width = f32::from(icon_w) + 2.0 * f32::from(minor_padding);
            container(divider::horizontal::default())
                .width(Length::Fixed(cell_width))
                .padding([gap, inset])
                .into()
        };

        self.core.applet.autosize_window(content).into()
    }
}
