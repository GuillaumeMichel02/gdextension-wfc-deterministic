#!/usr/bin/env python
import os
import sys

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

# Set as default target
Default(library)

# Print build info
print("Building '{}' for platform: {}, target: {}, arch: {}".format(
    lib_filename, env['platform'], env['target'], env.get('arch', 'default')))
print("Output: {}".format(os.path.join(bin_dir, lib_filename)))

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

# Set as default target
Default(library)

# Print build info
print("Building '{}' for platform: {}, target: {}, arch: {}".format(
    lib_filename, env['platform'], env['target'], env.get('arch', 'default')))
print("Output: {}".format(os.path.join(bin_dir, lib_filename)))
