#!/bin/bash
TARGET=$1
DATE=$(date +%Y-%m-%d)
RESULTS_DIR="recon_results/${TARGET}_${DATE}"
echo "=================================================="
echo "Starting recon drone for: $TARGET"
echo "=================================================="
mkdir -p $RESULTS_DIR
echo "[*] Running subfinder for subdomains..."
subfinder -d $TARGET -o "${RESULTS_DIR}/subdomains.txt"
echo "[+] Subfinder finished."
echo "[*] Running httpx to find live web servers..."
cat "${RESULTS_DIR}/subdomains.txt" | httpx -o "${RESULTS_DIR}/live_hosts.txt"
echo "[+] httpx finished."
echo "[*] Running nuclei for vulnerabilities..."
nuclei -l "${RESULTS_DIR}/live_hosts.txt" -as -o "${RESULTS_DIR}/nuclei_findings.txt"
echo "[+] Nuclei finished."
echo "=================================================="
echo "Recon drone for $TARGET has completed its mission."
echo "=================================================="
