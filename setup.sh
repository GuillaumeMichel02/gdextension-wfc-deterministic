#!/bin/bash

echo "Setting up Godot GDExtension environment..."

# Install SCons if not present
if ! command -v scons &> /dev/null; then
    echo "SCons not found. Installing..."
    if command -v brew &> /dev/null; then
        brew install scons
    elif command -v pip3 &> /dev/null; then
        pip3 install scons
    else
        echo "Please install SCons manually: pip install scons or brew install scons"
        exit 1
    fi
fi

# Clone godot-cpp if not present
if [ ! -d "godot-cpp" ]; then
    echo "Cloning godot-cpp..."
    git clone --recursive https://github.com/godotengine/godot-cpp.git
    cd godot-cpp
    
    # Build godot-cpp for the current platform
    if [[ "$OSTYPE" == "darwin"* ]]; then
        echo "Building godot-cpp for macOS..."
        scons platform=macos generate_bindings=yes target=release arch=arm64
        if [[ $(uname -m) == "x86_64" ]]; then
            scons platform=macos generate_bindings=yes target=release arch=x86_64
        fi
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        echo "Building godot-cpp for Linux..."
        scons platform=linux generate_bindings=yes target=release
    elif [[ "$OSTYPE" == "msys" ]] || [[ "$OSTYPE" == "win32" ]]; then
        echo "Building godot-cpp for Windows..."
        scons platform=windows generate_bindings=yes target=release
    fi
    
    cd ..
fi

echo "Setup complete! You can now build with:"
echo "scons platform=macos target=release arch=arm64  # for Apple Silicon"
echo "scons platform=macos target=release arch=x86_64 # for Intel Mac"
echo "scons platform=linux target=release             # for Linux"
echo "scons platform=windows target=release           # for Windows"
