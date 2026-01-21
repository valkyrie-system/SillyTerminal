# Valkyrie Terminal Ricing

A heavily customized Fish shell config with sound effects, meme commands, and absolutely unhinged aliases. Built for Arch Linux with yay/pacman, though most bits should work anywhere.

## What This Is

This is a terminal setup that decided it wanted to be a video game. Commands have sound effects. Package managers play loops. File deletion has a confirmation battle sequence with Earthbound music. It's chaotic. It's fun. It works.

The core philosophy: if you're going to spend eight hours a day in a terminal, it should be entertaining.

## Installation

1. **Copy the config:**
   ```bash
   cp config.fish ~/.config/fish/config.fish
   ```

2. **Create the sound directory:**
   ```bash
   mkdir -p ~/Tools/terminal-sounds
   ```

3. **Add your sound files** to `~/Tools/terminal-sounds/` as `.mp3` files. Exact names matter—see [Sounds](#sounds) section.

4. **Restart Fish:**
   ```bash
   exec fish
   ```

If you hear `oo-ee-ee-aa.mp3` on startup, you're golden.

---

## Core Commands

### Package Management (`3`, `:33`, `:333`)

These are shortcuts for pacman/yay with built-in sound loops and victory fanfares.

```bash
:3 firefox          # Install (plays cute-uwu.mp3, loops earthbound-what-battle-moment)
:33 firefox         # Sync + Install (cute-uwu twice, same loop)
:333 firefox        # Update + Install (cute-uwu thrice, same loop)
:3 firefox q-q      # Uninstall (plays lacrimosa.mp3)
pls :3 firefox      # Sudo install (pls.mp3 first, then cute-uwu)
```

Success triggers `earthbound-you-win.mp3`. Failure triggers `aw-dang-it.mp3`.

**Why three colons?** Because spamming `:3 :3 :3` is funnier.

### File Operations

```bash
smash /path/to/thing    # rm -rf with an interactive battle sequence
                        # Asks "Are you ready for battle?"
                        # Type 'y' for earthbound-partner-turn, proceeds to deletion + earthbound-you-win
                        # Type 'n' for earthbound-enemy-turn, cancels deletion

mine                    # eza -al (lists files, claims ownership vibes)
                        # Plays mine-mine-mine.mp3

nope                    # cd .. (go back one directory)
                        # Plays nope.mp3

backrooms              # cd .... (go back four directories)
                       # Plays burning-memory.mp3

dox-em                 # eza -a (lists everything including dotfiles)
                       # Plays allbase.mp3
```

### Navigation & Flex

```bash
plsgo /path            # cd + clear + list files
                       # Plays ack.mp3

flex                   # Shows system info via hyfetch + hwinfo
                       # Plays can-you-feel-my-heart.mp3

touch-grass            # Exit terminal
                       # Plays metal-pipe-falling.mp3
```

### System Commands

```bash
fuckoff                # Shutdown (plays fahhhhhhhhhhhhhhh.mp3)
:P                     # Restart (plays lizard-button.mp3 four times)
lets-go-gambling       # Update everything (pacman + yay + flatpak)
                       # Loops earthbound-what-battle-moment during updates
                       # Plays lets-go-gambling-win.mp3 on success
gotta-go-fast          # Update mirrors (plays sonic-x-theme loop)
                       # Ends with haha-ha-one.mp3
```

### Utilities

```bash
pls <cmd>              # Run with sudo (plays pls.mp3)
pls <cmd> iforgor      # Show sudo help + no-i-forgot.mp3
iforgor <cmd>          # Show command help + no-i-forgot.mp3
sound-volume 50        # Set global volume (0-100)
with-sounds <cmd>      # Wrap any interactive command with y/n sounds
                       # 'y' plays dog-clicker.mp3
                       # 'n' plays vine-boom.mp3
```

### Reading & Editing

```bash
yap <file>             # Display file contents (plays hamster-dance.mp3)
sus <pattern>          # Search for text (plays millionaire-suspense.mp3)
dial-up                # Show system errors (plays aol-dial.mp3)
maid-outfit            # Clean orphaned packages (plays maid-outfit.mp3)
wumbo                  # Show package sizes (plays w-for-wumbo.mp3)
yoink <url>            # wget files (plays yoink.mp3)
```

### Network & Info

```bash
who-dis                # Show IP address (plays new-phone-who-dis.mp3)
dript                  # Fast flatpak update (plays tokyo-dript.mp3)
receipts               # Show command history with timestamps
wrong-numba            # Arch Linux help (plays wrong-numba.mp3)
yeet                   # Clean pacman cache interactively
```

---

## Live Typing Sound Triggers

While you're typing, the config listens for specific keywords and plays sounds automatically:

| Keyword | Sound | Context |
|---------|-------|---------|
| `smash` | smaaaash.mp3 | About to delete? |
| `mine` | mine-mine-mine.mp3 | Claiming files |
| `plsgo` | ack.mp3 | Changing directories |
| `flex` | can-you-feel-my-heart.mp3 | Showing off specs |
| `pls` | pls.mp3 | Going admin |
| `:3` / `:33` / `:333` | cute-uwu.mp3 | Package install incoming |
| `q-q` | lacrimosa.mp3 | Uninstalling (sad) |
| `touch-grass` | metal-pipe-falling.mp3 | Leaving the matrix |
| `nope` | nope.mp3 | Backing out |
| `backrooms` | burning-memory.mp3 | Going too deep |
| `dox-em` | allbase.mp3 | Exposing everything |
| `receipts` | credit-card-slam.mp3 | Showing history |
| `yap` | hamster-dance.mp3 | About to read |
| `sus` | millionaire-suspense.mp3 | Searching |
| `dial-up` | aol-dial.mp3 | Checking errors |
| `maid-outfit` | maid-outfit.mp3 | Cleaning |
| `wumbo` | w-for-wumbo.mp3 | Checking sizes |
| `yoink` | yoink.mp3 | Downloading |
| `who-dis` | new-phone-who-dis.mp3 | Checking network |
| `dript` | tokyo-dript.mp3 | Flatpak updates |
| `wrong-numba` | wrong-numba.mp3 | Arch help |
| `gotta-go-fast` | sonic-x-theme.mp3 | Mirror updates |
| `fuckoff` | fahhhhhhhhhhhhhhh.mp3 | Shutdown |
| `:P` | lizard-button.mp3 | Restart |
| `lets-go-gambling` | cute-uwu.mp3 | Updates |

These trigger *while you're typing* if you haven't triggered them in the last 2+ seconds. It's chaotic. It's wonderful.

---

## Keybinds (Hotkeys)

Hold Alt (or whatever your mod key is) and press:

| Key | Effect |
|-----|--------|
| `Ctrl+Y` | Append `\| yes` + dog-clicker.mp3 |
| `Ctrl+N` | Append `&& no` + vine-boom.mp3 |
| `Ctrl+B` | Play vine-boom.mp3 + type 'n' |
| `Ctrl+Space` | Trigger all live typing sound detection |

---

## Sounds

All sound files should be `.mp3` format in `~/Tools/terminal-sounds/`:

### Installation Sounds
- `cute-uwu.mp3` — Package installs
- `earthbound-what-battle-moment.mp3` — Loops during updates
- `earthbound-you-win.mp3` — Installation success
- `aw-dang-it.mp3` — Installation failure

### Deletion & File Ops
- `smaaaash.mp3` — Deleting files
- `earthbound-partner-turn.mp3` — Confirming deletion (yes)
- `earthbound-enemy-turn.mp3` — Canceling deletion (no)
- `lacrimosa.mp3` — Uninstalling packages
- `mine-mine-mine.mp3` — Listing files
- `allbase.mp3` — Listing hidden files (dox-em)

### Navigation
- `ack.mp3` — Changing directories
- `nope.mp3` — Going back one directory
- `burning-memory.mp3` — Going back four directories
- `metal-pipe-falling.mp3` — Exiting terminal

### System
- `can-you-feel-my-heart.mp3` — System flex
- `fahhhhhhhhhhhhhhh.mp3` — Shutdown
- `lizard-button.mp3` — Restart (plays 4x)
- `sonic-x-theme.mp3` — Mirror updates (loops)
- `haha-ha-one.mp3` — Mirror update end

### Updates & Info
- `lets-go-gambling.mp3` — Starting update loop
- `lets-go-gambling-win.mp3` — Update success
- `tokyo-dript.mp3` — Flatpak updates
- `start-pacman.mp3` — pacseek start
- `pac-death.mp3` — pacseek exit
- `its-broken.mp3` — Fix pacman lock
- `new-phone-who-dis.mp3` — Checking IP

### Other
- `hamster-dance.mp3` — Reading files (yap)
- `millionaire-suspense.mp3` — Searching (sus)
- `aol-dial.mp3` — System errors (dial-up)
- `maid-outfit.mp3` — Cleaning packages
- `w-for-wumbo.mp3` — Package sizes
- `yoink.mp3` — Downloading files
- `credit-card-slam.mp3` — Command history (receipts)
- `wrong-numba.mp3` — Arch info
- `no-i-forgot.mp3` — Help triggers
- `dog-clicker.mp3` — Confirming yes
- `vine-boom.mp3` — Meme sound
- `oo-ee-ee-aa.mp3` — Terminal startup
- `pls.mp3` — Sudo wrapper
- `yeet.mp3` — Cache cleaning

---

## How It Actually Works

### Sound Playing
The config uses a `play_sound()` function that tries multiple audio backends in order:
1. **ffplay** (from ffmpeg)
2. **paplay** (PulseAudio)
3. **mpv** (if neither above works)

Volume is globally controlled via `$VALKYRIE_SOUND_VOLUME` (0-100).

### Interactive Sounds
Commands like `smash`, `mine`, and package installs that need confirmation use **expect** scripts to intercept your 'y' or 'n' keypresses and play the appropriate sound before executing.

### Music Loops
Commands like `lets-go-gambling` and `gotta-go-fast` start a background music loop that continues while the command runs, then stops cleanly when finished.

### Live Typing Detection
The `detectcommandsounds()` function runs on every keystroke, checking if you've typed any recognized keywords. If you have, it plays the associated sound (with a 2-second debounce to avoid spam).

---

## Customization

### Change Sounds
Just replace the `.mp3` files in `~/Tools/terminal-sounds/`. Names matter—they're hardcoded in the aliases.

### Change Volume
```bash
sound-volume 30    # Set to 30%
sound-volume 100   # Set to max
```

The setting persists in `$VALKYRIE_SOUND_VOLUME` for the current session.

### Add New Commands
Add a function to `config.fish`, add it to the `detectcommandsounds()` trigger list, and give it a sound. Example:

```fish
function new-thing --description "Do something cool"
    set -l currenttime (date +%s%N | string sub -l 13)
    if not set -q __last_sound_trigger_time
        set -g __last_sound_trigger_time $currenttime
    end
    if test (math "$currenttime - $__last_sound_trigger_time") -gt 3000
        play_sound "cool-sound"
    end
    # Your command here
end
```

Then add a trigger in `detectcommandsounds()`:
```fish
else if string match -qr new-thing -- $currentline
    set triggeredpattern new-thing
    if test $triggeredpattern != $lastsoundtriggerpattern -o $timediff -gt 2000
        play_sound "cool-sound"
    end
```

---

## Troubleshooting

### Sounds Not Playing
- Check that `.mp3` files exist in `~/Tools/terminal-sounds/` with correct names
- Check that at least one audio backend is installed:
  ```bash
  which ffplay paplay mpv
  ```
- Check volume:
  ```bash
  sound-volume
  ```

### Commands Not Found
Make sure you have the underlying tools installed:
- `eza` for file listing (instead of `ls`)
- `bat` for file viewing (`yap`)
- `ugrep` for searching (`sus`)
- `yay` for AUR packages (fallback to `pacman`)
- `expect` for interactive sounds

### Interactive Prompts Hanging
If `smash` or other interactive commands hang, make sure `expect` is installed and working:
```bash
which expect
```

### Performance Issues
If the terminal feels sluggish, it might be the live typing detection triggering too much. You can:
- Increase the 2000ms debounce in `detectcommandsounds()`
- Remove sound triggers you don't use
- Profile with `fish -d` (debug mode)

---

## Acknowledgments

This monstrosity was built on:
- Fish shell's function system
- expect for interactive automation
- Various internet sound effects (Earthbound, Sonic, memes, etc.)
- The collective chaos energy of plural system Valkyries

It works great for us. Your mileage may vary.

---

## License

Do whatever you want with it. It's a fish config, not a nuclear power plant. Customize it, break it, make it worse, share it. 💙

---

*System tuned for chaos. Valkyries approved.* ⚔️
