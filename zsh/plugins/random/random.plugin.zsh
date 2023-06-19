#!/usr/bin/env zsh

function rnd-fn() {

	function copy-to-clipboard(){
		
		if which xclip >/dev/null 2>&1; then
			echo $1 | xclip -selection clipboard
		
		elif which xsel >/dev/null 2>&1; then
			echo $1 | xsel -ib
		
		elif which pbcopy >/dev/null 2>&1; then
			echo $1 | pbcopy
		
		else
			echo "Clipboard utility not found. Please install 'pbcopy' (for macOS) or 'xsel' or 'xclip' (for Linux) to copy to the clipboard."
			return 0

		fi
		CL='\033[0;35m'
		NC='\033[0m'
		printf "${CL}$1${NC} copied to clipboard.\n"
	}

	function get-rnd(){
		cat /dev/urandom | tr -dc ${2:-'a-zA-Z0-9!@#$%^&*?'} | fold -w ${1:-8} | head -n 1
	}

	local output="";
	for arg in "$@"; do
		if [[ "$arg" =~ ^- ]]; then
			case "$arg" in
				-p|--pass)
					output=$(get-rnd ${1:-8})
					copy-to-clipboard $output
					return 0
					;;
				-x|--prefix)
					output="_$(get-rnd 5 'a-z')"
					copy-to-clipboard $output
					return 0
					;;
			esac
		fi
	done
	output=$(get-rnd ${1:-8} 'a-z')
	copy-to-clipboard $output

}

alias rnd="rnd-fn"
