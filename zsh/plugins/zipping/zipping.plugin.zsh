#!/usr/bin/env zsh

function zp-fn() {
    local zip_name="${1:-theme_bkp}.zip"

    # Zip the files while the spinner is running
    zip -rq "$zip_name" . \
        -x "**/node_modules/*" \
        -x "node_modules/*" \
        -x ".budfiles/*" \
        -x ".git/*" \
        -x "*.DS_Store*" \
        -x "*.zip" \


  	echo -e "\r[\033[0;32m✓\033[0m] Zip completed!"
    echo "Find $zip_name in $(pwd)"
}


alias zp="zp-fn"