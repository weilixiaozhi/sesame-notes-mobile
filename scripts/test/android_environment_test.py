"""Run the build-entry behavior checks with a fake Flutter; no SDK or APK build."""

import os
from pathlib import Path
import shutil
import subprocess
import unittest


ROOT = Path(__file__).resolve().parents[2]
SHELL = shutil.which("pwsh") or (
    str(Path(os.environ["SystemRoot"]) / "System32/WindowsPowerShell/v1.0/powershell.exe")
    if os.name == "nt"
    else shutil.which("pwsh")
)


class AndroidEnvironmentTest(unittest.TestCase):
    def test_public_build_entry(self):
        self.assertIsNotNone(SHELL, "PowerShell must already be installed")
        result = subprocess.run(
            [SHELL, "-NoProfile", "-NonInteractive"]
            + (["-ExecutionPolicy", "Bypass"] if os.name == "nt" else [])
            + ["-File", str(ROOT / "scripts/test/android_environment_test.ps1")],
            cwd=ROOT,
            capture_output=True,
            text=True,
            encoding="utf-8",
            errors="replace",
            timeout=30,
        )
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        self.assertIn("Android environment behavior checks passed", result.stdout)


if __name__ == "__main__":
    unittest.main()
