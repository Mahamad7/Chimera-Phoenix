import os
import sys
import requests
import json

def send_discord_message(webhook_url, message_content):
    if not webhook_url:
        print("[ERROR] Discord Webhook URL is not set.")
        return
    headers = {'Content-Type': 'application/json'}
    embed = {
        "title": "🚨 New High-Severity Finding!",
        "description": message_content,
        "color": 15158332
    }
    payload = {"embeds": [embed]}
    try:
        response = requests.post(webhook_url, data=json.dumps(payload), headers=headers)
        response.raise_for_status()
        print(f"[INFO] Successfully sent notification to Discord.")
    except requests.exceptions.RequestException as e:
        print(f"[ERROR] Failed to send Discord message: {e}")

def analyze_nuclei_results(file_path, webhook_url, target_domain):
    print(f"[INFO] Analyzing results for {target_domain} from file: {file_path}")
    try:
        with open(file_path, 'r') as f:
            for line in f:
                line = line.strip()
                if any(severity in line for severity in ['[high]', '[critical]']):
                    print(f"[FOUND] High or Critical severity finding: {line}")
                    parts = line.split(' ')
                    template_name = parts[0].strip('[]')
                    severity = parts[1].strip('[]').upper()
                    finding_url = parts[2]
                    report_message = (
                        f"**Target:** `{target_domain}`\n"
                        f"**URL:** `{finding_url}`\n"
                        f"**Severity:** `{severity}`\n"
                        f"**Vulnerability Type:** `{template_name}`\n\n"
                        f"**Recommendation:**\n"
                        f"Please verify this finding manually."
                    )
                    send_discord_message(webhook_url, report_message)
    except FileNotFoundError:
        print(f"[INFO] No results file found at {file_path}.")
    except Exception as e:
        print(f"[ERROR] An error occurred: {e}")

if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: python reporter.py <target_domain>")
        sys.exit(1)
    target = sys.argv[1]
    date = os.popen("date +%Y-%m-%d").read().strip()
    results_file = f"recon_results/{target}_{date}/nuclei_findings.txt"
    discord_webhook = os.getenv('DISCORD_WEBHOOK_URL')
    analyze_nuclei_results(results_file, discord_webhook, target)
