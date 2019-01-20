function fish_right_prompt
    set -l status_code $status

    set -l color_normal (set_color normal)
    set -l color_error (set_color $fish_color_error)
    set -l color "$color_normal"

    if test "$status_code" != 0
        echo -n "$color_error($status_code)$color_normal "
    end
end
