// SPDX-License-Identifier: GPL-3.0-only

use crate::window::Window;

mod localize;
mod window;

pub fn run() -> cosmic::iced::Result {
    localize::localize();

    cosmic::applet::run::<Window>(())
}
