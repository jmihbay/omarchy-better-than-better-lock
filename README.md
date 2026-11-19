# Better Than Better Lock - jmihbay fork of Better Lock

Personal [Omarchy](https://github.com/omacom/omarchy) lock screen, forked from [BibekBhusal0/omarchy-better-lock](https://github.com/BibekBhusal0/omarchy-better-lock).
Plugin ID: `jmihbay.better-lock`. Original MIT license and authorship are preserved.

## What changed

- Current physical keyboard layout below the password field (EN/RU).
- Caps Lock warning appears only while Caps Lock is on.
- Current Omarchy wallpaper, with softer configurable blur and only 15% theme-colored dimming.
- Media player hidden by default, including its keyboard navigation targets.
- Colors/fonts follow Omarchy. Password and fingerprint authentication flows are unchanged.

The lock remains opaque: transparency here means less tint over the wallpaper, never exposing applications behind the lock.

## Install

Only one lock plugin should be enabled. Disable your existing custom lock, then:

```sh
omarchy plugin add https://github.com/jmihbay/omarchy-better-than-better-lock.git --enable --yes
omarchy-shell lock preview
omarchy-shell lock hidePreview
```

Preview is not a real lock. Test actual password/fingerprint unlocking yourself before relying on it.

## Configuration

Optional `~/.config/omarchy/better-lock.json` (see `config.example.json`):

```json
{
  "timeFormat": "HH:mm",
  "dateFormat": "dddd, d MMMM",
  "showKeyboardLayout": true,
  "showCapsLock": true,
  "showMedia": false,
  "showForgotPassword": true,
  "backgroundDim": 0.15,
  "backgroundBlur": 0.65,
  "backgroundBlurMax": 64,
  "backgroundBlurMultiplier": 1.0
}
```

Set `showForgotPassword` to `false` to hide the button and remove it from keyboard navigation. Disabling it also clears its message and cancels a pending screen-blank timer. It is shown by default for compatibility.

The file is re-read every 10 seconds, without restarting the shell. File values take precedence over plugin settings. Numeric settings are validated and clamped: dim/blur 0–1, blurMax 0–128, multiplier 0–2. Lower `backgroundDim` shows more wallpaper; lower `backgroundBlur` reveals more detail. The upstream `lock.json` is not used by this fork.

Keyboard state is refreshed on layout events and once per second only while the lock or preview is visible. Queries have a two-second deadline and a 64 KiB output limit. No network access is used. Caps Lock state comes from Hyprland, not a guessed toggle counter.

## Development and updates

```sh
node --test tests/*.test.cjs
omarchy plugin validate .
```

`origin` is our fork; `upstream` is the original repository. Installed copies update from our fork with `omarchy plugin update jmihbay.better-lock`. Upstream changes are reviewed and merged in this development checkout before pushing to our fork; conflicts are resolved here. Local configuration remains outside the repository.

To restore the previous local lock:

```sh
omarchy plugin disable jmihbay.better-lock
omarchy plugin enable j1z3.lock
```

## Credits

Omarchy's original session lock, Bibek Bhusal's Better Lock interface, and our keyboard indicator and appearance settings. See `LICENSE`.
