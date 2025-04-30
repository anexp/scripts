#!/bin/sh

case "$XDG_SESSION_TYPE" in
"x11")
    clipboard_content=$(xclip -selection clipboard -o 2>/dev/null)

    if [ -z "$clipboard_content" ]; then
        # printf "Empty"
        printf "X11"
    else
        # printf "Full"
        printf "X11: Click"
    fi
    ;;
"wayland")
    printf "Wayland: "
    ;;
"*")
    printf "Error: Neither X11 nor Wayland"
    ;;
esac
