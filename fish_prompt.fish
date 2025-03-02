function fish_prompt
    set last_status $status
    set color_white (set_color white)
    set color_normal (set_color normal)
    set color_path (set_color normal)
    set color_path_basename (set_color white)
    set color_path_highlight (set_color cyan)
    set prompt_char '$'

    if test $last_status != 0
        set prompt_char '!'
    end

    if type -q git && set vcs_root (git rev-parse --show-toplevel 2> /dev/null)
        set vcs git
    else if which hg >/dev/null 2>&1 && test -d .hg # FIXME only works at top level
        set vcs hg
        set vcs_root (hg root)
    end

    if set -q vcs
        set color_path (set_color brgreen)
        set color_path_basename (set_color brgreen -o)
        set color_path_highlight (set_color brmagenta -o)
        set relative_vcs_root (path normalize "$PWD/"(realpath --relative-to=(pwd -P) $vcs_root))
        if test (realpath $relative_vcs_root) = $vcs_root
            set vcs_root $relative_vcs_root
            set vcs_basename $color_path_highlight(basename $vcs_root)$color_normal$color_path
            if test $vcs_root = ~
                set vcs_root_abbr $vcs_root
            else if test $vcs_root = /
                set vcs_root_abbr ''
            else
                set vcs_root_abbr (string replace -r ^$HOME \~ $vcs_root)
            end
            set vcs_basename_idx (count (string split / $vcs_root_abbr))
        end
    end

    if test (id -u $USER) = 0
        set root (set_color red)
    end

    set pwd (string replace -r ^$HOME \~ $PWD)
    if test $PWD = ~
        test $last_status = 0 && set prompt_char "~"
        if set -q vcs_basename
            set pwd $PWD
        else
            set prompt "$color_path_highlight$prompt_char"
        end
    else if test $PWD = /
        test $last_status = 0 && set prompt_char /
        set prompt "$color_path_highlight$prompt_char"
    end

    if not set -q prompt
        set glyph " $prompt_char"
        set paths (string split / $pwd | string replace --regex '^(\.?.).*$' '$1')

        set paths[-1] $color_path_basename(basename (pwd))

        if set -q vcs_basename_idx; and test $vcs_basename_idx != 0
            set paths[$vcs_basename_idx] $vcs_basename
        end

        if test "$vcs_root" = /
            set prompt "$color_path_highlight/$color_path"(string join / $paths[2..-1])
        else
            set prompt $color_path(string join / $paths)
        end
    end
    if set -q SSH_CLIENT
        set host '['(hostname -s)'] '
    end

    set vcs (fish_vcs_prompt)
    and set glyph $color_normal

    printf " $color_normal$host$root$color_normal$prompt$color_normal$vcs$glyph "
end
