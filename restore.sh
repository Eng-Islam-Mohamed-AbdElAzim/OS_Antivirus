#!/bin/bash

if [ "$#" -ne 2 ]; then
    echo "Usage: $0 dir malicious_dir"
    exit 1
fi

dir="$1"
malicious_dir="$2"

if [ ! -d "$dir" ]; then
    echo "Directory does not exist"
    exit 1
fi

if [ ! -d "$malicious_dir" ]; then
    echo "Quarantine directory does not exist"
    exit 1
fi

main() {
    files=("$malicious_dir"/*)
    i=0

    for file in "${files[@]}"; do
        [ -f "$file" ] || continue

        ((i++))
        fname=$(basename "$file")
        echo "$i- $fname"
    done

    if [ "$i" -eq 0 ]; then
        echo "No malicious files to review."
        return
    fi

    echo "Choose file (0 to exit):"
    read selection

    if [ "$selection" = "0" ]; then
        return
    fi

    if ! [[ "$selection" =~ ^[1-9][0-9]*$ ]] || [ "$selection" -gt "$i" ]; then
        echo "Invalid choice"
        main
        return
    fi

    action "$selection"
}

restore() {
    local x="$1"
    local i=0

    for file in "$malicious_dir"/*; do
        [ -f "$file" ] || continue

         i=$((i+1))

        if [ "$i" -eq "$x" ]; then
            fname=$(basename "$file")

            if mv "$file" "$dir/$fname"; then
                echo "Restored $fname to $dir."
            else
                echo "Could not restore $fname."
            fi

            break
        fi
    done
}

delete() {
    local x="$1"
    local i=0

    for file in "$malicious_dir"/*; do
        [ -f "$file" ] || continue

         i=$((i+1))

        if [ "$i" -eq "$x" ]; then
            fname=$(basename "$file")

            if rm "$file"; then
                echo "$fname permanently deleted."
            else
                echo "Could not delete $fname."
            fi

            break
        fi
    done
}

action() {
    local x="$1"

    echo "1- Restore"
    echo "2- Permanently delete"
    echo "3- Leave unchanged"
    echo "Choose action:"
    read choice

    case "$choice" in
        1)
            restore "$x"
            main
            ;;
        2)
            delete "$x"
            main
            ;;
        3)
            echo "Leaving file unchanged."
            main
            ;;
        *)
            echo "Invalid choice"
            main
            ;;
    esac
}

main