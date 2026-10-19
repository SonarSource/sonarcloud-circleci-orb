"""Exercise the scan script without network access, Java, or a SonarCloud token."""

import json
import os
from pathlib import Path
import shlex
import subprocess
import sys
import tempfile
import unittest
import zipfile


SOURCE = Path(__file__).resolve().parents[1] / "src/scripts/scan.sh"
DEFAULT_VERSION = "8.0.1.6346"


class ScanTest(unittest.TestCase):
    def setUp(self):
        temporary = tempfile.TemporaryDirectory(prefix="orb-scan-test-")
        self.addCleanup(temporary.cleanup)
        self.root = Path(temporary.name)
        self.bin = self.root / "bin"
        self.bin.mkdir()
        self.cache = self.root / "cache"
        self.download_log = self.root / "downloads.jsonl"
        self.run_log = self.root / "scanner.log"
        self.archive = self.root / "fixture.zip"
        self.script = self.root / "scan.sh"
        # Redirect the fixed production cache into this test's isolated directory.
        source = SOURCE.read_text()
        self.assertIn("SCANNER_DIRECTORY=/tmp/cache/scanner", source)
        self.script.write_text(source.replace(
            "SCANNER_DIRECTORY=/tmp/cache/scanner",
            "SCANNER_DIRECTORY=" + shlex.quote(str(self.cache)),
        ))
        self.env = {
            "PATH": str(self.bin) + os.pathsep + os.environ["PATH"],
            "SONAR_TOKEN": "fake_token",
            "MOCK_ARCH": "x86_64",
            "MOCK_ARCHIVE": str(self.archive),
            "MOCK_DOWNLOAD_LOG": str(self.download_log),
            "TEST_RUN_LOG": str(self.run_log),
        }
        self.stub("uname", 'import os\nprint(os.environ["MOCK_ARCH"])\n')
        self.stub("curl", '''
import json, os, pathlib, shutil, sys
with open(os.environ["MOCK_DOWNLOAD_LOG"], "a") as log:
    log.write(json.dumps(sys.argv[1:]) + "\\n")
target = pathlib.Path(sys.argv[-1].rsplit("/", 1)[1])
if os.environ.get("MOCK_HTTP_ERROR"):
    if any("f" in arg for arg in sys.argv[1:] if arg.startswith("-")):
        sys.exit(22)
    target.write_text("HTTP error response")
else:
    shutil.copyfile(os.environ["MOCK_ARCHIVE"], target)
''')
        self.stub("unzip", '''
import sys, zipfile
with zipfile.ZipFile(sys.argv[3]) as archive:
    archive.extractall(sys.argv[5])
''')
        self.make_archive()

    def stub(self, name, body):
        path = self.bin / name
        path.write_text("#!" + sys.executable + "\n" + body)
        path.chmod(0o755)

    def make_archive(self, arch="x64", version=DEFAULT_VERSION):
        self.installation = self.cache / f"sonar-scanner-{version}-linux-{arch}"
        prefix = self.installation.name
        with zipfile.ZipFile(self.archive, "w") as archive:
            archive.writestr(prefix + "/bin/sonar-scanner", '''#!/bin/sh
printf '%s\\n' "$PWD" "$SONAR_USER_HOME" > "$TEST_RUN_LOG"
echo SCANNER_EXECUTED
''')
            archive.writestr(prefix + "/jre/bin/java", "fixture bundled Java\n")

    def scan(self):
        return subprocess.run(
            ["bash", str(self.script)], cwd=self.root, env=self.env,
            text=True, capture_output=True,
        )

    def downloads(self):
        if not self.download_log.exists():
            return []
        return [json.loads(line) for line in self.download_log.read_text().splitlines()]

    def assert_architecture(self, alias, arch):
        self.env["MOCK_ARCH"] = alias
        self.make_archive(arch)
        result = self.scan()
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        self.assertIn("SCANNER_EXECUTED", result.stdout)
        self.assertEqual(self.downloads()[0][-1],
                         "https://binaries.sonarsource.com/Distribution/sonar-scanner-cli/"
                         f"sonar-scanner-cli-{DEFAULT_VERSION}-linux-{arch}.zip")
        self.assertTrue(os.access(self.installation / "jre/bin/java", os.X_OK))

    def test_x86_64(self):
        self.assert_architecture("x86_64", "x64")

    def test_x64(self):
        self.assert_architecture("x64", "x64")

    def test_amd64(self):
        self.assert_architecture("amd64", "x64")

    def test_arm64(self):
        self.assert_architecture("arm64", "aarch64")

    def test_aarch64(self):
        self.assert_architecture("aarch64", "aarch64")

    def test_unsupported_architecture_stops_before_download(self):
        for arch in ("riscv64", "armv7l", ""):
            with self.subTest(arch=arch):
                self.env["MOCK_ARCH"] = arch
                result = self.scan()
                self.assertNotEqual(result.returncode, 0)
                self.assertIn("Unsupported CPU architecture", result.stderr)
                self.assertEqual(self.downloads(), [])
                self.assertFalse(self.run_log.exists())

    def test_warm_cache_does_not_download_again(self):
        self.assertEqual(self.scan().returncode, 0)
        self.run_log.unlink()
        result = self.scan()
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertTrue(self.run_log.exists())
        self.assertEqual(len(self.downloads()), 1)

    def test_other_architecture_cache_does_not_skip_installation(self):
        self.assertEqual(self.scan().returncode, 0)
        self.env["MOCK_ARCH"] = "aarch64"
        self.make_archive("aarch64")
        result = self.scan()
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(len(self.downloads()), 2)
        self.assertIn("-linux-aarch64.zip", self.downloads()[-1][-1])

    def test_custom_scanner_version(self):
        self.env["SCANNER_VERSION"] = "6.2.1.4610"
        self.make_archive(version="6.2.1.4610")
        result = self.scan()
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn("6.2.1.4610-linux-x64.zip", self.downloads()[0][-1])

    def test_project_root_and_sonar_user_home(self):
        project = self.root / "project with spaces"
        project.mkdir()
        self.env["PROJECT_ROOT"] = str(project)
        result = self.scan()
        self.assertEqual(result.returncode, 0, result.stderr)
        actual_root, actual_home = self.run_log.read_text().splitlines()
        self.assertEqual(Path(actual_root).resolve(), project.resolve())
        self.assertEqual(actual_home, str(self.cache / ".sonar"))

    def test_missing_token_stops_before_download(self):
        del self.env["SONAR_TOKEN"]
        result = self.scan()
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("SONAR_TOKEN is required", result.stderr)
        self.assertEqual(self.downloads(), [])

    def test_http_error_stops_before_installation(self):
        self.env["MOCK_HTTP_ERROR"] = "1"
        result = self.scan()
        self.assertEqual(result.returncode, 22, result.stdout + result.stderr)
        self.assertFalse(self.installation.exists())
        self.assertFalse(self.run_log.exists())


if __name__ == "__main__":
    unittest.main()
