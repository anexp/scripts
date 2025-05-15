#!/bin/sh


# no notifications by default
notification_flag=false

clear_clipboard() {

    case "$XDG_SESSION_TYPE" in
    "x11")
        printf "In x11 session \n"
        # printf "" | xclip -sel clip
        xsel -bc &

        # current_clipboard_content="$(xclip -sel clip)"
        if [ "$notification_flag" = "true" ]; then
            # notify-send -u low "Cleared Clipboard X11 CurValue=[${current_clipboard_content}]" &
            notify-send -u low "Cleared Clipboard X11" &
        fi
        ;;
    "wayland")
        printf "In wayland session \n"
        wl-copy --clear &
        if [ "$notification_flag" = "true" ]; then
            notify-send -u low "Cleared Clipboard Wayland" &
        fi
        ;;
    *)
        printf "Neither x11 or wayland session. Failed to clear clipboard.\n"
        ;;
    esac

}

main() {
    case "$1" in
    -notify)
        shift
        notification_flag=true
        ;;
    -no-notify)
        shift
        notification_flag=false
        ;;
    *)
        ;;
    esac

    clear_clipboard &
}

main "$@"
