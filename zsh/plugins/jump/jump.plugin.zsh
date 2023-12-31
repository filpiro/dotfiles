# easy jump https://threkk.medium.com/how-to-use-bookmarks-in-bash-zsh-6b8074e40774

if [ -d "$HOME/.bookmarks" ]; then
    export CDPATH=".:$HOME/.bookmarks:/"
    alias goto="cd -P"
    alias z=goto
	alias bookmark="$HOME/.bookmarks && lt"
fi

addbookmark-fn(){
	local CURRENTPATH=$(pwd)
	cd $HOME/.bookmarks
	ln -s $CURRENTPATH $1
	echo "Bookmark $1 added"
	cd $CURRENTPATH
}

# alias addbookmark="addbookmark-fn"
alias addbm="addbookmark-fn"