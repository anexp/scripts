#!/bin/sh

show_help(){

	cat << EOF
bookmarks.sh

Choose one of the available commands:
    type
    add
    help | --help | -h

EOF


}


if [ $# -eq 0 ]; then
	show_help
	exit
fi

bookmarks_dir="${HOME}/Documents/db"
bookmarks_file="${bookmarks_dir}/bookmarks.txt"


bookmarks_type() {

pkill rofi

# Rofi
current_bookmark="$(rofi -dmenu -i -p "Bookmarks " < "$bookmarks_file" )"
retval="$?"
current_bookmark="$(echo "$current_bookmark" | cut -d "|" -f 2)"
string="$current_bookmark"
trimmed="${string#"${string%%[![:space:]]*}"}"
trimmed="${trimmed%"${trimmed##*[![:space:]]}"}"
current_bookmark="$trimmed"

# the `#` operator removes the longest leading substring that matches the pattern, and the % operator removes the longest trailing substring that matches the pattern. The pattern ${string%%[![:space:]]*} matches any leading whitespace, and ${trimmed##*[![:space:]]} matches any trailing whitespace.

# By combining these operations, you can effectively trim the leading and trailing whitespace from your string.


# Check the value of XDG_SESSION

copy_to_clipboard=false

if [ "$retval" = "10" ] ; then
    copy_to_clipboard=true

fi


case "$XDG_SESSION_TYPE" in
	("x11")
		printf "In x11 session \n"
        if  [ "$copy_to_clipboard" = "true" ] ; then
            printf "%s" "${current_bookmark}" | xclip -sel clip
        else
		    xdotool type "${current_bookmark}"
        fi
		;;
	("wayland")
		printf "In wayland session \n"
        if [ "${copy_to_clipboard}" = "true" ] ; then
            printf "%s" "${current_bookmark}" | wl-copy
        else
		    wtype "${current_bookmark}"
        fi
		;;
	(*)
		printf "Neither x11 or wayland \n"
		;;
esac




}

bookmarks_add() {

current_clipboard_content=""
case "$XDG_SESSION_TYPE" in
	("x11")
        current_clipboard_content="$(xclip -o)"
		;;
	("wayland")
        current_clipboard_content="$(wl-paste)"
		;;
	(*)
		printf "Neither x11 or wayland \n"
		;;
esac

pkill rofi
bookmark_url=$(echo "${current_clipboard_content}" | rofi -dmenu -p "Url of Bookmark")
if [ -z "${bookmark_url}" ] ; then
        notify-send "Abort Add Bookmark : Empty Url"
        return
fi
pkill rofi
bookmark_name=$(rofi -dmenu -p "Name of Bookmark")
if [ -z "${bookmark_name}" ] ; then
        notify-send "Abort Add Bookmark : Empty Name"
        return
fi
pkill rofi
bookmark_comment=$(rofi -dmenu -p "Comment of Bookmark")
if [ -z "${bookmark_comment}" ] ; then
        notify-send "Abort Add Bookmark : Empty Comment"
        return
fi

new_bookmark_line="${bookmark_name} | ${bookmark_url} | ${bookmark_comment}"

if [ -n "${bookmark_name}" ]  && [ -n "${bookmark_url}" ] && [ -n "${bookmark_comment}" ] ; then
    echo "${new_bookmark_line}" >> "$bookmarks_file"
    notify-send "Adding bookmark : ${new_bookmark_line}"

    if [ -d "${bookmarks_dir}/.git" ] ; then
        git -C "${bookmarks_dir}" add --all
        git -C "${bookmarks_dir}" commit -m "Add Bookmark : ${bookmark_name}" -m "Bookmark Name : ${bookmark_name}"
        git -C "${bookmarks_dir}" push --all
    fi
else
    notify-send "Incomplete bookmark : ${new_bookmark_line}"
fi



}

main() {

	case "$1" in
		(type)
			shift
			bookmarks_type "$@"
			;;
		(add)
			shift
			bookmarks_add "$@"
			;;
		(help | --help | -h)
			show_help
			exit 0
			;;
		(*)
			printf >&2 "Error: invalid command\n"
			show_help
			exit 1
			;;

	esac


}

main "$@"
