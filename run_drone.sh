#!/bin/bash

# $1 is the target domain, $2 is the GitHub token
TARGET=$1
TOKEN=$2
DATE=$(date +%Y-%m-%d)
RESULTS_DIR="recon_results/${TARGET}_${DATE}"

echo "=================================================="
echo "Starting recon drone for: $TARGET"
echo "=================================================="

# Create a directory for the results
mkdir -p $RESULTS_DIR

# --- Step 1: Subdomain Enumeration with subfinder ---
echo "[*] Running subfinder for subdomains..."
subfinder -d $TARGET -o "${RESULTS_DIR}/subdomains.txt"
echo "[+] Subfinder finished. Results saved to ${RESULTS_DIR}/subdomains.txt"

# --- Step 2: Check for live hosts with httpx ---
echo "[*] Running httpx to find live web servers..."
cat "${RESULTS_DIR}/subdomains.txt" | httpx -o "${RESULTS_DIR}/live_hosts.txt"
echo "[+] httpx finished. Results saved to ${RESULTS_DIR}/live_hosts.txt"

# --- Step 3: Vulnerability Scanning with nuclei ---
echo "[*] Running nuclei for vulnerabilities..."
nuclei -l "${RESULTS_DIR}/live_hosts.txt" -t "technologies,cves,misconfiguration,vulnerabilities" -o "${RESULTS_DIR}/nuclei_findings.txt"
echo "[+] Nuclei finished. Results saved to ${RESULTS_DIR}/nuclei_findings.txt"

echo "=================================================="
echo "Recon drone for $TARGET has completed its mission."
echo "=================================================="
