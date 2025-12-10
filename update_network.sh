#!/bin/bash

# check network status and update the network configuration if needed

(
    echo "10"; sleep 0.5
    echo " # checking network interfaces..."
    ip a > /tmp/network_status.txt

    echo "30"; sleep 0.5
    echo " # checking current IP address..."
    hostname -I >> /tmp/network_status.txt 2>&1

    echo "50"; sleep 0.5
    echo " # checking network manager status..."
    #nmcli gives info about the network manager and connectivity
    nmcli general status >> /tmp/network_status.txt 2>&1

    echo "70"; sleep 0.5
    echo " # updating network configuration..."
    # apt update refreshes the package lists
    sudo apt update >> /tmp/network_status.txt 2>&1
    # apt install --only-upgrade updates only the specified packages
    sudo apt install --only-upgrade network-manager net-tools -y >> /tmp/network_status.txt 2>&1
    
    echo "90"; sleep 0.5
    echo " # restarting network service..."
    #restarts the network manager to apply changes
    sudo systemctl restart NetworkManager >> /tmp/network_status.txt 2>&1

    echo "100"; sleep 0.5
) |
#displays progress bar as script runs
zenity --progress \
--title="Network Update" \
--text="Starting network checks" \
--percentage=0 \
--auto-close

#show completion message when done
zenity --info \
--title="Network Update Complete" \
--text="Network update finished, log saved to /tmp/network_status.txt"