function fetch
    # logo needs ~110 columns (logo + host/cpu lines); below that show info only
    if test $COLUMNS -lt 110
        fastfetch --logo none
    else
        fastfetch --logo ~/.config/fastfetch/s10.txt --logo-type file --logo-color-1 default \
                        --logo-padding-top 3 --logo-padding-left 3 --logo-padding-right 6
    end
    set -g __fetch_fresh 1
end

# While the terminal is fresh (no command run yet), redraw on every resize so the
# output always fits — niri narrows earlier windows when a new one opens.
function __fetch_on_resize --on-signal WINCH
    set -q __fetch_fresh; or return
    set -q __fetch_pending; and return
    set -g __fetch_pending 1
    sleep 0.08                      # let the resize settle (columns stop changing)
    set -e __fetch_pending
    clear
    fetch
    commandline -f repaint
end

function __fetch_done --on-event fish_preexec
    set -e __fetch_fresh
end
