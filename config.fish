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

# Set settings for https://github.com/franciscolourenco/done
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
# Functions needed for !! and !$ https://github.com/oh-my-fish/plugin-bang-bang
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

# -----------------------------------------------------
# MUSIC LOOPING LOGIC
# -----------------------------------------------------
set -g _music_loop_pid ""

function start_music_loop --argument sound_name
    set sound_file "/home/valkyrie-sys/Tools/terminal-sounds/$sound_name.mp3"

    if test -f "$sound_file"
        set ffplay_volume $VALKYRIE_SOUND_VOLUME
        set paplay_volume (math $VALKYRIE_SOUND_VOLUME \* 655.36)

        if type -q ffplay
            # ffplay native loop
            ffplay -nodisp -autoexit -loop 0 -volume $ffplay_volume -loglevel quiet "$sound_file" >/dev/null 2>&1 &
            set -g _music_loop_pid $last_pid
        else if type -q mpv
            # mpv native loop
            mpv --no-video --loop --volume=$VALKYRIE_SOUND_VOLUME --no-terminal --no-msg-color "$sound_file" >/dev/null 2>&1 &
            set -g _music_loop_pid $last_pid
        else if type -q paplay
            # paplay manual loop in background fish process
            fish -c "while true; paplay --volume=$paplay_volume --device=@DEFAULT_SINK@ \"$sound_file\"; end" >/dev/null 2>&1 &
            set -g _music_loop_pid $last_pid
        end
    end
end

function stop_music_loop
    if test -n "$_music_loop_pid"
        kill $_music_loop_pid 2>/dev/null
        set -g _music_loop_pid ""
    end
end

## LIVE TYPING DETECTOR
function __detect_command_sounds
    set -l current_line (commandline -b | string trim)
    set -l current_time (date +%s%N | string sub -l 13)
    if not set -q __last_sound_trigger_time
        set -g __last_sound_trigger_time $current_time
    end
    set -l time_diff (math "$current_time - $__last_sound_trigger_time")
    set -l triggered_pattern ""

    # Existing Triggers
    if string match -qr '(^|\s)pls\s+fuckoff$' -- "$current_line"
        set triggered_pattern "pls fuckoff"
        if test "$triggered_pattern" != "$__last_sound_trigger_pattern" -o $time_diff -gt 2000
            play_sound "pls"; sleep 0.4; play_sound "fahhhhhhhhhhhhhhh"
        end
    else if string match -qr '(^|\s)pls\s+:P$' -- "$current_line"
        set triggered_pattern "pls :P"
        if test "$triggered_pattern" != "$__last_sound_trigger_pattern" -o $time_diff -gt 2000
            play_sound "pls"; sleep 0.4; for i in (seq 4); play_sound "lizard-button"; sleep 0.3; end
        end
    else if string match -qr '(^|\s)fuckoff$' -- "$current_line"
        set triggered_pattern "fuckoff"
        if test "$triggered_pattern" != "$__last_sound_trigger_pattern" -o $time_diff -gt 2000
            play_sound "fahhhhhhhhhhhhhhh"
        end
    else if string match -qr '(^|\s):P$' -- "$current_line"
        set triggered_pattern ":P"
        if test "$triggered_pattern" != "$__last_sound_trigger_pattern" -o $time_diff -gt 2000
            for i in (seq 4); play_sound "lizard-button"; sleep 0.3; end
        end
    else if string match -qr '(^|\s)pls$' -- "$current_line"
        set triggered_pattern "pls"
        if test "$triggered_pattern" != "$__last_sound_trigger_pattern" -o $time_diff -gt 2000
            play_sound "pls"
        end
    else if string match -qr '(^|\s)smash$' -- "$current_line"
        set triggered_pattern "smash"
        if test "$triggered_pattern" != "$__last_sound_trigger_pattern" -o $time_diff -gt 2000
            play_sound "smaaaash"
        end
    else if string match -qr '(^|\s)mine$' -- "$current_line"
        set triggered_pattern "mine"
        if test "$triggered_pattern" != "$__last_sound_trigger_pattern" -o $time_diff -gt 2000
            play_sound "mine-mine-mine"
        end
    else if string match -qr '(^|\s)plsgo$' -- "$current_line"
        set triggered_pattern "plsgo"
        if test "$triggered_pattern" != "$__last_sound_trigger_pattern" -o $time_diff -gt 2000
            play_sound "ack"
        end
    else if string match -qr '(^|\s)flex$' -- "$current_line"
        set triggered_pattern "flex"
        if test "$triggered_pattern" != "$__last_sound_trigger_pattern" -o $time_diff -gt 2000
            play_sound "can-you-feel-my-heart"
        end
    else if string match -qr '(^|\s):333$' -- "$current_line"
        set triggered_pattern ":333"
        if test "$triggered_pattern" != "$__last_sound_trigger_pattern" -o $time_diff -gt 2000
            play_sound "cute-uwu"
        end
    else if string match -qr '(^|\s):33$' -- "$current_line"
        set triggered_pattern ":33"
        if test "$triggered_pattern" != "$__last_sound_trigger_pattern" -o $time_diff -gt 2000
            play_sound "cute-uwu"
        end
    else if string match -qr '(^|\s):3$' -- "$current_line"
        set triggered_pattern ":3"
        if test "$triggered_pattern" != "$__last_sound_trigger_pattern" -o $time_diff -gt 2000
            play_sound "cute-uwu"
        end
    else if string match -qr '(^|\s)q-q$' -- "$current_line"
        set triggered_pattern "q-q"
        if test "$triggered_pattern" != "$__last_sound_trigger_pattern" -o $time_diff -gt 2000
            play_sound "lacrimosa"
        end
    else if string match -qr '(^|\s)touch-grass$' -- "$current_line"
        set triggered_pattern "touch-grass"
        if test "$triggered_pattern" != "$__last_sound_trigger_pattern" -o $time_diff -gt 2000
            play_sound "metal-pipe-falling"
        end
    else if string match -qr '(^|\s)nope$' -- "$current_line"
        set triggered_pattern "nope"
        if test "$triggered_pattern" != "$__last_sound_trigger_pattern" -o $time_diff -gt 2000
            play_sound "nope"
        end
    else if string match -qr '(^|\s)backrooms$' -- "$current_line"
        set triggered_pattern "backrooms"
        if test "$triggered_pattern" != "$__last_sound_trigger_pattern" -o $time_diff -gt 2000
            play_sound "burning-memory"
        end
    else if string match -qr '(^|\s)dox-em$' -- "$current_line"
        set triggered_pattern "dox-em"
        if test "$triggered_pattern" != "$__last_sound_trigger_pattern" -o $time_diff -gt 2000
            play_sound "allbase"
        end
    else if string match -qr '(^|\s)receipts$' -- "$current_line"
        set triggered_pattern "receipts"
        if test "$triggered_pattern" != "$__last_sound_trigger_pattern" -o $time_diff -gt 2000
            play_sound "credit-card-slam"
        end
    else if string match -qr '(^|\s)yap$' -- "$current_line"
        set triggered_pattern "yap"
        if test "$triggered_pattern" != "$__last_sound_trigger_pattern" -o $time_diff -gt 2000
            play_sound "hamster-dance"
        end
    else if string match -qr '(^|\s)sus$' -- "$current_line"
        set triggered_pattern "sus"
        if test "$triggered_pattern" != "$__last_sound_trigger_pattern" -o $time_diff -gt 2000
            play_sound "millionaire-suspense"
        end
    else if string match -qr '(^|\s)dial-up$' -- "$current_line"
        set triggered_pattern "dial-up"
        if test "$triggered_pattern" != "$__last_sound_trigger_pattern" -o $time_diff -gt 2000
            play_sound "aol-dial"
        end
    else if string match -qr '(^|\s)maid-outfit$' -- "$current_line"
        set triggered_pattern "maid-outfit"
        if test "$triggered_pattern" != "$__last_sound_trigger_pattern" -o $time_diff -gt 2000
            play_sound "maid-outfit"
        end
    else if string match -qr '(^|\s)wumbo$' -- "$current_line"
        set triggered_pattern "wumbo"
        if test "$triggered_pattern" != "$__last_sound_trigger_pattern" -o $time_diff -gt 2000
            play_sound "w-for-wumbo"
        end
    else if string match -qr '(^|\s)yoink$' -- "$current_line"
        set triggered_pattern "yoink"
        if test "$triggered_pattern" != "$__last_sound_trigger_pattern" -o $time_diff -gt 2000
            play_sound "yoink"
        end
    else if string match -qr '(^|\s)who-dis$' -- "$current_line"
        set triggered_pattern "who-dis"
        if test "$triggered_pattern" != "$__last_sound_trigger_pattern" -o $time_diff -gt 2000
            play_sound "new-phone-who-dis"
        end
    else if string match -qr '(^|\s)numba-nine$' -- "$current_line"
        set triggered_pattern "numba-nine"
        if test "$triggered_pattern" != "$__last_sound_trigger_pattern" -o $time_diff -gt 2000
            play_sound "big-smoke-order"
        end
    else if string match -qr '(^|\s)do-a-barrel$' -- "$current_line"
        set triggered_pattern "do-a-barrel"
        if test "$triggered_pattern" != "$__last_sound_trigger_pattern" -o $time_diff -gt 2000
            play_sound "do-a-barrel"
        end
    else if string match -qr '(^|\s)this-is-sparta$' -- "$current_line"
        set triggered_pattern "this-is-sparta"
        if test "$triggered_pattern" != "$__last_sound_trigger_pattern" -o $time_diff -gt 2000
            play_sound "spartaa"
        end
    else if string match -qr '(^|\s)let-me-do-it-4-u$' -- "$current_line"
        set triggered_pattern "let-me-do-it-4-u"
        if test "$triggered_pattern" != "$__last_sound_trigger_pattern" -o $time_diff -gt 2000
            play_sound "let-me-do-it-for-you"
        end
    else if string match -qr '(^|\s)trololo$' -- "$current_line"
        set triggered_pattern "trololo"
        if test "$triggered_pattern" != "$__last_sound_trigger_pattern" -o $time_diff -gt 2000
            play_sound "trololo"
        end
    else if string match -qr '(^|\s)forever-alone$' -- "$current_line"
        set triggered_pattern "forever-alone"
        if test "$triggered_pattern" != "$__last_sound_trigger_pattern" -o $time_diff -gt 2000
            play_sound "forever-alone"
        end
    else if string match -qr '(^|\s)vitas$' -- "$current_line"
        set triggered_pattern "vitas"
        if test "$triggered_pattern" != "$__last_sound_trigger_pattern" -o $time_diff -gt 2000
            play_sound "vitas-7th-element"
        end
    else if string match -qr '(^|\s)wrong-numba$' -- "$current_line"
        set triggered_pattern "wrong-numba"
        if test "$triggered_pattern" != "$__last_sound_trigger_pattern" -o $time_diff -gt 2000
            play_sound "wrong-numba"
        end
    end

    if test -n "$triggered_pattern"
        set -g __last_sound_trigger_time $current_time
        set -g __last_sound_trigger_pattern "$triggered_pattern"
    end
end

function __bind_with_sound_check -a key
    bind $key "commandline -i '$key'; __detect_command_sounds"
end

# Core Bindings
if status --is-interactive
    # Live sound triggers (existing)
    __bind_with_sound_check 'f' # fuckoff
    __bind_with_sound_check 'P' # :P
    __bind_with_sound_check 's' # pls / smash
    __bind_with_sound_check ' ' # space triggers all
    __bind_with_sound_check 'h' # smash, touch
    __bind_with_sound_check 'e' # mine
    __bind_with_sound_check 'o' # plsgo
    __bind_with_sound_check 'x' # flex
    __bind_with_sound_check 't' # fast, touch

    # Bindings for :3 family and q-q
    __bind_with_sound_check '3' # :3, :33, :333
    __bind_with_sound_check 'q' # q-q
    __bind_with_sound_check '-' # q-q

    # NEW Bindings for Navigation & themed commands
    __bind_with_sound_check 'n' # nope
    __bind_with_sound_check 'b' # backrooms
    __bind_with_sound_check 'd' # dox-em, dial-up, dript
    __bind_with_sound_check 'r' # receipts
    __bind_with_sound_check 'y' # yap, yoink
    __bind_with_sound_check 'w' # who-dis, wumbo, wrong-numba
    __bind_with_sound_check 'm' # maid-outfit

    # NEW Bindings for System Info commands
    __bind_with_sound_check 'u' # numba-nine
    __bind_with_sound_check 'l' # trololo, let-me-do-it-4-u
    __bind_with_sound_check 'a' # do-a-barrel, this-is-sparta
    __bind_with_sound_check 'v' # vitas
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
    set cmd_str (string join " " $argv)

    # Create expect script dynamically using printf
    printf '%s\n' '#!/usr/bin/expect -f
log_user 0
exp_internal 0
set timeout -1
set volume $env(VALKYRIE_SOUND_VOLUME)
set sound_dir "/home/valkyrie-sys/Tools/terminal-sounds"

proc play_sound {sound_name} {
    global volume sound_dir
    set sound_file "$sound_dir/$sound_name.mp3"
    if {[file exists $sound_file]} {
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

spawn fish -c "source /home/valkyrie-sys/.config/fish/config.fish; '$cmd_str'"

interact {
    -re {[yY]} {
        play_sound "dog-clicker"
        send -- $interact_out(0,string)
    }
    -re {[nN]} {
        play_sound "vine-boom"
        send -- $interact_out(0,string)
    }
}

wait' > "$expect_script"

    chmod +x "$expect_script"

    # Run the command through expect wrapper
    env VALKYRIE_SOUND_VOLUME=$VALKYRIE_SOUND_VOLUME "$expect_script"
    set exit_status $status

    # Cleanup
    rm -f "$expect_script"

    return $exit_status
end

# Common use
alias .. 'cd ..'
alias ... 'cd ../..'
alias .... 'cd ../../..'
alias ..... 'cd ../../../..'
alias ...... 'cd ../../../../..'
alias big 'expac -H M "%m\t%n" | sort -h | nl'      # Sort installed packages according to size in MB (expac must be installed)
alias dir 'dir --color=auto'
alias gitpkg 'pacman -Q | grep -i "\-git" | wc -l' # List amount of -git packages
alias grep 'ugrep --color=auto'
alias egrep 'ugrep -E --color=auto'
alias fgrep 'ugrep -F --color=auto'
alias grubup 'sudo update-grub'
alias hw 'hwinfo --short'                       # Hardware Info
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

# =====================================================
# NEW THEMED ALIASES (Valkyrie Edition)
# =====================================================

## 📂 Navigation & Listing (with sounds via live detector)
alias nope 'cd ..'
alias backrooms 'cd ../..'
alias dox-em 'eza -a --color=always --group-directories-first --icons'
alias receipts 'builtin history --show-time="%F %T "'

## 📝 Reading & Editing (with sounds via live detector)
alias yap 'bat --style header --style snip --style changes --style header'
alias sus 'ugrep --color=auto'
alias dial-up 'journalctl -p 3 -xb'

## 💾 System & Maintenance (with sounds via live detector)
alias maid-outfit 'cleanup'
alias wumbo 'expac -H M "%m\t%n" | sort -h | nl'
alias yoink 'wget -c'
alias numba-nine 'free -h; htop'
alias do-a-barrel 'journalctl -p 3 | less'
alias this-is-sparta 'du -sh * | sort -hr | head -15'
alias let-me-do-it-4-u 'top -o %CPU'
alias trololo 'curl wttr.in | head -15'
alias forever-alone 'pstree -p | less'
alias vitas 'neofetch | lolcat | hyfetch'

## 🌐 Network & Mirrors (with sounds via live detector)
alias who-dis 'ip -color'

## 📦 Package Management (with sounds via live detector)
alias dript 'flatpak'
#Cachy-update (all)
alias lets-go-gambling 'lets_go_gambling'

## 🛡️ Noob Helpers (with sounds via live detector)
alias wrong-numba 'man pacman'
alias iforgor-now 'iforgor help now'

## Run hyfetch if session is interactive
if status --is-interactive && type -q hyfetch
   hyfetch
end

## Terminal launch sound
if status --is-interactive
    play_sound "oo-ee-ee-aa" &
end

# -----------------------------------------------------
# CUSTOM COMMANDS (With Live Sound & Expect Wrapper)
# -----------------------------------------------------

# flex (hyfetch + hwinfo) with interactive sounds
function flex
    set -l current_time (date +%s%N | string sub -l 13)
    if test (math "$current_time - $__last_sound_trigger_time") -gt 3000
        play_sound "can-you-feel-my-heart"
    end
    if status --is-interactive && type -q hyfetch
        with-sounds hwinfo $arg --short
    end
end

# mine (eza/ls) with interactive sounds
function mine --description "Play 'mine-mine-mine' then eza (ls)"
    set -l current_time (date +%s%N | string sub -l 13)
    if test (math "$current_time - $__last_sound_trigger_time") -gt 3000
        play_sound "mine-mine-mine"
    end
    with-sounds eza $argv -al --color=always --group-directories-first --icons
end

# smash (rm -rf with interactive Earthbound battle sounds)
function smash --description "Play smaaaash then rm -rf with Earthbound battle sounds"
    set -l current_time (date +%s%N | string sub -l 13)
    if not set -q __last_sound_trigger_time
        set -g __last_sound_trigger_time $current_time
    end
    if test (math "$current_time - $__last_sound_trigger_time") -gt 3000
        play_sound "smaaaash"
    end

    # Show what's about to be deleted
    echo "⚔️  SMASH BATTLE INCOMING! ⚔️"
    echo "About to delete: $argv"
    echo ""

    # Interactive prompt with custom expect wrapper for Earthbound sounds
    set expect_script "/tmp/smash-battle-sounds-$fish_pid.exp"

    echo '#!/usr/bin/expect -f
log_user 0
exp_internal 0
set timeout -1
set volume $env(VALKYRIE_SOUND_VOLUME)
set sound_dir "/home/valkyrie-sys/Tools/terminal-sounds"

# Helper to play sound based on volume
proc play_sound {sound_name} {
    global volume sound_dir
    set sound_file "$sound_dir/$sound_name.mp3"

    if {[file exists $sound_file]} {
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

# Spawn read prompt
spawn sh -c "read -p \"Are you ready for battle? (y/n): \" answer; echo \$answer"

# Main interaction loop with Earthbound battle sounds
interact {
    # Match when user types "y" or "Y" (Partner Turn - proceed)
    -re {[yY]} {
        play_sound "earthbound-partner-turn"
        send -- $interact_out(0,string)
    }
    # Match when user types "n" or "N" (Enemy Turn - cancel)
    -re {[nN]} {
        play_sound "earthbound-enemy-turn"
        send -- $interact_out(0,string)
    }
}

# Wait for program to finish
wait' > "$expect_script"

    chmod +x "$expect_script"

    # Run the interactive prompt through expect wrapper
    env VALKYRIE_SOUND_VOLUME=$VALKYRIE_SOUND_VOLUME "$expect_script"
    set prompt_status $status

    # Cleanup expect script
    rm -f "$expect_script"

    # If user said yes (y/Y), proceed with deletion
    if test $prompt_status -eq 0
        echo "💥 Executing smash..."
        sudo rm -rf $argv
        set smash_status $status

        if test $smash_status -eq 0
            play_sound "earthbound-you-win"
            echo "✨ Victory! Files obliterated!"
        else
            play_sound "earthbound-partner-die"
            echo "💔 Battle lost... deletion failed"
        end

        return $smash_status
    else
        play_sound "earthbound-enemy-turn"
        echo "🛡️  Battle averted! Files safe."
        return 1
    end
end

# plsgo (cd + clear + eza)
# Note: 'cd' cannot be wrapped in with-sounds (it's a shell builtin)
# We only wrap the eza part.
function plsgo
    set -l current_time (date +%s%N | string sub -l 13)
    if test (math "$current_time - $__last_sound_trigger_time") -gt 3000
        play_sound "ack"
    end

    if test (count $argv) -eq 0
        cd ~
    else
        cd $argv
    end
    clear
    with-sounds eza -al --color=always --group-directories-first --icons
end

# gotta-go-fast (mirror refresh with sonic theme)
function gotta-go-fast
    # Check if sonic theme is already playing
    if test -n "$_music_loop_pid" && kill -0 $_music_loop_pid 2>/dev/null
        echo "Already going fast! 🦔💨"
        return 0
    end

    # Start loop for long operations
    start_music_loop "sonic-x-theme"
    trap "stop_music_loop" EXIT INT TERM

    echo "Gotta go fast! Finding fastest mirrors... 🦔💨"
    # Use standard reflector flags from the 'mirror' alias
    sudo reflector -f 30 -l 30 --number 10 --verbose --save /etc/pacman.d/mirrorlist

    stop_music_loop
    trap - EXIT INT TERM

    # Play victory sound only if not already playing
    if not pgrep -f "haha-ha-one.mp3" >/dev/null 2>&1
        play_sound "haha-ha-one"
    end
end

# touch-grass (exit with metal pipe)
# Note: Flag used to prevent double playing with on_terminal_exit
set -g _touch_grass_active 0
function touch-grass
    set -g _touch_grass_active 1
    # Live sound handled by detector, but play here if detector missed it
    set -l current_time (date +%s%N | string sub -l 13)
    if test (math "$current_time - $__last_sound_trigger_time") -gt 3000
        play_sound "metal-pipe-falling"
    end
    exit
end

# =====================================================
# FIXED IFORGOR COMMAND - Undertale themed help system
# =====================================================

# Signal handler for Ctrl+C (MUST come BEFORE main function)
function __handle_iforgor_interrupt --on-signal INT
    if set -q __iforgor_executing
        play_sound "undertale-slash-attack" &
        set -g __iforgor_interrupt_flag 1
        commandline -f repaint
    end
end

# Helper: Type text with sound effects (defined OUTSIDE main function)
function __type_slowly --argument text speed sound_mode
    set -l delay (math "1.0 / $speed")
    set -l sound_choice

    # Pick sound ONCE, use for entire text
    if test "$sound_mode" = "random"
        if test (random 1 2) -eq 1
            set sound_choice "text-sans"
        else
            set sound_choice "text-papyrus"
        end
    else if test "$sound_mode" = "sans"
        set sound_choice "text-sans"
    else if test "$sound_mode" = "papyrus"
        set sound_choice "text-papyrus"
    end

    for char in (string split '' "$text")
        # Check for interrupt flag before each character
        if set -q __iforgor_interrupt_flag
            printf "\n"
            return 130
        end

        printf "%s" "$char"

        # Skip sound for spaces and box-drawing characters
        if not string match -q -e "$char" " ═║╔╗╚╝→"
            play_sound "$sound_choice" &
        else if test "$char" = " "
            sleep 0.1  # Pause longer for spaces
        end

        sleep $delay
    end
    sleep 0.15
end

# Main iforgor function
function iforgor --argument cmd --argument fast_mode
    set -g __iforgor_executing 1

    # Case 1: No arguments → Show help menu
    if test -z "$cmd"
        play_sound "no-i-forgot"
        sleep 2
        iforgor help
        set -e __iforgor_executing
        return 0
    end

    # Case 2: Help/all/commands command
    if test "$cmd" = "help" -o "$cmd" = "all" -o "$cmd" = "commands"

        # FAST MODE: Instant display with only "ohyes" at end
        if test "$fast_mode" = "now"
            echo "╔══════════════════════════════════════════════════════════════╗"
            echo "║            S I L L Y  Terminal Commands Reference            ║"
            echo "╚══════════════════════════════════════════════════════════════╝"
            echo ""
            echo "📦 PACKAGE MANAGEMENT"
            echo "  :3 <pkg>            → Install (-S) with cute-uwu.mp3"
            echo "  :33 <pkg>           → Sync+Install (-Sy) (cute-uwu x2)"
            echo "  :333 <pkg>          → Update+Install (-Syu) (cute-uwu x3)"
            echo "  :3 <pkg> q-q        → Uninstall with lacrimosa.mp3"
            echo "  pls :3 <pkg>        → Sudo install (pls.mp3 + cute-uwu.mp3)"
            echo "  yeet                → Clean cache (interactive with sounds)"
            echo "  pls-its-broken      → Fix pacman db lock with its-broken.mp3"
            echo "  seek                → Launch pacseek with start-pacman.mp3"
            echo "  lets-go-gambling    → Update all with gambling sounds"
            echo "  dript               → Flatpak package manager (tokyo-dript.mp3)"
            echo ""
            echo "📂 NAVIGATION & LISTING"
            echo "  plsgo <dir>         → cd + clear + ls (ack.mp3)"
            echo "  mine <file>         → List files (mine-mine-mine.mp3)"
            echo "  smash <file>        → Delete (rm -rf) (smaaaash.mp3)"
            echo "  flex                → Show sys info (can-you-feel-my-heart.mp3)"
            echo "  gotta-go-fast       → Update mirrors (sonic-x-theme.mp3)"
            echo "  touch-grass         → Exit terminal (metal-pipe-falling.mp3)"
            echo "  nope                → Go back one dir (nope.mp3)"
            echo "  backrooms           → Go back two dirs (burning-memory.mp3)"
            echo "  dox-em              → List all files inc. dotfiles (allbase.mp3)"
            echo "  receipts            → Show command history (credit-card-slam.mp3)"
            echo ""
            echo "📝 READING & EDITING"
            echo "  yap <file>          → Display file contents (hamster-dance.mp3)"
            echo "  sus <pattern>       → Search for text (millionaire-suspense.mp3)"
            echo "  dial-up             → Show system errors (aol-dial.mp3)"
            echo ""
            echo "💾 SYSTEM & MAINTENANCE"
            echo "  maid-outfit         → Clean orphaned packages (maid-outfit.mp3)"
            echo "  wumbo               → Show package sizes (w-for-wumbo.mp3)"
            echo "  yoink               → Download files (yoink.mp3)"
            echo ""
            echo "🌐 NETWORK & MIRRORS"
            echo "  who-dis             → Show IP address (new-phone-who-dis.mp3)"
            echo ""
            echo "🎮 SYSTEM INFO"
            echo "  numba-nine          → free -h + htop (big-smoke-order.mp3)"
            echo "  do-a-barrel         → journalctl errors less (do-a-barrel.mp3)"
            echo "  this-is-sparta      → du -sh top 15 hogs (spartaa.mp3)"
            echo "  let-me-do-it-4-u    → top CPU abusers (let-me-do-it-for-you.mp3)"
            echo "  trololo             → curl wttr.in weather (trololo.mp3)"
            echo "  forever-alone       → pstree process tree (forever-alone.mp3)"
            echo "  vitas               → hyfetch rainbow (vitas-7th-element.mp3)"
            echo ""
            echo "🛡️  NOOB HELPERS"
            echo "  wrong-numba         → Arch, not Debian! (wrong-numba.mp3)"
            echo ""
            echo "🔧 SYSTEM COMMANDS"
            echo "  fuckoff             → Shutdown with fahhhhhhhhhhhhhhh.mp3"
            echo "  :P                  → Restart with lizard-button.mp3 (4x)"
            echo ""
            echo "🎛️  UTILITY"
            echo "  pls <cmd>           → Sudo + pls.mp3"
            echo "  iforgor <cmd>       → Show command help + no-i-forgot.mp3"
            echo "  sound-volume <0-100> → Adjust all sound volumes"
            echo ""

            play_sound "ohyes" &
            set -e __iforgor_executing
            return 0
        end

        # SLOW MODE: Animated with music and voice selection
        start_music_loop "gasters-theme"

        echo "Choose typing voice:"
        echo "  1) Random (Sans or Papyrus)"
        echo "  2) Papyrus"
        echo "  3) Sans"
        read -l -P "  Enter choice (1-3): " choice

        set -l typing_sound "random"
        switch "$choice"
            case "2"
                set typing_sound "papyrus"
            case "3"
                set typing_sound "sans"
            case "*"
                set typing_sound "random"
        end

        # Display menu with animation
        echo ""
        __type_slowly "╔══════════════════════════════════════════════════════════════╗" 15 "$typing_sound"
        echo ""
        __type_slowly "║            S I L L Y  Terminal Commands Reference            ║" 15 "$typing_sound"
        echo ""
        __type_slowly "╚══════════════════════════════════════════════════════════════╝" 15 "$typing_sound"
        echo ""
        echo ""
        __type_slowly "📦 PACKAGE MANAGEMENT" 18 "$typing_sound"
        echo ""
        __type_slowly "  :3 <pkg>            → Install (-S) with cute-uwu.mp3" 18 "$typing_sound"
        echo ""
        __type_slowly "  :33 <pkg>           → Sync+Install (-Sy) (cute-uwu x2)" 18 "$typing_sound"
        echo ""
        __type_slowly "  :333 <pkg>          → Update+Install (-Syu) (cute-uwu x3)" 18 "$typing_sound"
        echo ""
        __type_slowly "  :3 <pkg> q-q        → Uninstall with lacrimosa.mp3" 18 "$typing_sound"
        echo ""
        __type_slowly "  pls :3 <pkg>        → Sudo install (pls.mp3 + cute-uwu.mp3)" 18 "$typing_sound"
        echo ""
        __type_slowly "  yeet                → Clean cache (interactive with sounds)" 18 "$typing_sound"
        echo ""
        __type_slowly "  pls-its-broken      → Fix pacman db lock with its-broken.mp3" 18 "$typing_sound"
        echo ""
        __type_slowly "  seek                → Launch pacseek with start-pacman.mp3" 18 "$typing_sound"
        echo ""
        __type_slowly "  lets-go-gambling    → Update all with gambling sounds" 18 "$typing_sound"
        echo ""
        __type_slowly "  dript               → Flatpak package manager (tokyo-dript.mp3)" 18 "$typing_sound"
        echo ""
        echo ""
        __type_slowly "📂 NAVIGATION & LISTING" 18 "$typing_sound"
        echo ""
        __type_slowly "  plsgo <dir>         → cd + clear + ls (ack.mp3)" 18 "$typing_sound"
        echo ""
        __type_slowly "  mine <file>         → List files (mine-mine-mine.mp3)" 18 "$typing_sound"
        echo ""
        __type_slowly "  smash <file>        → Delete (rm -rf) (smaaaash.mp3)" 18 "$typing_sound"
        echo ""
        __type_slowly "  flex                → Show sys info (can-you-feel-my-heart.mp3)" 18 "$typing_sound"
        echo ""
        __type_slowly "  gotta-go-fast       → Update mirrors (sonic-x-theme.mp3)" 18 "$typing_sound"
        echo ""
        __type_slowly "  touch-grass         → Exit terminal (metal-pipe-falling.mp3)" 18 "$typing_sound"
        echo ""
        __type_slowly "  nope                → Go back one dir (nope.mp3)" 18 "$typing_sound"
        echo ""
        __type_slowly "  backrooms           → Go back two dirs (burning-memory.mp3)" 18 "$typing_sound"
        echo ""
        __type_slowly "  dox-em              → List all files inc. dotfiles (allbase.mp3)" 18 "$typing_sound"
        echo ""
        __type_slowly "  receipts            → Show command history (credit-card-slam.mp3)" 18 "$typing_sound"
        echo ""
        echo ""
        __type_slowly "📝 READING & EDITING" 18 "$typing_sound"
        echo ""
        __type_slowly "  yap <file>          → Display file contents (hamster-dance.mp3)" 18 "$typing_sound"
        echo ""
        __type_slowly "  sus <pattern>       → Search for text (millionaire-suspense.mp3)" 18 "$typing_sound"
        echo ""
        __type_slowly "  dial-up             → Show system errors (aol-dial.mp3)" 18 "$typing_sound"
        echo ""
        echo ""
        __type_slowly "💾 SYSTEM & MAINTENANCE" 18 "$typing_sound"
        echo ""
        __type_slowly "  maid-outfit         → Clean orphaned packages (maid-outfit.mp3)" 18 "$typing_sound"
        echo ""
        __type_slowly "  wumbo               → Show package sizes (w-for-wumbo.mp3)" 18 "$typing_sound"
        echo ""
        __type_slowly "  yoink               → Download files (yoink.mp3)" 18 "$typing_sound"
        echo ""
        echo ""
        __type_slowly "🌐 NETWORK & MIRRORS" 18 "$typing_sound"
        echo ""
        __type_slowly "  who-dis             → Show IP address (new-phone-who-dis.mp3)" 18 "$typing_sound"
        echo ""
        echo ""
        __type_slowly "🎮 SYSTEM INFO" 18 "$typing_sound"
        echo ""
        __type_slowly "  numba-nine          → free -h + htop (big-smoke-order.mp3)" 18 "$typing_sound"
        echo ""
        __type_slowly "  do-a-barrel         → journalctl errors less (do-a-barrel.mp3)" 18 "$typing_sound"
        echo ""
        __type_slowly "  this-is-sparta      → du -sh top 15 hogs (spartaa.mp3)" 18 "$typing_sound"
        echo ""
        __type_slowly "  let-me-do-it-4-u    → top CPU abusers (let-me-do-it-for-you.mp3)" 18 "$typing_sound"
        echo ""
        __type_slowly "  trololo             → curl wttr.in weather (trololo.mp3)" 18 "$typing_sound"
        echo ""
        __type_slowly "  forever-alone       → pstree process tree (forever-alone.mp3)" 18 "$typing_sound"
        echo ""
        __type_slowly "  vitas               → hyfetch rainbow (vitas-7th-element.mp3)" 18 "$typing_sound"
        echo ""
        echo ""
        __type_slowly "🛡️  NOOB HELPERS" 18 "$typing_sound"
        echo ""
        __type_slowly "  wrong-numba         → Arch, not Debian! (wrong-numba.mp3)" 18 "$typing_sound"
        echo ""
        echo ""
        __type_slowly "🔧 SYSTEM COMMANDS" 18 "$typing_sound"
        echo ""
        __type_slowly "  fuckoff             → Shutdown with fahhhhhhhhhhhhhhh.mp3" 18 "$typing_sound"
        echo ""
        __type_slowly "  :P                  → Restart with lizard-button.mp3 (4x)" 18 "$typing_sound"
        echo ""
        echo ""
        __type_slowly "🎛️  UTILITY" 18 "$typing_sound"
        echo ""
        __type_slowly "  pls <cmd>           → Sudo + pls.mp3" 18 "$typing_sound"
        echo ""
        __type_slowly "  iforgor <cmd>       → Show command help + no-i-forgot.mp3" 18 "$typing_sound"
        echo ""
        __type_slowly "  sound-volume <0-100> → Adjust all sound volumes" 18 "$typing_sound"
        echo ""

        play_sound "ohyes" &
        stop_music_loop
        set -e __iforgor_interrupt_flag
        set -e __iforgor_executing
        return 0
    end

    # Case 3: Help for specific commands
    switch "$cmd"
        case "plsgo"
            play_sound "no-i-forgot"
            sleep 1
            echo "Navigate & List (plsgo)"
            echo "SOUND: ack.mp3"

        case "mine"
            play_sound "no-i-forgot"
            sleep 1
            echo "Claim Files (mine)"
            echo "SOUND: mine-mine-mine.mp3"

        case "smash"
            play_sound "no-i-forgot"
            sleep 1
            echo "Smash Files (smash)"
            echo "SOUND: smaaaash.mp3"

        case "flex"
            play_sound "no-i-forgot"
            sleep 1
            echo "Show System (flex)"
            echo "SOUND: can-you-feel-my-heart.mp3"

        case "touch-grass"
            play_sound "no-i-forgot"
            sleep 1
            echo "Exit Terminal (touch-grass)"
            echo "SOUND: metal-pipe-falling.mp3"

        case ":3"
            play_sound "no-i-forgot"
            sleep 1
            echo "Package Management (:3)"
            echo "SOUND: cute-uwu.mp3"

        case "*"
            play_sound "no-i-forgot"
            sleep 1
            echo "Unknown command: $cmd"
            echo "Use 'iforgor' or 'iforgor help' to see all commands"
    end

    set -e __iforgor_executing
    return 0
end

# Alias for fast mode
alias iforgor-now 'iforgor help now'

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

    set -l current_time (date +%s%N | string sub -l 13)
    if not set -q __last_sound_trigger_time
        set -g __last_sound_trigger_time $current_time
    end
    if test (math "$current_time - $__last_sound_trigger_time") -gt 3000
        play_sound "pls"
    end

    # Special handling for :3 - call directly without sudo
    # (yay/pacman handle their own privilege escalation)
    if test "$argv[1]" = ":3"
        set pkg $argv[2]
        set op $argv[3]
        :3 $pkg $op
    else if test "$argv[1]" = ":33"
        set pkg $argv[2]
        :33 $pkg
    else if test "$argv[1]" = ":333"
        set pkg $argv[2]
        :333 $pkg
    else if test "$argv[1]" = ":P"
        :P  # Run locally (sounds + sudo reboot inside)
    else if test "$argv[1]" = "fuckoff"
        fuckoff  # Run locally (sound + sudo shutdown inside)
    else if test "$argv[1]" = "smash"
        # Run sound locally (checked in function), then sudo rm
        # smash is rm -rf.
        play_sound "smaaaash"
        sudo rm -rf $argv[2..-1]
    else if test "$argv[1]" = "mine"
        play_sound "mine-mine-mine"
        sudo eza $argv[2..-1] -al --color=always --group-directories-first --icons
    else
        sudo fish -c "source /home/valkyrie-sys/.config/fish/config.fish; $argv"
    end
end

#based package install :3 / uninstall q-q (standalone, not via pls)
function :3 --argument-names pkg op
    if test -z "$pkg"
        echo "Usage: :3 <package> [q-q]"
        echo "  :3 firefox        # install :3"
        echo "  :3 firefox q-q    # uninstall q-q"
        return 1
    end

    play_sound "cute-uwu"

    if test "$op" = "q-q"
        play_sound "lacrimosa"
        # Wait for lacrimosa to finish before uninstalling
        sleep 2
        echo "Uninstalling $pkg q-q~"
        if type -q yay
            # Use --noconfirm for auto-yes without broken pipe
            yay -R "$pkg" --noconfirm
        else
            sudo pacman -R "$pkg" --noconfirm
        end
        # Check exit status for q-q
        set install_status $status
        if test $install_status -ne 0
            play_sound "aw-dang-it"
        end
    else
        echo "Installing $pkg :3~"

        # Start music loop and trap cleanup
        start_music_loop "earthbound-what-battle-moment"
        trap "stop_music_loop" EXIT INT TERM

        if type -q yay
            yay -S "$pkg" --noconfirm
        else
            sudo pacman -S "$pkg" --noconfirm
        end

        set install_status $status

        # Stop music loop immediately
        stop_music_loop
        trap - EXIT INT TERM

        if test $install_status -eq 0
            play_sound "earthbound-you-win"
        else
            play_sound "aw-dang-it"
        end
    end
end

# :33 = -Sy (Sync+Install)
function :33 --argument-names pkg
    play_sound "cute-uwu"
    sleep 0.2
    play_sound "cute-uwu"

    # Start music loop and trap cleanup
    start_music_loop "earthbound-what-battle-moment"
    trap "stop_music_loop" EXIT INT TERM

    if test -z "$pkg"
        if type -q yay
            yay -Sy --noconfirm
        else
            sudo pacman -Sy --noconfirm
        end
    else
        echo "Syncing and Installing $pkg :33~"
        if type -q yay
            yay -Sy "$pkg" --noconfirm
        else
            sudo pacman -Sy "$pkg" --noconfirm
        end
    end

    set install_status $status

    # Stop music loop
    stop_music_loop
    trap - EXIT INT TERM

    if test $install_status -eq 0
        play_sound "earthbound-you-win"
    else
        play_sound "aw-dang-it"
    end
end

# :333 = -Syu (Update+Install)
function :333 --argument-names pkg
    play_sound "cute-uwu"
    sleep 0.2
    play_sound "cute-uwu"
    sleep 0.2
    play_sound "cute-uwu"

    # Start music loop and trap cleanup
    start_music_loop "earthbound-what-battle-moment"
    trap "stop_music_loop" EXIT INT TERM

    if test -z "$pkg"
        # Just update
        if type -q yay
            yay -Syu --noconfirm
        else
            sudo pacman -Syu --noconfirm
        end
    else
        echo "Updating and Installing $pkg :333~"
        if type -q yay
            yay -Syu "$pkg" --noconfirm
        else
            sudo pacman -Syu "$pkg" --noconfirm
        end
    end

    set install_status $status

    # Stop music loop
    stop_music_loop
    trap - EXIT INT TERM

    if test $install_status -eq 0
        play_sound "earthbound-you-win"
    else
        play_sound "aw-dang-it"
    end
end

#fuckoff with sound (full play + delayed sudo shutdown)
function fuckoff
    set -l current_time (date +%s%N | string sub -l 13)
    if test (math "$current_time - $__last_sound_trigger_time") -gt 3000
        play_sound "fahhhhhhhhhhhhhhh"
    end
    sleep 4  # Adjust to sound length (test with `play_sound "fahhhhhhhhhhhhhhh"; sleep 5; echo DONE`)
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
    set -l current_time (date +%s%N | string sub -l 13)
    if test (math "$current_time - $__last_sound_trigger_time") -gt 3000
        for i in (seq 4)
            play_sound "lizard-button"
            sleep 0.8
        end
    end
    sudo reboot
end

# =====================================================
# NEW THEMED FUNCTIONS (Integrated with Live Sound System)
# =====================================================

## 📂 Navigation Functions

# nope (cd .. with timer guard)
function nope --description "Go back one directory (Homer backing into bushes)"
    set -l current_time (date +%s%N | string sub -l 13)
    if not set -q __last_sound_trigger_time
        set -g __last_sound_trigger_time $current_time
    end
    if test (math "$current_time - $__last_sound_trigger_time") -gt 3000
        play_sound "nope"
        set -g __last_sound_trigger_time $current_time
    end
    cd ..
end

# backrooms (cd ../.. with timer guard)
function backrooms --description "Go deeper into directories (burning-memory vibe)"
    set -l current_time (date +%s%N | string sub -l 13)
    if not set -q __last_sound_trigger_time
        set -g __last_sound_trigger_time $current_time
    end
    if test (math "$current_time - $__last_sound_trigger_time") -gt 3000
        play_sound "burning-memory"
        set -g __last_sound_trigger_time $current_time
    end
    cd ../..
end

# dox-em (list all with expect wrapper)
function dox-em --description "Expose everything - list all files including dotfiles"
    set -l current_time (date +%s%N | string sub -l 13)
    if not set -q __last_sound_trigger_time
        set -g __last_sound_trigger_time $current_time
    end
    if test (math "$current_time - $__last_sound_trigger_time") -gt 3000
        play_sound "allbase"
        set -g __last_sound_trigger_time $current_time
    end
    with-sounds eza -a --color=always --group-directories-first --icons $argv
end

# receipts (history with timer guard)
function receipts --description "Show the receipts - command history with timestamps"
    set -l current_time (date +%s%N | string sub -l 13)
    if not set -q __last_sound_trigger_time
        set -g __last_sound_trigger_time $current_time
    end
    if test (math "$current_time - $__last_sound_trigger_time") -gt 3000
        play_sound "credit-card-slam"
        set -g __last_sound_trigger_time $current_time
    end
    builtin history --show-time="%F %T " $argv
end

## 📝 Reading & Editing Functions

# yap (cat/bat with expect wrapper and enhanced visibility)
function yap --description "File is yapping (talking) - display with sounds"
    set -l current_time (date +%s%N | string sub -l 13)
    if not set -q __last_sound_trigger_time
        set -g __last_sound_trigger_time $current_time
    end
    if test (math "$current_time - $__last_sound_trigger_time") -gt 3000
        # Check if hamster-dance is already playing
        if not pgrep -f "hamster-dance.mp3" >/dev/null 2>&1
            play_sound "hamster-dance"
        end
        set -g __last_sound_trigger_time $current_time
    end
    with-sounds bat \
        --style header,grid,snip,changes \
        --color always \
        --theme Monokai\ Extended \
        $argv
end

# sus (grep with expect wrapper)
function sus --description "Search for something sus"
    set -l current_time (date +%s%N | string sub -l 13)
    if not set -q __last_sound_trigger_time
        set -g __last_sound_trigger_time $current_time
    end
    if test (math "$current_time - $__last_sound_trigger_time") -gt 3000
        play_sound "millionaire-suspense"
        set -g __last_sound_trigger_time $current_time
    end
    with-sounds ugrep --color=auto $argv
end

# dial-up (journalctl with expect wrapper)
function dial-up --description "Show system errors (AOL dial-up vibe)"
    set -l current_time (date +%s%N | string sub -l 13)
    if not set -q __last_sound_trigger_time
        set -g __last_sound_trigger_time $current_time
    end
    if test (math "$current_time - $__last_sound_trigger_time") -gt 3000
        play_sound "aol-dial"
        set -g __last_sound_trigger_time $current_time
    end
    with-sounds journalctl -p 3 -xb $argv
end

## 💾 System & Maintenance Functions

# maid-outfit (cleanup with sound effect and timer guard)
function maid-outfit --description "Put on the maid outfit and clean up orphaned packages"
    set -l current_time (date +%s%N | string sub -l 13)
    if not set -q __last_sound_trigger_time
        set -g __last_sound_trigger_time $current_time
    end
    if test (math "$current_time - $__last_sound_trigger_time") -gt 3000
        play_sound "maid-outfit"
        set -g __last_sound_trigger_time $current_time
    end
    echo "🧹 *adjusts cat ears* Cleaning up orphaned packages..."
    while pacman -Qdtq
        sudo pacman -R (pacman -Qdtq)
    end
    echo "✨ All clean!"
end

# wumbo (expac big packages with sound and expect wrapper)
function wumbo --description "M for Mini? No, packages need to be WUMBO sized!"
    set -l current_time (date +%s%N | string sub -l 13)
    if not set -q __last_sound_trigger_time
        set -g __last_sound_trigger_time $current_time
    end
    if test (math "$current_time - $__last_sound_trigger_time") -gt 3000
        play_sound "w-for-wumbo"
        set -g __last_sound_trigger_time $current_time
    end
    with-sounds expac -H M "%m\t%n" | sort -h | nl $argv
end

# yoink (wget with sound and expect wrapper)
function yoink --description "Grab files from the internet"
    set -l current_time (date +%s%N | string sub -l 13)
    if not set -q __last_sound_trigger_time
        set -g __last_sound_trigger_time $current_time
    end
    if test (math "$current_time - $__last_sound_trigger_time") -gt 3000
        play_sound "yoink"
        set -g __last_sound_trigger_time $current_time
    end
    with-sounds wget -c $argv
end

## 🎮 System Info Functions

# numba-nine (Memory + top processes)
function numba-nine --description "All you had to do was follow the damn train, CJ!"
    set -l current_time (date +%s%N | string sub -l 13)
    if not set -q __last_sound_trigger_time
        set -g __last_sound_trigger_time $current_time
    end
    if test (math "$current_time - $__last_sound_trigger_time") -gt 3000
        play_sound "big-smoke-order" &
        set -g __last_sound_trigger_time $current_time
    end
    htop
    free -h
end

# do-a-barrel (System errors barrel roll)
function do-a-barrel --description "Do a barrel roll with your errors"
    set -l current_time (date +%s%N | string sub -l 13)
    if not set -q __last_sound_trigger_time
        set -g __last_sound_trigger_time $current_time
    end
    if test (math "$current_time - $__last_sound_trigger_time") -gt 3000
        play_sound "do-a-barrel" &
        set -g __last_sound_trigger_time $current_time
    end
    journalctl -p 3 | less
end

# this-is-sparta (Largest disk hogs)
function this-is-sparta --description "THIS! IS! SPARTA! (disk space edition)"
    set -l current_time (date +%s%N | string sub -l 13)
    if not set -q __last_sound_trigger_time
        set -g __last_sound_trigger_time $current_time
    end
    if test (math "$current_time - $__last_sound_trigger_time") -gt 3000
        play_sound "spartaa" &
        set -g __last_sound_trigger_time $current_time
    end
    du -sh * | sort -hr | head -15
end

# let-me-do-it-4-u (Top CPU abusers)
function let-me-do-it-4-u --description "Let me do it for you - CPU hogs edition"
    set -l current_time (date +%s%N | string sub -l 13)
    if not set -q __last_sound_trigger_time
        set -g __last_sound_trigger_time $current_time
    end
    if test (math "$current_time - $__last_sound_trigger_time") -gt 3000
        play_sound "let-me-do-it-for-you" &
        set -g __last_sound_trigger_time $current_time
    end
    top -o %CPU
end

# trololo (Weather forecast)
function trololo --description "I'm trolling you - weather edition"
    set -l current_time (date +%s%N | string sub -l 13)
    if not set -q __last_sound_trigger_time
        set -g __last_sound_trigger_time $current_time
    end
    if test (math "$current_time - $__last_sound_trigger_time") -gt 3000
        play_sound "trololo" &
        set -g __last_sound_trigger_time $current_time
    end
    curl -s wttr.in/TheValkyriesLocation #Change this placeholder
end

# forever-alone (Process family tree)
function forever-alone --description "Process family tree - all processes are alone together"
    set -l current_time (date +%s%N | string sub -l 13)
    if not set -q __last_sound_trigger_time
        set -g __last_sound_trigger_time $current_time
    end
    if test (math "$current_time - $__last_sound_trigger_time") -gt 3000
        play_sound "forever-alone" &
        set -g __last_sound_trigger_time $current_time
    end
    pstree -p | less
end

# vitas (Rainbow system info)
function vitas --description "7th Element - your system info in rainbow"
    set -l current_time (date +%s%N | string sub -l 13)
    if not set -q __last_sound_trigger_time
        set -g __last_sound_trigger_time $current_time
    end
    if test (math "$current_time - $__last_sound_trigger_time") -gt 3000
        play_sound "vitas-7th-element" &
        set -g __last_sound_trigger_time $current_time
    end
    hyfetch
end

## 🌐 Network & Mirrors Functions

# who-dis (ip with sound and expect wrapper)
function who-dis --description "Check your identity - New phone who dis?"
    set -l current_time (date +%s%N | string sub -l 13)
    if not set -q __last_sound_trigger_time
        set -g __last_sound_trigger_time $current_time
    end
    if test (math "$current_time - $__last_sound_trigger_time") -gt 3000
        play_sound "new-phone-who-dis"
        set -g __last_sound_trigger_time $current_time
    end
    with-sounds ip -color $argv
end

## 📦 Package Management Functions

# dript (flatpak with sound wrapper and expect wrapper)
function dript --description "Fast, furious, painless installs"
    set -l current_time (date +%s%N | string sub -l 13)
    if not set -q __last_sound_trigger_time
        set -g __last_sound_trigger_time $current_time
    end
    if test (math "$current_time - $__last_sound_trigger_time") -gt 3000
        play_sound "tokyo-dript"
        set -g __last_sound_trigger_time $current_time
    end
    if test -n $musiclooppid
        kill $musiclooppid 2>/dev/null
        set -g musiclooppid
    end
    start_music_loop "tokyo-dript"
    trap stop_music_loop EXIT INT TERM
    with-sounds flatpak $argv
    set dript_status $status
    stop_music_loop
    trap - EXIT INT TERM
    return $dript_status
end

## 🛡️ Noob Helper Functions

# wrong-numba (apt redirect with sound and timer guard)
function wrong-numba --description "PSYCH! You're on Arch, not Debian"
    set -l current_time (date +%s%N | string sub -l 13)
    if not set -q __last_sound_trigger_time
        set -g __last_sound_trigger_time $current_time
    end
    if test (math "$current_time - $__last_sound_trigger_time") -gt 3000
        play_sound "wrong-numba"
        set -g __last_sound_trigger_time $current_time
    end
    echo "🤡 PSYCH! You're on Arch Linux, not Debian/Ubuntu!"
    echo "📚 Here's the Arch way..."
    sleep 3
    MANPAGER='bat --style header,grid,snip,changes --color always --theme Dracula' man pacman
end

#based update with gambling meme sounds (volume-aware via play_sound)
function lets_go_gambling
    play_sound "lets-go-gambling"
    echo "Let's go gambling! 🎰~"
    echo "Updating packages... wish us luck!"

    # Start looping earthbound music while updating
    start_music_loop "earthbound-what-battle-moment"
    trap "stop_music_loop" EXIT INT TERM

    # Run updates and capture exit status
    # Uses native flags --noconfirm and -y instead of pipe to fix "n" issue
    sudo pacman -Syu --noconfirm
    set pacman_status $status

    yay -Syu --noconfirm
    set yay_status $status

    # Run flatpak, capture output to temp file while showing it
    # We use a temp file to count occurrences later
    set flatpak_log "/tmp/valkyrie_flatpak.log"
    # We must capture pipe status to know if flatpak failed or tee failed
    flatpak update -y | tee $flatpak_log
    set pipe_status $pipestatus
    set flatpak_status $pipe_status[1] # Exit code of flatpak

    # Stop music loop (so we can hear the error counts clearly)
    stop_music_loop
    trap - EXIT INT TERM

    # Count "end-of-life" occurrences
    if test -f $flatpak_log
        set eol_count (grep -c "end-of-life" $flatpak_log)
        if test $eol_count -gt 0
            echo "Oof! $eol_count End-of-Life warnings detected! 🎲"
            for i in (seq $eol_count)
                play_sound "aw-dang-it"
                sleep 0.5
            end
        end
        rm -f $flatpak_log
    end

    # Check if ANY command failed
    if test $pacman_status -ne 0 -o $yay_status -ne 0 -o $flatpak_status -ne 0
        echo "Aw dang it! 😭"
        play_sound "aw-dang-it"
        return 1
    end

    # Success!
    echo "Update complete! We won! 🎰"
    play_sound "lets-go-gambling-win"
end

## Exit Handler
function on_terminal_exit --on-event fish_exit
    # Only play if interactive to avoid sounds on background scripts
    # And check the flag to ensure touch-grass doesn't play twice
    if status --is-interactive
        if test "$_touch_grass_active" != "1"
            play_sound "metal-pipe-falling"
            sleep 0.1
        end
    end
end
