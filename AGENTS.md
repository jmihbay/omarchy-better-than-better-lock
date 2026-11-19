# Agent guide

## Purpose and layout

Better Than Better Lock is an Omarchy Quattro/Quickshell session-lock plugin,
forked from BibekBhusal0/omarchy-better-lock. Our plugin ID is
`jmihbay.better-lock`; the repository name is different from the plugin ID.
It adds physical keyboard layout and Caps Lock indicators, configurable wallpaper
effects, and optional media and Forgot password controls. Colors/fonts follow Omarchy.

- `Service.qml`: session lock, PAM, configuration, wallpaper lookup and IPC.
- `LockView.qml`: visuals, controls and keyboard navigation.
- `KeyboardStatus.qml` / `KeyboardState.js`: bounded keyboard query and state parsing.
- `manifest.json`: plugin identity, defaults and settings schema.
- `config.example.json`: example user configuration; not loaded automatically.

## Installing for a user

Follow the user's instructions and existing authorization. Inspect `README.md`,
`omarchy plugin list`, and the existing configuration before changing anything.
Record the currently enabled lock plugin and back up settings you will modify.
Do not assume this machine's username, paths, existing lock plugin, or preferences.

Install from `https://github.com/jmihbay/omarchy-better-than-better-lock.git` with
`omarchy plugin add`. Only one lock plugin should be enabled: replace the user's
existing lock deliberately, keeping it available for rollback. Do not modify
`/usr/share/omarchy/` or PAM files. Honor the installed Omarchy customization skill
when available. If cloning a development checkout, establish its name/location
with the user or use their established project layout.

After installation, proactively explain the optional config and offer to tailor
it. Installation alone does not require creating or overwriting a config. Merge
requested keys into existing JSON, preserving unrelated preferences. Prefer user
configuration over source edits for supported settings.

## Configuration to discuss

The file is `~/.config/omarchy/better-lock.json`, NOT upstream's `lock.json`.
See `config.example.json` and the README for the full defaults. File values override
plugin settings and are re-read approximately every 10 seconds.

- `language`: `auto` follows Omarchy, `en` and `ru` override the lock screen language.
- `timeFormat`, `dateFormat`: Qt date/time patterns; offer 12/24-hour preference.
- `showKeyboardLayout`, `showCapsLock`: default true; Caps Lock text appears only when on.
- `allowFingerprint`: defaults to true. Set false to hide the indicator and disable fingerprint authentication in this plugin.
- `screenOffSeconds`, `suspendSeconds`, `forgotPasswordScreenOffSeconds`: delays in seconds. Default 15, 45, and 3.5 respectively. Zero disables the corresponding timer.
- `showMedia`: default false; controls MPRIS player visibility and focus targets.
- `showForgotPassword`: default true. Offer false if the user wants a simpler lock.
  This button is NOT password recovery: it displays a message and blanks the screen.
- `backgroundDim`: 0–1, default 0.15; lower means less tint over current wallpaper.
- `backgroundBlur`: 0–1, default 0.65; lower reveals more wallpaper detail.
- `backgroundBlurMax`: 0–128, default 64; `backgroundBlurMultiplier`: 0–2, default 1.

Explain that “transparency” means wallpaper visibility, never showing applications
through a locked session. Do not silently apply this fork maintainer's local choices.

## Verification and rollback

Use `omarchy-shell lock preview` and always close it with
`omarchy-shell lock hidePreview` after inspection. Preview does not lock the session.
Do not trigger a real lock merely to test appearance; arrange an actual unlock test
with the user, who enters their own password. Report what remains untested.
Never restart/unload a lock service while the session is locked. If service code
needs a shell restart, first check `omarchy-shell lock status` and wait for an unlocked
session. Restore the previously recorded lock plugin if enabling this one fails.

Installed plugins update with `omarchy plugin update jmihbay.better-lock`; configs
remain outside Git. Do not reset or overwrite a user's modified plugin checkout.

## Changing the code

Run `node --test tests/*.test.cjs`, `omarchy plugin validate .`, and
`git diff --check`; validate visual changes in preview too. Keep documentation,
manifest defaults/schema, and `config.example.json` consistent. Use
`Commons.Color` with an explicit `import qs.Commons as Commons`, and `ShellIpc`
for current Omarchy IPC. Treat device names, metadata and configuration strings as
untrusted; render them as plain text. Keep keyboard queries bounded and inactive
when the lock/preview is hidden. Preserve authentication behavior when editing UI.
