#!/bin/bash

DIR="test_dir"
MALICIOUS_DIR="malicious_dir"

action() {
    echo "1- Run antivirus"
    echo "2- Run restore"
    echo "3- Create malicious directory"
    echo "Choose action:"
    read choice

    case "$choice" in
        1)
            ./antivirusd.sh "$DIR" "$MALICIOUS_DIR"
            ;;
        2)
            ./restore.sh "$DIR" "$MALICIOUS_DIR"
            ;;
        3)
            mkdir -p "$MALICIOUS_DIR"
            echo "Quarantine directory created."
            action
            ;;
        *)
            echo "Invalid choice"
            action
            ;;
    esac
}

mkdir -p "$DIR" "$MALICIOUS_DIR"
action