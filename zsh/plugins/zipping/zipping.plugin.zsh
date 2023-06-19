#!/usr/bin/env zsh

function zp-fn() {
    local zip_name="${1:-theme_bkp}.zip"

	file_list=$(find \
		! -path "*/node_modules/*" \
		! -path "*/budfiles/*" \
		! -path "*.zip" \
		! -path "*.DS_Store*" \
		! -path "*/git/*" \
		| grep -v node_modules 
	)

	total_files=$(echo "$file_list" | wc -l)

	# Initialize the progress variables
    progress=1
    progress_bar_width=50

    # Zip the files while the spinner is running
    zip -r "$zip_name" .\
        -x "**/node_modules/*" \
        -x "node_modules/*" \
        -x ".budfiles/*" \
        -x ".git/*" \
        -x "*.DS_Store*" \
        -x "*.zip" \ | {
			while read -r line; do
				((progress++))

            # Calculate the progress percentage
            percentage=$((progress * 100 / total_files))

            # Calculate the width of the progress bar
            filled_width=$((progress * progress_bar_width / total_files))
            remaining_width=$((progress_bar_width - filled_width))

            # Print the progress bar
            printf "\r%-${progress_bar_width}s %d%%" "$(printf '█%.0s' $(seq 1 $filled_width))" "$percentage"
			done
		}
	
  	echo -e "\n\r[\033[0;32m✓\033[0m] Zip completed!"
    echo "Find $zip_name in $(pwd)"
}

alias zp="zp-fn"

alias zz="sh zipme.sh"