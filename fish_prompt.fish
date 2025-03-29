function fish_prompt
    set last_status $status
    set color_normal (set_color normal)
    set color_path (set_color normal)
    set color_path_basename (set_color white)
    set color_path_highlight (set_color cyan)
    set prompt_char '$'

    if test $last_status != 0
        set prompt_char '!'
    end

    type -q git
    and set real_vcs_root (git --no-optional-locks rev-parse --show-toplevel 2>/dev/null; or jj root 2>/dev/null)
    and begin
        set color_path (set_color (string replace -r '(-o|--bold)' '' -- "$fish_color_command" | string trim))
        set color_path_basename (set_color $fish_color_command -o)
        set color_path_highlight (set_color $fish_color_param -o)
        set relative_vcs_root (path normalize "$PWD/"(realpath --relative-to=(pwd -P) "$real_vcs_root"))
        if test (realpath $relative_vcs_root) = "$real_vcs_root"
            set vcs_root $relative_vcs_root
        end
        while not set -q vcs_root
            set -q logical_parent
            or set logical_parent (dirname $PWD)
            set real_sym_parent (realpath $logical_parent)
            if test $real_sym_parent = "$real_vcs_root"
                set vcs_root $real_sym_parent
            else if not string match -q "$real_vcs_root*" $real_sym_parent
                break
            else if test logical_parent = /
                break
            end
            set logical_parent (dirname $logical_parent)
        end
    end

    if test $PWD = ~
        test $last_status = 0 && set prompt_char "~"
        if not set -q vcs_root
            set prompt "$color_path_highlight$prompt_char"
        end
    else if test $PWD = /
        test $last_status = 0 && set prompt_char /
        set prompt "$color_path_highlight$prompt_char"
    end

    if not set -q prompt
        set glyph " $prompt_char"
        set full_paths (string split / $PWD)
        set paths (string replace -r '^(\.?.).*$' '$1' $full_paths)

        set paths[-1] $color_path_basename$full_paths[-1]

        if test "$real_vcs_root" = /
            set prefix "$color_path_highlight/$color_normal"
            set paths $paths[2..-1]
        else if test "$real_vcs_root" = ~
            set prefix "$color_path_highlight~$color_normal"
            set skip (math 1 + (count (string split / ~)))
            set paths '' $paths[$skip..-1]
        else if set -q vcs_root
            set vcs_root_idx (count (string split / $vcs_root))
            set vcs_basename $color_path_highlight$full_paths[$vcs_root_idx]$color_normal$color_path
            set paths[$vcs_root_idx] $vcs_basename
        end
        set short_home (string replace -ar '(\.?[^/])[^/]*' '$1' $HOME)
        set prompt "$prefix$color_path"(string join / $paths | string replace -r ^$short_home \~)
    end

    if set -q SSH_CLIENT
        set host '['(hostname -s)'] '
    end

    if test (id -u $USER) = 0
        set root (set_color $fish_color_error)'# '
    end

    set -q vcs_root
    and set vcs (fish_vcs_prompt)
    and set glyph $color_normal

    printf " $color_normal$host$root$color_normal$prompt$color_normal$vcs$glyph "
end
