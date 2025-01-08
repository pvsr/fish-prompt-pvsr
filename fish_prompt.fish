function fish_prompt
    set last_status $status
    set color_white (set_color white)
    set color_yellow (set_color yellow)
    set color_command (set_color $fish_color_command)
    set color_red (set_color red)
    set color_normal (set_color $fish_color_normal)
    set color_vcs_basename (set_color cyan)
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
        set vcs_root (path normalize "$PWD/"(realpath --relative-to=(pwd -P) $vcs_root))
        set vcs_basename $color_normal$color_vcs_basename(basename $vcs_root)$color_normal
        if test $vcs_root != ~
            set vcs_root_abbr (string replace -r ^$HOME \~ $vcs_root)
        else
            set vcs_root_abbr $vcs_root
        end
        set vcs_basename_idx (count (string split / $vcs_root_abbr))

        set color_glyph $color_normal

        if test $vcs = git
            if not git diff --no-ext-diff --quiet --exit-code &>/dev/null
                set color_glyph $color_red
            else if not git diff --cached --no-ext-diff --quiet --exit-code &>/dev/null
                set color_glyph $color_green
            end
        end

        set glyph " $color_glyph$prompt_char$color_normal"
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
            set prompt "$color_command$prompt_char"
        end
    else if test $PWD = /
        test $last_status = 0 && set prompt_char /

        set prompt "$color_command$prompt_char"

        if set -q vcs_basename
            set prompt $color_vcs_basename$prompt
        end
    end

    if not set -q prompt
        if not set -q glyph
            set glyph " $prompt_char"
        end
        set paths (string split / $pwd | string replace --regex '^(\.?.).*$' '$1')

        set color_init $color_command

        if set -q vcs_basename_idx
            if test $vcs_basename_idx != 0
                set paths[$vcs_basename_idx] $vcs_basename
            end

            if test $vcs_basename_idx != (count $paths)
                set paths[-1] $color_normal$color_white(basename (pwd))
            end
        else
            set paths[-1] $color_normal$color_white(basename (pwd))
        end

        set prompt (string join / $paths)
        if test "$vcs_root" = /
            set prompt (string replace --regex '^/' "$color_vcs_basename/$color_normal" $prompt)
        end
    end

    if set -q SSH_CLIENT
        set host '['(hostname -s)'] '
    end

    set vcs (fish_vcs_prompt)

    printf " $color_normal$host$root$color_normal$prompt$color_normal$vcs$glyph "
end
