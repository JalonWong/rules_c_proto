import sys
import tarfile
from glob import glob

TAMPLATE = """
`MODULE.bazel`:
```py
bazel_dep(name = "rules_c_proto", version = "{version}")
```
"""


if __name__ == "__main__":
    tag = sys.argv[1]

    with open("MODULE.bazel", "r") as f:
        v = tag.replace("v", "")
        print(TAMPLATE.format(version=v))
        text = f.read().replace("0.0.0", v)
        with open("MODULE.bazel", "w") as f:
            f.write(text)

    with tarfile.open(f"rules_c_proto-{tag}.tar.gz", "w:gz") as tar:
        tar.add(".bazelrc")
        tar.add("BUILD")
        tar.add("MODULE.bazel")

        files = (
            glob("*.bzl") + glob("test/base/**", recursive=True) + glob("tools/**", recursive=True)
        )
        for file in files:
            tar.add(file)
