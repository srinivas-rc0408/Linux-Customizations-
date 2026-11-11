# PATH
set -gx PATH /home/superior/.local/bin /usr/local/bin /usr/bin /bin /usr/local/sbin /usr/bin/site_perl /usr/bin/vendor_perl /usr/bin/core_perl

if status is-interactive

    function launcher-add
        mkdir -p ~/Pictures/launcher
        for f in $argv
            if test -f "$f"
                set out ~/Pictures/launcher/(date +%s%N).jpg
                magick "$f" -resize "660x1000^" -gravity center -extent 660x1000 -quality 92 $out
                echo "✅ Added: "(basename "$f")
            else
                echo "❌ Not found: $f"
            end
        end
    end

    function launcher-list
        ls ~/Pictures/launcher
        echo "Total: "(count ~/Pictures/launcher/*.jpg)" images"
    end

    function launcher-clear
        rm -f ~/Pictures/launcher/*.jpg
        echo "🗑 Slideshow cleared"
    end
    function ram-hogs
        echo "🧠 Top 10 memory consumers:"
        ps aux --sort=-%mem | head -11 | awk '{printf "%-8s %5s%%  %s\n", $1, $4, $11}'
    end
    function setcursor
        sed -i "s|xcursor-theme \".*\"|xcursor-theme \"$argv[1]\"|" ~/.config/niri/config.kdl
        gsettings set org.gnome.desktop.interface cursor-theme $argv[1]
        echo "✅ Cursor set to $argv[1] — log out and back in to apply"
    end

    function turbo
        echo "🚀 TURBO mode — max performance (charger required)..."
        if not grep -q 1 /sys/class/power_supply/AC*/online
            echo "⚠  Warning: charger not connected — turbo may drain battery fast or throttle"
        end
        sudo cpupower frequency-set -g performance >/dev/null
        asusctl profile set Performance >/dev/null 2>&1
        sudo supergfxctl --mode Hybrid >/dev/null
        echo "✅ TURBO active — CPU: performance, ASUS: Performance, Display: 144Hz locked"
    end

    function perf
        echo "⚡ Performance mode..."
        sudo cpupower frequency-set -g performance >/dev/null
        asusctl profile set Balanced >/dev/null 2>&1
        echo "✅ Performance mode active — CPU: performance, ASUS: Balanced, Display: 144Hz locked"
    end

    function battery-saver
        echo "🔋 Battery Saver mode — max battery life..."
        sudo cpupower frequency-set -g powersave >/dev/null
        asusctl profile set Quiet >/dev/null 2>&1
        echo "✅ Battery Saver active — CPU: powersave, ASUS: Quiet"
    end

    function clean++
        echo "🧹 Cleaning system..."
        sudo sh -c 'rm -rf /var/cache/pacman/pkg/download-* 2>/dev/null; true'
        sudo pacman -Sc --noconfirm
        yay -Sc --noconfirm
        sudo journalctl --vacuum-time=7d
        rm -rf ~/.cache/thumbnails
        sudo pacman -Qtdq | sudo pacman -Rns --noconfirm - 2>/dev/null
        sudo fstrim -v / >/dev/null
        sudo fstrim -v /home >/dev/null
        echo "✅ System cleaned, cache cleared, orphans removed, SSD trimmed"
    end

    function success
        echo "🔄 Updating system..."
        sudo pacman -Syu --noconfirm
        yay -Syu --noconfirm
        sudo sysctl -w vm.swappiness=10 >/dev/null
        sudo pacman -Qtdq | sudo pacman -Rns --noconfirm - 2>/dev/null
        echo "✅ System fully updated and optimized"
    end

    function status-check
        echo "📊 System Status"
        echo "─────────────────"
        echo "Disk /: "(df -h / | tail -1 | awk '{print $5" used, "$4" free"}')
        echo "Disk /home: "(df -h /home | tail -1 | awk '{print $5" used, "$4" free"}')
        echo "RAM: "(free -h | awk '/Mem/{print $3" used / "$2" total"}')
        echo "CPU Governor: "(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor)
        echo "GPU Mode: "(supergfxctl --status)
        echo "Failed services: "(systemctl --failed --no-legend | wc -l)
        echo "ASUS Profile: "(asusctl profile get 2>/dev/null | grep "Active" | cut -d: -f2)
        echo "─────────────────"
    end

    function prime-run
        command prime-run $argv
    end

    function comb
        ollama run comb-llm $argv
    end

    # fastfetch only in real interactive terminals, never for `fish -c` launches
    if not set -q S10_NO_FETCH
        fetch
    end

    abbr -a ls 'eza --icons --group-directories-first'
    abbr -a ll 'eza -la --icons --git --group-directories-first'
    abbr -a lt 'eza --tree --level=2 --icons'
    abbr -a cat 'bat --style=plain --paging=never'

    # cached shell inits: generated once, sourced instantly (no 3 subprocesses per shell)
    set -l c ~/.cache/fish-init.fish
    if not test -s $c; or test (command -v starship) -nt $c
        begin
            starship init fish --print-full-init
            zoxide init fish
            fzf --fish
        end > $c 2>/dev/null
    end
    source $c
end

alias vpn-on="warp-cli connect"
alias vpn-off="warp-cli disconnect"
alias vpn-status="warp-cli status"

# opencode
fish_add_path /home/superior/.opencode/bin

# ollama
set -x OLLAMA_MODELS /home/superior/.ollama/models

# bun
set --export BUN_INSTALL "$HOME/.bun"
set --export PATH $BUN_INSTALL/bin $PATH
