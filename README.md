# 🎮 Silly Terminal: Meme-Powered Fish Shell Config

> A chaotic, fun Fish shell configuration for Arch Linux with gamified commands, interactive sound effects, and themed aliases. Built for maximum terminal chaos and fun.

---

## 📖 Overview

This is a heavily customized **Fish shell configuration** that transforms your terminal into an interactive, sound-enabled experience. Every action has a corresponding meme sound, from installing packages to navigating directories. Perfect for those who want their terminal to be as entertaining as it is functional.

**What makes it special:**
- 🔊 **Interactive sound effects** for y/n confirmations, command execution, and system info
- 🎯 **Themed aliases & functions** based on memes, gaming references, and pop culture
- 🎨 **Live typing detection** that triggers sounds as you type keywords
- 🎵 **Music loops** for long operations (updates, mirror checks)
- 🌈 **Undertale/Earthbound integration** with battle sounds and Papyrus/Sans voice packs
- ⚙️ **Fully modular** – adjust volume, enable/disable, customize easily

---

## 🚀 Installation

### Prerequisites
- **Fish Shell** (3.1+)
- **Arch Linux** (or Arch-based distro)
- Sound player: `ffplay`, `paplay`, or `mpv`
- Optional: `bat`, `eza`, `ugrep`, `expect`, `hyfetch`, `lolcat`, `htop`

### Setup
1. **Backup your current config:**
   ```fish
   cp ~/.config/fish/config.fish ~/.config/fish/config.fish.bak
   ```

2. **Replace or merge with the new config:**
   ```fish
   cp config-fish.txt ~/.config/fish/config.fish
   ```

3. **Create the sound directory:**
   ```bash
   mkdir -p ~/Tools/terminal-sounds
   ```

4. **Add your MP3 sound files (extract provided zip)** (place in `~/Tools/terminal-sounds/`):
   - `dog-clicker.mp3` – Yes confirmation
   - `vine-boom.mp3` – No confirmation
   - `smaaaash.mp3` – Delete action
   - `pls.mp3`, `cute-uwu.mp3`, `lacrimosa.mp3` – Package management
   - And 50+ more! (See complete list below)

5. **Reload your shell:**
   ```fish
   source ~/.config/fish/config.fish
   ```

---

## 🎯 Quick Start: Command Categories

### 📦 Package Management

| Command | Sound | Action |
|---------|-------|--------|
| `:3 <pkg>` | cute-uwu.mp3 | Install package (-S) |
| `:33 <pkg>` | cute-uwu x2 | Sync + install (-Sy) |
| `:333 <pkg>` | cute-uwu x3 | Update + install (-Syu) |
| `:3 <pkg> q-q` | lacrimosa.mp3 | Uninstall with sadness |
| `pls :3 <pkg>` | pls.mp3 + cute-uwu | Sudo install |
| `yeet` | yeet.mp3 | Clean package cache (interactive) |
| `pls-its-broken` | its-broken.mp3 | Fix pacman db lock |
| `seek` | start-pacman.mp3 | Launch pacseek |
| `lets-go-gambling` | gambling sounds | Update all (pacman + yay + flatpak) |
| `dript <args>` | tokyo-dript.mp3 | Flatpak package manager |

**Example:**
```fish
:3 firefox          # Install Firefox with cute-uwu sound
:3 firefox q-q      # Uninstall with sad Lacrimosa music
pls :3 neovim       # Sudo install Neovim
```

---

### 📂 Navigation & Listing

| Command | Sound | Action |
|---------|-------|--------|
| `nope` | nope.mp3 | `cd ..` (go back) |
| `backrooms` | burning-memory.mp3 | `cd ../..` (go deeper) |
| `plsgo <dir>` | ack.mp3 | `cd` + `clear` + list files |
| `mine` | mine-mine-mine.mp3 | List files with `eza` |
| `dox-em` | allbase.mp3 | List all files (including dotfiles) |
| `receipts` | credit-card-slam.mp3 | Show command history |

**Example:**
```fish
plsgo Desktop      # Navigate to Desktop and list contents
mine               # Show all files in current directory
nope               # Go back one directory
```

---

### 💾 System & Maintenance

| Command | Sound | Action |
|---------|-------|--------|
| `smash <file>` | smaaaash.mp3 | Delete with Earthbound battle sounds |
| `maid-outfit` | maid-outfit.mp3 | Clean orphaned packages |
| `wumbo` | w-for-wumbo.mp3 | Show package sizes (largest first) |
| `yoink` | yoink.mp3 | Download files with `wget` |
| `gotta-go-fast` | sonic-x-theme.mp3 loop | Update mirrors with Sonic theme |

**Example:**
```fish
smash oldfile.txt   # Delete with battle sounds (prompts y/n)
maid-outfit         # Clean up orphaned packages
gotta-go-fast       # Find fastest mirrors + play Sonic
```

---

### 📝 Reading & Editing

| Command | Sound | Action |
|---------|-------|--------|
| `yap <file>` | hamster-dance.mp3 | Display file with `bat` |
| `sus <pattern>` | millionaire-suspense.mp3 | Search with `ugrep` |
| `dial-up` | aol-dial.mp3 | Show system errors (journalctl) |

**Example:**
```fish
yap config.fish     # Display config file with hamster sounds
sus "function"      # Search for "function" in files
dial-up             # Check system errors
```

---

### 🎮 System Info

| Command | Sound | Action |
|---------|-------|--------|
| `numba-nine` | big-smoke-order.mp3 | Memory + htop (GTA reference) |
| `do-a-barrel` | do-a-barrel.mp3 | Journalctl errors (barrel roll) |
| `this-is-sparta` | spartaa.mp3 | Top 15 disk hogs |
| `let-me-do-it-4-u` | let-me-do-it-for-you.mp3 | Top CPU users |
| `trololo` | trololo.mp3 | Weather forecast (customizable location) |
| `forever-alone` | forever-alone.mp3 | Process tree |
| `vitas` | vitas-7th-element.mp3 | System info in rainbow (hyfetch) |
| `flex` | can-you-feel-my-heart.mp3 | Show system specs |

**Example:**
```fish
numba-nine          # Check memory and running processes
trololo             # Get weather for your location
vitas               # Rainbow system info
```

---

### 🌐 Network

| Command | Sound | Action |
|---------|-------|--------|
| `who-dis` | new-phone-who-dis.mp3 | Show IP address |

---

### 🛡️ Noob Helpers

| Command | Sound | Action |
|---------|-------|--------|
| `wrong-numba` | wrong-numba.mp3 | Redirect to `man pacman` |

---

### 🔧 System Commands

| Command | Sound | Action |
|---------|-------|--------|
| `fuckoff` | fahhhhhhhhhhhhhhh.mp3 | Shutdown now |
| `:P` | lizard-button.mp3 x4 | Reboot |
| `touch-grass` | metal-pipe-falling.mp3 | Exit terminal |

---

### 🎛️ Utility

| Command | Sound | Description |
|---------|-------|-------------|
| `pls <cmd>` | pls.mp3 | Run command with `sudo` |
| `iforgor` | no-i-forgot.mp3 | Show command reference (animated or fast) |
| `iforgor-now` | – | Fast (instant) reference |
| `sound-volume <0-100>` | – | Adjust global sound volume |

**Example:**
```fish
pls pacman -Syu     # Run system update with sudo + sound
iforgor             # Show animated help menu (choose voice)
iforgor-now         # Show help instantly
sound-volume 75     # Set volume to 75%
```

---

## 🔌 Interactive Features

### `with-sounds` Function
Wraps any command with interactive **yes/no sound effects**:

```fish
with-sounds flatpak update    # Plays dog-clicker for 'y', vine-boom for 'n'
with-sounds dript update      # Works with custom functions too!
```

**How it works:**
- Spawns an `expect` script that listens for y/n input
- **dog-clicker.mp3** plays when you type `y`
- **vine-boom.mp3** plays when you type `n`
- Works with any command that prompts for confirmation

### Live Typing Detection
Sounds play **as you type** specific keywords:

```fish
# Type these at the end of a line:
pls              # pls.mp3
fuckoff          # fahhhhhhhhhhhhhhh.mp3
:3               # cute-uwu.mp3
q-q              # lacrimosa.mp3
:P               # lizard-button.mp3 x4
smash            # smaaaash.mp3
mine             # mine-mine-mine.mp3
...and 40+ more!
```

### Music Loops
Long-running operations play looping background music:

- `gotta-go-fast` → sonic-x-theme.mp3 (loops during mirror update)
- `:3` installs → earthbound-what-battle-moment.mp3 (loops during install)
- `dript` updates → tokyo-dript.mp3 (loops during flatpak update)

Music stops automatically when the command completes.

---

## ⚙️ Configuration

### Sound Volume
```fish
sound-volume 50      # Set to 50%
sound-volume --show  # Show current volume
sound-volume 100     # Max volume
```

The volume applies to **all** sounds globally. Internally converts to:
- ffplay: 0-100
- paplay: 0-65536
- mpv: 0-100

### Set Your Weather Location (trololo)

By default, `trololo` fetches weather for Whitewater, Wisconsin. To change it to your location:

**Step 1: Find your location code**

Test a location using `curl`:
```bash
# Try your city name:
curl wttr.in/Seattle              # City name
curl wttr.in/Portland,Oregon      # City, State
curl wttr.in/Paris,France         # City, Country
curl wttr.in/~40.7128,-74.0060    # GPS coordinates
curl wttr.in/~Berlin              # Search with ~
```

Choose whichever format returns the weather data you want!

**Step 2: Edit the `trololo` function**

Open `~/.config/fish/config.fish` and find the `trololo` function. Change this line:

```fish
curl -s wttr.in/Whitewater,WI    # ← Change this
```

To your chosen location:

```fish
curl -s wttr.in/Seattle           # Example
curl -s wttr.in/London,UK         # Or any location
curl -s wttr.in/~Paris            # Or search format
```

**Step 3: Reload and test**

```fish
source ~/.config/fish/config.fish
trololo    # Should now show YOUR location's weather!
```

**Complete location examples:**
```fish
curl -s wttr.in/NewYork           # New York, USA
curl -s wttr.in/Tokyo,Japan       # Tokyo, Japan
curl -s wttr.in/Berlin,Germany    # Berlin, Germany
curl -s wttr.in/Sydney,Australia  # Sydney, Australia
curl -s wttr.in/~Toronto          # Toronto (search)
curl -s wttr.in/~40.7128,-74.0060 # NYC by GPS
```

### Customize Sound Paths

The config uses **auto-detection** to find sound files relative to wherever SillyTerminal is installed. This means it works **regardless of the home directory** or installation path!

**How it works:**
```fish
set SILLY_TERMINAL_DIR (dirname (status filename))
set sound_file "$SILLY_TERMINAL_DIR/terminal-sounds/$sound_name.mp3"
```

The config automatically detects where it's located and looks for sounds in the `terminal-sounds/` folder **next to it**.

**Expected folder structure:**
```
SillyTerminal/
├── config.fish                    ← Main config (detects this location)
├── README.md
└── terminal-sounds/               ← Sounds go here
    ├── dog-clicker.mp3
    ├── vine-boom.mp3
    ├── cute-uwu.mp3
    └── ... (50+ more files)
```

**If you need to customize the path:**

If you're using a custom setup, you can override it by setting the `SILLY_TERMINAL_DIR` variable before sourcing the config:

```fish
set -gx SILLY_TERMINAL_DIR /custom/path/to/SillyTerminal
source ~/.config/fish/config.fish
```

Or edit this line in the config:
```fish
set SILLY_TERMINAL_DIR (dirname (status filename))  # ← Change this to a hardcoded path
```

To:
```fish
set SILLY_TERMINAL_DIR "/your/custom/path/to/SillyTerminal"
```

### Add New Sound Triggers
Add to the `__detect_command_sounds` function:

```fish
else if string match -qr '(^|\s)mycommand$' -- "$current_line"
    set triggered_pattern "mycommand"
    if test "$triggered_pattern" != "$__last_sound_trigger_pattern" -o $time_diff -gt 2000
        play_sound "my-sound"
    end
```

Then bind the triggering key in the keybinds section.

---

## 📋 Complete Sound File Reference

### Required Sounds (50+ files)

**Package Management:**
- cute-uwu.mp3, lacrimosa.mp3, pls.mp3, its-broken.mp3, start-pacman.mp3, pac-death.mp3, earthbound-what-battle-moment.mp3, earthbound-you-win.mp3, earthbound-partner-turn.mp3, earthbound-enemy-turn.mp3, earthbound-partner-die.mp3, aw-dang-it.mp3, yeet.mp3, lets-go-gambling.mp3, lets-go-gambling-win.mp3

**Navigation:**
- nope.mp3, burning-memory.mp3, allbase.mp3, credit-card-slam.mp3, ack.mp3, mine-mine-mine.mp3

**System:**
- smaaaash.mp3, maid-outfit.mp3, w-for-wumbo.mp3, yoink.mp3, sonic-x-theme.mp3, haha-ha-one.mp3, metal-pipe-falling.mp3

**Reading/Editing:**
- hamster-dance.mp3, millionaire-suspense.mp3, aol-dial.mp3

**System Info:**
- big-smoke-order.mp3, do-a-barrel.mp3, spartaa.mp3, let-me-do-it-for-you.mp3, trololo.mp3, forever-alone.mp3, vitas-7th-element.mp3, can-you-feel-my-heart.mp3

**Network:**
- new-phone-who-dis.mp3

**Noob Helpers:**
- wrong-numba.mp3

**System Commands:**
- fahhhhhhhhhhhhhhh.mp3, lizard-button.mp3

**Utility:**
- dog-clicker.mp3, vine-boom.mp3, no-i-forgot.mp3, undertale-slash-attack.mp3, text-sans.mp3, text-papyrus.mp3, gasters-theme.mp3, ohyes.mp3, tokyo-dript.mp3, oo-ee-ee-aa.mp3

---

## 🎮 Advanced: The `iforgor` Help System

The **`iforgor`** command is an Undertale-themed command reference system:

```fish
iforgor           # No args: play "no-i-forgot" + show help
iforgor help      # Show animated help (choose voice: random/papyrus/sans)
iforgor help now  # Show help instantly (no animation)
iforgor plsgo     # Show help for specific command
```

### Animated Mode (slow)
- Choose voice: **Random** (alternates Sans/Papyrus), **Papyrus**, or **Sans**
- Text types out character-by-character with sound effects
- Background music: Gaster's Theme (loops)
- Press Ctrl+C to stop animation and return to prompt

### Fast Mode (instant)
- Displays full reference immediately
- Plays "ohyes.mp3" at the end
- No animation, instant lookup

---
# Silly Terminal Config - Optimization TODOs

## 🔴 HIGH PRIORITY - Critical Optimizations (600+ lines savings potential)

### Phase 1: Sound Detector Refactor (-300 lines)
- [ ] Create lookup table for command-to-sound mappings
  - [ ] Define array structure: `set sound_triggers cmd1 sound1 cmd2 sound2 ...`
  - [ ] Test with 10-20 commands first
  - [ ] Verify pattern matching still works correctly
- [ ] Replace 50+ `else if` blocks in `__detect_command_sounds` with loop
  - [ ] Loop through sound_triggers array
  - [ ] Match against current_line
  - [ ] Call play_sound and set pattern variables
- [ ] Validate all 50 commands still trigger sounds
  - [ ] Manual testing: `:3`, `smash`, `mine`, `plsgo`, `flex`, etc.
  - [ ] Verify timing guard still prevents double-triggers

**Estimated savings**: 300 lines  
**File affected**: config.fish  
**Risk level**: Medium (core functionality)

---

### Phase 2: Timer Guard Helper (-200 lines)
- [ ] Create `__play_sound_if_cooldown` helper function
  - [ ] Parameters: sound_name, cooldown_ms (default 3000)
  - [ ] Extract timer logic from existing functions
  - [ ] Return success/failure for chaining
- [ ] Refactor functions using timer guard:
  - [ ] `nope` → `__play_sound_if_cooldown nope 3000 && cd ..`
  - [ ] `backrooms` → `__play_sound_if_cooldown burning-memory 3000 && cd ../..`
  - [ ] `smash`, `mine`, `plsgo`, `flex`, `gotta-go-fast`, `touch-grass`
  - [ ] All other timer-guarded functions (25+ total)
- [ ] Test each refactored function individually
  - [ ] Verify cooldown prevents double-triggers
  - [ ] Confirm sound plays only on first call within window

**Estimated savings**: 200 lines  
**File affected**: config.fish  
**Risk level**: Low (isolated changes)

---

### Phase 3: Player Detection Caching (-subprocess overhead)
- [ ] Move player detection to startup (before any functions)
  ```fish
  # At top of config
  if type -q ffplay
      set -gx VALKYRIE_SOUND_PLAYER ffplay
  else if type -q paplay
      set -gx VALKYRIE_SOUND_PLAYER paplay
  else if type -q mpv
      set -gx VALKYRIE_SOUND_PLAYER mpv
  end
  ```
- [ ] Update `play_sound()` to use $VALKYRIE_SOUND_PLAYER
  - [ ] Replace `if type -q ffplay` with switch statement
  - [ ] Remove 50+ redundant `type -q` calls
- [ ] Update `start_music_loop()` to use cached player
- [ ] Test each player type:
  - [ ] Works with ffplay installed
  - [ ] Falls back gracefully if only paplay available
  - [ ] Works with mpv as final fallback

**Estimated savings**: Process overhead reduction (not line count)  
**File affected**: config.fish  
**Risk level**: Low (performance optimization)

---

## 🟡 MEDIUM PRIORITY - Code Quality Improvements

### Phase 4: Iforgor Function Refactor (-complexity)
- [ ] Extract `iforgor` animated display logic into separate function
  - [ ] Create `__iforgor_animated_help` function
  - [ ] Move all `__type_slowly` calls there
  - [ ] Move voice selection logic there
- [ ] Extract `iforgor` fast display into separate function
  - [ ] Create `__iforgor_fast_help` function
  - [ ] Move all instant echo statements there
- [ ] Simplify main `iforgor` function to dispatcher:
  ```fish
  if test "$fast_mode" = "now"
      __iforgor_fast_help
  else
      __iforgor_animated_help
  end
  ```
- [ ] Test both modes:
  - [ ] `iforgor help` (animated)
  - [ ] `iforgor help now` (instant)
  - [ ] No args → plays sound and shows help

**Estimated savings**: 100 lines of cleaner, more maintainable code  
**File affected**: config.fish  
**Risk level**: Low (already working)

---

### Phase 5: Expect Script Documentation
- [ ] Add comment block explaining expect script pattern:
  ```fish
  # ========================================
  # EXPECT SCRIPT PATTERN EXPLANATION
  # ========================================
  # We use embedded expect scripts for interactive prompts
  # because Fish doesn't have native read/confirmation hooks.
  # 
  # Pattern: printf to /tmp/scriptname.exp, chmod +x, run, cleanup
  # Rationale: Allows sound playback on user input (y/n)
  # 
  # Why separate scripts vs. helper?
  # - Each use case (with-sounds, smash, etc.) needs different logic
  # - Keeping inline improves readability for complex logic
  # - Trade-off: 3 similar blocks vs. 1 abstract helper
  # ========================================
  ```
- [ ] Verify security assumptions:
  - [ ] Document that $cmd_str is only internal commands
  - [ ] Confirm no user input injection risks
- [ ] Add note about Fish version compatibility

**File affected**: config.fish (documentation only)  
**Risk level**: None (comments)

---

## 🟢 LOW PRIORITY - Nice-to-Have Improvements

### Phase 6: Test Suite Creation
- [ ] Create `tests/` directory
- [ ] Create test script for each command category:
  - [ ] `test_package_management.fish` (`:3`, `:33`, `:333`, `:3 q-q`)
  - [ ] `test_navigation.fish` (`nope`, `backrooms`, `plsgo`, `mine`)
  - [ ] `test_system_info.fish` (`flex`, `vitas`, `trololo`, `numba-nine`)
  - [ ] `test_sounds.fish` (verify all 50+ trigger sounds play)
  - [ ] `test_iforgor.fish` (both modes)
  - [ ] `test_volume_control.fish` (`sound-volume` command)

**File affected**: New tests/ directory  
**Risk level**: None (documentation)

---

### Phase 7: Performance Profiling
- [ ] Measure startup time before optimizations
  ```bash
  time source ~/.config/fish/config.fish
  ```
- [ ] Measure after each phase
- [ ] Measure keystroke latency with profiler
- [ ] Document baseline vs. optimized timing

**Tools**: Fish built-in `time`, optionally `hyperfine`

---

### Phase 8: README Updates
- [ ] Update installation docs with new player caching note
- [ ] Add performance section documenting optimizations
- [ ] Add test instructions
- [ ] Update troubleshooting with common optimization issues

**File affected**: README.md

---

## 📋 Testing Checklist (Run After Each Phase)

- [ ] Sound playback works (test each 50 commands triggers sound)
- [ ] Live typing detection works (type `:3`, `smash`, `flex`, etc.)
- [ ] Package management (`:3 firefox`, `:33 pkg`, `:333 update+install`)
- [ ] Navigation (`nope`, `backrooms`, `plsgo ~/Desktop`)
- [ ] System info (`flex`, `vitas`, `trololo`, `numba-nine`)
- [ ] `iforgor` help (both animated and `iforgor help now`)
- [ ] `with-sounds` wrapper with y/n prompts
- [ ] Music loops (start/stop cleanly with `gotta-go-fast`)
- [ ] Volume control (`sound-volume 50`, `sound-volume --show`)
- [ ] Config reload (`source ~/.config/fish/config.fish`)
- [ ] No error messages on startup
- [ ] All 50+ meme sounds play correctly

---

## 🎯 Completion Criteria

- [ ] Achieve 600+ lines reduction (from ~2000 to ~1400)
- [ ] All 50+ commands still trigger sounds perfectly
- [ ] No new bugs introduced
- [ ] Code more maintainable/readable
- [ ] Performance equivalent or better
- [ ] All tests pass
- [ ] Documentation updated
- [ ] README reflects optimizations

---

## 📊 Progress Tracking

| Phase | Task | Lines Saved | Status | PR |
|-------|------|-------------|--------|-----|
| 1 | Sound detector refactor | 300 | ⬜ TODO | — |
| 2 | Timer guard helper | 200 | ⬜ TODO | — |
| 3 | Player caching | Overhead reduction | ⬜ TODO | — |
| 4 | Iforgor refactor | 100 | ⬜ TODO | — |
| 5 | Expect docs | Documentation | ⬜ TODO | — |
| 6 | Test suite | N/A (tests) | ⬜ TODO | — |
| 7 | Performance profile | N/A (analysis) | ⬜ TODO | — |
| 8 | README updates | N/A (docs) | ⬜ TODO | — |
| **TOTAL** | **All phases** | **600+ lines** | **⬜ TODO** | **TBD** |

---

## 🔗 Related Issues

- None yet - create GitHub issues for:
  - Performance regression testing
  - Keybind collision detection
  - Sound file availability checks

---

## 📝 Notes

- **Valkyrie System**: Estimate 2-3 hours for all phases if doing sequentially
- **Risk mitigation**: Test after each phase, commit frequently
- **Backward compatibility**: No breaking changes to user-facing commands
- **Future work**: Consider moving to separate module files (aliases.fish, functions.fish, etc.)

---

**Last Updated**: January 21, 2026  
**Status**: Planning Phase  
**Next Step**: Phase 1 - Sound Detector Refactor

---

## 🐛 Troubleshooting

### Sound Not Playing
1. **Check sound files exist:**
   ```bash
   ls ~/Tools/terminal-sounds/ | wc -l  # Should be 50+
   ```

2. **Check volume:**
   ```fish
   sound-volume --show
   ```

3. **Test a player:**
   ```bash
   ffplay ~/Tools/terminal-sounds/dog-clicker.mp3
   paplay ~/Tools/terminal-sounds/dog-clicker.mp3
   mpv ~/Tools/terminal-sounds/dog-clicker.mp3
   ```

4. **Verify config sourced:**
   ```fish
   type play_sound  # Should show function definition
   ```

### `with-sounds` Not Finding Functions
- Make sure `with-sounds` sources your full config: `source ~/.config/fish/config.fish`
- This allows custom functions like `dript` to be available in the spawned shell

### Music Loop Won't Stop
- Manually kill the process:
  ```bash
  pkill -f "ffplay.*sonic-x-theme"
  ```
- Or call `stop_music_loop` directly in Fish

### Ctrl+C in `iforgor` Hangs
- Fixed in this version with `__iforgor_interrupt_flag` check
- If still issues, press Ctrl+C again to force exit

### Weather Not Showing (trololo)
- Check if curl is installed: `which curl`
- Test your location code: `curl wttr.in/YourCity`
- Verify the URL format in the `trololo` function
- Check internet connection: `curl wttr.in`

---

## 📝 Tips & Tricks

### Chaining Commands
```fish
plsgo Documents && mine    # Navigate and list
nope && receipts           # Go back and show history
```

### Using `pls` with Custom Functions
```fish
pls :3 firefox             # Works via special handling
pls dript update           # Works via with-sounds wrapper
pls smash oldfile.txt      # Works via special handling
```

### Combine with Other Tools
```fish
yap config.fish | sus "function"  # View file, then search
mine | yap                        # List files, view selected
trololo && gotta-go-fast          # Check weather then update mirrors
```

### Custom Sound Triggers
Add your own keywords to `__detect_command_sounds`:

```fish
else if string match -qr '(^|\s)meow$' -- "$current_line"
    set triggered_pattern "meow"
    if test "$triggered_pattern" != "$__last_sound_trigger_pattern"
        play_sound "meow-sound"
    end
```

---

## 🎨 Customization Examples

### Change Default Volume
```fish
set -U VALKYRIE_SOUND_VOLUME 80  # Default to 80%
```

### Disable a Specific Sound Trigger
Comment out in `__detect_command_sounds`:
```fish
# else if string match -qr '(^|\s)smash$' -- "$current_line"
#     ...
```

### Customize Sound Directory
```fish
# In config.fish, change:
set sound_file "/your/custom/path/$sound_name.mp3"
```

### Add New Themed Function
```fish
function mycmd --description "My custom command"
    set -l current_time (date +%s%N | string sub -l 13)
    if test (math "$current_time - $__last_sound_trigger_time") -gt 3000
        play_sound "my-sound"
        set -g __last_sound_trigger_time $current_time
    end
    # Your command here
end
```

---

## 📚 Dependencies

### Required
- `fish` 3.1+
- `expect` (for interactive sounds)

### Highly Recommended
- `bat` – Syntax-highlighted file viewing
- `eza` – Modern `ls` replacement
- `ugrep` – Fast grep
- `ffplay` or `mpv` – Sound playback

### Optional (for specific commands)
- `hyfetch` – Rainbow system info
- `lolcat` – Colorize output
- `htop` – Interactive process viewer
- `pacseek` – Package searcher
- `flatpak` – Container package manager

---

## 🤝 Credits & References

- **Fish Shell:** https://fishshell.com
- **Undertale:** Toby Fox
- **Earthbound:** Nintendo/Ape Inc.
- **Sonic The Headgehog:** SEGA
- **wttr.in:** https://wttr.in/ (weather service)
- **Meme sounds:** Various internet culture references
- **Original inspiration:** Chaotic terminal ricing culture

---

## 📄 License

This config is **free to use, modify, and share**. No attribution required, but appreciated!

---

## 🚨 Disclaimer

This config is **intentionally chaotic and noisy**. Use in professional settings at your own risk! 😄

Turn down the volume when demoing in meetings. You have been warned.

---

**Last Updated:** January 2026  
**Maintained by:** Valkyrie System  
**Status:** ✅ Fully Working & Tested
