# Changelog

All notable changes to the Yapper plugin. The format follows
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/); versions follow
[Semantic Versioning](https://semver.org/).

## [Unreleased]

### Fixed
- Wheel scrolling moves a fixed, comfortable step per notch (160 px instead of
  Qt's 72 px, which was about one message row) and no longer loses distance when
  notches come quickly: Qt used to cancel the previous notch's flick, so five
  fast notches travelled ~200 px instead of 360. Touchpads still track the
  fingers one-to-one, and at the end of a list the step moves the next scroller
  out (the popup body, say) as before.
- The reply/react bar on a message no longer blinks and stays clickable. The
  bar's visibility was bound to the hover of a MouseArea the buttons were
  drawn over, so hovering a button hid the bar, which put the pointer back on
  the message and showed it again; the bar now keeps its own hover and holds
  it across the hand-off from the message. The row highlight itself follows
  the pointer immediately again, so skimming the list leaves no trail.
- A message appears the moment Enter is pressed instead of waiting for the
  daemon to come back from the homeserver (and, in an encrypted room, to
  finish setting up the room key). The row is shown dimmed as pending and is
  named with its real event id when either the send reply or the room's own
  echo arrives; a failed send takes it back and restores the text.
- The community status is asked for one request at a time, with a short
  throttle, and the room list only asks while there is no answer. An
  unreachable space alias used to cost the daemon ~30 s per refresh; a burst
  of those filled its per-connection request queue and held up a send.
- The room list is only replaced when its contents changed, so a receipt or
  a typing notice no longer rebuilds every row.

## [1.0.7]

### Security
- Pins daemon 1.0.2, whose source PKGBUILD no longer overrides the pinned
  Rust toolchain with a moving channel.

## [1.0.6]

### Security
- Pasting an image reads the clipboard in pieces and stops at 64 MiB; a larger
  clipboard image is refused and its partial file removed, so a hostile
  clipboard provider cannot fill the runtime directory.

## [1.0.5]

### Fixed
- The pre-build clean uses `git clean -ffdx`: makepkg's source directory is a
  nested git clone, which the single-force clean skipped, so a second source
  install stopped with "the checkout is not clean after git clean".

## [1.0.4]

### Security
- Pins daemon 1.0.1, which bounds media downloads and ffmpeg, allowlists
  cached attachment extensions, rejects edits from other senders, and caps
  search time, socket requests and remote string lengths.
- Link previews are no longer fetched automatically in encrypted rooms; a
  "Show link preview" chip loads one on request.
- Notification arguments derived from other people's text can no longer be
  read as options by the notification script.
- `bin/pick-files` runs Python in isolated mode.

### Fixed
- Plain-text links containing `&` no longer end up double-escaped.

## [1.0.3]

### Security
- Before `makepkg` runs, the helper reduces the daemon checkout to exactly
  the verified commit with `git clean -fdx` and confirms nothing untracked
  or ignored remains; `makepkg` runs with `-C`, so its source directory is
  recreated from that tree on every build. Nothing from a previous build can
  reach the package. Source builds therefore compile in full every time.

## [1.0.2]

### Security
- Message HTML (`formatted_body`) is rebuilt from an allowlist of formatting
  tags and attributes; every other tag and attribute is dropped and all text
  is re-escaped. Links keep only `https://`, `http://` and `mailto:` targets,
  and every browser launch, from a message link, a link preview or the
  homeserver's sign-in URL, is refused unless the URL has one of those
  schemes.

## [1.0.1]

### Changed
- The plugin installs, reinstalls and updates only the daemon commit pinned
  in the plugin release (`daemonPinCommit`). The run-time lookup of newer
  `pkg-v*` tags is gone; a newer daemon ships as a new plugin release.

## [1.0.0]

### Added
- The Yapper look: rail, sidebar, room view, threads, room info, people,
  explore, search, settings, verification and recovery, with seven palettes,
  per-look color overrides, custom palettes and live color preview. The
  Omarchy look on the shell's own widgets stays available.
- Daemon install from the panel as a pacman package, prebuilt or built from
  source, pinned to one commit of the daemon repository and run in a
  terminal by `bin/yapper-helper`, with a progress card (phase, crates
  compiled, percentage, elapsed time) fed by the helper's state file.
- Quit Yapper in the rail: closes the window and stops the daemon.
- Settings › Daemon: Stop, Start, Restart, Reinstall or switch, Reset the
  data, Remove the package or everything.
- Daemon updates from `pkg-vX.Y.Z` tags, installed the same way.
- File attachments through the desktop portal file chooser.

### Changed
- Every program the plugin runs is named by absolute path; no shell.
- American spelling throughout.

[Unreleased]: https://github.com/marcho78/omarchy-yapper/compare/v1.0.7...HEAD
[1.0.7]: https://github.com/marcho78/omarchy-yapper/compare/v1.0.6...v1.0.7
[1.0.6]: https://github.com/marcho78/omarchy-yapper/compare/v1.0.5...v1.0.6
[1.0.5]: https://github.com/marcho78/omarchy-yapper/compare/v1.0.4...v1.0.5
[1.0.4]: https://github.com/marcho78/omarchy-yapper/compare/v1.0.3...v1.0.4
[1.0.3]: https://github.com/marcho78/omarchy-yapper/compare/v1.0.2...v1.0.3
[1.0.2]: https://github.com/marcho78/omarchy-yapper/compare/v1.0.1...v1.0.2
[1.0.1]: https://github.com/marcho78/omarchy-yapper/compare/v1.0.0...v1.0.1
[1.0.0]: https://github.com/marcho78/omarchy-yapper/releases/tag/v1.0.0
