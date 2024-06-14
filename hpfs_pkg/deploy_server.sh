#!/bin/bash

# Function to get IP address of the current machine
get_ip_address() {
    ip addr show | grep -oP '(?<=inet\s)\d+(\.\d+){3}' | grep -v '127.0.0.1' | head -n 1
}

# Get the IP address of the current machine
current_ip=$(get_ip_address)
echo "Current IP address: $current_ip"

# Read data from /etc/fsconf/msrv.conf file
meta_addrs=$(awk '/^MetaAddrs=/{print $1}' /etc/fsconf/msrv.conf | cut -d= -f2)
echo "MetaAddrs: $meta_addrs"

# Extract IP addresses from MetaAddrs
IFS='&' read -ra addr_array <<< "$meta_addrs"
echo "Number of addresses: ${#addr_array[@]}"
echo "Addresses:"
for addr in "${addr_array[@]}"; do
    if [[ "$addr" == *"$current_ip"* ]]; then
        echo "$addr"
    fi
done

# Find the index of current_ip in the addr_array
indexes=()
for ((i=0; i<${#addr_array[@]}; i++)); do
    address="${addr_array[$i]}"
    if [[ "$address" == *"$current_ip"* ]]; then
        indexes+=("$i")
    fi
done

# If current_ip is found in addr_array
if [ "${#indexes[@]}" -gt 0 ]; then
    for idx in "${indexes[@]}"; do
        address="${addr_array[$idx]}"
        # Extract the port number from the address
        port=$(echo "$address" | cut -d: -f2)
        echo "Port: $port"

        # Execute the command for each found result
        echo "Executing command: ./execute_command.sh $port $idx"
        ./command.sh "$port" "$idx"
    done
ps -ef|grep hpfs
else
    echo "IP address not found in MetaAddrs."
fi
