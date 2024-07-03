#!/bin/bash

# Function to run Hashcat with specific mask
run_hashcat_mask() {
    handshake_file=$1
    mask=$2
    ssid=$3

    echo "Running Hashcat for SSID: $ssid with mask: $mask"

    # Check if the handshake file exists
    if [ ! -f "$handshake_file" ]; then
        echo "Handshake file '$handshake_file' not found."
        return 1
    fi

    # Hashcat command for mask attack
    hashcat -m 2500 -a 3 "$handshake_file" "$mask" --quiet --force --status --potfile-disable --outfile=found.txt

    # Check if password found
    if [ $? -eq 0 ]; then
        echo "Password found for SSID: $ssid"
        return 0
    else
        echo "Password not found for SSID: $ssid with mask: $mask"
        return 1
    fi
}

# Function to run Hashcat in straight mode (brute-force)
run_hashcat_bruteforce() {
    handshake_file=$1
    ssid=$2
    used_masks=$3
    bruteforce_timeout=$4

    echo "Running Hashcat for SSID: $ssid in straight mode (brute-force) with timeout: $bruteforce_timeout seconds"

    # Check if the handshake file exists
    if [ ! -f "$handshake_file" ]; then
        echo "Handshake file '$handshake_file' not found."
        return 1
    fi

    # Hashcat command for straight mode (brute-force)
    hashcat -m 2500 -a 3 "$handshake_file" --quiet --force --status --potfile-disable --outfile=found.txt --skip="$used_masks" --runtime=$bruteforce_timeout

    # Check if password found
    if [ $? -eq 0 ]; then
        echo "Password found for SSID: $ssid"
        return 0
    else
        echo "Password not found for SSID: $ssid in straight mode (brute-force)"
        return 1
    fi
}

# Main script
echo "============================================================"
echo "=               WIFI PASSWORD CRACKER by HARIXX             ="
echo "============================================================"
echo "Welcome to WIFI PASSWORD CRACKER! This tool helps you crack Wi-Fi passwords using hashcat."
echo "Enter the path to your handshake file (hccapx): "
read handshake_file

# Check if handshake file exists
if [ ! -f "$handshake_file" ]; then
    echo "Handshake file '$handshake_file' not found."
    exit 1
fi

# Extract SSID from handshake file
ssid=$(hcxpcaptool -I "$handshake_file" | grep -oP 'SSID\s+\K.+')

if [ -z "$ssid" ]; then
    echo "Failed to extract SSID from handshake file."
    exit 1
fi

echo "SSID found in handshake file: $ssid"

# Masks for mask attack (adjust as needed)
masks=(
    '?d?d?d?d?d?d?d?d'        # 8-digit numeric password
    '?d?d?d?d?d?d?d?d?d'      # 9-digit numeric password
    '?d?d?d?d?d?d?d?d?d?d'    # 10-digit numeric password
    '?d?d?d?d?d?d?d?d?d?d?d'  # 11-digit numeric password
    '?d?d?d?d?d?d?d?d?d?d?d?d' # 12-digit numeric password
    '?a?a?a?a?a?a?a?a'        # 8-character alphanumeric password
    '?a?a?a?a?a?a?a?a?a'      # 9-character alphanumeric password
    '?a?a?a?a?a?a?a?a?a?a'    # 10-character alphanumeric password
    '?a?a?a?a?a?a?a?a?a?a?a'  # 11-character alphanumeric password
    '?a?a?a?a?a?a?a?a?a?a?a?a' # 12-character alphanumeric password
)

# Track used masks
used_masks=""

# Run mask attack first
password_found=0
for mask in "${masks[@]}"; do
    run_hashcat_mask "$handshake_file" "$mask" "$ssid"
    if [ $? -eq 0 ]; then
        password_found=1
        break
    fi
    used_masks="$used_masks,$mask"
done

# If password not found, proceed with brute-force attack
if [ $password_found -eq 0 ]; then
    echo "Enter the duration in hours for straight mode (brute-force): "
    read bruteforce_hours
    bruteforce_timeout=$(( bruteforce_hours * 3600 ))  # Convert hours to seconds
    run_hashcat_bruteforce "$handshake_file" "$ssid" "$used_masks" "$bruteforce_timeout"
fi

if [ $password_found -eq 0 ]; then
    echo "Password not found with any of the specified methods."
fi
