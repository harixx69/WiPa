# WiPa - Wi-Fi Password Cracker

WiPa is a script designed to crack Wi-Fi passwords using Hashcat, a popular password recovery tool.

## Features

- Supports both mask attack and straight mode (brute-force).
- Automates the process of attempting different password patterns to crack Wi-Fi passwords stored in handshake files (hccapx).

## Requirements

- Hashcat installed on your system.
- Handshake file (hccapx) captured from a Wi-Fi network.

## Usage

1. Clone the repository or download the WiPa script.
2. Ensure Hashcat is properly installed on your system.
3. Run the script and follow the prompts to specify the path to your handshake file and choose between mask attack or brute-force mode.

## Examples

```bash
# Run WiPa script
./wipa.sh
