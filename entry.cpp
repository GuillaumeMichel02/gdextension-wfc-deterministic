#include <godot_cpp/godot.hpp>
#include "WFCChunk.hpp"

using namespace godot;

// This function registers the extension and the class
extern "C" {
GDExtensionBool GDExtensionInit(
    GDExtensionInterface *p_interface,
    GDExtensionClassLibraryPtr p_library,
    GDExtensionInitialization *r_initialization) {

    GDExtensionBinding::InitObject init_obj(p_interface, p_library, r_initialization);

    // Register your class with Godot here
    init_obj.register_initializer([]() {
        ClassDB::register_class<WFCChunk>();
    });

    // Define when the extension should be initialized (scene = ready for nodes/resources)
    init_obj.set_minimum_library_initialization_level(MODULE_INITIALIZATION_LEVEL_SCENE);
    init_obj.initialize();
    
    return true;
}
}