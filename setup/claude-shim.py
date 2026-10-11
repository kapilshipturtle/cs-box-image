#!/opt/vision/bin/python
"""/usr/local/bin/claude ON THE BOX (Plan Freedom): forwards the call to the laptop's claude-bridge (ssh reverse tunnel
127.0.0.1:8765) and prints its output exactly; retries while the tunnel is down (a network drop only delays the turn)."""
import json, os, sys, time, urllib.request
stdin = "" if sys.stdin.isatty() else sys.stdin.read()
run = next((a for a in sys.argv[1:] + [stdin] if "/channel-studio/runs/" in a), "")
import re
m = re.search(r"/home/shipturtle/channel-studio/runs/[\w-]+", run)
body = json.dumps({"argv": sys.argv[1:], "stdin": stdin, "cwd": os.getcwd(), "run": m.group(0) if m else ""}).encode()
for k in range(240):
    try:
        r = json.loads(urllib.request.urlopen(urllib.request.Request("http://127.0.0.1:8765/", body, {"Content-Type": "application/json"}), timeout=3600).read())
        sys.stdout.write(r["stdout"]); sys.stderr.write(r["stderr"]); sys.exit(r["rc"])
    except (OSError, ValueError) as e:
        sys.stderr.write(f"claude-bridge unreachable ({e}); retrying\n"); time.sleep(15)
sys.exit(1)
