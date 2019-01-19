function fish_right_prompt
    set -l status_copy $status
    set -l status_code $status_copy

    set -l color_normal (set_color normal)
    set -l color_error (set_color $fish_color_error)
    set -l color "$color_normal"

    switch "$status_copy"
        case 0 "$__mono_status_last"
            set status_code
    end

    set -g __mono_status_last $status_copy

    if test "$status_copy" -ne 0
        set color "$color_error"
    end

    if test ! -z "$status_code"
        echo -sn "$color($status_code)$color_normal "
    end

    echo -sn "$color$VIRTUAL_ENV$color_normal "
end
