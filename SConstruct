import os
import sys
from SCons.Script import *
from SCons.Node.FS import File

# Get build parameters
arch = ARGUMENTS.get("arch", "")
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

# Auto-detect architecture if not specified
if arch == "":
    import platform as platform_module
    if platform == "windows":
        arch = "x86_64"  # Default for Windows
    elif platform == "macos":
        arch = "arm64" if platform_module.machine() == "arm64" else "x86_64"
    else:
        arch = "x86_64"  # Default for Linux

print(f"=== Build Configuration ===")
print(f"Platform: {platform}")
print(f"Architecture: {arch}")
print(f"Target: {target}")
print(f"Arguments: {dict(ARGUMENTS)}")

# Map new target names to old ones for library naming
if target == "template_release":
    lib_target = "release"
elif target == "template_debug":
    lib_target = "debug"
else:
    lib_target = target

print(f"Mapped lib_target: {lib_target}")

# Setup environment - use default tools
env = Environment(tools=["default"])

# Godot-cpp path
godot_cpp_path = "godot-cpp"
godot_cpp_lib_path = os.path.join(godot_cpp_path, "bin")

# Include paths
env.Append(CPPPATH=[
    os.path.join(godot_cpp_path, "include"),
    os.path.join(godot_cpp_path, "gen", "include"),
    os.path.join(godot_cpp_path, "gdextension")
])

# Common C++ standard and defines
env.Append(CXXFLAGS=["-std=c++17" if platform != "windows" or ARGUMENTS.get("use_mingw", "no") == "yes" else "/std:c++17"])
env.Append(CPPDEFINES=["GDEXTENSION"])

# Platform-specific configuration following godot-cpp patterns
if platform == "windows":
    use_mingw = ARGUMENTS.get("use_mingw", "no") == "yes"
    
    # Set target architecture
    target_arch = arch
    library_name = f"wfc.{lib_target}.{target_arch}.dll"
    
    if use_mingw:
        print(f"Configuring MinGW build for {target_arch}")
        
        # MinGW defines and flags (following godot-cpp windows.py pattern)
        env.Append(CPPDEFINES=["WINDOWS_ENABLED", "__MINGW32__", "NOMINMAX"])
        env.Append(CCFLAGS=["-Wwrite-strings"])
        
        # Cross-compilation setup for MinGW
        if target_arch == "arm64":
            prefix = "aarch64-w64-mingw32"
        elif target_arch == "x86_64":
            prefix = "x86_64-w64-mingw32"
        elif target_arch == "x86_32":
            prefix = "i686-w64-mingw32"
        else:
            prefix = "x86_64-w64-mingw32"  # fallback
        
        # Set MinGW tools if cross-compiling
        mingw_prefix = ARGUMENTS.get("mingw_prefix", "")
        if mingw_prefix:
            tool_prefix = f"{mingw_prefix}/bin/{prefix}"
            env["CXX"] = f"{tool_prefix}-g++"
            env["CC"] = f"{tool_prefix}-gcc"
            env["AR"] = f"{tool_prefix}-gcc-ar"
            env["RANLIB"] = f"{tool_prefix}-ranlib"
            env["LINK"] = f"{tool_prefix}-g++"
        
        # MinGW linking flags
        env.Append(LINKFLAGS=["-Wl,--no-undefined"])
        if ARGUMENTS.get("use_static_cpp", "yes") == "yes":
            env.Append(LINKFLAGS=["-static", "-static-libgcc", "-static-libstdc++"])
        
        # Set library prefixes/suffixes
        env["SHLIBPREFIX"] = ""
        env["SHLIBSUFFIX"] = ".dll"
        
        # Optimization flags
        if target == "template_debug":
            env.Append(CCFLAGS=["-g", "-O0"])
            env.Append(CPPDEFINES=["DEBUG_ENABLED"])
        else:
            env.Append(CCFLAGS=["-O3"])
            env.Append(CPPDEFINES=["NDEBUG"])
        
        # Link godot-cpp (MinGW uses .a files)
        godot_cpp_lib = f"godot-cpp.{platform}.{target}.{target_arch}"
    
    else:
        print(f"Configuring MSVC build for {target_arch}")
        
        # MSVC setup (following godot-cpp windows.py pattern)
        if target_arch == "x86_64":
            env["TARGET_ARCH"] = "amd64"
        elif target_arch == "arm64":
            env["TARGET_ARCH"] = "arm64"
        elif target_arch == "arm32":
            env["TARGET_ARCH"] = "arm"
        elif target_arch == "x86_32":
            env["TARGET_ARCH"] = "x86"
        
        env["is_msvc"] = True
        
        # MSVC defines and flags
        env.Append(CPPDEFINES=["TYPED_METHOD_BIND", "NOMINMAX", "WINDOWS_ENABLED"])
        env.Append(CCFLAGS=["/utf-8"])
        
        # Runtime library flags
        if ARGUMENTS.get("use_static_cpp", "yes") == "yes":
            env.Append(CCFLAGS=["/MT" if target == "template_release" else "/MTd"])
        else:
            env.Append(CCFLAGS=["/MD" if target == "template_release" else "/MDd"])
        
        # Linker flags
        env.Append(LINKFLAGS=["/WX:NO"])  # Don't treat warnings as errors
        
        # Set target machine for linker
        if target_arch == "arm64":
            env.Append(LINKFLAGS=["/MACHINE:ARM64"])
        else:
            env.Append(LINKFLAGS=["/MACHINE:X64"])
        
        # Optimization flags
        if target == "template_debug":
            env.Append(CCFLAGS=["/Zi", "/Od"])
            env.Append(LINKFLAGS=["/DEBUG"])
            env.Append(CPPDEFINES=["DEBUG_ENABLED"])
        else:
            env.Append(CCFLAGS=["/O2"])
            env.Append(CPPDEFINES=["NDEBUG"])
        
        # Set library prefixes/suffixes for MSVC
        env["SHLIBPREFIX"] = ""
        env["SHLIBSUFFIX"] = ".dll"
        
        # Link godot-cpp (MSVC needs lib prefix and .lib extension)
        godot_cpp_lib = f"libgodot-cpp.{platform}.{target}.{target_arch}.lib"
    
    print(f"Building for Windows {target_arch} with {'MinGW' if use_mingw else 'MSVC'}")
    print(f"Looking for godot-cpp library: {godot_cpp_lib}")
    
    env.Append(LIBPATH=[godot_cpp_lib_path])
    env.Append(LIBS=[godot_cpp_lib])

elif platform == "macos":
    env.Append(CXXFLAGS=["-fPIC"])
    env.Append(LINKFLAGS=["-Wl,-undefined,dynamic_lookup"])
    
    # Architecture detection
    target_arch = ARGUMENTS.get("arch", "arm64")  # Default to arm64 for Apple Silicon
    library_name = f"wfc.{lib_target}.{target_arch}.dylib"
    
    print(f"=== macOS Build Details ===")
    print(f"Requested architecture: {target_arch}")
    print(f"Library name: {library_name}")
    
    # Link godot-cpp - make sure we're linking the right architecture
    godot_cpp_lib = f"libgodot-cpp.{platform}.{target}.{target_arch}.a"
    godot_cpp_lib_path_full = os.path.join(godot_cpp_lib_path, godot_cpp_lib)
    
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

elif platform == "web":
    # Web/WebAssembly platform using Emscripten
    print("Configuring for Web/WebAssembly platform with Emscripten")
    
    # Check for Emscripten tools
    import shutil
    emcc_path = shutil.which("emcc")
    if not emcc_path:
        print("ERROR: emcc not found! Make sure Emscripten SDK is installed and activated.")
        Exit(1)
    
    print(f"Found Emscripten compiler: {emcc_path}")
    
    # Configure Emscripten toolchain
    env['CC'] = 'emcc'
    env['CXX'] = 'em++'
    env['AR'] = 'emar'
    env['LINK'] = 'em++'
    
    # Emscripten-specific C++ flags (similar to Unix but with Web-specific additions)
    env.Append(CXXFLAGS=["-std=c++17", "-fPIC"])
    if target == "template_debug":
        env.Append(CXXFLAGS=["-g", "-O0", "-DDEBUG_ENABLED"])
    else:  # template_release or release
        env.Append(CXXFLAGS=["-O3", "-DNDEBUG"])
    
    # Emscripten-specific linker flags
    env.Append(LINKFLAGS=[
        "-s", "SIDE_MODULE=1",  # Create a side module that can be loaded by Godot
        "-s", "EXPORT_ALL=1"    # Export all symbols
    ])
    
    # Architecture is always wasm32 for web
    target_arch = ARGUMENTS.get("arch", "wasm32")
    library_name = f"wfc.{lib_target}.{target_arch}.wasm"
    
    # Link godot-cpp
    godot_cpp_lib = f"libgodot-cpp.{platform}.{target}.{target_arch}.a"
    godot_cpp_lib_path_full = os.path.join(godot_cpp_lib_path, godot_cpp_lib)
    
    print(f"Building for Web {target_arch}")
    print(f"Looking for godot-cpp library: {godot_cpp_lib_path_full}")
    
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

# Remove the automatic "lib" prefix that SCons adds on Unix systems
if platform != "windows":
    env["SHLIBPREFIX"] = ""

library = env.SharedLibrary(target=library_path, source=sources)

print(f"=== Build Summary ===")
print(f"Output library: {library_path}")
print(f"Platform: {platform}, Architecture: {target_arch}")
print(f"Target: {target} -> {lib_target}")

# Set default target
env.Default(library)
