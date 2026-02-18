# Programming Fun


## Quick Start

1. **Setup** your [Development Environment](docs/DevEnvironment.md)
2. **Build** the project:
   ```sh
   python scripts/build_project.py
   ```

## Build Reference

### CMake Presets

CMake presets are predefined build configurations stored in `CMakePresets.json`. We have three build types:

| Preset | Description |
|--------|-------------|
| `debug` | No optimizations, full debug symbols. Best for development and debugging. |
| `developer-release` | Optimized build with `DEVELOPER_VERSION` macro defined. Enables developer debugging tools. |
| `release` | Full optimizations, no debug symbols. For final distribution. |

Each build type is combined with a platform target (e.g., `windows-debug`, `linux-release`, `web-developer-release`).

### Build Script Options

```sh
python scripts/build_project.py                      # Scan and build all configurations
python scripts/build_project.py --skip-todos         # Skip TODO/FIXME scanning
python scripts/build_project.py --skip-opengl        # Skip OpenGL usage scanning
python scripts/build_project.py --skip-build         # Scan only, no building
python scripts/build_project.py --target web         # Build only web target
python scripts/build_project.py --target windows --build-type debug  # Build specific target and type
```

### Manual CMake

```sh
# Windows
cmake --preset windows-debug && cmake --build --preset windows-debug
# Web
cmake --preset web-debug && cmake --build --preset web-debug
# Linux
cmake --preset linux-debug && cmake --build --preset linux-debug
```

### Build Output

| Platform | Location |
|----------|----------|
| Windows | `build/windows-{debug,developer-release,release}/graphics_fun.exe` |
| Linux | `build/linux-{debug,developer-release,release}/graphics_fun` |
| Web | `build/web-{debug,developer-release,release}/graphics_fun.html` |
