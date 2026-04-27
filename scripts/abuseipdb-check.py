import sys
import json
import urllib.request
import urllib.error

def check_ip(ip: str, api_key: str) -> dict:
    url = f"https://api.abuseipdb.com/api/v2/check?ipAddress={ip}&maxAgeInDays=90&verbose"
    req = urllib.request.Request(url)
    req.add_header("Key", api_key)
    req.add_header("Accept", "application/json")

    try:
        with urllib.request.urlopen(req, timeout=5) as resp:
            data = json.loads(resp.read().decode())["data"]
            return {
                "score":        data.get("abuseConfidenceScore", 0),
                "country":      data.get("countryCode", "N/A"),
                "isp":          data.get("isp", "N/A"),
                "total_reports": data.get("totalReports", 0),
                "last_reported": data.get("lastReportedAt", "N/A"),
                "is_tor":       data.get("isTor", False),
                "error":        None
            }
    except urllib.error.HTTPError as e:
        return {"error": f"HTTP {e.code}"}
    except Exception as e:
        return {"error": str(e)}

if __name__ == "__main__":
    if len(sys.argv) < 3:
        print(json.dumps({"error": "Uso: abuseipdb-check.py <IP> <API_KEY>"}))
        sys.exit(1)

    result = check_ip(sys.argv[1], sys.argv[2])
    print(json.dumps(result))
