# Changelog

All notable changes to RetroRuns are documented here. This file is read
by the CurseForge packager and used as the public release notes.

## [Unreleased]

## [0.5.2] - 2026-04-23

### Changed

- Transmog browser dropdown labels (expansion / raid / boss) now
  reflect the player's current difficulty instead of rolling up all
  four difficulties. A Mythic-mode player browsing Soulrender Dormazain
  now sees a Mythic-slice count; switching difficulty updates the
  numbers. Falls back to the cross-all rollup when no active difficulty
  is known (browsing outside a raid).
- Idle-state list header renamed from "Supported Raids" to
  "Currently supported:" for clearer framing. Rendered in grey to sit
  as a subtle label above the list rather than competing with the
  yellow expansion headings.
- Idle-state "No supported legacy raid detected." and "Travel to a
  supported raid to begin." lines now render at matching font sizes.

### Fixed

- Idle-state list header ("Currently supported:") now renders reliably
  after transitioning from an in-raid state. Previously the header
  could silently disappear due to a layout geometry issue when
  adjacent text fields were empty.

### Infrastructure

- Added CHANGELOG.md and .pkgmeta so CurseForge release notes are
  hand-written going forward instead of being auto-generated from
  git log output.
- Support email (retroruns.support@gmail.com) added to README contact
  list.

## [0.5.1] - 2026-04-23

### Changed

- Transmog summary on the main panel redesigned. Now splits by current
  difficulty vs. other difficulties, with explicit Missing and Shared
  counts per line. Numbers render green when zero, orange otherwise.
  Collapses to "All appearances collected!" when everything is done
  across all four difficulties.

### Fixed

- Main panel no longer resets to its default position on `/reload`
  inside a supported raid. Drag handlers now normalize the frame
  anchor to CENTER/CENTER before saving position, so saved offsets
  correctly round-trip through reload.

### Maintenance

- Data files cleaned up for customer-facing readability. No functional
  changes.

## [0.5.0] - 2026-04-22

### Added

- Castle Nathria (Shadowlands) raid support with weapon-token tracking
  and covenant-aware vendor hints.
- MIT License. Addon is now formally licensed and free to use, modify,
  and redistribute under the MIT terms.

### Changed

- First public release candidate on CurseForge.
