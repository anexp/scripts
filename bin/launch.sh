#!/bin/sh

show_help(){

	cat << EOF
launch.sh

Choose one of the available commands:
    desktop
    terminal
    browsers
    tts
    filemanager
    bookmarks
    bookmarks-add
    lockscreen
    command-palette
    password-manager
    vm-android
    help | --help | -h

EOF


}


if [ $# -eq 0 ]; then
	show_help
	exit
fi


if [ -f "$HOME/.dotconfig/shell/shell.d/00-func.sh" ]; then
    . "$HOME/.dotconfig/shell/shell.d/00-func.sh"
fi

if [ -f "$HOME/.dotconfig/shell/shell.d/env.sh" ]; then
    . "$HOME/.dotconfig/shell/shell.d/env.sh"
fi

prepend_path "/nix/var/nix/profiles/default/bin"
prepend_path "$HOME/.nix-profile/bin"
prepend_env_var "XDG_DATA_DIRS" "/nix/var/nix/profiles/default/share"
prepend_env_var "XDG_DATA_DIRS" "$HOME/.nix-profile/share"

if [ -d "/usr/share" ] ; then
    prepend_env_var "XDG_DATA_DIRS" '/usr/share'
fi

if [ -d "/usr/local/share" ] ; then
    prepend_env_var "XDG_DATA_DIRS" '/usr/local/share'
fi

if [ -d "/var/lib/flatpak/exports/share" ] ; then
    prepend_env_var "XDG_DATA_DIRS" '/var/lib/flatpak/exports/share'
fi

if [ -d "${HOME}/.local/share/flatpak/exports/share" ] ; then
    prepend_env_var "XDG_DATA_DIRS" "${HOME}/.local/share/flatpak/exports/share"
fi

if [ -d "$HOME/.local/share" ] ; then
    prepend_env_var "XDG_DATA_DIRS" "$HOME/.local/share"
fi

launch_desktop() {
	export QT_QPA_PLATFORMTHEME=qt5ct
	# export QT_STYLE_OVERRIDE=kvantum

	rofi -show drun
}


launch_appimage() {

	app=`/bin/ls ~/applications/appimages/ | rofi -theme Arc-Dark -dmenu -i -p "AppImage "` && ~/applications/appimages/$app
}


launch_flatpak() {


	if [ -f ~/.config/qtile/lists/flatpak_apps.txt ]; then
	    app=`cat ~/.config/qtile/lists/flatpak_apps.txt | rofi -dmenu -i -p "Flatpak "` && flatpak run "$app"
	else
	    app=`flatpak list --columns=application | rofi -dmenu -i -p "Flatpak "` && flatpak run "$app"
	fi

}


launch_terminal() {

	alacritty &

}



launch_filemanager() {

	nautilus &

}

launch_bookmarks(){

    "$HOME/Documents/scripts/bin/bookmarks.sh" "$@" &

}


launch_browsers() {

    pkill rofi
    choice_list="
        librewolf-flatpak
        brave-flatpak
        ugc-flatpak
        vivaldi-flatpak
        librewolf-flatpak-private
        chromium-flatpak
        brave-command
        librewolf-flatpak-surfer
        librewolf-flatpak-local-dev
        librewolf-flatpak-profile-manager
    "
    choice_list_actual=""
    for choice in ${choice_list}; do
        # printf "%s" "$choice"
        choice_list_actual="$(printf "%s\n%s" "$choice_list_actual" "$choice")"
    done

    choice_list_actual_trimmed="${choice_list_actual#"${choice_list_actual%%[![:space:]]*}"}"

    choice=$(printf "%s" "$choice_list_actual_trimmed" | rofi -dmenu -p "Browsers")



	case "${choice}" in
		(librewolf-flatpak)
            flatpak run io.gitlab.librewolf-community &
	        # librewolf &
			;;
		(librewolf-flatpak-private)
            flatpak run  io.gitlab.librewolf-community --private-window &
			;;
        (librewolf-flatpak-profile-manager)
            flatpak run  io.gitlab.librewolf-community --ProfileManager &
            ;;
        (librewolf-flatpak-local-dev)
            flatpak run  io.gitlab.librewolf-community -P local_dev &
            ;;
        (librewolf-flatpak-surfer)
            flatpak run  io.gitlab.librewolf-community -P surfer &
            ;;
        (brave-command)
            brave &
            ;;
		(brave-flatpak)
	        # chromium &
	        # /usr/bin/flatpak run --branch=stable --arch=x86_64 --command=/app/bin/chromium --file-forwarding com.github.Eloston.UngoogledChromium @@u %U @@   &
            # brave-browser-stable --new-window &
            flatpak run com.brave.Browser --new-window &
			;;
		(ugc-flatpak)
            flatpak run io.github.ungoogled_software.ungoogled_chromium &
            # flatpak run com.github.Eloston.UngoogledChromium &
			;;
        (ugc-dbox1)
            distrobox-enter -n dbox1 -- "/opt/ungoogled-software/ungoogled-chromium/chrome" &
            ;;
		(sub-brave)
            distrobox-enter -n sub -- brave-browser &
			;;
        (chromium-flatpak)
            flatpak run org.chromium.Chromium &
            ;;
        (vivaldi-flatpak)
            flatpak run com.vivaldi.Vivaldi &
            ;;
		(*)
			printf >&2 "Error: invalid browser\n"
			exit 1
			;;

	esac


}

choose_screenlayout() {
    screen_layout_dir="$HOME/.screenlayout"
    pkill rofi
    choice=$(/bin/ls "${screen_layout_dir}" | rofi -dmenu -p "Screenlayout")
    printf "Running %s \n" "${choice}"
    "${screen_layout_dir}/${choice}"

}

kill_flatpak_app() {
    app_id="$(flatpak ps --columns=app | rofi -dmenu -p "Kill Flatpak")"
    printf "Flatpak App ID selected : %s\n" "$app_id"
    if [ -n "$app_id" ] ; then
        flatpak kill "$app_id"
    else
        printf "No app id selected\n"
    fi
}

qr_to_clipboard() {
    flameshot gui -r | zbarimg -1q --raw - | xclip -selection clipboard
}

launch_command_palette() {

    pkill rofi
    choice_list="
        window
        clear-clipboard
        kill-flatpak
	bookmark-add
        brightness-controller
        screenshot
        screenshot-delay
        pycharm-community
        intellij-idea-community
        eclipse
        android-studio
        texstudio-nix
        qr-to-clipboard
        argos-translate-gui
        gpt4all
        packettracer
        lockscreen
        screen-layout
    "
    choice_list_actual=""
    for choice in ${choice_list}; do
        # printf "%s" "$choice"
        choice_list_actual="$(printf "%s\n%s" "$choice_list_actual" "$choice")"
    done

    choice_list_actual_trimmed="${choice_list_actual#"${choice_list_actual%%[![:space:]]*}"}"

    choice=$(printf "%s" "$choice_list_actual_trimmed" | rofi -dmenu -p "Command Palette")


	case "${choice}" in
        (window)
            pkill rofi
            rofi -show window &
            ;;
        (screenshot)
            flameshot launcher &
            ;;
        (screenshot-delay)
            ( sleep 5 && flameshot launcher ) &
            ;;
        (brightness-controller)
            "$HOME/.local/bin/brightness-controller" &
            ;;
        (pycharm-community)
            "/opt/jetbrains/pycharm-community/bin/pycharm.sh" &
            ;;
        (intellij-idea-community)
            /opt/jetbrains/idea-IC/bin/idea.sh &
            ;;
        (eclipse)
            /opt/eclipse/eclipse &
            ;;
        (android-studio)
            devenv_android_enable
            /opt/android-studio/bin/studio &
            ;;
        (texstudio-nix)
            nix-shell -p texstudio texliveFull --run "texstudio" &
            ;;
        (gpt4all)
            distrobox-enter -n dbox2 -- "$HOME/distroboxes/dbox2/gpt4all/bin/chat" &
            ;;
        (argos-translate-gui)
            . "$HOME/apps/argostranslate/venv/bin/activate"
            python "$HOME/apps/argostranslate/main.py" &
            ;;
        (packettracer)
            distrobox-enter -n pt -- '/opt/pt/packettracer' &
            ;;
        (screen-layout)
            choose_screenlayout
            ;;
        (lockscreen)
            launch_lockscreen &
            ;;
        (clear-clipboard)
            "$HOME/Documents/scripts/bin/clear_clipboard.sh" &
            ;;
        (qr-to-clipboard)
            qr_to_clipboard &
            ;;
        (bookmark-add)
            launch_bookmarks add
            ;;
        (kill-flatpak)
            kill_flatpak_app
            ;;
		(*)
			printf >&2 "Error: invalid command\n"
			exit 1
			;;

	esac


}



launch_buku() {

    "$HOME/.local/bin/rofi-buku" "$@"
}

launch_password_manager() {

case "$XDG_SESSION_TYPE" in
	("x11")
		printf "In x11 session \n"
        rofi-pass $@
		;;
	("wayland")
		printf "In wayland session \n"
        ROFI_PASS_BACKEND=wtype ROFI_PASS_CLIPBOARD_BACKEND=wl-clipboard rofi-pass $@
		;;
	(*)
		printf "Neither x11 or wayland \n"
		;;
esac

}

launch_lockscreen() {

path_to_lockscreen_image="$HOME/.dotconfig-assets/current/lockscreen-bg.png"

case "$XDG_SESSION_TYPE" in
	("x11")
		printf "In x11 session \n"
        i3lock -n -e -f -t -i "$path_to_lockscreen_image"
		;;
	("wayland")
		printf "In wayland session \n"
        swaylock -n -e -f -t -c 312222
		;;
	(*)
		printf "Neither x11 or wayland \n"
		;;
esac

}


launch_vm_android() {

virsh --connect qemu:///system start android-x86-9.0
virt-manager --connect qemu:///system --show-domain-console android-x86-9.0
}

launch_tts() {

    "$HOME/Documents/scripts/bin/tts.sh" "$@"
}



main() {

	case "$1" in
		(desktop)
			shift
			launch_desktop "$@" &
			;;
		(terminal)
			shift
			launch_terminal "$@" &
			;;
		(browsers)
			shift
			launch_browsers "$@" &
			;;
		(tts)
			shift
			launch_tts "$@" &
			;;
		(command-palette)
			shift
			launch_command_palette "$@" &
			;;
		(filemanager)
			shift
			launch_filemanager "$@" &
			;;
		(bookmarks)
			shift
			launch_bookmarks "$@" &
			;;
		(buku)
			shift
			launch_buku "$@" &
			;;
		(lockscreen)
			shift
			launch_lockscreen "$@" &
			;;
		(password-manager)
			shift
			launch_password_manager "$@" &
			;;
		(vm-android)
			shift
			launch_vm_android "$@" &
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
