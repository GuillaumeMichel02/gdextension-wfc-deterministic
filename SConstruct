#!/usr/bin/env python
import os
import sys
import subprocess

# Define our library name
libname = "wfc"

# Create local environment to configure godot-cpp options
localEnv = Environment(tools=["default"], PLATFORM="")

# Build options (similar to official template)
customs = []
opts = Variables(customs, ARGUMENTS)
opts.Update(localEnv)

env = localEnv.Clone()

# Check if godot-cpp is available
if not (os.path.isdir("godot-cpp") and os.listdir("godot-cpp")):
    print("ERROR: godot-cpp is not available within this folder, as Git submodules haven't been initialized.")
    print("Run the following command to download godot-cpp:")
    print()
    print("    git submodule update --init --recursive")
    sys.exit(1)

# Call the godot-cpp SConstruct to set up the environment with all platform-specific details
# Note: godot-cpp's build system is smart about incremental builds and will reuse existing libraries
env = SConscript("godot-cpp/SConstruct", exports={"env": env, "customs": customs})

# Add our source directory to include path
env.Append(CPPPATH=["./"])

# Gather our source files
sources = Glob("*.cpp")

# Get the suffix from godot-cpp environment (contains platform, arch, target info)
suffix = env['suffix']

# Build our library filename using godot-cpp's naming convention
lib_filename = "{}{}{}{}".format(env.subst('$SHLIBPREFIX'), libname, suffix, env.subst('$SHLIBSUFFIX'))

# Create the platform-specific directory under bin/
bin_dir = "bin/{}".format(env['platform'])
if not os.path.exists(bin_dir):
    os.makedirs(bin_dir)

# Build the shared library
library = env.SharedLibrary(
    "{}/{}".format(bin_dir, lib_filename),
    source=sources,
)

# Add code signing for macOS
def sign_macos_library(target, source, env):
    """Sign macOS dynamic libraries to avoid security warnings"""
    for t in target:
        lib_path = str(t)
        print(f"Signing macOS library: {lib_path}")
        try:
            # Use ad-hoc signing (no developer certificate required)
            result = subprocess.run([
                "codesign", "--force", "--deep", "--sign", "-", lib_path
            ], capture_output=True, text=True, check=True)
            print(f"Successfully signed: {lib_path}")
        except subprocess.CalledProcessError as e:
            print(f"Warning: Failed to sign {lib_path}")
            print(f"Error: {e.stderr}")
            print("You may need to manually sign the library with:")
            print(f"  codesign --force --deep --sign - {lib_path}")
        except FileNotFoundError:
            print("Warning: codesign not found. Skipping code signing.")
            print("Install Xcode Command Line Tools if you need code signing.")

# Add post-build action for macOS to sign the library
if env['platform'] == 'macos':
    env.AddPostAction(library, sign_macos_library)

# Set as default target
Default(library)

# Print build info
print("Building '{}' for platform: {}, target: {}, arch: {}".format(
    lib_filename, env['platform'], env['target'], env.get('arch', 'default')))
print("Output: {}".format(os.path.join(bin_dir, lib_filename)))

# Alternative build method (keeping for compatibility/reference)
# This section ensures all source files are properly included
print("Source files found: {}".format([str(f) for f in sources]))

# Verify all required source files exist
required_sources = ["entry.cpp", "WFCChunk.cpp"]
for src in required_sources:
    if not os.path.exists(src):
        print("Warning: Required source file '{}' not found".format(src))
    else:
        print("Found: {}".format(src))
