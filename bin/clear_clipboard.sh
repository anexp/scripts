#!/bin/sh


clear_clipboard() {

case "$XDG_SESSION_TYPE" in
	("x11")
		printf "In x11 session \n"
        # printf "" | xclip -sel clip
        xsel -bc &

        # current_clipboard_content="$(xclip -sel clip)"
        # notify-send "Cleared Clipboard - Current Clipboard Content ${current_clipboard_content}" &
		;;
	("wayland")
		printf "In wayland session \n"
        wl-copy --clear &
		;;
	(*)
		printf "Neither x11 or wayland \n"
		;;
esac

}


clear_clipboard &
