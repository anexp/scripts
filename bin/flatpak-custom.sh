#!/bin/sh

show_help(){

	cat << EOF
flatpak-custom.sh

Choose one of the available commands:
    add-flathub
    my-custom
    theme-copy
    theme-add
    theme-rm
    ls
    help | --help | -h

EOF


}


if [ $# -eq 0 ]; then
	show_help
	exit
fi

flatpak_add_flathub() {

    # flatpak remote-add --if-not-exists --user flathub https://dl.flathub.org/repo/flathub.flatpakrepo
	flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
}

flatpak_add_remotes() {

	flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
    flatpak remote-add --if-not-exists flathub-beta https://flathub.org/beta-repo/flathub-beta.flatpakrepo

}


theme_copy() {
	cp -ruv /usr/share/themes/* ~/.themes
	cp -ruv /usr/share/icons/* ~/.icons
}

theming_gtk() {

	mkdir -p ~/.themes
	mkdir -p ~/.icons
	cp -ruv /usr/share/themes/* ~/.themes
	cp -ruv /usr/share/icons/* ~/.icons
	flatpak override --user --filesystem=$HOME/.themes "$@"
	flatpak override --user --filesystem=$HOME/.icons "$@"

	flatpak override --user --env=GTK_THEME=Arc-Dark "$@"
	# flatpak override --user --env=GTK_THEME=Breeze-Dark "$@"
	# flatpak override --user --env=ICON_THEME=Adwaita-dark "$@"



}

theming_qt() {

	flatpak override --user --filesystem=xdg-config/Kvantum:ro "$@"
	# flatpak override --user --env=QT_STYLE_OVERRIDE=kvantum "$@"
	flatpak override --user --env=QT_STYLE_OVERRIDE=Adwaita-dark "$@"
}

theme_rm() {

	if [ $# -lt 1 ]; then
		printf "Please pass the name of atleast one app"
		exit
	fi
	# Some apps don't work on theming
	# GTK
	flatpak override --user --nofilesystem=$HOME/.themes "$@"
	flatpak override --user --nofilesystem=$HOME/.icons "$@"
	flatpak override --user --unset-env=GTK_THEME "$@"
	# QT
	flatpak override --user --nofilesystem=xdg-config/Kvantum "$@"
	flatpak override --user --unset-env=QT_STYLE_OVERRIDE "$@"


}


theme_add() {

	if [ $# -lt 1 ]; then
		printf "Please pass the name of atleast one app"
		exit
	fi

	theming_gtk "$@"
	theming_qt "$@"
}

flatpak_app_ls() {
	flatpak --user list --app --columns=application
}

my_custom_flatpak() {
    # flatpak override --user --nofilesystem=$HOME/my
    flatpak override --user --filesystem=$HOME/my/Now/WhatSie com.ktechpit.whatsie
}

main() {

	case "$1" in
		(add-flathub)
			shift
			flatpak_add_flathub "$@"
			;;
		(my-custom)
			shift
			my_custom_flatpak "$@"
			;;
        (theme-copy)
            shift
            theme_copy "$@"
            ;;
		(theme-add)
			shift
			 theme_add "$@"
			;;
		(theme-rm)
			shift
			 theme_rm "$@"
			;;
		(ls)
			shift
			 flatpak_app_ls "$@"
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
