# Git Flow
alias fw="git flow"
alias fwfs="git flow feature start"
alias fwfe="git flow feature finish"
alias fwrs="git flow release start"
alias fwre="git flow release finish"

function git-flow-push-fn(){
    git push --all
    git push origin --tags
}
alias fwpush="git-flow-push-fn"