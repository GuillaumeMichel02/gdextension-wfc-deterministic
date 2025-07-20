import os
import sys

# Get build parameters
platform = ARGUMENTS.get("platform", "")
target = ARGUMENTS.get("target", "template_release")

# Auto-detect platform if not specified
if platform == "":
    if sys.platform.startswith("win"):
        platform = "windows"
    elif sys.platform == "darwin":
        platform = "macos"
    else:
        platform = "linux"

# Map new target names to old ones for library naming
if target == "template_release":
    lib_target = "release"
elif target == "template_debug":
    lib_target = "debug"
else:
    lib_target = target

# Setup environment
env = Environment()

# Godot-cpp path
godot_cpp_path = "godot-cpp"
godot_cpp_lib_path = os.path.join(godot_cpp_path, "bin")

# Include paths
env.Append(CPPPATH=[
    os.path.join(godot_cpp_path, "include"),
    os.path.join(godot_cpp_path, "gen", "include"),
    os.path.join(godot_cpp_path, "gdextension")
])

# C++ standard
env.Append(CXXFLAGS=["-std=c++17"])

# Debug/Release flags
if target == "template_debug":
    env.Append(CXXFLAGS=["-g", "-O0", "-DDEBUG_ENABLED"])
    if platform != "windows":
        env.Append(CXXFLAGS=["-fno-omit-frame-pointer"])
else:  # template_release or release
    env.Append(CXXFLAGS=["-O3", "-DNDEBUG"])
    if platform != "windows":
        env.Append(CXXFLAGS=["-fomit-frame-pointer"])

# Platform-specific settings
if platform == "windows":
    env.Append(CXXFLAGS=["/MD"])
    env.Append(LINKFLAGS=["/WX:NO"])
    
    # Architecture detection
    target_arch = ARGUMENTS.get("arch", "x86_64")
    library_name = f"wfc.{lib_target}.{target_arch}.dll"
    
    # Link godot-cpp
    godot_cpp_lib = f"godot-cpp.{platform}.{target}.{target_arch}"
    
    print(f"Building for Windows {target_arch}")
    print(f"Looking for godot-cpp library: {godot_cpp_lib}")
    
    env.Append(LIBPATH=[godot_cpp_lib_path])
    env.Append(LIBS=[godot_cpp_lib])

elif platform == "macos":
    env.Append(CXXFLAGS=["-fPIC"])
    env.Append(LINKFLAGS=["-Wl,-undefined,dynamic_lookup"])
    
    # Architecture detection
    target_arch = ARGUMENTS.get("arch", "arm64")  # Default to arm64 for Apple Silicon
    library_name = f"wfc.{lib_target}.{target_arch}.dylib"
    
    # Link godot-cpp - make sure we're linking the right architecture
    godot_cpp_lib = f"libgodot-cpp.{platform}.{target}.{target_arch}.a"
    godot_cpp_lib_path_full = os.path.join(godot_cpp_lib_path, godot_cpp_lib)
    
    print(f"Building for macOS {target_arch}")
    print(f"Looking for godot-cpp library: {godot_cpp_lib_path_full}")
    
    # Verify the library exists
    if not os.path.exists(godot_cpp_lib_path_full):
        print(f"ERROR: godot-cpp library not found at {godot_cpp_lib_path_full}")
        print("Available libraries:")
        if os.path.exists(godot_cpp_lib_path):
            for f in os.listdir(godot_cpp_lib_path):
                if f.startswith("libgodot-cpp") and f.endswith(".a"):
                    print(f"  {f}")
        Exit(1)
    
    env.Append(LIBPATH=[godot_cpp_lib_path])
    env.Append(LIBS=[File(godot_cpp_lib_path_full)])

else:  # linux
    env.Append(CXXFLAGS=["-fPIC"])
    
    # Architecture detection
    target_arch = ARGUMENTS.get("arch", "x86_64")
    library_name = f"wfc.{lib_target}.{target_arch}.so"
    
    # Link godot-cpp
    godot_cpp_lib = f"libgodot-cpp.{platform}.{target}.{target_arch}.a"
    godot_cpp_lib_path_full = os.path.join(godot_cpp_lib_path, godot_cpp_lib)
    
    print(f"Building for Linux {target_arch}")
    print(f"Looking for godot-cpp library: {godot_cpp_lib_path_full}")
    
    env.Append(LIBPATH=[godot_cpp_lib_path])
    env.Append(LIBS=[File(godot_cpp_lib_path_full)])

# Create bin directory if it doesn't exist
bin_dir = "bin"
if not os.path.exists(bin_dir):
    os.makedirs(bin_dir)

# Source files
sources = ["WFCChunk.cpp", "entry.cpp"]

# Build the shared library
library_path = os.path.join(bin_dir, library_name)
library = env.SharedLibrary(target=library_path, source=sources)

# Set default target
Default(library)
