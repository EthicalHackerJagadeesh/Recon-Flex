#!/usr/bin/env bash

cat << 'EOF'

██████╗ ███████╗ ██████╗ ██████╗ ███╗   ██╗
██╔══██╗██╔════╝██╔════╝██╔═══██╗████╗  ██║
██████╔╝█████╗  ██║     ██║   ██║██╔██╗ ██║
██╔══██╗██╔══╝  ██║     ██║   ██║██║╚██╗██║
██║  ██║███████╗╚██████╗╚██████╔╝██║ ╚████║
╚═╝  ╚═╝╚══════╝ ╚═════╝ ╚═════╝ ╚═╝  ╚═══╝
           R E C O N   F L E X

AUTHOR: Mr Hacker
GITHUB: 
EOF

echo ""

# Function to display usage
usage() {
    echo "Usage:"
    echo "  bash recon-flex.sh <domain>              # Single domain scan"
    echo "  bash recon-flex.sh -f <domains.txt>      # Scan a list of domains from a file"
    echo "  bash recon-flex.sh -h, --help            # Show this help message"
    echo ""
    echo "Options:"
    echo "  -f, --file    Specify a file containing a list of domains (one per line)"
    echo "  -h, --help    Display this help message and exit"
    echo ""
    echo "Tools Utilized:"
    echo "  * Subdomain Discovery : subfinder, assetfinder, findomain, amass"
    echo "  * Live Verification   : httprobe"
    echo "  * URL Discovery       : waybackurls, gau"
    echo "  * Parameter Extraction: unfurl"
    echo "  * Takeover Scan       : subjack"
    echo ""
    echo "Examples:"
    echo "  bash d:\Bug Hunting Tools\ReconKit\recon-flex.sh example.com"
    echo "  bash d:\Bug Hunting Tools\ReconKit\recon-flex.sh -f domains.txt"
    exit 0
}

# Check for help argument first
if [[ "$1" == "-h" || "$1" == "--help" ]]; then
    usage
fi

# Check if arguments provided
if [[ $# -eq 0 ]]; then
    echo "Error: Missing arguments."
    usage
fi

# Function to run recon on a single domain
run_recon() {
    local target=$1
    
    echo "=========================================="
    echo "Target: $target"
    echo "=========================================="
    echo ""
    
    mkdir -p "recon_$target"
    cd "recon_$target"
    
    # Subfinder
    subfinder -d "${target}" -o "${target}-subfinder.txt" -silent > /dev/null 2>&1
    
    if [[ -s "${target}-subfinder.txt" ]]; then
        echo "----------SUBFINDER OUTPUT FOR ${target}----------"
        echo "Subdomains Found: $(wc -l < "${target}-subfinder.txt")"
        echo "Output File Name: ${target}-subfinder.txt"
        echo ""
    else
        echo "No subdomains were found from subfinder"
    fi
    
    # Assetfinder
    assetfinder --subs-only "${target}" > "${target}-assetfinder.txt"
    
    if [[ -s "${target}-assetfinder.txt" ]]; then
        echo "----------ASSETFINDER OUTPUT FOR ${target}----------"
        echo "Subdomains Found: $(wc -l < "${target}-assetfinder.txt")"
        echo "Output File Name: ${target}-assetfinder.txt"
        echo ""
    else
        echo "No subdomains were found from assetfinder"
    fi
    
    # Findomain
    findomain -t "${target}" -u "${target}-findomain.txt" > /dev/null 2>&1
    if [[ -s "${target}-findomain.txt" ]]; then
        echo "----------FINDOMAIN OUTPUT FOR ${target}----------"
        echo "Subdomains Found: $(wc -l < "${target}-findomain.txt")"
        echo "Output File Name: ${target}-findomain.txt"
        echo ""
    else
        echo "No subdomains were found from findomain"
    fi
    
    # Amass (Passive Mode)
    amass enum -passive -d "${target}" -o "${target}-amass.txt" > /dev/null 2>&1
    if [[ -s "${target}-amass.txt" ]]; then
        echo "----------AMASS OUTPUT FOR ${target}----------"
        echo "Subdomains Found: $(wc -l < "${target}-amass.txt")"
        echo "Output File Name: ${target}-amass.txt"
        echo ""
    else
        echo "No subdomains were found from amass"
    fi
    
    echo ""
    echo "SORTING UNIQUE SUBDOMAINS TO A NEW FILE..."
    echo ""
    
    cat "${target}-subfinder.txt" "${target}-assetfinder.txt" "${target}-findomain.txt" "${target}-amass.txt" 2>/dev/null | sort -u > "${target}-uniq-subs.txt"
    
    echo "----------UNIQUE SUBDOMAINS OUTPUT----------"
    echo "Total Unique Subdomains: $(wc -l < "${target}-uniq-subs.txt")"
    echo "Output File Name: ${target}-uniq-subs.txt"
    echo ""
    
    echo ""
    echo "STARTED PROBING TO FIND LIVE SUBDOMAINS..."
    echo ""
    
    cat "${target}-uniq-subs.txt" | httprobe > "${target}-live-subs.txt"
    
    if [[ -s "${target}-live-subs.txt" ]]; then
        echo "----------LIVE SUBDOMAINS FOUND FOR ${target}----------"
        echo "Total Live Subdomains: $(wc -l < "${target}-live-subs.txt")"
        echo "Output File Name: ${target}-live-subs.txt"
        echo ""
    else
        echo "No Live Subdomains found for ${target}"
    fi
    
    echo ""
    echo "FINDING HISTORICAL URLS AND ENDPOINTS OF UNIQUE LIVE SUBDOMAINS"
    echo "Note: This may take some time to finish...."
    echo ""
    
    # RUNS SIMULTANEOUSLY
    cat "${target}-live-subs.txt" | waybackurls > "${target}-waybackurls.txt" &    # Background job 1
    cat "${target}-live-subs.txt" | gau --subs > "${target}-gau.txt" 2>/dev/null &  # Background job 2
    wait                                             # Wait for BOTH to finish
    
    cat "${target}-waybackurls.txt" "${target}-gau.txt" 2>/dev/null | sort -u > "${target}-uniq-urls.txt"
    
    echo "----------HISTORICAL URLS AND ENDPOINTS FOUND FOR ${target}----------"
    echo "Urls Found Using Waybackurls: $(wc -l < "${target}-waybackurls.txt")"
    echo "Urls Found Using Gau: $(wc -l < "${target}-gau.txt")"
    echo "Unique Urls After Sorting: $(wc -l < "${target}-uniq-urls.txt")"
    echo "Output File Saved For Unique Urls: ${target}-uniq-urls.txt"
    
    cat "${target}-uniq-urls.txt" | unfurl --unique keys > "${target}-params.txt"
    
    if [[ -s "${target}-params.txt" ]]; then
        echo ""
        echo "----------PARAMETERS ON URL'S FOUND FOR ${target}----------"
        echo "Total Parameters: $(wc -l < "${target}-params.txt")"
        echo "Output File: ${target}-params.txt"
    else
        echo "No Parameters have been found..."
    fi
    
    echo ""
    echo "SCANNING FOR SUBDOMAIN TAKEOVERS..."
    echo ""
    
    # Ensure fingerprints.json path is correct for your system
    subjack -w "${target}-uniq-subs.txt" -t 25 -ssl -c "$HOME/go/bin/fingerprints.json" -o "${target}-takeovers.txt"
    
    if [[ -s "${target}-takeovers.txt" ]]; then
        echo "⚠️ TAKEOVERS: $(wc -l < "${target}-takeovers.txt")"
        cat "${target}-takeovers.txt"
    else
        echo "No takeovers"
    fi
    
    cd ..
    echo ""
    echo "✅ Completed: $target"
    echo ""
}

# Check if file mode or single domain mode
if [[ "$1" == "-f" ]]; then
    # File mode
    if [[ ! -f "$2" ]]; then
        echo "Error: File '$2' not found!"
        exit 1
    fi
    
    domains_file="$2"
    total_domains=$(grep -v '^#' "$domains_file" | grep -v '^[[:space:]]*$' | wc -l)
    echo "Found $total_domains domains in file: $domains_file"
    echo "Starting batch reconnaissance..."
    echo ""
    
    current=0
    
    while IFS= read -r target || [[ -n "$target" ]]; do
        # Skip empty lines and comments
        [[ -z "$target" || "$target" =~ ^[[:space:]]*# ]] && continue
        
        current=$((current + 1))
        echo "[$current/$total_domains]"
        run_recon "$target"
    done < "$domains_file"
    
    echo "=========================================="
    echo "🎉 BATCH RECON COMPLETE!"
    echo "Processed $current domains"
    echo "=========================================="
    
else
    # Single domain mode
    target="$1"
    run_recon "$target"
    
    echo "=========================================="
    echo "🎉 RECON COMPLETE!"
    echo "=========================================="
fi