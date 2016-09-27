#!/bin/bash
# GNU GPL v3 applies. No warranty of any kind... Use it at your own risk!

x-terminal-emulator -e bash -c "sudo dpkg -i "$@"; sudo apt-get -f install -q -y; bash"

