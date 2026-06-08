#!/usr/bin/python3
import json
import sys
import urllib.error
import urllib.request

url = sys.argv[1]
try:
    with urllib.request.urlopen(url, timeout=5) as response:
        body = json.loads(response.read().decode())
        print(json.dumps({"url": url, "http_code": response.status, "body": body}, sort_keys=True))
except (urllib.error.URLError, TimeoutError, json.JSONDecodeError) as error:
    print(json.dumps({"url": url, "exit_code": 2, "error": str(error)}, sort_keys=True))
    sys.exit(2)
