# det-wfc-gdextension
GDExtension for a deterministic WFC algorithm regardless of the starting point

## Installation

1. Download the latest release from the [Releases](../../releases) page
2. Extract the `wfc-gdextension-cross-platform.tar.gz` file
3. Copy the `wfc/` folder to your Godot project's `addons/` directory
4. Restart Godot

Your project structure should look like:

```text
your_project/
├── addons/
│   └── wfc/
│       ├── wfc.gdextension
│       ├── plugin.cfg
│       └── bin/
│           ├── macos/
│           ├── windows/
│           ├── linux/
│           └── web/
└── ...
```

## macOS Users - Quarantine Issue

macOS may block the downloaded libraries due to quarantine attributes. If you see errors like "libwfc cannot be opened because the developer cannot be verified", you have several options:

### Option 1: Use the Included Script (Recommended)

Run the included quarantine removal script:

```bash
cd /path/to/your/project/addons/wfc
./remove_quarantine_macos.sh
```

### Option 2: Manual Command

Remove quarantine attributes manually:

```bash
xattr -dr com.apple.quarantine /path/to/your/project/addons/wfc/bin/macos/
```

### Option 3: Individual Files

For each library file:

```bash
xattr -d com.apple.quarantine /path/to/your/project/addons/wfc/bin/macos/libwfc.*.dylib
```

## Usage

Once installed, you can use the WFC extension in your GDScript:

```gdscript
# Create a WFC chunk
var wfc_chunk = WFCChunk.new()

# Your WFC algorithm code here
```

## Building from Source

See [BUILD.md](BUILD.md) for detailed build instructions.

## License

MIT License - see [LICENSE](LICENSE) for details.
