#!/bin/bash

usage() {
  echo "Usage: $0 -ip <ip_list> -count <port_count>"
  echo "  -ip    Comma-separated list of IP addresses (e.g., '192.168.1.1,192.168.1.2')"
  echo "  -count Number of ports per IP, starting from 10101 (e.g., 2)"
  exit 1
}

parse_args() {
  if [ $# -eq 0 ]; then
    usage
  fi

  while [[ "$#" -gt 0 ]]; do
    case $1 in
      -ip) ip_addresses="$2"; shift ;;
      -count) count="$2"; shift ;;
      *) echo "Unknown parameter passed: $1"; usage ;;
    esac
    shift
  done

  if [ -z "$ip_addresses" ] || [ -z "$count" ]; then
    echo "Error: Missing required arguments."
    usage
  fi
}

parse_args "$@"

mkdir -p /etc/fsconf

meta_addrs=""
meta_srvs=0

IFS=',' read -ra ADDR <<< "$ip_addresses"
for ip in "${ADDR[@]}"; do
  for (( i=0; i<count; i++ )); do
    port=$((10101 + i))
    meta_addrs+="$ip:$port&"
    meta_srvs=$((meta_srvs + 1))
  done
done

meta_addrs=${meta_addrs%&}

cat <<EOF > /etc/fsconf/msrv.conf
MetaAddrs=$meta_addrs
MetaSrvs=$meta_srvs
EOF

echo "Configuration file created successfully."

