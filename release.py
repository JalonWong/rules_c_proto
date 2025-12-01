import subprocess
import sys
import tarfile
from glob import glob

PYTHON = sys.executable


if __name__ == "__main__":
    tag = sys.argv[1]

    subprocess.run([PYTHON, "--version"])

    with open("MODULE.bazel", "r") as f:
        text = f.read().replace("0.0.0", tag.replace("v", ""))
        with open("MODULE.bazel", "w") as f:
            f.write(text)

    with tarfile.open(f"rules_c_proto-{tag}.tar.gz", "w:gz") as tar:
        tar.add(".bazelrc")
        tar.add("BUILD")
        tar.add("MODULE.bazel")
        tar.add("tools/bin.BUILD")
        tar.add("tools/BUILD")

        files = glob("*.bzl") + glob("test/**", recursive=True) + glob("tools/*.bzl", recursive=True)
        for file in files:
            tar.add(file)
