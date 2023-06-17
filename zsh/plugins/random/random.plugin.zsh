#!/usr/bin/env zsh

function copy-to-clipboard(){
	echo "$1 -> copied to clipboard.";

	if which xclip >/dev/null 2>&1; then
		echo $1 | xclip -selection clipboard
	
	elif which xsel >/dev/null 2>&1; then
		echo $1 | xsel -ib
	
	elif which pbcopy >/dev/null 2>&1; then
		echo $1 | pbcopy
	
	else
		echo "Clipboard utility not found. Please install 'pbcopy' (for macOS) or 'xsel' or 'xclip' (for Linux) to copy to the clipboard."
	fi
}

function rnd-fn() {
	local output="";
	for arg in "$@"; do
		if [[ "$arg" =~ ^- ]]; then
			case "$arg" in
				-p|--pass)
					output=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9!@#$%^&*?' | fold -w ${1:-32} | head -n 1)
					copy-to-clipboard $output
					return 1
					;;
			esac
		fi
	done
	output=$(cat /dev/urandom | tr -dc 'a-z' | fold -w ${1:-32} | head -n 1)
	copy-to-clipboard $output

}

alias getrandom="rnd-fn"
