# [ R E C O N  F L E X ]

Advanced Reconnaissance Framework

A powerful reconnaissance automation tool for bug hunters and penetration testers.

## Features

- **Subdomain Discovery**: Uses multiple tools to find subdomains
- **Live Verification**: Checks which subdomains are actually reachable
- **Historical URL Discovery**: Finds historical URLs and endpoints
- **Parameter Extraction**: Identifies parameters in discovered URLs
- **Subdomain Takeover Detection**: Scans for potential subdomain takeovers
- **Batch Processing**: Supports scanning multiple domains from a file

## Requirements

Make sure you have the following tools installed and accessible in your PATH:

- [subfinder](https://github.com/projectdiscovery/subfinder)
- [assetfinder](https://github.com/tomnomnom/assetfinder)
- [findomain](https://github.com/Edu4rdSHL/findomain)
- [amass](https://github.com/owasp-amass/amass)
- [httprobe](https://github.com/tomnomnom/httprobe)
- [waybackurls](https://github.com/tomnomnom/waybackurls)
- [gau](https://github.com/lc/gau)
- [unfurl](https://github.com/tomnomnom/unfurl)
- [subjack](https://github.com/haccer/subjack)

## Installation

1. Clone or download this repository
2. Ensure all required tools are installed
3. Add the ReconKit directory to your PATH (optional, for easy access)

## Usage

### Single Domain Scan

```bash
bash recon-flex.sh example.com
```

### Batch Scan from File

```bash
bash recon-flex.sh -f domains.txt
```

### Help

```bash
bash recon-flex.sh --help
```

## Example Output

```
==========================================
Target: example.com
==========================================

----------SUBFINDER OUTPUT FOR example.com----------
Subdomains Found: 42
Output File Name: example.com-subfinder.txt

----------ASSETFINDER OUTPUT FOR example.com----------
Subdomains Found: 56
Output File Name: example.com-assetfinder.txt

----------FINDOMAIN OUTPUT FOR example.com----------
Subdomains Found: 38
Output File Name: example.com-findomain.txt

----------AMASS OUTPUT FOR example.com----------
Subdomains Found: 100
Output File Name: example.com-amass.txt

SORTING UNIQUE SUBDOMAINS TO A NEW FILE...

----------UNIQUE SUBDOMAINS OUTPUT----------
Total Unique Subdomains: 102
Output File Name: example.com-uniq-subs.txt

STARTED PROBING TO FIND LIVE SUBDOMAINS...

----------LIVE SUBDOMAINS FOUND FOR example.com----------
Total Live Subdomains: 78
Output File Name: example.com-live-subs.txt

FINDING HISTORICAL URLS AND ENDPOINTS OF UNIQUE LIVE SUBDOMAINS
Note: This may take some time to finish....

----------HISTORICAL URLS AND ENDPOINTS FOUND FOR example.com----------
Urls Found Using Waybackurls: 12456
Urls Found Using Gau: 8923
Unique Urls After Sorting: 15678
Output File Saved For Unique Urls: example.com-uniq-urls.txt

----------PARAMETERS ON URL'S FOUND FOR example.com----------
Total Parameters: 456
Output File: example.com-params.txt

SCANNING FOR SUBDOMAIN TAKEOVERS...

No takeovers

✅ Completed: example.com

==========================================
🎉 RECON COMPLETE!
==========================================
```

## Directory Structure

When you run the script, it creates a directory for each target domain:

```
ReconKit/
├── recon-flex.sh          # Main script
├── domains.txt            # Example domains file
└── recon_example.com/     # Output directory for example.com
    ├── example.com-assetfinder.txt    # Subdomains from assetfinder
    ├── example.com-findomain.txt      # Subdomains from findomain
    ├── example.com-gau.txt            # URLs from gau
    ├── example.com-live-subs.txt      # Live subdomains
    ├── example.com-params.txt         # Extracted parameters
    ├── example.com-subfinder.txt      # Subdomains from subfinder
    ├── example.com-takeovers.txt      # Subdomain takeover results
    ├── example.com-uniq-subs.txt      # Unique subdomains
    ├── example.com-uniq-urls.txt      # Unique URLs
    └── example.com-waybackurls.txt    # URLs from waybackurls
```

## Tools Utilized

| Category                | Tools Used                                  |
|-------------------------|---------------------------------------------|
| Subdomain Discovery     | subfinder, assetfinder, findomain, amass    |
| Live Verification       | httprobe                                    |
| URL Discovery           | waybackurls, gau                            |
| Parameter Extraction    | unfurl                                      |
| Takeover Scan           | subjack                                     |

## Customization

You can customize the script by modifying the following:

- Adjust tool parameters in the `run_recon` function
- Change the output directory naming convention
- Modify the subjack fingerprints path (currently set to `$HOME/go/bin/fingerprints.json`)

## Contributing

Feel free to submit issues and enhancement requests!

## License

This project is open source and available under the [MIT License](LICENSE).