## Set values
# Hide welcome message & ensure we are reporting fish as shell
set fish_greeting
set VIRTUAL_ENV_DISABLE_PROMPT "1"
set -xU MANPAGER "sh -c 'col -bx | bat -l man -p'"
set -xU MANROFFOPT "-c"
set -x SHELL /usr/bin/fish
## Set Input Engine
set -x GTK_IM_MODULE fcitx
set -x QT_IM_MODULE fcitx
set -x XMODIFIERS "@im=fcitx"

## Export variable need for qt-theme
if type "qtile" >> /dev/null 2>&1
   set -x QT_QPA_PLATFORMTHEME "qt5ct"
end

# Set settings for [https://github.com/franciscolourenco/done](https://github.com/franciscolourenco/done)
set -U __done_min_cmd_duration 10000
set -U __done_notification_urgency_level low


## Environment setup
# Apply .profile: use this to put fish compatible .profile stuff in
if test -f ~/.fish_profile
  source ~/.fish_profile
end

# Add ~/.local/bin to PATH
if test -d ~/.local/bin
    if not contains -- ~/.local/bin $PATH
        set -p PATH ~/.local/bin
    end
end

# Add depot_tools to PATH
if test -d ~/Applications/depot_tools
    if not contains -- ~/Applications/depot_tools $PATH
        set -p PATH ~/Applications/depot_tools
    end
end


## Starship prompt
if status --is-interactive
   source ("/usr/bin/starship" init fish --print-full-init | psub)
end


## Advanced command-not-found hook
source /usr/share/doc/find-the-command/ftc.fish


## Functions
# Functions needed for !! and !$ [https://github.com/oh-my-fish/plugin-bang-bang](https://github.com/oh-my-fish/plugin-bang-bang)
function __history_previous_command
  switch (commandline -t)
  case "!"
    commandline -t $history[1]; commandline -f repaint
  case "*"
    commandline -i !
  end
end

function __history_previous_command_arguments
  switch (commandline -t)
  case "!"
    commandline -t ""
    commandline -f history-token-search-backward
  case "*"
    commandline -i '$'
  end
end

if [ "$fish_key_bindings" = fish_vi_key_bindings ];
  bind -Minsert ! __history_previous_command
  bind -Minsert '$' __history_previous_command_arguments
else
  bind ! __history_previous_command
  bind '$' __history_previous_command_arguments
end

# Fish command history
function history
    builtin history --show-time='%F %T '
end

function backup --argument filename
    cp $filename $filename.bak
end

# Copy DIR1 DIR2
function copy
    set count (count $argv | tr -d \n)
    if test "$count" = 2; and test -d "$argv[1]"
	set from (echo $argv[1] | string trim --right --chars=/)
	set to (echo $argv[2])
        command cp -r $from $to
    else
        command cp $argv
    end
end

# Cleanup local orphaned packages
function cleanup
    while pacman -Qdtq
        sudo pacman -R (pacman -Qdtq)
    end
end

## Sound volume management
# Set default volume (0-100, where 100 is max)
set -U VALKYRIE_SOUND_VOLUME 50

# Function to adjust sound volume globally
function sound-volume --argument level
    if test -z "$level"
        echo "Current sound volume: $VALKYRIE_SOUND_VOLUME%"
        echo ""
        echo "USAGE:"
        echo "  sound-volume <0-100>   # Set volume (0=silent, 100=max)"
        echo "  sound-volume --show    # Show current volume"
        echo ""
        echo "EXAMPLES:"
        echo "  sound-volume 50"
        echo "  sound-volume 75"
        return 0
    end

    if test "$level" = "--show"
        echo "Current sound volume: $VALKYRIE_SOUND_VOLUME%"
        return 0
    end

    # Validate input is a number between 0-100
    if not string match -qr '^[0-9]+$' "$level"
        echo "Error: Volume must be a number between 0-100"
        return 1
    end

    if test $level -lt 0 -o $level -gt 100
        echo "Error: Volume must be between 0-100"
        return 1
    end

    set -U VALKYRIE_SOUND_VOLUME $level
    echo "Sound volume set to $level%"
end

## Sound utility function with volume control (Fish compatible) - FISH MATH FIXED
function play_sound --argument sound_name
    set sound_file "/home/valkyrie-sys/Tools/terminal-sounds/$sound_name.mp3"
    if test -f "$sound_file"
        # ffplay: 0-100
        set ffplay_volume $VALKYRIE_SOUND_VOLUME
        # paplay: 0-65536 (Fish math)
        set paplay_volume (math $VALKYRIE_SOUND_VOLUME \* 655.36)
        # mpv: 0-100

        if type -q ffplay
            ffplay -nodisp -autoexit -volume $ffplay_volume -loglevel quiet "$sound_file" >/dev/null 2>&1 &
        else if type -q paplay
            paplay --volume=(string join "" $paplay_volume) --device=@DEFAULT_SINK@ "$sound_file" >/dev/null 2>&1 &
        else if type -q mpv
            mpv --no-video --no-loop --volume=$VALKYRIE_SOUND_VOLUME --no-terminal --no-msg-color "$sound_file" >/dev/null 2>&1 &
        end
        disown
    end
end

# Y/N sounds: wrappers + keybinds (replaces broken hooks)
function yes --wraps=builtin_yes
    play_sound "dog-clicker" &
    command yes $argv
end

function no
    play_sound "vine-boom" &
    return 0
end

# Keybinds for instant testing
bind \cy 'commandline -it --append " | yes"; play_sound "dog-clicker"'
bind \cn 'commandline -it --append " && no"; play_sound "vine-boom"'

# Ctrl+B: Manual boom button for unexpected prompts
bind \cb 'play_sound "vine-boom"; commandline -i "n"'

# Auto-yes for echo "y" replacement
function auto_yes
    yes y | head -n 100  # Enough for most prompts
end

# Auto-no with sound (for piped commands)
function auto_no
    play_sound "vine-boom"
    sleep 0.2
    yes n | head -n 100
end

## Interactive wrapper with sounds using expect
# This creates the expect script on-the-fly if needed
function with-sounds
    set expect_script "/tmp/fish-interactive-sounds-$fish_pid.exp"

    # Create expect script dynamically
    echo '#!/usr/bin/expect -f
set timeout -1
set volume $env(VALKYRIE_SOUND_VOLUME)
set sound_dir "/home/valkyrie-sys/Tools/terminal-sounds"

# Helper to play sound based on volume
proc play_sound {sound_name} {
    global volume sound_dir
    set sound_file "$sound_dir/$sound_name.mp3"

    if {[file exists $sound_file]} {
        # Try ffplay first, then paplay, then mpv
        if {[catch {exec which ffplay} result] == 0} {
            exec ffplay -nodisp -autoexit -volume $volume -loglevel quiet $sound_file >/dev/null 2>&1 &
        } elseif {[catch {exec which paplay} result] == 0} {
            set paplay_vol [expr {int($volume * 655.36)}]
            exec paplay --volume=$paplay_vol --device=@DEFAULT_SINK@ $sound_file >/dev/null 2>&1 &
        } elseif {[catch {exec which mpv} result] == 0} {
            exec mpv --no-video --no-loop --volume=$volume --no-terminal --no-msg-color $sound_file >/dev/null 2>&1 &
        }
    }
}

# Spawn the command passed as arguments
eval spawn $argv

# Main interaction loop
interact {
    # Match when user types "y" or "Y" at prompts
    -re {[yY]} {
        play_sound "dog-clicker"
        send -- $interact_out(0,string)
    }
    # Match when user types "n" or "N" at prompts
    -re {[nN]} {
        play_sound "vine-boom"
        send -- $interact_out(0,string)
    }
}

# Wait for program to finish
wait' > "$expect_script"

    chmod +x "$expect_script"

    # Run the command through expect wrapper
    env VALKYRIE_SOUND_VOLUME=$VALKYRIE_SOUND_VOLUME "$expect_script" $argv
    set exit_status $status

    # Cleanup
    rm -f "$expect_script"

    return $exit_status
end

## Useful aliases

# Replace ls with eza
alias ls 'eza -al --color=always --group-directories-first --icons' # preferred listing
alias la 'eza -a --color=always --group-directories-first --icons'  # all files and dirs
alias ll 'eza -l --color=always --group-directories-first --icons'  # long format
alias lt 'eza -aT --color=always --group-directories-first --icons' # tree listing
alias l. 'eza -ald --color=always --group-directories-first --icons .*' # show only dotfiles

# Replace some more things with better alternatives
alias cat 'bat --style header --style snip --style changes --style header'
if not test -x /usr/bin/yay; and test -x /usr/bin/paru
   alias yay 'paru'
end

#Cachy-update (all)
alias lets-go-gambling 'lets_go_gambling'
#cd
alias plsgo 'cd'

# Common use
alias .. 'cd ..'
alias ... 'cd ../..'
alias .... 'cd ../../..'
alias ..... 'cd ../../../..'
alias ...... 'cd ../../../../..'
alias big 'expac -H M "%m\t%n" | sort -h | nl'     # Sort installed packages according to size in MB (expac must be installed)
alias dir 'dir --color=auto'
alias fixpacman 'sudo rm /var/lib/pacman/db.lck'
alias gitpkg 'pacman -Q | grep -i "\-git" | wc -l' # List amount of -git packages
alias grep 'ugrep --color=auto'
alias egrep 'ugrep -E --color=auto'
alias fgrep 'ugrep -F --color=auto'
alias grubup 'sudo update-grub'
alias hw 'hwinfo --short'                          # Hardware Info
alias ip 'ip -color'
alias psmem 'ps auxf | sort -nr -k 4'
alias psmem10 'ps auxf | sort -nr -k 4 | head -10'
alias rmpkg 'sudo pacman -Rdd'
alias tarnow 'tar -acf '
alias untar 'tar -zxvf '
alias upd '/usr/bin/garuda-update'
alias vdir 'vdir --color=auto'
alias wget 'wget -c '

# Get fastest mirrors
alias mirror 'sudo reflector -f 30 -l 30 --number 10 --verbose --save /etc/pacman.d/mirrorlist'
alias mirrora 'sudo reflector --latest 50 --number 20 --sort age --save /etc/pacman.d/mirrorlist'
alias mirrord 'sudo reflector --latest 50 --number 20 --sort delay --save /etc/pacman.d/mirrorlist'
alias mirrors 'sudo reflector --latest 50 --number 20 --sort score --save /etc/pacman.d/mirrorlist'

# Help people new to Arch
alias apt 'man pacman'
alias apt-get 'man pacman'
alias tb 'nc termbin.com 9999'
alias helpme 'echo "To print basic information about a command use tldr <command>"'
alias pacdiff 'sudo -H DIFFPROG=meld pacdiff'

# Get the error messages from journalctl
alias jctl 'journalctl -p 3 -xb'

# Recent installed packages
alias rip 'expac --timefmt="%Y-%m-%d %T" "%l\t%n %v" | sort | tail -200 | nl'

## Run hyfetch if session is interactive
if status --is-interactive && type -q hyfetch
   hyfetch
end

## Terminal launch sound
if status --is-interactive
    play_sound "oo-ee-ee-aa" &
end

#Help for all packages / show all commands
function iforgor --argument cmd
    # Play sound once at the start
    set -l played_sound 0

    if test -z "$cmd"
        play_sound "no-i-forgot"
        set played_sound 1
        iforgor help
        return 0
    end

    if test "$cmd" = "help" -o "$cmd" = "all" -o "$cmd" = "commands"
        if test $played_sound -eq 0
            play_sound "no-i-forgot"
        end
        echo "╔══════════════════════════════════════════════════════════════╗"
        echo "║           Valkyrie Terminal Commands Reference               ║"
        echo "╚══════════════════════════════════════════════════════════════╝"
        echo ""
        echo "📦 PACKAGE MANAGEMENT"
        echo "  :3 <pkg>           → Install with cute-uwu.mp3"
        echo "  :3 <pkg> q-q       → Uninstall with lacrimosa.mp3"
        echo "  pls :3 <pkg>       → Sudo install (pls.mp3 + cute-uwu.mp3)"
        echo "  pls :3 <pkg> q-q   → Sudo uninstall (pls.mp3 + lacrimosa.mp3)"
        echo "  yeet               → Clean cache (interactive with sounds)"
        echo "  pls-its-broken     → Fix pacman db lock with its-broken.mp3"
        echo "  seek               → Launch pacseek with start-pacman.mp3"
        echo ""
        echo "🔧 SYSTEM COMMANDS"
        echo "  fuckoff            → Shutdown with fahhhhhhhhhhhhhhh.mp3"
        echo "  :P                 → Restart with lizard-button.mp3 (4x)"
        echo "  lets-go-gambling   → Update all with gambling sounds"
        echo ""
        echo "🎛️  UTILITY"
        echo "  pls <cmd>          → Sudo + pls.mp3"
        echo "  pls <cmd> iforgor  → Show sudo help + no-i-forgot.mp3"
        echo "  iforgor <cmd>      → Show command help + no-i-forgot.mp3"
        echo "  sound-volume <0-100> → Adjust all sound volumes"
        echo "  with-sounds <cmd>  → Run any interactive command with y/n sounds"
        echo "  iforgor help       → Show this menu + no-i-forgot.mp3"
        echo ""
        echo "🔊 SOUNDS & KEYBINDS"
        echo "  Terminal Start     → oo-ee-ee-aa.mp3"
        echo "  Update Success     → lets-go-gambling-win.mp3"
        echo "  Update Failure     → aw-dang-it.mp3"
        echo "  Help/Iforgor       → no-i-forgot.mp3"
        echo "  Ctrl+Y             → Append '| yes' + dog-clicker"
        echo "  Ctrl+N             → Append '&& no' + vine-boom"
        echo "  Ctrl+B             → Play vine-boom + type 'n'"
        echo "  Current Volume     → $VALKYRIE_SOUND_VOLUME%"
        echo ""
        return 0
    end

    # Show help for specific custom commands
    switch "$cmd"
        case ":3"
            play_sound "no-i-forgot"
            echo "Install/Uninstall Packages (:3)"
            echo ""
            echo "USAGE:"
            echo "  :3 <package>       # Install package :3~"
            echo "  :3 <package> q-q   # Uninstall package q-q~"
            echo "  pls :3 <package>       # Sudo install (pls.mp3 + cute-uwu.mp3)"
            echo "  pls :3 <package> q-q   # Sudo uninstall (pls.mp3 + lacrimosa.mp3)"
            echo ""
            echo "SOUNDS:"
            echo "  Install  → cute-uwu.mp3"
            echo "  Uninstall → lacrimosa.mp3 (plays to completion)"
            echo "  Via pls  → pls.mp3 + one of above"
            echo "  Volume   → $VALKYRIE_SOUND_VOLUME% (adjust with sound-volume)"
            echo ""
            echo "EXAMPLES:"
            echo "  :3 firefox"
            echo "  :3 neofetch q-q"
            echo "  pls :3 protonup-qt q-q"
            return 0
        case "yeet"
            play_sound "no-i-forgot"
            echo "Clean Package Cache (yeet)"
            echo ""
            echo "USAGE:"
            echo "  yeet"
            echo ""
            echo "DESCRIPTION:"
            echo "  Cleans yay package cache interactively"
            echo "  Plays yeet.mp3 on start"
            echo "  Plays vine-boom.mp3 when you type 'n'"
            echo "  Plays dog-clicker.mp3 when you type 'y'"
            echo ""
            echo "SOUNDS: yeet.mp3 @ $VALKYRIE_SOUND_VOLUME%"
            echo "        + interactive y/n sounds via expect wrapper"
            return 0
        case "with-sounds"
            play_sound "no-i-forgot"
            echo "Interactive Command Sound Wrapper (with-sounds)"
            echo ""
            echo "USAGE:"
            echo "  with-sounds <command> [args...]"
            echo ""
            echo "DESCRIPTION:"
            echo "  Wraps any interactive command to play sounds on y/n input"
            echo "  Uses expect to intercept your keypresses"
            echo "  Plays dog-clicker.mp3 when you type 'y'"
            echo "  Plays vine-boom.mp3 when you type 'n'"
            echo ""
            echo "EXAMPLES:"
            echo "  with-sounds pacman -Syu"
            echo "  with-sounds yay -R firefox"
            echo "  with-sounds rm -i file.txt"
            echo ""
            echo "VOLUME: $VALKYRIE_SOUND_VOLUME% (adjust with sound-volume)"
            return 0
        case "pls-its-broken"
            play_sound "no-i-forgot"
            echo "Fix Pacman Database Lock (pls-its-broken)"
            echo ""
            echo "USAGE:"
            echo "  pls-its-broken"
            echo ""
            echo "DESCRIPTION:"
            echo "  Removes pacman database lock file"
            echo "  Use when pacman gets stuck or locked"
            echo "  Equivalent to: sudo rm /var/lib/pacman/db.lock"
            echo ""
            echo "SOUND: its-broken.mp3 @ $VALKYRIE_SOUND_VOLUME%"
            return 0
        case "seek"
            play_sound "no-i-forgot"
            echo "Package Search (seek)"
            echo ""
            echo "USAGE:"
            echo "  seek"
            echo ""
            echo "DESCRIPTION:"
            echo "  Launches pacseek interactive package browser"
            echo "  Plays start sound, then exit sound on completion"
            echo ""
            echo "SOUNDS:"
            echo "  Start  → start-pacman.mp3"
            echo "  Exit   → pac-death.mp3"
            echo "  Volume → $VALKYRIE_SOUND_VOLUME%"
            return 0
        case "fuckoff"
            play_sound "no-i-forgot"
            echo "Shutdown System (fuckoff)"
            echo ""
            echo "USAGE:"
            echo "  fuckoff"
            echo ""
            echo "DESCRIPTION:"
            echo "  Initiates system shutdown"
            echo "  Equivalent to: shutdown"
            echo ""
            echo "SOUND: fahhhhhhhhhhhhhhh.mp3 @ $VALKYRIE_SOUND_VOLUME%"
            return 0
        case ":P"
            play_sound "no-i-forgot"
            echo "Restart System (:P)"
            echo ""
            echo "USAGE:"
            echo "  :P"
            echo ""
            echo "DESCRIPTION:"
            echo "  Restarts the system after playing lizard-button sound 4 times"
            echo "  Equivalent to: restart"
            echo ""
            echo "SOUND: lizard-button.mp3 (plays 4 times with 0.3s delay) @ $VALKYRIE_SOUND_VOLUME%"
            return 0
        case "lets-go-gambling"
            play_sound "no-i-forgot"
            echo "Update All Packages (lets-go-gambling)"
            echo ""
            echo "USAGE:"
            echo "  lets-go-gambling"
            echo "  lets-go-gambling (alias)"
            echo ""
            echo "DESCRIPTION:"
            echo "  Updates all packages from:"
            echo "    • pacman (sudo pacman -Syu)"
            echo "    • yay (yay -Syu)"
            echo "    • flatpak (flatpak update)"
            echo ""
            echo "SOUNDS:"
            echo "  Start        → lets-go-gambling.mp3"
            echo "  All succeed  → lets-go-gambling-win.mp3"
            echo "  Any fail     → aw-dang-it.mp3"
            echo "  Volume       → $VALKYRIE_SOUND_VOLUME%"
            echo ""
            echo "RETURNS: 0 if all succeed, 1 if any fail"
            return 0
        case "pls"
            play_sound "no-i-forgot"
            echo "Sudo Wrapper (pls)"
            echo ""
            echo "USAGE:"
            echo "  pls <command> [args...]"
            echo "  pls <command> iforgor    (show command help)"
            echo ""
            echo "DESCRIPTION:"
            echo "  Runs command with sudo and plays pls.mp3 sound"
            echo "  Special handling for :3 and q-q commands"
            echo ""
            echo "EXAMPLES:"
            echo "  pls systemctl restart"
            echo "  pls :3 firefox"
            echo "  pls :3 firefox q-q"
            echo "  pls pacman -Syu iforgor"
            echo ""
            echo "SOUND: pls.mp3 (before command) @ $VALKYRIE_SOUND_VOLUME%"
            return 0
        case "sound-volume"
            play_sound "no-i-forgot"
            echo "Sound Volume Control (sound-volume)"
            echo ""
            echo "USAGE:"
            echo "  sound-volume              # Show current volume"
            echo "  sound-volume <0-100>      # Set volume"
            echo "  sound-volume --show       # Show current volume"
            echo ""
            echo "DESCRIPTION:"
            echo "  Adjusts volume for ALL terminal sounds globally"
            echo "  Setting persists between sessions"
            echo "  Affects: :3, yeet, pls-its-broken, seek, fuckoff,"
            echo "           :P, lets-go-gambling, pls, and all play_sound calls"
            echo ""
            echo "CURRENT VOLUME: $VALKYRIE_SOUND_VOLUME%"
            echo ""
            echo "EXAMPLES:"
            echo "  sound-volume 50   # Set to 50%"
            echo "  sound-volume 75   # Set to 75%"
            echo "  sound-volume 100  # Max volume"
            echo "  sound-volume 0    # Mute all sounds"
            return 0
        case "*"
            play_sound "no-i-forgot"
            # Check if it's a Fish function
            if functions -q "$cmd"
                fish -c "$cmd --help" 2>/dev/null
            else
                command "$cmd" --help 2>/dev/null
            end
            return $status
    end
end

#pls = sudo (with :3, q-q, and iforgor support)
function pls
    if test (count $argv) -eq 0
        echo "Usage: pls <command> [args...]"
        return 1
    end

    # Special case: last argument is 'iforgor' -> turn it into --help
    set last $argv[-1]
    if test "$last" = "iforgor"
        set -e argv[-1]
        set argv $argv --help
    end

    play_sound "pls"

    # Special handling for :3 - call directly without sudo
    # (yay/pacman handle their own privilege escalation)
    if test "$argv[1]" = ":3"
        set pkg $argv[2]
        set op $argv[3]
        :3 $pkg $op
    else if test "$argv[1]" = ":P"
        :P  # Run locally (sounds + sudo reboot inside)
    else if test "$argv[1]" = "fuckoff"
        fuckoff  # Run locally (sound + sudo shutdown inside)
    else
        sudo fish -c "source /home/valkyrie-sys/.config/fish/config.fish; $argv"
    end
end

#based package install :3 / uninstall q-q (standalone, not via pls)
function :3 --argument-names pkg op
    if test -z "$pkg"
        echo "Usage: :3 <package> [q-q]"
        echo "  :3 firefox       # install :3"
        echo "  :3 firefox q-q   # uninstall q-q"
        return 1
    end

    play_sound "cute-uwu"

    if test "$op" = "q-q"
        play_sound "lacrimosa"
        # Wait for lacrimosa to finish before uninstalling
        sleep 2
        echo "Uninstalling $pkg q-q~"
        if type -q yay
            auto_yes | yay -R "$pkg"
        else
            auto_yes | sudo pacman -R "$pkg"
        end
    else
        echo "Installing $pkg :3~"
        if type -q yay
            auto_yes | yay -S "$pkg"
        else
            auto_yes | sudo pacman -S "$pkg"
        end
    end
end

#fuckoff with sound (full play + delayed sudo shutdown)
function fuckoff
    play_sound "fahhhhhhhhhhhhhhh"
    sleep 4  # Adjust to sound length (test with `play_sound fahhhhhhhhhhhhhhh; sleep 5; echo DONE`)
    sudo shutdown -h now
end

#pls-its-broken with sound
function pls-its-broken
    play_sound "its-broken"
    sudo rm /var/lib/pacman/db.lock
end

#yeet with interactive sounds via expect wrapper
function yeet
    if not type -q expect
        echo "Error: 'expect' is required for interactive sound support"
        echo "Install with: sudo pacman -S expect"
        echo "Falling back to basic yeet..."
        play_sound "yeet"
        yay -Scc
        return $status
    end

    play_sound "yeet"
    with-sounds yay -Scc
end

#seek with pacseek sounds (fixed)
function seek
    play_sound "start-pacman"
    sleep 0.5
    pacseek
    set pacseek_status $status
    if test $pacseek_status -eq 0
        play_sound "pac-death"
    end
end

#:P with lizard-button 4 times (user sounds + sudo reboot)
function :P
    for i in (seq 4)
        play_sound "lizard-button"
        sleep 0.8
    end
    sudo reboot
end

#based update with gambling meme sounds (volume-aware via play_sound)
function lets_go_gambling
    play_sound lets-go-gambling
    echo "Let's go gambling! 🎰~"
    echo "Updating packages... wish us luck!"

    # Run updates and capture exit status
    auto_yes | sudo pacman -Syu
    set pacman_status $status

    auto_yes | yay -Syu
    set yay_status $status

    auto_yes | flatpak update
    set flatpak_status $status

    # Check if ANY command failed
    if test $pacman_status -ne 0 -o $yay_status -ne 0 -o $flatpak_status -ne 0
        echo "Aw dang it! 😭"
        play_sound aw-dang-it
        return 1
    end

    # Success!
    echo "Update complete! We won! 🎰"
    play_sound lets-go-gambling-win
end
