#!/bin/bash
#strict mode
set -euo pipefail
IFS=$'\n\t'

get_latest_node_exporter(){
    curl -s https://api.github.com/repos/prometheus/node_exporter/releases/latest | grep "browser_download_url.*linux-amd64" | cut -d : -f 2,3 | tr -d \"
}