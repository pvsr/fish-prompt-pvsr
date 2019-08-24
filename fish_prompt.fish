function fish_prompt
    set last_status $status
    set color_white (set_color white)
    set color_command (set_color $fish_color_command)
    set color_error (set_color $fish_color_error)
    set color_normal (set_color $fish_color_normal)
    set color_vcs_basename (set_color cyan)
    set prompt_char '$'

    if test $last_status != 0
        set prompt_char '!'
    end

    if which git > /dev/null 2>&1 && git_is_repo && not test -d .git/annex
        set vcs git
        set vcs_root (git_repository_root)
        set vcs_branch (git_branch_name)
    else if which hg > /dev/null 2>&1 && test -d .hg
        set vcs hg
        set vcs_root (hg root)
        set vcs_branch (hg branch)
    end

    if set -q vcs
        if not string match --entire $vcs_root $PWD > /dev/null
            # we need to reconcile the virtual PWD, which reflects symlinks, with the actual path
            set -l suffix (string replace --regex $vcs_root '' (realpath $PWD))
            set vcs_root (string replace --regex "(.*)$suffix\$" '$1' $PWD)
        end

        set vcs_basename $color_normal$color_vcs_basename(basename $vcs_root)$color_normal
        set vcs_basename_idx (count (string split / (string replace ~ \~ $vcs_root)))

        set color_glyph $color_normal

        if test $vcs = 'git'
            if git_is_dirty
                set color_glyph $color_error
            else if git_is_staged
                set color_glyph (set_color green)
            end

            set ahead (git_ahead ' +' ' -' ' ±')
        end

        set vcs_branch ' ('(set_color yellow)"$vcs_branch$color_normal)"

        set glyph "$vcs_branch$color_glyph $prompt_char$ahead"

        # TODO could add more git info
    end

    if test (id -u $USER) = 0
        set root (set_color red)
    end

    set pwd (string replace ~ \~ $PWD)
    if test $PWD = ~
        if set -q vcs_basename
            set pwd $PWD
        else
            test $last_status = 0 && set prompt_char "~"
            set prompt "$color_command$prompt_char"
        end
    else if test $PWD = /
        test $last_status = 0 && set prompt_char "/"

        set prompt "$color_command$prompt_char"

        if set -q vcs_basename
            set prompt $color_vcs_basename$prompt
        end
    end

    if not set -q prompt
        if not set -q glyph
            set glyph $default_glyph
        end
        set paths (string split / $pwd | string replace --regex '^(\.?.).*$' '$1')

        set color_init $color_command

        if set -q vcs_basename_idx
            if test $vcs_basename_idx = 0
                set vcs_root
            else
                set paths[$vcs_basename_idx] $vcs_basename
            end

            if test $vcs_basename_idx != (count $paths)
                set paths[-1] $color_normal$color_white(basename (pwd))
            end
        else
            set paths[-1] $color_normal$color_white(basename (pwd))
        end

        set prompt (string join / $paths)
        if set -q vcs_root
            set prompt (string replace --regex '^/' "$color_vcs_basename/$color_normal" $prompt)
        end
    end

    if set -q SSH_CLIENT
        set host '['(hostname -s)'] '
    end

    printf " $color_normal$host$root$color_normal$prompt$color_normal$glyph $color_normal"
end
