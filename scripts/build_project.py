"""
file: build_project.py
author: Rudy Castan
date: 2026 Spring
copyright: CC0 1.0 Universal

Builds all CMake presets.
"""

import argparse
import re
import sys
import platform
import subprocess
from concurrent.futures import ThreadPoolExecutor, as_completed, Future
from dataclasses import dataclass
from pathlib import Path


# Module-level constants
BUILD_TYPES = ('debug', 'developer-release', 'release')
BASE_TARGETS = ('web', 'linux')
SEPARATOR = '=' * 60


@dataclass
class BuildResult:
    """Result of building a specific target and build type."""
    target: str
    build_type: str
    output: str
    error: str = ""

    @property
    def success(self) -> bool:
        return not self.error


def windows_to_wsl_path(win_path: Path) -> str:
    """Convert Windows path to WSL path format."""
    win_path = win_path.resolve()
    match = re.match(r"([A-Za-z]):\\(.*)", str(win_path))
    if not match:
        raise ValueError("Invalid Windows path format")
    drive, path = match.groups()
    return "/mnt/" + drive.lower() + "/" + path.replace("\\", "/")


def configure_preset(folder: Path, build_type: str, target: str) -> BuildResult:
    """Configure a specific CMake preset. Returns BuildResult with configure output."""
    linux_prefix: list[str] = []
    folder_path: Path | str = folder

    if platform.system() == "Windows" and target in ("web", "linux"):
        linux_prefix = ['wsl']
        folder_path = windows_to_wsl_path(folder)
    else:
        folder_path = str(folder)

    log_content: list[str] = []
    log_content.append(SEPARATOR)
    log_content.append(f"Configure: {target.upper()} {build_type}")
    log_content.append(SEPARATOR)

    configure = subprocess.run(
        linux_prefix + ['cmake', '--preset', f'{target}-{build_type.lower()}', '-S', folder_path],
        capture_output=True, text=True, encoding="utf-8"
    )
    log_content.append(configure.stdout)
    if configure.stderr:
        log_content.append(configure.stderr)

    if configure.returncode != 0:
        log_content.append(f"\n[CONFIGURE FAILED] Return code: {configure.returncode}")
        return BuildResult(target, build_type, '\n'.join(log_content), configure.stderr + '\n' + configure.stdout)

    log_content.append("\n[CONFIGURE SUCCESS]")
    return BuildResult(target, build_type, '\n'.join(log_content))


def build_preset(folder: Path, build_type: str, target: str) -> BuildResult:
    """Build a specific CMake preset. Assumes configure has already been run."""
    linux_prefix: list[str] = []
    build_dir: Path | str = folder / 'build' / f'{target}-{build_type.lower()}'

    if platform.system() == "Windows" and target in ("web", "linux"):
        linux_prefix = ['wsl']
        build_dir = windows_to_wsl_path(build_dir)
    else:
        build_dir = str(build_dir)

    log_content: list[str] = []
    log_content.append(SEPARATOR)
    log_content.append(f"Build: {target.upper()} {build_type}")
    log_content.append(SEPARATOR)

    config_build_type: str = build_type if build_type != "developer-release" else "Release"
    build = subprocess.run(
        linux_prefix + ['cmake', '--build', build_dir, '--config', config_build_type],
        capture_output=True, text=True, encoding="utf-8"
    )
    log_content.append(build.stdout)
    if build.stderr:
        log_content.append(build.stderr)

    if build.returncode != 0:
        log_content.append(f"\n[BUILD FAILED] Return code: {build.returncode}")
        return BuildResult(target, build_type, '\n'.join(log_content), build.stderr + '\n' + build.stdout)

    log_content.append("\n[BUILD SUCCESS]")
    return BuildResult(target, build_type, '\n'.join(log_content))


def build_all(folder: Path, target_filter: list[str] | None = None, build_type_filter: list[str] | None = None) -> int:
    """Build all presets and return exit code (0=success, 1=failure)."""
    print(SEPARATOR)
    print("  BUILD ALL PRESETS")
    print(SEPARATOR)

    # Determine targets
    if target_filter:
        targets = target_filter
    else:
        targets = list(BASE_TARGETS)
        if platform.system() == "Windows":
            targets.append('windows')

    # Determine build types
    build_types = build_type_filter if build_type_filter else list(BUILD_TYPES)

    print(f"Targets: {', '.join(targets)}")
    print(f"Build types: {', '.join(build_types)}")
    print()

    total: int = len(targets) * len(build_types)

    # Step 1: Configure all presets sequentially (to avoid data races with caching dependencies)
    print("\nSTEP 1: Configuring all presets...")
    print(SEPARATOR)

    configure_errors: list[BuildResult] = []
    count: int = 0

    for target in targets:
        for build_type in build_types:
            count += 1
            print(f"\n[{count}/{total}] Configuring {target.upper()} {build_type}...")

            result = configure_preset(folder, build_type, target)
            print(result.output)

            if result.success:
                print(f"[OK] Configure: {target.upper()} {build_type}")
            else:
                print(f"[FAIL] Configure: {target.upper()} {build_type}")
                configure_errors.append(result)

    # If any configure failed, stop here
    if configure_errors:
        print()
        print(SEPARATOR)
        print("  CONFIGURE SUMMARY")
        print(SEPARATOR)
        print(f"Total: {total}, Failed: {len(configure_errors)}")
        print("\nFailed configurations:")
        for result in configure_errors:
            print(f"  - {result.target.upper()} {result.build_type}")
        print("\nStopping - cannot build without successful configuration.")
        return 1

    print()
    print(SEPARATOR)
    print(f"All {total} configurations succeeded!")
    print(SEPARATOR)

    # Step 2: Build all presets in parallel (safe after all are configured)
    print("\nSTEP 2: Building all presets...")
    print(SEPARATOR)

    build_errors: list[BuildResult] = []
    build_successes: list[BuildResult] = []
    count = 0

    with ThreadPoolExecutor() as executor:
        futures: list[Future[BuildResult]] = [
            executor.submit(build_preset, folder, build_type, target)
            for target in targets for build_type in build_types
        ]

        for future in as_completed(futures):
            result = future.result()
            count += 1

            print(result.output)

            if result.success:
                print(f"[{count}/{total}] [OK] Build: {result.target.upper()} {result.build_type}")
                build_successes.append(result)
            else:
                print(f"[{count}/{total}] [FAIL] Build: {result.target.upper()} {result.build_type}")
                build_errors.append(result)
            print()

    # Final summary
    print()
    print(SEPARATOR)
    print("  BUILD SUMMARY")
    print(SEPARATOR)
    print(f"Total: {total}, Passed: {len(build_successes)}, Failed: {len(build_errors)}")
    print()

    if build_errors:
        print("Failed builds:")
        for result in build_errors:
            print(f"  - {result.target.upper()} {result.build_type}")
        print()
        return 1
    else:
        print(f"All {total} builds succeeded!")
        return 0


def main() -> int:
    """Main entry point."""
    try:
        parser = argparse.ArgumentParser(
            description="Builds a project using CMake presets.",
            formatter_class=argparse.RawDescriptionHelpFormatter,
            epilog="""Examples:
  %(prog)s                                    # Build all configurations
  %(prog)s --target web                       # Build only web target
  %(prog)s --build-type debug release         # Build only debug and release configurations
  %(prog)s --target web --build-type debug    # Build only web debug configuration
            """
        )
        parser.add_argument(
            "directory",
            nargs="?",
            type=Path,
            default=Path.cwd(),
            help="Project directory (default: current working directory)"
        )
        parser.add_argument(
            "--target",
            nargs="+",
            choices=['windows', 'web', 'linux'],
            help="Build only specified targets"
        )
        parser.add_argument(
            "--build-type",
            nargs="+",
            choices=['debug', 'developer-release', 'release'],
            help="Build only specified build types"
        )
        args = parser.parse_args()

        return build_all(args.directory, args.target, args.build_type)

    except Exception as e:
        print(f"\nFATAL ERROR: {e}", file=sys.stderr)
        return 1


if __name__ == "__main__":
    if sys.stdout.encoding.lower() != "utf-8":
        sys.stdout.reconfigure(encoding="utf-8")
    if sys.stderr.encoding.lower() != "utf-8":
        sys.stderr.reconfigure(encoding="utf-8")
    sys.exit(main())
