#!/bin/sh

case "$XDG_SESSION_TYPE" in
"x11")
    printf "X11: "
    clipboard_content=$(xclip -selection clipboard -o 2>/dev/null)

    if [ -z "$clipboard_content" ]; then
        printf "Empty"
    else
        printf "Full"
    fi
    ;;
"wayland")
    printf "Wayland: "
    ;;
"*")
    printf "Error: Neither X11 nor Wayland"
    ;;
esac
