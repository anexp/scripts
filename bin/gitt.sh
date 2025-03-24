#!/bin/sh

show_help(){

	cat << EOF
gitt.sh

Choose one of the available commands:
    push
    pull
    change-email-all
    remote-add
    status
    help | --help | -h

EOF


}


if [ $# -eq 0 ]; then
	show_help
	exit
fi


git_sh_push() {
# may not work if the remote name has spaces

# Get the list of configured remotes
remotes=$(git remote)

# Loop through each remote and push to it
for remote in $remotes; do
	printf "Pushing to remote : %s \n" "$remote"
    git push "$remote" "$@"
done

}

git_sh_pull() {

# Get the list of configured remotes
remotes=$(git remote)

# Loop through each remote and push to it
for remote in $remotes; do
	printf "Pulling from remote : %s \n" "$remote"
    git pull "$remote" "$@"
done

}

git_sh_status() {
	git status
}


git_sh_change_committer_email_all() {

git filter-branch --env-filter '
CORRECT_NAME="$(git config --global user.name)"
CORRECT_EMAIL="$(git config --global user.email)"
export GIT_COMMITTER_NAME="$CORRECT_NAME"
export GIT_COMMITTER_EMAIL="$CORRECT_EMAIL"
export GIT_AUTHOR_NAME="$CORRECT_NAME"
export GIT_AUTHOR_EMAIL="$CORRECT_EMAIL"
' --tag-name-filter cat -- --branches --tags


}

git_sh_others1() {

	 # If you want to list all the files currently being tracked under the branch master, you could use this command:

	git ls-tree -r master --name-only

	# If you want a list of files that ever existed (i.e. including deleted files):

	git log --pretty=format: --name-only --diff-filter=A | sort - | sed '/^$/d'


}



main() {

	case "$1" in
		(push)
			shift
			git_sh_push "$@"
			;;
		(pull)
			shift
			git_sh_pull "$@"
			;;
		(remote-add)
			shift
			git_sh_remote_add "$@"
			;;
		(change-email-all)
			shift
			git_sh_change_committer_email_all "$@"
			;;
		(status)
			shift
			git_sh_status "$@"
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
