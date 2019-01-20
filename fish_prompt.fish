function fish_prompt
    set status_copy $status
    set color_white (set_color white)
    set color_command (set_color $fish_color_command)
    set color_error (set_color $fish_color_error)
    set color_normal (set_color normal)
    set color_red (set_color red)
    set color_git_basename (set_color cyan)
    set default_glyph ' $'
    set error_glyph ' !'

    if test $status_copy != 0
        set default_glyph $error_glyph
    end

    if git_is_repo
        set -l git_root (git_repository_root)
        if not string match --entire $git_root $PWD > /dev/null
            # we need to reconcile the virtual PWD, which reflects symlinks, with the actual file
            set -l suffix (string match --regex $git_root $PWD)
            set git_root (string replace --regex "(.*)$suffix\$" '$1' $PWD)
        end

        set git_basename "$color_normal$color_git_basename"(basename $git_root)"$color_normal"
        set git_basename_idx (count (string split / (string replace ~ \~ $git_root)))
        if git_is_dirty
            set color_glyph "$color_red"
        else if git_is_staged
            set color_glyph (set_color green)
        else
            set color_glyph "$color_normal"
        end
        set ahead (git_ahead ' +' ' -' ' ±')
        set glyph "$color_glyph$default_glyph$ahead"
    end

    if test (id -u "$USER") = 0
        set root "$color_red# "
    end

    set pwd (string replace ~ \~ $PWD)
    if test $PWD = ~
        if set -q git_basename
            set pwd $PWD
        else
            set prompt "$color_command~"
        end
    else if test $PWD = /
        set prompt "$color_command/"
        if set -q git_basename
            set prompt "$color_git_basename$prompt"
        end
    end

    if not set -q prompt
        if not set -q glyph
            set glyph $default_glyph
        end
        set paths (string split / "$pwd" | sed 's|\(\.\?.\{1,1\}\).*|\1|')

        set color_init "$color_command"

        if set -q git_basename_idx
            if test "$git_basename_idx" = 0
                set color_init "$color_git_basename$color_init"
            else
                set paths["$git_basename_idx"] "$git_basename"
            end

            if test "$git_basename_idx" != (count "$paths")
                set paths[-1] $color_normal$color_white(basename (pwd))
            end
        else
            set paths[-1] $color_normal$color_white(basename (pwd))
        end

        set prompt (string join / $paths | sed "s|^.|$color_init&$color_normal|")
    end

    printf " $color_normal$root$color_normal$prompt$color_normal$glyph $color_normal"
end
