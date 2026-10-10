#!/bin/bash

if [ "$#" -ne 2 ]; then
    echo "Usage: $0 dir malicious_dir"
    exit 1
fi

dir="$1"
malicious_dir="$2"
interval=5

if [ ! -d "$dir" ]; then
    echo "Directory does not exist"
    exit 1
fi

mkdir -p "$malicious_dir"

malicious_ex=("exe" "bat" "vbs" "scr" "ps1")
malicious_key=("virus" "trojan" "malware" "worm" "ransomware")

info_new="directory-info.new"
info_last="directory-info.last"

getInfo() {
    ls -l "$dir" > "$info_new"
}

scanF() {
    for file in "$dir"/*; do
        [ -f "$file" ] || continue

        fname=$(basename "$file")
        ext=""
         if [[ "$fname" == *.* ]]; then
          ext=${fname##*.}
         fi
        malicious=0

        for ex in "${malicious_ex[@]}"; do
            if [ "$ext" = "$ex" ]; then
                malicious=1
                break
            fi
        done

        if [ "$malicious" == "0" ]; then
            for key in "${malicious_key[@]}"; do
                if grep -qi "$key" "$file"; then
                    malicious=1
                    break
                fi
            done
        fi

        if [ "$malicious" == "1" ]; then
            if cp "$file" "$malicious_dir/$fname"; then
             rm "$file"
             echo "$fname is malicious and it is DELETED"
            fi
        fi
    done
}

init() {
    scanF
    ls -l "$dir" > "$info_last"
}

scan() {
    init

    while true; do
        sleep "$interval"

        getInfo

        if ! cmp -s "$info_last" "$info_new"; then
            echo "Change detected. Scanning directory..."
            scanF
            ls -l "$dir" > "$info_last"
        fi
    done
}

scan