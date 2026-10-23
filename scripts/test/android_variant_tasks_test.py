"""Check the real Gradle task graph from `:app:tasks --all` on standard input."""

import argparse
import re
import sys


parser = argparse.ArgumentParser()
parser.add_argument("--environment", choices=["test", "prod"], required=True)
environment = parser.parse_args().environment
tasks = set(re.findall(r"^(\w+) -", sys.stdin.read(), flags=re.MULTILINE))
test_tasks = {"assembleEnvTestDebug", "testEnvTestDebugUnitTest"}
prod_tasks = {"assembleProdRelease", "assembleProdProfile"}
probe_tasks = {"assembleEnvTestProbeProfile"}
forbidden = {
    "assembleEnvTestRelease", "assembleEnvTestProfile", "assembleProdDebug",
    "assembleEnvTestProbeDebug", "assembleEnvTestProbeRelease",
}
if environment == "test":
    required = test_tasks | probe_tasks
    forbidden |= prod_tasks
else:
    required = prod_tasks
    forbidden |= test_tasks | probe_tasks
missing = sorted(required - tasks)
unexpected = sorted(forbidden & tasks)
if missing or unexpected:
    raise SystemExit(f"Android environment variants rejected: missing={missing}, unexpected={unexpected}")
print(f"Android environment variants passed: {environment}.")
