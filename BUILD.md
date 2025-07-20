## Build Instructions

### Prerequisites
- Python 3.6+
- SCons (install with `pip install scons` or `brew install scons`)
- Git

### Setup
1. Run the setup script to install dependencies:
   ```bash
   ./setup.sh
   ```

### Building

#### For macOS:
```bash
# Apple Silicon (M1/M2/M3)
scons platform=macos target=release arch=arm64

# Intel Mac
scons platform=macos target=release arch=x86_64

# Debug builds
scons platform=macos target=debug arch=arm64
```

#### For Linux:
```bash
scons platform=linux target=release arch=x86_64
scons platform=linux target=debug arch=x86_64
```

#### For Windows:
```bash
scons platform=windows target=release arch=x86_64
scons platform=windows target=debug arch=x86_64
```

### Output
Built libraries will be placed in the `bin/` directory with the correct naming convention:
- macOS: `wfc.release.arm64.dylib` / `wfc.release.x86_64.dylib`
- Linux: `wfc.release.x86_64.so`
- Windows: `wfc.release.x86_64.dll`

### Usage in Godot
1. Copy the built library and the `wfc.gdextension` file to your Godot project
2. The `WFCChunk` class will be available in GDScript:
   ```gdscript
   var wfc = WFCChunk.new()
   wfc.generate(12345)  # Generate with seed
   var grid = wfc.get_flat_grid()  # Get the result as 1D array
   ```
