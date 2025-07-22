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

print(f"=== Build Configuration ===")
print(f"Platform: {platform}")
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

# C++ standard and compiler flags
if platform == "windows":
    # Check if using MinGW (recommended for CI)
    use_mingw = ARGUMENTS.get("use_mingw", "no") == "yes"
    
    if use_mingw:
        # MinGW flags (GCC-style)
        env.Append(CXXFLAGS=["-std=c++17"])
        # Add Windows-specific defines for MinGW
        env.Append(CPPDEFINES=[
            "WIN32", "_WIN32", "__MINGW32__", "NOMINMAX",
            # Fix MinGW DLL export issues
            "__DECLSPEC_SUPPORTED",  # Enable __declspec support in MinGW
            "_WINDLL"                # Define Windows DLL context
        ])
        # Fix MinGW linker issues: multiple definitions, missing math/thread functions, missing operator new/delete
        env.Append(LINKFLAGS=[
            "-static-libgcc", 
            "-static-libstdc++",
            "-Wl,--allow-multiple-definition",  # Allow multiple definitions
            "-lm",  # Link math library for math functions
            "-lpthread",  # Link pthread for threading functions
            "-lmingw32",  # MinGW runtime
            "-lgcc_s",  # GCC support library
            "-lmoldname",  # C runtime functions
            "-lmsvcrt"  # Microsoft C runtime for printf functions
        ])
        # Add compiler flags to reduce symbol conflicts
        env.Append(CXXFLAGS=[
            "-fvisibility=hidden",  # Hide symbols by default
            "-fvisibility-inlines-hidden"  # Hide inline symbols
        ])
        if target == "template_debug":
            env.Append(CXXFLAGS=["-g", "-O0", "-DDEBUG_ENABLED"])
        else:  # template_release or release
            env.Append(CXXFLAGS=["-O3", "-DNDEBUG"])
    else:
        # MSVC flags
        env.Append(CXXFLAGS=["/std:c++17"])
        # Add ARM64-specific MSVC flags if building for ARM64
        if ARGUMENTS.get("arch", "x86_64") == "arm64":
            # Note: /arch:ARM64 is not valid, ARM64 is the default for ARM64 builds
            env.Append(CPPDEFINES=["_ARM64_"])
            # Add workaround for ARM64 method binding issues
            env.Append(CPPDEFINES=[
                "_ALLOW_ITERATOR_DEBUG_LEVEL_MISMATCH", 
                "_ALLOW_RUNTIME_LIBRARY_MISMATCH",
                "GODOT_CPP_ARM64_WORKAROUND"  # Custom define for our workaround
            ])
        if target == "template_debug":
            env.Append(CXXFLAGS=["/Zi", "/Od", "/DDEBUG_ENABLED"])
        else:  # template_release or release
            env.Append(CXXFLAGS=["/O2", "/DNDEBUG"])
else:
    # GCC/Clang flags for Unix platforms
    env.Append(CXXFLAGS=["-std=c++17"])
    if target == "template_debug":
        env.Append(CXXFLAGS=["-g", "-O0", "-DDEBUG_ENABLED", "-fno-omit-frame-pointer"])
    else:  # template_release or release
        env.Append(CXXFLAGS=["-O3", "-DNDEBUG", "-fomit-frame-pointer"])

# Platform-specific settings
if platform == "windows":
    # Check if using MinGW (recommended for CI)
    use_mingw = ARGUMENTS.get("use_mingw", "no") == "yes"
    
    if not use_mingw:
        # Only add MSVC-specific flags when NOT using MinGW
        env.Append(CXXFLAGS=["/MD"])
        env.Append(LINKFLAGS=["/WX:NO"])
        # Add Windows-specific defines for MSVC
        env.Append(CPPDEFINES=["WIN32", "_WIN32", "NOMINMAX"])
    
    # Architecture detection
    target_arch = ARGUMENTS.get("arch", "x86_64")
    library_name = f"wfc.{lib_target}.{target_arch}.dll"
    
    # Link godot-cpp - handle different naming conventions for MinGW vs MSVC
    if use_mingw:
        # MinGW uses .a files
        godot_cpp_lib = f"godot-cpp.{platform}.{target}.{target_arch}"
    else:
        # MSVC uses lib prefix and .lib extension
        godot_cpp_lib = f"libgodot-cpp.{platform}.{target}.{target_arch}.lib"
    
    compiler_type = "MinGW" if use_mingw else "MSVC"
    print(f"Building for Windows {target_arch} with {compiler_type}")
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
Default(library)
