function fish_prompt
    set status_copy $status
    set color_white (set_color white)
    set color_command (set_color $fish_color_command)
    set color_error (set_color $fish_color_error)
    set color_normal (set_color normal)
    set color_reset (set_color normal)
    set color_git_root (set_color cyan)

    # if test $status_copy != 0
    #     set color_white $color_error
    #     set color_normal $color_error
    #     if not git_is_repo
    #         set color_command $color_error$color_command
    #     end
    # end

    if git_is_repo
        # set git_root "$color_reset$color_git_root"(basename (git_repository_root))"$color_normal"
        # TODO problem: git_repository_root is the real path, $PWD uses a virtual path that reflects symlinks
        # TODO may be able to find root virtual PWD root by walking up the tree and checking if realpath == git_root
        # set git_root_idx (count (string split / (string replace ~ \~ (git_repository_root))))
        if git_is_dirty
            set glyph " $color_error\$"
        else if git_is_staged
            set glyph ' '(set_color green)"\$"
        else
            set glyph " $color_normal\$"
        end
        set ahead (git_ahead ' +' ' -' ' ±')
        set glyph "$color_reset$glyph$ahead$color_reset"
    end

    if test (id -u "$USER") = 0
        set root "$color_error#$color_normal "
    end

    set pwd (string replace ~ \~ $PWD)
    if test $PWD = ~
        # if set -q git_root
        #     set pwd $PWD
        # else
            set prompt "$color_command~$color_normal"
        # end
    else if test $PWD = /
        set prompt "$color_command/$color_normal"
        # if set -q git_root
        #     set prompt $color_git_root$prompt
        # end
    end

    if not set -q prompt
        if not set -q glyph
            set glyph ' $'
        end
        set paths (string split / $pwd | sed 's|\(\.\?.\{1,1\}\).*|\1|')

        set color_init $color_command

        # if set -q git_root_idx
        #     if test $git_root_idx = 0
        #         set color_init $color_git_root$color_init
        #     else
        #         set paths[$git_root_idx] $git_root
        #     end

        #     if test $git_root_idx != (count $paths)
        #         set paths[-1] $color_white(basename (pwd))$color_normal
        #     end
        # else
            set paths[-1] $color_white(basename (pwd))$color_normal
        # end

        set prompt (string join / $paths | sed "s|^.|$color_init&$color_normal|")
    end

    printf "$color_reset $root$color_normal$prompt$color_reset$glyph $color_reset"
end
